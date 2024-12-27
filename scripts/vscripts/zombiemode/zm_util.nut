::REMOVE_ON_DEATH <- Constants.FTFBotAttributeType.REMOVE_ON_DEATH
::DISABLE_DODGE <- Constants.FTFBotAttributeType.DISABLE_DODGE
local notebook = Entities.FindByName(null, "notebook")
local respawn_override = Entities.FindByName(null, "respawn_override")
local checkpoint_relay = Entities.FindByName(null, "checkpoint_relay")
local checkpoint_relay_boss = Entities.FindByName(null, "checkpoint_relay_boss")
local boss_spawn = Entities.FindByName(null, "boss_spawn_point")
local boss_eff_1 = Entities.FindByName(null, "boss_spawn_effect_1")
local boss_eff_2 = Entities.FindByName(null, "boss_spawn_effect_2")
local escape_counter = Entities.FindByName(null, "escape_counter")
local escape_case = Entities.FindByName(null, "escape_case")
local escape_relay = Entities.FindByName(null, "escape_relay")
local phone = Entities.FindByName(null, "phone_sfx")
local ee_song = Entities.FindByName(null, "snd_eesong")
local powerupindex = RandomInt(0,4)
local powerupcount = 0
local powerupcooldown = 0	// how many bots have to die before powerups can spawn again
local powerupfail = 0 // how many times did a powerup not spawn
const STRONGMANN_TIME = 30;
const POWERUP_TIME = 30;

::ModelTable <-
[
	"models/lazy_zombies_v2/scout.mdl",
	"models/lazy_zombies_v2/soldier.mdl",
	"models/lazy_zombies_v2/pyro.mdl",
	"models/lazy_zombies_v2/demo.mdl",
	"models/lazy_zombies_v2/heavy.mdl",
	"models/lazy_zombies_v2/engineer.mdl",
	"models/lazy_zombies_v2/medic.mdl",
	"models/lazy_zombies_v2/sniper.mdl",
	"models/lazy_zombies_v2/spy.mdl",
]

::PowerupTable <-
[
	"powerup_instakill_spawner",
	"powerup_bonuspoints_spawner",
	"powerup_maxammo_spawner",
	"powerup_nuke_spawner",
	"powerup_doublepoints_spawner",
	"powerup_minigun_spawner",
]

::AnimationTable <-		// check itemclass of weapon and setmodel to respective class
{
	tf_weapon_pistol =						{ model = "models/player/engineer.mdl",}	
	tf_weapon_shotgun_primary = 			{ model = "models/player/engineer.mdl",}	
	tf_weapon_shotgun_pyro = 				{ model = "models/player/pyro.mdl",}	
	tf_weapon_flamethrower = 				{ model = "models/player/pyro.mdl",}	
	tf_weapon_scattergun = 					{ model = "models/player/scout.mdl",}	
	tf_weapon_sniperrifle = 				{ model = "models/player/sniper.mdl",}	
	tf_weapon_smg = 						{ model = "models/player/sniper.mdl",}	
	tf_weapon_grenadelauncher = 			{ model = "models/player/demo.mdl",}	
	tf_weapon_buff_item = 					{ model = "models/player/soldier.mdl",}	
	tf_weapon_rocketlauncher = 				{ model = "models/player/soldier.mdl",}	
	tf_weapon_minigun = 					{ model = "models/player/heavy.mdl",}	
	tf_weapon_crossbow = 					{ model = "models/player/medic.mdl",}	
	tf_weapon_revolver = 					{ model = "models/player/spy.mdl",}	
}
::PlayerModels <-
[
	"models/player/scout.mdl",
	"models/player/scout.mdl",
	"models/player/sniper.mdl",
	"models/player/soldier.mdl",
	"models/player/demo.mdl",
	"models/player/medic.mdl",
	"models/player/heavy.mdl",
	"models/player/pyro.mdl",
	"models/player/spy.mdl",
	"models/player/engineer.mdl",
]
::UpdatePlayerModel <- function(self, weapon)
{
	local playerclass = self.GetPlayerClass()
	local scope = self.GetScriptScope()
	local wep = self.GetActiveWeapon().GetClassname()
	if (self.GetActiveWeapon().GetSlot() >= 2)
	{
		self.SetCustomModelWithClassAnimations(PlayerModels[playerclass])
		scope.Preserved.activeweapon = wep
		SetPropInt(self,"m_nRenderMode",0)
		SetPropInt(self,"Alpha",255)
		return
	}
	if (!(wep in AnimationTable)) return
	local animmodel = AnimationTable[weapon].model 
	self.SetCustomModelWithClassAnimations(animmodel)
	SetPropInt(self,"m_nRenderMode",8)
	SetPropInt(self,"Alpha",1)
	local playeranim = PopExtUtil.CreatePlayerWearable(self,PlayerModels[playerclass],true)
	SetPropBool(playeranim,"m_bGlowEnabled",true)
	scope.Preserved.activeweapon = wep
}
::RoundEnd <- function(activator)
{
	PopExtUtil.AddThinkToEnt(activator, "RoundEnd_Think")
	for (local node; node = Entities.FindByClassname(node, "point_commentary_node");)
	{
		if (node.IsValid()) node.Destroy()
	}
}
::RoundEnd_Boss <- function(activator)
{
	PopExtUtil.AddThinkToEnt(activator, "BossEnd_Think")
	for (local node; node = Entities.FindByClassname(node, "point_commentary_node");)
	{
		if (node.IsValid()) node.Destroy()
	}
}
::RoundEndGlow <- function()
{
	foreach (bot in PopExtUtil.BotArray)
	{
		SetPropBool(bot,"m_bGlowEnabled",true)
	}
}

