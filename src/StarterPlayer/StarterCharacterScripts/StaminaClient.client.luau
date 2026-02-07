local UIS = game:GetService("UserInputService")
local RuS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")

local Events = RS:WaitForChild("Events")
local climbBind = Events:WaitForChild("ClimbBind")
local fallBind = Events:WaitForChild("ClimbFallBind")

local player = game.Players.LocalPlayer
local camera = workspace.Camera

local char = player.Character or player.CharacterAdded:Wait()
local hum:Humanoid = char:WaitForChild("Humanoid")
local hrp:BasePart = char:WaitForChild("HumanoidRootPart")

local sprintAnim = script:WaitForChild("Sprint")
local track = hum:LoadAnimation(sprintAnim)
track:AdjustSpeed(0.5)
track.Looped = true
track.Priority = Enum.AnimationPriority.Movement

local stamina = 100
local walkSpeed = 12
local sprintSpeed = 34

local sprintHold = false
local sprinting = false
local runout = false

local climbing = false
local climbPaused = false

local refresh = 2
local drain = 20

local staminaGui = script:WaitForChild("Stamina")
local holder = staminaGui:WaitForChild("Holder")
local max = holder:WaitForChild("Max")
local current = max:WaitForChild("Current")

local healthGui = script:WaitForChild("Health")

if char then
	staminaGui.Parent = char
	healthGui.Parent = char
else
	player.CharacterAdded:Wait()
	staminaGui.Parent = char
	healthGui.Parent = char
end

local function update()
	local now = tick()
	local height = math.sin(now) / 4

	hum.CameraOffset = Vector3.new(0, height, 0)
end

RuS.RenderStepped:Connect(update)

climbBind.Event:Connect(function(bool, paused)
	climbing = bool
	
	if paused ~= nil then
		climbPaused = paused
	end
end)

local function zoom(bool)
	if bool then
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
		local tween = TS:Create(camera, tweenInfo, {FieldOfView = 70})
		tween:Play()
	else
		local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
		local tween = TS:Create(camera, tweenInfo, {FieldOfView = 60})
		tween:Play()
	end
end
zoom(true)

local function sprint(bool)
	if bool then
		zoom(true)
		track:Play(.5)
		hum.WalkSpeed = sprintSpeed
	else
		zoom(false)
		track:Stop(.5)
		hum.WalkSpeed = walkSpeed
	end
	
	local sound:Sound = hrp:FindFirstChild("Running")
	sound.PlaybackSpeed = bool and 1.5 or 1
	
	sprinting = bool
end

UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	
	if input.KeyCode == Enum.KeyCode.LeftShift then
		if not climbing then
			sprintHold = true
		end
		
		if hrp.AssemblyLinearVelocity.Magnitude > 0.1 then
			if not climbing then
				if stamina > 5 then
					sprint(true)
				end
			end
		end
	end
end)

UIS.InputEnded:Connect(function(input, gpe)
	if gpe then return end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		sprintHold = false
		sprint(false)
	end
end)

RuS.Heartbeat:Connect(function(dt)
	if sprinting or climbing then
		if stamina > 0 then
			if climbing then
				stamina = stamina - (drain / 2) * dt
			else
				stamina = stamina - (drain / 1.5) * dt
			end
			
			local diff = (100-stamina) / 100
			current.Position = UDim2.new(0, 0, diff, 0)
		else
			if climbing then fallBind:Fire() end
			sprint(false)
			runout = true
		end
	elseif stamina < 100 then
		if not runout then
			if not climbing and not climbPaused then
				stamina = stamina + (drain / 1.5) * dt
			end

			local diff = (100 - stamina) / 100
			current.Position = UDim2.new(0, 0, diff, 0)
			
			if sprintHold and not climbing then
				sprint(sprintHold)
			end
		else
			task.delay(refresh, function()
				runout = false
			end)
		end
	end
	
	if stamina < 100 then
		staminaGui.Enabled = true
	else
		staminaGui.Enabled = false
	end
	
	if sprinting and climbing then
		sprint(false)
	end
	
	-- health stuff
	if hum.Health < 100 then
		healthGui.Enabled = true
	else
		healthGui.Enabled = false
	end
	
	local diff = (100 - hum.Health) / 100
	healthGui.Holder.Max.Current.Position = UDim2.new(0, 0, diff, 0)
end)