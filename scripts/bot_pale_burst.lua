--Sawed down version of bot_monochrome_logic.lua, Here so his burst shotgun logic can be used on smaller robots.
local function removeCallbacks(player, callbacks)
	if not IsValid(player) then
		return
	end

	for _, callbackId in pairs(callbacks) do
		player:RemoveCallback(callbackId)
	end
end

function PaleBurstLogic(_, activator)

	local PASSIVE_RELOAD_SPEED_FACTOR = 0.8	
	local primary = activator:GetPlayerItemBySlot(0)
	local secondary = activator:GetPlayerItemBySlot(1)	
	local clipBonusMult = primary:GetAttributeValueByClass("mult_clipsize", 1)

	local clipBonusAtomic = primary:GetAttributeValueByClass("mult_clipsize_upgrade_atomic", 0)

	local maxClip = (4 * clipBonusMult) + clipBonusAtomic	
		
	local reloadDuration = ((((maxClip - 1) * 0.8) + 0.92) * primary:GetAttributeValueByClass("fast_reload", 1)) * PASSIVE_RELOAD_SPEED_FACTOR;

	local callbacks = {}

	local check

	local terminated = false


	local function terminate()
		if terminated then
			return
		end

		terminated = true

		timer.Stop(check)
		removeCallbacks(activator, callbacks)

	end

	check = timer.Create(0.015, function()

		if not IsValid(activator) or not activator:IsAlive() then
			terminate()
			return
		end				

			--print(primary.m_iClip1)
			if primary.m_iClip1 == 0 then	
				activator:WeaponSwitchSlot(1)	
				secondary:SetAttributeValue("disable weapon switch", 1)	
				primary.m_iClip1 = maxClip
				--print("Reloaded Primary")
					if activator.m_hActiveWeapon ~= primary then
						--print("our clip is low!")
						timer.Simple(reloadDuration, function()	
							secondary:SetAttributeValue("disable weapon switch", 0)							
							activator:WeaponSwitchSlot(0)
							--print("Switched to Primary")			
						end, 1)
					end
			end		
	end, 0)	
	
	
	callbacks.died = activator:AddCallback(ON_DEATH, function()
		terminate()
	end)
	callbacks.removed = activator:AddCallback(ON_REMOVE, function()
		terminate()
	end)
	callbacks.spawned = activator:AddCallback(ON_SPAWN, function()
		terminate()
	end)	
end