::MoveToSpawnLocation <- function(self)
{
	if (self.GetPlayerClass() == 1 || self.GetPlayerClass() == 2) return
	local lobby = false
	local hallways = false
	local warehouse = false
	local outside = false
	local exterior = false
	local maintenance = false
	local powerstation = false
	local lab_e = false
	local lab = false
	local secret = false
	local activesound = null
	local spawns = []
	local offset = Vector(0,0,-4)
	foreach (player in PopExtUtil.HumanArray)
	{
		if (player.IsAlive() && player.GetTeam() == 2)
		{
		activesound = GetPropInt(player, "m_Local.m_audio.soundscapeIndex")
		if (activesound == 153) lobby = true
		if (activesound == 154) warehouse = true
		if (activesound == 155) outside = true
		if (activesound == 156) exterior = true
		if (activesound == 157) maintenance = true
		if (activesound == 158) powerstation = true
		if (activesound == 159) hallways = true
		if (activesound == 160) lab_e = true
		if (activesound == 161) lab = true
		if (activesound == 20) secret = true
		}
	}
	if (lobby == true)
	{
		for (local entity; entity = Entities.FindByName(entity, "zombie_spawn_lobby");)
		{
			spawns.append(entity)
		}
	}
	if (warehouse == true)
	{
		for (local entity; entity = Entities.FindByName(entity, "zombie_spawn_warehouse");)
		{
			spawns.append(entity)
		}
	}
	if (hallways == true)
	{
		for (local entity; entity = Entities.FindByName(entity, "zombie_spawn_hallways");)
		{
			spawns.append(entity)
		}
	}
	if (outside == true || secret == true)
	{
		for (local entity; entity = Entities.FindByName(entity, "zombie_spawn_outside");)
		{
			spawns.append(entity)
		}
	}
	if (exterior == true)
	{
		for (local entity; entity = Entities.FindByName(entity, "zombie_spawn_exterior");)
		{
			spawns.append(entity)
		}
	}
	if (powerstation == true)
	{
		for (local entity; entity = Entities.FindByName(entity, "zombie_spawn_powerstation");)
		{
			spawns.append(entity)
		}
	}
	if (lab_e == true)
	{
		for (local entity; entity = Entities.FindByName(entity, "zombie_spawn_lab_e");)
		{
			spawns.append(entity)
		}
	}
	if (lab == true)
	{
		for (local entity; entity = Entities.FindByName(entity, "zombie_spawn_lab");)
		{
			spawns.append(entity)
		}
	}
	if (maintenance == true)
	{
		for (local entity; entity = Entities.FindByName(entity, "zombie_spawn_maintenance");)
		{
			spawns.append(entity)
		}
	}
	if (spawns.len() == 0)
	{
		local failsafe = Entities.FindByName(null, "failsafe")
		self.Teleport(true,failsafe.GetOrigin(),true,failsafe.GetAbsAngles(),false,self.GetAbsVelocity());
		printl("----------------------------")
		printl("Spawn array returned empty ... Where the fuck are you??")
		printl("----------------------------")
		return
	}
	local spawnlocation = spawns[RandomInt(0, spawns.len() - 1)]
	self.Teleport(true,spawnlocation.GetCenter()+offset,true,spawnlocation.GetAbsAngles(),true,spawnlocation.GetAbsVelocity());
//	UnstuckEntity(self)
}

::UseBossSpawnLocation <- function(self)	// use above function 
{
	
	local lobby = false
	local hallways = false
	local warehouse = false
	local outside = false
	local exterior = false
	local maintenance = false
	local powerstation = false
	local lab_e = false
	local lab = false
	local secret = false
	local activesound = null
	local spawns = []
	local offset = Vector(0,0,-4)
	foreach (player in PopExtUtil.HumanArray)
	{
		if (player.IsAlive() && player.GetTeam() == 2)
		{
		activesound = GetPropInt(player, "m_Local.m_audio.soundscapeIndex")
		if (activesound == 153) lobby = true
		if (activesound == 154) warehouse = true
		if (activesound == 155) outside = true
		if (activesound == 156) exterior = true
		if (activesound == 157) maintenance = true
		if (activesound == 158) powerstation = true
		if (activesound == 159) hallways = true
		if (activesound == 160) lab_e = true
		if (activesound == 161) lab = true
		if (activesound == 20) secret = true
		}
	}
	if (lobby == true)
	{
		for (local entity; entity = Entities.FindByName(entity, "boss_spawn_lobby");)
		{
			spawns.append(entity)
		}
	}
	if (warehouse == true)
	{
		for (local entity; entity = Entities.FindByName(entity, "boss_spawn_warehouse");)
		{
			spawns.append(entity)
		}
	}
	if (hallways == true)
	{
		for (local entity; entity = Entities.FindByName(entity, "boss_spawn_hallways");)
		{
			spawns.append(entity)
		}
	}
	if (outside == true || secret == true)
	{
		for (local entity; entity = Entities.FindByName(entity, "boss_spawn_outside");)
		{
			spawns.append(entity)
		}
	}
	if (exterior == true)
	{
		for (local entity; entity = Entities.FindByName(entity, "boss_spawn_exterior");)
		{
			spawns.append(entity)
		}
	}
	if (powerstation == true)
	{
		for (local entity; entity = Entities.FindByName(entity, "boss_spawn_powerstation");)
		{
			spawns.append(entity)
		}
	}
	if (lab_e == true)
	{
		for (local entity; entity = Entities.FindByName(entity, "boss_spawn_lab_e");)
		{
			spawns.append(entity)
		}
	}
	if (lab == true)
	{
		for (local entity; entity = Entities.FindByName(entity, "boss_spawn_lab");)
		{
			spawns.append(entity)
		}
	}
	if (maintenance == true)
	{
		for (local entity; entity = Entities.FindByName(entity, "boss_spawn_maintenance");)
		{
			spawns.append(entity)
		}
	}
	if (spawns.len() == 0)
	{
		local failsafe = Entities.FindByName(null, "failsafe")
		self.Teleport(true,failsafe.GetCenter(),true,failsafe.GetAbsAngles(),false,self.GetAbsVelocity());
		printl("----------------------------")
		printl("!! Spawn array returned empty !!")
		printl("----------------------------")
		return
	}
	local spawnlocation = spawns[RandomInt(0, spawns.len() - 1)]
	self.Teleport(true,spawnlocation.GetCenter()+offset,true,spawnlocation.GetAbsAngles(),false,self.GetAbsVelocity());
	UnstuckEntity(self)
}

