local dialogue = {}

local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local Queue = {}
local Active = false
local Input = false

local function CreateText(text, dialogueGui, speed, richtext)
	dialogueGui.Title.RichText = richtext
	for i = 1, #text do
		local letter = string.sub(text, i, i)
		dialogueGui.Title.Text = dialogueGui.Title.Text .. letter
		script.sound:Play()

		if letter == "." or letter == "," or letter == "!" or letter == "?" then
			task.wait(0.5)
		else
			task.wait(0.05)
		end
		
		if Input then
			dialogueGui.Title.Text = text
			break
		end

		script.sound:Stop()
	end
	task.wait(speed)
	return true
end

local function ProcessQueue()
	if Active then return end
	Active = true
	Input = false

	task.spawn(function()
		local dialogueGui = player.PlayerGui:WaitForChild("DialogueGui")
		local main = dialogueGui:WaitForChild("Main")
		local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local characterHumanoid = character:WaitForChild("Humanoid")

		main.Position = UDim2.new(0.32, 0, 1.2, 0)
		local enterTween = TS:Create(main, tweenInfo, {Position = UDim2.new(0.32, 0, 0.687, 0), Rotation = 0})
		enterTween:Play()

		while #Queue > 0 do
			local currentDialogue = table.remove(Queue, 1)

			characterHumanoid.WalkSpeed = 0

			main.NameLabel.Text = currentDialogue.speaker
			main.Visible = true
			main.Title.Text = ""

			local info = CreateText(currentDialogue.text, main, 1, currentDialogue.richtext)
			if info == true then
				main.Continue.Visible = true

				local continueClicked = false
				local conn
				conn = main.Continue.MouseButton1Click:Connect(function()
					Input = false
					continueClicked = true
					conn:Disconnect()
				end)

				repeat task.wait(0.1) until continueClicked
				main.Continue.Visible = false
			end
		end

		local leaveTween = TS:Create(main, tweenInfo, {Position = UDim2.new(0.32, 0, 1.2, 0), Rotation = 0})
		leaveTween:Play()

		characterHumanoid.WalkSpeed = 12

		Active = false
	end)
end

function dialogue.CreateDialogue(text, speaker, richtext)
	table.insert(Queue, {text = text, speaker = speaker, richtext = richtext})
	ProcessQueue()
end

UIS.InputBegan:Connect(function(input, gpe)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if Input == false then
			Input = true
			task.wait(0.05)
			input = false
		end
	end
end)

return dialogue
