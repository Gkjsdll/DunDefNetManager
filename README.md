# What is this script
[Dungeon Defenders](https://store.steampowered.com/app/65800/Dungeon_Defenders/) has issues hosting multiplayer matches when more than one network adapter is enabled. [^1] This script does the following:
- Copies itself to your system
- Sets up a task to automatically run the script whenever any user logs on
- Disables all but one network adapter when Dungeon Defenders is running
- Reenables adapters after Dungeon Defenders closes
- Starts running immediately after install

# How to install or update
1. Download the latest version of this script
2. Run powershell as administrator
3. Run the script to install and run the script

[^1]: [Steam discussion on issue hosting game](https://steamcommunity.com/app/65800/discussions/0/617320628261238972/)