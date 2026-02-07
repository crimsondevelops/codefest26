if not game:IsLoaded() then game.Loaded:Wait() end

for i, v in pairs(workspace:GetDescendants()) do
	if v:IsA("BasePart") and v.Anchored == false then
		v:SetNetworkOwner(nil)
	end
end

game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		for i, v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end)
end)