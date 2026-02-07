local TS = game:GetService("TweenService")

local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)
local btnInfo = TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)

local player = game.Players.LocalPlayer
local backpack = player.Backpack

local char = player.Character or player.CharacterAdded:Wait()
local hum:Humanoid = char:WaitForChild("Humanoid")

local playerGui = player.PlayerGui
local mainGui = playerGui:WaitForChild("MainGui")
local holder = mainGui:WaitForChild("Holder")
local slots = {
	[1] = holder.Slot1,
	[2] = holder.Slot2,
	[3] = holder.Slot3,
}

for i, slot in pairs(slots) do
	slot.MouseEnter:Connect(function()
		local tween = TS:Create(slot, tweenInfo, {Size = UDim2.new(1, 0, 1, 0)})
		tween:Play()
		
		slot.Title.Visible = true
	end)
	
	slot.MouseLeave:Connect(function()
		local tween = TS:Create(slot, tweenInfo, {Size = UDim2.new(0.342, 0, 0.88, 0)})
		tween:Play()
		
		slot.Title.Visible = false
	end)
	
	slot.Btn.Activated:Connect(function()
		local tween = TS:Create(slot, btnInfo, {Size = UDim2.new(0.9, 0, 0.95, 0)})
		tween:Play()
		
		task.wait(0.15)
		
		local tween = TS:Create(slot, btnInfo, {Size = UDim2.new(0.342, 0, 0.88, 0)})
		tween:Play()
	end)
end

backpack.ChildAdded:Connect(function(child)
	if child:IsA("Tool") then
		if slots[1].Title.Text == "Label" then
			slots[1].Title.Text = child.Name
		elseif slots[2].Title.Text == "Label" then
			slots[2].Title.Text = child.Name
		elseif slots[3].Title.Text == "Label" then
			slots[3].Title.Text = child.Name
		end
	end
end)