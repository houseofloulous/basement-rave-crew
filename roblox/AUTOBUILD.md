# Auto-build Basement — one paste

Paste the full `BuildBasement.server.lua` into **ServerScriptService → Script**. Leave it there — it rebuilds on every Play / join.

## Steps

1. Roblox Studio → open **Basement Rave Crew** (or New → Baseplate)
2. Explorer → **ServerScriptService** → **+** → **Script** (or replace existing)
3. Paste entire file from:  
   https://raw.githubusercontent.com/houseofloulous/basement-rave-crew/main/roblox/BuildBasement.server.lua
4. **Play ▶** once — wait for `[Basement] Club built…`
5. Walk courtyard → gate → club → **Stop** → **Publish**

Builds `Workspace.BasementClub` (also clears old `BasementAuto`). Avatars later.

## After paste — interactive flow

Proximity prompts (E / tap) on the club path:

1. **Show ID** at ID desk → **Dress-code check**
2. Security gate opens → **Put coat & lock** at lockers
3. Hub: **Get water**, **Buy snack**
4. Main floor: **Buy drink** at bar, **Dance** on the floor
5. The Stalls: **Take paper**, **Flush**, **Wash hands**

One-shot rebuild: leave the Script in ServerScriptService; every Play rebuilds `Workspace.BasementClub`.
