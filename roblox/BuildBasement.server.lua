--[[
  Basement Rave Crew — ONE-SHOT AUTO BUILD (club realism pass)
  ============================================================
  Focus: industrial club shell that feels like Basement NYC.
  Avatars / outfits: later — skip for now.

  Studio (Mac):
  1. New → Baseplate
  2. ServerScriptService → + → Script → paste THIS ENTIRE FILE
  3. Play ▶ once → Stop → Publish as "Basement Rave Crew"

  Safe to re-run: wipes Workspace.BasementAuto first.
]]

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local ROOT_NAME = "BasementAuto"

local old = Workspace:FindFirstChild(ROOT_NAME)
if old then old:Destroy() end

-- Clear leftover lighting effects from prior runs
for _, child in ipairs(Lighting:GetChildren()) do
	if child:IsA("Atmosphere")
		or child:IsA("ColorCorrectionEffect")
		or child:IsA("BloomEffect")
		or child:IsA("DepthOfFieldEffect")
		or child:IsA("SunRaysEffect")
	then
		child:Destroy()
	end
end

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
	p.CastShadow = props.CastShadow ~= false
	if props.Transparency then p.Transparency = props.Transparency end
	if props.Reflectance then p.Reflectance = props.Reflectance end
	p.Parent = props.Parent or root
	return p
end

local function light(parent, color, brightness, range)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Brightness = brightness or 2
	l.Range = range or 24
	l.Shadows = true
	l.Parent = parent
	return l
end

local function sign(parentPart, text, face, textColor, bgColor)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "Sign"
	gui.Face = face or Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(512, 256)
	gui.LightInfluence = 0.2
	gui.Parent = parentPart
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = bgColor or Color3.fromRGB(20, 20, 22)
	frame.BorderSizePixel = 0
	frame.Parent = gui
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = textColor or Color3.fromRGB(255, 240, 235)
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.Parent = frame
	return gui
end

local function beam(fromPos, toPos, color, thickness)
	-- simple structural beam as a long part between two points
	local mid = (fromPos + toPos) / 2
	local delta = toPos - fromPos
	local len = delta.Magnitude
	local p = part({
		Name = "Beam",
		Size = Vector3.new(thickness or 0.6, thickness or 0.6, len),
		CFrame = CFrame.lookAt(mid, toPos),
		Color = color or Color3.fromRGB(55, 55, 58),
		Material = Enum.Material.Metal,
	})
	return p
end

-- Palette (industrial Basement night)
local COL_ASPHALT = Color3.fromRGB(38, 38, 40)
local COL_BRICK = Color3.fromRGB(112, 64, 50)
local COL_BRICK_DARK = Color3.fromRGB(78, 48, 40)
local COL_CONCRETE = Color3.fromRGB(148, 142, 132)
local COL_CONCRETE_DARK = Color3.fromRGB(92, 88, 82)
local COL_SLATE = Color3.fromRGB(70, 68, 72)
local COL_METAL = Color3.fromRGB(58, 58, 62)
local COL_RUST = Color3.fromRGB(110, 70, 45)
local COL_RED = Color3.fromRGB(220, 8, 0)
local COL_BLACK = Color3.fromRGB(18, 18, 22)
local COL_FLOOR = Color3.fromRGB(62, 42, 38)
local COL_TILE = Color3.fromRGB(210, 205, 195)
local COL_GRAVEL = Color3.fromRGB(95, 90, 80)
local COL_WHITE = Color3.fromRGB(235, 233, 228)
local COL_ORANGE = Color3.fromRGB(255, 110, 35)

----------------------------------------------------------------
-- LIGHTING / ATMOSPHERE (club haze, not daylight baseplate)
----------------------------------------------------------------
Lighting.Ambient = Color3.fromRGB(22, 14, 24)
Lighting.OutdoorAmbient = Color3.fromRGB(28, 22, 36)
Lighting.Brightness = 0.85
Lighting.ClockTime = 0.5
Lighting.GeographicLatitude = 40
Lighting.FogColor = Color3.fromRGB(10, 6, 14)
Lighting.FogStart = 30
Lighting.FogEnd = 160
Lighting.GlobalShadows = true
Lighting.EnvironmentDiffuseScale = 0.35
Lighting.EnvironmentSpecularScale = 0.2

local atmosphere = Instance.new("Atmosphere")
atmosphere.Density = 0.38
atmosphere.Offset = 0.15
atmosphere.Color = Color3.fromRGB(55, 28, 40)
atmosphere.Decay = Color3.fromRGB(18, 8, 14)
atmosphere.Glare = 0.15
atmosphere.Haze = 2.4
atmosphere.Parent = Lighting

local cc = Instance.new("ColorCorrectionEffect")
cc.Name = "BasementCC"
cc.TintColor = Color3.fromRGB(255, 205, 205)
cc.Brightness = -0.04
cc.Contrast = 0.12
cc.Saturation = 0.08
cc.Parent = Lighting

local bloom = Instance.new("BloomEffect")
bloom.Name = "BasementBloom"
bloom.Intensity = 0.55
bloom.Size = 28
bloom.Threshold = 0.85
bloom.Parent = Lighting

local dof = Instance.new("DepthOfFieldEffect")
dof.Name = "BasementDOF"
dof.FarIntensity = 0.18
dof.NearIntensity = 0.05
dof.FocusDistance = 28
dof.InFocusRadius = 22
dof.Parent = Lighting

