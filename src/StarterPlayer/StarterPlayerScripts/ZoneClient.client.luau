local TS = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

local RS = game:GetService("ReplicatedStorage")
local Events = RS:WaitForChild("Events")
local zoneEvent = Events:WaitForChild("ZoneEvent")

local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui

local mainGui = playerGui:WaitForChild("MainGui")
local areaF = mainGui:WaitForChild("Area")
local title = areaF:WaitForChild("Title")

zoneEvent.OnClientEvent:Connect(function(name)
	local ross = workspace.NPCs.Ross
	if ross.HumanoidRootPart:FindFirstChild("Beam") then
		ross.HumanoidRootPart.Beam:D
	end
	
	areaF.Visible = true
	title.Text = "- "..name.." -"
	
	areaF.Position = UDim2.new(0.26, 0, -0.3, 0)
	local t1 = TS:Create(areaF, tweenInfo, {Position = UDim2.new(0.26, 0, 0, 0)})
	t1:Play()
	
	task.delay(1.5, function()
		local t1 = TS:Create(areaF, tweenInfo, {Position = UDim2.new(0.26, 0, -0.3, 0)})
		t1:Play()
		
		task.delay(.5, function()
			areaF.Visible = false
		end)
	end)
end)