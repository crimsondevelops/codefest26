local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp:BasePart = char:WaitForChild("HumanoidRootPart")

local npcs = workspace:WaitForChild("NPCs")
local Ross = npcs:WaitForChild("Ross")
local rHrp = Ross:WaitForChild("HumanoidRootPart")

local beam = script.Beam
beam.Attachment0 = hrp.RootAttachment
beam.Attachment1 = rHrp.RootAttachment
beam.Parent = rHrp

rHrp.Prompt.Triggered:Once(function()
	beam:Destroy()
end)