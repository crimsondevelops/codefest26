local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum:Humanoid = char:WaitForChild("Humanoid")

local dialogue = require(script.DialogueModule)

local Events = RS:WaitForChild("Events")
local dialogueRemote = Events:WaitForChild("DialogueRemote")
local dialogueBind = Events:WaitForChild("DialogueBindable")

dialogueRemote.OnClientEvent:Connect(function(text:string, speaker:string, richtext:boolean)
	dialogue.CreateDialogue(text, speaker, richtext)
end)

dialogueBind.Event:Connect(function(text:string, speaker:string, richtext:boolean)
	dialogue.CreateDialogue(text, speaker, richtext)
end)

for i, npc in pairs(workspace.NPCs:GetChildren()) do
	local hrp:BasePart = npc:WaitForChild("HumanoidRootPart")
	local prompt:ProximityPrompt = hrp:WaitForChild("Prompt")
	
	prompt.Triggered:Connect(function()
		prompt.Enabled = false
		
		if npc.Name == "Ross" then
			dialogue.CreateDialogue("Hey, you just reached huh? There's a reason why I called.", "Ross", false)
			dialogue.CreateDialogue("This place isn't just a random hill station.", "Ross", false)
			dialogue.CreateDialogue("A cult-like group have been creating odd statues and symbols across the mountain.", "Ross", false)
			dialogue.CreateDialogue("You need to investigate, rumors say there might be something related at one of the peaks.", "Ross", false)
			dialogue.CreateDialogue("You'll find the gear needed to climb in one of the canopies, Just remember to stay safe.", "Ross", false)
			dialogue.CreateDialogue("I've evacuated the villagers for safety. Good luck.", "Ross", false)
		end
	end)
end