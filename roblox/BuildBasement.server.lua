--[[
  BASEMENT RAVE CREW :: club builder for Roblox Studio
  =====================================================
  PLACEMENT: Explorer > ServerScriptService > + > Script. Delete the default
  line, paste this entire file. LEAVE THE SCRIPT THERE. It rebuilds the club
  every time the game starts (in Studio Play and for friends once published).
  Do not paste it into Workspace or a LocalScript.

  Layout (one level, underground, below a street-level courtyard):
    Courtyard (the line + VIP express) > gate > ramp down > tunnel
    > ID check + dress code > lockers > hub (water, snacks)
    > Basement main floor (Charlotte de Witte, bar, lights, dance)
    > dark rooms (nooks) > Break Time backyard (bar, 2nd bathroom)
    > Studio (2nd DJ, 2nd bar) > The Stalls (toilets, TP, flush, sinks, graffiti)

  Interactions (ProximityPrompts, server-only): show ID → dress-code →
  lockers (bag + coat) → snacks/drinks/water → dance → toilet paper / flush / wash.
  Free audio: Roblox Creator tutorial IDs + built-in engine SFX.
  Avatar: all-black BodyColors + harness on spawn.

  Safe to re-run: it deletes its previous build first.
]]

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local ROOT_NAME = "BasementClub"

local FLOOR = 1 -- club floor height (sits on the baseplate)
local STREET = 17 -- courtyard height (street level, above the club)
local CEIL = 19 -- club ceiling height
local DOOR_TOP = FLOOR + 12 -- doorway height
local WALL_T = 2

local function log(msg)
	print("[Basement] " .. msg)
end

local function section(name, fn)
	local ok, err = pcall(fn)
	if not ok then
		warn("[Basement] " .. name .. " skipped: " .. tostring(err))
	end
end

----------------------------------------------------------------
-- CLEAN UP PREVIOUS BUILDS
----------------------------------------------------------------
for _, oldName in ipairs({ ROOT_NAME, "BasementAuto" }) do
	local old = Workspace:FindFirstChild(oldName)
	if old then
		old:Destroy()
	end
end

local root = Instance.new("Model")
root.Name = ROOT_NAME
root.Parent = Workspace

local function folder(name, parent)
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent or root
	return f
end

----------------------------------------------------------------
-- PALETTE
----------------------------------------------------------------
local C = {
	asphalt = Color3.fromRGB(34, 34, 37),
	brick = Color3.fromRGB(104, 58, 46),
	brickDark = Color3.fromRGB(72, 44, 38),
	concrete = Color3.fromRGB(128, 124, 118),
	concreteDark = Color3.fromRGB(80, 78, 76),
	black = Color3.fromRGB(12, 12, 14),
	nearBlack = Color3.fromRGB(24, 22, 26),
	metal = Color3.fromRGB(52, 52, 56),
	steel = Color3.fromRGB(150, 152, 158),
	rust = Color3.fromRGB(104, 66, 44),
	red = Color3.fromRGB(230, 10, 0),
	magenta = Color3.fromRGB(255, 0, 110),
	violet = Color3.fromRGB(140, 0, 255),
	orange = Color3.fromRGB(255, 120, 40),
	amber = Color3.fromRGB(255, 170, 80),
	blue = Color3.fromRGB(40, 90, 255),
	ice = Color3.fromRGB(160, 205, 255),
	white = Color3.fromRGB(240, 238, 232),
	tile = Color3.fromRGB(214, 212, 204),
	wood = Color3.fromRGB(86, 60, 40),
	gravel = Color3.fromRGB(112, 106, 96),
	green = Color3.fromRGB(40, 255, 110),
	glass = Color3.fromRGB(30, 34, 40),
}

local M = Enum.Material

----------------------------------------------------------------
-- BUILD HELPERS
----------------------------------------------------------------

local function box(name, x0, x1, y0, y1, z0, z1, color, material, opts)
	opts = opts or {}
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Size = Vector3.new(math.abs(x1 - x0), math.abs(y1 - y0), math.abs(z1 - z0))
	p.CFrame = CFrame.new((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2)
	p.Color = color or C.concrete
	p.Material = material or M.Concrete
	p.CanCollide = opts.collide ~= false
	p.CastShadow = opts.shadow ~= false
	if opts.transparency then
		p.Transparency = opts.transparency
	end
	if opts.reflectance then
		p.Reflectance = opts.reflectance
	end
	if opts.shape then
		p.Shape = opts.shape
	end
	p.Parent = opts.parent or root
	return p
end

local function neon(name, x0, x1, y0, y1, z0, z1, color, parent)
	return box(name, x0, x1, y0, y1, z0, z1, color, M.Neon, { collide = false, shadow = false, parent = parent })
end

local function barrier(x0, x1, y0, y1, z0, z1, parent)
	return box("InvisibleBarrier", x0, x1, y0, y1, z0, z1, C.black, M.SmoothPlastic, {
		transparency = 1,
		shadow = false,
		parent = parent,
	})
end

local function addLight(part, className, color, brightness, range, extra)
	local l = Instance.new(className)
	l.Color = color
	l.Brightness = brightness
	l.Range = range
	extra = extra or {}
	if extra.face then
		l.Face = extra.face
	end
	if extra.angle then
		l.Angle = extra.angle
	end
	if extra.shadows ~= nil then
		l.Shadows = extra.shadows
	end
	l.Parent = part
	return l
end

local function lamp(name, x, y, z, color, brightness, range, parent)
	local p = box(name, x - 0.3, x + 0.3, y - 0.3, y + 0.3, z - 0.3, z + 0.3, C.black, M.SmoothPlastic, {
		collide = false,
		shadow = false,
		transparency = 1,
		parent = parent,
	})
	addLight(p, "PointLight", color, brightness, range, { shadows = false })
	return p
end

local function fontNamed(name)
	local ok, f = pcall(function()
		return Enum.Font[name]
	end)
	if ok and f then
		return f
	end
	return Enum.Font.GothamBlack
end

local function sign(part, face, text, textColor, bg, fontName)
	local w, h
	if face == Enum.NormalId.Front or face == Enum.NormalId.Back then
		w, h = part.Size.X, part.Size.Y
	elseif face == Enum.NormalId.Left or face == Enum.NormalId.Right then
		w, h = part.Size.Z, part.Size.Y
	else
		w, h = part.Size.X, part.Size.Z
	end
	local gui = Instance.new("SurfaceGui")
	gui.Name = "Sign"
	gui.Face = face
	gui.LightInfluence = 0
	gui.CanvasSize = Vector2.new(math.floor(w * 50), math.floor(h * 50))
	gui.Parent = part
	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.fromScale(1, 1)
	label.BorderSizePixel = 0
	if bg then
		label.BackgroundColor3 = bg
		label.BackgroundTransparency = 0
	else
		label.BackgroundTransparency = 1
	end
	label.Text = text
	label.TextColor3 = textColor
	label.TextScaled = true
	label.Font = fontNamed(fontName or "GothamBlack")
	label.Parent = gui
	return gui
end

local function panel(name, x0, x1, y0, y1, z0, z1, face, text, textColor, bg, fontName, parent, invisible)
	local p = box(name, x0, x1, y0, y1, z0, z1, bg or C.black, M.SmoothPlastic, {
		collide = false,
		shadow = false,
		transparency = invisible and 1 or nil,
		parent = parent,
	})
	sign(p, face, text, textColor, (not invisible) and bg or nil, fontName)
	return p
end

-- Dense layered graffiti (Mad Max / crew / abstract — no political slogans)
local GRAFFITI_TAGS = {
	"MAD MAX", "RAVE CREW", "4 EVA", "VOID", "BC-88", "BASEMENT",
	"ALL BLACK", "NO PHOTOS", "CHARLOTTE", "KNOCKDOWN", "CREW",
	"XXX", ">>>", "///", "SAM", "MIKE", "MAX", "CHRIS", "LOULOUS",
	"BERG", "PULSE", "WRECK", "NIGHT", "GRID", "HORN", "FOG",
	"WRECKED", "HARD", "PITCH", "KICK", "NO VIP", "EXIT?", "????",
}

local function graffitiOn(part, face, density)
	density = density or 22
	local rng = Random.new((part.Position.X * 17 + part.Position.Z * 31 + density * 7) % 100000)
	for i = 1, density do
		local gui = Instance.new("SurfaceGui")
		gui.Name = "Graffiti" .. i
		gui.Face = face
		gui.LightInfluence = 0.05
		gui.ZOffset = i
		gui.CanvasSize = Vector2.new(768, 768)
		gui.Parent = part
		-- occasional paint block under tag (dense layered look like photo refs)
		if i % 4 == 0 then
			local blot = Instance.new("Frame")
			local bx = 0.08 + rng:NextNumber() * 0.5
			local by = 0.06 + rng:NextNumber() * 0.35
			blot.Size = UDim2.fromScale(bx, by)
			blot.Position = UDim2.fromScale(rng:NextNumber() * (1 - bx), rng:NextNumber() * (1 - by))
			blot.BorderSizePixel = 0
			blot.BackgroundColor3 = (i % 8 == 0) and C.red or Color3.fromRGB(18, 18, 22)
			blot.BackgroundTransparency = 0.35 + rng:NextNumber() * 0.4
			blot.Rotation = rng:NextNumber() * 40 - 20
			blot.Parent = gui
		end
		local label = Instance.new("TextLabel")
		local sx = 0.14 + rng:NextNumber() * 0.55
		local sy = 0.09 + rng:NextNumber() * 0.32
		label.Size = UDim2.fromScale(sx, sy)
		label.Position = UDim2.fromScale(rng:NextNumber() * (1 - sx), rng:NextNumber() * (1 - sy))
		label.BackgroundTransparency = 1
		label.BorderSizePixel = 0
		label.Text = GRAFFITI_TAGS[(rng:NextInteger(1, #GRAFFITI_TAGS))]
		local palette = {
			C.black, C.red, Color3.fromRGB(20, 20, 40), Color3.fromRGB(180, 40, 20),
			Color3.fromRGB(40, 40, 40), Color3.fromRGB(90, 10, 10), Color3.fromRGB(200, 200, 200),
		}
		label.TextColor3 = palette[rng:NextInteger(1, #palette)]
		label.TextTransparency = rng:NextNumber() * 0.28
		label.TextScaled = true
		label.Font = fontNamed((i % 3 == 0) and "PermanentMarker" or "GothamBlack")
		label.Rotation = rng:NextNumber() * 32 - 16
		label.Parent = gui
	end
end

local function makePrompt(parent, actionText, objectText, hold, maxDist)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = actionText
	prompt.ObjectText = objectText or ""
	prompt.HoldDuration = hold or 0
	prompt.MaxActivationDistance = maxDist or 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = parent
	return prompt
end

local function notify(player, text)
	local pg = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 2)
	if not pg then
		return
	end
	local old = pg:FindFirstChild("BasementToast")
	if old then
		old:Destroy()
	end
	local gui = Instance.new("ScreenGui")
	gui.Name = "BasementToast"
	gui.ResetOnSpawn = false
	gui.Parent = pg
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.5, 0, 0, 40)
	label.Position = UDim2.new(0.25, 0, 0.12, 0)
	label.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
	label.BackgroundTransparency = 0.2
	label.BorderSizePixel = 0
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 240, 235)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = gui
	task.delay(2.8, function()
		if gui.Parent then
			gui:Destroy()
		end
	end)
end

-- Free Roblox audio + built-in SFX (no paid assets)
-- DJ: Creator Hub sample "Upbeat Electronica" — free tutorial ID (audible indoors at high volume)
local DJ_MUSIC_ID = "rbxassetid://1837849285"
local PEW_SFX = "rbxasset://sounds/electronicpingshort.wav"
local PEW_CLICK = "rbxasset://sounds/switch.wav"
local DANCE_ANIM_IDS = {
	"rbxassetid://507771019",
	"rbxassetid://507771955",
	"rbxassetid://507776043",
}
-- Free Roblox catalog pants (0 Robux Black Jeans). Shirt = body black (no unreliable free shirt ID).
local FREE_BLACK_PANTS = 382537569

local CREW = {
	{ name = "Sam", accent = Color3.fromRGB(230, 10, 0) },
	{ name = "Mike", accent = Color3.fromRGB(40, 90, 255) },
	{ name = "Max", accent = Color3.fromRGB(255, 120, 40) },
	{ name = "Chris", accent = Color3.fromRGB(40, 255, 110) },
}

local playerCrew = {} -- [userId] = crew name

local function playPew(player)
	local char = player.Character
	local head = char and char:FindFirstChild("Head")
	local parent = head or Workspace
	-- club zap: switch click + double electronic ping
	local click = Instance.new("Sound")
	click.Name = "BasementPewClick"
	click.SoundId = PEW_CLICK
	click.Volume = 0.7
	click.PlaybackSpeed = 1.4
	click.Parent = parent
	click:Play()
	task.delay(1.0, function()
		if click.Parent then
			click:Destroy()
		end
	end)
	for i = 1, 2 do
		local s = Instance.new("Sound")
		s.Name = "BasementPew"
		s.SoundId = PEW_SFX
		s.Volume = 0.85
		s.PlaybackSpeed = (i == 1) and 1.35 or 0.75
		s.RollOffMaxDistance = 55
		s.Parent = parent
		s:Play()
		task.delay(1.4, function()
			if s.Parent then
				s:Destroy()
			end
		end)
		task.wait(0.08)
	end
end

local function flashPassGui(player, crewName)
	local pg = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 2)
	if not pg then
		return
	end
	local old = pg:FindFirstChild("BasementPassFlash")
	if old then
		old:Destroy()
	end
	local gui = Instance.new("ScreenGui")
	gui.Name = "BasementPassFlash"
	gui.ResetOnSpawn = false
	gui.Parent = pg
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0.42, 0, 0, 110)
	frame.Position = UDim2.new(0.29, 0, 0.2, 0)
	frame.BackgroundColor3 = Color3.fromRGB(250, 248, 240)
	frame.BorderSizePixel = 0
	frame.Parent = gui
	local stripe = Instance.new("Frame")
	stripe.Size = UDim2.new(1, 0, 0, 14)
	stripe.BackgroundColor3 = C.red
	stripe.BorderSizePixel = 0
	stripe.Parent = frame
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -16, 0, 36)
	title.Position = UDim2.new(0, 8, 0, 22)
	title.BackgroundTransparency = 1
	title.Text = "BASEMENT GUEST PASS"
	title.TextColor3 = Color3.fromRGB(10, 10, 12)
	title.Font = Enum.Font.GothamBlack
	title.TextScaled = true
	title.Parent = frame
	local who = Instance.new("TextLabel")
	who.Size = UDim2.new(1, -16, 0, 40)
	who.Position = UDim2.new(0, 8, 0, 58)
	who.BackgroundTransparency = 1
	who.Text = tostring(crewName or player.DisplayName or player.Name)
	who.TextColor3 = C.red
	who.Font = Enum.Font.GothamBold
	who.TextScaled = true
	who.Parent = frame
	task.delay(3.2, function()
		if gui.Parent then
			gui:Destroy()
		end
	end)
