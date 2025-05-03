--by watermelon
--a bunch of stuff is stolen/inspired by royal, as noted
local gmed = 0
local BOSS_WAVE = 6
local currentwave = 0
local shieldcount = 0
local players = {} --key: player entindex, v: player handle

function OnWaveStart(wave)
	if wave == BOSS_WAVE then
		currentwave = wave
		players = {}
	end
end

--mostly a lot of post wave fail/success cleanup
function OnWaveInit(wave)
	currentwave = 0
	shieldcount = 0

	for _, p in pairs(ents.GetAllPlayers()) do
		if not p:IsRealPlayer() then
			p:RemoveAllCallbacks() --make sure no odd callbacks are getting stuck on bots
		end	
		p:SetName("") --clear targetnames
	end
end

function SetBotAggroOnPlayer(player, botindex)
	local interruptstring = "interrupt_action -posent " .. player:GetName() .. " -lookposent " .. player:GetName() 
		.. " -killlook -waituntildone -alwayslook"
	local bot = Entity(botindex)
	local botPrimary = bot:GetPlayerItemBySlot(0)
	
	if botPrimary and botPrimary:GetClassname() == "tf_weapon_crossbow" then
		interruptstring = interruptstring .. " -distance 1500"
	end
	bot:BotCommand(interruptstring)
end

function MimicPlayers(gmedorigin, gmedangles)
	local totalplayercount = 0
	local attackbotcount = 0
	local TOTALHP = 21000
	
	for _, p in pairs(players) do
		totalplayercount = totalplayercount + 1
	end
	
	local perhp = TOTALHP / totalplayercount
	
	for playerEntIndex, player in pairs(players) do
		local botname = 0
		local bot = 0
		local primaryattr = 0
		local meleeattr = 0
		
		local primary = player:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY)
		local secondary = player:GetPlayerItemBySlot(LOADOUT_POSITION_SECONDARY)
		local melee = player:GetPlayerItemBySlot(LOADOUT_POSITION_MELEE)
	
		for attr, _ in pairs(primary:GetAllAttributeValues()) do
			primaryattr = primaryattr + 1
		end
		for attr, _ in pairs(melee:GetAllAttributeValues()) do
			meleeattr = meleeattr + 1
		end
		
		attackbotcount = attackbotcount + 1
		botname = "attack" .. attackbotcount
		bot = ents.FindByName(botname)
		
		local botSecondary = bot:GiveItem(secondary:GetItemName())
		botSecondary.m_flChargeLevel = 100 --max uber here
		
		if primaryattr >= meleeattr then
			bot:WeaponStripSlot(LOADOUT_POSITION_MELEE)
			CopyPrimary(bot, primary)
		else 
			bot:WeaponStripSlot(LOADOUT_POSITION_PRIMARY)
			CopyMelee(bot, melee)
		end
		
		player:SetName(playerEntIndex)
		
		if not player:InCond(TF_COND_HALLOWEEN_GHOST_MODE) and player:IsAlive() then --aggro lock only if player is alive
			SetBotAggroOnPlayer(player, bot:GetNetIndex())
		end
		
		for _, item in pairs(player:GetAllItems()) do
			if item:IsWearable() then
				local botitem = bot:GiveItem(item:GetItemName())
				if botitem then --some items fail
					CopyAttribute("attach particle effect", item, botitem, true)
					CopyAttribute("set item tint RGB", item, botitem, true)
					CopyAttribute("set item tint RGB 2", item, botitem, true) --i think this is for team color paints?
					CopyAttribute("SPELL: set item tint RGB", item, botitem, true)
					CopyAttribute("SPELL: set Halloween footstep type", item, botitem, true)
					CopyAttribute("custom texture lo", item, botitem, true)
					CopyAttribute("custom texture hi", item, botitem, true)
					CopyAttribute("item style override", item, botitem, true)
				end
			end
		end
	
		bot:SetAttributeValue("max health additive bonus", perhp)
		bot:SetAttributeValue("mod weapon blocks healing", 1)
		bot.m_bIsMiniBoss = true
		
		--pair bot index to player index in vscript
		local inputString = "mimicListeners.registerPair(" .. playerEntIndex .. "," .. bot:GetNetIndex() .. ")"
		bot:AcceptInput("RunScriptCode", inputString, nil, nil)
		bot:Teleport(gmedorigin + Vector(0, 40, 0), gmedangles)
	end
	
	--clean up extra bots
	if attackbotcount < 6 then
		for i = attackbotcount + 1, 6 do
			local botname = "attack" .. i
			local bot = ents.FindByName(botname)
			
			bot:BotCommand("despawn")
		end
	end
