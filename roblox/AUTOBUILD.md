# Auto-build Basement — one paste

Paste the full `BuildBasement.server.lua` into **ServerScriptService → Script**.  
**Leave the Script there** — it rebuilds `Workspace.BasementClub` on every Play / join.

## Steps

1. Roblox Studio → open **Basement Rave Crew** (or New → Baseplate)
2. Explorer → **ServerScriptService** → **+** → **Script** (or replace existing)
3. Paste entire file from:  
   https://raw.githubusercontent.com/houseofloulous/basement-rave-crew/main/roblox/BuildBasement.server.lua
4. **Play ▶** once — wait for `[Basement] Club built…`
5. Walk courtyard → gate → club → **Stop** → **Publish**

## Interactive flow (ProximityPrompt — press **E** / tap)

1. Courtyard line: optional **Play as Sam / Mike / Max / Chris** (still all black + harness)
2. **Show ID** (bouncer + guest pass flash) → **Dress-code check**
3. Gate opens → **Put bag & coat · lock** (bag/coat appear in front of locker, LOCKED)
4. Hub: **Get water**, **Buy snack**
5. Main: hear **DJ music** (loud on dancefloor) · **Buy drink** · stand on neon pad → **Press E to dance**
6. Each completed stop plays a club **pew-pew** zap + toast
7. The Stalls: **Take paper**, **Flush**, **Wash hands**

Free assets only: DJ `rbxassetid://1837849285` (Creator docs Upbeat Electronica), engine SFX, free Black Jeans pants `382537569`, default dance anims.

Optional client tip script: `BasementClient.local.lua` → StarterPlayerScripts (not required).
