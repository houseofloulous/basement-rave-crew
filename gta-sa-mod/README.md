# Basement Rave Crew — GTA: San Andreas mod pack

Scaffold for the real club. This is the product; the browser walkthrough is not.

## Target experience

- Third-person SA camera, industrial Basement (Knockdown) courtyard → ramp → tunnel → ID/fashion check → lockers → main / Charlotte → studio → dark rooms → bathrooms → backyard  
- Mad Max crew as selectable peds  
- Photo-matched textures where stock props fail  
- Ship as a **ModLoader** folder friends drop in  

## Folder plan (fill as assets land)

```
gta-sa-mod/
  README.md                 ← this file
  LAYOUT.md                 ← room order + map coords notes
  CHARACTERS.md             ← ped / skin roster
  textures-from-photos/     ← cropped TXD sources from textures-real/
  ariane/                   ← exported IPL / override from Ariane
  models/                   ← custom DFF/COL when needed
  modloader/
    BasementRaveCrew/       ← final drop-in pack
```

## Install (players)

1. Own GTA San Andreas (PC).  
2. Install ASI loader + ModLoader.  
3. Copy `modloader/BasementRaveCrew/` into the game’s `modloader` directory.  
4. Launch SA → spawn / teleport to Basement marker (documented once placed).  

## Build (authors)

1. Backup a clean SA install used only for modding.  
2. Run **Ariane** from the game root; save overrides to `modloader/Ariane` then promote into `BasementRaveCrew`.  
3. Match exterior to `textures-real/entrance-*` and the [@lop_bln Basement reel](https://www.instagram.com/reel/DgDlPgNoNDU/).  
4. Interior kits from SA industrial objects first; custom meshes only for signature pieces (F1 horns, red carpet gate, check-in desk).  
5. Characters: start from high-quality ped packs; retexture for harness / crew colors.  

## Status

- [x] Pivot decided (leave Three.js prototype)  
- [ ] LAYOUT.md from floorplan reel  
- [ ] Texture crop list from `textures-real/`  
- [ ] Ariane courtyard blocked out  
- [ ] Ped roster assigned  
- [ ] ModLoader pack playable end-to-end  
