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

Proximity prompts (**E** / tap) on the club path:

1. **Show ID** (see guest pass + bouncers) → **Dress-code check** (all black + harness)
2. Security gate opens → **Put bag & coat · lock** at lockers
3. Hub: **Get water**, **Buy snack**
4. Main floor: hear **DJ music**, **Buy drink**, stand on neon pad → **Press E to dance**
5. Completing a stop plays a club **pew-pew** SFX
6. The Stalls: **Take paper**, **Flush**, **Wash hands**

Optional client tip: paste `BasementClient.local.lua` into StarterPlayerScripts (server already covers the flow).

One-shot rebuild: leave the Script in ServerScriptService; every Play rebuilds `Workspace.BasementClub`.
Free assets only (Roblox tutorial music ID + engine `electronicpingshort` SFX + default dance anims).
