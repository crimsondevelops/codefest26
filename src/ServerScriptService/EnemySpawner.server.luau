local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local enemyFolder = ReplicatedStorage:WaitForChild("Enemies")
local spawnFolder = workspace:WaitForChild("EnemySpawns")
local activeEnemies = workspace:WaitForChild("Enemies")

local spawnDelay = 3
local maxPerSpawn = 3
local spawnRadius = 120

local function getEnemyList()
	local list = {}
	for _, enemy in pairs(enemyFolder:GetChildren()) do
		table.insert(list, enemy)
	end
	return list
end

local function getClosestPlayer(pos)
	local closest
	local closestDist = math.huge

	for _, plr in pairs(Players:GetPlayers()) do
		local char = plr.Character
		if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
			local dist = (pos - char.HumanoidRootPart.Position).Magnitude
			if dist < closestDist then
				closestDist = dist
				closest = char
			end
		end
	end

	return closest, closestDist
end

local function countNearbyEnemies(pos, radius)
	local count = 0

	for _, enemy in pairs(activeEnemies:GetChildren()) do
		local hrp = enemy:FindFirstChild("HumanoidRootPart")
		local hum = enemy:FindFirstChild("Humanoid")

		if hrp and hum and hum.Health > 0 then
			if (hrp.Position - pos).Magnitude <= radius then
				count += 1
			end
		end
	end

	return count
end

local function spawnEnemyAt(spawnPart)
	local enemies = getEnemyList()
	if #enemies == 0 then return end

	local chosen = enemies[math.random(1, #enemies)]:Clone()
	chosen:PivotTo(spawnPart.CFrame)
	chosen.Parent = activeEnemies
end

task.spawn(function()
	while true do
		task.wait(spawnDelay)

		for _, spawnPart in pairs(spawnFolder:GetChildren()) do
			local player, dist = getClosestPlayer(spawnPart.Position)

			if player and dist <= spawnRadius then
				local nearby = countNearbyEnemies(spawnPart.Position, 60)

				if nearby < maxPerSpawn then
					spawnEnemyAt(spawnPart)
					task.wait(0.5)
				end
			end
		end
	end
end)