::ClearBoxScope <- function(self)
{
	local scope = self.GetScriptScope();
	if (scope.Preserved.isusingbox == true) return // do not clear scope if this is not cleared, failsafe against quick rollers
	scope.Preserved.mysteryslot = "null"
	scope.Preserved.mysteryitemname = "null"
	scope.Preserved.mysteryresponse = "null"
}
::ClearPaPScope <- function(self)
{
	local scope = self.GetScriptScope();
	if (scope.Preserved.isusingstrongmann == true) return // do not clear scope if this is not cleared, failsafe against quick rollers
	scope.Preserved.papweapon = "null"
}
::ConfirmNotInUse <- function()	// check that box is not being used
{
	foreach (player in PopExtUtil.HumanArray)
	{
		local scope = player.GetScriptScope()
		if (scope.Preserved.isusingstrongmann == true)
		{
			return false;
			break
		}
	}
	return true
}
::SurvivalBonus <- function() // OH HOH NO YOU DON'T
{
//	local currency = GetPropInt(FindByClassname(null, "tf_mann_vs_machine_stats"),"m_currentWaveStats.nCreditsBonus")
//	foreach (player in PopExtUtil.HumanArray)
//	{
//		player.RemoveCurrency(-1500);
//		ClientPrint(player, HUD_PRINTCENTER, "You've received a $1500 survival bonus!");
//	}
//	currency = currency + 1500
//	SetPropInt(FindByClassname(null, "tf_mann_vs_machine_stats"),"m_currentWaveStats.nCreditsBonus",currency)
}
::ActivateEasterEgg <- function(activator)
{
	EntFireByHandle(phone,"playsound","",0,null,activator);
	EntFireByHandle(ee_song,"playsound","",10,null,activator);
}
::ClearBots <- function() // begone, bot
{
	local generator = SpawnEntityFromTable("tf_logic_training_mode"
	{
		targetname = "bot_wiper"
	})
	EntFireByHandle(Entities.FindByName(null, "bot_wiper"),"KickBots","",0,null,null);
	EntFireByHandle(Entities.FindByName(null, "bot_wiper"),"Kill","",0,null,null);
}

::RoundEnd_Think <- function()
{
	if (PopExtUtil.CountAliveBots() == 1)
	{
		EntFireByHandle(checkpoint_relay, "trigger", "", 0, null, null);
	}
}
::BossEnd_Think <- function()
{
	if (PopExtUtil.CountAliveBots() == 1)
	{
		EntFireByHandle(checkpoint_relay_boss, "trigger", "", 0, null, null);
	}
}

::PlayerSpawn <- function(self)
{
	EntFireByHandle(respawn_override, "StartTouch", "", -1, self, self) // exists in the bot prison
	PopExtUtil.AddThinkToEnt(self, "ButtonThink")
	GetPlayerLoadout(self)
	UpdatePlayerCurrency(self)
	UpdateHUDForPerks(self)
	NetProps.SetPropBool(self,"m_bGlowEnabled",true)
}
::GetPlayerLoadout <- function(self)
{
	local scope = self.GetScriptScope();
	local round_number = NetProps.GetPropInt(PopExtUtil.ObjectiveResource, "m_nMannVsMachineWaveCount")
	if (!self.IsValid()) return
	if (!"Preserved" in self.GetScriptScope()) return
	if (GetRoundState() == 10) // give starting weapon because it's pre-round
	{
		self.SetCurrency(500)
		local items = 
		{							 
			weapon_primary = "null"
			weapon_secondary = "ZM_Pistol"
			weapon_melee = "null"
		}
		if ("Preserved" in self.GetScriptScope())
		{
			foreach (k, v in items)
			self.GetScriptScope().Preserved[k] <- v
		}
		::CustomWeapons.GiveItem(scope.Preserved.weapon_secondary, self)
		EntFireByHandle(self,"runscriptcode","SetPropIntArray(self, `m_iAmmo`, ::CustomWeapons.GetMaxAmmo(self, 2), 2)",0.1,null,self);
	}
	if (GetRoundState() == 4)
	{
		if (("weapon_primary" && "weapon_secondary") in scope.Preserved)
		{
			::CustomWeapons.GiveItem(scope.Preserved.weapon_primary, self)
			::CustomWeapons.GiveItem(scope.Preserved.weapon_secondary, self)
			::CustomWeapons.GiveItem(scope.Preserved.weapon_melee, self)
			ApplyPerkBonuses(self)
			EntFireByHandle(self,"runscriptcode","SetPropIntArray(self, `m_iAmmo`, ::CustomWeapons.GetMaxAmmo(self, 1), 1)",0.1,null,self);
			EntFireByHandle(self,"runscriptcode","SetPropIntArray(self, `m_iAmmo`, ::CustomWeapons.GetMaxAmmo(self, 2), 2)",0.1,null,self);
			return
		}
		if (!("weapon_primary" && "weapon_secondary") in scope.Preserved)
		{
			if (round_number > 10)
			{
				self.SetCurrency(5000)
				local items = 
				{
					weapon_primary = "ZM_Rusty"
					weapon_secondary = "ZM_Raygun"
					weapon_melee = "null"
				}
				if ("Preserved" in self.GetScriptScope())
				{
					foreach (k, v in items)
					self.GetScriptScope().Preserved[k] <- v
				}
				EntFireByHandle(self,"runscriptcode","self.AddCustomAttribute(`max health additive bonus`,100,-1)",1.2,null,self);
				scope.Preserved.powerups["Saxton Ale"] <- true
				
				::CustomWeapons.GiveItem(scope.Preserved.weapon_primary, self)
				::CustomWeapons.GiveItem(scope.Preserved.weapon_secondary, self)
				::CustomWeapons.GiveItem(scope.Preserved.weapon_melee, self)
			}
		}
		else
		{
			self.SetCurrency(500)
			local items = 
			{
				weapon_primary = "null"
				weapon_secondary = "ZM_Pistol"
				weapon_melee = "null"
			}
			if ("Preserved" in self.GetScriptScope())
			{
				foreach (k, v in items)
				self.GetScriptScope().Preserved[k] <- v
			}
			::CustomWeapons.GiveItem(scope.Preserved.weapon_primary, self)
			::CustomWeapons.GiveItem(scope.Preserved.weapon_secondary, self)
			::CustomWeapons.GiveItem(scope.Preserved.weapon_melee, self)
		}
	}
}

