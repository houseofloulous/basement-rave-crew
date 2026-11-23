--[[
  Basement Rave Crew — ONE-SHOT AUTO BUILD (realism v2.1)
  =======================================================
  Club shell only — avatars deferred.

  Studio:
  1. New → Baseplate  (or open Basement Rave Crew)
  2. ServerScriptService → Script → paste THIS ENTIRE FILE
  3. View → Output  (so you can see [BasementAuto] lines)
  4. Play ▶ once → Stop → Publish

  Re-run safe: wipes Workspace.BasementAuto + prior lighting FX.
  If the world looks black: expand Workspace → BasementAuto should exist;
  this pass keeps spawn courtyard lit so you can see immediately.
]]

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

print("[BasementAuto] Building club shell…")

local ROOT_NAME = "BasementAuto"

local old = Workspace:FindFirstChild(ROOT_NAME)
if old then old:Destroy() end

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
	gui.CanvasSize = Vector2.new(800, 320)
	gui.LightInfluence = 0.15
	gui.Parent = parentPart
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = bgColor or Color3.fromRGB(20, 20, 22)
	frame.BorderSizePixel = 0
	frame.Parent = gui
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(0.94, 0.9)
	label.Position = UDim2.fromScale(0.03, 0.05)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = textColor or Color3.fromRGB(255, 240, 235)
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.Parent = frame
	return gui
end

-- Palette
local COL_ASPHALT = Color3.fromRGB(36, 36, 38)
local COL_BRICK = Color3.fromRGB(118, 62, 48)
local COL_BRICK_DARK = Color3.fromRGB(72, 42, 36)
local COL_BRICK_AGED = Color3.fromRGB(98, 55, 44)
local COL_CONCRETE = Color3.fromRGB(155, 148, 138)
local COL_CONCRETE_DARK = Color3.fromRGB(88, 84, 78)
local COL_CONCRETE_PALE = Color3.fromRGB(175, 170, 160)
local COL_SLATE = Color3.fromRGB(68, 66, 70)
local COL_METAL = Color3.fromRGB(55, 55, 60)
local COL_METAL_DK = Color3.fromRGB(32, 32, 36)
local COL_RUST = Color3.fromRGB(118, 72, 42)
local COL_CORRUGATED = Color3.fromRGB(70, 72, 75)
local COL_RED = Color3.fromRGB(210, 6, 0)
local COL_RED_DEEP = Color3.fromRGB(140, 8, 12)
local COL_BLACK = Color3.fromRGB(14, 14, 18)
local COL_FLOOR = Color3.fromRGB(58, 38, 34)
local COL_TILE = Color3.fromRGB(218, 212, 200)
local COL_GRAVEL = Color3.fromRGB(98, 92, 82)
local COL_WHITE = Color3.fromRGB(238, 236, 230)
local COL_ORANGE = Color3.fromRGB(255, 105, 28)
local COL_AMBER = Color3.fromRGB(255, 160, 50)

----------------------------------------------------------------
-- LIGHTING / ATMOSPHERE
-- Keep club mood, but spawn/courtyard must stay readable (v2 was too black).
----------------------------------------------------------------
Lighting.Ambient = Color3.fromRGB(55, 42, 58)
Lighting.OutdoorAmbient = Color3.fromRGB(70, 58, 75)
Lighting.Brightness = 1.6
Lighting.ClockTime = 20.5 -- evening, not pitch midnight
Lighting.GeographicLatitude = 40
Lighting.FogColor = Color3.fromRGB(28, 18, 32)
Lighting.FogStart = 90
Lighting.FogEnd = 320
Lighting.GlobalShadows = true
Lighting.EnvironmentDiffuseScale = 0.45
Lighting.EnvironmentSpecularScale = 0.25

local atmosphere = Instance.new("Atmosphere")
atmosphere.Density = 0.22
atmosphere.Offset = 0.2
atmosphere.Color = Color3.fromRGB(70, 40, 55)
atmosphere.Decay = Color3.fromRGB(30, 18, 28)
atmosphere.Glare = 0.08
atmosphere.Haze = 1.2
atmosphere.Parent = Lighting

local cc = Instance.new("ColorCorrectionEffect")
cc.Name = "BasementCC"
cc.TintColor = Color3.fromRGB(255, 210, 210)
cc.Brightness = 0.02
cc.Contrast = 0.1
cc.Saturation = 0.06
cc.Parent = Lighting

local bloom = Instance.new("BloomEffect")
bloom.Name = "BasementBloom"
bloom.Intensity = 0.45
bloom.Size = 24
bloom.Threshold = 0.9
bloom.Parent = Lighting

-- No heavy DOF — it crushed visibility in Play

