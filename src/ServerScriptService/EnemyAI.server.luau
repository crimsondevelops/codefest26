local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

function createHitbox(char, size, collision, anchor, name, massless, transparency)
	size = size or Vector3.new(6,6,6)
	collision = false
	anchor = false
	name = name or "Hitbox-" .. char.Name
	massless = true
	transparency = 1

	local hitNew = Instance.new("Part")
	hitNew.Name = name
	hitNew.Size = size
	hitNew.CanCollide = collision
	hitNew.Anchored = anchor
	hitNew.Massless = massless
	hitNew.Transparency = transparency
	hitNew.CFrame = char.HumanoidRootPart.CFrame
	hitNew.Parent = char

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hitNew
	weld.Part1 = char.HumanoidRootPart
	weld.Parent = hitNew

	return hitNew
end

local function getClosestTarget(hrp, range)
	local closest
	local closestDist = math.huge

	for _, plr in pairs(Players:GetPlayers()) do
		local char = plr.Character
		if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
			local dist = (hrp.Position - char.HumanoidRootPart.Position).Magnitude
			if dist < closestDist then
				closestDist = dist
				closest = char
			end
		end
	end

	if closestDist <= range then
		return closest, closestDist
	end
end

local function spawnEnemy(name, position)
	local template = RS.Enemies:FindFirstChild(name)
	if not template then return end
	local clone = template:Clone()
	clone:PivotTo(CFrame.new(position))
	clone.Parent = workspace.Enemies
end

