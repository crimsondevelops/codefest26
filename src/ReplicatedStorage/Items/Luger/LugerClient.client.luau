local tool = script.Parent
local player = game.Players.LocalPlayer
local shootEvent = tool:WaitForChild("ShootEvent")
local handle = tool:WaitForChild("Handle")
local shootAnim = handle:WaitForChild("Shoot")

local mouse
local humanoid
local track
local canShoot = true
local fireDelay = 0

tool.Equipped:Connect(function(m)
	mouse = m
	local char = player.Character or player.CharacterAdded:Wait()
	humanoid = char:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")
	track = animator:LoadAnimation(shootAnim)
	track.Looped = false
end)

tool.Activated:Connect(function()
	if not canShoot then return end
	canShoot = false

	if track then
		track:Play()
	end

	if mouse then
		shootEvent:FireServer(mouse.Hit.Position)
	end

	task.wait(fireDelay)
	canShoot = true
end)