----------------------------------------------------------------
-- HELPERS: room shell (floor / 4 walls with door gaps / ceiling)
----------------------------------------------------------------
local function roomShell(opts)
	local folder = Instance.new("Folder")
	folder.Name = opts.Name
	folder.Parent = root

	local cx, cy, cz = opts.Center.X, opts.Center.Y, opts.Center.Z
	local sx, sy, sz = opts.Size.X, opts.Size.Y, opts.Size.Z
	local wallT = opts.WallThickness or 2
	local floorColor = opts.FloorColor or COL_FLOOR
	local floorMat = opts.FloorMaterial or Enum.Material.Brick
	local wallColor = opts.WallColor or COL_BRICK
	local wallMat = opts.WallMaterial or Enum.Material.Brick
	local ceilColor = opts.CeilColor or COL_CONCRETE_DARK
	local ceilY = cy + sy

	part({
		Name = "Floor",
		Size = Vector3.new(sx, 1, sz),
		Position = Vector3.new(cx, cy, cz),
		Color = floorColor,
		Material = floorMat,
		Parent = folder,
	})
	part({
		Name = "Ceil",
		Size = Vector3.new(sx, 1, sz),
		Position = Vector3.new(cx, ceilY, cz),
		Color = ceilColor,
		Material = Enum.Material.Concrete,
		Parent = folder,
	})

	-- Walls: North (+Z), South (-Z), West (-X), East (+X)
	-- DoorGaps: { N = width, S = width, W = width, E = width } — centered gap
	local gaps = opts.DoorGaps or {}

	local function wallWithGap(name, fullSize, fullPos, axis, gapW)
		if not gapW or gapW <= 0 then
			part({
				Name = name,
				Size = fullSize,
				Position = fullPos,
				Color = wallColor,
				Material = wallMat,
				Parent = folder,
			})
			return
		end
		-- split into two panels along the long horizontal axis
		if axis == "X" then
			local total = fullSize.X
			local side = (total - gapW) / 2
			local leftX = fullPos.X - (gapW / 2 + side / 2)
			local rightX = fullPos.X + (gapW / 2 + side / 2)
			part({
				Name = name .. "L",
				Size = Vector3.new(side, fullSize.Y, fullSize.Z),
				Position = Vector3.new(leftX, fullPos.Y, fullPos.Z),
				Color = wallColor,
				Material = wallMat,
				Parent = folder,
			})
			part({
				Name = name .. "R",
				Size = Vector3.new(side, fullSize.Y, fullSize.Z),
				Position = Vector3.new(rightX, fullPos.Y, fullPos.Z),
				Color = wallColor,
				Material = wallMat,
				Parent = folder,
			})
			-- lintel
			part({
				Name = name .. "Lintel",
				Size = Vector3.new(gapW + 1, 1.5, fullSize.Z),
				Position = Vector3.new(fullPos.X, fullPos.Y + fullSize.Y / 2 - 0.75, fullPos.Z),
				Color = COL_METAL,
				Material = Enum.Material.Metal,
				Parent = folder,
			})
		else -- Z
			local total = fullSize.Z
			local side = (total - gapW) / 2
			local nearZ = fullPos.Z - (gapW / 2 + side / 2)
			local farZ = fullPos.Z + (gapW / 2 + side / 2)
			part({
				Name = name .. "A",
				Size = Vector3.new(fullSize.X, fullSize.Y, side),
				Position = Vector3.new(fullPos.X, fullPos.Y, nearZ),
				Color = wallColor,
				Material = wallMat,
				Parent = folder,
			})
			part({
				Name = name .. "B",
				Size = Vector3.new(fullSize.X, fullSize.Y, side),
				Position = Vector3.new(fullPos.X, fullPos.Y, farZ),
				Color = wallColor,
				Material = wallMat,
				Parent = folder,
			})
			part({
				Name = name .. "Lintel",
				Size = Vector3.new(fullSize.X, 1.5, gapW + 1),
				Position = Vector3.new(fullPos.X, fullPos.Y + fullSize.Y / 2 - 0.75, fullPos.Z),
				Color = COL_METAL,
				Material = Enum.Material.Metal,
				Parent = folder,
			})
		end
	end

	local wallH = sy - 0.5
	local wallY = cy + wallH / 2 + 0.5

	wallWithGap("WallN", Vector3.new(sx, wallH, wallT), Vector3.new(cx, wallY, cz + sz / 2), "X", gaps.N)
	wallWithGap("WallS", Vector3.new(sx, wallH, wallT), Vector3.new(cx, wallY, cz - sz / 2), "X", gaps.S)
	wallWithGap("WallW", Vector3.new(wallT, wallH, sz), Vector3.new(cx - sx / 2, wallY, cz), "Z", gaps.W)
	wallWithGap("WallE", Vector3.new(wallT, wallH, sz), Vector3.new(cx + sx / 2, wallY, cz), "Z", gaps.E)

	-- ceiling pipes / beams for industrial density
	if opts.Pipes ~= false then
		for i = -2, 2 do
			part({
				Name = "Pipe",
				Size = Vector3.new(0.7, 0.7, sz * 0.85),
				Position = Vector3.new(cx + i * (sx / 6), ceilY - 1.2, cz),
				Color = COL_RUST,
				Material = Enum.Material.CorrodedMetal,
				Parent = folder,
			})
		end
		for i = -1, 1 do
			part({
				Name = "IBeam",
				Size = Vector3.new(sx * 0.9, 0.8, 0.8),
				Position = Vector3.new(cx, ceilY - 2.2, cz + i * (sz / 4)),
				Color = COL_METAL,
				Material = Enum.Material.Metal,
				Parent = folder,
			})
		end
	end

	return folder
end

----------------------------------------------------------------
-- 1. COURTYARD (street / queue / gate)
----------------------------------------------------------------
local yard = Instance.new("Folder")
yard.Name = "Courtyard"
yard.Parent = root

