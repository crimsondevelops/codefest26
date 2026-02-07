local RS = game:GetService("ReplicatedStorage")
local Events = RS:WaitForChild("Events")
local zoneEvent = Events:WaitForChild("ZoneEvent")

script.Parent.Touched:Connect(function(hit)
	if game.Players:GetPlayerFromCharacter(hit.Parent) then
		script.Parent.CanTouch = false
		zoneEvent:FireClient(game.Players:GetPlayerFromCharacter(hit.Parent), "The Start")
		
	end
end)