::ShowGasOnPlayer <- function(self)
{
	local scope = self.GetScriptScope().Preserved
	local gastext = ""
	local text_gas = FindByName(null, "__text_gas")
	if (text_gas == null)
	{
		text_gas = SpawnEntityFromTable("game_text",
		{
			targetname = "__text_gas"
			channel = 2
			color = "255 255 255"
		//	spawnflags = 1
			fadein = 0
			fadeout = 0.2
			holdtime = 1
			message = ""	// leave blank in case spawnflags makes this display for everyone??
			x = 0.77
			y = 0.77
		})
	}
	gastext = format("Gas Cans: %i", scope.gasheld)
	NetProps.SetPropString(text_gas, "m_iszMessage", format("%s", gastext))
	text_gas.AcceptInput("Display","",self,null)
	if (scope.gasheld > 0) EntFireByHandle(self,"runscriptcode","ShowGasOnPlayer(self)",1,null,self);
}
::UpdatePowerupDurations <- function(self)
{
	local scope = self.GetScriptScope().Preserved
	local deathmachinetext = ""
	local instakilltext = ""
	local doublepointstext = ""
	local text_powerup = FindByName(null, "__text_powerup")
	
	doublepointstext = format("Double Points: %i", scope.doublepointstime - Time())
	instakilltext = format("Instakill: %i", scope.instakilltime - Time())
	deathmachinetext = format("Death Machine: %i", scope.miniguntime - Time())
	if ((scope.doublepointstime - Time()) <= 0) doublepointstext = ""
	if ((scope.instakilltime - Time()) <= 0) instakilltext = ""
	if ((scope.miniguntime - Time()) <= 0) deathmachinetext = ""
	if (text_powerup == null)
	{
		text_powerup = SpawnEntityFromTable("game_text",
		{
			targetname = "__text_powerup"
			channel = 1
			color = "255 255 255"
		//	spawnflags = 1
			fadein = 0
			fadeout = 0.2
			holdtime = 1
			message = ""	// leave blank in case spawnflags makes this display for everyone??
			x = 0.5
			y = 0.77
		})
	}
	NetProps.SetPropString(text_powerup, "m_iszMessage", format("%s \n %s \n %s", doublepointstext, instakilltext, deathmachinetext))
	text_powerup.AcceptInput("Display","",self,null)
	
	if (scope.instakilltime > Time() || scope.doublepointstime > Time() || scope.miniguntime > Time()) EntFireByHandle(self,"runscriptcode","UpdatePowerupDurations(self)",1,null,self);
}

