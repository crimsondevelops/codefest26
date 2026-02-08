local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")

local Events = RS:WaitForChild("Events")
local blockEvent = Events:WaitForChild("BlockEvent")

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum:Humanoid = char:WaitForChild("Humanoid")

local blocking = false
local blockTrack = hum:LoadAnimation(script.Block)
blockTrack.Priority = Enum.AnimationPriority.Action4
blockTrack.Looped = true
local debounce = false

UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.F then
		if debounce == false then
			if not blocking then
				debounce = true
				task.delay(, function()
					debounce = false
					blocking = false
					blockTrack:Stop()
					blockEvent:FireServer(false)
					hum.WalkSpeed = 12
				end)
				
				blocking = true
				blockTrack:Play()
				blockEvent:FireServer(true)
				hum.WalkSpeed = 4
			end
		end
	end
end)

UIS.InputEnded:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.F then
		if blocking then
			
			blocking = false
			blockTrack:Stop()
			blockEvent:FireServer(false)
			hum.WalkSpeed = 12
		end
	end
end)