part({
	Name = "Asphalt",
	Size = Vector3.new(90, 1, 100),
	Position = Vector3.new(0, 0.5, 0),
	Color = COL_ASPHALT,
	Material = Enum.Material.Asphalt,
	Parent = yard,
})
-- curb strips
part({ Name = "CurbW", Size = Vector3.new(1.2, 0.6, 100), Position = Vector3.new(-44, 1.1, 0), Color = COL_CONCRETE, Material = Enum.Material.Concrete, Parent = yard })
part({ Name = "CurbE", Size = Vector3.new(1.2, 0.6, 100), Position = Vector3.new(44, 1.1, 0), Color = COL_CONCRETE, Material = Enum.Material.Concrete, Parent = yard })

-- Brick perimeter (open toward +Z gate)
part({ Name = "WallS", Size = Vector3.new(90, 20, 2.5), Position = Vector3.new(0, 10.5, -50), Color = COL_BRICK, Material = Enum.Material.Brick, Parent = yard })
part({ Name = "WallW", Size = Vector3.new(2.5, 20, 100), Position = Vector3.new(-45, 10.5, 0), Color = COL_BRICK, Material = Enum.Material.Brick, Parent = yard })
part({ Name = "WallE", Size = Vector3.new(2.5, 20, 100), Position = Vector3.new(45, 10.5, 0), Color = COL_BRICK, Material = Enum.Material.Brick, Parent = yard })
-- coping
part({ Name = "CopeS", Size = Vector3.new(92, 0.8, 3.2), Position = Vector3.new(0, 20.8, -50), Color = COL_CONCRETE, Material = Enum.Material.Concrete, Parent = yard })
part({ Name = "CopeW", Size = Vector3.new(3.2, 0.8, 100), Position = Vector3.new(-45, 20.8, 0), Color = COL_CONCRETE, Material = Enum.Material.Concrete, Parent = yard })
part({ Name = "CopeE", Size = Vector3.new(3.2, 0.8, 100), Position = Vector3.new(45, 20.8, 0), Color = COL_CONCRETE, Material = Enum.Material.Concrete, Parent = yard })

-- Industrial gate facade
part({ Name = "GateL", Size = Vector3.new(32, 20, 3), Position = Vector3.new(-26, 10.5, 48), Color = COL_CONCRETE_DARK, Material = Enum.Material.Concrete, Parent = yard })
part({ Name = "GateR", Size = Vector3.new(32, 20, 3), Position = Vector3.new(26, 10.5, 48), Color = COL_CONCRETE_DARK, Material = Enum.Material.Concrete, Parent = yard })
part({ Name = "GateLintel", Size = Vector3.new(22, 3, 3.5), Position = Vector3.new(0, 19, 48), Color = COL_METAL, Material = Enum.Material.Metal, Parent = yard })
-- rusted door leaves (open / ajar feel — partial)
part({ Name = "GateLeafL", Size = Vector3.new(8, 16, 0.6), Position = Vector3.new(-9, 9, 46.5), Color = COL_RUST, Material = Enum.Material.CorrodedMetal, Parent = yard })
part({ Name = "GateLeafR", Size = Vector3.new(8, 16, 0.6), Position = Vector3.new(9, 9, 46.5), Color = COL_RUST, Material = Enum.Material.CorrodedMetal, Parent = yard })
local gateSign = part({
	Name = "GateSign",
	Size = Vector3.new(14, 3, 0.4),
	Position = Vector3.new(0, 16.5, 46.2),
	Color = COL_BLACK,
	Material = Enum.Material.SmoothPlastic,
	CanCollide = false,
	Parent = yard,
})
sign(gateSign, "BASEMENT", Enum.NormalId.Front, COL_RED, COL_BLACK)

-- Red VIP carpet into gate
part({
	Name = "RedCarpet",
	Size = Vector3.new(12, 0.15, 55),
	Position = Vector3.new(0, 1.08, 12),
	Color = COL_RED,
	Material = Enum.Material.Fabric,
	CanCollide = false,
	Parent = yard,
})

-- Queue stanchions + rope bars
for i = 0, 9 do
	local z = -18 + i * 6
	local sl = part({ Name = "StanchionL", Size = Vector3.new(0.5, 3.2, 0.5), Position = Vector3.new(-6.5, 2.6, z), Color = COL_BLACK, Material = Enum.Material.Metal, Parent = yard })
	local sr = part({ Name = "StanchionR", Size = Vector3.new(0.5, 3.2, 0.5), Position = Vector3.new(6.5, 2.6, z), Color = COL_BLACK, Material = Enum.Material.Metal, Parent = yard })
	part({ Name = "RopeL", Size = Vector3.new(0.15, 0.15, 5.5), Position = Vector3.new(-6.5, 3.8, z + 3), Color = COL_RED, Material = Enum.Material.Fabric, CanCollide = false, Parent = yard })
	part({ Name = "RopeR", Size = Vector3.new(0.15, 0.15, 5.5), Position = Vector3.new(6.5, 3.8, z + 3), Color = COL_RED, Material = Enum.Material.Fabric, CanCollide = false, Parent = yard })
	-- caps
	part({ Name = "CapL", Size = Vector3.new(0.7, 0.25, 0.7), Position = Vector3.new(-6.5, 4.3, z), Color = COL_METAL, Material = Enum.Material.Metal, Parent = yard })
	part({ Name = "CapR", Size = Vector3.new(0.7, 0.25, 0.7), Position = Vector3.new(6.5, 4.3, z), Color = COL_METAL, Material = Enum.Material.Metal, Parent = yard })
end

