local SPELL_GEN_INTERVAL = 5
local CHARGES = 6

local POSSIBLE_COMMONS = {
	"Fireball",
	"Pumpkin MIRV",
	"Superjump",
}

local POSSIBLE_RARES = {
	"Summon Monoculus",
	"Meteor Shower",
	"Summon Skeletons",
}

function AddRandomSpell(rareWeight, activator)
	local gen = math.random(1, 100)

	if gen <= tonumber(rareWeight) then
		local chosenSpell = POSSIBLE_RARES[math.random(#POSSIBLE_RARES)]
		print(chosenSpell)
		activator:AddSpell(chosenSpell)
	else
		local chosenSpell = POSSIBLE_COMMONS[math.random(#POSSIBLE_COMMONS)]
		print(chosenSpell)
		activator:AddSpell(chosenSpell)
	end
end