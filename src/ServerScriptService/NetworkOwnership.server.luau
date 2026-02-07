if not game:IsLoaded() then game.Loaded:Wait() end

for i, v in pairs(workspace:GetDescendants()) do
	if v:IsA("BasePart") and v.Anchored == false then
		v:SetNetworkOwner(nil)
	end
end