::UpdateHUDForPerks <- function(self)
{
//	return 		// disable for now, can't get this shit to display right
	local scope = self.GetScriptScope().Preserved
	local hasostarion = false
	local hassaxton = false 
	local hasdoubletap = false 
	local hasquickola = false 
	if (self.GetCustomAttribute("Reload time decreased",0)) hasquickola = true
	if (self.GetCustomAttribute("fire rate bonus",0) != 0) hasdoubletap = true
	if (self.GetCustomAttribute("max health additive bonus",0)) hassaxton = true
	if (self.InCond(129)) hasostarion = true
	
	if ( hasostarion && !hassaxton && !hasdoubletap && !hasquickola) self.SetScriptOverlayMaterial("zombies/powerups/powerups_1___")
	if ( hasostarion && hassaxton && !hasdoubletap && !hasquickola)  self.SetScriptOverlayMaterial("zombies/powerups/powerups_12__")
	if ( hasostarion && hassaxton && hasdoubletap && !hasquickola)   self.SetScriptOverlayMaterial("zombies/powerups/powerups_123_")
	if ( hasostarion && hassaxton && hasdoubletap && hasquickola)    self.SetScriptOverlayMaterial("zombies/powerups/powerups_1234")
	if ( hasostarion && !hassaxton && !hasdoubletap && hasquickola)  self.SetScriptOverlayMaterial("zombies/powerups/powerups_1__4")
	if ( hasostarion && hassaxton && !hasdoubletap && hasquickola)   self.SetScriptOverlayMaterial("zombies/powerups/powerups_12_4")
	if ( !hasostarion && hassaxton && !hasdoubletap && !hasquickola) self.SetScriptOverlayMaterial("zombies/powerups/powerups__2__")
	if ( !hasostarion && hassaxton && hasdoubletap && !hasquickola)  self.SetScriptOverlayMaterial("zombies/powerups/powerups__23_")
	if ( !hasostarion && hassaxton && !hasdoubletap && hasquickola)  self.SetScriptOverlayMaterial("zombies/powerups/powerups__2_4")
	if ( !hasostarion && hassaxton && hasdoubletap && hasquickola)   self.SetScriptOverlayMaterial("zombies/powerups/powerups__234")
	if ( hasostarion && !hassaxton && hasdoubletap && !hasquickola)  self.SetScriptOverlayMaterial("zombies/powerups/powerups_1_3_")
	if ( hasostarion && !hassaxton && hasdoubletap && hasquickola)   self.SetScriptOverlayMaterial("zombies/powerups/powerups_1_34")
	if ( !hasostarion && !hassaxton && hasdoubletap && !hasquickola) self.SetScriptOverlayMaterial("zombies/powerups/powerups___3_")
	if ( !hasostarion && !hassaxton && hasdoubletap && hasquickola)  self.SetScriptOverlayMaterial("zombies/powerups/powerups___34")
	if ( !hasostarion && !hassaxton && !hasdoubletap && hasquickola) self.SetScriptOverlayMaterial("zombies/powerups/powerups____4")
	if ( !hasostarion && !hassaxton && !hasdoubletap && !hasquickola) self.SetScriptOverlayMaterial("")
}
::UpdatePlayerCurrency <- function(self)
{
	local currency = self.GetCurrency()
	local PlayerManager = Entities.FindByClassname(null, "tf_player_manager")

	SetPropIntArray(PlayerManager,"m_iCurrencyCollected",currency,self.entindex())
}

::ApplyTeleportEffects <- function(self)
{
	ScreenFade(self,255,255,255,255,1.5,0,2)
	ScreenShake(self.GetCenter(),8,128,3,48,0,true)
	self.AddCondEx(51,3,null)
	EmitSoundEx
	({
		sound_name = "Halloween.TeleportVortex.BookSpawn",
		origin = self.GetCenter(),
		filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
	});
}

::EnterStrongmann <- function(self)
{
	self.ValidateScriptScope()
	local scope = self.GetScriptScope();
	self.AddCondEx(6,10,null)
	scope.Preserved.timesteleported = scope.Preserved.timesteleported + (POWERUP_TIME - 29)
	scope.Preserved.teleporttime = Time() + STRONGMANN_TIME; // I dunno keep it as like a minute??
	scope.Preserved.isinstrongmannroom = true; // trip look up for playerlogic
	ScreenFade(self,255,255,255,255,1,0,1)
	ScreenShake(self.GetCenter(),16,144,2,48,0,true)
	local strongmannwarp = Entities.FindByName(null, "warp_destination")
	self.Teleport(true,strongmannwarp.GetCenter(),true,strongmannwarp.GetAbsAngles(),false,self.GetAbsVelocity());
	EmitSoundEx
	({
		sound_name = "Halloween.TeleportVortex.BookExit",
		origin = self.GetCenter(),
		filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
	});
}

::EnterBoardroom <- function(self)
{
	self.ValidateScriptScope()
	local scope = self.GetScriptScope();
	self.AddCondEx(6,10,null)
	scope.Preserved.teleporttime = Time() + STRONGMANN_TIME - 10; // I dunno keep it as like a minute??
	scope.Preserved.isinstrongmannroom = true; // trip look up for playerlogic
	ScreenFade(self,255,255,255,255,1,0,1)
	ScreenShake(self.GetCenter(),16,144,2,48,0,true)
	local secretwarp = Entities.FindByName(null, "boardroom_destination")
	self.Teleport(true,secretwarp.GetCenter(),true,secretwarp.GetAbsAngles(),false,self.GetAbsVelocity());
	EmitSoundEx
	({
		sound_name = "Halloween.TeleportVortex.BookExit",
		origin = self.GetCenter(),
		filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
	});
}

::ExitStrongmann <- function(self)
{
	self.ValidateScriptScope()
	local scope = self.GetScriptScope();
	local startwarp = Entities.FindByName(null, "red_spawn")
	self.AddCondEx(6,10,null)
	ScreenFade(self,255,255,255,255,1,0,1)
	ScreenShake(self.GetCenter(),16,144,2,48,0,true)
	self.Teleport(true,startwarp.GetCenter(),true,startwarp.GetAbsAngles(),false,self.GetAbsVelocity());
	EmitSoundEx
	({
		sound_name = "Halloween.TeleportVortex.BookExit",
		origin = self.GetCenter(),
		filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
	});
}

::SpawnPowerup <- function(player)
{
	if (player.GetScriptScope().Preserved.isenteringlevel == 1 || powerupcount == 4) return
	if (powerupcooldown > 0)
	{
		powerupcooldown -= 1
		return
	}
	local diceroll = RandomInt(1,100)
	local round_number = NetProps.GetPropInt(PopExtUtil.ObjectiveResource, "m_nMannVsMachineWaveCount")
	local botcount = (NetProps.GetPropInt(PopExtUtil.ObjectiveResource, "m_nMannVsMachineWaveClassCounts"))
	local dicecheck = 0
	local round_threshold = 0
	
	// count our powerup odds
	if (round_number <= 5) round_threshold = 2
	if (round_number > 5 && round_number <= 10) round_threshold = 1
	if (round_number > 10 && round_number <= 15) round_threshold = 0.5
	if (round_number > 15) round_threshold = 0.33
	
	dicecheck = (botcount * round_threshold) + powerupfail
	
	if (diceroll > dicecheck)
	{
		powerupfail += 2
		return
	}
	EmitSoundEx
	({
		sound_name = "misc/halloween/merasmus_spell.wav",
		origin = player.GetCenter(),
		filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
	});
	local powerup = Entities.FindByName(null, PowerupTable[powerupindex])
	powerup.SetAbsOrigin(player.GetCenter());
	EntFireByHandle(powerup, "forcespawn", "", 0, player, player);
	powerupindex += 1
	powerupcount += 1
	powerupfail = 0
	powerupcooldown = 2
	
	if (powerupindex >= 6) 
	{
		powerupindex = 0
	}
}
::ResetPowerupCount <- function()
{
	powerupcount = 0
}
::ForceMaxAmmo <- function(player)
{
	local powerup = Entities.FindByName(null, "powerup_maxammo_spawner")
	powerup.SetAbsOrigin(player.GetCenter());
	EntFireByHandle(powerup, "forcespawn", "", 0, player, player);
}

