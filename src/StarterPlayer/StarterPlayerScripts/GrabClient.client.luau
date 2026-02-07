if not game:IsLoaded() then game.Loaded:Wait() end
local RuS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local SG = game:GetService("StarterGui")

local Items = RS:WaitForChild("Items")

local Modules = RS:WaitForChild("Modules")
local itemModule = require(Modules.ItemModule)

local Events = RS:WaitForChild("Events")
local equipEvent = Events:WaitForChild("EquipEvent")
local destroyEvent = Events:WaitForChild("DestroyEvent")

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

local mouse = player:GetMouse()

local highlight = script:WaitForChild("Highlight")
local displayGui = script:WaitForChild("DisplayGUI")
displayGui.Parent = player.PlayerGui

local displayTXT = displayGui:WaitForChild("DisplayTXT")
local titleTXT = displayGui:WaitForChild("TitleTXT")

local hoverItem = nil

itemModule.Anims(player)
SG:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

RuS.Heartbeat:Connect(function()
	if mouse.Target then
		local pos = mouse.Target.Position
		local hrpPos = hrp.Position
		local distance = (hrpPos - pos).Magnitude
		
		if distance < 10 then
			local root = mouse.Target
			local item = root.Parent

			if item and item:HasTag("ITEM") then
				hoverItem = item
				displayTXT.Text = item.Name
				highlight.Adornee = item
				displayGui.Adornee = item
				displayGui.Enabled = true
			else
				hoverItem = nil
				displayGui.Enabled = false
				displayGui.Adornee = nil
				highlight.Adornee = nil
			end
		else
			hoverItem = nil
			displayGui.Enabled = false
			displayGui.Adornee = nil
			highlight.Adornee = nil
		end
	else
		hoverItem = nil
		displayGui.Enabled = false
		displayGui.Adornee = nil
		highlight.Adornee = nil
	end
end)

UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	
	if input.KeyCode == Enum.KeyCode.E then
		if hoverItem then
			destroyEvent:FireServer(hoverItem)
			
			local name = hoverItem.Name
			local tool = Items:FindFirstChild(name)
			
			if tool then
				equipEvent:FireServer(tool, hum,)
				
				if not char:FindFirstChild(name) then char.ChildAdded:Wait() end
				local clone = char:FindFirstChild(name)
				
				if clone then
					clone.Activated:Once(function()
						itemModule.Load(player, clone)
					end)
				end
			end
			
			hoverItem = nil
		end
	end
end)