--Sawed down version of bot_monochrome_logic.lua, Here so his burst shotgun logic can be used on smaller robots.


--Legacy functions, OPaleBurstLogicOnAttack is the more optimized, better version
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
		if primary ~= nil then
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



function PaleBurstLogicMangler(_, activator)

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
		if primary ~= nil then
			--print(primary.m_flEnergy)
			if primary.m_flEnergy == 0 then	
				activator:WeaponSwitchSlot(1)	
				secondary:SetAttributeValue("disable weapon switch", 1)	
				primary.m_flEnergy = maxClip * 5
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


--Substantially more optimized than the fuckers above, only time I could think that this would be inferior in performance to the others
--is if you're using a blackbox with a really really large clip, and if that is the case there is nothing stopping you from using the legacy functions.

--Other application of the above functions is if you have some funky custom thing that depletes people's clips to 0 (and only to 0, if it reduces to a minimum of 1, there's no point) 
function paleBurstLogicOnAttack(param, activator, caller)
	--Shouldn't be possible for primary to be nil, given that the rocket launcher would need to fire to invoke this.
	local primary = activator:GetPlayerItemBySlot(0)

	--If you're not at 0, we don't care, this is what makes this orders of magnitude more optimized than the previous version. We
	--aren't checking if the clip is 0 every tick, and as a result, we don't need to check if the bot is alive every tick either.
	
	--bot_reserve_combo.lua could probably be optimized in a similar way, but that would result in functionality loss, and the gameplay concept of it
	--is a piece of shit anyway.
	if primary.m_iClip1 ~= 0 then
		return
	end
	
	--Pale bursts will cheat a bit when reloading to come up faster, was made with monochrome in mind (who was a gigaburst boss)
	--as a small punishment for making him expend his full clip rather than circle him or something. The pale bursts inherit this, could
	--probably put this on a colonel to make it more significant.
	local PASSIVE_RELOAD_SPEED_FACTOR = 0.8	
	
	local secondary = activator:GetPlayerItemBySlot(1)	
	local clipBonusMult = primary:GetAttributeValueByClass("mult_clipsize", 1)
	local clipBonusAtomic = primary:GetAttributeValueByClass("mult_clipsize_upgrade_atomic", 0)

	local maxClip = (4 * clipBonusMult) + clipBonusAtomic	
		
	--Hardcoded soldier rocket launcher constants, first rocket takes 0.92 flat, every subsequent rocket takes 0.8. This is then all
	--multiplied by reload attributes present on the bot, and then the passive reload speed factor
	local reloadDuration = ((((maxClip - 1) * 0.8) + 0.92) * primary:GetAttributeValueByClass("fast_reload", 1)) * PASSIVE_RELOAD_SPEED_FACTOR
	
	
	--If our clip is 0, switch to our secondary, and make it impossible to switch back, and silently reload our launcher. Wait reloadDuration seconds, then make it
	--possible to switch back, then force the bot to switch anyway.
	--So we've done that barrage of variable calculations above to determine how long the script should wait to make the bot switch back to their launcher, and nothing more.
	activator:WeaponSwitchSlot(1)	
	secondary:SetAttributeValue("disable weapon switch", 1)	
	primary.m_iClip1 = maxClip
	--print("Reloaded Primary")
	timer.Simple(reloadDuration, function()	
		secondary:SetAttributeValue("disable weapon switch", 0)							
		activator:WeaponSwitchSlot(0)
		--print("Switched to Primary")			
	end, 1)	
	
end





