::ActivateInstakill <- function(self)
{
	local scope = self.GetScriptScope();
	PopExtUtil.PlaySoundOnClient(self,"items/powerup_pickup_crits.wav",1.0,100)
	PopExtUtil.PlaySoundOnClient(self,"deadlands/powerup_instagib.mp3",1.0,100)
	self.AddCondEx(56,30,null)
	scope.Preserved.instakilltime = Time() + POWERUP_TIME;
	ClientPrint(self, HUD_PRINTCENTER, "Instakill!");
	UpdatePowerupDurations(self)
}
::ActivateMaxammo <- function(self)
{
	foreach (player in PopExtUtil.HumanArray)
	{
        if (player.IsAlive())
		{
			PopExtUtil.PlaySoundOnClient(player,"deadlands/pickup_maxammo.mp3",1.0,100)
			PopExtUtil.PlaySoundOnClient(player,"deadlands/powerup_maxammo.mp3",1.0,100)
			SetPropIntArray(player, "m_iAmmo", ::CustomWeapons.GetMaxAmmo(player, 1), 1)
			SetPropIntArray(player, "m_iAmmo", ::CustomWeapons.GetMaxAmmo(player, 2), 2) 
			ClientPrint(player, HUD_PRINTCENTER, "Max Ammo!");
		}
	}
}
::ActivateBonuspoints <- function(self)
{
	PopExtUtil.PlaySoundOnClient(self,"deadlands/pickup_bonuspoints.mp3",1.0,100)
	PopExtUtil.PlaySoundOnClient(self,"deadlands/powerup_bonuspoints.mp3",1.0,100)
	foreach (player in PopExtUtil.HumanArray)
	{
        self.RemoveCurrency(-500)
	}
	self.RemoveCurrency(-500)
	local currency = GetPropInt(FindByClassname(null, "tf_mann_vs_machine_stats"),"m_currentWaveStats.nCreditsBonus")
	currency = currency + 1000
	SetPropInt(FindByClassname(null, "tf_mann_vs_machine_stats"),"m_currentWaveStats.nCreditsBonus",currency)
	ClientPrint(self, HUD_PRINTCENTER, "Bonus Points!");
}
::ActivateDoublePoints <- function(self)
{
	local scope = self.GetScriptScope();
	scope.Preserved.doublepointstime = Time() + POWERUP_TIME;
	ClientPrint(self, HUD_PRINTCENTER, "Double Points!");
	PopExtUtil.PlaySoundOnClient(self,"items/powerup_pickup_haste.wav",1.0,100)
	PopExtUtil.PlaySoundOnClient(self,"deadlands/powerup_doublepoints.mp3",1.0,100)
	UpdatePowerupDurations(self)
}
::ActivateNuke <- function(self)
{
    local killicon_dummy = CreateByClassname("info_teleport_destination")
    SetPropString(killicon_dummy, "m_iClassname", "megaton")

    PopExtUtil.PlaySoundOnAllClients("misc/doomsday_missile_explosion.wav")
    foreach (player in PopExtUtil.HumanArray)
    {
        ScreenFade(player,255,255,255,255,1.5,0,1)
        ScreenShake(player.GetCenter(),16,144,3,48,0,true)
		player.RemoveCurrency(-400)
    }
    foreach (bot in PopExtUtil.BotArray)
    {
        if (PopExtUtil.IsAlive(bot) && !bot.HasBotTag("Cooldude"))
        {
            // bot.TakeDamage(bot.GetHealth(),8256,self) // self credits player for kill
            bot.TakeDamageEx(killicon_dummy, self, null, Vector(), Vector(), bot.GetHealth(), DMG_BLAST)
        }
    }
    EntFireByHandle(killicon_dummy,"kill","",-1,null,null)
    EntFireByHandle(notebook,"runscriptcode","PopExtUtil.PlaySoundOnAllClients(`deadlands/powerup_nuke.mp3`)",0,null,null);
}
::ActivateMinigun <- function(self)
{
	self.ValidateScriptScope()
	local scope = self.GetScriptScope();
	PopExtUtil.PlaySoundOnClient(self,"ui/item_heavy_gun_pickup.wav",1.0,100)
	PopExtUtil.PlaySoundOnClient(self,"deadlands/powerup_minigun.mp3",1.0,100)
	
	for (local i = 0; i < MAX_WEAPONS; i++)
	{
		local weapon = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i)
		if (weapon == null)
		continue
		if (weapon.GetSlot() == 0) 
		{
			NetProps.SetPropEntityArray(self, "m_hMyWeapons", null, i)
			weapon.Destroy()
			if ("ammofix" in self.GetScriptScope().CustomWeapons) self.GetScriptScope().CustomWeapons.ammofix.RemoveAttribute("hidden primary max ammo bonus")
			break
		}
	}
	::CustomWeapons.GiveItem("Death Machine", self);
	EntFireByHandle(self,"runscriptcode","SetPropIntArray(self, `m_iAmmo`, ::CustomWeapons.GetMaxAmmo(self, 1), 1)",0,null,self);
	ClientPrint(self, HUD_PRINTCENTER, "Death Machine!");
	self.SetIsMiniBoss(true)
	ApplyPerkBonuses(self)
	scope.Preserved.miniguntime = Time() + POWERUP_TIME;
	scope.Preserved.hasdeathmachine = true
	UpdatePowerupDurations(self)
}
::PlayPerkAnimation <- function(self) 
{
	local main_viewmodel = GetPropEntity(self, "m_hViewModel")
	::CustomWeapons.GiveItem("Perk Bottle", self);
	main_viewmodel.SetSequence(main_viewmodel.LookupSequence("bb_fire_red"))
	main_viewmodel.ResetSequence(main_viewmodel.LookupSequence("bb_fire_red"))
	main_viewmodel.SetPlaybackRate(0.7)
	EntFireByHandle(self,"runscriptcode","PopExtUtil.PlaySoundOnClient(self,`Scout.DodgeCanDrink`,1.0,100)",0.5,null,self);
}
::RollZombieModel <- function(self)
{
	local diceroll = RandomInt(0,8)
	local model = ModelTable[diceroll]	
	self.SetCustomModelWithClassAnimations(model)
}

