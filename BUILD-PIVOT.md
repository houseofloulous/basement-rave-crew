# Stop polishing Three.js — build Basement the way the references are built

## The hard truth

The Instagram reel you sent ([@lop_bln / Basement NYC](https://www.instagram.com/reel/DgDlPgNoNDU/)) and the “advanced” screenshots are **GTA: San Andreas club recreations**.

They look real because they run on Rockstar’s world, characters, lighting, and animation — not because someone coded better boxes in a webpage.

What we’ve been shipping (`basement-rave-crew` Three.js walkthrough) will never close that gap. More GLB tweaks, camera pads, and capsule people are the wrong improvements. **Base44 / GDevelop / more custom WebGL also won’t match that bar.**

## New build path (chosen)

| Layer | Job |
|-------|-----|
| **Primary game** | **GTA: San Andreas map + interior mod** of Basement (Knockdown) — same medium as the reel |
| **Crew avatars** | Custom ped skins / player models (Sam, Mike, Max, Chris, …) — each person picks their character in single-player; later MTA:SA if you want friends in one world |
| **Web link** | Keep https://basement-rave-crew.apps.grok.bot as the **door**: poster, ENTER, crew vibe, Bitly — plus **install & play** for the SA mod. Browser 3D becomes an optional prototype, not the product |

## Toolchain (Mac — no Windows PC required)

1. **CrossOver** on Mac + **Steam** bottle  
2. **GTA: San Andreas** (Steam) inside CrossOver — downgrade to v1.0 + SilentPatch + ASI loader  
3. **ModLoader** — drop-in packs without overwriting the base game  
4. **Ariane** map editor against that install ([gtastuff.com/ariane](https://gtastuff.com/ariane/))  
5. Ped / clothing mods for the Mad Max crew look  

Whisky can work but CrossOver is the more reliable Mac path for classic SA.

## What we stop doing

- Hand-authoring the club from Three.js `BoxGeometry` walls  
- Expecting one Mixamo `Xbot` to look like GTA peds  
- Treating “fix the camera again” as progress toward the reel  

## What we do next

1. Freeze Three.js as **prototype only** (still at the live URL until the hub ships).  
2. Build the **mod pack scaffold** under `gta-sa-mod/` (layout notes, texture targets from your photos, character roster).  
3. Rebuild the website as **ENTER → crew → Install the club**.  
4. Author the courtyard → security → tunnel → floors in Ariane using your photo refs + the reel.  

## Why not Base44 / GDevelop / “better Three.js”

- **Base44** — ships apps fast; does not give you GTA characters or that club fidelity.  
- **GDevelop** — we already tried; one capsule GLB + image props. Same ceiling.  
- **Better Three.js** — fine for a toy; wrong engine for the aesthetic you keep pointing at.  

## Open requirement

A Mac with **CrossOver + GTA: San Andreas** (Steam). No separate Windows PC. Until that install exists, the browser walkthrough is the only playable door — and it must at least let you walk into the club.
