# Build pivot — locked (free)

## Standing rules

1. **Always pick the more realistic option** among choices that fit the constraints.  
2. **No paid tools** for this project (user rule). That rules out CrossOver licenses and “buy a stack to play.”

## Why GTA SA / CrossOver is paused

- CrossOver trial ends in 14 days, then it’s paid.  
- Whisky (free) lists classic SA as **unplayable**.  
- GTA SA itself is a paid Steam game.  

So the reel-accurate SA path is **paused** until there’s a free way to run it. Notes stay in `gta-sa-mod/` for later.

## Current product (free + Mac)

| Layer | Role |
|-------|------|
| **Roblox** | Real club build — free Roblox Studio on Mac, custom avatars, friends join |
| **This website** | Door + free setup guide (`install.html`) |
| **Old Three.js sketch** | Dead end (`?sketch=1` only) |

Roblox won’t look identical to a GTA SA mod, but among **$0 Mac** options it’s the one that actually looks like a game with real people — not brown box avatars.

## Focus now

**Club shell realism first. Avatars / Mad Max outfits later.**

The auto-builder (`roblox/BuildBasement.server.lua`) generates the full one-level flow: courtyard → gate → ramp/tunnel → security → lockers → main (Charlotte) → studio → dark rooms → bathrooms → Break Time backyard — with industrial materials, haze lighting, and signage. No avatar work until the rooms feel right.

## Next

1. User: free Roblox Studio → paste `roblox/BuildBasement.server.lua` → Play once (see `roblox/AUTOBUILD.md`).  
2. Walk the club; we iterate the **space** (materials, scale, lighting) via script updates.  
3. Only after the shell feels real: outfits / avatars (still scripted).  
