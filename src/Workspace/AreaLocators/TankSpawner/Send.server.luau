local RS = game:GetService("ReplicatedStorage")
local SEnemies = RS:WaitForChild("SpecialEnemies")

script.Parent.Touched:Connect(function(hit)
	if game.Players:GetPlayerFromCharacter(hit.Parent) then
		script.Parent.CanTouch = false
		local clone = SEnemies.Tank:Clone()
		clone.Parent = workspace.Enemies
		clone.PrimaryPart.CFrame = script.Parent.Att.WorldCFrame
	end
end)