local UIS = game:GetService("UserInputService")

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum:Humanoid = char:WaitForChild("Humanoid")

local sprinting = false

UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	
	if input.KeyCode == Enum.KeyCode.LeftShift then
		if sprinting == false then
			sprinting = true
			hum.WalkSpeed = 20
		end
	end
end)

UIS.InputEnded:Connect(function(input, gpe)
	if gpe then return end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		if sprinting == true then
			sprinting = false
			hum.WalkSpeed = 1
		end
	end
end)