-- Yard sodium lights
for _, x in ipairs({ -22, 22 }) do
	part({ Name = "Pole", Size = Vector3.new(0.55, 16, 0.55), Position = Vector3.new(x, 8.5, -8), Color = COL_METAL, Material = Enum.Material.Metal, Parent = yard })
	local bulb = part({
		Name = "Sodium",
		Size = Vector3.new(1.4, 1.4, 1.4),
		Position = Vector3.new(x, 16.8, -8),
		Color = Color3.fromRGB(255, 150, 70),
		Material = Enum.Material.Neon,
		CanCollide = false,
		Parent = yard,
	})
	light(bulb, Color3.fromRGB(255, 145, 70), 3.2, 55)
end

-- Dumpster / industrial clutter
part({ Name = "Dumpster", Size = Vector3.new(8, 5, 5), Position = Vector3.new(-32, 3.5, -30), Color = COL_SLATE, Material = Enum.Material.Metal, Parent = yard })
part({ Name = "PalletStack", Size = Vector3.new(4, 3, 4), Position = Vector3.new(34, 2.5, -22), Color = Color3.fromRGB(120, 90, 50), Material = Enum.Material.Wood, Parent = yard })

----------------------------------------------------------------
-- 2. RAMP + TUNNEL
----------------------------------------------------------------
local rampFolder = Instance.new("Folder")
rampFolder.Name = "RampTunnel"
rampFolder.Parent = root

local rampSteps = 14
local rampDrop = 16
local rampStartZ = 50
local rampLen = 42
for i = 0, rampSteps - 1 do
	local t0 = i / rampSteps
	local t1 = (i + 1) / rampSteps
	local z0 = rampStartZ + t0 * rampLen
	local z1 = rampStartZ + t1 * rampLen
	local y0 = 1 - rampDrop * t0
	local y1 = 1 - rampDrop * t1
	local yMid = (y0 + y1) / 2
	local thick = math.max(1.4, math.abs(y0 - y1) + 1)
	part({
		Name = "RampStep" .. i,
		Size = Vector3.new(18, thick, z1 - z0 + 0.25),
		Position = Vector3.new(0, yMid, (z0 + z1) / 2),
		Color = COL_CONCRETE_DARK,
		Material = Enum.Material.Concrete,
		Parent = rampFolder,
	})
	local wallH = 10 + rampDrop * t1 * 0.35
	part({
		Name = "RampWallL" .. i,
		Size = Vector3.new(1.8, wallH, z1 - z0 + 0.25),
		Position = Vector3.new(-9.5, y1 + wallH / 2, (z0 + z1) / 2),
		Color = COL_CONCRETE,
		Material = Enum.Material.Concrete,
		Parent = rampFolder,
	})
	part({
		Name = "RampWallR" .. i,
		Size = Vector3.new(1.8, wallH, z1 - z0 + 0.25),
		Position = Vector3.new(9.5, y1 + wallH / 2, (z0 + z1) / 2),
		Color = COL_CONCRETE,
		Material = Enum.Material.Concrete,
		Parent = rampFolder,
	})
	-- handrails
	part({
		Name = "RailL" .. i,
		Size = Vector3.new(0.25, 0.25, z1 - z0 + 0.2),
		Position = Vector3.new(-8.2, y1 + 3.5, (z0 + z1) / 2),
		Color = COL_METAL,
		Material = Enum.Material.Metal,
		Parent = rampFolder,
	})
	part({
		Name = "RailR" .. i,
		Size = Vector3.new(0.25, 0.25, z1 - z0 + 0.2),
		Position = Vector3.new(8.2, y1 + 3.5, (z0 + z1) / 2),
		Color = COL_METAL,
		Material = Enum.Material.Metal,
		Parent = rampFolder,
	})
end

local tunnelY = 1 - rampDrop
local tunnelZ0 = rampStartZ + rampLen
local tunnelZ1 = tunnelZ0 + 36
part({
	Name = "TunnelFloor",
	Size = Vector3.new(18, 1, tunnelZ1 - tunnelZ0),
	Position = Vector3.new(0, tunnelY, (tunnelZ0 + tunnelZ1) / 2),
	Color = COL_SLATE,
	Material = Enum.Material.Concrete,
	Parent = rampFolder,
})
part({
	Name = "TunnelWallL",
	Size = Vector3.new(1.8, 14, tunnelZ1 - tunnelZ0),
	Position = Vector3.new(-9.5, tunnelY + 7, (tunnelZ0 + tunnelZ1) / 2),
	Color = COL_CONCRETE,
	Material = Enum.Material.Concrete,
	Parent = rampFolder,
})
part({
	Name = "TunnelWallR",
	Size = Vector3.new(1.8, 14, tunnelZ1 - tunnelZ0),
	Position = Vector3.new(9.5, tunnelY + 7, (tunnelZ0 + tunnelZ1) / 2),
	Color = COL_CONCRETE,
	Material = Enum.Material.Concrete,
	Parent = rampFolder,
})
part({
	Name = "TunnelCeil",
	Size = Vector3.new(18, 1.2, tunnelZ1 - tunnelZ0),
	Position = Vector3.new(0, tunnelY + 14, (tunnelZ0 + tunnelZ1) / 2),
	Color = COL_CONCRETE_DARK,
	Material = Enum.Material.Concrete,
	Parent = rampFolder,
})

-- Arch ribs + red wash lights (Knockdown / Basement tunnel vibe)
for i = 0, 7 do
	local z = tunnelZ0 + 3 + i * 4.2
	part({
		Name = "ArchRib",
		Size = Vector3.new(17.5, 0.6, 0.6),
		Position = Vector3.new(0, tunnelY + 13.2, z),
		Color = COL_METAL,
		Material = Enum.Material.Metal,
		Parent = rampFolder,
	})
	part({
		Name = "ArchPostL",
		Size = Vector3.new(0.5, 12, 0.5),
		Position = Vector3.new(-8.4, tunnelY + 7, z),
		Color = COL_METAL,
		Material = Enum.Material.Metal,
		Parent = rampFolder,
	})
	part({
		Name = "ArchPostR",
		Size = Vector3.new(0.5, 12, 0.5),
		Position = Vector3.new(8.4, tunnelY + 7, z),
		Color = COL_METAL,
		Material = Enum.Material.Metal,
		Parent = rampFolder,
	})
	local red = part({
		Name = "TunnelRed",
		Size = Vector3.new(2.5, 0.4, 2.5),
		Position = Vector3.new(0, tunnelY + 13.5, z),
		Color = COL_RED,
		Material = Enum.Material.Neon,
		CanCollide = false,
		Parent = rampFolder,
	})
	light(red, COL_RED, 3.5, 22)
