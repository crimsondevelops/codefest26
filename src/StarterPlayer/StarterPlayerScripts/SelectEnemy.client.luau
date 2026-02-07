local highlight = script.Highlight

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local RuS = game:GetService("RunService")

RuS.Heartbeat:Connect(function()
	if mouse.Target then
		if mouse.Target.Parent:HasTag("Enemy") then
			highlight.Adornee = mouse.Target.
		else
			highlight.Adornee = nil
		end 
	else
		highlight.Adornee = nil
	end
end)