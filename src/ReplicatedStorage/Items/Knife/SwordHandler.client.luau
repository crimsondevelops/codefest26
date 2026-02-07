local player = game.Players.LocalPlayer

repeat wait() until player.Character

local character = player.Character
local humanoid = character.Humanoid

local cooldown = false

local swing = 0
local animation = script.Parent.Swing

script.Parent.Activated:Connect(function()
	if cooldown == false then
		cooldown = true
		
		if swing == 2 then
			swing = 1
		else
			swing = 2
		end
		
		if swing == 1 then
			animation = script.Parent.Swing
		elseif swing == 2 then
			animation = script.Parent.Swing2
		end

		local loadedanimation = humanoid:LoadAnimation(animation)
		loadedanimation:Play()
		
		script.Parent.SwingEvent:FireServer()
		
		wait(1)
		cooldown = false
	end
end)

script.Parent.Equipped:Connect(function()
	script.Parent.equip_audio:Play()
end)