--[[
  OPTIONAL client helper for Basement Rave Crew.
  Not required — BuildBasement.server.lua already handles dance prompts,
  toast UI, DJ music, and pew-pew SFX on the server (replicates).

  If you want louder client-side music ducking / dance tip, paste this into:
    StarterPlayer → StarterPlayerScripts → LocalScript
]]

local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local player = Players.LocalPlayer

local tip = Instance.new("ScreenGui")
tip.Name = "BasementDanceTip"
tip.ResetOnSpawn = false
tip.Parent = player:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.4, 0, 0, 28)
label.Position = UDim2.new(0.3, 0, 0.88, 0)
label.BackgroundTransparency = 0.35
label.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
label.BorderSizePixel = 0
label.Text = "Dancefloor: stand in the neon pad → press E"
label.TextColor3 = Color3.fromRGB(255, 230, 220)
label.Font = Enum.Font.GothamBold
label.TextScaled = true
label.Parent = tip

-- Soften global bed when near spatial DJ (server owns both Sounds)
task.spawn(function()
	while tip.Parent do
		local bed = SoundService:FindFirstChild("BasementMusicBed")
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local club = workspace:FindFirstChild("BasementClub")
		local dj = club and club:FindFirstChild("DJMusic", true)
		if bed and root and dj and dj:IsA("Sound") then
			local dist = (root.Position - dj.Parent.Position).Magnitude
			bed.Volume = (dist < 50) and 0.04 or 0.12
		end
		task.wait(0.5)
	end
end)
