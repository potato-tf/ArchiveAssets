-- requested by drcactus

local shieldCallbacks = {}

function ClearShieldCallbacks(activator, handle)
	if not IsValid(activator) then
		return
	end

	activator.ShieldReplacementFlag = nil

	if not shieldCallbacks[handle] then
		return
	end

	for _, callbackId in pairs(shieldCallbacks[handle]) do
		activator:RemoveCallback(callbackId)
	end
end

function PersonalProjectileShieldRefunded(_, activator)
	ClearShieldCallbacks(activator, activator:GetHandleIndex())
end

function PersonalProjectileShieldPurchase(_, activator)
	print("personal shield purchased")
	local handle = activator:GetHandleIndex()

	-- force it to level 2
	local medigun = activator:GetPlayerItemBySlot(1)
	local medigunHandle = medigun:GetHandleIndex()

	medigun:SetAttributeValue("generate rage on heal", 2)

	activator.ShieldReplacementFlag = true

	shieldCallbacks[handle] = {}

	local callbacks = shieldCallbacks[handle]

	local function clear()
		ClearShieldCallbacks(activator, handle)
	end

	callbacks.removed = activator:AddCallback(ON_REMOVE, function()
		clear()
	end)

	callbacks.died = activator:AddCallback(ON_DEATH, function()
		if medigunHandle == activator:GetPlayerItemBySlot(1):GetHandleIndex() then
			return
		end

		clear()
	end)

	callbacks.spawned = activator:AddCallback(ON_SPAWN, function()
		if medigunHandle == activator:GetPlayerItemBySlot(1):GetHandleIndex() then
			return
		end

		clear()
	end)
end

-- smol shield replacement
function ReplaceAllMedigunShields()
	for _, shield in pairs(ents.FindAllByClass("entity_medigun_shield")) do
		if shield.Changed then
			goto continue
		end

		local shieldOwner = shield.m_hOwnerEntity

		if not shieldOwner or not IsValid(shieldOwner) then
			goto continue
		end

		if not shieldOwner.ShieldReplacementFlag then
			goto continue
		end

		shield.Changed = true

		shield:SetModel("models/props_mvm/mvm_comically_small_player_shield.mdl")

		::continue::
	end
end

function OnGameTick()
	ReplaceAllMedigunShields()
end
