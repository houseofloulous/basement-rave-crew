--[[
  Basement Rave Crew — ONE-SHOT AUTO BUILD
  ========================================
  In Roblox Studio (Mac):
  1. New → Baseplate
  2. Explorer → ServerScriptService → + → Script
  3. Delete the default print("Hello"), paste THIS ENTIRE FILE
  4. Press Play (▶) once — the club builds itself in a few seconds
  5. Stop ▶, then File → Publish to Roblox as "Basement Rave Crew"
  6. You can delete this Script after it runs (map stays in Workspace)

  Safe to run again: it wipes the previous "BasementAuto" folder first.
]]

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local ROOT_NAME = "BasementAuto"

-- Wipe previous auto-build
local old = Workspace:FindFirstChild(ROOT_NAME)
if old then old:Destroy() end

local root = Instance.new("Model")
root.Name = ROOT_NAME
root.Parent = Workspace

local function part(props)
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Name = props.Name or "Part"
	p.Size = props.Size
	p.CFrame = props.CFrame or CFrame.new(props.Position or Vector3.zero)
	p.Color = props.Color or Color3.fromRGB(90, 90, 90)
	p.Material = props.Material or Enum.Material.Concrete
	p.CanCollide = props.CanCollide ~= false
	if props.Transparency then p.Transparency = props.Transparency end
	p.Parent = props.Parent or root
	return p
end

local function light(parent, color, brightness, range)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Brightness = brightness or 2
	l.Range = range or 24
	l.Parent = parent
	return l
end

-- Colors
local COL_ASPHALT = Color3.fromRGB(40, 40, 42)
local COL_BRICK = Color3.fromRGB(120, 70, 55)
local COL_CONCRETE = Color3.fromRGB(160, 155, 145)
local COL_DARK = Color3.fromRGB(45, 42, 40)
local COL_METAL = Color3.fromRGB(55, 55, 60)
local COL_RED = Color3.fromRGB(225, 6, 0)
local COL_BLACK = Color3.fromRGB(20, 20, 24)
local COL_FLOOR = Color3.fromRGB(70, 45, 40)

----------------------------------------------------------------
-- LIGHTING (Basement night / red haze)
----------------------------------------------------------------
Lighting.Ambient = Color3.fromRGB(25, 18, 28)
Lighting.OutdoorAmbient = Color3.fromRGB(30, 25, 40)
Lighting.Brightness = 1.2
Lighting.ClockTime = 0
Lighting.FogColor = Color3.fromRGB(12, 8, 18)
Lighting.FogStart = 40
Lighting.FogEnd = 180
Lighting.GlobalShadows = true

----------------------------------------------------------------
-- 1. COURTYARD
----------------------------------------------------------------
part({
	Name = "CourtyardFloor",
	Size = Vector3.new(80, 1, 90),
	Position = Vector3.new(0, 0.5, 0),
	Color = COL_ASPHALT,
	Material = Enum.Material.Asphalt,
})

-- Perimeter walls (open toward +Z gate)
part({ Name = "WallSouth", Size = Vector3.new(80, 18, 2), Position = Vector3.new(0, 9, -45), Color = COL_BRICK, Material = Enum.Material.Brick })
part({ Name = "WallWest", Size = Vector3.new(2, 18, 90), Position = Vector3.new(-40, 9, 0), Color = COL_BRICK, Material = Enum.Material.Brick })
part({ Name = "WallEast", Size = Vector3.new(2, 18, 90), Position = Vector3.new(40, 9, 0), Color = COL_BRICK, Material = Enum.Material.Brick })

-- Gate line with center opening (~20 studs)
part({ Name = "GateLeft", Size = Vector3.new(28, 18, 2), Position = Vector3.new(-24, 9, 44), Color = COL_CONCRETE, Material = Enum.Material.Concrete })
part({ Name = "GateRight", Size = Vector3.new(28, 18, 2), Position = Vector3.new(24, 9, 44), Color = COL_CONCRETE, Material = Enum.Material.Concrete })
part({ Name = "GateLintel", Size = Vector3.new(22, 2, 2), Position = Vector3.new(0, 17, 44), Color = COL_METAL, Material = Enum.Material.Metal })

-- Red carpet into gate
part({
	Name = "RedCarpet",
	Size = Vector3.new(10, 0.2, 50),
	Position = Vector3.new(0, 1.1, 10),
	Color = COL_RED,
	Material = Enum.Material.Fabric,
	CanCollide = false,
})

