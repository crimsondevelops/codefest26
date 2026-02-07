local module = {}

function module.Load(player:Player, tool:Tool)
	local typ = tool:GetAttribute("type")
	
	if typ then
		local typModule = script:FindFirstChild(typ)
		
		if typModule then
			local required = require(typModule)
			required.Init(player, tool)
		end
	end
end

function module.Anims(player:Player)
	for i, typModule in pairs(script:GetChildren()) do
		if typModule then
			local required = require(typModule)
			required.Load(player)
		end
	end
end


return module
