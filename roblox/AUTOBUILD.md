# Auto-build Basement (≈2 minutes, not hours)

You do **not** place parts by hand.

## Steps

1. Open **Roblox Studio** → **New** → **Baseplate**
2. In **Explorer**, hover **ServerScriptService** → **+** → **Script**
3. Open that Script, select all, delete, paste the full contents of  
   **`BuildBasement.server.lua`**  
   (from this repo / GitHub)
4. Press **Play (▶)** once — wait a few seconds while the club generates
5. Press **Stop**
6. **File → Publish to Roblox** → name **Basement Rave Crew**
7. (Optional) Delete the Script — the built map stays under `Workspace.BasementAuto`

## Play with friends

On create.roblox.com → your place → **…** → permissions → friends can join. Share the place link (Bitly if you want).

## Re-run

Press Play again anytime; the script clears the old `BasementAuto` model and rebuilds.
