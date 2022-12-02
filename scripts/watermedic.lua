--by watermelon
--a bunch of stuff is stolen/inspired by royal, as noted

--callback related stuff taken from royal
local callbacks = {}
timers = {}
local players = {} -- k: player handles, v - table of player entity, if reanimator is active, reanimator entity, reanimated count
local bots = {} -- k: bot handle, v: matching player handle
local gmed = 0
local HUNT_WAVE = 5
local BOSS_WAVE = 6
local currentwave = 0
local shieldcount = 0

--specific wave gametick stuff from royal
function OnWaveStart(wave)
	if wave == HUNT_WAVE or wave == BOSS_WAVE then
		currentwave = wave
		players = {} --fresh start
		bots = {}
		callbacks = {}
		for _, p in pairs(ents.GetAllPlayers()) do
			if p:IsRealPlayer() and p.m_iTeamNum == 2 then --ignore specs
				local handle = p:GetHandleIndex()
			
				players[handle] = {}
				players[handle].entity = p
				players[handle].reanimstate = false
				players[handle].reanimentity = nil --in practice this does nothing, just sugar
				players[handle].reanimcount = 0
				
				p:SetAttributeValue("min respawn time", 2401)
			end
		end
		if wave == HUNT_WAVE then
			local door1 = ents.FindByName("door_red_large_win_1")
			local door2 = ents.FindByName("door_red_large_win_2")
		
			door1:AcceptInput("Unlock")
			door2:AcceptInput("Unlock")
			door1:AcceptInput("Open")
			door2:AcceptInput("Open")
		
			timers.aggrotimer = timer.Create(1, function()
				for bot, _ in pairs(bots) do
					CheckBotAggro(bot)
				end
			end, 0)
		end
		OnPlayerConnected = SpecificPlayerConnected
	end
end

function CheckBotAggro(bot)
	local botentity = Entity(bot)
	local boteyetrace = {
		start = botentity, -- Start position vector. Can also be set to entity, in this case the trace will start from entity eyes position
		endpos = nil, -- End position vector. If nil, the trace will be fired in `angles` direction with `distance` length
		distance = 1500, -- Used if endpos is nil
		angles = botentity:GetAbsAngles(), -- Used if endpos is nil
		mask = MASK_ALL, -- Solid type mask, see MASK_* globals
		collisiongroup = TFCOLLISION_GROUP_ROCKETS, -- Pretend the trace to be fired by an entity belonging to this group. See COLLISION_GROUP_* globals
		mins = Vector(0,0,0), -- Extends the size of the trace in negative direction
		maxs = Vector(0,0,0), -- Extends the size of the trace in positive direction
		filter = nil -- Entity to ignore. Can be a single entity, table of entities, or a function with a single entity parameter
	}

	local tracetable = util.Trace(boteyetrace)
	if tracetable.HitTexture == "ENCOUNTER/BARRIER_BLUE_DETAIL" then
		--force bots to aggro on someone else if they're looking at someone outside a barrier
		botentity:ChangeAttributes("changetarget")				
	end
end

--mostly a lot of post wave fail/success cleanup
function OnWaveInit(wave)
	OnPlayerConnected = Nothing
	
	currentwave = 0
	shieldcount = 0

	for timername, timerid in pairs(timers) do	
		timer.Stop(timerid)
		timers[timername] = nil
	end
	
	if wave == HUNT_WAVE then
		timer.Simple(1, function()
			local door1 = ents.FindByName("door_red_large_win_1")
			local door2 = ents.FindByName("door_red_large_win_2")
		
			door1:AcceptInput("Lock")
			door2:AcceptInput("Lock")
		end)
	end

	for _, p in pairs(ents.GetAllPlayers()) do
		if p:IsRealPlayer() then
			p:SetCustomModel("") --sometimes ghost model gets stuck
			p:SetAttributeValue("min respawn time", nil)
			if wave == HUNT_WAVE then
				local spawn = ents.FindByName("teamspawn_all")
				local spawnorigin = spawn:GetAbsOrigin()
				timer.Simple(2, function()
					p:Teleport(spawnorigin)
				end)
			end
		else 
			p:RemoveAllCallbacks() --make sure no odd callbacks are getting stuck on bots
		end	
		p:SetName("") --clear targetnames
	end
end

function OnWaveSuccess(wave)
	currentwave = 0
end

function OnPlayerDisconnected(player) 
	players[player:GetHandleIndex()] = nil
end

function OnPlayerConnected(player) 
end

--no need to run outside of specific waves
function SpecificPlayerConnected(player)
	local handle = player:GetHandleIndex()

	players[handle] = {}
	players[handle].entity = player
	players[handle].reanimstate = false
	players[handle].reanimentity = nil
	players[handle].reanimcount = 0
end

local function Nothing()
end

function OnGameTick()
	medigunTick()
	if currentwave == HUNT_WAVE or currentwave == BOSS_WAVE then
		SpecificWaveGameTick()
	end
