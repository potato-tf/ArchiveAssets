local ON_CHARGE_HIT_FUNCS = {
	["throwable fire speed"] = function(target, owner)
		target:AddCond(TF_COND_MARKEDFORDEATH, 5)
    end,
}

local AMMO_CONTROL_ATTR = "throwable damage"

local BASE_CLIP = 4

local cowmanglerPlayers = {}

function CustomChargeShotStart(_, activator)
	local handleIndex = activator:GetHandleIndex()
	cowmanglerPlayers[handleIndex] = true
end

function CustomChargeShotStop(_, activator)
	local handleIndex = activator:GetHandleIndex()
	cowmanglerPlayers[handleIndex] = nil
end

ents.AddCreateCallback("tf_projectile_energy_ball", function(ent)
	timer.Simple(0, function ()
		if not IsValid(ent) then
			return
		end

		if ent.m_bChargedShot == 0 then
			return
		end

		local owner = ent.m_hOwnerEntity

		if not cowmanglerPlayers[owner:GetHandleIndex()] then
			return
		end

		local primary = owner:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY)

		ent:AddCallback(ON_SHOULD_COLLIDE, function(_, other)
			if not other:IsPlayer() then
				return
			end

			if other.m_iTeamNum == owner.m_iTeamNum then
				return
			end

			for attributeName, func in pairs(ON_CHARGE_HIT_FUNCS) do
				if primary:GetAttributeValue(attributeName, true) then
					func(other, owner)
				end
			end
		end)

		local ammoCostOverride = primary:GetAttributeValue(AMMO_CONTROL_ATTR)
		if not ammoCostOverride then
			return
		end

		local clipBonusMult = primary:GetAttributeValueByClass("mult_clipsize_upgrade", 1)
		local clipBonusAtomic = primary:GetAttributeValueByClass("mult_clipsize_upgrade_atomic", 0)

		local maxClip = (BASE_CLIP * clipBonusMult) + clipBonusAtomic

		primary.m_flEnergy = (maxClip - ammoCostOverride) * 5
	end)
end)