end

-- Rise back into club level
local riseSteps = 10
local riseLen = 24
for i = 0, riseSteps - 1 do
	local t0 = i / riseSteps
	local t1 = (i + 1) / riseSteps
	local z0 = tunnelZ1 + t0 * riseLen
	local z1 = tunnelZ1 + t1 * riseLen
	local y0 = tunnelY + rampDrop * t0
	local y1 = tunnelY + rampDrop * t1
	part({
		Name = "RiseStep" .. i,
		Size = Vector3.new(18, math.max(1.4, math.abs(y1 - y0) + 1), z1 - z0 + 0.25),
		Position = Vector3.new(0, (y0 + y1) / 2, (z0 + z1) / 2),
		Color = COL_FLOOR,
		Material = Enum.Material.Brick,
		Parent = rampFolder,
	})
	part({
		Name = "RiseWallL" .. i,
		Size = Vector3.new(1.8, 12, z1 - z0 + 0.25),
		Position = Vector3.new(-9.5, (y0 + y1) / 2 + 6, (z0 + z1) / 2),
		Color = COL_BRICK_DARK,
		Material = Enum.Material.Brick,
		Parent = rampFolder,
	})
	part({
		Name = "RiseWallR" .. i,
		Size = Vector3.new(1.8, 12, z1 - z0 + 0.25),
		Position = Vector3.new(9.5, (y0 + y1) / 2 + 6, (z0 + z1) / 2),
		Color = COL_BRICK_DARK,
		Material = Enum.Material.Brick,
		Parent = rampFolder,
	})
end

local clubZ0 = tunnelZ1 + riseLen -- ~ first interior room center base

----------------------------------------------------------------
-- 3. SECURITY (ID + fashion check)
----------------------------------------------------------------
local secCenter = Vector3.new(0, 1, clubZ0 + 20)
local sec = roomShell({
	Name = "Security",
	Center = secCenter,
	Size = Vector3.new(48, 16, 40),
	DoorGaps = { S = 14, N = 12 },
	FloorColor = COL_FLOOR,
	WallColor = COL_BRICK_DARK,
})

-- Split desks + aisle (walkable center)
part({ Name = "DeskL", Size = Vector3.new(14, 3.5, 5), Position = Vector3.new(-12, 2.75, secCenter.Z + 2), Color = COL_METAL, Material = Enum.Material.DiamondPlate, Parent = sec })
part({ Name = "DeskR", Size = Vector3.new(14, 3.5, 5), Position = Vector3.new(12, 2.75, secCenter.Z + 2), Color = COL_METAL, Material = Enum.Material.DiamondPlate, Parent = sec })
part({ Name = "MonitorL", Size = Vector3.new(3, 2, 0.4), Position = Vector3.new(-12, 5.5, secCenter.Z + 0.5), Color = Color3.fromRGB(40, 80, 50), Material = Enum.Material.Neon, CanCollide = false, Parent = sec })
part({ Name = "MonitorR", Size = Vector3.new(3, 2, 0.4), Position = Vector3.new(12, 5.5, secCenter.Z + 0.5), Color = Color3.fromRGB(40, 80, 50), Material = Enum.Material.Neon, CanCollide = false, Parent = sec })

local idSign = part({
	Name = "IDSign",
	Size = Vector3.new(10, 2.8, 0.35),
	Position = Vector3.new(-12, 8.5, secCenter.Z - 2),
	Color = COL_BLACK,
	Material = Enum.Material.SmoothPlastic,
	CanCollide = false,
	Parent = sec,
})
sign(idSign, "ID CHECK", Enum.NormalId.Front, COL_WHITE, COL_BLACK)

local fashionSign = part({
	Name = "FashionSign",
	Size = Vector3.new(12, 2.8, 0.35),
	Position = Vector3.new(12, 8.5, secCenter.Z - 2),
	Color = COL_BLACK,
	Material = Enum.Material.SmoothPlastic,
	CanCollide = false,
	Parent = sec,
})
sign(fashionSign, "FASHION CHECK", Enum.NormalId.Front, COL_RED, COL_BLACK)

local secLight = part({
	Name = "SecWash",
	Size = Vector3.new(1, 1, 1),
	Position = Vector3.new(0, 14, secCenter.Z),
	Color = COL_RED,
	Material = Enum.Material.Neon,
	CanCollide = false,
	Parent = sec,
})
light(secLight, COL_RED, 2.8, 36)

-- Barrier posts flanking aisle
for _, x in ipairs({ -4, 4 }) do
	part({ Name = "AislePost", Size = Vector3.new(0.6, 4, 0.6), Position = Vector3.new(x, 3, secCenter.Z + 8), Color = COL_BLACK, Material = Enum.Material.Metal, Parent = sec })
end

----------------------------------------------------------------
-- 4. LOCKERS
----------------------------------------------------------------
local lockCenter = Vector3.new(0, 1, secCenter.Z + 48)
local lockers = roomShell({
	Name = "Lockers",
	Center = lockCenter,
	Size = Vector3.new(56, 16, 52),
	DoorGaps = { S = 12, N = 14 },
	FloorColor = COL_FLOOR,
	WallColor = COL_BRICK,
})

