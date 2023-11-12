# CREWS
[![GitHub release](https://img.shields.io/github/v/release/LikeManTV/crews.svg)](https://github.com/LikeManTV/crews/releases/latest)
[![GitHub license](https://img.shields.io/github/license/LikeManTV/crews.svg)](LICENSE)
<a href="https://discordapp.com/invite/54jH2Uu7tc" title="Chat on Discord"><img alt="Discord Status" src="https://discordapp.com/api/guilds/912329245789933569/widget.png"></a>   
A crew system for FiveM.

Please report any problems by creating a new issue or join the Discord server.
Also feel free to make a PR.

## Features
- Crew menu
- Crew tag & name
- Player invitation
- Member management
- Ranks & permissions (WIP)
- Settings
- Blips between members
- Nametags above head (/crewTags to hide)

## Dependencies
- [oxmysql](https://github.com/overextended/oxmysql)
- [ox_lib](https://github.com/overextended/ox_lib)

## Installation
1. Download latest release or source code
2. Extract the .zip file
3. Copy the folder to your server resources folder
4. Add `ensure crews` to your server.cfg
5. Restart the server

`OPTIONAL` - If you want to have permissions compatible with HRS scripts.
Follow the tutorial in `HRS-INTEGRATION.txt`

## Known issues
- Random blip duplication

## Exports (client)
- getCrew - returns table with crew data
- ownsCrew - returns true if player owns a crew
- isInCrew - returns true if player is in crew

## Exports (server)
- ownsCrew(identifier) - returns true if player owns a crew
- isInCrew(owner, identifier) - returns true if player is in crew
- getCrewName(netId) - returns crew name of players crew
- getCrewTag(netId) - returns crew tag of players crew