-- Stanchions along carpet
for i = 0, 7 do
	local z = -10 + i * 6
	part({ Name = "StanchionL", Size = Vector3.new(0.6, 3, 0.6), Position = Vector3.new(-5.5, 2.5, z), Color = COL_BLACK, Material = Enum.Material.Metal })
	part({ Name = "StanchionR", Size = Vector3.new(0.6, 3, 0.6), Position = Vector3.new(5.5, 2.5, z), Color = COL_BLACK, Material = Enum.Material.Metal })
end

-- Yard light
local yardPole = part({ Name = "YardLightPole", Size = Vector3.new(0.5, 14, 0.5), Position = Vector3.new(-18, 7, -5), Color = COL_METAL, Material = Enum.Material.Metal })
local yardBulb = part({ Name = "YardBulb", Size = Vector3.new(1.2, 1.2, 1.2), Position = Vector3.new(-18, 14.5, -5), Color = Color3.fromRGB(255, 140, 60), Material = Enum.Material.Neon, CanCollide = false })
light(yardBulb, Color3.fromRGB(255, 140, 80), 3, 50)

----------------------------------------------------------------
-- 2. RAMP + TUNNEL (into +Z)
----------------------------------------------------------------
-- Stepped ramp down
local rampSteps = 12
local rampDrop = 14
for i = 0, rampSteps - 1 do
	local t0 = i / rampSteps
	local t1 = (i + 1) / rampSteps
	local z0 = 45 + t0 * 36
	local z1 = 45 + t1 * 36
	local y0 = 1 - rampDrop * t0
	local y1 = 1 - rampDrop * t1
	local yMid = (y0 + y1) / 2
	local thick = math.max(1.2, math.abs(y0 - y1) + 0.8)
	part({
		Name = "RampStep" .. i,
		Size = Vector3.new(16, thick, z1 - z0 + 0.2),
		Position = Vector3.new(0, yMid, (z0 + z1) / 2),
		Color = COL_DARK,
		Material = Enum.Material.Concrete,
	})
	-- retaining walls
	local wallH = 8 + rampDrop * t1 * 0.4
	part({
		Name = "RampWallL" .. i,
		Size = Vector3.new(1.5, wallH, z1 - z0 + 0.2),
		Position = Vector3.new(-8.5, y1 + wallH / 2, (z0 + z1) / 2),
		Color = COL_CONCRETE,
		Material = Enum.Material.Concrete,
	})
	part({
		Name = "RampWallR" .. i,
		Size = Vector3.new(1.5, wallH, z1 - z0 + 0.2),
		Position = Vector3.new(8.5, y1 + wallH / 2, (z0 + z1) / 2),
		Color = COL_CONCRETE,
		Material = Enum.Material.Concrete,
	})
end

local tunnelY = 1 - rampDrop
local tunnelZ0 = 81
local tunnelZ1 = 110
part({
	Name = "TunnelFloor",
	Size = Vector3.new(16, 1, tunnelZ1 - tunnelZ0),
	Position = Vector3.new(0, tunnelY, (tunnelZ0 + tunnelZ1) / 2),
	Color = COL_DARK,
	Material = Enum.Material.Concrete,
})
part({
	Name = "TunnelWallL",
	Size = Vector3.new(1.5, 12, tunnelZ1 - tunnelZ0),
	Position = Vector3.new(-8.5, tunnelY + 6, (tunnelZ0 + tunnelZ1) / 2),
	Color = COL_CONCRETE,
	Material = Enum.Material.Concrete,
})
part({
	Name = "TunnelWallR",
	Size = Vector3.new(1.5, 12, tunnelZ1 - tunnelZ0),
	Position = Vector3.new(8.5, tunnelY + 6, (tunnelZ0 + tunnelZ1) / 2),
	Color = COL_CONCRETE,
	Material = Enum.Material.Concrete,
})
part({
	Name = "TunnelCeil",
	Size = Vector3.new(16, 1, tunnelZ1 - tunnelZ0),
	Position = Vector3.new(0, tunnelY + 12, (tunnelZ0 + tunnelZ1) / 2),
	Color = COL_DARK,
	Material = Enum.Material.Concrete,
})
local redCeil = part({
	Name = "TunnelRedLight",
	Size = Vector3.new(2, 0.5, 2),
	Position = Vector3.new(0, tunnelY + 11.2, tunnelZ0 + 8),
	Color = COL_RED,
	Material = Enum.Material.Neon,
	CanCollide = false,
})
light(redCeil, COL_RED, 4, 28)