for row = 0, 2 do
	for col = 0, 5 do
		local x = -20 + col * 8
		if x > -4 and x < 4 then
			-- keep center aisle clear
		else
			local z = lockCenter.Z - 14 + row * 12
			part({
				Name = "LockerBank",
				Size = Vector3.new(6, 8, 2.2),
				Position = Vector3.new(x, 5, z),
				Color = COL_METAL,
				Material = Enum.Material.Metal,
				Parent = lockers,
			})
			-- door seams
			part({
				Name = "LockerDoor",
				Size = Vector3.new(2.6, 7.2, 0.15),
				Position = Vector3.new(x - 1.5, 5, z - 1.2),
				Color = COL_SLATE,
				Material = Enum.Material.Metal,
				CanCollide = false,
				Parent = lockers,
			})
			part({
				Name = "LockerDoor2",
				Size = Vector3.new(2.6, 7.2, 0.15),
				Position = Vector3.new(x + 1.5, 5, z - 1.2),
				Color = COL_SLATE,
				Material = Enum.Material.Metal,
				CanCollide = false,
				Parent = lockers,
			})
		end
	end
end

local bench = part({
	Name = "Bench",
	Size = Vector3.new(18, 1.2, 3),
	Position = Vector3.new(0, 1.6, lockCenter.Z + 8),
	Color = Color3.fromRGB(40, 40, 44),
	Material = Enum.Material.Wood,
	Parent = lockers,
})

----------------------------------------------------------------
-- 5. MAIN / CHARLOTTE (dance floor)
----------------------------------------------------------------
local mainCenter = Vector3.new(10, 1, lockCenter.Z + 58)
local main = roomShell({
	Name = "MainCharlotte",
	Center = mainCenter,
	Size = Vector3.new(78, 18, 64),
	DoorGaps = { S = 14, E = 12, W = 10 },
	FloorColor = COL_FLOOR,
	FloorMaterial = Enum.Material.Brick,
	WallColor = COL_BRICK_DARK,
	Pipes = true,
})

-- Dance floor plate (slightly raised darker slab)
part({
	Name = "DancePlate",
	Size = Vector3.new(36, 0.25, 28),
	Position = Vector3.new(mainCenter.X, 1.2, mainCenter.Z - 2),
	Color = COL_BLACK,
	Material = Enum.Material.SmoothPlastic,
	Parent = main,
})

-- DJ booth / riser
part({
	Name = "DJRiser",
	Size = Vector3.new(16, 2.5, 8),
	Position = Vector3.new(mainCenter.X, 2.25, mainCenter.Z + 22),
	Color = COL_SLATE,
	Material = Enum.Material.Concrete,
	Parent = main,
})
part({
	Name = "DJDesk",
	Size = Vector3.new(12, 3, 3.5),
	Position = Vector3.new(mainCenter.X, 5, mainCenter.Z + 22),
	Color = COL_BLACK,
	Material = Enum.Material.SmoothPlastic,
	Parent = main,
})
part({
	Name = "CDJGlow",
	Size = Vector3.new(8, 0.3, 2),
	Position = Vector3.new(mainCenter.X, 6.6, mainCenter.Z + 22),
	Color = Color3.fromRGB(80, 180, 255),
	Material = Enum.Material.Neon,
	CanCollide = false,
	Parent = main,
})

-- Funktion-One-ish white stacks (left / right)
for _, xOff in ipairs({ -28, 28 }) do
	local bx = mainCenter.X + xOff
	part({
		Name = "StackBase",
		Size = Vector3.new(5, 10, 4),
		Position = Vector3.new(bx, 6, mainCenter.Z + 18),
		Color = COL_WHITE,
		Material = Enum.Material.SmoothPlastic,
		Parent = main,
	})
	part({
		Name = "Horn",
		Size = Vector3.new(6, 4, 5),
		Position = Vector3.new(bx, 13, mainCenter.Z + 18),
		Color = COL_WHITE,
		Material = Enum.Material.SmoothPlastic,
		Parent = main,
	})
	part({
		Name = "HornMouth",
		Size = Vector3.new(5, 3, 1),
		Position = Vector3.new(bx, 13, mainCenter.Z + 15.2),
		Color = COL_BLACK,
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
		Parent = main,
	})
end

-- Orange grid light panels (ceiling)
for r = 0, 2 do
	for c = 0, 5 do
		local bulb = part({
			Name = "OrangeGrid",
			Size = Vector3.new(2.2, 2.2, 0.35),
			Position = Vector3.new(mainCenter.X - 12 + c * 5, 16.5, mainCenter.Z - 12 + r * 6),
			Color = COL_ORANGE,
			Material = Enum.Material.Neon,
			CanCollide = false,
			Parent = main,
		})
		light(bulb, COL_ORANGE, 1.2, 16)
	end
end

local mainWash = part({
	Name = "MainWash",
	Size = Vector3.new(1.5, 1.5, 1.5),
	Position = Vector3.new(mainCenter.X, 15, mainCenter.Z),
	Color = COL_RED,
	Material = Enum.Material.Neon,
	CanCollide = false,
	Parent = main,
})
light(mainWash, COL_RED, 3.2, 55)

-- Side pillars
for _, xOff in ipairs({ -30, -10, 10, 30 }) do
	part({
		Name = "Pillar",
		Size = Vector3.new(3, 16, 3),
		Position = Vector3.new(mainCenter.X + xOff, 9, mainCenter.Z - 20),
		Color = COL_CONCRETE,
		Material = Enum.Material.Concrete,
		Parent = main,
	})
end

