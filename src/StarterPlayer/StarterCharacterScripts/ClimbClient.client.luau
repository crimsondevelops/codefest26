local UIS = game:GetService("UserInputService")
local RuS = game:GetService("RunService")
local TS = game:GetService("TweenService")

local climbingPart = nil
local cooldown = false

local climbing = false
local climbDeb = false
local keyHolds = {
	["W"] = false,
	["A"] = false,
	["S"] = false,
	["D"] = false,
}

local climbFac = 2.5

if not game:IsLoaded() then game.Loaded:Wait() end

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp:BasePart = char:WaitForChild("HumanoidRootPart")
local hum:Humanoid = char:WaitForChild("Humanoid")

function freezeChar(bool)
	cooldown = true
	task.delay(0.25, function()
		cooldown = false
	end)

	if bool then
		hum:ChangeState(Enum.HumanoidStateType.None)
		hrp.Anchored = true
	else
		hum:ChangeState(Enum.HumanoidStateType.Freefall)
		hrp.Anchored = false
	end
end

RuS.Heartbeat:Connect(function()
	if climbing then

		if not climbDeb then
			local offset = CFrame.new(0, 0, 0)

			if keyHolds["W"] then
				offset = offset * CFrame.new(0, climbFac, 0)
			end
			if keyHolds["S"] then
				offset = offset * CFrame.new(0, -climbFac, 0)
			end
			if keyHolds["A"] then
				offset = offset * CFrame.new(-climbFac, 0, 0)
			end
			if keyHolds["D"] then
				offset = offset * CFrame.new(climbFac, 0, 0)
			end

			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = {workspace.Walls}

			local result = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 5, raycastParams)

			if result and result.Instance and not climbDeb then
				climbDeb = true
				task.delay(0.05, function()
					climbDeb = false
				end)

				if result and result.Instance then
					climbingPart = result.Instance

					local normal = result.Normal
					local diffZ = (hrp.CFrame:PointToObjectSpace(climbingPart.Position).Z) + 1

					local combinedOffset = offset
					combinedOffset = combinedOffset * CFrame.new(0, 0, diffZ)

					local hitPos = result.Position
					local right = climbingPart.CFrame.RightVector -- x axis direction
					local up = climbingPart.CFrame.UpVector -- y axis direction
					local forward = right:Cross(up) -- basically multiplies the right vector with upvector

					local pos = hitPos + forward + (right * combinedOffset.X) + (up * combinedOffset.Y)
					local targetCF = CFrame.fromMatrix(pos, right, up)

					local tweenInfo = TweenInfo.new(.25, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
					local tween = TS:Create(hrp, tweenInfo, {CFrame = targetCF})
					tween:Play()

					task.spawn(function()
						while tween.PlaybackState == Enum.PlaybackState.Playing do
							if not climbing then
								tween:Pause()
								tween:Destroy()
							end
							task.wait()
						end
					end)
				end
			elseif not result or not result.Instance then
				climbing = false
				climbingPart = nil
				freezeChar(false)
			end
		end
	end
end)

UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end

	if input.KeyCode == Enum.KeyCode.Space then
		for i, v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") then
				local touching = v:GetTouchingParts()

				for m, r in pairs(touching) do

					if r:IsA("BasePart") then

						if r:HasTag("WALL") then

							if not climbingPart then
								if not cooldown then
									if climbing then
										freezeChar(false)

										climbingPart = nil
										climbing = false
									elseif not climbing then
										freezeChar(true)

										climbingPart = r
										climbing = true
									end
								end
							end
						end

					end

				end
			end
		end
	end

	for key, m in pairs(keyHolds) do
		if input.KeyCode == Enum.KeyCode[key] then
			keyHolds[key] = true
		end
	end
end)

UIS.InputEnded:Connect(function(input, gpe)
	if gpe then return end

	for key, m in pairs(keyHolds) do
		if input.KeyCode == Enum.KeyCode[key] then
			keyHolds[key] = false
		end
	end
end)