end

--copy an attr + value from one wep to another
--does nothing if first wep doesn't have the attr
function CopyAttribute(name, copyfromwep, copytowep, checkdef)
	local value = copyfromwep:GetAttributeValue(name, checkdef)
	copytowep:SetAttributeValue(name, value)
end

--primarily user custom stuff (skins, festivizers, ks, names)
function CopyGeneric(copyfromwep, copytowep)
	CopyAttribute("paintkit_proto_def_index", copyfromwep, copytowep, true)
	CopyAttribute("set_item_texture_wear", copyfromwep, copytowep, true)
	CopyAttribute("custom_paintkit_seed_lo", copyfromwep, copytowep, true)
	CopyAttribute("custom_paintkit_seed_hi", copyfromwep, copytowep, true)
	CopyAttribute("is_festivized", copyfromwep, copytowep, true)
	CopyAttribute("killstreak tier", copyfromwep, copytowep, true)
	CopyAttribute("killstreak effect", copyfromwep, copytowep, true)
	CopyAttribute("killstreak idleeffect", copyfromwep, copytowep, true)
	CopyAttribute("attach particle effect", copyfromwep, copytowep, true)
	CopyAttribute("custom name attr", copyfromwep, copytowep, true)
end

function CopyPrimary(bot, copyfromwep)
	local copytowep = bot:GiveItem(copyfromwep:GetItemName())
	
	CopyAttribute("damage bonus", copyfromwep, copytowep)
	CopyAttribute("fire rate bonus", copyfromwep, copytowep)
	CopyAttribute("clip size bonus upgrade", copyfromwep, copytowep)
	CopyAttribute("clip size upgrade atomic", copyfromwep, copytowep)
	CopyAttribute("projectile penetration", copyfromwep, copytowep)
	CopyAttribute("faster reload rate", copyfromwep, copytowep)
	
	--aussie bluts
	CopyAttribute("item style override", copyfromwep, copytowep, true)
	CopyAttribute("is australium item", copyfromwep, copytowep, true)
	
	CopyGeneric(copyfromwep, copytowep)
end

function CopyMelee(bot, copyfromwep)
	local copytowep = bot:GiveItem(copyfromwep:GetItemName())

	--no dmg cause cok is strong enough
	CopyAttribute("melee attack rate bonus", copyfromwep, copytowep)
	CopyAttribute("critboost on kill", copyfromwep, copytowep)
	CopyAttribute("heal on kill", copyfromwep, copytowep)
	
	--objector
	CopyAttribute("custom texture lo", copyfromwep, copytowep, true)
	CopyAttribute("custom texture hi", copyfromwep, copytowep, true)
	
	CopyGeneric(copyfromwep, copytowep)
end

--set targetname on mimic bots 
function OnWaveSpawnBot(bot, _, tags)
	--if currentwave == BOSS_WAVE then
		if FindTag(tags, "gmed") then
			gmed = bot
		end

		if FindTag(tags, "attack1") then
			bot:SetName("attack1")
		elseif FindTag(tags, "attack2") then
			bot:SetName("attack2")
		elseif FindTag(tags, "attack3") then
			bot:SetName("attack3")
		elseif FindTag(tags, "attack4") then
			bot:SetName("attack4")
		elseif FindTag(tags, "attack5") then
			bot:SetName("attack5")
		elseif FindTag(tags, "attack6") then
			bot:SetName("attack6")
		end
	--end
end

--search for specific tag
function FindTag(tags, target)
	for _, tag in pairs(tags) do
		if tag == target then
			return true
		end
	end
end

--handle phase 1 stuff
function Phase1()
	local spawnbot = ents.FindByName("spawnbot_roof")
	local spawnbotorigin = spawnbot:GetAbsOrigin()
	local HEALTHSTAGE = 10010
	local recallstage = 0
	local text = "{blue}The King of the Robot Ghosts{reset}"
	.. " has used their {9BBF4D}RECALL{reset} Power Up Canteen!"
	
	for _, p in pairs(ents.GetAllPlayers()) do
		if p:IsRealPlayer() then
			players[p:GetNetIndex()] = p
		end	
	end

	gmed:AddCallback(ON_DAMAGE_RECEIVED_PRE, function(_, damageinfo)
		gmed:AddCond(TF_COND_PREVENT_DEATH) --removed automatically
	
		if gmed.m_iHealth - (damageinfo.Damage * 3.1 + 1) <= 0 then
			--as usual, stolen from royal

			for _, p in pairs(players) do
				p:AcceptInput("$DisplayTextChat", text)
				p:AcceptInput("$PlaySoundToSelf", "=35|mvm/mvm_used_powerup.wav")
			end

			gmed:Teleport(spawnbotorigin)
			recallstage = recallstage + 1
			gmed:AddHealth(HEALTHSTAGE, false)
			
			if recallstage == 1 then
				gmed:ChangeAttributes("shotgun")
			elseif recallstage == 2 then
				gmed:ChangeAttributes("crossbow")
			elseif recallstage == 3 then
				gmed:RemoveCond(TF_COND_SODAPOPPER_HYPE)
				gmed:ChangeAttributes("vita2")
				gmed:RemoveAllCallbacks(ON_DAMAGE_RECEIVED_PRE)
			end
			
			damageinfo.Damage = 0
			damageinfo.DamageType = DMG_GENERIC
			return true
		end
	end)