-- Rise back up into club
local riseSteps = 8
for i = 0, riseSteps - 1 do
	local t0 = i / riseSteps
	local t1 = (i + 1) / riseSteps
	local z0 = tunnelZ1 + t0 * 20
	local z1 = tunnelZ1 + t1 * 20
	local y0 = tunnelY + rampDrop * t0
	local y1 = tunnelY + rampDrop * t1
	part({
		Name = "RiseStep" .. i,
		Size = Vector3.new(16, math.max(1.2, math.abs(y1 - y0) + 0.8), z1 - z0 + 0.2),
		Position = Vector3.new(0, (y0 + y1) / 2, (z0 + z1) / 2),
		Color = COL_FLOOR,
		Material = Enum.Material.Brick,
	})
	part({
		Name = "RiseWallL" .. i,
		Size = Vector3.new(1.5, 10, z1 - z0 + 0.2),
		Position = Vector3.new(-8.5, (y0 + y1) / 2 + 5, (z0 + z1) / 2),
		Color = COL_BRICK,
		Material = Enum.Material.Brick,
	})
	part({
		Name = "RiseWallR" .. i,
		Size = Vector3.new(1.5, 10, z1 - z0 + 0.2),
		Position = Vector3.new(8.5, (y0 + y1) / 2 + 5, (z0 + z1) / 2),
		Color = COL_BRICK,
		Material = Enum.Material.Brick,
	})
end

----------------------------------------------------------------
-- 3. SECURITY CHECK-IN
----------------------------------------------------------------
local secZ = tunnelZ1 + 28
part({
	Name = "SecurityFloor",
	Size = Vector3.new(40, 1, 36),
	Position = Vector3.new(0, 1, secZ),
	Color = COL_FLOOR,
	Material = Enum.Material.Brick,
})
part({ Name = "SecWallW", Size = Vector3.new(2, 14, 36), Position = Vector3.new(-20, 8, secZ), Color = COL_BRICK, Material = Enum.Material.Brick })
part({ Name = "SecWallE", Size = Vector3.new(2, 14, 36), Position = Vector3.new(20, 8, secZ), Color = COL_BRICK, Material = Enum.Material.Brick })
part({ Name = "SecCeil", Size = Vector3.new(40, 1, 36), Position = Vector3.new(0, 15, secZ), Color = COL_DARK, Material = Enum.Material.Concrete })

-- Split desk + aisle
part({ Name = "DeskL", Size = Vector3.new(10, 4, 4), Position = Vector3.new(-10, 3, secZ + 4), Color = COL_METAL, Material = Enum.Material.Metal })
part({ Name = "DeskR", Size = Vector3.new(10, 4, 4), Position = Vector3.new(10, 3, secZ + 4), Color = COL_METAL, Material = Enum.Material.Metal })
part({ Name = "SignL", Size = Vector3.new(6, 2.5, 0.4), Position = Vector3.new(-10, 7, secZ + 2), Color = COL_RED, Material = Enum.Material.Neon, CanCollide = false })
part({ Name = "SignR", Size = Vector3.new(6, 2.5, 0.4), Position = Vector3.new(10, 7, secZ + 2), Color = COL_RED, Material = Enum.Material.Neon, CanCollide = false })
local secLight = part({ Name = "SecLight", Size = Vector3.new(1, 1, 1), Position = Vector3.new(0, 12, secZ), Color = COL_RED, Material = Enum.Material.Neon, CanCollide = false })
light(secLight, COL_RED, 3, 30)

----------------------------------------------------------------
-- 4. LOCKERS
----------------------------------------------------------------
local lockZ = secZ + 40
part({
	Name = "LockerFloor",
	Size = Vector3.new(50, 1, 50),
	Position = Vector3.new(0, 1, lockZ),
	Color = COL_FLOOR,
	Material = Enum.Material.Brick,
})
part({ Name = "LockerWallN", Size = Vector3.new(50, 14, 2), Position = Vector3.new(0, 8, lockZ + 25), Color = COL_BRICK, Material = Enum.Material.Brick })
part({ Name = "LockerWallS", Size = Vector3.new(18, 14, 2), Position = Vector3.new(-16, 8, lockZ - 25), Color = COL_BRICK, Material = Enum.Material.Brick })
part({ Name = "LockerWallS2", Size = Vector3.new(18, 14, 2), Position = Vector3.new(16, 8, lockZ - 25), Color = COL_BRICK, Material = Enum.Material.Brick })
-- doorway gap center south
part({ Name = "LockerWallW", Size = Vector3.new(2, 14, 50), Position = Vector3.new(-25, 8, lockZ), Color = COL_BRICK, Material = Enum.Material.Brick })
part({ Name = "LockerCeil", Size = Vector3.new(50, 1, 50), Position = Vector3.new(0, 15, lockZ), Color = COL_DARK, Material = Enum.Material.Concrete })