----------------------------------------------------------------
-- 6. STUDIO (off main, west)
----------------------------------------------------------------
local studioCenter = Vector3.new(mainCenter.X - 55, 1, mainCenter.Z)
local studio = roomShell({
	Name = "Studio",
	Center = studioCenter,
	Size = Vector3.new(36, 16, 40),
	DoorGaps = { E = 10 },
	FloorColor = COL_SLATE,
	FloorMaterial = Enum.Material.Concrete,
	WallColor = COL_BRICK_DARK,
})
part({
	Name = "Booth",
	Size = Vector3.new(10, 4, 6),
	Position = Vector3.new(studioCenter.X - 8, 3, studioCenter.Z + 8),
	Color = COL_BLACK,
	Material = Enum.Material.SmoothPlastic,
	Parent = studio,
})
part({
	Name = "Glass",
	Size = Vector3.new(0.3, 6, 8),
	Position = Vector3.new(studioCenter.X - 2.5, 5, studioCenter.Z + 8),
	Color = Color3.fromRGB(120, 160, 180),
	Material = Enum.Material.Glass,
	Transparency = 0.45,
	Reflectance = 0.2,
	Parent = studio,
})
local studioLight = part({
	Name = "StudioWash",
	Size = Vector3.new(1, 1, 1),
	Position = Vector3.new(studioCenter.X, 13, studioCenter.Z),
	Color = Color3.fromRGB(180, 200, 255),
	Material = Enum.Material.Neon,
	CanCollide = false,
	Parent = studio,
})
light(studioLight, Color3.fromRGB(160, 190, 255), 2, 28)

----------------------------------------------------------------
-- 7. DARK ROOMS (2×2 grid, east of main)
----------------------------------------------------------------
local darkOrigin = Vector3.new(mainCenter.X + 55, 1, mainCenter.Z - 8)
local darkFolder = Instance.new("Folder")
darkFolder.Name = "DarkRooms"
darkFolder.Parent = root

for row = 0, 1 do
	for col = 0, 1 do
		local cx = darkOrigin.X + col * 22
		local cz = darkOrigin.Z + row * 22
		local cell = roomShell({
			Name = "Dark" .. row .. col,
			Center = Vector3.new(cx, 1, cz),
			Size = Vector3.new(20, 12, 20),
			DoorGaps = { W = (col == 0 and row == 0) and 8 or 6 },
			FloorColor = COL_BLACK,
			FloorMaterial = Enum.Material.SmoothPlastic,
			WallColor = COL_BLACK,
			WallMaterial = Enum.Material.SmoothPlastic,
			CeilColor = COL_BLACK,
			Pipes = false,
		})
		cell.Parent = darkFolder
		local ember = part({
			Name = "Ember",
			Size = Vector3.new(0.6, 0.6, 0.6),
			Position = Vector3.new(cx, 9, cz),
			Color = Color3.fromRGB(180, 40, 20),
			Material = Enum.Material.Neon,
			CanCollide = false,
			Parent = cell,
		})
		light(ember, Color3.fromRGB(180, 40, 20), 0.6, 12)
	end
end

----------------------------------------------------------------
-- 8. BATHROOMS (bright tile — Mad Max contrast)
----------------------------------------------------------------
local bathCenter = Vector3.new(mainCenter.X + 20, 1, mainCenter.Z + 48)
local baths = roomShell({
	Name = "Bathrooms",
	Center = bathCenter,
	Size = Vector3.new(40, 14, 28),
	DoorGaps = { S = 10 },
	FloorColor = COL_TILE,
	FloorMaterial = Enum.Material.CeramicTiles,
	WallColor = COL_TILE,
	WallMaterial = Enum.Material.CeramicTiles,
	CeilColor = COL_WHITE,
	Pipes = false,
})

for i = 0, 3 do
	part({
		Name = "Stall",
		Size = Vector3.new(4, 8, 5),
		Position = Vector3.new(bathCenter.X - 12 + i * 7, 5, bathCenter.Z + 4),
		Color = COL_WHITE,
		Material = Enum.Material.SmoothPlastic,
		Parent = baths,
	})
	part({
		Name = "StallDoor",
		Size = Vector3.new(3.2, 7, 0.2),
		Position = Vector3.new(bathCenter.X - 12 + i * 7, 4.5, bathCenter.Z + 1.2),
		Color = Color3.fromRGB(200, 200, 205),
		Material = Enum.Material.SmoothPlastic,
		Parent = baths,
	})
end
for i = 0, 2 do
	part({
		Name = "Sink",
		Size = Vector3.new(3, 2, 2),
		Position = Vector3.new(bathCenter.X - 8 + i * 7, 3, bathCenter.Z - 8),
		Color = COL_WHITE,
		Material = Enum.Material.Porcelain,
		Parent = baths,
	})
end
local bathLight = part({
	Name = "BathFluoro",
	Size = Vector3.new(12, 0.4, 1),
	Position = Vector3.new(bathCenter.X, 12.5, bathCenter.Z),
	Color = Color3.fromRGB(255, 250, 230),
	Material = Enum.Material.Neon,
	CanCollide = false,
	Parent = baths,
})
light(bathLight, Color3.fromRGB(255, 250, 230), 4, 30)

----------------------------------------------------------------
-- 9. BREAK TIME / BACKYARD
----------------------------------------------------------------
local yard2Center = Vector3.new(mainCenter.X - 10, 1, mainCenter.Z + 85)
local breakYard = Instance.new("Folder")
breakYard.Name = "BreakTime"
breakYard.Parent = root