end

--player mimics
function Phase2()
	local gmedorigin = 0
	local gmedangles = 0
	
	gmed:AddCond(TF_COND_INVULNERABLE, 4)
	gmed:StunPlayer(4, 1, TF_STUNFLAG_NOSOUNDOREFFECT | TF_STUNFLAG_SLOWDOWN)
	--gmed:AcceptInput("$Taunt", nil, nil, nil)
	gmed:AcceptInput("$Taunt")
	gmedorigin = gmed:GetAbsOrigin()
	gmedangles = gmed:GetAbsAngles()
	
	local flames = MakeParticle("utaunt_hellswirl_flames", gmedorigin)
	local smoke = MakeParticle("utaunt_hellswirl_smoke", gmedorigin)
	local land = MakeParticle("utaunt_hellswirl_smoke_land", gmedorigin)
	
	timer.Simple(3, function()
		MimicPlayers(gmedorigin, gmedangles)
	end)
	
	flames:Remove()
	smoke:Remove()
	land:Remove()
end

function MakeParticle(effect, orig, cp1) 
	local particle = Entity("info_particle_system", true)
	local keyvals = {
		effect_name = effect,
		origin = orig,
		cpoint1 = cp1,
		flag_as_weather = 0
	}
	
	for k, v in pairs(keyvals) do
		particle:AddOutput(k.. " " .. tostring(v))
	end
	
	particle:Activate()
	particle:AcceptInput("Start")
	
	return particle
end

local registeredShields = {}

--royal shield dmg handling
function RegisterShield(shieldEntName, activator)
	local shieldEnt = ents.FindByName(shieldEntName)
	--local ownerTeamNum = activator.m_iTeamNum
	local ownerTeamNum = 3
	--print(shieldEnt:GetAbsAngles())
	shieldEnt:SetAbsAngles(Vector(0, shieldcount * 90, 0))
	shieldcount = shieldcount + 1

	shieldEnt.registered = true
	shieldEnt:SetModel("models/props_mvm/mvm_comically_small_player_shield.mdl")
	local handle = shieldEnt:GetHandleIndex()

	registeredShields[handle] = {}
	
	shieldEnt:AddCallback(ON_REMOVE, function()
		registeredShields[handle] = nil
	end)
	
	-- lvl 1: 3 dmg / .1 cooldown
	--lvl 2: 6 dmg / .1 cooldown
	
	local levelInfo = {
		Damage = 3,
		Cooldown = 0.1
	}
	
	shieldEnt:AddCallback(ON_TOUCH, function(_, target, hitPos)
		if not target then
			return
		end

		if not target:IsCombatCharacter() and target.m_iClassname ~= "tank_boss" then
			return
		end

		local visualHitPost = hitPos + Vector(0, 0, 50)

		local targetHandle = target:GetHandleIndex()

		local nextAllowedDamageTickOnTarget = registeredShields[handle][targetHandle] or -1

		if CurTime() < nextAllowedDamageTickOnTarget then
			return
		end

		local targetTeamnum = target.m_iTeamNum

		if targetTeamnum == ownerTeamnum then
			return
		end

		local damageInfo = {
			Attacker = activator or target,
			Inflictor = nil,
			Weapon = nil,
			Damage = levelInfo.Damage,
			DamageType = DMG_SHOCK,
			DamageCustom = 0,
			DamagePosition = visualHitPost,
			DamageForce = Vector(0, 0, 0),
			ReportedPosition = visualHitPost
		}

		local dmg = target:TakeDamage(damageInfo)

		registeredShields[handle][targetHandle] = CurTime() + levelInfo.Cooldown

		-- print("damage dealt " .. dmg)
	end)
end