for row = 0, 1 do
	for _, x in ipairs({ -18, -12, 12, 18 }) do
		part({
			Name = "Locker",
			Size = Vector3.new(3, 7, 2),
			Position = Vector3.new(x, 4.5, lockZ - 8 + row * 16),
			Color = COL_METAL,
			Material = Enum.Material.Metal,
		})
	end
end

----------------------------------------------------------------
-- 5. MAIN / CHARLOTTE (dance)
----------------------------------------------------------------
local mainZ = lockZ + 55
part({
	Name = "MainFloor",
	Size = Vector3.new(70, 1, 60),
	Position = Vector3.new(15, 1, mainZ),
	Color = COL_FLOOR,
	Material = Enum.Material.Brick,
})
part({ Name = "MainWallN", Size = Vector3.new(70, 16, 2), Position = Vector3.new(15, 9, mainZ + 30), Color = COL_BRICK, Material = Enum.Material.Brick })
part({ Name = "MainWallS", Size = Vector3.new(70, 16, 2), Position = Vector3.new(15, 9, mainZ - 30), Color = COL_BRICK, Material = Enum.Material.Brick })
part({ Name = "MainWallW", Size = Vector3.new(2, 16, 60), Position = Vector3.new(-20, 9, mainZ), Color = COL_BRICK, Material = Enum.Material.Brick })
part({ Name = "MainWallE", Size = Vector3.new(2, 16, 60), Position = Vector3.new(50, 9, mainZ), Color = COL_BRICK, Material = Enum.Material.Brick })
part({ Name = "MainCeil", Size = Vector3.new(70, 1, 60), Position = Vector3.new(15, 17, mainZ), Color = COL_DARK, Material = Enum.Material.Concrete })

-- DJ / F1-ish white stacks
for _, x in ipairs({ -5, 35 }) do
	part({ Name = "Speaker", Size = Vector3.new(4, 8, 3), Position = Vector3.new(x, 5, mainZ + 20), Color = Color3.fromRGB(230, 230, 225), Material = Enum.Material.SmoothPlastic })
	part({ Name = "Horn", Size = Vector3.new(5, 3, 4), Position = Vector3.new(x, 10, mainZ + 20), Color = Color3.fromRGB(230, 230, 225), Material = Enum.Material.SmoothPlastic })
end

-- Orange grid lights
for r = 0, 1 do
	for c = 0, 3 do
		local bulb = part({
			Name = "OrangeGrid",
			Size = Vector3.new(2, 2, 0.4),
			Position = Vector3.new(5 + c * 5, 14, mainZ - 10 + r * 5),
			Color = Color3.fromRGB(255, 120, 40),
			Material = Enum.Material.Neon,
			CanCollide = false,
		})
		light(bulb, Color3.fromRGB(255, 120, 40), 1.5, 18)
	end
end

local mainWash = part({ Name = "MainWash", Size = Vector3.new(1, 1, 1), Position = Vector3.new(15, 14, mainZ), Color = COL_RED, Material = Enum.Material.Neon, CanCollide = false })
light(mainWash, COL_RED, 2.5, 45)

----------------------------------------------------------------
-- 6. SPAWN
----------------------------------------------------------------
-- Remove default spawn if present
for _, child in ipairs(Workspace:GetChildren()) do
	if child:IsA("SpawnLocation") then
		child:Destroy()
	end
end

local spawn = Instance.new("SpawnLocation")
spawn.Name = "BasementSpawn"
spawn.Size = Vector3.new(6, 1, 6)
spawn.Position = Vector3.new(0, 1.5, -25)
spawn.Anchored = true
spawn.Duration = 0
spawn.Neutral = true
spawn.Color = COL_RED
spawn.Material = Enum.Material.Neon
spawn.Parent = root

print("[BasementAuto] Club built. Stop Play, then Publish to Roblox as Basement Rave Crew.")
print("[BasementAuto] Walk: courtyard (-Z) → red carpet → gate → ramp → tunnel → security → lockers → main.")