end

local function setCrewNametag(character, crewName, accent)
	local head = character:FindFirstChild("Head")
	if not head then
		return
	end
	local old = head:FindFirstChild("CrewNametag")
	if old then
		old:Destroy()
	end
	local bb = Instance.new("BillboardGui")
	bb.Name = "CrewNametag"
	bb.Size = UDim2.fromOffset(140, 36)
	bb.StudsOffset = Vector3.new(0, 2.4, 0)
	bb.AlwaysOnTop = true
	bb.MaxDistance = 80
	bb.Parent = head
	local tl = Instance.new("TextLabel")
	tl.Size = UDim2.fromScale(1, 1)
	tl.BackgroundTransparency = 0.35
	tl.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
	tl.BorderSizePixel = 0
	tl.Text = crewName
	tl.TextColor3 = accent or C.white
	tl.Font = Enum.Font.GothamBlack
	tl.TextScaled = true
	tl.Parent = bb
end

local function attachHarness(character, accent)
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if not torso then
		return
	end
	local old = character:FindFirstChild("BasementHarness")
	if old then
		old:Destroy()
	end
	local harness = Instance.new("Model")
	harness.Name = "BasementHarness"
	harness.Parent = character
	-- Readable on black body: dark brown leather + bright steel hardware
	local leather = Color3.fromRGB(78, 52, 36)
	local leatherDark = Color3.fromRGB(48, 32, 22)
	local function strap(name, size, offset, color, material)
		local p = Instance.new("Part")
		p.Name = name
		p.Size = size
		p.Color = color or leather
		p.Material = material or M.Leather
		p.CanCollide = false
		p.Massless = true
		p.CastShadow = true
		p.CFrame = torso.CFrame * offset
		p.Parent = harness
		local w = Instance.new("WeldConstraint")
		w.Part0 = torso
		w.Part1 = p
		w.Parent = p
		return p
	end
	-- X chest (crossing diagonals + horizontal) with depth off the torso
	strap("ChestH", Vector3.new(1.85, 0.22, 0.16), CFrame.new(0, 0.4, -0.62), leather)
	strap("DiagL", Vector3.new(0.2, 1.35, 0.16), CFrame.new(-0.35, 0.05, -0.62) * CFrame.Angles(0, 0, math.rad(28)), leatherDark)
	strap("DiagR", Vector3.new(0.2, 1.35, 0.16), CFrame.new(0.35, 0.05, -0.62) * CFrame.Angles(0, 0, math.rad(-28)), leatherDark)
	strap("Waist", Vector3.new(2.05, 0.28, 0.42), CFrame.new(0, -0.6, -0.05), leather)
	strap("WaistFront", Vector3.new(0.9, 0.22, 0.18), CFrame.new(0, -0.6, -0.58), leatherDark)
	-- shoulder D-rings (metal blocks — read against black body)
	strap("RingL", Vector3.new(0.5, 0.5, 0.14), CFrame.new(-0.85, 0.65, -0.15), C.steel, M.Metal)
	strap("RingLInner", Vector3.new(0.28, 0.28, 0.16), CFrame.new(-0.85, 0.65, -0.15), leatherDark, M.Leather)
	strap("RingR", Vector3.new(0.5, 0.5, 0.14), CFrame.new(0.85, 0.65, -0.15), C.steel, M.Metal)
	strap("RingRInner", Vector3.new(0.28, 0.28, 0.16), CFrame.new(0.85, 0.65, -0.15), leatherDark, M.Leather)
	local buckle = strap("Buckle", Vector3.new(0.42, 0.34, 0.22), CFrame.new(0, -0.58, -0.7), accent or C.steel, M.Metal)
	strap("BucklePin", Vector3.new(0.12, 0.4, 0.12), CFrame.new(0, -0.58, -0.82), C.steel, M.Metal)
	return buckle
end

local function dressAllBlack(character, crewName)
	local hum = character:FindFirstChildOfClass("Humanoid")
	if not hum then
		return
	end
	local accent = C.steel
	for _, c in ipairs(CREW) do
		if c.name == crewName then
			accent = c.accent
			break
		end
	end
	pcall(function()
		local desc = hum:GetAppliedDescription()
		local black = Color3.fromRGB(12, 12, 14)
		desc.HeadColor = black
		desc.TorsoColor = black
		desc.LeftArmColor = black
		desc.RightArmColor = black
		desc.LeftLegColor = black
		desc.RightLegColor = black
		desc.GraphicTShirt = 0
		desc.Shirt = 0
		desc.Pants = FREE_BLACK_PANTS
		-- strip loud layered clothing ids if present
		pcall(function()
			desc.ShirtAccessory = 0
			desc.PantsAccessory = 0
			desc.JacketAccessory = 0
			desc.SweaterAccessory = 0
		end)
		hum:ApplyDescription(desc)
	end)
	task.wait(0.05)
	local bc = character:FindFirstChildOfClass("BodyColors")
	if not bc then
		bc = Instance.new("BodyColors")
		bc.Parent = character
	end
	local black = BrickColor.new("Really black")
	bc.HeadColor = black
	bc.TorsoColor = black
	bc.LeftArmColor = black
	bc.RightArmColor = black
	bc.LeftLegColor = black
	bc.RightLegColor = black
	-- remove bright classic shirt graphics / keep free black pants
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Shirt") or child:IsA("ShirtGraphic") then
			child:Destroy()
		elseif child:IsA("Pants") then
			pcall(function()
				child.PantsTemplate = "rbxassetid://" .. tostring(FREE_BLACK_PANTS)
			end)
		elseif child:IsA("Accessory") then
			local handle = child:FindFirstChild("Handle")
			if handle and handle:IsA("BasePart") then
				local bright = handle.Color.R + handle.Color.G + handle.Color.B
				if bright > 1.6 or handle.Material == M.Neon then
					child:Destroy()
				end
			end
		end
	end
	if not character:FindFirstChildOfClass("Pants") then
		pcall(function()
			local pants = Instance.new("Pants")
			pants.PantsTemplate = "rbxassetid://" .. tostring(FREE_BLACK_PANTS)
			pants.Parent = character
		end)
	end
	-- harness after clothing so ApplyDescription can't wipe welds
	attachHarness(character, accent)
	task.defer(function()
		task.wait(0.2)
		if character.Parent then
			attachHarness(character, accent)
			if crewName then
				setCrewNametag(character, crewName, accent)
			end
		end
	end)
	if crewName then
		setCrewNametag(character, crewName, accent)
	end
end

local function makeBouncer(name, x, z, yawDeg, parent, labelText)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	local y = FLOOR
	local function limb(n, x0, x1, y0, y1, z0, z1, color)
		return box(n, x0, x1, y0, y1, z0, z1, color or C.black, M.SmoothPlastic, {
			collide = false,
			parent = model,
		})
	end
	local torso = limb("Torso", x - 0.75, x + 0.75, y + 3.2, y + 6.4, z - 0.45, z + 0.45)
	limb("Head", x - 0.6, x + 0.6, y + 6.4, y + 7.7, z - 0.5, z + 0.5, Color3.fromRGB(36, 36, 40))
	limb("LArm", x - 1.4, x - 0.75, y + 3.4, y + 6.1, z - 0.35, z + 0.35)
	limb("RArm", x + 0.75, x + 1.4, y + 3.4, y + 6.1, z - 0.35, z + 0.35)
	limb("LLeg", x - 0.7, x - 0.1, y, y + 3.2, z - 0.4, z + 0.4)
	limb("RLeg", x + 0.1, x + 0.7, y, y + 3.2, z - 0.4, z + 0.4)
	-- vest faces approach path (Front = -Z); rotate model by yaw
	local vest = limb("Vest", x - 0.85, x + 0.85, y + 3.5, y + 6.0, z - 0.65, z - 0.4, C.red)
	sign(vest, Enum.NormalId.Front, "SECURITY", C.white, C.red, "GothamBlack")
	local cf = CFrame.new(x, y + 3.85, z) * CFrame.Angles(0, math.rad(yawDeg), 0)
	for _, p in ipairs(model:GetChildren()) do
		if p:IsA("BasePart") then
			local rel = CFrame.new(x, y + 3.85, z):ToObjectSpace(p.CFrame)
			p.CFrame = cf * rel
		end
	end
	local tag = Instance.new("BillboardGui")
	tag.Name = "BouncerTag"
	tag.Size = UDim2.fromOffset(180, 40)
	tag.StudsOffset = Vector3.new(0, 4.6, 0)
	tag.AlwaysOnTop = true
	tag.MaxDistance = 70
	tag.Parent = torso
	local tl = Instance.new("TextLabel")
	tl.Size = UDim2.fromScale(1, 1)
	tl.BackgroundTransparency = 0.2
	tl.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
	tl.BorderSizePixel = 0
	tl.Text = labelText or "BOUNCER"
	tl.TextColor3 = C.red
	tl.Font = Enum.Font.GothamBlack
	tl.TextScaled = true
	tl.Parent = tag
	return model
end

local function makeIdCardProp(name, x0, x1, y0, y1, z0, z1, parent, face)
	local card = box(name, x0, x1, y0, y1, z0, z1, C.white, M.SmoothPlastic, {
		collide = false,
		parent = parent,
	})
	sign(card, face or Enum.NormalId.Front, "BASEMENT\nGUEST ID", C.black, C.white, "GothamBlack")
	box(name .. "Stripe", x0, x1, y0, y0 + (y1 - y0) * 0.22, z0 - 0.02, z1 + 0.02, C.red, M.Neon, {
		collide = false,
		parent = parent,
	})
	return card
end

