# What is this script
[Dungeon Defenders](https://store.steampowered.com/app/65800/Dungeon_Defenders/) has issues hosting multiplayer matches when more than one network adapter is enabled. [^1] This script does the following:
- Copies itself to your system
- Sets up a task to automatically run the script whenever any user logs on
- Disables all but one network adapter when Dungeon Defenders is running
- Reenables adapters after Dungeon Defenders closes
- Starts running immediately after install

# How to run, install, or update
1. Download the latest version of this script
2. Change any options
3. Run powershell as administrator
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

Determines how long to wait between enabling normal & HyperV virtual network interfaces. An error will be shown when running [portableMode](#portablemode) if you have any HyperV interfaces which need more time, in which case you should increase this number.

[^1]: [Steam discussion on issue hosting game](https://steamcommunity.com/app/65800/discussions/0/617320628261238972/)