end

function SpecificWaveGameTick()
	local alive = 0

	for p, datatable in pairs(players) do
		local player = datatable.entity

		if player:InCond(TF_COND_HALLOWEEN_GHOST_MODE) == 1 and not datatable.reanimstate then
			--if ghost but doesn't have a reanim yet
			CreateReanim(datatable)
			BecomeGhost(p, datatable)
		elseif datatable.reanimstate and not datatable.reanimentity then
			--if a reanim somehow gets destroyed, then force respawn the player
			player:ForceRespawn()
		elseif player:InCond(TF_COND_HALLOWEEN_GHOST_MODE) == 0 and player:IsAlive() then
			--if alive/not ghost
			alive = alive + 1
		end
	end
	
	if alive == 0 then
		local bots_win = ents.FindByName("bots_win")
		bots_win:AcceptInput("RoundWin")
	end
end

function CreateReanim(datatable)
	local reanim = 0
	local origin = 0
	local player = datatable.entity
	
	origin = player:GetAbsOrigin() + Vector(0, 0, 75)
	-- med eye height
	
	reanim = Entity("entity_revive_marker", true, false)
	
	reanim.m_hOwner = player
	reanim.m_iTeamNum = 2
	reanim.m_iMaxHealth = 75 + (datatable.reanimcount * 10)
	reanim.m_nBody = 4
	
	reanim:SetAbsOrigin(origin)
	
	reanim:Activate()
	
	datatable.reanimstate = true
	datatable.reanimentity = reanim
	
	reanim:AddCallback(ON_REMOVE, function()
		datatable.reanimentity = nil
		--reanim:RemoveAllCallbacks(ON_REMOVE) --might not be necessary since callbacks autoremoved on death
	end)
end

function BecomeGhost(handle, datatable) 
	--change model
	--get/play m1 sound
	--set invis to bots
	--check if has been revived
	local player = datatable.entity
	callbacks[handle] = {}
	
	for _, medigun in pairs(ents.FindAllByClass("tf_weapon_medigun")) do
		if medigun.m_hHealingTarget == player then
			medigun.m_hHealingTarget = nil
		end
	end
	
	if currentwave == BOSS_WAVE then --make mimic harass someone else if you die
		local bothandle = FindMimickingBot(handle)
		if bothandle then
			Entity(bothandle):BotCommand("stop interrupt action")
		end
	end 
	
	player:SetCustomModel("models/props_halloween/ghost_no_hat_red.mdl")
	player:AcceptInput("SetCustomModelVisibleToSelf", true)
	player:SetAttributeValue("mod weapon blocks healing", 1)
	player:SetAttributeValue("ignored by bots", 1)
	
	--callbacks[handle].keypressed = player:AddCallback(ON_KEY_PRESSED, function(_, key)
		--print(key)
	--	if key == IN_ATTACK then
			--print("attack")
	--		player:AcceptInput("SpeakResponseConcept", "TLK_PLAYER_MEDIC")
	--	end
	--end)
	
	--if revived
	callbacks[handle].spawn = player:AddCallback(ON_SPAWN, function()
		if datatable.reanimentity then
			datatable.reanimentity:Remove()
			datatable.reanimcount = datatable.reanimcount + 1
			--only punish if not freak accident
		end
		
		--always do in case forcerespawned
		datatable.reanimstate = false
		datatable.reanimentity = nil
		player:SetAttributeValue("min respawn time", 2401)
		player:SetCustomModel("")
		player:AcceptInput("SetCustomModelVisibleToSelf", false)
		player:SetAttributeValue("mod weapon blocks healing", nil)
		player:SetAttributeValue("ignored by bots", nil)
		player:RemoveCallback(callbacks[handle].spawn)
		--player:RemoveCallback(callbacks[handle].keypressed)
		
		--reaggro mimic to player on revive
		if currentwave == BOSS_WAVE then
			local bothandle = FindMimickingBot(handle)
			if bothandle then
				SetBotAggroOnPlayer(player, bothandle)
			end
		end
		
	end)
end

function FindMimickingBot(playerhandle) --this should be only fired if player is valid in the first place
	for bothandle, pairedhandle in pairs(bots) do
		if playerhandle == pairedhandle then
			if Entity(bothandle):IsAlive() and IsValid(Entity(playerhandle)) then
				return bothandle
			end
		end
	end
end

function SetBotAggroOnPlayer(player, bothandle)
	local interruptstring = "interrupt_action -posent " .. player:GetName() .. " -lookposent " .. player:GetName() 
		.. " -killlook -waituntildone -alwayslook"
	local bot = Entity(bothandle)
	local botPrimary = bot:GetPlayerItemBySlot(0)
	
	if botPrimary and botPrimary:GetClassname() == "tf_weapon_crossbow" then
		interruptstring = interruptstring .. " -distance 1500"
	end
	--print(interruptstring)
	bot:BotCommand(interruptstring)
end