::TeleportToTarget <- function(self)
{
	local targetarray = []
	local spots = []
	local target = null
	local targetnav = {}
	local filternav = {}
	local minareasize = 300
	foreach (player in PopExtUtil.HumanArray)
	{
		if (player.IsAlive())
		{
			targetarray.append(player)
		}
	}
	if (targetarray.len() == 0) return
	target = targetarray[RandomInt(0,targetarray.len()-1)]
	
	if (target == null) return	// wtf??
	self.GetScriptScope().Preserved.attackcooldown = Time() + POWERUP_TIME;
	self.Taunt(0,11)
	self.Taunt(0,11)
	self.AddCustomAttribute("no_attack", 1, 3)
//	self.AddCustomAttribute("mult_player_movespeed_active", 0.0001, 3)
	
	GetNavAreasInRadius(target.GetOrigin(),500,targetnav)	// now rewritten with some of Stardustspy's code
	GetNavAreasInRadius(target.GetOrigin(),150,filternav)
	foreach(id, nav in targetnav)
	{
		if (nav.GetSizeX() * nav.GetSizeY() > minareasize)
		{
			spots.append(nav)
		}
	}
	foreach(id, nav in filternav)
	{
		if (id, nav in targetnav)
		{
			spots.remove(nav)
		}
	}
	local nav = spots[RandomInt(0, spots.len() - 1)]
	local warpsite = nav.FindRandomSpot()
	local starteff = SpawnEntityFromTable("info_particle_system", 
	{
		effect_name = "utaunt_electric_mist_parent", 
		targetname = "tele_eff"
		origin = self.GetOrigin()
		angles = Vector(0,0,0)
	})
	local teleport = SpawnEntityFromTable("info_particle_system", 
	{
		effect_name = "utaunt_electric_mist_parent", 
		targetname = "tele_eff_1"
		origin = warpsite
		angles = Vector(0,0,0)
	})
	local teleport_2 = SpawnEntityFromTable("info_particle_system", 
	{
		effect_name = "utaunt_lightning_bolt", 
		targetname = "tele_eff_2"
		origin = warpsite + Vector(0,0,24)
		angles = Vector(0,0,0)
	})
	EmitSoundEx
	({
		sound_name = "Halloween.TeleportVortex.BookSpawn",
		origin = teleport.GetCenter(),
		filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
	});
	EmitSoundEx
	({
		sound_name = "Necronaut.Warp",
		origin = teleport.GetCenter(),
		filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
	});
	EmitSoundEx
	({
		sound_name = "Halloween.TeleportVortex.BookSpawn",
		origin = self.GetCenter(),
		filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
	});
	EntFireByHandle(teleport,"Start","",0,self,null);
	EntFireByHandle(starteff,"Start","",0,self,null);
	EntFireByHandle(teleport,"runscriptcode","activator.SetAbsOrigin(self.GetCenter());",1.5,self,null);
	EntFireByHandle(self,"runscriptcode","UnstuckEntity(self)",1.8,self,null);
	EntFireByHandle(starteff,"Stop","",1.5,self,null);
	EntFireByHandle(teleport,"Stop","",1.5,self,null);
	EntFireByHandle(teleport_2,"Start","",1.5,self,null);
	EntFireByHandle(teleport_2,"Stop","",1.7,self,null);
	EntFireByHandle(self,"RunScriptCode","self.RemoveCond(7)",3,self,null);
	EntFireByHandle(starteff,"runscriptcode","EmitSoundEx({sound_name = `Halloween.TeleportVortex.BookExit`,origin = self.GetCenter(),filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT});",1.5,self,null);
	EntFireByHandle(teleport_2,"runscriptcode","EmitSoundEx({sound_name = `Halloween.TeleportVortex.BookExit`,origin = self.GetCenter(),filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT});",1.5,self,null);
	EntFireByHandle(starteff,"Kill","",3,self,null);
	EntFireByHandle(teleport,"Kill","",3,self,null);
	EntFireByHandle(teleport_2,"Kill","",3,self,null);
	
}

