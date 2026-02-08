local module = {}
local types = {
	["Apple"] = {
		Health = 25,
		
		SoundId = "rbxassetid://6830386386",
		Sound = nil,
		
		AnimId = "rbxassetid://102469612610014",
		AnimTrack = nil,
	},
	
	["Vial"] = {
		Health = 50,

		SoundId = "rbxassetid://122960938851347",
		Sound = nil,

		AnimId = "rbxassetid://102469612610014",
		AnimTrack = nil,
	},
	
}

local SS = game:GetService("SoundService")
local RS = game:GetService("ReplicatedStorage")

local Events = RS:WaitForChild("Events")
local destroyEvent = Events:WaitForChild("DestroyEvent")
local healEvent = Events:WaitForChild("HealEvent")

function module.Init(player:Player, tool:Tool)
	local selected = types[tool.Name]
	
	local char = player.Character
	local hum:Humanoid = char:FindFirstChild("Humanoid")
	
	if selected and hum then
		if selected.AnimTrack then
			selected.AnimTrack:Play()
			
			task.delay(0.1, function()
				SS:PlayLocalSound(selected.Sound)
			end)
			
			selected.AnimTrack.Stopped:Connect(function()
				destroyEvent:FireServer(tool)
			end)
		end
		
		if selected.Health then
			if tool.Name == "Vial" then
				if math.random(1, 2) == 1 then
					healEvent:FireServer(-selected.Health)
				else
					healEvent:FireServer(selected.Health)
				end
			else
				healEvent:FireServer(-selected.Health)
			end
		end
	end
end

function module.Load(player:Player)
	local char = player.Character
	local hum:Humanoid = char:FindFirstChild("Humanoid")
	
	for i, selected in pairs(types) do
		if selected.AnimId then
			local anim = Instance.new("Animation")
			anim.AnimationId = selected.AnimId

			selected.AnimTrack = hum:LoadAnimation(anim)
			anim:Destroy()
		end
		
		if selected.SoundId then
			local sound = Instance.new("Sound")
			sound.SoundId = selected.SoundId
			
			selected.Sound = sound
		end
	end
end

return module
