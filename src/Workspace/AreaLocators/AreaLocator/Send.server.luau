local RS = game:GetService("ReplicatedStorage")
local Events = RS:WaitForChild("Events")
local zoneEvent = Events:WaitForChild("ZoneEvent")

script.Parent.Touched:Connect(function(hit)
	if hit.Parent:FindFirstChild("Humanoid") then
		script.Parent.CanTouch = false
		zoneEvent:FireClient(game.Players:GetPlayerFromCharacter(hit.Parent), "B")
	end
end)