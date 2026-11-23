# Studio step 1 — new place + courtyard shell

Do these in order. Reply with a screenshot when the courtyard floor + walls are in.

## 1. New place
1. Roblox Studio → **New** → **Baseplate**
2. **File → Publish to Roblox**
3. Name: **Basement Rave Crew**
4. Create new place → Publish

## 2. Clean the baseplate
1. In **Explorer**, select the default **SpawnLocation** (keep one spawn for now)
2. Delete any random demo parts you don’t want; keep the flat Baseplate for a minute

## 3. Courtyard floor (asphalt)
1. **Home → Part → Block**
2. In **Properties**:
   - Size: `80, 1, 100`
   - Position: `0, 0.5, 0`
   - Color: dark gray (`BrickColor` Concrete / Really black-ish gray)
   - Material: **Concrete** or **Asphalt** if available
3. Rename the part: `CourtyardFloor`

## 4. Brick perimeter (three walls — leave south open for now)
Add 3 blocks (Material **Brick**, color reddish-brown):

| Name | Size | Position |
|------|------|----------|
| `WallNorth` | `80, 16, 2` | `0, 8, -50` |
| `WallWest` | `2, 16, 100` | `-40, 8, 0` |
| `WallEast` | `2, 16, 100` | `40, 8, 0` |

## 5. Gate opening (north end of courtyard)
1. Part → Block, name `GateLeft` — Size `28, 16, 2` — Position `-26, 8, 40`
2. Part → Block, name `GateRight` — Size `28, 16, 2` — Position `26, 8, 40`
3. Leave the center gap (~20 studs) empty — that’s the entrance into the ramp later

## 6. Lighting vibe
1. In Explorer → **Lighting**
2. Ambient: dark purple-black
3. ColorShift_Top: slight red
4. Add a **PointLight** parented to a part above the gate (orange/red, Brightness ~2, Range ~40)

## 7. Publish again
**File → Publish to Roblox** (overwrite).

Then send a screenshot of the 3D view looking toward the gate gap.
