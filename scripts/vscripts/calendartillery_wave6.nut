IncludeScript("popextensions_main.nut",getroottable())
IncludeScript("seel_ins.nut",getroottable())
MissionAttrs({
"ForceHoliday" : 2
"NoCrumpkins" : 1
"NoThrillerTaunt" : 1
})
IncludeScript("calendartillery_pointtemplates.nut",getroottable())

const SLOT_MELEE = 2
const OVERLAY_BUDDHA_MODE = 0x02000000
::NavDirs <- [ "NORTH","EAST","SOUTH","WEST" ]

::MaxPlayers <- MaxClients().tointeger();
for (local i = 1; i <= MaxPlayers ; i++)
{
	local player = PlayerInstanceFromIndex(i)
	if (player == null) continue
	if (!player.IsBotOfType(TF_BOT_TYPE)) continue
	SetPropInt(player, "m_debugOverlays", GetPropInt(player, "m_debugOverlays") & ~OVERLAY_BUDDHA_MODE)
}

PopExt.AddRobotTag("the_general", {
OnSpawn = function(bot,tag) {
	SINS.ChangeClassIcon(bot,"heavy_rocket")
	bot.SetCustomModel("models/empty.mdl")
	for (local child = bot.FirstMoveChild(); child != null; child = child.NextMovePeer())
		if (child.GetClassname() == "tf_wearable" || startswith(child.GetClassname(),"tf_weapon"))
			child.DisableDraw();
	SpawnTemplate("TheGeneralsCar")
	EntFire("heavy_shooter","SetParent","!activator",-1,bot)
	EntFire("heavy_model_prop","RunScriptCode","self.GetScriptScope().NextAttackTime <- Time() + 0.1",0.1)
	EntFire("heavy_model_prop","RunScriptCode","self.GetScriptScope().StopAnimation <- false",0.1)
	EntFire("heavy_model_prop","RunScriptCode","TheGeneralsCarAddThink(self,!activator)",0.1,bot)
	
	::TheGeneralsHealth <- 1
	::TheGeneralsOrigin <- bot.GetOrigin()
	::TheGeneralsAngles <- bot.GetAbsAngles()
	::TheGeneralsEyeAngles <- bot.EyeAngles()
	bot.GetScriptScope().currentPhase <- 1
	bot.GetScriptScope().prizeFound <- false
	bot.GetScriptScope().gotShotWhileSitting <- false
	SetPropInt(bot, "m_debugOverlays", GetPropInt(bot, "m_debugOverlays") | OVERLAY_BUDDHA_MODE)
	
	bot.GetScriptScope().PlayerThinkTable.bossThink <- function() {
		TheGeneralsHealth = fabs(self.GetHealth()) / fabs(self.GetMaxHealth())
		TheGeneralsOrigin = self.GetOrigin()
		TheGeneralsAngles = self.GetAbsAngles()
		TheGeneralsEyeAngles = self.EyeAngles()
		//printf("General's health is %f\n",TheGeneralsHealth)

		if (TheGeneralsHealth <= 0.7 && currentPhase == 1 && self.IsValid())
		{
			//Phase change handled through func for delay.
			currentPhase = 2
			EntFireByHandle(self,"CallScriptFunction","TheGeneralsPhaseChange",0.7,null,null)
			
			EmitSoundEx({
			sound_name = "weapons/buff_banner_horn_blue.wav",
			sound_level = 105,
			entity = self
			}); //900 HU
			
			for (local i = 1; i <= MaxPlayers ; i++)
			{
				local player = PlayerInstanceFromIndex(i)
				if (player == null) continue
				if (!player.IsBotOfType(TF_BOT_TYPE)) continue
				if (GetPropInt(player, "m_lifeState") != 0) continue
				
				if (player.HasBotTag("the_general_medic"))
				{
					player.AddCustomAttribute("move speed penalty",1,-1) //RemoveCustomAttribute didn't work. wack.
					player.RemoveBotAttribute(SUPPRESS_FIRE)
				}
				else if (player.HasBotTag("botblocker"))
				{
					player.SetAbsOrigin(Vector(1620,2150,-380))
					player.AddCustomAttribute("health regen",-5,-1)
				}
			}
		}
		if (TheGeneralsHealth <= 0.05 && currentPhase == 2 && self.IsValid())
		{
			currentPhase = 3
			self.AddCond(66)
			for (local child = self.FirstMoveChild(); child != null; child = child.NextMovePeer())
				child.DisableDraw();
			TheGeneralsBattFlag.Destroy()
			TheGeneralsBuffFlag.Destroy()
			
			SpawnTemplate("TheGeneralsDefeat",null,TheGeneralsOrigin);
			EntFire("heavy_model_prop_defeat","RunScriptCode","self.GetScriptScope().StopAnimation <- false",0.1)
			EntFire("heavy_model_prop_defeat","RunScriptCode","AddThinkToEnt(self,`TheGeneralsDefeatThink`)",0.1,bot)
			for (local i = 1; i <= MaxPlayers ; i++)
			{
				local player = PlayerInstanceFromIndex(i)
				if (player == null) continue
				if (!player.IsBotOfType(TF_BOT_TYPE)) continue
				if (player == self) continue
				
				if (player.HasBotTag("the_general_medic"))
				{
					player.TakeDamage(999, DMG_GENERIC, PopExtUtil.Worldspawn)
					continue
				}
				
				self.AddCond(87) //FREEZE_INPUT
				player.AddBotAttribute(IGNORE_ENEMIES)
				player.AddBotAttribute(IGNORE_FLAG)
				player.SetAbsOrigin(Vector(2940,-2960,-95)) //Spawnbot
			}
			EntFire("Classic_Mode_Intel","ForceResetAndDisableSilent") //Who names their intel like that?
			
			self.AddCond(87) //FREEZE_INPUT
			self.AddBotAttribute(IGNORE_ENEMIES)
			self.SetHealth(self.GetMaxHealth() * 0.05)
			self.SetIsMiniBoss(false)
			self.SetModelScale(1,0)
			ClientPrint(null,3,"\x07F1C232The General \x078FCE00: Enough.")
			ClientPrint(null,3,"\x078FCE00To lose a battle with dignity, a true commander must know when he has been bested.")
			EntFireByHandle(bot,"RunScriptCode","TheGeneralsPrizeSpawn(self)",1,null,null) //Creates TheGeneralsPrize
		}
		if (currentPhase == 3 && !prizeFound && self.IsValid())
		{
			// printl("Phase 3 initiated, searching for the Prize!")
			SetPropInt(bot, "m_debugOverlays", GetPropInt(bot, "m_debugOverlays") & ~OVERLAY_BUDDHA_MODE)
			for (local i = 1; i <= MaxPlayers ; i++)
			{
				local player = PlayerInstanceFromIndex(i)
				if (player == null) continue
				if (player.IsBotOfType(TF_BOT_TYPE)) continue
				if (GetPropInt(player, "m_lifeState") != 0) continue
				
				if (GetPropInt(PopExtUtil.GetItemInSlot(player,SLOT_MELEE),"m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 1071)
				{
					prizeFound = true
					PopExtUtil.GetItemInSlot(player,SLOT_MELEE).AddAttribute("item style override",0,-1)
				}
			}
		}
	}
}
OnTakeDamage = function(bot,params) {
	if (!(bot.GetScriptScope().currentPhase == 3)) return
	
	if (GetPropInt(params.weapon,"m_AttributeManager.m_Item.m_iItemDefinitionIndex") != 1071)
		params.damage = params.damage * 0.2
	else
		params.damage = params.const_entity.GetHealth() + 1
	
	if (!bot.GetScriptScope().gotShotWhileSitting && bot.GetScriptScope().prizeFound && GetPropInt(params.weapon,"m_AttributeManager.m_Item.m_iItemDefinitionIndex") != 1071)
	{
		ClientPrint(null,3,"\x07F1C232The General \x078FCE00: Ah. How insulting it is, to be belittled in this way. You are a cruel bunch; in another path, I would have respected that in you.")
		bot.GetScriptScope().gotShotWhileSitting = true
	}
	if (params.damage >= params.const_entity.GetHealth())
	{
		params.damage_type = DMG_NEVERGIB
		for (local child = bot.FirstMoveChild(); child != null; child = child.NextMovePeer())
			child.EnableDraw();
		
		EntFire("heavy_model_prop_defeat","Kill","",-1)
	}
}
})
::TheGeneralsPrizeSpawn <- function(bot)
{
	::TheGeneralsPrize <- CreateByClassname("tf_dropped_weapon")
	SetPropInt(TheGeneralsPrize, "m_Item.m_iItemDefinitionIndex", 1071)
	SetPropInt(TheGeneralsPrize, "m_Item.m_iEntityLevel", 5)
	SetPropInt(TheGeneralsPrize, "m_Item.m_iEntityQuality", 6)
	SetPropBool(TheGeneralsPrize, "m_Item.m_bInitialized", true)
	TheGeneralsPrize.SetModelSimple("models/weapons/c_models/c_frying_pan/c_frying_pan.mdl")
	TheGeneralsPrize.SetSkin(2)
	
	local botOrigin = bot.GetOrigin()
	::dropOrigin <- botOrigin
	local desiredNav = null;
	local navTable = {}
	GetNavAreasOverlappingEntityExtent(bot,navTable)
	local preferNavDir = floor((TheGeneralsAngles.y + 180) / 90)
	//printl("Let's see, the preferred nav direction is "+NavDirs[preferNavDir].tostring())
	foreach (nav in navTable)
	{
		local checkNav = nav.GetRandomAdjacentArea(preferNavDir)
		// If the nav is not under the General, coplanar (approx same height), reachable by red, and not damaging, it's cool!
		if (!checkNav || checkNav in navTable || !checkNav.IsCoplanar(nav) || !checkNav.IsReachableByTeam(TF_TEAM_RED) || checkNav.IsDamaging()) continue;
		desiredNav = checkNav
		break
	}
	if (desiredNav != null)
		dropOrigin = desiredNav.GetCenter();
	
	TheGeneralsPrize.SetAbsOrigin(dropOrigin)

	TheGeneralsPrize.DispatchSpawn()
	
	ClientPrint(null,3,"\x07F1C232The General \x078FCE00: I ask only for a simple kindness: allow me to pass with vanity, in the absence of infamy.")
	EntFire("prize_particle","RunScriptCode","self.SetAbsOrigin(dropOrigin)")
	EntFire("prize_particle","SetParent","!activator",-1,TheGeneralsPrize)
	SpawnTemplate("TheGeneralsDefeatHint",null,dropOrigin)
	EntFire("prize_hint","RunScriptCode","self.SetAbsOrigin(dropOrigin)")
}
::TheGeneralsPhaseChange <- function()
{
	self.SetCustomModel("")
	for (local child = self.FirstMoveChild(); child != null; child = child.NextMovePeer())
		child.EnableDraw();
	::TheGeneralsBattFlag <- PopExtUtil.CreatePlayerWearable(self,"models/weapons/c_models/c_battalion_buffbanner/c_batt_buffbanner.mdl",true,"flag")
	
	::TheGeneralsBuffFlag <- PopExtUtil.CreatePlayerWearable(self,"models/weapons/c_models/c_buffbanner/c_buffbanner.mdl",false,"flag")
	TheGeneralsBuffFlag.SetLocalAngles(QAngle(90,-90,20))
	TheGeneralsBuffFlag.SetLocalOrigin(Vector(-5,30,-10))
	
	self.RemoveBotAttribute(SUPPRESS_FIRE)
	
	SpawnTemplate("TheGeneralsBuffs",self,"","",true)
	SINS.ChangeClassIcon(self,"heavy_buff_backup_v1")
}
::TheGeneralsCarAddThink <- function(ent,bot)
{
	AddThinkToEnt(ent,"TheGeneralsCarThink")
	for (local shooter; shooter = FindByClassname(shooter, "tf_point_weapon_mimic");)
	{
		if (shooter.GetName() == "heavy_shooter")
			shooter.SetOwner(bot)
	}
}
::TheGeneralsCarThink <- function()
{
	if (!self) return -1;
	self.SetOrigin(TheGeneralsOrigin)
	self.SetAbsAngles(TheGeneralsAngles)
	if (self.GetSequenceName(self.GetSequence()) == "taunt_the_road_rager_a1")
	{
		if (self.GetCycle() > 0.15 && self.GetCycle() < 0.36 && NextAttackTime < Time()) {
			EntFire("heavy_shooter","RunScriptCode","self.SetAbsOrigin(Vector(TheGeneralsOrigin.x,TheGeneralsOrigin.y,TheGeneralsOrigin.z+70))")
			EntFire("heavy_shooter","RunScriptCode","self.SetAbsAngles(QAngle(TheGeneralsEyeAngles.x-2,self.GetAbsAngles().y,0))")
			EntFire("heavy_shooter","FireOnce")
			NextAttackTime = Time() + 0.2
		}
	}
	if (TheGeneralsHealth <= 0.7 && !StopAnimation)
	{
		StopAnimation = true
		self.ResetSequence(self.LookupSequence("taunt_the_road_rager_a1"))
		self.StudioFrameAdvance()
		self.DispatchAnimEvents(self)
		self.SetSequence(self.LookupSequence("taunt_the_road_rager_outro"))
		self.StudioFrameAdvance()
		self.DispatchAnimEvents(self)
		self.SetPlaybackRate(0.65)
	}
	if (self.GetSequenceName(self.GetSequence()) == "taunt_the_road_rager_outro" && self.GetCycle() >= 0.35)
	{
		self.ResetSequence(self.LookupSequence("STAND_PRIMARY"))
		self.StudioFrameAdvance()
		self.DispatchAnimEvents(self)
		EntFire("heavy_model_prop","Kill","",0.15)
	}
	self.StudioFrameAdvance()
	self.DispatchAnimEvents(self)
	return -1
}
::TheGeneralsDefeatThink <- function()
{
	if (!self.IsValid()) 
	{
		//printl("Debug: ERROR: NO SELF FOUND.")
		return -1;
	}
	if (!TheGeneralsOrigin) return -1;
	self.SetOrigin(TheGeneralsOrigin)
	if (self.GetSequenceName(self.GetSequence()) == "tauntrussian_rubdown") //russian rubdown
	{
		if (self.GetCycle() >= 0.15) {
			self.SetCycle(0.147) //approx 53 / 354
			self.StopAnimation()
		}
		else if (self.GetCycle() < 0.147)
			self.StudioFrameAdvance()
	}
	self.DispatchAnimEvents(self)
	return -1
}