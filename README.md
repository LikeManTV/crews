# CREWS
[![GitHub release](https://img.shields.io/github/v/release/LikeManTV/crews.svg)](https://github.com/LikeManTV/crews/releases/latest)
[![GitHub license](https://img.shields.io/github/license/LikeManTV/crews.svg)](LICENSE)
<a href="https://discordapp.com/invite/55aQNKzQVW" title="Chat on Discord"><img alt="Discord Status" src="https://discordapp.com/api/guilds/912329245789933569/widget.png"></a>

The crew system facilitates seamless coordination and management of team members within the game. It offers players a structured approach to assemble and organize their crew, ensuring efficient teamwork and collaboration. With the crew system, players can easily recruit, assign roles, and communicate with their crew members, enhancing their strategic gameplay experience.

Please report any problems by creating a new issue or join the Discord server.
Also feel free to make a PR.

## Features
- Supports ESX, QB & OX
- Crew menu
- Crew tag & name
- Player invitation
- Member management
  - Ranks & permissions (WIP)
  - Crew ownership transfer (WIP)
- Settings
  - Rename crew
  - Change tag
- Blips between members
- Nametags above head (/crewTags to hide)
  - Player's health

## Dependencies
- [oxmysql](https://github.com/overextended/oxmysql)
- [ox_lib](https://github.com/overextended/ox_lib)

## Installation
1. Download latest release or source code
2. Extract the .zip file
3. Copy the folder to your server resources folder
4. Run the `SETUP/crews.sql` file
5. Add `ensure crews` to your server.cfg
6. Restart the server

`OPTIONAL` - If you want to have permissions compatible with HRS scripts.
- Follow the tutorial in `SETUP/HRS-INTEGRATION.txt`

## Known issues
- Random blip duplication

## Exports (client)
- `getCrew()` - returns table with crew data
- `ownsCrew()` - returns true if player owns a crew
- `isInCrew()` - returns true if player is in crew
- `getCrewOwner()` - returns the identifier of your current crew owner

## Exports (server)
- `ownsCrew(netId)` - returns true if player owns a crew
- `ownsCrew2(identifier)` - returns true if player owns a crew
- `isInCrew(netId)` - returns true if player is in a crew
- `isInCrew2(identifier)` - returns true if player is in a crew
- `isInPlayersCrew(owner, player)` - returns true if player is in other player's crew (uses identifiers)
- `getCrewName(netId)` - returns crew name of players crew
- `getCrewTag(netId)` - returns crew tag of players crew
- `getCrewMembers(netId)` - returns table containing server IDs of all members

Credits: Vallorz, HRS
