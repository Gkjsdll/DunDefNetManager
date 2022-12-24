# What is this script
[Dungeon Defenders](https://store.steampowered.com/app/65800/Dungeon_Defenders/) has issues hosting multiplayer matches when more than one network adapter is enabled. [^1]

This script automatically disables all but one adapter while Dungeon Defenders is running, then re-enables them after the game closes. It also recovers if your computer crashes & still re-enables the adapters.

By default, this script installs itself to your system and runs automatically. To avoid the install, you can set the [portableMode](#portablemode) option to `$true`.

# How to run, install, or update
1. Download the latest version of this script
2. Change any options
3. Run PowerShell as administrator
    - [How to](https://learn.microsoft.com/en-us/powershell/scripting/windows-powershell/starting-windows-powershell?view=powershell-7.3#with-administrative-privileges-run-as-administrator)
4. Run the script to install and run the script

# Options

## Basic

### portableMode
(`default: $false`)

Runs the script in-place without installing it.

## Advanced

### autoDetectPrimaryInterface
(`default: $true`)

Detects primary network interface automatically when Dungeon Defenders is launched to determine which other interfaces should be disabled.

You must set [overrideInterfaceName](#overrideinterfacename) when setting this to `$false`.

### overrideInterfaceName
Set this to the name of a specific network interface to choose which you'll use when playing Dungeon Defenders.

Ignored when [autoDetectPrimaryInterface](#autoDetectPrimaryInterface) is  `$true`.

Interface names can be found by:
1. Press `Win+R`
2. Enter `powershell -Command Get-NetAdapter; Pause`
3. Click OK

### scriptDirPath
(`default: "C:\DunDefScripts"`)

The location where the script will be installed.

### taskName
(`default: "Dungeon Defenders Network Manager"`)

The name of the task created during install to run the script automatically.

### waitSeconds
(`default: 15`)

Ignored if you do not have any Hyper V virtual network interfaces.

Determines how long to wait between re-enabling normal & HyperV virtual network interfaces.

An error will be shown when running [portableMode](#portablemode) if you have any HyperV interfaces which need more time, in which case you should increase this number.

[^1]: [Steam discussion on issue hosting game](https://steamcommunity.com/app/65800/discussions/0/617320628261238972/)