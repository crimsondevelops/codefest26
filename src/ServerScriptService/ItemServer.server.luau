local RS = game:GetService("ReplicatedStorage")



local Items = RS:WaitForChild("Items")
local Events = RS:WaitForChild("Events")
local equipEvent = Events:WaitForChild("EquipEvent")
local destroyEvent = Events:WaitForChild("DestroyEvent")

equipEvent.OnServerEvent:Connect(function(player, tool, hum, bool)
	local clone:Tool = tool:Clone()
	
	if bool then
		clone.Parent = player.Character
	else
		clone.Parent = player.Backpack
	end

	if not hum.Parent:FindFirstChildOfClass("Tool") then
		hum:EquipTool(clone)
	end
end)

destroyEvent.OnServerEvent:Connect(function(player, item)
	item:Destroy()
end)