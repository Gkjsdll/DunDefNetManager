#Requires -RunAsAdministrator

# Set to true to run the script in-place without installing it to the system
$portableMode = $false

# Set to false in order to manually specify the network interface which should be used when playing Dungeon Defenders
$autoDetectPrimaryInterface = $true

# Replace Physical Ethernet with the adapter you will use when playing Dungeon Defenders
$overrideInterfaceName = "<REPLACE_ME>"

$scriptDirPath = "C:\DunDefScripts"
$scriptPath = "$scriptDirPath\DunDefNetManager.ps1"
$disabledAdaptersPath = "$scriptDirPath\DisabledAdapters"

$taskName = "Dungeon Defenders Network Manager"

# Set to 0 if you don't care about an error message which doesn't cause problems
# Set higher if you're getting the error, want to avoid it, and your machine takes longer to be re-create all HyperV virtual adapters 
$waitSeconds = 15

# Register & run task
function Initialize-Task() {
    $action = New-ScheduledTaskAction `
        -Execute "powershell.exe" `
        -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File $scriptPath"

    $principal = New-ScheduledTaskPrincipal `
        -UserID ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name) `
        -LogonType S4U `
        -Id Author `
        -RunLevel Highest

    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -ExecutionTimeLimit "00:00:00"

    $trigger = New-ScheduledTaskTrigger -AtLogOn

    Register-ScheduledTask -TaskName $taskName `
        -Action $action `
        -Description "Disables all non-primary network adapters while Dungeon Defenders is running to restore access to ranked multiplayer" `
        -Principal $principal `
        -Settings $settings `
        -Trigger $trigger `
    | Out-Null

    Start-ScheduledTask -TaskName $taskName
}


function Invoke-Manager() {
    Recover-Adapters

    While ($true) {
        Write-Output "Waiting for Dungeon Defenders to start..."

        While (!(Get-Process DunDefGame -ErrorAction SilentlyContinue)) {
            Start-Sleep -Seconds 1
        }

        $primaryNetworkInterfaceName = $(
            If ($autoDetectPrimaryInterface) {
                Get-NetAdapter `
                | Where-Object Status -eq Up `
                | Sort-Object ifIndex `
                | Select-Object -First 1 -Expand Name
            }
            Else { $overrideInterfaceName }
        )

        $enabledInterfaces = Get-NetAdapter `
        | Where-Object Status -ne "Disabled" `
        | Where-Object Name -ne $primaryNetworkInterfaceName `
        | Sort-Object Name
        
        # The order of the virtual adapters vs the physical adapters matters
        $hyperVInterfaces = $enabledInterfaces `
        | Where-Object InterfaceDescription -Match  "Hyper-V Virtual Ethernet Adapter*"
        $hyperVInterfaceNames = $hyperVInterfaces `
        | Select-Object -Expand Name

        $nonHyperVInterfaces = $enabledInterfaces `
        | Where-Object InterfaceDescription -NotMatch "Hyper-V Virtual Ethernet Adapter*"
        $nonHyperVInterfaceNames = $nonHyperVInterfaces `
        | Select-Object -Expand Name

        Write-Output "`nDungeon Defenders is open, disabling the following network intefaces:"
        Write-Output $hyperVInterfaceNames
        Write-Output $nonHyperVInterfaceNames

        Disable-NetAdapter -Confirm:$false -Name $hyperVInterfaceNames
        $hyperVInterfaceNames `
        | Out-File -FilePath $disabledAdaptersPath
        
        Disable-NetAdapter -Confirm:$false -Name $nonHyperVInterfaceNames
        $hyperVInterfaceNames + $nonHyperVInterfaceNames `
        | Out-File -FilePath $disabledAdaptersPath

        Write-Output "`nWaiting for Dungeon Defenders to exit..."

        Wait-Process -Name DunDefGame

        Write-Output "Dungeon Defenders has exited, re-enabling network interfaces"
        Enable-NetAdapter -Confirm:$false -Name $nonHyperVInterfaceNames
        If ($hyperVInterfaceNames) {
            $hyperVInterfaceNames `
            | Out-File -FilePath $disabledAdaptersPath
            Start-Sleep $waitSeconds
            Enable-NetAdapter -Confirm:$false -Name $hyperVInterfaceNames
        }
        Remove-Item -Path $disabledAdaptersPath
    }
}

function Main() {
    If ($portableMode -Or $PSCommandPath -eq $scriptPath) {
        Invoke-Manager
        Return
    }

    # Check if task already exists
    Get-ScheduledTask -TaskName $taskName `
        -ErrorAction SilentlyContinue `
        -OutVariable taskExists `
    | Out-Null

    # Copy script to destintaion to install/update
    mkdir -Force $scriptDirPath `
    | Out-Null
    Copy-Item $PSCommandPath $scriptPath
    
    # Stop & delete existing task
    If ($taskExists) {
        Stop-ScheduledTask -TaskName $taskName
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    }

    Initialize-Task

    If ($taskExists) {
        Write-Output "Updated script and task"
    }
    Else {
        Write-Output "Installed script as a task & started task"
    }
}

function Recover-Adapters() {
    If (-Not (Test-Path -Path $disabledAdaptersPath)) {
        Return
    }

    $adapters = Get-Content -Path $disabledAdaptersPath
    Try {
        Enable-NetAdapter -Confirm:$false -Name $adapters | Out-Null
    }
    Catch {
        Start-Sleep $waitSeconds
        Enable-NetAdapter -Confirm:$false -Name $adapters | Out-Null
    }
    Remove-Item $disabledAdaptersPath
}

Main
