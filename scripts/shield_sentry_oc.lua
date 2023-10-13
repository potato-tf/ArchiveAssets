local DESPAWN_TIME_CONTROL_ATTRIBUTE = "throwable damage"

local SHIELD_OFFSET = 100

local SHIELD_DAMAGE_ABSORB_MULT = 0.8
local SHIELD_DAMAGE_AMMO_REDUCTION_MULT = 0.5

local DESPAWN_TIME_INCREASE_PER_HEALTH_TICK = 10

local function DisableShield(shield)
	shield:SetModel("models/empty.mdl")
end

local function UpdateShieldModel(shield, building)
	local buildingLevel = building.m_iHighestUpgradeLevel

	if building.m_bDisposableBuilding ~= 0 or buildingLevel <= 1 then
		shield:SetModel("models/props_mvm/mvm_comically_small_player_shield.mdl")
	elseif buildingLevel == 2 then
		shield:SetModel("models/props_mvm/mvm_player_shield.mdl")
	else
		shield:SetModel("models/props_mvm/mvm_player_shield2.mdl")
	end
end

local function UpdateSentryShield(shield, building, owner)
	if building.m_bCarried == 1 or building.m_bPlacing == 1 then
		DisableShield(shield)
		return
	end

	local angles = building.m_bPlayerControlled == 1 and owner:GetAbsAngles() or building:GetAbsAngles()
	shield:SetAbsOrigin(building:GetAbsOrigin() + angles:GetForward() * SHIELD_OFFSET)
	shield:SetAbsAngles(angles)

	UpdateShieldModel(shield, building)
end

local function SetupPSGSentry(building, owner)
	local melee = owner:GetPlayerItemBySlot(LOADOUT_POSITION_MELEE)
	local despawnTime = melee:GetAttributeValue(DESPAWN_TIME_CONTROL_ATTRIBUTE) or 8

	local pda = owner:GetPlayerItemBySlot(LOADOUT_POSITION_PDA)
	local healthUpgradeTicks = pda:GetAttributeValue("engy building health bonus") or 1

	despawnTime = despawnTime + (DESPAWN_TIME_INCREASE_PER_HEALTH_TICK * (healthUpgradeTicks - 1))

	local despawnTimestamp = CurTime() + despawnTime

	if building.m_bDisposableBuilding ~= 0 then
		building["$attributeoverride"] = 1
	end

	local shield = ents.CreateWithKeys("entity_medigun_shield", {
		teamnum = owner.m_iTeamNum,
		spawnflags = 1,
	})

	UpdateSentryShield(shield, building, owner)

	building:AddCallback(ON_REMOVE, function()
		shield:Remove()
	end)

	local lastDamageTick = TickCount()
	shield:AddCallback(ON_DAMAGE_RECEIVED_POST, function(_, damageinfo)
		local curTick = TickCount()
		lastDamageTick = curTick

		shield:Color("200 0 100")

		timer.Simple(0.1, function()
			if not IsValid(shield) then
				return
			end

			-- prevents constant flickering on constant damage
			if lastDamageTick ~= curTick then
				return
			end

			shield:Color("255 255 255")
		end)

		if building.m_bDisposableBuilding ~= 0 then
			building.m_iAmmoShells = building.m_iAmmoShells - (damageinfo.Damage * SHIELD_DAMAGE_AMMO_REDUCTION_MULT)
			return
		end

		damageinfo.Damage = damageinfo.Damage * SHIELD_DAMAGE_ABSORB_MULT
		building:TakeDamage(damageinfo)
	end)

	local despawnTimerText

	building:AddCallback(ON_REMOVE, function()
		if despawnTimerText then
			despawnTimerText:Remove()
			despawnTimerText = nil
		end
	end)

	local function newTimerText()
		if despawnTimerText then
			despawnTimerText:Remove()
			despawnTimerText = nil
		end

		if building.m_bCarried == 1 then
			return
		end

		despawnTimerText = ents.CreateWithKeys("point_worldtext", {
			message = tostring(math.floor(despawnTimestamp - CurTime())),
			textsize = 30,
			orientation = 1,
			color = "255 255 255",
		}, true, true)
		despawnTimerText:SetAbsOrigin(building:GetAbsOrigin() + Vector(0, 0, 80))
	end

	local updateLoop
	updateLoop = timer.Create(0.1, function ()
		if not IsValid(building) then
			if updateLoop then
				timer.Stop(updateLoop)
				updateLoop = nil
			end

			return
		end
		newTimerText()
		UpdateSentryShield(shield, building, owner)
	end, 0)


	timer.Create(despawnTime, function()
		if updateLoop then
			timer.Stop(updateLoop)
			updateLoop = nil
		end

		building:RemoveHealth(10000)
	end)
end

function OnPSGSentrySpawn(building)
	local owner = building.m_hBuilder

	local pda = owner:GetPlayerItemBySlot(LOADOUT_POSITION_PDA)

	if not pda:GetAttributeValue("throwable fire speed") then
		return
	end

	timer.Simple(0.1, function ()
		SetupPSGSentry(building, owner)
	end)
end

ents.AddCreateCallback("obj_sentrygun", function(building)
	timer.Simple(0, function()
		OnPSGSentrySpawn(building)
	end)
end)