part({
	Name = "Gravel",
	Size = Vector3.new(70, 1, 50),
	Position = yard2Center,
	Color = COL_GRAVEL,
	Material = Enum.Material.Ground,
	Parent = breakYard,
})
-- low brick walls (open feel)
part({ Name = "BYWallN", Size = Vector3.new(70, 8, 2), Position = Vector3.new(yard2Center.X, 5, yard2Center.Z + 25), Color = COL_BRICK, Material = Enum.Material.Brick, Parent = breakYard })
part({ Name = "BYWallW", Size = Vector3.new(2, 8, 50), Position = Vector3.new(yard2Center.X - 35, 5, yard2Center.Z), Color = COL_BRICK, Material = Enum.Material.Brick, Parent = breakYard })
part({ Name = "BYWallE", Size = Vector3.new(2, 8, 50), Position = Vector3.new(yard2Center.X + 35, 5, yard2Center.Z), Color = COL_BRICK, Material = Enum.Material.Brick, Parent = breakYard })
-- doorway from baths / main side
part({ Name = "BYWallS_L", Size = Vector3.new(26, 8, 2), Position = Vector3.new(yard2Center.X - 18, 5, yard2Center.Z - 25), Color = COL_BRICK, Material = Enum.Material.Brick, Parent = breakYard })
part({ Name = "BYWallS_R", Size = Vector3.new(26, 8, 2), Position = Vector3.new(yard2Center.X + 18, 5, yard2Center.Z - 25), Color = COL_BRICK, Material = Enum.Material.Brick, Parent = breakYard })

-- picnic tables
for i = 0, 2 do
	local x = yard2Center.X - 16 + i * 16
	part({
		Name = "PicnicTop",
		Size = Vector3.new(8, 0.5, 4),
		Position = Vector3.new(x, 3.2, yard2Center.Z),
		Color = Color3.fromRGB(90, 70, 45),
		Material = Enum.Material.Wood,
		Parent = breakYard,
	})
	part({
		Name = "PicnicBenchA",
		Size = Vector3.new(8, 0.4, 1.2),
		Position = Vector3.new(x, 2.2, yard2Center.Z - 3),
		Color = Color3.fromRGB(90, 70, 45),
		Material = Enum.Material.Wood,
		Parent = breakYard,
	})
	part({
		Name = "PicnicBenchB",
		Size = Vector3.new(8, 0.4, 1.2),
		Position = Vector3.new(x, 2.2, yard2Center.Z + 3),
		Color = Color3.fromRGB(90, 70, 45),
		Material = Enum.Material.Wood,
		Parent = breakYard,
	})
end

-- string lights
for i = 0, 8 do
	local bulb = part({
		Name = "StringBulb",
		Size = Vector3.new(0.5, 0.5, 0.5),
		Position = Vector3.new(yard2Center.X - 20 + i * 5, 9, yard2Center.Z - 5 + (i % 2) * 8),
		Color = Color3.fromRGB(255, 220, 140),
		Material = Enum.Material.Neon,
		CanCollide = false,
		Parent = breakYard,
	})
	light(bulb, Color3.fromRGB(255, 210, 130), 1.2, 14)
end

local breakSign = part({
	Name = "BreakSign",
	Size = Vector3.new(16, 3, 0.4),
	Position = Vector3.new(yard2Center.X, 10, yard2Center.Z + 23),
	Color = COL_BLACK,
	Material = Enum.Material.SmoothPlastic,
	CanCollide = false,
	Parent = breakYard,
})
sign(breakSign, "BREAK TIME", Enum.NormalId.Front, COL_WHITE, COL_BLACK)

----------------------------------------------------------------
-- CONNECTING CORRIDORS (security→lockers already via doors;
-- main↔baths, main↔break via short halls)
----------------------------------------------------------------
local hall = Instance.new("Folder")
hall.Name = "Halls"
hall.Parent = root

-- Main → Bathrooms hall
part({
	Name = "HallBathFloor",
	Size = Vector3.new(12, 1, 18),
	Position = Vector3.new(mainCenter.X + 20, 1, mainCenter.Z + 32),
	Color = COL_FLOOR,
	Material = Enum.Material.Brick,
	Parent = hall,
})
part({
	Name = "HallBathCeil",
	Size = Vector3.new(12, 1, 18),
	Position = Vector3.new(mainCenter.X + 20, 14, mainCenter.Z + 32),
	Color = COL_CONCRETE_DARK,
	Material = Enum.Material.Concrete,
	Parent = hall,
})
for _, x in ipairs({ mainCenter.X + 14, mainCenter.X + 26 }) do
	part({
		Name = "HallBathWall",
		Size = Vector3.new(1.5, 12, 18),
		Position = Vector3.new(x, 7.5, mainCenter.Z + 32),
		Color = COL_BRICK_DARK,
		Material = Enum.Material.Brick,
		Parent = hall,
	})
end

----------------------------------------------------------------
-- SPAWN (courtyard, facing gate)
----------------------------------------------------------------
for _, child in ipairs(Workspace:GetChildren()) do
	if child:IsA("SpawnLocation") then
		child:Destroy()
	end
end
-- hide default baseplate under courtyard if present
local bp = Workspace:FindFirstChild("Baseplate")
if bp and bp:IsA("BasePart") then
	bp.Transparency = 1
	bp.CanCollide = false
end

local spawn = Instance.new("SpawnLocation")
spawn.Name = "BasementSpawn"
spawn.Size = Vector3.new(8, 1, 8)
spawn.Position = Vector3.new(0, 1.5, -30)
spawn.Anchored = true
spawn.Duration = 0
spawn.Neutral = true
spawn.Color = COL_RED
spawn.Material = Enum.Material.Neon
spawn.Parent = root

print("[BasementAuto] Club realism pass built (avatars skipped).")
print("[BasementAuto] Path: courtyard → gate → ramp → tunnel → security → lockers → main → studio / dark / baths → break time.")
print("[BasementAuto] Stop Play, then Publish to Roblox as Basement Rave Crew.")
