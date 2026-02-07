local UIS = game:GetService("UserInputService")
local RuS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")

local Events = RS:WaitForChild("Events")
local climbEvent = Events:WaitForChild("ClimbEvent")
local climbBind = Events:WaitForChild("ClimbBind")
local fallBind = Events:WaitForChild("ClimbFallBind")

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

local climbFac = 1.5

if not game:IsLoaded() then game.Loaded:Wait() end

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp:BasePart = char:WaitForChild("HumanoidRootPart")
local hum:Humanoid = char:WaitForChild("Humanoid")
local head:BasePart = char:WaitForChild("Head")

local upClimb = hum:LoadAnimation(script.UpClimb)
local downClimb = hum:LoadAnimation(script.DownClimb)
local leftClimb = hum:LoadAnimation(script.LeftClimb)
local rightClimb = hum:LoadAnimation(script.RightClimb)

local old_dir = 1

local hitbox = Instance.new("Part", workspace)
hitbox.Name = "Hitbox"
hitbox.CanCollide = false
hitbox.Massless = true
hitbox.Anchored = false
hitbox.Transparency = 1
hitbox.Size = Vector3.new(3,3,3)
hitbox.CFrame = head.CFrame * CFrame.new(0, .5, -.75)

local weld = Instance.new("WeldConstraint", head)
weld.Part0 = head
weld.Part1 = hitbox

function freezeChar(bool)
	cooldown = true
	task.delay(0.25, function()
		cooldown = false
	end)
	
	climbBind:Fire(bool, false)
	if bool then
		hum:ChangeState(Enum.HumanoidStateType.Running)
		hrp.Anchored = true
	else
		hum:ChangeState(Enum.HumanoidStateType.Freefall)
		hrp.Anchored = false
		task.delay(0.05, function()
			hrp:ApplyImpulse(-hrp.CFrame.LookVector * 550)
		end)
	end
end

fallBind.Event:Connect(function()
	climbing = false
	climbingPart = false
	freezeChar(false)
end)

hum.StateChanged:Connect(function(old, new)
	if new == Enum.HumanoidStateType.Climbing then
		hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	end
end)

RuS.Heartbeat:Connect(function()
	if climbing then
		
		local hit = hitbox:GetTouchingParts()
		for i, t in pairs(hit) do
			if t:HasTag("FLOOR") then
				climbing = false
				climbDeb = true
				task.delay(0.5, function()
					climbDeb = false
				end)

				freezeChar(false)
			end
		end
		
		for i, v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") then
				local touching = v:GetTouchingParts()
				
				for m, r in pairs(touching) do
					if r:HasTag("FLOOR") then
						climbing = false
						climbDeb = true
						task.delay(0.5, function()
							climbDeb = false
						end)
						
						freezeChar(false)
					end
				end
			end
		end
		
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
			raycastParams.FilterDescendantsInstances = workspace:GetDescendants()

			local result = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 5, raycastParams)

			if result and result.Instance and not climbDeb then
				climbDeb = true
				task.delay(0.05, function()
					climbDeb = false
				end)
				
				if result and result.Instance and result.Instance:HasTag("WALL") then
					climbingPart = result.Instance

					local normal = result.Normal
					local hitPos = result.Position

					local combinedOffset = offset

					local up = Vector3.new(0, 1, 0)
					local right = up:Cross(normal).Unit
					local forward = normal

					if right.Magnitude < 0.01 then
						right = Vector3.new(1, 0, 0)
					end

					local realUp = normal:Cross(right).Unit

					local pos = hitPos + (right * combinedOffset.X) + (realUp * combinedOffset.Y) + (forward * 1)

					local targetCF = CFrame.fromMatrix(pos, right, realUp, forward)
					
					local x, y = offset.X, offset.Y
					
					local dir
					if (targetCF.Position - hrp.Position).Magnitude < (climbFac - 0.5) then
						dir = old_dir
					else
						dir =
							(y > 0 and 1) or
							(x > 0 and 2) or
							(x < 0 and 3) or
							(y < 0 and 4) or
							1
						old_dir = dir
					end
					
					local track = upClimb
					if dir == 1 then
						track = upClimb
					elseif dir == 2 then
						track = rightClimb
					elseif dir == 3 then
						track = leftClimb
					else
						track = downClimb
					end
					
					if upClimb.IsPlaying then
						if upClimb ~= track then
							upClimb:Stop()
						end
					end
					if rightClimb.IsPlaying then
						if rightClimb ~= track then
							rightClimb:Stop()
						end
					end
					if leftClimb.IsPlaying then
						if leftClimb ~= track then
							leftClimb:Stop()
						end
					end
					if downClimb.IsPlaying then
						if downClimb ~= track then
							downClimb:Stop()
						end
					end
					
					if (targetCF.Position - hrp.Position).Magnitude < (climbFac - 0.5) then
						climbBind:Fire(false, true)
						track:AdjustSpeed(0)
					else
						climbBind:Fire(true, false)
						if upClimb.IsPlaying or downClimb.IsPlaying then
							track:AdjustSpeed(0.5)
						else
							track:AdjustSpeed(1)
						end
						
						if rightClimb.IsPlaying then
							track:AdjustSpeed(-0.5)
						elseif leftClimb.IsPlaying then
							track:AdjustSpeed(0.5)
						end
					end
					
					if not track.IsPlaying then
						track:Play()
					end
					
					climbEvent:FireServer(targetCF)
				end
			elseif not result or not result.Instance then
				climbing = false
				climbingPart = nil
				freezeChar(false)
			end
		end
	else
		downClimb:Stop()
		rightClimb:Stop()
		leftClimb:Stop()
		upClimb:Stop()
	end
end)

UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.Space then
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = workspace:GetDescendants()

		local result = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 5, raycastParams)
		
		if result and result.Instance and result.Instance:HasTag("WALL") then
			if not cooldown then
				if climbing then
					freezeChar(false)
					
					climbingPart = nil
					climbing = false
				elseif not climbing then
					freezeChar(true)

					climbingPart = result.Instance
					climbing = true
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