function RemoveCallbacks(player, callbacks)
	if not IsValid(player) then
		return
	end

	for _, callbackID in pairs(callbacks) do
		--print(callbackid)
		player:RemoveCallback(callbackID)
	end
end

function MimicPlayers()
	local totalplayercount = 0
	local attackbotcount = 0
	local TOTALHP = 21000
	local bots = {}
	
	for p, _ in pairs(players) do
		totalplayercount = totalplayercount + 1
	end
	
	local perhp = TOTALHP / totalplayercount
	
	for playerhandle, datatable in pairs(players) do
		local botname = 0
		local bot = 0
		local p = datatable.entity
		local primaryattr = 0
		local meleeattr = 0
		
		local primary = p:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY)
		local secondary = p:GetPlayerItemBySlot(LOADOUT_POSITION_SECONDARY)
		local melee = p:GetPlayerItemBySlot(LOADOUT_POSITION_MELEE)
	
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
		
		p:SetName(p:GetHandleIndex())
		
		if p:InCond(TF_COND_HALLOWEEN_GHOST_MODE) == 0 and p:IsAlive() then --don't aggro lock if player isn't alive
			SetBotAggroOnPlayer(p, bot:GetHandleIndex())
		end
		
		for _, item in pairs(p:GetAllItems()) do
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
		
		bots[bot:GetHandleIndex()] = playerhandle
		--pair bot handle to player handle
		
		bot:SetAttributeValue("max health additive bonus", perhp)
		bot:SetAttributeValue("mod weapon blocks healing", 1)
		bot.m_bIsMiniBoss = true
	end
	
	--clean up extra bots 
	for i = attackbotcount + 1, 6 do
		local botname = "attack" .. i
		local bot = ents.FindByName(botname)
		--print("removed " .. botname)
		
		bot:Suicide()
	end
	
	return bots
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
	--CopyAttribute("heal on kill", copyfromwep, copytowep) --this is kinda useless
	CopyAttribute("projectile penetration", copyfromwep, copytowep)
	CopyAttribute("faster reload rate", copyfromwep, copytowep)
	--CopyAttribute("mad milk syringes", copyfromwep, copytowep)
	
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
	if currentwave == HUNT_WAVE then --add bot to botlist so it can be iterated, remove from list on death
		bots[bot:GetHandleIndex()] = bot
		bot:AddCallback(ON_DEATH, function()
			bots[bot:GetHandleIndex()] = nil
			bot:RemoveAllCallbacks(ON_DEATH)
		end)
	end
	
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
	local roof_player_warp = ents.FindByName("roof_player_warp")
	local spawnbot = ents.FindByName("spawnbot_roof")
	local spawnbotorigin = spawnbot:GetAbsOrigin()
	local HEALTHSTAGE = 10000
	local recallstage = 0
	local text = "{blue}The King of the Robot Ghosts{reset}"
	.. " has used their {9BBF4D}RECALL{reset} Power Up Canteen!"

	timer.Simple(1, function()
		Fade()
		
		timer.Simple(1, function()
			for _, datatable in pairs(players) do
				local player = datatable.entity
				if player:InCond(TF_COND_HALLOWEEN_GHOST_MODE) == 1 or player:IsAlive() == false then
					player:ForceRespawn()
				end
				player:Teleport(roof_player_warp:GetAbsOrigin(), roof_player_warp:GetAbsAngles())
			end
		end)		
	end)
	
	gmed:AddCallback(ON_DAMAGE_RECEIVED_PRE, function(_, damageinfo)
		gmed:AddCond(TF_COND_PREVENT_DEATH) --removed automatically
	
		if gmed.m_iHealth - (damageinfo.Damage * 3.1 + 1) <= 0 then
			--as usual, stolen from royal

			for _, datatable in pairs(players) do
				p = datatable.entity
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
	gmed:AcceptInput("$Taunt")
	gmedorigin = gmed:GetAbsOrigin()
	gmedangles = gmed:GetAbsAngles()
	
	local flames = MakeParticle("utaunt_hellswirl_flames", gmedorigin)
	local smoke = MakeParticle("utaunt_hellswirl_smoke", gmedorigin)
	local land = MakeParticle("utaunt_hellswirl_smoke_land", gmedorigin)
	
	timer.Simple(3, function()
		bots = MimicPlayers() --returns table of bots 
		
		for b, _ in pairs(bots) do
			--uses handle keys
			local bot = Entity(b)
	
			bot:Teleport(gmedorigin + Vector(0, 40, 0), gmedangles)
		end
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

--taken from royal
function Fade()
	local fadeEnt = Entity("env_fade", true)
	local properties = {
		holdtime = 1,
		duration = 0.5,
		rendercolor = "255, 255, 255",
		renderamt = 255
	}

	for name, value in pairs(properties) do
		fadeEnt:AcceptInput("$SetKey$"..name, value)
	end

	fadeEnt.Fade(fadeEnt)

	timer.Simple(1, function ()
		fadeEnt:Remove()
	end)
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