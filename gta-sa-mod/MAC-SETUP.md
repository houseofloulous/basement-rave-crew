# Mac setup — GTA San Andreas + CrossOver

Standing rule: **always pick the more realistic path** (this stack), not the old browser sketch.

## Why CrossOver

Classic SA + ASI mods are more reliable in **CrossOver** on Apple Silicon than Whisky. Goal: Steam SA running in a bottle, then ModLoader, then our `BasementRaveCrew` pack.

## Checklist

### A. Bottle
- [ ] Install CrossOver
- [ ] New Windows 10 bottle (name e.g. `GTA-SA`)
- [ ] Install Steam into the bottle
- [ ] Sign in to Steam

### B. Game
- [ ] Install **Grand Theft Auto: San Andreas** from Steam into the bottle
- [ ] Launch once; pick a working resolution if prompted
- [ ] Quit cleanly

### C. Modding baseline (v1.0 stack)
- [ ] Open the SA folder via CrossOver → Open C: Drive → `…/steamapps/common/GTA San Andreas` (path may vary)
- [ ] Downgrade to **SA 1.0** (Steam copies often need a downgrader — keep a backup)
- [ ] Install **SilentPatchSA**
- [ ] Install **ASI loader** / Widescreen Fix scripts folder as needed
- [ ] Install **ModLoader** (`modloader.asi` + `modloader/` folder in the game root)
- [ ] Confirm ModLoader menu appears in-game

### D. Basement pack (when ready)
- [ ] Copy `modloader/BasementRaveCrew/` from this repo into the game’s `modloader/`
- [ ] Launch SA → teleport / marker to Basement (coords in LAYOUT once placed)

### E. Map authoring
- [ ] Install [Ariane](https://gtastuff.com/ariane/) beside the game
- [ ] Save overrides under ModLoader, not over original IMG blindly
- [ ] Build courtyard → gate → ramp → tunnel → security per `LAYOUT.md`

## What this Mac agent can’t do remotely

We can’t run CrossOver or Ariane inside the cloud Linux VM. Once SA launches on **your** Mac, say so — next step is courtyard block-out using your Basement photo refs.