local function showPlayerIdCard(player)
	local char = player.Character
	if not char then
		return
	end
	local hand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm") or char:FindFirstChild("Head")
	if not hand then
		return
	end
	local old = char:FindFirstChild("HeldGuestID")
	if old then
		old:Destroy()
	end
	local crewName = playerCrew[player.UserId] or player.DisplayName or player.Name
	local card = Instance.new("Part")
	card.Name = "HeldGuestID"
	card.Size = Vector3.new(0.12, 1.5, 2.3)
	card.Color = Color3.fromRGB(250, 248, 240)
	card.Material = M.SmoothPlastic
	card.CanCollide = false
	card.Massless = true
	card.CFrame = hand.CFrame * CFrame.new(0, -0.15, -0.85)
	card.Parent = char
	local w = Instance.new("WeldConstraint")
	w.Part0 = hand
	w.Part1 = card
	w.Parent = card
	sign(card, Enum.NormalId.Front, "BASEMENT GUEST\n" .. tostring(crewName), C.black, Color3.fromRGB(250, 248, 240), "GothamBlack")
	sign(card, Enum.NormalId.Back, "ID OK", C.white, C.red, "GothamBlack")
	flashPassGui(player, crewName)
	task.delay(10, function()
		if card.Parent then
			card:Destroy()
		end
	end)
end