//similarly from Stardustspy, written by Lite
::UnstuckEntity <- function(entity)
{
	if (!entity.IsAlive()) return
	::MASK_PLAYERSOLID <- 33636363
	local origin = entity.GetOrigin();
	local trace = 	{
	start = origin,
	end = origin,
	hullmin = entity.GetBoundingMins(),
	hullmax = entity.GetBoundingMaxs(),
	mask = MASK_PLAYERSOLID,
	ignore = entity
					}
	TraceHull(trace);
	if ("startsolid" in trace)
	{
	local dirs = [Vector(1, 0, 0), Vector(-1, 0, 0), Vector(0, 1, 0), Vector(0, -1, 0), Vector(0, 0, 1), Vector(0, 0, -1)];
	for (local i = 16; i <= 96; i += 16)
	{
		foreach (dir in dirs)
		{
			trace.start = origin + dir * i;
			trace.end = trace.start;
			delete trace.startsolid;
			TraceHull(trace);
			if (!("startsolid" in trace))
			{
				entity.SetAbsOrigin(trace.end);
				return true;
			}
		}
	}
	return false;
	}
	return true;
}

::ConfirmEscape <- function()
{
	local players_escaping = 0
	local player_count = 0
	local building = Entities.FindByName(null, "escape_check")
	
	players_escaping = players_escaping + GetPropInt(escape_counter, "m_OutValue")
	foreach (player in PopExtUtil.HumanArray)
	{
		if (player.IsAlive())
		{
			player_count++
		}
		escape_case.AcceptInput("SetCompareValue", player_count.tostring(), null, null)
		escape_case.AcceptInput("Compare", "", null, null)
	}
}
::TurnOnEscapeCamera <- function()
{
	foreach (player in PopExtUtil.HumanArray)
	{
		EntFireByHandle(player,"RunScriptCode","Entities.FindByName(null, `escape_camera`).AcceptInput(`Enable`,``,self,null)",2,null,null);
		EntFireByHandle(player,"RunScriptCode","self.Teleport(true,Entities.FindByName(null, `boardroom_destination`).GetCenter(),true,Entities.FindByName(null, `boardroom_destination`).GetAbsAngles(),false,self.GetAbsVelocity());",2,null,null);
		EntFireByHandle(player,"RunScriptCode","ScreenShake(self.GetCenter(),48,512,6,48,0,true)",14,null,null);
		EntFireByHandle(player,"RunScriptCode","Entities.FindByName(null, `escape_camera`).AcceptInput(`Disable`,``,self,null)",17,null,null);
	}
	for (local node; node = Entities.FindByClassname(node, "point_commentary_node");)
	{
		if (node.IsValid()) node.Destroy()
	}
}
::ExitStageLeft <- function() // remove bot from wave counter
{ 
	local botcount = NetProps.GetPropInt(PopExtUtil.ObjectiveResource, "m_nMannVsMachineWaveClassCounts")
	if (botcount == 0) return
	
	botcount-= 1
	NetProps.SetPropInt(PopExtUtil.ObjectiveResource, "m_nMannVsMachineWaveClassCounts", botcount)
}

::IsInFieldOfView <- function (user, target)
{
	local tolerance = 0.5736 // cos(110/2)
	local eyefwd = user.EyeAngles().Forward()
	local eyepos = user.EyePosition()
	local delta = target.GetOrigin() - eyepos
	delta.Norm()
	if (eyefwd.Dot(delta) >= tolerance)
	return true

	delta = target.GetCenter() - eyepos
	delta.Norm()
	if (eyefwd.Dot(delta) >= tolerance)
	return true

	delta = target.EyePosition() - eyepos
	delta.Norm()
	return (eyefwd.Dot(delta) >= tolerance)
}
::IsVisible <- function (user, target)
{
	local trace =
	{
		start  = user.EyePosition(),
		end    = target.EyePosition(),
		mask   = MASK_OPAQUE,
		ignore = user
	}
	TraceLineEx(trace)
	return !trace.hit
}
::IsThreatVisible <- function (user, target)
{
	return IsInFieldOfView(user, target) && IsVisible(user, target)
}

::AttemptRelocation <- function (user)
{
	if (user.GetPlayerClass() == 7) return // no necronauts
	local visible = false;
	for (local i = 0; i < MaxClients().tointeger(); ++i)
	{
		local player = PlayerInstanceFromIndex(i);
		if (!player || player.IsBotOfType(1337)) continue;
		if (IsThreatVisible(player, user))
		{
			visible = true;
			break;
		}
	}
	if (visible) return
	if (!visible)
	{
		if (user.GetPlayerClass() == 2)
		{
			UseBossSpawnLocation(user)
			user.GetScriptScope().Preserved.isenteringlevel = 1
		}
		else
		{
			MoveToSpawnLocation(user)
			user.GetScriptScope().Preserved.isenteringlevel = 1
		}
	}
}
::DropGascans <- function (user)
{
	local scope = user.GetScriptScope().Preserved
	if (scope.gasheld == 0) return
	SpawnTemplate("Gascan_Drop",null,user.GetOrigin() + Vector(-8,-8,48))
	scope.gasheld = (scope.gasheld - 1)
	if (scope.gasheld > 0) DropGascans(user)
}
::LastManWarning <- function()
{
	if (PopExtUtil.CountAlivePlayers() == 0) return
	local diceroll = RandomInt(0,3)
	local warninglines =
	[
		"Announcer.AM_LastManAlive01",
		"Announcer.AM_LastManAlive02",
		"Announcer.AM_LastManAlive03",
		"Announcer.AM_LastManAlive04",
	]
	foreach (player in PopExtUtil.HumanArray)
	{
		if (player.IsAlive() && player.GetTeam() == 2)
		{
			PopExtUtil.PlaySoundOnClient(player,warninglines[diceroll],1.0,100)
			ClientPrint(player, HUD_PRINTCENTER, "You are the last one standing...");
		}
	}
}