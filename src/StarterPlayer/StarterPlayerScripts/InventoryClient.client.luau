local TS = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")

local Modules = RS:WaitForChild("Modules")
local itemModule = require(Modules.ItemModule)

local Items = RS:WaitForChild("Items")
local Events = RS:WaitForChild("Events")
local equipEvent = Events:WaitForChild("EquipEvent")

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
		if player.Backpack:FindFirstChild(slot.Title.Text) then
			local item = Items:FindFirstChild(slot.Title.Text)
			equipEvent:FireServer(item, hum, true)
			
			task.delay(0.05, function()
				local clone = player.Character:FindFirstChildOfClass("Tool")
				clone.Activated:Once(function()
					itemModule.Load(player, clone)
				end)
			end)
		end
		
		local tween = TS:Create(slot, btnInfo, {Size = UDim2.new(0.9, 0, 0.95, 0)})
		tween:Play()
		
		task.wait(0.15)
		
		local tween = TS:Create(slot, btnInfo, {Size = UDim2.new(0.342, 0, 0.88, 0)})
		tween:Play()
	end)
end

char.ChildRemoved:Connect(function(child)
	if child:IsA("Tool") then
		if slots[1].Title.Text == child.Name then
			slots[1].Title.Text = "None"
			slots[1].Img.Image = ""
		elseif slots[2].Title.Text == child.Name then
			slots[2].Title.Text = "None"
			slots[2].Img.Image = ""
		elseif slots[3].Title.Text == child.Name then
			slots[3].Title.Text = "None"
			slots[3].Img.Image = ""
		end
	end
end)

player.Backpack.ChildAdded:Connect(function(child)
	if child:IsA("Tool") then
		if slots[1].Title.Text == "None" then
			slots[1].Title.Text = child.Name
			slots[1].Img.Image = child.TextureId
		elseif slots[2].Title.Text == "None" then
			slots[2].Title.Text = child.Name
			slots[2].Img.Image = child.TextureId
		elseif slots[3].Title.Text == "None" then
			slots[3].Title.Text = child.Name
			slots[3].Img.Image = child.TextureId
		end
	end
end)