local function playDance(player)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then
		return
	end
	local animator = hum:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = hum
	end
	local id = DANCE_ANIM_IDS[math.random(1, #DANCE_ANIM_IDS)]
	pcall(function()
		local anim = Instance.new("Animation")
		anim.AnimationId = id
		local track = animator:LoadAnimation(anim)
		track.Priority = Enum.AnimationPriority.Action
		track.Looped = true
		track:Play()
		task.delay(12, function()
			if track.IsPlaying then
				track:Stop(0.4)
			end
		end)
	end)
end

local function setupDjMusic(parentPart, dancePart)
	local sound = Instance.new("Sound")
	sound.Name = "DJMusic"
	sound.SoundId = DJ_MUSIC_ID
	sound.Looped = true
	sound.Volume = 0.95
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.RollOffMinDistance = 18
	sound.RollOffMaxDistance = 140
	sound.Playing = true
	sound.Parent = parentPart
	if dancePart then
		local floor = Instance.new("Sound")
		floor.Name = "DancefloorMusic"
		floor.SoundId = DJ_MUSIC_ID
		floor.Looped = true
		floor.Volume = 1.0
		floor.RollOffMode = Enum.RollOffMode.InverseTapered
		floor.RollOffMinDistance = 22
		floor.RollOffMaxDistance = 70
		floor.Playing = true
		floor.Parent = dancePart
	end
	local bed = SoundService:FindFirstChild("BasementMusicBed")
	if bed then
		bed:Destroy()
	end
	bed = Instance.new("Sound")
	bed.Name = "BasementMusicBed"
	bed.SoundId = DJ_MUSIC_ID
	bed.Looped = true
	bed.Volume = 0.28
	bed.Playing = true
	bed.Parent = SoundService
	-- ensure play after replicate
	task.defer(function()
		sound.Looped = true
		sound:Play()
		if bed then
			bed.Looped = true
			bed:Play()
		end
	end)
	return sound
end

local function setupAvatars()
	local function onCharacter(player, character)
		task.defer(function()
			task.wait(0.4)
			if not character.Parent then
				return
			end
			local crew = playerCrew[player.UserId]
			dressAllBlack(character, crew)
			notify(player, "Dancefloor: neon pad → press E")
		end)
	end
	local function onPlayer(player)
		player.CharacterAdded:Connect(function(character)
			onCharacter(player, character)
		end)
		if player.Character then
			onCharacter(player, player.Character)
		end
	end
	Players.PlayerAdded:Connect(onPlayer)
	for _, p in ipairs(Players:GetPlayers()) do
		onPlayer(p)
	end
end

local function wallX(name, z, x0, x1, gaps, opts)
	opts = opts or {}
	local y0, y1 = opts.y0 or 0, opts.y1 or CEIL + 1
	local t = opts.thick or WALL_T
	local doorTop = opts.doorTop or DOOR_TOP
	local zA, zB = z - t / 2, z + t / 2
	local list = {}
	for _, g in ipairs(gaps or {}) do
		table.insert(list, g)
	end
	table.sort(list, function(a, b)
		return a[1] < b[1]
	end)
	local cursor = x0
	for _, g in ipairs(list) do
		if g[1] > cursor then
			box(name, cursor, g[1], y0, y1, zA, zB, opts.color, opts.material, { parent = opts.parent })
		end
		if not opts.open and y1 > doorTop then
			box(name .. "Lintel", g[1], g[2], doorTop, y1, zA, zB, opts.color, opts.material, { parent = opts.parent })
		end
		cursor = g[2]
	end
	if x1 > cursor then
		box(name, cursor, x1, y0, y1, zA, zB, opts.color, opts.material, { parent = opts.parent })
	end
end

local function wallZ(name, x, z0, z1, gaps, opts)
	opts = opts or {}
	local y0, y1 = opts.y0 or 0, opts.y1 or CEIL + 1
	local t = opts.thick or WALL_T
	local doorTop = opts.doorTop or DOOR_TOP
	local xA, xB = x - t / 2, x + t / 2
	local list = {}
	for _, g in ipairs(gaps or {}) do
		table.insert(list, g)
	end
	table.sort(list, function(a, b)
		return a[1] < b[1]
	end)
	local cursor = z0
	for _, g in ipairs(list) do
		if g[1] > cursor then
			box(name, xA, xB, y0, y1, cursor, g[1], opts.color, opts.material, { parent = opts.parent })
		end
		if not opts.open and y1 > doorTop then
			box(name .. "Lintel", xA, xB, doorTop, y1, g[1], g[2], opts.color, opts.material, { parent = opts.parent })
		end
		cursor = g[2]
	end
	if z1 > cursor then
		box(name, xA, xB, y0, y1, cursor, z1, opts.color, opts.material, { parent = opts.parent })
	end
end

local function slope(name, x0, x1, zA, yA, zB, yB, thick, color, material, parent)
	local xc = (x0 + x1) / 2
	local a = Vector3.new(xc, yA, zA)
	local b = Vector3.new(xc, yB, zB)
	local mid = (a + b) / 2
	local len = (b - a).Magnitude
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Size = Vector3.new(x1 - x0, thick, len + 0.6)
	p.CFrame = CFrame.lookAt(mid, b) * CFrame.new(0, -thick / 2, 0)
	p.Color = color
	p.Material = material
	p.Parent = parent or root
	return p
end

local function seamsAlongX(x0, x1, step, y0, y1, zFace, color, parent)
	local x = x0 + step
	while x < x1 - 0.1 do
		box("Seam", x - 0.06, x + 0.06, y0, y1, zFace - 0.05, zFace + 0.05, color, M.Metal, {
			collide = false,
			shadow = false,
			parent = parent,
		})
		x = x + step
	end
end

local function seamsAlongZ(z0, z1, step, y0, y1, xFace, color, parent)
	local z = z0 + step
	while z < z1 - 0.1 do
		box("Seam", xFace - 0.05, xFace + 0.05, y0, y1, z - 0.06, z + 0.06, color, M.Metal, {
			collide = false,
			shadow = false,
			parent = parent,
		})
		z = z + step
	end
end

local FX = {
	mainSpots = {},
	studioSpots = {},
	strobes = {},
	lasers = {},
	embers = {},
}

----------------------------------------------------------------
-- 0. WORLD: baseplate, spawn cleanup, night lighting
----------------------------------------------------------------
section("World", function()
	for _, child in ipairs(Workspace:GetChildren()) do
		if child:IsA("SpawnLocation") then
			child:Destroy()
		end
	end
	local bp = Workspace:FindFirstChild("Baseplate")
	if bp and bp:IsA("BasePart") then
		bp.Color = C.asphalt
		bp.Material = M.Asphalt
		for _, d in ipairs(bp:GetChildren()) do
			if d:IsA("Texture") or d:IsA("Decal") then
				d:Destroy()
			end
		end
	end

	for _, child in ipairs(Lighting:GetChildren()) do
		if child:IsA("Atmosphere") or child:IsA("PostEffect") then
			child:Destroy()
		end
	end
	-- Keep readable indoors: light fog, low haze (prior black-screen lessons)
	Lighting.ClockTime = 0
	Lighting.Brightness = 2.2
	Lighting.Ambient = Color3.fromRGB(55, 48, 62)
	Lighting.OutdoorAmbient = Color3.fromRGB(70, 62, 80)
	Lighting.EnvironmentDiffuseScale = 0.55
	Lighting.EnvironmentSpecularScale = 0.5
	Lighting.FogColor = Color3.fromRGB(28, 22, 34)
	Lighting.FogStart = 120
	Lighting.FogEnd = 420
	Lighting.GlobalShadows = true

	local atmo = Instance.new("Atmosphere")
	atmo.Density = 0.12
	atmo.Offset = 0.05
	atmo.Color = Color3.fromRGB(80, 60, 90)
	atmo.Decay = Color3.fromRGB(30, 20, 34)
	atmo.Glare = 0.05
	atmo.Haze = 0.35
	atmo.Parent = Lighting

	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = "BasementGrade"
	cc.TintColor = Color3.fromRGB(255, 240, 238)
	cc.Contrast = 0.08
	cc.Saturation = 0.05
	cc.Brightness = 0.05
	cc.Parent = Lighting

	local bloom = Instance.new("BloomEffect")
	bloom.Name = "BasementBloom"
	bloom.Intensity = 0.45
	bloom.Size = 22
	bloom.Threshold = 1.1
	bloom.Parent = Lighting
end)

----------------------------------------------------------------
-- 1. COURTYARD
----------------------------------------------------------------
section("Courtyard", function()
	local f = folder("1 Courtyard")
	box("StreetGround", -95, 5, 0, STREET, -110, -50, C.asphalt, M.Asphalt, { parent = f })

	local wallTop = STREET + 14
	box("YardWallS", -97, 7, STREET, wallTop, -112, -110, C.brick, M.Brick, { parent = f })
	box("YardWallW", -97, -95, STREET, wallTop, -112, -48, C.brick, M.Brick, { parent = f })
	box("YardWallE", 5, 7, STREET, wallTop, -112, -48, C.brick, M.Brick, { parent = f })
	local facadeTop = STREET + 28
	box("Facade", -97, -53, STREET, facadeTop, -51, -49, C.brickDark, M.Brick, { parent = f })
	box("Facade", -39, 7, STREET, facadeTop, -51, -49, C.brickDark, M.Brick, { parent = f })
	box("FacadeBridge", -53, -39, STREET + 15, STREET + 19, -51, -49, C.concreteDark, M.Concrete, { parent = f })
	box("BridgeRail", -53, -39, STREET + 19, STREET + 20.2, -50.2, -49.8, C.metal, M.Metal, { parent = f })
	local lit = 0
	for _, x in ipairs({ -90, -82, -74, -66, -30, -22, -14, -6 }) do
		for _, y in ipairs({ STREET + 16, STREET + 23 }) do
			lit = lit + 1
			if lit % 3 == 0 then
				neon("WindowLit", x - 2, x + 2, y - 2.5, y + 2.5, -51.3, -51.1, C.amber, f)
			else
				box("Window", x - 2, x + 2, y - 2.5, y + 2.5, -51.3, -51.1, C.glass, M.Glass, {
					collide = false,
					reflectance = 0.3,
					parent = f,
				})
			end
		end
	end

	box("GatePostL", -55, -53, STREET, STREET + 12, -51.2, -48.8, C.metal, M.Metal, { parent = f })
	box("GatePostR", -39, -37, STREET, STREET + 12, -51.2, -48.8, C.metal, M.Metal, { parent = f })
	box("GateBeam", -55, -37, STREET + 10, STREET + 12, -51.2, -48.8, C.metal, M.Metal, { parent = f })
	panel("BasementSign", -51, -41, STREET + 6.6, STREET + 9.8, -51.6, -51.3, Enum.NormalId.Front, "BASEMENT", C.red, C.black, "GothamBlack", f)
	lamp("SignGlow", -46, STREET + 8, -53, C.red, 1.2, 14, f)
	box("GateLeafL", -62, -55, STREET, STREET + 9, -51.8, -51.4, C.steel, M.DiamondPlate, { transparency = 0.35, parent = f })
	box("GateLeafR", -37, -30, STREET, STREET + 9, -51.8, -51.4, C.steel, M.DiamondPlate, { transparency = 0.35, parent = f })

	local function stanchionLane(x0, x1, zFrom, zTo, ropeColor, laneName)
		local z = zFrom
		local prevZ = nil
		while z <= zTo do
			for _, x in ipairs({ x0, x1 }) do
				box(laneName .. "Post", x - 0.25, x + 0.25, STREET, STREET + 3.2, z - 0.25, z + 0.25, C.black, M.Metal, { parent = f })
				box(laneName .. "Cap", x - 0.4, x + 0.4, STREET + 3.2, STREET + 3.45, z - 0.4, z + 0.4, C.steel, M.Metal, { parent = f })
				if prevZ then
					box(laneName .. "Rope", x - 0.08, x + 0.08, STREET + 2.7, STREET + 2.86, prevZ, z, ropeColor, M.Fabric, {
						collide = false,
						shadow = false,
						parent = f,
					})
				end
			end
			prevZ = z
			z = z + 6
		end
	end
	stanchionLane(-66, -58, -106, -58, C.nearBlack, "Line")
	stanchionLane(-34, -28, -106, -58, C.red, "VIP")
	box("VIPCarpet", -33.6, -28.4, STREET, STREET + 0.08, -106, -51, C.red, M.Fabric, { parent = f })

	for _, lane in ipairs({ { -66, -58, "THE LINE", C.white }, { -34, -28, "VIP EXPRESS", C.red } }) do
		local x0, x1 = lane[1], lane[2]
		box("SignPost", x0 - 0.7, x0 - 0.3, STREET, STREET + 9, -57.4, -57, C.black, M.Metal, { parent = f })
		box("SignPost", x1 + 0.3, x1 + 0.7, STREET, STREET + 9, -57.4, -57, C.black, M.Metal, { parent = f })
		panel("LaneSign", x0 - 0.3, x1 + 0.3, STREET + 6.5, STREET + 8.8, -57.7, -57.4, Enum.NormalId.Front, lane[3], lane[4], C.black, "GothamBlack", f)
	end
	box("DressCodePost", -70.3, -69.7, STREET, STREET + 6, -80.3, -79.7, C.black, M.Metal, { parent = f })
	panel("DressCodeSign", -71.8, -68.2, STREET + 4, STREET + 7.5, -80.6, -80.3, Enum.NormalId.Front, "DRESS CODE: ALL BLACK", C.white, C.black, "GothamBold", f)
	box("NoPhotosPost", -37.2, -36.8, STREET, STREET + 6, -62.2, -61.8, C.black, M.Metal, { parent = f })
	panel("NoPhotos", -36.8, -36.5, STREET + 3, STREET + 6, -64, -60, Enum.NormalId.Right, "NO PHOTOS", C.white, C.red, "GothamBlack", f)

	for _, pos in ipairs({ { -86, -78 }, { -12, -78 }, { -48, -102 } }) do
		local x, z = pos[1], pos[2]
		box("LampPole", x - 0.3, x + 0.3, STREET, STREET + 14, z - 0.3, z + 0.3, C.metal, M.Metal, { parent = f })
		local head = neon("LampHead", x - 0.9, x + 0.9, STREET + 13.4, STREET + 14.2, z - 0.9, z + 0.9, C.amber, f)
		addLight(head, "PointLight", C.amber, 2.2, 48, { shadows = true })
	end

	box("Dumpster", -92, -84, STREET, STREET + 5, -108, -103, C.metal, M.CorrodedMetal, { parent = f })
	box("DumpsterLid", -92.2, -83.8, STREET + 5, STREET + 5.3, -108.2, -102.8, C.nearBlack, M.Rubber, { parent = f })
	box("Pallets", 0, 4, STREET, STREET + 2.4, -108, -104, C.wood, M.WoodPlanks, { parent = f })
	box("Barrier", -20, -12, STREET, STREET + 1.2, -66, -65, C.steel, M.DiamondPlate, { parent = f })

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "BasementSpawn"
	spawn.Anchored = true
	spawn.Size = Vector3.new(6, 0.2, 6)
	local sp = Vector3.new(-62, STREET + 0.1, -102)
	spawn.CFrame = CFrame.lookAt(sp, sp + Vector3.new(0, 0, 1))
	spawn.Color = C.nearBlack
	spawn.Material = M.Concrete
	spawn.Duration = 0
	spawn.Neutral = true
	spawn.Parent = f

	-- Crew picker (Sam / Mike / Max / Chris) — still all black + harness; nametag + buckle accent only
	panel("CrewPickSign", -74, -66, STREET + 4.5, STREET + 6.5, -98.2, -97.9, Enum.NormalId.Front, "PICK CREW", C.white, C.black, "GothamBlack", f)
	for i, crew in ipairs(CREW) do
		local x0 = -74 + (i - 1) * 3.2
		local pad = box("CrewPad_" .. crew.name, x0, x0 + 2.6, STREET, STREET + 0.15, -100.5, -98.5, crew.accent, M.Neon, {
			parent = f,
		})
		pad:SetAttribute("Interact", "PickCrew")
		pad:SetAttribute("CrewName", crew.name)
		makePrompt(pad, "Play as " .. crew.name, "All black + harness", 0.4, 12)
		panel("CrewName_" .. crew.name, x0, x0 + 2.6, STREET + 2.2, STREET + 3.4, -98.35, -98.15, Enum.NormalId.Front, crew.name, crew.accent, C.black, "GothamBlack", f)
	end

	barrier(-97, 7, wallTop, wallTop + 30, -112, -110, f)
	barrier(-97, -95, wallTop, wallTop + 30, -112, -48, f)
	barrier(5, 7, wallTop, wallTop + 30, -112, -48, f)
end)

----------------------------------------------------------------
-- 2. RAMP DOWN + TUNNEL
----------------------------------------------------------------
section("Ramp and tunnel", function()
	local f = folder("2 Ramp and Tunnel")
	slope("Ramp", -53, -39, -50, STREET, -14, FLOOR, 2, C.concreteDark, M.Concrete, f)
	box("RetainingWallL", -55, -53, 0, STREET + 1, -50, 0, C.concrete, M.Concrete, { parent = f })
	box("RetainingWallR", -39, -37, 0, STREET + 1, -50, 0, C.concrete, M.Concrete, { parent = f })
	barrier(-55, -53, STREET + 1, STREET + 30, -50, 0, f)
	barrier(-39, -37, STREET + 1, STREET + 30, -50, 0, f)
	slope("HandrailL", -52.9, -52.6, -50, STREET + 3, -14, FLOOR + 3, 0.3, C.steel, M.Metal, f).CanCollide = false
	slope("HandrailR", -39.4, -39.1, -50, STREET + 3, -14, FLOOR + 3, 0.3, C.steel, M.Metal, f).CanCollide = false
	box("GrimeL", -53.05, -52.95, 0, 4, -50, 0, C.nearBlack, M.Concrete, { collide = false, parent = f })
	box("GrimeR", -39.05, -38.95, 0, 4, -50, 0, C.nearBlack, M.Concrete, { collide = false, parent = f })

	box("TunnelFloor", -53, -39, 0, FLOOR, -14, 0, C.concreteDark, M.Concrete, { parent = f })
	box("TunnelRoof", -55, -37, FLOOR + 12, FLOOR + 13.5, -14, 0, C.concreteDark, M.Concrete, { parent = f })
	for i = 0, 3 do
		local z = -12.5 + i * 3.6
		box("ArchRib", -53, -39, FLOOR + 11.2, FLOOR + 12, z - 0.3, z + 0.3, C.metal, M.Metal, { parent = f })
		local red = neon("TunnelRed", -46.8, -45.2, FLOOR + 10.8, FLOOR + 11.2, z - 0.8, z + 0.8, C.red, f)
		addLight(red, "PointLight", C.red, 2.6, 18, { shadows = true })
	end
	panel("TunnelNoPhotos", -52.95, -52.7, FLOOR + 5, FLOOR + 7, -10, -5, Enum.NormalId.Right, "NO PHOTOS ON THE DANCEFLOOR", C.white, C.nearBlack, "GothamBold", f)
end)

----------------------------------------------------------------
-- 3. THE BUILDING SHELL
----------------------------------------------------------------
section("Building shell", function()
	local f = folder("3 Shell")
	box("ClubSlab", -60, 90, 0, FLOOR - 0.1, 0, 100, C.concreteDark, M.Concrete, { parent = f })
	box("FloorEntry", -60, -30, 0.4, FLOOR, 0, 45, C.concrete, M.Concrete, { parent = f })
	box("FloorHub", -30, 15, 0.4, FLOOR, 0, 45, C.concreteDark, M.Concrete, { parent = f })
	box("FloorStudio", 15, 60, 0.4, FLOOR, 0, 45, Color3.fromRGB(58, 56, 56), M.Concrete, { parent = f })
	box("FloorStalls", 60, 90, 0.4, FLOOR, 0, 45, C.tile, M.SmoothPlastic, { parent = f })
	box("FloorMain", -60, 0, 0.4, FLOOR, 45, 100, Color3.fromRGB(70, 40, 34), M.Brick, { parent = f })
	box("FloorDark", 0, 35, 0.4, FLOOR, 45, 100, C.black, M.Slate, { parent = f })
	box("FloorYard", 35, 90, 0.4, FLOOR, 45, 100, C.gravel, M.Pebble, { parent = f })

	wallX("OuterS", 0, -61, -30, { { -53, -39 } }, { color = C.concrete, material = M.Concrete, parent = f })
	wallX("OuterS", 0, -30, 15, {}, { color = C.brickDark, material = M.Brick, parent = f })
	wallX("OuterS", 0, 15, 91, {}, { color = C.concrete, material = M.Concrete, parent = f })
	wallX("OuterN", 100, -61, 91, {}, { color = C.brickDark, material = M.Brick, parent = f })
	wallZ("OuterW", -60, 0, 100, {}, { color = C.brickDark, material = M.Brick, parent = f })
	wallZ("OuterE", 90, 0, 100, {}, { color = C.brick, material = M.Brick, parent = f })

	wallX("Divider", 45, -60, 90, { { -24, -12 }, { 4, 12 }, { 40, 50 } }, { color = C.brickDark, material = M.Brick, parent = f })
	wallZ("EntryHubWall", -30, 0, 45, { { 26, 38 } }, { color = C.concrete, material = M.Concrete, parent = f })
	wallZ("HubStudioWall", 15, 0, 45, { { 14, 26 } }, { color = C.brickDark, material = M.Brick, parent = f })
	wallZ("StudioStallsWall", 60, 0, 45, { { 4, 14 } }, { color = C.concrete, material = M.Concrete, parent = f })
	wallZ("MainDarkWall", 0, 45, 100, { { 62, 74 } }, { color = C.brickDark, material = M.Brick, parent = f })
	wallZ("DarkYardWall", 35, 45, 100, { { 76, 86 } }, { color = C.brick, material = M.Brick, parent = f })

	local function ceiling(name, x0, x1, z0, z1, y)
		box(name, x0, x1, y, y + 1, z0, z1, C.concreteDark, M.Concrete, { parent = f })
	end
	ceiling("CeilEntry", -60, -30, 0, 45, CEIL)
	ceiling("CeilHub", -30, 15, 0, 45, CEIL)
	ceiling("CeilStudio", 15, 60, 0, 45, CEIL)
	ceiling("CeilStalls", 60, 90, 0, 45, CEIL)
	ceiling("CeilMain", -60, 0, 45, 100, CEIL)
	ceiling("CeilDark", 0, 35, 45, 100, DOOR_TOP)

	for _, z in ipairs({ 8, 22, 36 }) do
		box("Pipe", -59, 59, CEIL - 1.6, CEIL - 0.8, z - 0.4, z + 0.4, C.rust, M.CorrodedMetal, {
			shape = Enum.PartType.Cylinder,
			collide = false,
			parent = f,
		})
	end
	for _, z in ipairs({ 58, 72, 86 }) do
		box("Pipe", -59, -1, CEIL - 1.6, CEIL - 0.8, z - 0.4, z + 0.4, C.rust, M.CorrodedMetal, {
			shape = Enum.PartType.Cylinder,
			collide = false,
			parent = f,
		})
	end
	for _, x in ipairs({ -45, -15, 30, 50 }) do
		box("IBeam", x - 0.5, x + 0.5, CEIL - 1.2, CEIL, 1, 44, C.metal, M.Metal, { collide = false, parent = f })
	end
	for _, x in ipairs({ -45, -30, -15 }) do
		box("IBeam", x - 0.5, x + 0.5, CEIL - 1.2, CEIL, 46, 99, C.metal, M.Metal, { collide = false, parent = f })
	end

	panel("Exit", -20, -16, DOOR_TOP + 0.5, DOOR_TOP + 2, 46.05, 46.3, Enum.NormalId.Back, "EXIT", C.green, C.black, "GothamBlack", f)
	panel("Exit", -31.3, -31.05, DOOR_TOP + 0.5, DOOR_TOP + 2, 30, 34, Enum.NormalId.Left, "EXIT", C.green, C.black, "GothamBlack", f)
end)

----------------------------------------------------------------
-- 4. ENTRY: ID check, dress code, lockers
----------------------------------------------------------------
section("Entry", function()
	local f = folder("4 Entry Security Lockers")
	local deskID = box("DeskID", -59, -50, FLOOR, FLOOR + 3.6, 10, 13, C.metal, M.DiamondPlate, { parent = f })
	local deskDress = box("DeskDress", -42, -31, FLOOR, FLOOR + 3.6, 10, 13, C.metal, M.DiamondPlate, { parent = f })
	box("DeskTopID", -59.2, -49.8, FLOOR + 3.6, FLOOR + 3.9, 9.8, 13.2, C.nearBlack, M.Rubber, { parent = f })
	box("DeskTopDress", -42.2, -30.9, FLOOR + 3.6, FLOOR + 3.9, 9.8, 13.2, C.nearBlack, M.Rubber, { parent = f })
	neon("ScannerScreen", -55, -53.5, FLOOR + 3.9, FLOOR + 4.9, 11.5, 11.7, C.green, f)
	panel("IDCheckSign", -58, -51, FLOOR + 8, FLOOR + 10.5, 11.3, 11.6, Enum.NormalId.Front, "ID CHECK", C.white, C.black, "GothamBlack", f)
	panel("DressCodeSign", -41, -32, FLOOR + 8, FLOOR + 10.5, 11.3, 11.6, Enum.NormalId.Front, "DRESS CODE CHECK", C.red, C.black, "GothamBlack", f)
	box("ScannerPostL", -50, -49, FLOOR, FLOOR + 8.5, 16, 17, C.steel, M.Metal, { parent = f })
	box("ScannerPostR", -43, -42, FLOOR, FLOOR + 8.5, 16, 17, C.steel, M.Metal, { parent = f })
	box("ScannerTop", -50, -42, FLOOR + 8.5, FLOOR + 9.3, 16, 17, C.steel, M.Metal, { parent = f })
	neon("ScannerStrip", -49, -43, FLOOR + 8.2, FLOOR + 8.5, 16.3, 16.7, C.red, f)
	for _, z in ipairs({ 3, 6, 9 }) do
		for _, x in ipairs({ -50, -42 }) do
			box("Post", x - 0.25, x + 0.25, FLOOR, FLOOR + 3.2, z - 0.25, z + 0.25, C.black, M.Metal, { parent = f })
		end
	end
	box("RopeL", -50.08, -49.92, FLOOR + 2.7, FLOOR + 2.86, 3, 9, C.red, M.Fabric, { collide = false, parent = f })
	box("RopeR", -42.08, -41.92, FLOOR + 2.7, FLOOR + 2.86, 3, 9, C.red, M.Fabric, { collide = false, parent = f })
	lamp("EntryRed", -46, CEIL - 2, 8, C.red, 2.4, 34, f)
	local fluoro = neon("DeskFluoro", -58, -32, CEIL - 0.6, CEIL - 0.3, 11, 11.6, C.white, f)
	addLight(fluoro, "SurfaceLight", C.white, 1.4, 16, { face = Enum.NormalId.Bottom, angle = 90 })

	-- Gate until ID + dress-code cleared (per-player CanCollide handled in Interactions)
	local gate = barrier(-50, -42, FLOOR, FLOOR + 9, 16.2, 16.9, f)
	gate.Name = "SecurityGate"
	gate:SetAttribute("InteractGate", true)

	local idPad = box("IDPad", -55.5, -53.5, FLOOR + 3.9, FLOOR + 4.2, 12.4, 13.1, C.green, M.Neon, { collide = false, parent = f })
	idPad:SetAttribute("Interact", "ShowID")
	makePrompt(idPad, "Show ID", "Hold up your guest pass", 0.6, 10)

	local dressPad = box("DressPad", -38, -35, FLOOR + 3.9, FLOOR + 4.2, 12.4, 13.1, C.red, M.Neon, { collide = false, parent = f })
	dressPad:SetAttribute("Interact", "DressCode")
	makePrompt(dressPad, "Dress-code check", "All black + harness", 0.8, 10)

	deskID:SetAttribute("Interact", "ShowID")
	deskDress:SetAttribute("Interact", "DressCode")

	-- Visible guest ID cards on desks + bouncers facing the approach path
	makeIdCardProp("DeskGuestID", -54.4, -51.8, FLOOR + 3.95, FLOOR + 4.12, 10.0, 11.6, f, Enum.NormalId.Top)
	makeIdCardProp("SampleID", -57.2, -55.0, FLOOR + 4.0, FLOOR + 5.4, 12.35, 12.55, f, Enum.NormalId.Front)
	makeIdCardProp("DressSampleID", -40.5, -38.3, FLOOR + 4.0, FLOOR + 5.4, 12.35, 12.55, f, Enum.NormalId.Front)
	-- Behind desks, facing -Z (toward queue / tunnel approach)
	makeBouncer("BouncerID", -54.5, 13.8, 0, f, "BOUNCER · ID")
	makeBouncer("BouncerDress", -36.5, 13.8, 0, f, "BOUNCER · DRESS")

	box("LockersWest", -59, -57, FLOOR, FLOOR + 8.5, 21, 44, C.metal, M.Metal, { parent = f })
	seamsAlongZ(21, 44, 1.5, FLOOR + 0.3, FLOOR + 8.2, -56.95, C.nearBlack, f)
	box("LockersNorth", -56, -33, FLOOR, FLOOR + 8.5, 42, 44, C.metal, M.Metal, { parent = f })
	seamsAlongX(-56, -33, 1.5, FLOOR + 0.3, FLOOR + 8.2, 41.95, C.nearBlack, f)
	box("LockerShelf", -56, -33, FLOOR + 4.2, FLOOR + 4.35, 41.9, 42.05, C.nearBlack, M.Metal, { collide = false, parent = f })
	panel("LockersSign", -50, -39, FLOOR + 10, FLOOR + 12.2, 43.6, 43.9, Enum.NormalId.Front, "LOCKERS — BAGS & COATS", C.white, C.black, "GothamBlack", f)
	box("Bench", -50, -40, FLOOR, FLOOR + 1.6, 30, 32, C.wood, M.WoodPlanks, { parent = f })
	lamp("LockerLight", -45, CEIL - 2, 34, C.amber, 1.3, 30, f)

	-- Clickable locker doors (bag + coat + lock) — props spawn in aisle in front of door
	for i = 0, 5 do
		local z0 = 22 + i * 3.5
		local door = box("LockerDoor", -56.9, -56.55, FLOOR + 1.5, FLOOR + 7.5, z0, z0 + 2.8, C.steel, M.Metal, { parent = f })
		door:SetAttribute("Interact", "Locker")
		door:SetAttribute("LockerId", i + 1)
		door:SetAttribute("LockerZ", z0)
		makePrompt(door, "Put bag & coat · lock", "Locker " .. (i + 1), 1.0, 8)
	end
end)

----------------------------------------------------------------
-- 5. HUB
----------------------------------------------------------------
section("Hub", function()
	local f = folder("5 Hub Water Snacks")
	for _, x in ipairs({ -15, 0 }) do
		box("Column", x - 1.5, x + 1.5, FLOOR, CEIL, 20.5, 23.5, C.concrete, M.Concrete, { parent = f })
	end
	box("WaterTrough", -24, -14, FLOOR, FLOOR + 3.4, 1, 3.4, C.steel, M.Metal, { parent = f })
	box("WaterBasin", -23.5, -14.5, FLOOR + 3.1, FLOOR + 3.45, 1.4, 3, C.nearBlack, M.Metal, { collide = false, parent = f })
	for _, x in ipairs({ -22, -19, -16 }) do
		local tap = box("Tap", x - 0.2, x + 0.2, FLOOR + 3.4, FLOOR + 5.2, 1.2, 1.6, C.steel, M.Metal, { collide = false, parent = f })
		tap:SetAttribute("Interact", "Water")
		makePrompt(tap, "Get water", "Free water", 0.5, 8)
	end
	neon("WaterGlow", -24, -14, FLOOR + 6, FLOOR + 6.3, 1.05, 1.2, C.ice, f)
	panel("WaterSign", -22, -16, FLOOR + 7, FLOOR + 9, 1.05, 1.35, Enum.NormalId.Back, "WATER", C.ice, C.black, "GothamBlack", f)
	lamp("WaterLight", -19, FLOOR + 7, 4, C.ice, 1, 12, f)

	local snackMachine = box("SnackMachine", -7, -1, FLOOR, FLOOR + 8.5, 1, 4, C.nearBlack, M.Metal, { parent = f })
	box("SnackGlass", -6.6, -2.6, FLOOR + 2.2, FLOOR + 7.6, 4.0, 4.15, C.glass, M.Glass, {
		collide = false,
		transparency = 0.4,
		reflectance = 0.2,
		parent = f,
	})
	local snackColors = { C.red, C.orange, C.blue, C.green, C.magenta }
	local n = 0
	for row = 0, 3 do
		for col = 0, 2 do
			n = n + 1
			local x = -6.1 + col * 1.25
			local y = FLOOR + 2.6 + row * 1.3
			neon("Snack", x, x + 0.8, y, y + 0.7, 3.6, 3.95, snackColors[(n % #snackColors) + 1], f)
		end
	end
	local keypad = neon("SnackKeypad", -2.3, -1.4, FLOOR + 4, FLOOR + 6, 4.0, 4.15, C.green, f)
	keypad:SetAttribute("Interact", "Snack")
	makePrompt(keypad, "Buy snack", "Vending", 0.6, 8)
	snackMachine:SetAttribute("Interact", "Snack")
	panel("SnackSign", -6.6, -1.4, FLOOR + 7.7, FLOOR + 8.4, 4.0, 4.15, Enum.NormalId.Back, "SNACKS", C.white, C.red, "GothamBlack", f)
	lamp("SnackLight", -4, FLOOR + 6, 6, C.ice, 0.8, 10, f)

	lamp("HubWash", -8, CEIL - 2, 24, C.magenta, 1.6, 40, f)
	lamp("HubWash2", -24, CEIL - 2, 12, C.red, 1.4, 30, f)
end)

----------------------------------------------------------------
-- 6. BASEMENT MAIN FLOOR
----------------------------------------------------------------
section("Main floor", function()
	local f = folder("6 Basement Main Floor")
	box("DJRiser", -40, -20, FLOOR, FLOOR + 3, 89, 99, C.concreteDark, M.Concrete, { parent = f })
	local djDesk = box("DJDesk", -36, -24, FLOOR + 3, FLOOR + 6.5, 91, 93.5, C.black, M.SmoothPlastic, { parent = f })
	-- dancePart wired after dance pad is created below; temporary nil then re-call not needed — pass via late attach
	local djMusicPending = djDesk
	for i, x in ipairs({ -35, -31.4, -27.6 }) do
		local w = (i == 2) and 2.4 or 3.4
		box("Deck", x, x + w, FLOOR + 6.5, FLOOR + 6.9, 91.4, 93.1, C.metal, M.Metal, { collide = false, parent = f })
		neon("DeckScreen", x + 0.3, x + w - 0.3, FLOOR + 6.9, FLOOR + 7.0, 91.8, 92.5, (i == 2) and C.orange or C.ice, f)
	end
	for col = 0, 8 do
		for row = 0, 4 do
			local x = -41 + col * 2.75
			local y = FLOOR + 6 + row * 2
			neon("Bulb", x - 0.4, x + 0.4, y - 0.4, y + 0.4, 98.4, 98.9, C.orange, f)
		end
	end
	lamp("BulbGlow", -36, FLOOR + 10, 96.5, C.orange, 1.6, 22, f)
	lamp("BulbGlow", -24, FLOOR + 10, 96.5, C.orange, 1.6, 22, f)
	panel("CharlotteSign", -40, -20, FLOOR + 16, FLOOR + 17.6, 98.5, 98.95, Enum.NormalId.Front, "CHARLOTTE DE WITTE", C.white, C.black, "GothamBlack", f)

	for _, x0 in ipairs({ -50, -16 }) do
		box("Stack", x0, x0 + 6, FLOOR, FLOOR + 14, 86, 93, C.black, M.SmoothPlastic, { parent = f })
		for k = 0, 2 do
			local y = FLOOR + 1.5 + k * 4.2
			box("Driver", x0 + 0.6, x0 + 5.4, y, y + 3.4, 85.8, 86, C.nearBlack, M.DiamondPlate, { collide = false, parent = f })
		end
	end

	for _, x in ipairs({ -42, -18 }) do
		local fogger = box("Fogger", x - 1, x + 1, FLOOR, FLOOR + 1, 87, 88.5, C.black, M.Metal, { parent = f })
		pcall(function()
			local s = Instance.new("Smoke")
			s.Color = Color3.fromRGB(90, 80, 100)
			s.Opacity = 0.06
			s.RiseVelocity = 1.5
			s.Size = 14
			s.Parent = fogger
		end)
	end

	for _, x in ipairs({ -50, -30, -10 }) do
		for _, z in ipairs({ 60, 76 }) do
			box("Pillar", x - 1.5, x + 1.5, FLOOR, CEIL, z - 1.5, z + 1.5, C.concrete, M.Concrete, { parent = f })
		end
	end

	for _, z in ipairs({ 70, 83 }) do
		box("Truss", -52, -8, CEIL - 2.6, CEIL - 1.8, z - 0.5, z + 0.5, C.metal, M.Metal, { collide = false, parent = f })
		for _, x in ipairs({ -48, -40, -32, -24, -16 }) do
			local head = box("SpotHead", x - 0.6, x + 0.6, CEIL - 3.6, CEIL - 2.6, z - 0.6, z + 0.6, C.black, M.Metal, {
				collide = false,
				parent = f,
			})
			local s = addLight(head, "SpotLight", C.red, 4, 40, { face = Enum.NormalId.Bottom, angle = 55, shadows = false })
			table.insert(FX.mainSpots, s)
		end
	end
	for _, pos in ipairs({ { -40, 76.5 }, { -20, 76.5 }, { -30, 64.5 } }) do
		local x, z = pos[1], pos[2]
		local strobe = neon("Strobe", x - 1.5, x + 1.5, CEIL - 3.2, CEIL - 2.8, z - 0.3, z + 0.3, C.white, f)
		local l = addLight(strobe, "PointLight", C.white, 6, 30, { shadows = false })
		l.Enabled = false
		strobe.Transparency = 1
		table.insert(FX.strobes, { part = strobe, light = l })
	end

	local emitter = box("LaserEmitter", -31, -29, FLOOR + 14, FLOOR + 15, 97, 98, C.black, M.Metal, { collide = false, parent = f })
	local a0 = Instance.new("Attachment")
	a0.Parent = emitter
	for i, x in ipairs({ -56, -46, -36, -24, -14, -4 }) do
		local anchor = box("LaserTarget", x - 0.2, x + 0.2, FLOOR + 3 + (i % 3) * 2, FLOOR + 3.4 + (i % 3) * 2, 46.3, 46.7, C.black, M.SmoothPlastic, {
			collide = false,
			transparency = 1,
			shadow = false,
			parent = f,
		})
		local a1 = Instance.new("Attachment")
		a1.Parent = anchor
		local beam = Instance.new("Beam")
		beam.Attachment0 = a0
		beam.Attachment1 = a1
		beam.Color = ColorSequence.new((i % 2 == 0) and C.red or C.green)
		beam.Width0 = 0.12
		beam.Width1 = 0.2
		beam.LightEmission = 1
		beam.FaceCamera = true
		beam.Transparency = NumberSequence.new(0.15)
		beam.Enabled = false
		beam.Parent = emitter
		table.insert(FX.lasers, beam)
	end

	local barCounter = box("BarCounter", -57, -37, FLOOR, FLOOR + 3.6, 48, 50.5, C.nearBlack, M.Concrete, { parent = f })
	box("BarTop", -57.3, -36.7, FLOOR + 3.6, FLOOR + 4, 47.8, 50.8, C.wood, M.Wood, { parent = f })
	neon("BarUnderglow", -57, -37, FLOOR + 0.3, FLOOR + 0.5, 50.5, 50.7, C.red, f)
	local drinkPad = box("DrinkPad", -48, -44, FLOOR + 4, FLOOR + 4.15, 49.2, 50.2, C.amber, M.Neon, { collide = false, parent = f })
	drinkPad:SetAttribute("Interact", "Drink")
	makePrompt(drinkPad, "Buy drink", "Bar", 0.7, 10)
	barCounter:SetAttribute("Interact", "Drink")

	-- Dance floor pad (main room center) — press E / tap prompt
	local dance = box("DanceFloor", -40, -20, FLOOR + 0.05, FLOOR + 0.12, 58, 78, Color3.fromRGB(90, 20, 40), M.Neon, {
		collide = false,
		transparency = 0.55,
		parent = f,
	})
	dance:SetAttribute("Interact", "Dance")
	local dancePrompt = makePrompt(dance, "Press E to dance", "Dancefloor — stand here", 0, 16)
	dancePrompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	dancePrompt.KeyboardKeyCode = Enum.KeyCode.E
	setupDjMusic(djMusicPending, dance)
	local danceSign = box("DanceHint", -32, -28, FLOOR + 6, FLOOR + 8, 67.5, 68, C.black, M.SmoothPlastic, {
		collide = false,
		transparency = 1,
		parent = f,
	})
	local bb = Instance.new("BillboardGui")
	bb.Name = "DanceHowTo"
	bb.Size = UDim2.fromOffset(240, 58)
	bb.StudsOffset = Vector3.new(0, 2, 0)
	bb.AlwaysOnTop = true
	bb.MaxDistance = 60
	bb.Parent = danceSign
	local bbLabel = Instance.new("TextLabel")
	bbLabel.Size = UDim2.fromScale(1, 1)
	bbLabel.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
	bbLabel.BackgroundTransparency = 0.2
	bbLabel.BorderSizePixel = 0
	bbLabel.Text = "HOW TO DANCE\nStand on the neon pad → press E"
	bbLabel.TextColor3 = Color3.fromRGB(255, 230, 220)
	bbLabel.Font = Enum.Font.GothamBold
	bbLabel.TextScaled = true
	bbLabel.Parent = bb
	for k = 0, 1 do
		local y = FLOOR + 5 + k * 2.4
		box("BackShelf", -57, -37, y, y + 0.25, 46, 47, C.metal, M.Metal, { collide = false, parent = f })
		local bottleColors = { C.amber, C.green, C.ice, C.red }
		local x = -56.4
		local j = 0
		while x < -37.6 do
			j = j + 1
			box("Bottle", x, x + 0.45, y + 0.25, y + 1.7, 46.3, 46.75, bottleColors[(j % 4) + 1], M.Glass, {
				collide = false,
				transparency = 0.25,
				parent = f,
			})
			x = x + 0.9
		end
	end
	neon("BarStrip", -57, -37, FLOOR + 10, FLOOR + 10.25, 46.05, 46.3, C.red, f)
	panel("BarSign", -50, -44, FLOOR + 10.6, FLOOR + 12.6, 46.05, 46.35, Enum.NormalId.Back, "BAR", C.white, C.black, "GothamBlack", f)
	lamp("BarLight", -47, FLOOR + 9, 49, C.amber, 1.4, 16, f)

	box("AVPlatform", -9, -2, FLOOR, FLOOR + 2.2, 49, 55, C.nearBlack, M.DiamondPlate, { parent = f })
	box("AVDesk", -8.5, -2.5, FLOOR + 2.2, FLOOR + 4.6, 49.5, 51, C.black, M.SmoothPlastic, { parent = f })
	neon("AVScreens", -8, -3, FLOOR + 4.6, FLOOR + 5.8, 49.7, 49.9, C.ice, f)
	panel("AVSign", -8.5, -2.5, FLOOR + 6.5, FLOOR + 7.7, 48.9, 49.1, Enum.NormalId.Back, "LIGHT / AV", C.white, C.black, "GothamBold", f)

	lamp("MainWash", -30, CEIL - 3, 64, C.red, 2.2, 50, f)
	lamp("MainWash2", -30, CEIL - 3, 90, C.magenta, 1.6, 36, f)
end)

----------------------------------------------------------------
-- 7. DARK ROOMS
----------------------------------------------------------------
section("Dark rooms", function()
	local f = folder("7 Dark Rooms")
	local top = DOOR_TOP
	wallZ("LinerW", 1.1, 46, 99, { { 62, 74 } }, { y0 = FLOOR, y1 = top, thick = 0.2, color = C.black, material = M.SmoothPlastic, parent = f })
	wallZ("LinerE", 33.9, 46, 99, { { 76, 86 } }, { y0 = FLOOR, y1 = top, thick = 0.2, color = C.black, material = M.SmoothPlastic, parent = f })
	wallX("LinerS", 46.1, 1, 34, { { 4, 12 } }, { y0 = FLOOR, y1 = top, thick = 0.2, color = C.black, material = M.SmoothPlastic, parent = f })
	wallX("LinerN", 98.9, 1, 34, {}, { y0 = FLOOR, y1 = top, thick = 0.2, color = C.black, material = M.SmoothPlastic, parent = f })

	local function block(name, x0, x1, z0, z1)
		box(name, x0, x1, FLOOR, top, z0, z1, C.nearBlack, M.Slate, { parent = f })
	end
	local function nookBench(x0, x1, z0, z1, lx, lz)
		box("NookBench", x0, x1, FLOOR, FLOOR + 1.6, z0, z1, C.black, M.Leather, { parent = f })
		local l = lamp("NookEmber", lx, FLOOR + 7, lz, Color3.fromRGB(170, 30, 20), 0.45, 9, f)
		table.insert(FX.embers, l:FindFirstChildOfClass("PointLight"))
	end
	block("BlockSW", 6, 14.5, 51.5, 57.5)
	block("BlockSW", 6, 14.5, 63.5, 69.5)
	block("BlockSW", 6, 10.5, 57.5, 63.5)
	nookBench(10.5, 11.9, 58, 63, 12.5, 60.5)
	block("BlockSE", 20.5, 29, 51.5, 57.5)
	block("BlockSE", 20.5, 29, 63.5, 69.5)
	block("BlockSE", 24.5, 29, 57.5, 63.5)
	nookBench(23.1, 24.5, 58, 63, 22.5, 60.5)
	block("BlockNW", 6, 14.5, 75.5, 81.5)
	block("BlockNW", 6, 14.5, 87.5, 93.5)
	block("BlockNW", 6, 10.5, 81.5, 87.5)
	nookBench(10.5, 11.9, 82, 87, 12.5, 84.5)
	block("BlockNE", 20.5, 29, 75.5, 81.5)
	block("BlockNE", 20.5, 29, 87.5, 93.5)
	block("BlockNE", 24.5, 29, 81.5, 87.5)
	nookBench(23.1, 24.5, 82, 87, 22.5, 84.5)

	for _, pos in ipairs({ { 3.5, 50 }, { 3.5, 95 }, { 31.5, 50 }, { 31.5, 95 }, { 17.5, 50 }, { 17.5, 96 } }) do
		local e = neon("Ember", pos[1] - 0.3, pos[1] + 0.3, top - 0.8, top - 0.4, pos[2] - 0.3, pos[2] + 0.3, Color3.fromRGB(150, 20, 10), f)
		table.insert(FX.embers, addLight(e, "PointLight", Color3.fromRGB(170, 30, 20), 0.5, 14, { shadows = false }))
	end
	local bulb = neon("BareBulb", 17.2, 17.8, top - 2.2, top - 1.6, 72.2, 72.8, C.amber, f)
	box("BulbCord", 17.45, 17.55, top - 1.6, top, 72.45, 72.55, C.black, M.Rubber, { collide = false, parent = f })
	addLight(bulb, "PointLight", C.amber, 0.7, 16, { shadows = true })
end)

----------------------------------------------------------------
-- 8. STUDIO
----------------------------------------------------------------
section("Studio", function()
	local f = folder("8 Studio")
	local diag = Instance.new("Part")
	diag.Name = "DiagonalWall"
	diag.Anchored = true
	diag.Size = Vector3.new(4, CEIL - FLOOR, 18)
	diag.CFrame = CFrame.new(37.5, (FLOOR + CEIL) / 2, 22.5) * CFrame.Angles(0, math.rad(45), 0)
	diag.Color = C.concrete
	diag.Material = M.Concrete
	diag.Parent = f

	box("StudioRiser", 50, 59, FLOOR, FLOOR + 2.5, 24, 38, C.concreteDark, M.Concrete, { parent = f })
	box("StudioDesk", 52, 54.5, FLOOR + 2.5, FLOOR + 6, 27, 35, C.black, M.SmoothPlastic, { parent = f })
	neon("StudioDeckScreens", 52.2, 52.4, FLOOR + 6, FLOOR + 6.3, 28, 34, C.ice, f)
	for row = 0, 4 do
		for col = 0, 5 do
			local z = 25.5 + col * 2.3
			local y = FLOOR + 6 + row * 2
			neon("StudioBulb", 58.4, 58.9, y - 0.35, y + 0.35, z - 0.35, z + 0.35, C.ice, f)
		end
	end
	panel("StudioSign", 58.5, 58.95, FLOOR + 15.2, FLOOR + 17.2, 25, 37, Enum.NormalId.Left, "STUDIO", C.ice, C.black, "GothamBlack", f)

	box("StudioBarCounter", 18, 34, FLOOR, FLOOR + 3.6, 40, 42.5, C.nearBlack, M.Concrete, { parent = f })
	box("StudioBarTop", 17.7, 34.3, FLOOR + 3.6, FLOOR + 4, 39.8, 42.8, C.steel, M.Metal, { parent = f })
	box("StudioBackShelf", 18, 34, FLOOR + 5, FLOOR + 5.25, 43, 44, C.metal, M.Metal, { collide = false, parent = f })
	neon("StudioBarStrip", 18, 34, FLOOR + 9, FLOOR + 9.25, 43.7, 43.95, C.blue, f)
	panel("StudioBarSign", 23, 29, FLOOR + 9.8, FLOOR + 11.8, 43.6, 43.95, Enum.NormalId.Front, "BAR", C.white, C.black, "GothamBlack", f)

	box("Bleacher1", 38, 56, FLOOR, FLOOR + 1.2, 1, 7, C.concreteDark, M.Concrete, { parent = f })
	box("Bleacher2", 38, 56, FLOOR + 1.2, FLOOR + 2.4, 1, 4.6, C.concreteDark, M.Concrete, { parent = f })
	box("Bleacher3", 38, 56, FLOOR + 2.4, FLOOR + 3.6, 1, 2.4, C.concreteDark, M.Concrete, { parent = f })

	box("StudioAV", 16, 20, FLOOR, FLOOR + 3.5, 30, 36, C.nearBlack, M.DiamondPlate, { parent = f })
	neon("StudioAVScreen", 19.9, 20.05, FLOOR + 3.6, FLOOR + 4.6, 31, 35, C.ice, f)

	box("StudioTruss", 20, 52, CEIL - 2.6, CEIL - 1.8, 21.5, 22.5, C.metal, M.Metal, { collide = false, parent = f })
	for _, x in ipairs({ 22, 30, 44, 50 }) do
		local head = box("SpotHead", x - 0.6, x + 0.6, CEIL - 3.6, CEIL - 2.6, 21.4, 22.6, C.black, M.Metal, { collide = false, parent = f })
		table.insert(FX.studioSpots, addLight(head, "SpotLight", C.blue, 3.5, 36, { face = Enum.NormalId.Bottom, angle = 60, shadows = false }))
	end
	local strobe = neon("StudioStrobe", 36, 39, CEIL - 3.2, CEIL - 2.8, 30, 30.6, C.white, f)
	local sl = addLight(strobe, "PointLight", C.white, 5, 26, { shadows = false })
	sl.Enabled = false
	strobe.Transparency = 1
	table.insert(FX.strobes, { part = strobe, light = sl })
	lamp("StudioWash", 30, CEIL - 3, 10, C.violet, 1.4, 36, f)

	panel("WCSign", 58.75, 58.95, FLOOR + 12.5, FLOOR + 14.5, 5, 13, Enum.NormalId.Left, "THE STALLS", C.white, C.black, "GothamBlack", f)
end)

----------------------------------------------------------------
-- 9. THE STALLS (real toilets + dense layered graffiti)
----------------------------------------------------------------
section("The Stalls", function()
	local f = folder("9 The Stalls")
	local top = CEIL
	local stallH = FLOOR + 9
	local tileMat = M.SmoothPlastic -- ceramic look without enum risk
	wallZ("TileW", 61.1, 1, 44, { { 4, 14 } }, { y0 = FLOOR, y1 = top, thick = 0.2, color = C.tile, material = tileMat, parent = f })
	wallZ("TileE", 88.9, 1, 44, {}, { y0 = FLOOR, y1 = top, thick = 0.2, color = C.tile, material = tileMat, parent = f })
	wallX("TileS", 1.1, 61, 89, {}, { y0 = FLOOR, y1 = top, thick = 0.2, color = C.tile, material = tileMat, parent = f })
	wallX("TileN", 43.9, 61, 89, {}, { y0 = FLOOR, y1 = top, thick = 0.2, color = C.tile, material = tileMat, parent = f })

	local eastGraff = box("EastGraffitiWall", 88.55, 88.7, FLOOR, stallH, 3, 42, C.tile, M.SmoothPlastic, {
		collide = false,
		parent = f,
	})
	graffitiOn(eastGraff, Enum.NormalId.Left, 36)
	local westGraff = box("WestGraffitiWall", 61.3, 61.45, FLOOR, stallH, 16, 40, C.tile, M.SmoothPlastic, {
		collide = false,
		parent = f,
	})
	graffitiOn(westGraff, Enum.NormalId.Right, 28)

	local edges = { 3, 9.6, 16.2, 22.8, 29.4, 36.0, 42.6 }
	for i, z in ipairs(edges) do
		local part = box("StallPartition", 80, 88.8, FLOOR, stallH, z - 0.2, z + 0.2, C.white, M.SmoothPlastic, { parent = f })
		graffitiOn(part, Enum.NormalId.Front, 18)
		graffitiOn(part, Enum.NormalId.Back, 18)
		if i < #edges then
			local zA, zB = z, edges[i + 1]
			local doorL = box("StallFront", 80, 80.4, FLOOR, stallH, zA, zA + 1.05, C.nearBlack, M.Metal, { parent = f })
			local doorR = box("StallFront", 80, 80.4, FLOOR, stallH, zB - 1.05, zB, C.nearBlack, M.Metal, { parent = f })
			graffitiOn(doorL, Enum.NormalId.Right, 14)
			graffitiOn(doorR, Enum.NormalId.Right, 14)
			box("Latch", 79.7, 80.1, FLOOR + 4, FLOOR + 4.6, (zA + zB) / 2 - 0.15, (zA + zB) / 2 + 0.15, C.steel, M.Metal, { collide = false, parent = f })

			local mid = (zA + zB) / 2
			-- Real toilet: bowl, seat, tank, flush handle, TP dispenser + rolls
			box("ToiletBowl", 86.2, 88.2, FLOOR, FLOOR + 1.6, mid - 0.9, mid + 0.9, C.white, M.SmoothPlastic, { parent = f })
			box("ToiletSeat", 86.1, 88.3, FLOOR + 1.55, FLOOR + 1.75, mid - 1.0, mid + 1.0, C.white, M.SmoothPlastic, { collide = false, parent = f })
			box("ToiletTank", 87.6, 88.8, FLOOR + 1.6, FLOOR + 4.2, mid - 1.0, mid + 1.0, C.white, M.SmoothPlastic, { parent = f })
			local flush = box("FlushHandle", 87.4, 87.7, FLOOR + 3.4, FLOOR + 3.7, mid + 0.7, mid + 1.05, C.steel, M.Metal, { collide = false, parent = f })
			flush:SetAttribute("Interact", "Flush")
			makePrompt(flush, "Flush", "Toilet", 0.4, 8)

			local tp = box("TPDispenser", 85.2, 86.0, FLOOR + 3.2, FLOOR + 4.4, zA + 0.35, zA + 1.1, C.nearBlack, M.Metal, { parent = f })
			box("TPRoll", 85.35, 85.85, FLOOR + 3.4, FLOOR + 4.1, zA + 0.45, zA + 1.0, C.white, M.SmoothPlastic, { collide = false, parent = f })
			tp:SetAttribute("Interact", "ToiletPaper")
			makePrompt(tp, "Take paper", "Toilet paper", 0, 8)

			box("SpareTP", 87.8, 88.5, FLOOR + 4.2, FLOOR + 4.7, mid - 0.7, mid - 0.2, C.white, M.SmoothPlastic, { collide = false, parent = f })
			box("SpareTP", 87.8, 88.5, FLOOR + 4.2, FLOOR + 4.7, mid + 0.2, mid + 0.7, C.white, M.SmoothPlastic, { collide = false, parent = f })

			local sideTag = box("StallGraffiti", 81, 87.5, FLOOR + 2, stallH - 0.5, z + 0.25, z + 0.35, C.white, M.SmoothPlastic, {
				collide = false,
				transparency = 1,
				parent = f,
			})
			graffitiOn(sideTag, Enum.NormalId.Front, 20)
		end
	end

	panel("MadMaxStall", 88.6, 88.75, FLOOR + 4.6, FLOOR + 9.2, 23.4, 28.8, Enum.NormalId.Left, "MAD MAX RAVE CREW 4 EVA!", C.red, nil, "PermanentMarker", f, true)
	panel("MadMaxMural", 64, 86, FLOOR + 9.5, FLOOR + 15.5, 43.75, 43.8, Enum.NormalId.Front, "MAD MAX RAVE CREW 4 EVA!", C.red, nil, "PermanentMarker", f, true)
	local muralBoard = box("MuralBoard", 64, 86, FLOOR + 9.5, FLOOR + 15.5, 43.6, 43.7, C.nearBlack, M.SmoothPlastic, { collide = false, parent = f })
	graffitiOn(muralBoard, Enum.NormalId.Front, 32)
	-- extra layered Mad Max board (photo-ref density)
	local mural2 = box("MuralLayer2", 66, 84, FLOOR + 10, FLOOR + 14.5, 43.5, 43.58, C.nearBlack, M.SmoothPlastic, { collide = false, parent = f })
	graffitiOn(mural2, Enum.NormalId.Front, 24)

	box("SinkCounter", 61.2, 64, FLOOR, FLOOR + 3.6, 17, 39, C.concrete, M.Marble, { parent = f })
	for _, z in ipairs({ 20, 25, 30, 35 }) do
		box("Basin", 61.8, 63.4, FLOOR + 3.3, FLOOR + 3.65, z - 1, z + 1, C.white, M.SmoothPlastic, { collide = false, parent = f })
		local faucet = box("Faucet", 61.3, 61.8, FLOOR + 3.6, FLOOR + 4.8, z - 0.15, z + 0.15, C.steel, M.Metal, { collide = false, parent = f })
		faucet:SetAttribute("Interact", "WashHands")
		makePrompt(faucet, "Wash hands", "Sink", 0.8, 8)
	end
	box("Mirror", 61.2, 61.35, FLOOR + 5.5, FLOOR + 11, 17, 39, C.steel, M.Glass, { reflectance = 0.6, collide = false, parent = f })

	for _, x in ipairs({ 66, 74, 84 }) do
		local tube = neon("FluoroTube", x - 0.3, x + 0.3, top - 0.6, top - 0.3, 4, 41, C.white, f)
		addLight(tube, "SurfaceLight", C.white, 1.3, 20, { face = Enum.NormalId.Bottom, angle = 120 })
	end
end)

----------------------------------------------------------------
-- 10. BREAK TIME
----------------------------------------------------------------
section("Break Time", function()
	local f = folder("10 Break Time Backyard")
	wallZ("WC2Wall", 70, 72, 100, { { 80, 90 } }, { y0 = 0, y1 = FLOOR + 15, color = C.brick, material = M.Brick, parent = f })
	wallX("WC2Wall", 72, 70, 90, {}, { y0 = 0, y1 = FLOOR + 15, color = C.brick, material = M.Brick, parent = f })
	box("WC2Roof", 69, 90, FLOOR + 14, FLOOR + 15, 71, 100, C.concreteDark, M.Concrete, { parent = f })
	box("WC2Floor", 70, 90, 0.45, FLOOR + 0.05, 72, 100, C.tile, M.SmoothPlastic, { parent = f })
	wallZ("WC2TileW", 71.1, 73, 99, { { 80, 90 } }, { y0 = FLOOR, y1 = FLOOR + 14, thick = 0.2, color = C.tile, material = M.SmoothPlastic, parent = f })
	wallX("WC2TileS", 73.1, 71, 89, {}, { y0 = FLOOR, y1 = FLOOR + 14, thick = 0.2, color = C.tile, material = M.SmoothPlastic, parent = f })
	wallX("WC2TileN", 98.9, 71, 89, {}, { y0 = FLOOR, y1 = FLOOR + 14, thick = 0.2, color = C.tile, material = M.SmoothPlastic, parent = f })
	wallZ("WC2TileE", 88.9, 73, 99, {}, { y0 = FLOOR, y1 = FLOOR + 14, thick = 0.2, color = C.tile, material = M.SmoothPlastic, parent = f })
	local xs = { 71.2, 77.0, 82.8, 88.8 }
	for i, x in ipairs(xs) do
		box("WC2Partition", x - 0.2, x + 0.2, FLOOR, FLOOR + 9, 91, 98.8, C.white, M.SmoothPlastic, { parent = f })
		if i < #xs then
			local xA, xB = x, xs[i + 1]
			box("WC2Front", xA, xA + 0.95, FLOOR, FLOOR + 9, 90.6, 91, C.white, M.SmoothPlastic, { parent = f })
			box("WC2Front", xB - 0.95, xB, FLOOR, FLOOR + 9, 90.6, 91, C.white, M.SmoothPlastic, { parent = f })
			local mid = (xA + xB) / 2
			box("Toilet", mid - 1, mid + 1, FLOOR, FLOOR + 2.2, 96.4, 98.8, C.white, M.SmoothPlastic, { parent = f })
		end
	end
	box("WC2Sinks", 75, 86, FLOOR, FLOOR + 3.6, 73.2, 75.6, C.concrete, M.Marble, { parent = f })
	local wcTube = neon("WC2Tube", 74, 86, FLOOR + 13.4, FLOOR + 13.7, 82, 82.6, C.white, f)
	addLight(wcTube, "SurfaceLight", C.white, 1.2, 16, { face = Enum.NormalId.Bottom, angle = 120 })
	local tag = box("Tag", 79.5, 82.5, FLOOR + 5, FLOOR + 7, 98.75, 98.8, C.black, M.SmoothPlastic, { collide = false, transparency = 1, shadow = false, parent = f })
	sign(tag, Enum.NormalId.Front, "4 EVA", C.red, nil, "PermanentMarker")
	panel("WC2Sign", 69.6, 69.8, FLOOR + 10, FLOOR + 12, 81, 89, Enum.NormalId.Left, "WC", C.white, C.black, "GothamBlack", f)

	box("YardBarCounter", 37, 55, FLOOR, FLOOR + 3.6, 94, 96.5, C.wood, M.WoodPlanks, { parent = f })
	box("YardBarTop", 36.7, 55.3, FLOOR + 3.6, FLOOR + 4, 93.8, 96.8, C.metal, M.Metal, { parent = f })
	box("YardBarShelf", 37, 55, FLOOR + 5, FLOOR + 5.25, 98, 99, C.metal, M.Metal, { collide = false, parent = f })
	box("Canopy", 36, 56, FLOOR + 10.5, FLOOR + 11.1, 91.5, 99, C.metal, M.CorrodedMetal, { parent = f })
	panel("YardBarSign", 42, 50, FLOOR + 8.6, FLOOR + 10.4, 91.6, 91.9, Enum.NormalId.Front, "BAR", C.white, C.black, "GothamBlack", f)
	neon("YardBarStrip", 37, 55, FLOOR + 10.2, FLOOR + 10.45, 91.6, 91.85, C.amber, f)
	panel("BreakTimeSign", 57, 68, FLOOR + 12, FLOOR + 15, 98.75, 98.95, Enum.NormalId.Front, "BREAK TIME", C.white, C.black, "GothamBlack", f)

	for _, pos in ipairs({ { 45, 60 }, { 59, 60 }, { 45, 76 }, { 59, 76 } }) do
		local cx, cz = pos[1], pos[2]
		box("TableTop", cx - 4, cx + 4, FLOOR + 3, FLOOR + 3.5, cz - 1.8, cz + 1.8, C.wood, M.WoodPlanks, { parent = f })
		box("TableLeg", cx - 0.5, cx + 0.5, FLOOR, FLOOR + 3, cz - 1.2, cz + 1.2, C.wood, M.Wood, { parent = f })
		box("Bench", cx - 4, cx + 4, FLOOR + 1.6, FLOOR + 2, cz - 3.6, cz - 2.6, C.wood, M.WoodPlanks, { parent = f })
		box("Bench", cx - 4, cx + 4, FLOOR + 1.6, FLOOR + 2, cz + 2.6, cz + 3.6, C.wood, M.WoodPlanks, { parent = f })
		box("BenchLeg", cx - 0.4, cx + 0.4, FLOOR, FLOOR + 1.6, cz - 3.4, cz - 2.8, C.wood, M.Wood, { parent = f })
		box("BenchLeg", cx - 0.4, cx + 0.4, FLOOR, FLOOR + 1.6, cz + 2.8, cz + 3.4, C.wood, M.Wood, { parent = f })
	end

	local poles = { { 37, 47 }, { 68, 47 }, { 68, 70 }, { 37, 90 } }
	local poleTop = FLOOR + 12
	for _, p in ipairs(poles) do
		box("LightPole", p[1] - 0.25, p[1] + 0.25, FLOOR, poleTop, p[2] - 0.25, p[2] + 0.25, C.wood, M.Wood, { parent = f })
	end
	local runs = { { 1, 3 }, { 2, 4 }, { 1, 2 }, { 3, 4 } }
	for _, r in ipairs(runs) do
		local a, b = poles[r[1]], poles[r[2]]
		for k = 1, 11 do
			local t = k / 12
			local x = a[1] + (b[1] - a[1]) * t
			local z = a[2] + (b[2] - a[2]) * t
			local y = poleTop - 0.4 - math.sin(t * math.pi) * 2.2
			local bulb = neon("StringBulb", x - 0.25, x + 0.25, y - 0.25, y + 0.25, z - 0.25, z + 0.25, Color3.fromRGB(255, 205, 130), f)
			if k == 6 then
				addLight(bulb, "PointLight", Color3.fromRGB(255, 200, 130), 1.1, 22, { shadows = false })
			end
		end
	end

	barrier(35, 90, CEIL + 1, CEIL + 30, 99, 101, f)
	barrier(89, 91, CEIL + 1, CEIL + 30, 45, 100, f)
	barrier(34, 36, CEIL + 1, CEIL + 30, 45, 100, f)
	barrier(35, 90, CEIL + 1, CEIL + 30, 44, 46, f)
end)

----------------------------------------------------------------
-- 11. INTERACTIONS (ProximityPrompts — server-side)
----------------------------------------------------------------
section("Interactions", function()
	local state = {} -- [userId] = { id, dress, locker, ... }
	local lockerBags = folder("LockerBags", root)

	local function st(player)
		local id = player.UserId
		if not state[id] then
			state[id] = {
				id = false,
				dress = false,
				locker = false,
				snack = false,
				drink = false,
				water = false,
				danced = false,
				tp = false,
				flushed = false,
				washed = false,
			}
		end
		return state[id]
	end

	local function succeed(player, message)
		task.spawn(function()
			playPew(player)
		end)
		if message then
			notify(player, message)
		end
	end

	local function tryOpenGate(player)
		local s = st(player)
		if s.id and s.dress then
			local gate = root:FindFirstChild("SecurityGate", true)
			if gate and gate:IsA("BasePart") then
				gate.CanCollide = false
				gate.Transparency = 1
			end
			notify(player, "Gate open. Lockers → bag & coat → floor.")
		end
	end

	local handlers = {
		PickCrew = function(player, part)
			local name = part and part:GetAttribute("CrewName") or "Sam"
			playerCrew[player.UserId] = name
			if player.Character then
				dressAllBlack(player.Character, name)
			end
			succeed(player, "You're " .. name .. " — all black + harness.")
		end,
		ShowID = function(player)
			local s = st(player)
			s.id = true
			showPlayerIdCard(player)
			succeed(player, "ID shown to bouncer. Next: dress-code.")
			tryOpenGate(player)
		end,
		DressCode = function(player)
			local s = st(player)
			s.dress = true
			if player.Character then
				dressAllBlack(player.Character, playerCrew[player.UserId])
			end
			succeed(player, "Dress code OK — all black + harness.")
			tryOpenGate(player)
		end,
		Locker = function(player, part)
			local s = st(player)
			if not (s.id and s.dress) then
				notify(player, "Clear ID + dress-code first.")
				return
			end
			s.locker = true
			local n = part and part:GetAttribute("LockerId") or "?"
			local z0 = part and part:GetAttribute("LockerZ") or 22
			-- Clear prior props for this player
			for _, ch in ipairs(lockerBags:GetChildren()) do
				if string.find(ch.Name, tostring(player.UserId), 1, true) then
					ch:Destroy()
				end
			end
			-- Open/tilt door into the aisle so bay is readable
			if part and part:IsA("BasePart") then
				part.CFrame = part.CFrame * CFrame.new(1.1, 0, 0) * CFrame.Angles(0, math.rad(-55), 0)
				part.Color = Color3.fromRGB(40, 40, 48)
			end
			-- Bag + coat IN FRONT of the chosen door (aisle side — visibly outside the wall)
			local bag = box("Bag_" .. tostring(player.UserId), -56.35, -55.4, FLOOR + 0.2, FLOOR + 2.4, z0 + 0.5, z0 + 1.8, Color3.fromRGB(28, 24, 22), M.Leather, {
				collide = false,
				parent = lockerBags,
			})
			box("BagStrap_" .. tostring(player.UserId), -56.15, -55.95, FLOOR + 2.3, FLOOR + 3.2, z0 + 0.9, z0 + 1.4, C.steel, M.Metal, {
				collide = false,
				parent = lockerBags,
			})
			box("Coat_" .. tostring(player.UserId), -56.45, -55.55, FLOOR + 2.6, FLOOR + 6.2, z0 + 0.35, z0 + 2.0, Color3.fromRGB(16, 16, 18), M.Fabric, {
				collide = false,
				parent = lockerBags,
			})
			local lock = neon("Locked_" .. tostring(player.UserId), -56.2, -55.7, FLOOR + 6.4, FLOOR + 7.0, z0 + 1.0, z0 + 1.5, C.red, lockerBags)
			sign(lock, Enum.NormalId.Right, "LOCKED", C.white, C.red, "GothamBlack")
			succeed(player, "Bag + coat in locker " .. tostring(n) .. " — LOCKED.")
		end,
		Snack = function(player)
			st(player).snack = true
			succeed(player, "Snack acquired. $0 tonight.")
		end,
		Drink = function(player)
			st(player).drink = true
			succeed(player, "Drink in hand. Cheers.")
		end,
		Water = function(player)
			st(player).water = true
			succeed(player, "Cold water. Hydrate.")
		end,
		Dance = function(player)
			st(player).danced = true
			playDance(player)
			succeed(player, "Dancing — stay on the floor (E again to refresh).")
		end,
		ToiletPaper = function(player)
			st(player).tp = true
			succeed(player, "Paper grabbed.")
		end,
		Flush = function(player)
			st(player).flushed = true
			succeed(player, "Flushed.")
		end,
		WashHands = function(player)
			st(player).washed = true
			succeed(player, "Hands washed. Back to the floor.")
		end,
	}

	local function onPrompt(prompt, player)
		local part = prompt.Parent
		if not part then
			return
		end
		local kind = part:GetAttribute("Interact")
		if not kind then
			return
		end
		local fn = handlers[kind]
		if fn then
			fn(player, part)
		end
	end

	local function wire(inst)
		if inst:IsA("ProximityPrompt") then
			inst.Triggered:Connect(function(player)
				onPrompt(inst, player)
			end)
		end
	end

	for _, d in ipairs(root:GetDescendants()) do
		wire(d)
	end
	root.DescendantAdded:Connect(wire)

	Players.PlayerRemoving:Connect(function(player)
		state[player.UserId] = nil
	end)

	log("Interactions live: ID → dress → bag/coat lockers → snacks/drinks/water → dance → stalls.")
end)

----------------------------------------------------------------
-- 12. LIGHT SHOW
----------------------------------------------------------------
local palette = { C.red, C.magenta, C.violet, C.blue, C.red, C.white }

task.spawn(function()
	local t = 0
	while true do
		local ok, err = pcall(function()
			t = t + 1
			if t % 4 == 0 then
				local step = math.floor(t / 4)
				for i, s in ipairs(FX.mainSpots) do
					s.Color = palette[((i + step) % #palette) + 1]
				end
				for i, s in ipairs(FX.studioSpots) do
					s.Color = ((i + step) % 2 == 0) and C.blue or C.ice
				end
			end
			local phase = t % 90
			local strobeOn = phase < 16 and (phase % 2 == 0)
			for _, s in ipairs(FX.strobes) do
				s.light.Enabled = strobeOn
				s.part.Transparency = strobeOn and 0 or 1
			end
			for i, beam in ipairs(FX.lasers) do
				beam.Enabled = (phase > 24 and phase < 70) and ((i + math.floor(t / 3)) % 2 == 0)
			end
			if t % 3 == 0 then
				for _, e in ipairs(FX.embers) do
					if e then
						e.Brightness = 0.3 + math.random() * 0.35
					end
				end
			end
		end)
		if not ok then
			warn("[Basement] light show: " .. tostring(err))
			task.wait(2)
		end
		task.wait(0.1)
	end
end)

setupAvatars()

for _, player in ipairs(Players:GetPlayers()) do
	pcall(function()
		player:LoadCharacter()
	end)
end

log("Club built. All-black + harness, DJ music, pew-pew on stops. Spawn in courtyard line.")
