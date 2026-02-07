for i, enemy in pairs(workspace.Enemies:GetChildren()) do
	local hum:Humanoid = enemy:WaitForChild("Humanoid", 3)
	local hrp:BasePart = enemy:WaitForChild("HumanoidRootPart", 3)
	
	local anim = hum:LoadAnimation(enemy.Walk)
	
	
	if hum and hrp then
		task.spawn(function()
			while task.wait() do
				for i, v in pairs(workspace:GetDescendants()) do
					if v.Name == "HumanoidRootPart" and v ~= hrp then
						if v:IsA("BasePart") then
							local distance = (hrp.Position - v.Position).Magnitude
							
							if distance < 30 and distance > 10 then
								hum:MoveTo(v.Position)
							end
						end
					end
				end
			end
		end)
	end
end