local function runEnemy(enemy)
	local hum = enemy:WaitForChild("Humanoid")
	local hrp = enemy:WaitForChild("HumanoidRootPart")

	local moduleScript = script:FindFirstChild(enemy.Name)
	if not moduleScript then return end
	local data = require(moduleScript)

	if enemy.Name == "Tank" then
		hum.MaxHealth = hum.MaxHealth * 2
		hum.Health = hum.MaxHealth
	end

	if enemy.Name == "Cloaker" then
		task.spawn(function()
			while hum.Health > 0 do
				hum.WalkSpeed = math.random(26, 36)
				task.wait(math.random(1,3))
			end
		end)
	end

	local animTrack
	if data.Animation then
		local anim = Instance.new("Animation")
		anim.AnimationId = data.Animation
		animTrack = hum:LoadAnimation(anim)
		animTrack.Priority = Enum.AnimationPriority.Action3
	end

	local cooldown = false
	local lastWander = 0
	local wanderPos

	local function wander()
		if tick() - lastWander < 3 then return end
		lastWander = tick()
		local offset = Vector3.new(math.random(-40,40),0,math.random(-40,40))
		wanderPos = hrp.Position + offset
		hum:MoveTo(wanderPos)
	end

	local function melee(target)
		if cooldown then return end
		cooldown = true

		if animTrack then
			animTrack.Looped = false
			animTrack:Play()
		end

		local hitbox = createHitbox(enemy)
		local conn

		conn = hitbox.Touched:Connect(function(hit)
			if not hit.Parent then conn:Disconnect() return end
			local h = hit.Parent:FindFirstChild("Humanoid")
			if h and hit.Parent ~= enemy and Players:GetPlayerFromCharacter(hit.Parent) then
				h:TakeDamage(data.Damage or 10)
				conn:Disconnect()
				hitbox:Destroy()
			end
		end)

		task.delay(0.4, function()
			if hitbox then hitbox:Destroy() end
		end)

		task.delay(data.Cooldown or 2, function()
			cooldown = false
		end)
	end

	local function ranged(target)
		if cooldown then return end
		cooldown = true

		if animTrack then
			animTrack.Looped = false
			animTrack:Play()
		end

		local luger = enemy:FindFirstChild("Luger")
		if luger and luger:FindFirstChild("Handle") then
			local handle = luger.Handle

			if handle:FindFirstChild("Fire") then
				handle.Fire:Play()
			end

			if handle:FindFirstChild("Muzzle") and handle.Muzzle:FindFirstChild("Effect") then
				handle.Muzzle.Effect:Emit(1)
			end

			local rayParams = RaycastParams.new()
			rayParams.FilterDescendantsInstances = {enemy}
			rayParams.FilterType = Enum.RaycastFilterType.Exclude

			local dir = (target.HumanoidRootPart.Position - handle.Position).Unit * 300
			local result = workspace:Raycast(handle.Position, dir, rayParams)

			if result and result.Instance then
				local h = result.Instance.Parent:FindFirstChild("Humanoid")
				if h and Players:GetPlayerFromCharacter(result.Instance.Parent) then
					h:TakeDamage(data.Damage)
				end
			end
		end

		task.delay(data.Cooldown or 2, function()
			cooldown = false
		end)
	end

	local function summon(target)
		if cooldown then return end
		cooldown = true

		if animTrack then
			animTrack.Looped = false
			animTrack:Play()
		end
		hum.WalkSpeed = 0
		task.wait(1)
		hum.WalkSpeed = 16

		local amount = 2
		for i = 1, amount do
			local offset = Vector3.new(math.random(-10,10),0,math.random(-10,10))
			spawnEnemy("Cultist", hrp.Position + offset)
		end

		task.delay(data.Cooldown or 8, function()
			cooldown = false
		end)
	end

	task.spawn(function()
		hum.BreakJointsOnDeath = false
		while hum.Health > 0 do
			task.wait(0.2)

			local target, dist = getClosestTarget(hrp, 80)

			if target and enemy.Name == "Invoker" then
				local gyro = hrp:FindFirstChild("InvokerGyro")
				if not gyro then
					gyro = Instance.new("BodyGyro")
					gyro.Name = "InvokerGyro"
					gyro.MaxTorque = Vector3.new(0, math.huge, 0)
					gyro.P = 20000
					gyro.Parent = hrp
				end
				local look = CFrame.lookAt(hrp.Position, Vector3.new(target.HumanoidRootPart.Position.X, hrp.Position.Y, target.HumanoidRootPart.Position.Z))
				gyro.CFrame = look
			end

			if not target then
				wander()
				continue
			end

			if data.Type == "Defensive" then
				local allies = {}
				for _, e in pairs(workspace.Enemies:GetChildren()) do
					if e ~= enemy and e:FindFirstChild("HumanoidRootPart") and e:FindFirstChild("Humanoid") and e.Humanoid.Health > 0 then
						table.insert(allies, e)
					end
				end

				local allyCenter = hrp.Position
				if #allies > 0 then
					local sum = Vector3.zero
					for _, a in pairs(allies) do
						sum += a.HumanoidRootPart.Position
					end
					allyCenter = sum / #allies
				end

				local playerPos = target.HumanoidRootPart.Position
				local dir = (playerPos - allyCenter).Unit
				local desired = playerPos - dir * 20

				hum:MoveTo(desired)
				if dist < 60 then
					summon(target)
				end
			end

			if data.Type == "Offensive" then
				if data.Class == "Melee" then
					hum:MoveTo(target.HumanoidRootPart.Position)

					if dist < 9 then
						melee(target)
					end
				else
					if dist > 25 and enemy.Name ~= "Tank" then
						hum:MoveTo(target.HumanoidRootPart.Position)
					elseif enemy.Name == "Tank" and dist > 15 then
						
					else
						hum:MoveTo(hrp.Position)
						ranged(target)
					end
				end
			end
		end

		if hum.Health <= 0 then
			pcall(function()
				for index,joint in pairs(script.Parent:GetDescendants()) do
					if joint:IsA("Motor6D") then
						local socket = Instance.new("BallSocketConstraint")
						local a1 = Instance.new("Attachment")
						local a2 = Instance.new("Attachment")
						a1.Parent = joint.Part0
						a2.Parent = joint.Part1
						socket.Parent = joint.Parent
						socket.Attachment0 = a1
						socket.Attachment1 = a2
						a1.CFrame = joint.C0
						a2.CFrame = joint.C1
						socket.LimitsEnabled = true
						socket.TwistLimitsEnabled = true
						joint:Destroy()
					end
				end
			end)

			task.wait(3)

			if enemy.Name == "Invoker" then
				if math.random(1, 3) == 3 then
					local drops = RS:WaitForChild("Drops")
					local luger = drops.Luger:Clone()
					luger.Parent = workspace
					luger.Root.CFrame = hrp.CFrame
				end
			end

			enemy:Destroy()
		end
	end)
end

local function register(enemy)
	task.spawn(function()
		runEnemy(enemy)
	end)
end

for _, enemy in pairs(workspace.Enemies:GetChildren()) do
	register(enemy)
end

workspace.Enemies.ChildAdded:Connect(function(enemy)
	task.wait(0.2)
	register(enemy)
end)