----------------------------------------------------------------
-- ROOM SHELL HELPER
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
	local gaps = opts.DoorGaps or {}

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
		if axis == "X" then
			local total = fullSize.X
			local side = (total - gapW) / 2
			part({
				Name = name .. "L",
				Size = Vector3.new(side, fullSize.Y, fullSize.Z),
				Position = Vector3.new(fullPos.X - (gapW / 2 + side / 2), fullPos.Y, fullPos.Z),
				Color = wallColor,
				Material = wallMat,
				Parent = folder,
			})
			part({
				Name = name .. "R",
				Size = Vector3.new(side, fullSize.Y, fullSize.Z),
				Position = Vector3.new(fullPos.X + (gapW / 2 + side / 2), fullPos.Y, fullPos.Z),
				Color = wallColor,
				Material = wallMat,
				Parent = folder,
			})
			part({
				Name = name .. "Lintel",
				Size = Vector3.new(gapW + 1, 1.8, fullSize.Z + 0.4),
				Position = Vector3.new(fullPos.X, fullPos.Y + fullSize.Y / 2 - 0.9, fullPos.Z),
				Color = COL_METAL,
				Material = Enum.Material.Metal,
				Parent = folder,
			})
		else
			local total = fullSize.Z
			local side = (total - gapW) / 2
			part({
				Name = name .. "A",
				Size = Vector3.new(fullSize.X, fullSize.Y, side),
				Position = Vector3.new(fullPos.X, fullPos.Y, fullPos.Z - (gapW / 2 + side / 2)),
				Color = wallColor,
				Material = wallMat,
				Parent = folder,
			})
			part({
				Name = name .. "B",
				Size = Vector3.new(fullSize.X, fullSize.Y, side),
				Position = Vector3.new(fullPos.X, fullPos.Y, fullPos.Z + (gapW / 2 + side / 2)),
				Color = wallColor,
				Material = wallMat,
				Parent = folder,
			})
			part({
				Name = name .. "Lintel",
				Size = Vector3.new(fullSize.X + 0.4, 1.8, gapW + 1),
				Position = Vector3.new(fullPos.X, fullPos.Y + fullSize.Y / 2 - 0.9, fullPos.Z),
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

	if opts.Pipes ~= false then
		for i = -2, 2 do
			part({
				Name = "Pipe",
				Size = Vector3.new(0.85, 0.85, sz * 0.82),
				Position = Vector3.new(cx + i * (sx / 6), ceilY - 1.4, cz),
				Color = (i % 2 == 0) and COL_RUST or COL_METAL,
				Material = Enum.Material.CorrodedMetal,
				Parent = folder,
			})
		end
		-- cross conduits
		for i = -1, 1 do
			part({
				Name = "Conduit",
				Size = Vector3.new(sx * 0.75, 0.45, 0.45),
				Position = Vector3.new(cx, ceilY - 2.6, cz + i * (sz / 5)),
				Color = COL_METAL_DK,
				Material = Enum.Material.Metal,
				Parent = folder,
			})
		end
		for i = -1, 1 do
			part({
				Name = "IBeam",
				Size = Vector3.new(sx * 0.92, 1.0, 0.9),
				Position = Vector3.new(cx, ceilY - 3.4, cz + i * (sz / 3.5)),
				Color = COL_METAL,
				Material = Enum.Material.Metal,
				Parent = folder,
			})
		end
	end

	return folder
end

----------------------------------------------------------------
-- 1. STREET GATE (Knockdown industrial portal)
----------------------------------------------------------------
local street = Instance.new("Folder")
street.Name = "StreetGate"
street.Parent = root

-- Sidewalk strip south of gate
part({
	Name = "Sidewalk",
	Size = Vector3.new(70, 0.8, 18),
	Position = Vector3.new(0, 0.4, -62),
	Color = COL_CONCRETE_PALE,
	Material = Enum.Material.Concrete,
	Parent = street,
})
part({
	Name = "StreetAsphalt",
	Size = Vector3.new(90, 1, 22),
	Position = Vector3.new(0, 0.5, -78),
	Color = COL_ASPHALT,
	Material = Enum.Material.Asphalt,
	Parent = street,
})

-- Bollards + hydrant
for _, x in ipairs({ -14, -10, 10, 14 }) do
	part({
		Name = "Bollard",
		Size = Vector3.new(1.2, 2.4, 1.2),
		Position = Vector3.new(x, 1.6, -54),
		Color = COL_CONCRETE,
		Material = Enum.Material.Concrete,
		Parent = street,
	})
end
part({
	Name = "Hydrant",
	Size = Vector3.new(1.4, 2.2, 1.4),
	Position = Vector3.new(-18, 1.5, -56),
	Color = COL_METAL_DK,
	Material = Enum.Material.Metal,
	Parent = street,
})

-- Steel I-beam portal frame (~20 stud opening)
local gateZ = -48
local openingW = 20
-- Vertical I-beams (flange + web approximated as thick posts)
for _, x in ipairs({ -openingW / 2 - 1.5, openingW / 2 + 1.5 }) do
	part({
		Name = "IBeamPost",
		Size = Vector3.new(2.2, 22, 2.2),
		Position = Vector3.new(x, 11.5, gateZ),
		Color = COL_METAL,
		Material = Enum.Material.Metal,
		Parent = street,
	})
	part({
		Name = "IBeamFlange",
		Size = Vector3.new(3.4, 22, 0.6),
		Position = Vector3.new(x, 11.5, gateZ - 1.2),
		Color = COL_RUST,
		Material = Enum.Material.CorrodedMetal,
		Parent = street,
	})
end
-- Crossbeams
part({
	Name = "GateHeader",
	Size = Vector3.new(openingW + 8, 2.2, 2.4),
	Position = Vector3.new(0, 22, gateZ),
	Color = COL_METAL,
	Material = Enum.Material.Metal,
	Parent = street,
})
part({
	Name = "GateHeader2",
	Size = Vector3.new(openingW + 6, 1.4, 2.0),
	Position = Vector3.new(0, 19.5, gateZ),
	Color = COL_RUST,
	Material = Enum.Material.CorrodedMetal,
	Parent = street,
})
-- Roll-up shutter (open — corrugated panel tucked up)
for i = 0, 5 do
	part({
		Name = "RollUp",
		Size = Vector3.new(openingW - 1, 0.55, 0.4),
		Position = Vector3.new(0, 17.5 - i * 0.55, gateZ + 0.8),
		Color = COL_CORRUGATED,
		Material = Enum.Material.Metal,
		Parent = street,
	})
end
-- Corrugated metal wall right of gate
for i = 0, 11 do
	part({
		Name = "CorrPanel",
		Size = Vector3.new(2.8, 16, 0.35),
		Position = Vector3.new(14 + i * 2.9, 8.5, gateZ),
		Color = COL_CORRUGATED,
		Material = Enum.Material.DiamondPlate,
		Parent = street,
	})
end
-- Iron fence pickets left of gate
for i = 0, 18 do
	part({
		Name = "Picket",
		Size = Vector3.new(0.25, 10, 0.25),
		Position = Vector3.new(-12 - i * 1.4, 5.5, gateZ),
		Color = COL_BLACK,
		Material = Enum.Material.Metal,
		Parent = street,
	})
	part({
		Name = "PicketTip",
		Size = Vector3.new(0.35, 0.8, 0.35),
		Position = Vector3.new(-12 - i * 1.4, 11, gateZ),
		Color = COL_BLACK,
		Material = Enum.Material.Metal,
		Parent = street,
	})
end
part({
	Name = "FenceRail",
	Size = Vector3.new(28, 0.3, 0.3),
	Position = Vector3.new(-26, 8, gateZ),
	Color = COL_BLACK,
	Material = Enum.Material.Metal,
	Parent = street,
})
-- Security cams
for _, x in ipairs({ -12, 12 }) do
	part({
		Name = "CamArm",
		Size = Vector3.new(0.3, 0.3, 2),
		Position = Vector3.new(x, 20.5, gateZ - 1),
		Color = COL_METAL_DK,
		Material = Enum.Material.Metal,
		Parent = street,
	})
	part({
		Name = "Cam",
		Size = Vector3.new(0.8, 0.6, 1.2),
		Position = Vector3.new(x, 20.5, gateZ - 2.2),
		Color = COL_BLACK,
		Material = Enum.Material.SmoothPlastic,
		Parent = street,
	})
end

----------------------------------------------------------------
-- 2. COURTYARD (inside gate → brick warehouse + ramp mouth)
----------------------------------------------------------------
local yard = Instance.new("Folder")
yard.Name = "Courtyard"
yard.Parent = root

part({
	Name = "Asphalt",
	Size = Vector3.new(90, 1, 88),
	Position = Vector3.new(0, 0.5, -2),
	Color = COL_ASPHALT,
	Material = Enum.Material.Asphalt,
	Parent = yard,
})
-- asphalt patches
for _, pos in ipairs({
	Vector3.new(-18, 1.05, -20),
	Vector3.new(12, 1.05, 5),
	Vector3.new(-8, 1.05, 15),
}) do
	part({
		Name = "Patch",
		Size = Vector3.new(10, 0.12, 6),
		Position = pos,
		Color = Color3.fromRGB(55, 52, 48),
		Material = Enum.Material.Asphalt,
		CanCollide = false,
		Parent = yard,
	})
end

-- Perimeter brick
part({ Name = "WallW", Size = Vector3.new(2.5, 18, 90), Position = Vector3.new(-45, 9.5, -2), Color = COL_BRICK, Material = Enum.Material.Brick, Parent = yard })
part({ Name = "WallE", Size = Vector3.new(2.5, 18, 90), Position = Vector3.new(45, 9.5, -2), Color = COL_BRICK, Material = Enum.Material.Brick, Parent = yard })

-- Red VIP carpet / queue
part({
	Name = "RedCarpet",
	Size = Vector3.new(11, 0.12, 50),
	Position = Vector3.new(0, 1.06, -8),
	Color = COL_RED,
	Material = Enum.Material.Fabric,
	CanCollide = false,
	Parent = yard,
})
for i = 0, 9 do
	local z = -28 + i * 5.5
	part({ Name = "StanchionL", Size = Vector3.new(0.45, 3.2, 0.45), Position = Vector3.new(-6, 2.6, z), Color = COL_BLACK, Material = Enum.Material.Metal, Parent = yard })
	part({ Name = "StanchionR", Size = Vector3.new(0.45, 3.2, 0.45), Position = Vector3.new(6, 2.6, z), Color = COL_BLACK, Material = Enum.Material.Metal, Parent = yard })
	part({ Name = "RopeL", Size = Vector3.new(0.12, 0.12, 5), Position = Vector3.new(-6, 3.9, z + 2.5), Color = COL_RED, Material = Enum.Material.Fabric, CanCollide = false, Parent = yard })
	part({ Name = "RopeR", Size = Vector3.new(0.12, 0.12, 5), Position = Vector3.new(6, 3.9, z + 2.5), Color = COL_RED, Material = Enum.Material.Fabric, CanCollide = false, Parent = yard })
end

-- Sodium yard lights (bright enough to read courtyard in Play)
for _, pos in ipairs({
	Vector3.new(-24, 16, -25),
	Vector3.new(24, 16, -25),
	Vector3.new(-20, 14, -5),
	Vector3.new(20, 14, -5),
	Vector3.new(0, 14, 20),
}) do
	part({
		Name = "Pole",
		Size = Vector3.new(0.5, pos.Y - 1, 0.5),
		Position = Vector3.new(pos.X, pos.Y / 2, pos.Z),
		Color = COL_METAL,
		Material = Enum.Material.Metal,
		Parent = yard,
	})
	local bulb = part({
		Name = "Sodium",
		Size = Vector3.new(1.6, 1.6, 1.6),
		Position = pos,
		Color = COL_AMBER,
		Material = Enum.Material.Neon,
		CanCollide = false,
		Parent = yard,
	})
	light(bulb, COL_AMBER, 4.5, 70)
end

-- Dumpster / clutter
part({ Name = "Dumpster", Size = Vector3.new(9, 5.5, 5.5), Position = Vector3.new(-34, 3.5, -28), Color = COL_SLATE, Material = Enum.Material.Metal, Parent = yard })
part({ Name = "Pallets", Size = Vector3.new(5, 3.5, 4), Position = Vector3.new(36, 2.5, -18), Color = Color3.fromRGB(110, 85, 50), Material = Enum.Material.Wood, Parent = yard })

-- Brick warehouse facade with OPEN ramp mouth (no invisible full-width wall)
local facadeZ = 40
local mouthGap = 18 -- walkable opening width
part({
	Name = "RampMouthL",
	Size = Vector3.new(26, 14, 3),
	Position = Vector3.new(-(mouthGap / 2 + 13), 7.5, facadeZ),
	Color = COL_BRICK_AGED,
	Material = Enum.Material.Brick,
	Parent = yard,
})
part({
	Name = "RampMouthR",
	Size = Vector3.new(26, 14, 3),
	Position = Vector3.new(mouthGap / 2 + 13, 7.5, facadeZ),
	Color = COL_BRICK_AGED,
	Material = Enum.Material.Brick,
	Parent = yard,
})
part({
	Name = "FacadeLintelBand",
	Size = Vector3.new(70, 10, 3),
	Position = Vector3.new(0, 19, facadeZ),
	Color = COL_BRICK_AGED,
	Material = Enum.Material.Brick,
	Parent = yard,
})
-- Windows on side masses
for _, x in ipairs({ -28, -16, 16, 28 }) do
	part({
		Name = "Window",
		Size = Vector3.new(7, 5, 0.4),
		Position = Vector3.new(x, 12, facadeZ - 1.6),
		Color = Color3.fromRGB(30, 35, 45),
		Material = Enum.Material.Glass,
		Transparency = 0.35,
		Reflectance = 0.15,
		CanCollide = false,
		Parent = yard,
	})
end
local kdSign = part({
	Name = "KnockdownSign",
	Size = Vector3.new(28, 5, 0.5),
	Position = Vector3.new(0, 24, facadeZ - 1.8),
	Color = COL_WHITE,
	Material = Enum.Material.SmoothPlastic,
	CanCollide = false,
	Parent = yard,
})
sign(kdSign, "KNOCKDOWN CENTER\nWELCOME", Enum.NormalId.Front, COL_BLACK, COL_WHITE)
-- Entrance flood so ramp mouth is readable
local entranceFlood = part({
	Name = "EntranceFlood",
	Size = Vector3.new(2, 2, 2),
	Position = Vector3.new(0, 10, facadeZ - 6),
	Color = COL_AMBER,
	Material = Enum.Material.Neon,
	CanCollide = false,
	Parent = yard,
})
light(entranceFlood, COL_AMBER, 5, 45)

-- Roof planter + rail above tunnel (from ramp photo)
part({
	Name = "RoofRail",
	Size = Vector3.new(20, 1.2, 0.3),
	Position = Vector3.new(-8, 26, facadeZ - 2),
	Color = COL_METAL,
	Material = Enum.Material.Metal,
	Parent = yard,
})
part({
	Name = "Planter",
	Size = Vector3.new(8, 2, 3),
	Position = Vector3.new(-8, 24, facadeZ - 3),
	Color = Color3.fromRGB(50, 40, 30),
	Material = Enum.Material.Wood,
	Parent = yard,
})
part({
	Name = "Foliage",
	Size = Vector3.new(7, 2.5, 2.5),
	Position = Vector3.new(-8, 26, facadeZ - 3),
	Color = Color3.fromRGB(40, 80, 45),
	Material = Enum.Material.Grass,
	CanCollide = false,
	Parent = yard,
})

-- Smokestack silhouette
part({
	Name = "Stack",
	Size = Vector3.new(4, 40, 4),
	Position = Vector3.new(-32, 30, facadeZ + 8),
	Color = COL_BRICK_DARK,
	Material = Enum.Material.Brick,
	Parent = yard,
})

----------------------------------------------------------------
-- 3. RAMP (tall cast-concrete walls + pipe rails → black mouth)
----------------------------------------------------------------
local rampFolder = Instance.new("Folder")
rampFolder.Name = "RampTunnel"
rampFolder.Parent = root

local rampSteps = 16
local rampDrop = 18
local rampStartZ = 42
local rampLen = 48
local rampWidth = 16

	for i = 0, rampSteps - 1 do
	local t0 = i / rampSteps
	local t1 = (i + 1) / rampSteps
	local z0 = rampStartZ + t0 * rampLen
	local z1 = rampStartZ + t1 * rampLen
	local y0 = 1 - rampDrop * t0
	local y1 = 1 - rampDrop * t1
	local yMid = (y0 + y1) / 2
	local thick = math.max(1.5, math.abs(y0 - y1) + 1.1)
	part({
		Name = "RampFloor" .. i,
		Size = Vector3.new(rampWidth, thick, z1 - z0 + 0.3),
		Position = Vector3.new(0, yMid, (z0 + z1) / 2),
		Color = COL_CONCRETE_PALE,
		Material = Enum.Material.Concrete,
		Parent = rampFolder,
	})
	-- Tall cast walls (formwork bands)
	local wallH = 14 + rampDrop * t1 * 0.25
	for side = -1, 1, 2 do
		part({
			Name = "RampWall",
			Size = Vector3.new(2.2, wallH, z1 - z0 + 0.3),
			Position = Vector3.new(side * (rampWidth / 2 + 1), y1 + wallH / 2 - 1, (z0 + z1) / 2),
			Color = COL_CONCRETE,
			Material = Enum.Material.Concrete,
			Parent = rampFolder,
		})
		-- formwork seam lines
		part({
			Name = "FormLine",
			Size = Vector3.new(0.15, wallH * 0.9, 0.15),
			Position = Vector3.new(side * (rampWidth / 2 + 0.1), y1 + wallH / 2 - 1, (z0 + z1) / 2),
			Color = COL_CONCRETE_DARK,
			Material = Enum.Material.Concrete,
			CanCollide = false,
			Parent = rampFolder,
		})
		-- pipe handrail (collide off — was snagging players)
		part({
			Name = "Rail",
			Size = Vector3.new(0.28, 0.28, z1 - z0 + 0.2),
			Position = Vector3.new(side * (rampWidth / 2 - 0.8), y1 + 3.6, (z0 + z1) / 2),
			Color = COL_METAL,
			Material = Enum.Material.Metal,
			CanCollide = false,
			Parent = rampFolder,
		})
		part({
			Name = "RailPost",
			Size = Vector3.new(0.25, 3.4, 0.25),
			Position = Vector3.new(side * (rampWidth / 2 - 0.8), y1 + 2.2, (z0 + z1) / 2),
			Color = COL_METAL,
			Material = Enum.Material.Metal,
			CanCollide = false,
			Parent = rampFolder,
		})
	end
	-- Path lights down the ramp (every other step)
	if i % 2 == 0 then
		local lamp = part({
			Name = "RampLamp",
			Size = Vector3.new(1.2, 0.4, 1.2),
			Position = Vector3.new(0, y1 + 5.5, (z0 + z1) / 2),
			Color = Color3.fromRGB(255, 190, 120),
			Material = Enum.Material.Neon,
			CanCollide = false,
			Parent = rampFolder,
		})
		light(lamp, Color3.fromRGB(255, 200, 140), 3.5, 28)
	end
end

local tunnelY = 1 - rampDrop
local tunnelZ0 = rampStartZ + rampLen
local tunnelZ1 = tunnelZ0 + 42

-- Mouth jambs only (NO solid black wall across the path — that blocked Play)
part({
	Name = "MouthJambL",
	Size = Vector3.new(1.5, 14, 1.5),
	Position = Vector3.new(-(rampWidth / 2) - 0.2, tunnelY + 7, tunnelZ0),
	Color = COL_METAL_DK,
	Material = Enum.Material.Metal,
	Parent = rampFolder,
})
part({
	Name = "MouthJambR",
	Size = Vector3.new(1.5, 14, 1.5),
	Position = Vector3.new(rampWidth / 2 + 0.2, tunnelY + 7, tunnelZ0),
	Color = COL_METAL_DK,
	Material = Enum.Material.Metal,
	Parent = rampFolder,
})
part({
	Name = "MouthLintel",
	Size = Vector3.new(rampWidth + 2, 1.5, 1.5),
	Position = Vector3.new(0, tunnelY + 14, tunnelZ0),
	Color = COL_METAL_DK,
	Material = Enum.Material.Metal,
	Parent = rampFolder,
})
local mouthLight = part({
	Name = "MouthLight",
	Size = Vector3.new(2, 0.5, 2),
	Position = Vector3.new(0, tunnelY + 12.5, tunnelZ0 + 2),
	Color = COL_RED,
	Material = Enum.Material.Neon,
	CanCollide = false,
	Parent = rampFolder,
})
light(mouthLight, COL_RED, 4, 30)

----------------------------------------------------------------
-- 4. TUNNEL (brick arches, mesh rails, red wash, amber ahead)
----------------------------------------------------------------
part({
	Name = "TunnelFloor",
	Size = Vector3.new(rampWidth, 1, tunnelZ1 - tunnelZ0),
	Position = Vector3.new(0, tunnelY, (tunnelZ0 + tunnelZ1) / 2),
	Color = COL_BRICK_DARK,
	Material = Enum.Material.Brick,
	Parent = rampFolder,
})
part({
	Name = "TunnelWallL",
	Size = Vector3.new(2, 14, tunnelZ1 - tunnelZ0),
	Position = Vector3.new(-(rampWidth / 2 + 1), tunnelY + 7, (tunnelZ0 + tunnelZ1) / 2),
	Color = COL_BRICK_AGED,
	Material = Enum.Material.Brick,
	Parent = rampFolder,
})
part({
	Name = "TunnelWallR",
	Size = Vector3.new(2, 14, tunnelZ1 - tunnelZ0),
	Position = Vector3.new(rampWidth / 2 + 1, tunnelY + 7, (tunnelZ0 + tunnelZ1) / 2),
	Color = COL_BRICK_AGED,
	Material = Enum.Material.Brick,
	Parent = rampFolder,
})
part({
	Name = "TunnelCeil",
	Size = Vector3.new(rampWidth + 2, 1.5, tunnelZ1 - tunnelZ0),
	Position = Vector3.new(0, tunnelY + 14, (tunnelZ0 + tunnelZ1) / 2),
	Color = COL_BRICK_DARK,
	Material = Enum.Material.Brick,
	Parent = rampFolder,
})

-- Arch ribs (decorative — no collide in walk lane) + red wash
for i = 0, 9 do
	local z = tunnelZ0 + 3 + i * 4
	for a = 0, 6 do
		local ang = math.rad(-90 + a * 30)
		local ax = math.cos(ang) * 7.2
		local ay = tunnelY + 7 + math.sin(ang) * 6
		-- Keep arch bricks above head / out of center aisle
		part({
			Name = "ArchBrick",
			Size = Vector3.new(1.6, 1.1, 0.9),
			Position = Vector3.new(ax, ay, z),
			Color = COL_BRICK,
			Material = Enum.Material.Brick,
			CanCollide = false,
			Parent = rampFolder,
		})
	end
	-- Pillars against walls (leave ~10-stud clear aisle)
	part({
		Name = "ArchPillarL",
		Size = Vector3.new(2, 10, 2),
		Position = Vector3.new(-8.2, tunnelY + 5, z),
		Color = COL_BRICK,
		Material = Enum.Material.Brick,
		Parent = rampFolder,
	})
	part({
		Name = "ArchPillarR",
		Size = Vector3.new(2, 10, 2),
		Position = Vector3.new(8.2, tunnelY + 5, z),
		Color = COL_BRICK,
		Material = Enum.Material.Brick,
		Parent = rampFolder,
	})
	-- Mesh rails — visual only
	part({
		Name = "MeshRailL",
		Size = Vector3.new(0.15, 2.2, 3.5),
		Position = Vector3.new(-6.2, tunnelY + 2.2, z),
		Color = COL_BLACK,
		Material = Enum.Material.Metal,
		Transparency = 0.35,
		CanCollide = false,
		Parent = rampFolder,
	})
	part({
		Name = "MeshRailR",
		Size = Vector3.new(0.15, 2.2, 3.5),
		Position = Vector3.new(6.2, tunnelY + 2.2, z),
		Color = COL_BLACK,
		Material = Enum.Material.Metal,
		Transparency = 0.35,
		CanCollide = false,
		Parent = rampFolder,
	})
	if i % 2 == 0 then
		part({
			Name = "WallSpeaker",
			Size = Vector3.new(1.5, 3, 2),
			Position = Vector3.new(-9.2, tunnelY + 9, z),
			Color = COL_BLACK,
			Material = Enum.Material.SmoothPlastic,
			CanCollide = false,
			Parent = rampFolder,
		})
		part({
			Name = "WallSpeaker",
			Size = Vector3.new(1.5, 3, 2),
			Position = Vector3.new(9.2, tunnelY + 9, z),
			Color = COL_BLACK,
			Material = Enum.Material.SmoothPlastic,
			CanCollide = false,
			Parent = rampFolder,
		})
	end
	local red = part({
		Name = "TunnelRed",
		Size = Vector3.new(3, 0.4, 3),
		Position = Vector3.new(0, tunnelY + 13.2, z),
		Color = COL_RED,
		Material = Enum.Material.Neon,
		CanCollide = false,
		Parent = rampFolder,
	})
	light(red, COL_RED, 5.5, 32)
	-- Floor path glow so tunnel is never pitch black
	local pathGlow = part({
		Name = "TunnelPathGlow",
		Size = Vector3.new(4, 0.15, 2),
		Position = Vector3.new(0, tunnelY + 0.7, z),
		Color = COL_RED,
		Material = Enum.Material.Neon,
		CanCollide = false,
		Parent = rampFolder,
	})
	light(pathGlow, Color3.fromRGB(255, 80, 60), 2.2, 18)
end

-- Amber grid at tunnel end (pull toward club) — brighter
for r = 0, 3 do
	for c = 0, 5 do
		local bulb = part({
			Name = "AmberGrid",
			Size = Vector3.new(1.4, 1.4, 0.3),
			Position = Vector3.new(-5 + c * 2, tunnelY + 4 + r * 2.2, tunnelZ1 - 1),
			Color = COL_AMBER,
			Material = Enum.Material.Neon,
			CanCollide = false,
			Parent = rampFolder,
		})
		light(bulb, COL_AMBER, 2.2, 16)
	end
end

-- Rise into club
local riseSteps = 10
local riseLen = 26
for i = 0, riseSteps - 1 do
	local t0 = i / riseSteps
	local t1 = (i + 1) / riseSteps
	local z0 = tunnelZ1 + t0 * riseLen
	local z1 = tunnelZ1 + t1 * riseLen
	local y0 = tunnelY + rampDrop * t0
	local y1 = tunnelY + rampDrop * t1
	part({
		Name = "RiseFloor" .. i,
		Size = Vector3.new(rampWidth, math.max(1.5, math.abs(y1 - y0) + 1), z1 - z0 + 0.3),
		Position = Vector3.new(0, (y0 + y1) / 2, (z0 + z1) / 2),
		Color = COL_FLOOR,
		Material = Enum.Material.Brick,
		Parent = rampFolder,
	})
	for side = -1, 1, 2 do
		part({
			Name = "RiseWall",
			Size = Vector3.new(2, 12, z1 - z0 + 0.3),
			Position = Vector3.new(side * (rampWidth / 2 + 1), (y0 + y1) / 2 + 6, (z0 + z1) / 2),
			Color = COL_BRICK_DARK,
			Material = Enum.Material.Brick,
			Parent = rampFolder,
		})
	end
	if i % 2 == 0 then
		local riseLamp = part({
			Name = "RiseLamp",
			Size = Vector3.new(1.2, 0.4, 1.2),
			Position = Vector3.new(0, (y0 + y1) / 2 + 5, (z0 + z1) / 2),
			Color = COL_AMBER,
			Material = Enum.Material.Neon,
			CanCollide = false,
			Parent = rampFolder,
		})
		light(riseLamp, COL_AMBER, 3.2, 24)
	end
end

local clubZ0 = tunnelZ1 + riseLen

----------------------------------------------------------------
-- 5. SECURITY
----------------------------------------------------------------
local secCenter = Vector3.new(0, 1, clubZ0 + 22)
local sec = roomShell({
	Name = "Security",
	Center = secCenter,
	Size = Vector3.new(52, 16, 42),
	DoorGaps = { S = 14, N = 12 },
	FloorColor = COL_FLOOR,
	WallColor = COL_BRICK_DARK,
})

-- Desks leave a clear ~10-stud center aisle to lockers
part({ Name = "DeskL", Size = Vector3.new(14, 3.6, 5.5), Position = Vector3.new(-14, 2.8, secCenter.Z + 2), Color = COL_METAL, Material = Enum.Material.DiamondPlate, Parent = sec })
part({ Name = "DeskR", Size = Vector3.new(14, 3.6, 5.5), Position = Vector3.new(14, 2.8, secCenter.Z + 2), Color = COL_METAL, Material = Enum.Material.DiamondPlate, Parent = sec })
part({ Name = "MonitorL", Size = Vector3.new(3.2, 2.2, 0.35), Position = Vector3.new(-14, 5.6, secCenter.Z + 0.2), Color = Color3.fromRGB(35, 90, 55), Material = Enum.Material.Neon, CanCollide = false, Parent = sec })
part({ Name = "MonitorR", Size = Vector3.new(3.2, 2.2, 0.35), Position = Vector3.new(14, 5.6, secCenter.Z + 0.2), Color = Color3.fromRGB(35, 90, 55), Material = Enum.Material.Neon, CanCollide = false, Parent = sec })
-- Scanners beside aisle (not in the walk lane)
for _, x in ipairs({ -8, 8 }) do
	part({ Name = "Scanner", Size = Vector3.new(1.2, 6, 1.2), Position = Vector3.new(x, 4, secCenter.Z + 10), Color = COL_BLACK, Material = Enum.Material.Metal, Parent = sec })
	part({ Name = "ScannerBeam", Size = Vector3.new(0.2, 4, 0.2), Position = Vector3.new(x, 4, secCenter.Z + 10), Color = COL_RED, Material = Enum.Material.Neon, CanCollide = false, Parent = sec })
end

local idSign = part({ Name = "IDSign", Size = Vector3.new(11, 3, 0.35), Position = Vector3.new(-14, 9, secCenter.Z - 3), Color = COL_BLACK, Material = Enum.Material.SmoothPlastic, CanCollide = false, Parent = sec })
sign(idSign, "ID CHECK", Enum.NormalId.Front, COL_WHITE, COL_BLACK)
local fashionSign = part({ Name = "FashionSign", Size = Vector3.new(13, 3, 0.35), Position = Vector3.new(14, 9, secCenter.Z - 3), Color = COL_BLACK, Material = Enum.Material.SmoothPlastic, CanCollide = false, Parent = sec })
sign(fashionSign, "FASHION CHECK", Enum.NormalId.Front, COL_RED, COL_BLACK)

for _, pos in ipairs({
	Vector3.new(0, 13, secCenter.Z - 8),
	Vector3.new(0, 13, secCenter.Z),
	Vector3.new(0, 13, secCenter.Z + 10),
}) do
	local secLight = part({
		Name = "SecWash",
		Size = Vector3.new(1.4, 1.4, 1.4),
		Position = pos,
		Color = COL_RED,
		Material = Enum.Material.Neon,
		CanCollide = false,
		Parent = sec,
	})
	light(secLight, COL_RED, 4, 36)
end
-- Floor path stripe toward lockers
part({
	Name = "SecPathGlow",
	Size = Vector3.new(6, 0.12, 28),
	Position = Vector3.new(0, 1.15, secCenter.Z),
	Color = COL_RED,
	Material = Enum.Material.Neon,
	CanCollide = false,
	Parent = sec,
})

----------------------------------------------------------------
-- 6. LOCKERS (after security — clear center aisle, lit banks)
----------------------------------------------------------------
local lockCenter = Vector3.new(0, 1, secCenter.Z + 50)
local lockers = roomShell({
	Name = "Lockers",
	Center = lockCenter,
	Size = Vector3.new(58, 16, 54),
	DoorGaps = { S = 14, N = 14 },
	FloorColor = COL_FLOOR,
	WallColor = COL_BRICK,
})

local lockerSign = part({
	Name = "LockersSign",
	Size = Vector3.new(16, 3.2, 0.4),
	Position = Vector3.new(0, 10, lockCenter.Z - 24),
	Color = COL_BLACK,
	Material = Enum.Material.SmoothPlastic,
	CanCollide = false,
	Parent = lockers,
})
sign(lockerSign, "LOCKERS", Enum.NormalId.Front, COL_WHITE, COL_BLACK)

-- Banks on left/right only — center aisle ~12 studs clear to main
for row = 0, 2 do
	for col = 0, 6 do
		local x = -24 + col * 8
		if x <= -8 or x >= 8 then
			local z = lockCenter.Z - 16 + row * 14
			part({
				Name = "LockerBank",
				Size = Vector3.new(6.5, 9, 2.4),
				Position = Vector3.new(x, 5.5, z),
				Color = COL_METAL,
				Material = Enum.Material.Metal,
				Parent = lockers,
			})
			for d = -1, 1, 2 do
				part({
					Name = "LockerDoor",
					Size = Vector3.new(2.8, 8, 0.15),
					Position = Vector3.new(x + d * 1.6, 5.5, z - 1.3),
					Color = COL_SLATE,
					Material = Enum.Material.Metal,
					CanCollide = false,
					Parent = lockers,
				})
				part({
					Name = "Handle",
					Size = Vector3.new(0.15, 0.8, 0.3),
					Position = Vector3.new(x + d * 0.5, 5.5, z - 1.5),
					Color = COL_METAL_DK,
					Material = Enum.Material.Metal,
					CanCollide = false,
					Parent = lockers,
				})
			end
		end
	end
end
part({
	Name = "Bench",
	Size = Vector3.new(16, 1.3, 3.2),
	Position = Vector3.new(0, 1.7, lockCenter.Z + 8),
	Color = Color3.fromRGB(38, 38, 42),
	Material = Enum.Material.Wood,
	Parent = lockers,
})
part({
	Name = "CoatHooks",
	Size = Vector3.new(16, 0.4, 0.4),
	Position = Vector3.new(0, 8, lockCenter.Z + 22),
	Color = COL_METAL,
	Material = Enum.Material.Metal,
	CanCollide = false,
	Parent = lockers,
})
-- Lit aisle + bank washes
for _, pos in ipairs({
	Vector3.new(0, 12, lockCenter.Z - 10),
	Vector3.new(0, 12, lockCenter.Z + 5),
	Vector3.new(0, 12, lockCenter.Z + 18),
	Vector3.new(-16, 10, lockCenter.Z),
	Vector3.new(16, 10, lockCenter.Z),
}) do
	local ll = part({
		Name = "LockerLight",
		Size = Vector3.new(1.3, 1.3, 1.3),
		Position = pos,
		Color = Color3.fromRGB(255, 210, 160),
		Material = Enum.Material.Neon,
		CanCollide = false,
		Parent = lockers,
	})
	light(ll, Color3.fromRGB(255, 210, 160), 3.5, 32)
end
part({
	Name = "LockerPathGlow",
	Size = Vector3.new(6, 0.12, 40),
	Position = Vector3.new(0, 1.15, lockCenter.Z),
	Color = COL_AMBER,
	Material = Enum.Material.Neon,
	CanCollide = false,
	Parent = lockers,
})

----------------------------------------------------------------
-- 7. MAIN / CHARLOTTE
----------------------------------------------------------------
local mainCenter = Vector3.new(12, 1, lockCenter.Z + 60)
local main = roomShell({
	Name = "MainCharlotte",
	Center = mainCenter,
	Size = Vector3.new(82, 20, 68),
	DoorGaps = { S = 14, E = 12, W = 10, N = 10 },
	FloorColor = COL_FLOOR,
	FloorMaterial = Enum.Material.Brick,
	WallColor = COL_BRICK_DARK,
	Pipes = true,
})

-- Extra diagonal ceiling pipes (photo ref) — no collide
for i = 0, 3 do
	part({
		Name = "DiagPipe",
		Size = Vector3.new(0.7, 0.7, 40),
		CFrame = CFrame.new(mainCenter.X - 20 + i * 10, 17.5, mainCenter.Z) * CFrame.Angles(0, math.rad(25 + i * 8), 0),
		Color = COL_RUST,
		Material = Enum.Material.CorrodedMetal,
		CanCollide = false,
		Parent = main,
	})
end

part({
	Name = "DancePlate",
	Size = Vector3.new(40, 0.3, 32),
	Position = Vector3.new(mainCenter.X, 1.2, mainCenter.Z - 4),
	Color = COL_BLACK,
	Material = Enum.Material.SmoothPlastic,
	Parent = main,
})

-- DJ riser + booth
part({ Name = "DJRiser", Size = Vector3.new(18, 2.8, 10), Position = Vector3.new(mainCenter.X, 2.4, mainCenter.Z + 24), Color = COL_SLATE, Material = Enum.Material.Concrete, Parent = main })
part({ Name = "DJDesk", Size = Vector3.new(14, 3.2, 4), Position = Vector3.new(mainCenter.X, 5.2, mainCenter.Z + 24), Color = COL_BLACK, Material = Enum.Material.SmoothPlastic, Parent = main })
part({ Name = "CDJGlow", Size = Vector3.new(10, 0.25, 2.2), Position = Vector3.new(mainCenter.X, 6.9, mainCenter.Z + 24), Color = Color3.fromRGB(70, 170, 255), Material = Enum.Material.Neon, CanCollide = false, Parent = main })
part({ Name = "DJRail", Size = Vector3.new(18, 1.2, 0.3), Position = Vector3.new(mainCenter.X, 4.2, mainCenter.Z + 19), Color = COL_METAL, Material = Enum.Material.Metal, Parent = main })

-- Funktion-One-ish stacks
for _, xOff in ipairs({ -30, 30 }) do
	local bx = mainCenter.X + xOff
	part({ Name = "StackLow", Size = Vector3.new(5.5, 6, 4.5), Position = Vector3.new(bx, 4, mainCenter.Z + 20), Color = COL_WHITE, Material = Enum.Material.SmoothPlastic, Parent = main })
	part({ Name = "StackMid", Size = Vector3.new(5.5, 5, 4.5), Position = Vector3.new(bx, 9.5, mainCenter.Z + 20), Color = COL_WHITE, Material = Enum.Material.SmoothPlastic, Parent = main })
	part({ Name = "Horn", Size = Vector3.new(7, 4.5, 5.5), Position = Vector3.new(bx, 14.5, mainCenter.Z + 20), Color = COL_WHITE, Material = Enum.Material.SmoothPlastic, Parent = main })
	part({ Name = "HornMouth", Size = Vector3.new(5.5, 3.5, 1.2), Position = Vector3.new(bx, 14.5, mainCenter.Z + 16.8), Color = COL_BLACK, Material = Enum.Material.SmoothPlastic, CanCollide = false, Parent = main })
	part({ Name = "HornBrace", Size = Vector3.new(0.5, 8, 0.5), Position = Vector3.new(bx, 10, mainCenter.Z + 22), Color = COL_METAL, Material = Enum.Material.Metal, Parent = main })
end

-- Orange LED grid wall (behind DJ / ceiling)
for r = 0, 3 do
	for c = 0, 7 do
		local bulb = part({
			Name = "OrangeGrid",
			Size = Vector3.new(2.0, 2.0, 0.35),
			Position = Vector3.new(mainCenter.X - 14 + c * 4, 16.8, mainCenter.Z - 8 + r * 4),
			Color = COL_ORANGE,
			Material = Enum.Material.Neon,
			CanCollide = false,
			Parent = main,
		})
		light(bulb, COL_ORANGE, 1.35, 15)
	end
end
-- rear amber wall grid
for r = 0, 4 do
	for c = 0, 8 do
		part({
			Name = "RearGrid",
			Size = Vector3.new(1.6, 1.6, 0.25),
			Position = Vector3.new(mainCenter.X - 14 + c * 3.5, 4 + r * 2.8, mainCenter.Z + 32),
			Color = COL_AMBER,
			Material = Enum.Material.Neon,
			CanCollide = false,
			Parent = main,
		})
	end
end

for _, pos in ipairs({
	Vector3.new(mainCenter.X, 16, mainCenter.Z),
	Vector3.new(mainCenter.X, 14, mainCenter.Z - 16),
	Vector3.new(mainCenter.X, 14, mainCenter.Z + 12),
	Vector3.new(mainCenter.X - 20, 14, mainCenter.Z),
	Vector3.new(mainCenter.X + 20, 14, mainCenter.Z),
}) do
	local mainWash = part({
		Name = "MainWash",
		Size = Vector3.new(1.8, 1.8, 1.8),
		Position = pos,
		Color = COL_RED,
		Material = Enum.Material.Neon,
		CanCollide = false,
		Parent = main,
	})
	light(mainWash, COL_RED, 4, 50)
end
-- Sign toward bathrooms (north-east of main)
local bathDir = part({
	Name = "BathroomsDir",
	Size = Vector3.new(14, 2.8, 0.35),
	Position = Vector3.new(mainCenter.X + 22, 8, mainCenter.Z + 28),
	Color = COL_BLACK,
	Material = Enum.Material.SmoothPlastic,
	CanCollide = false,
	Parent = main,
})
sign(bathDir, "BATHROOMS →", Enum.NormalId.Front, COL_WHITE, COL_BLACK)

for _, xOff in ipairs({ -32, -12, 12, 32 }) do
	part({
		Name = "Pillar",
		Size = Vector3.new(3.5, 18, 3.5),
		Position = Vector3.new(mainCenter.X + xOff, 10, mainCenter.Z - 22),
		Color = COL_CONCRETE,
		Material = Enum.Material.Concrete,
		Parent = main,
	})
end

-- Side wall recessed panels (angular industrial)
for i = 0, 4 do
	part({
		Name = "RecessPanel",
		Size = Vector3.new(0.4, 8, 6),
		Position = Vector3.new(mainCenter.X - 40, 8, mainCenter.Z - 16 + i * 8),
		Color = COL_METAL_DK,
		Material = Enum.Material.Metal,
		Parent = main,
	})
end

----------------------------------------------------------------
-- 8. STUDIO
----------------------------------------------------------------
local studioCenter = Vector3.new(mainCenter.X - 58, 1, mainCenter.Z)
local studio = roomShell({
	Name = "Studio",
	Center = studioCenter,
	Size = Vector3.new(38, 16, 42),
	DoorGaps = { E = 10 },
	FloorColor = COL_SLATE,
	FloorMaterial = Enum.Material.Concrete,
	WallColor = COL_BRICK_DARK,
})
part({ Name = "Booth", Size = Vector3.new(12, 4.5, 7), Position = Vector3.new(studioCenter.X - 8, 3.2, studioCenter.Z + 8), Color = COL_BLACK, Material = Enum.Material.SmoothPlastic, Parent = studio })
part({ Name = "Mixer", Size = Vector3.new(8, 0.4, 3), Position = Vector3.new(studioCenter.X - 8, 5.6, studioCenter.Z + 8), Color = COL_METAL_DK, Material = Enum.Material.Metal, Parent = studio })
part({ Name = "Glass", Size = Vector3.new(0.3, 7, 10), Position = Vector3.new(studioCenter.X - 1.5, 6, studioCenter.Z + 8), Color = Color3.fromRGB(110, 150, 175), Material = Enum.Material.Glass, Transparency = 0.4, Reflectance = 0.25, Parent = studio })
part({ Name = "Couch", Size = Vector3.new(10, 2.5, 4), Position = Vector3.new(studioCenter.X + 8, 2.2, studioCenter.Z - 8), Color = Color3.fromRGB(28, 28, 32), Material = Enum.Material.Fabric, Parent = studio })
part({ Name = "MonitorWall", Size = Vector3.new(6, 4, 0.4), Position = Vector3.new(studioCenter.X + 10, 8, studioCenter.Z + 18), Color = Color3.fromRGB(20, 40, 60), Material = Enum.Material.Neon, CanCollide = false, Parent = studio })
local studioLight = part({ Name = "StudioWash", Size = Vector3.new(1, 1, 1), Position = Vector3.new(studioCenter.X, 13, studioCenter.Z), Color = Color3.fromRGB(170, 195, 255), Material = Enum.Material.Neon, CanCollide = false, Parent = studio })
light(studioLight, Color3.fromRGB(150, 185, 255), 2.4, 30)

----------------------------------------------------------------
-- 9. DARK ROOMS 2×2
----------------------------------------------------------------
local darkOrigin = Vector3.new(mainCenter.X + 58, 1, mainCenter.Z - 10)
local darkFolder = Instance.new("Folder")
darkFolder.Name = "DarkRooms"
darkFolder.Parent = root

for row = 0, 1 do
	for col = 0, 1 do
		local cx = darkOrigin.X + col * 24
		local cz = darkOrigin.Z + row * 24
		local cell = roomShell({
			Name = "Dark" .. row .. col,
			Center = Vector3.new(cx, 1, cz),
			Size = Vector3.new(22, 12, 22),
			DoorGaps = { W = (col == 0) and 7 or 6 },
			FloorColor = COL_BLACK,
			FloorMaterial = Enum.Material.SmoothPlastic,
			WallColor = COL_BLACK,
			WallMaterial = Enum.Material.SmoothPlastic,
			CeilColor = COL_BLACK,
			Pipes = false,
		})
		cell.Parent = darkFolder
		-- recessed angular panels
		for i = 0, 2 do
			part({
				Name = "DarkPanel",
				Size = Vector3.new(0.35, 5, 4),
				Position = Vector3.new(cx + 9, 5, cz - 5 + i * 5),
				Color = Color3.fromRGB(25, 8, 10),
				Material = Enum.Material.Metal,
				Parent = cell,
			})
		end
		local ember = part({
			Name = "Ember",
			Size = Vector3.new(0.5, 0.5, 0.5),
			Position = Vector3.new(cx, 9.5, cz),
			Color = Color3.fromRGB(160, 30, 18),
			Material = Enum.Material.Neon,
			CanCollide = false,
			Parent = cell,
		})
		light(ember, Color3.fromRGB(160, 30, 18), 0.55, 11)
	end
end

----------------------------------------------------------------
-- 10. BATHROOMS (bright multi-stall — open fronts, well lit)
----------------------------------------------------------------
local bathCenter = Vector3.new(mainCenter.X + 22, 1, mainCenter.Z + 52)
local baths = roomShell({
	Name = "Bathrooms",
	Center = bathCenter,
	Size = Vector3.new(48, 14, 32),
	DoorGaps = { S = 12 },
	FloorColor = COL_TILE,
	FloorMaterial = Enum.Material.SmoothPlastic,
	WallColor = COL_TILE,
	WallMaterial = Enum.Material.SmoothPlastic,
	CeilColor = COL_WHITE,
	Pipes = false,
})

local bathSign = part({
	Name = "BathroomsSign",
	Size = Vector3.new(18, 3, 0.4),
	Position = Vector3.new(bathCenter.X, 10, bathCenter.Z - 14),
	Color = COL_BLACK,
	Material = Enum.Material.SmoothPlastic,
	CanCollide = false,
	Parent = baths,
})
sign(bathSign, "BATHROOMS", Enum.NormalId.Front, COL_WHITE, COL_BLACK)

-- 5 open-front stalls (divider walls + back wall — walk into them)
for i = 0, 4 do
	local sx = bathCenter.X - 16 + i * 8
	local sz = bathCenter.Z + 6
	-- back wall
	part({
		Name = "StallBack",
		Size = Vector3.new(7, 8, 0.4),
		Position = Vector3.new(sx, 5, sz + 3),
		Color = COL_WHITE,
		Material = Enum.Material.SmoothPlastic,
		Parent = baths,
	})
	-- side dividers
	part({
		Name = "StallSideL",
		Size = Vector3.new(0.35, 8, 6),
		Position = Vector3.new(sx - 3.5, 5, sz),
		Color = COL_WHITE,
		Material = Enum.Material.SmoothPlastic,
		Parent = baths,
	})
	part({
		Name = "StallSideR",
		Size = Vector3.new(0.35, 8, 6),
		Position = Vector3.new(sx + 3.5, 5, sz),
		Color = COL_WHITE,
		Material = Enum.Material.SmoothPlastic,
		Parent = baths,
	})
	-- ajar door (doesn't seal the stall)
	part({
		Name = "StallDoor",
		Size = Vector3.new(2.4, 7, 0.25),
		Position = Vector3.new(sx - 1.8, 4.5, sz - 3),
		Color = Color3.fromRGB(200, 200, 208),
		Material = Enum.Material.SmoothPlastic,
		Parent = baths,
	})
	-- toilet
	part({
		Name = "Toilet",
		Size = Vector3.new(2, 2.2, 2.5),
		Position = Vector3.new(sx, 2.1, sz + 1.5),
		Color = COL_WHITE,
		Material = Enum.Material.SmoothPlastic,
		Parent = baths,
	})
	local stallLamp = part({
		Name = "StallLamp",
		Size = Vector3.new(1, 0.3, 1),
		Position = Vector3.new(sx, 9.5, sz),
		Color = Color3.fromRGB(255, 250, 230),
		Material = Enum.Material.Neon,
		CanCollide = false,
		Parent = baths,
	})
	light(stallLamp, Color3.fromRGB(255, 250, 230), 2.5, 14)
end
for i = 0, 3 do
	part({
		Name = "Sink",
		Size = Vector3.new(3.2, 2.2, 2.2),
		Position = Vector3.new(bathCenter.X - 12 + i * 8, 3.1, bathCenter.Z - 10),
		Color = COL_WHITE,
		Material = Enum.Material.SmoothPlastic,
		Parent = baths,
	})
	part({
		Name = "Mirror",
		Size = Vector3.new(3, 3.5, 0.15),
		Position = Vector3.new(bathCenter.X - 12 + i * 8, 7, bathCenter.Z - 13),
		Color = Color3.fromRGB(180, 200, 210),
		Material = Enum.Material.Glass,
		Reflectance = 0.6,
		CanCollide = false,
		Parent = baths,
	})
end
part({
	Name = "Graffiti",
	Size = Vector3.new(22, 4, 0.2),
	Position = Vector3.new(bathCenter.X, 9, bathCenter.Z + 14.5),
	Color = COL_RED,
	Material = Enum.Material.SmoothPlastic,
	CanCollide = false,
	Parent = baths,
})
for _, zOff in ipairs({ -8, 0, 8 }) do
	local bathLight = part({
		Name = "BathFluoro",
		Size = Vector3.new(18, 0.4, 1.2),
		Position = Vector3.new(bathCenter.X, 12.5, bathCenter.Z + zOff),
		Color = Color3.fromRGB(255, 252, 235),
		Material = Enum.Material.Neon,
		CanCollide = false,
		Parent = baths,
	})
	light(bathLight, Color3.fromRGB(255, 250, 230), 5, 28)
end

----------------------------------------------------------------
-- 11. BREAK TIME / BACKYARD
----------------------------------------------------------------
local yard2Center = Vector3.new(mainCenter.X - 8, 1, mainCenter.Z + 92)
local breakYard = Instance.new("Folder")
breakYard.Name = "BreakTime"
breakYard.Parent = root

part({ Name = "Gravel", Size = Vector3.new(74, 1, 54), Position = yard2Center, Color = COL_GRAVEL, Material = Enum.Material.Ground, Parent = breakYard })
part({ Name = "BYWallN", Size = Vector3.new(74, 9, 2), Position = Vector3.new(yard2Center.X, 5.5, yard2Center.Z + 27), Color = COL_BRICK, Material = Enum.Material.Brick, Parent = breakYard })
part({ Name = "BYWallW", Size = Vector3.new(2, 9, 54), Position = Vector3.new(yard2Center.X - 37, 5.5, yard2Center.Z), Color = COL_BRICK, Material = Enum.Material.Brick, Parent = breakYard })
part({ Name = "BYWallE", Size = Vector3.new(2, 9, 54), Position = Vector3.new(yard2Center.X + 37, 5.5, yard2Center.Z), Color = COL_BRICK, Material = Enum.Material.Brick, Parent = breakYard })
part({ Name = "BYWallS_L", Size = Vector3.new(28, 9, 2), Position = Vector3.new(yard2Center.X - 20, 5.5, yard2Center.Z - 27), Color = COL_BRICK, Material = Enum.Material.Brick, Parent = breakYard })
part({ Name = "BYWallS_R", Size = Vector3.new(28, 9, 2), Position = Vector3.new(yard2Center.X + 20, 5.5, yard2Center.Z - 27), Color = COL_BRICK, Material = Enum.Material.Brick, Parent = breakYard })

for i = 0, 3 do
	local x = yard2Center.X - 21 + i * 14
	part({ Name = "PicnicTop", Size = Vector3.new(9, 0.5, 4.2), Position = Vector3.new(x, 3.3, yard2Center.Z), Color = Color3.fromRGB(88, 68, 42), Material = Enum.Material.Wood, Parent = breakYard })
	part({ Name = "PicnicBenchA", Size = Vector3.new(9, 0.4, 1.3), Position = Vector3.new(x, 2.2, yard2Center.Z - 3.2), Color = Color3.fromRGB(88, 68, 42), Material = Enum.Material.Wood, Parent = breakYard })
	part({ Name = "PicnicBenchB", Size = Vector3.new(9, 0.4, 1.3), Position = Vector3.new(x, 2.2, yard2Center.Z + 3.2), Color = Color3.fromRGB(88, 68, 42), Material = Enum.Material.Wood, Parent = breakYard })
end
-- barrel ashtrays / crates
for i = 0, 2 do
	part({ Name = "Barrel", Size = Vector3.new(2.5, 3.5, 2.5), Position = Vector3.new(yard2Center.X - 25 + i * 25, 2.5, yard2Center.Z + 14), Color = COL_RUST, Material = Enum.Material.CorrodedMetal, Parent = breakYard })
end

for i = 0, 10 do
	local bulb = part({
		Name = "StringBulb",
		Size = Vector3.new(0.55, 0.55, 0.55),
		Position = Vector3.new(yard2Center.X - 24 + i * 4.8, 9.5, yard2Center.Z - 6 + (i % 2) * 10),
		Color = Color3.fromRGB(255, 220, 140),
		Material = Enum.Material.Neon,
		CanCollide = false,
		Parent = breakYard,
	})
	light(bulb, Color3.fromRGB(255, 210, 130), 1.3, 15)
end
-- wire between bulbs
part({
	Name = "StringWire",
	Size = Vector3.new(52, 0.08, 0.08),
	Position = Vector3.new(yard2Center.X, 9.7, yard2Center.Z),
	Color = COL_BLACK,
	Material = Enum.Material.Metal,
	CanCollide = false,
	Parent = breakYard,
})

local breakSign = part({ Name = "BreakSign", Size = Vector3.new(18, 3.2, 0.4), Position = Vector3.new(yard2Center.X, 11, yard2Center.Z + 25), Color = COL_BLACK, Material = Enum.Material.SmoothPlastic, CanCollide = false, Parent = breakYard })
sign(breakSign, "BREAK TIME", Enum.NormalId.Front, COL_WHITE, COL_BLACK)

----------------------------------------------------------------
-- HALL main → baths (lit, clear 12-stud corridor)
----------------------------------------------------------------
local hall = Instance.new("Folder")
hall.Name = "Halls"
hall.Parent = root
part({
	Name = "HallBathFloor",
	Size = Vector3.new(14, 1, 22),
	Position = Vector3.new(mainCenter.X + 22, 1, mainCenter.Z + 36),
	Color = COL_FLOOR,
	Material = Enum.Material.Brick,
	Parent = hall,
})
part({
	Name = "HallBathCeil",
	Size = Vector3.new(14, 1, 22),
	Position = Vector3.new(mainCenter.X + 22, 14, mainCenter.Z + 36),
	Color = COL_CONCRETE_DARK,
	Material = Enum.Material.Concrete,
	Parent = hall,
})
for _, x in ipairs({ mainCenter.X + 15, mainCenter.X + 29 }) do
	part({
		Name = "HallBathWall",
		Size = Vector3.new(1.5, 12, 22),
		Position = Vector3.new(x, 7.5, mainCenter.Z + 36),
		Color = COL_BRICK_DARK,
		Material = Enum.Material.Brick,
		Parent = hall,
	})
end
for _, zOff in ipairs({ -6, 0, 6 }) do
	local hallRed = part({
		Name = "HallRed",
		Size = Vector3.new(1.2, 1.2, 1.2),
		Position = Vector3.new(mainCenter.X + 22, 11, mainCenter.Z + 36 + zOff),
		Color = COL_RED,
		Material = Enum.Material.Neon,
		CanCollide = false,
		Parent = hall,
	})
	light(hallRed, COL_RED, 3.5, 22)
end
part({
	Name = "HallPathGlow",
	Size = Vector3.new(5, 0.12, 20),
	Position = Vector3.new(mainCenter.X + 22, 1.15, mainCenter.Z + 36),
	Color = COL_AMBER,
	Material = Enum.Material.Neon,
	CanCollide = false,
	Parent = hall,
})

----------------------------------------------------------------
-- SPAWN (lit courtyard pad — facing gate / club)
----------------------------------------------------------------
for _, child in ipairs(Workspace:GetChildren()) do
	if child:IsA("SpawnLocation") then
		child:Destroy()
	end
end
-- Keep a faint ground under spawn so Play never drops into void if something fails
local bp = Workspace:FindFirstChild("Baseplate")
if bp and bp:IsA("BasePart") then
	bp.Color = COL_ASPHALT
	bp.Material = Enum.Material.Asphalt
	bp.Transparency = 0.35
	bp.CanCollide = true
end

local spawn = Instance.new("SpawnLocation")
spawn.Name = "BasementSpawn"
spawn.Size = Vector3.new(10, 1, 10)
spawn.Position = Vector3.new(0, 1.5, -20)
spawn.Anchored = true
spawn.Duration = 0
spawn.Neutral = true
spawn.Color = COL_RED
spawn.Material = Enum.Material.Neon
spawn.Parent = root

-- Flood lights so first frame is never pure black
for _, offset in ipairs({
	Vector3.new(0, 12, -20),
	Vector3.new(-10, 10, -12),
	Vector3.new(10, 10, -12),
	Vector3.new(0, 8, 0),
}) do
	local beacon = part({
		Name = "SpawnBeacon",
		Size = Vector3.new(1.5, 1.5, 1.5),
		Position = offset,
		Color = Color3.fromRGB(255, 200, 140),
		Material = Enum.Material.Neon,
		CanCollide = false,
		Parent = root,
	})
	light(beacon, Color3.fromRGB(255, 210, 160), 5, 55)
end

-- Visible arrow toward gate / club (+Z)
part({
	Name = "SpawnArrow",
	Size = Vector3.new(4, 0.4, 10),
	Position = Vector3.new(0, 1.3, -8),
	Color = COL_RED,
	Material = Enum.Material.Neon,
	CanCollide = false,
	Parent = root,
})

print("[BasementAuto] Realism v2.2 built (avatars skipped). Path lit; tunnel mouth unblocked.")
print("[BasementAuto] Explorer → Workspace → BasementAuto → Lockers / Bathrooms / MainCharlotte …")
print("[BasementAuto] Walk: courtyard → Knockdown mouth → ramp → tunnel → security → LOCKERS → main → hall → BATHROOMS")
print("[BasementAuto] Stop Play, then Publish. Re-paste this script anytime to rebuild.")
