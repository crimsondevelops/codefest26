local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
	local template = ReplicatedStorage.Enemies:FindFirstChild(name)
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
			animTrack:Play()
		end

		local hitbox = createHitbox(enemy)
		local conn

		conn = hitbox.Touched:Connect(function(hit)
			local h = hit.Parent:FindFirstChild("Humanoid")
			if h and hit.Parent ~= enemy then
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
			animTrack:Play()
		end

		local luger = enemy:FindFirstChild("Luger")
		if luger and luger:FindFirstChild("Handle") then
			local handle = luger.Handle

			if handle:FindFirstChild("Fire") then
				handle.Fire:Play()
			end

			if handle:FindFirstChild("Muzzle") and handle.Muzzle:FindFirstChild("Emitter") then
				handle.Muzzle.Emitter:Emit(1)
			end

			local rayParams = RaycastParams.new()
			rayParams.FilterDescendantsInstances = {enemy}
			rayParams.FilterType = Enum.RaycastFilterType.Exclude

			local dir = (target.HumanoidRootPart.Position - handle.Position).Unit * 300
			local result = workspace:Raycast(handle.Position, dir, rayParams)

			if result and result.Instance then
				local h = result.Instance.Parent:FindFirstChild("Humanoid")
				if h then
					if math.random(1, 2) == 2 then
						h:TakeDamage(data.Damage)
					end
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
			animTrack:Play()
		end

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
		while hum.Health > 0 do
			task.wait(0.2)

			local target, dist = getClosestTarget(hrp, 80)

			if not target then
				wander()
				continue
			end

			if data.Type == "Defensive" then
				if dist < 40 then
					local flee = (hrp.Position - target.HumanoidRootPart.Position).Unit * 25
					hum:MoveTo(hrp.Position + flee)
					summon(target)
				else
					hum:MoveTo(target.HumanoidRootPart.Position)
				end
			end

			if data.Type == "Offensive" then
				if data.Class == "Melee" then
					hum:MoveTo(target.HumanoidRootPart.Position)

					if dist < 9 then
						melee(target)
					end
				else
					if dist > 25 then
						hum:MoveTo(target.HumanoidRootPart.Position)
					else
						hum:MoveTo(hrp.Position)
						ranged(target)
					end
				end
			end
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
