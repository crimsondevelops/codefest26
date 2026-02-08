local RS = game:GetService("ReplicatedStorage")

script.Parent.Touched:Connect(function(hit)
	if game.Players:GetPlayerFromCharacter(hit.Parent) then
		script.Parent.CanTouch = false
		hit.Parent.HumanoidRootPart.Position = Vector3.new(219.384, 243.845, 1685.093)
		hit.Parent.HumanoidRootPart.Orientation = Vector3.new(0.086, -178.497, 0.472)
		hit.Parent.HumanoidRootPart.Anchored =
		
		hit.Parent.Humanoid:ChangeState(Enum.HumanoidStateType.None)
		
		game.ReplicatedStorage.Cutscenes.EndingCutscene:FireClient(game.Players:GetPlayerFromCharacter(hit.Parent))
		
		task.delay(0.1, function()
			local loaded = hit.Parent.Humanoid:LoadAnimation(script.Cutscene)
			loaded:Play()
		end)
		
		task.delay(3, function()
			game.Players:GetPlayerFromCharacter(hit.Parent):Kick("Thank you for playing.")
		end)
	end
end)