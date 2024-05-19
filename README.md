# CREWS
[![GitHub release](https://img.shields.io/github/v/release/LikeManTV/crews.svg)](https://github.com/LikeManTV/crews/releases/latest)
[![GitHub license](https://img.shields.io/github/license/LikeManTV/crews.svg)](LICENSE)
<a href="https://discordapp.com/invite/55aQNKzQVW" title="Chat on Discord"><img alt="Discord Status" src="https://discordapp.com/api/guilds/912329245789933569/widget.png"></a>

The crew system facilitates seamless coordination and management of team members within the game. It offers players a structured approach to assemble and organize their crew, ensuring efficient teamwork and collaboration. With the crew system, players can easily recruit, assign roles, and communicate with their crew members, enhancing their strategic gameplay experience.

Please report any problems by creating a new issue or join the Discord server.<br/>
Also feel free to make a PR.

## 🔥 Features
- Supports ESX, QB & OX
- Crew menu
- Crew tag & name
- Player invitation
- Member management
  - Ranks & permissions
  - Crew ownership transfer
- Settings
  - Rename crew
  - Change tag
- Blips between members
- Nametags above head (/crewTags to hide)
  - Displays player's health
 
## ⏰ Planned Features
- Bridge system for custom menu integrations.
- Crew level/point system & leaderboard.
- In-game rank editor.
- UI displaying active crew members.

## 🛠️ Dependencies
- [oxmysql](https://github.com/overextended/oxmysql)
- [ox_lib](https://github.com/overextended/ox_lib)

## 📲 Installation
1. Download latest release or source code
2. Extract the .zip file
3. Copy the folder to your server resources folder
4. Run the `SETUP/crews.sql` file
5. Add `ensure crews` to your server.cfg
6. Restart the server

`OPTIONAL` - If you want to have permissions compatible with HRS scripts.<br>
Follow the tutorial in `SETUP/HRS-INTEGRATION.txt`

## 📝 Exports (client)
- `ownsCrew()` - returns true if player owns a crew
- `isInCrew()` - returns true if player is in crew
- `getCrew()` - returns crew data
- `getCrewOwner()` - returns the identifier of the current crew owner
- `getCrewName()` - returns crew name
- `getCrewTag()` - returns crew tag
- `getPlayerRank()` - returns the player's rank

## 📝 Exports (server)
- `ownsCrew(netId)` - returns true if player owns a crew
- `isInCrew(netId)` - returns true if player is in a crew
- `isInPlayersCrew(owner, player)` - returns true if player is in other player's crew (uses identifiers)
- `getCrew(identifier)` - returns crew data of players crew
- `getCrewOwner(identifier)` - returns owner of players crew
- `getCrewName(identifier)` - returns crew name of players crew
- `getCrewTag(identifier)` - returns crew tag of players crew
- `getCrewMembers(identifier)` - returns table containing server IDs of all members
- `getPlayerRank(identifier)` - returns the player's rank

Credits: Vallorz, HRS
