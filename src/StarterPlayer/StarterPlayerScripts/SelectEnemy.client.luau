local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local highlight = script.Highlight
local info = script.Info
info.Parent = player.PlayerGui

local title = info.Title
local health = info.Health

local RuS = game:GetService("RunService")

RuS.Heartbeat:Connect(function()
	if mouse.Target then
		local enemy = nil

		if mouse.Target:HasTag("Enemy") then
			enemy = mouse.Target
		elseif mouse.Target.Parent and mouse.Target.Parent:HasTag("Enemy") then
			enemy = mouse.Target.Parent
		elseif mouse.Target.Parent and mouse.Target.Parent.Parent and mouse.Target.Parent.Parent:HasTag("Enemy") then
			enemy = mouse.Target.Parent.Parent
		end

		if enemy then
			highlight.Adornee = enemy
			info.Adornee = enemy
			info.Parent = enemy

			title.Text = enemy.Name
			health.Text = enemy.Humanoid.Health .. "/" .. enemy.Humanoid.MaxHealth
		else
			highlight.Adornee = nil
			info.Parent = nil
		end
	else
		highlight.Adornee = nil
		info.Parent = nil
	end
end)