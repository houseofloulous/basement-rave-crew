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

## Toolchain (PC)

1. **GTA: San Andreas** (Steam / classic PC) — dedicated modding copy  
2. **ModLoader** — load our pack without overwriting the base game  
3. **Ariane** map editor — place courtyard, ramp, tunnel, rooms in the SA world ([gtastuff.com/ariane](https://gtastuff.com/ariane/))  
4. **Blender + INU Tools** — custom DFF/TXD/COL from your Basement photos when stock SA props aren’t enough  
5. Ped / clothing mods for the Mad Max crew look  

Mac friends: play via cloud PC, Boot Camp/Parallels Windows, or a shared Windows box. SA modding is a Windows-first workflow.

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

## Open requirement (blocks the real game)

Someone on the crew needs a **PC copy of GTA San Andreas** for modding. Without that, we can only prepare the pack and the web door — we can’t play the real club.
