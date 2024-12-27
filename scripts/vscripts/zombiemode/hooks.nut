const RADIUS = 8;
const DISP_RADIUS = 410;
const DISP_COOLDOWN = 1;
if ("RedRidgeEvents" in getroottable()) delete ::RedRidgeEvents // this is done to prevent hook stacking
::RedRidgeEvents <- {
    function OnGameEvent_post_inventory_application(params)
	{
		local player = GetPlayerFromUserID(params.userid);
		if (player.GetTeam() == 2) // set up the stuffs
		{
	
		player.ValidateScriptScope();
		local scope = player.GetScriptScope();
		
		//stuff we want to put in player scope
		local items = 
		{							 
			playerskin = "null"
			mysteryitemname = "null"
			mysteryslot = "null"
			mysteryresponse = "null" // values to shit you pull from box, put in scope for simple access
			papweapon = "null" // same goes to PaP, they're written into user's scope to make things less of a hassle
			papslot = "null" 
			
			powerups = {}
			isinstrongmannroom = false 
			isusingbox = false
			isusingstrongmann = false
			isinanimation 	= 	false 
			hasdeathmachine = 	false 
			activeweapon = 		null
			timesrepaired = 	0
			timesteleported = 	0
			hurttime = 			0
			ammotime = 			0
			ammobuys = 			0
			gasheld = 			0
			cooldown = 			0
			animationtime = 	0
			cooldowntime = 		0	// cooldown time between button presses
			teleporttime = 		0  	// timer for strongmann room 
			instakilltime = 	0
			miniguntime = 		0	// for death machine
			doublepointstime = 	0
			multiplier =		1	// double points, to double points
		}
		if ("Preserved" in player.GetScriptScope())
		{
			foreach (k, v in items)
			player.GetScriptScope().Preserved[k] <- v	// calls an error but still works, probably happens because the player entity doesn't exist when the hook tries to hook?
			PlayerSpawn(player);
			EntFireByHandle(player,"RunScriptCode","ApplyPlayerAttributes(self)",0.1,null,player);
		}
		};
		if (player.GetTeam() == 3)
		{
			player.ValidateScriptScope();
			local scope = player.GetScriptScope();
	
			//stuff we want to put in player scope
			local items = {
			
			isenteringlevel = 1
			voicecooldown = 0
			attackcooldown = 0
			warpcooldown = 0
			zombie_type   =	0 	// used to swap type of noise
			isinanimation  = 0	// if true, bot gets no_attack
			}
			foreach (k, v in items)
			player.GetScriptScope().Preserved[k] <- v
			ZombieSpawn(player);
		}
    } 
	function OnGameEvent_player_changeclass(params)
	{
		local player = GetPlayerFromUserID(params.userid);
		if (player.GetTeam() == 2) EntFireByHandle(player,"RunScriptCode","ApplyPlayerAttributes(self)",0.1,null,player);
	}
	function OnScriptHook_OnTakeDamage (params)
	{
		local victim = params.const_entity
		local attacker = params.attacker
		local inflictor = params.inflictor
		local damage = params.damage
		local weapon = params.weapon
		if (attacker == null) return
		if (attacker.GetTeam() == 3)
		{
			if (attacker.GetScriptScope().Preserved.zombie_type <= 5) NetProps.SetPropString(params.weapon, "m_iClassname", "unarmed_combat")
			if (attacker.GetScriptScope().Preserved.zombie_type == 7) NetProps.SetPropString(params.weapon, "m_iClassname", "battleaxe")
			if (attacker.GetScriptScope().Preserved.zombie_type == 10) NetProps.SetPropString(params.weapon, "m_iClassname", "battleneedle")
		}
		if (attacker.GetTeam() == 2)
		{
			if (params.damage_type & DMG_ALWAYSGIB)
			{
				params.damage_type = params.damage_type | TF_DMG_CUSTOM_END
				NetProps.SetPropString(params.weapon, "m_iClassname", "megaton")
			}
			if (weapon != null && weapon.GetAttribute("Set DamageType Ignite",0) != 0)
			{
				local utilignite = FindByName(null, "__utilignite")
				if (utilignite == null)
				{
					utilignite = SpawnEntityFromTable("trigger_ignite",
					{
						targetname = "__utilignite"
						burn_duration = 3.0
						damage = damage
						spawnflags = SF_TRIGGER_ALLOW_CLIENTS
					})
				}
				EntFireByHandle(utilignite, "StartTouch", "", -1, victim, victim)
				EntFireByHandle(utilignite, "EndTouch", "", SINGLE_TICK, victim, victim)
			}
		}
		if ((victim.GetTeam() == 2 && victim.IsPlayer() && victim.GetCustomAttribute("health regen",0) != 0))
		{
			victim.RemoveCustomAttribute("health regen")
			victim.GetScriptScope().Preserved.hurttime = Time() + (DISP_COOLDOWN + 1)
		}
	}
	function OnGameEvent_player_builtobject(params)
	{
		local builder = GetPlayerFromUserID(params.userid)
		local object = params.object
		local building = EntIndexToHScript(params.index)
		local isbuilding = EntIndexToHScript(params.index)
		local hasthestuff = false
		local outputs = []
		
		if (GetRoundState() != 4)
		{
			building.Destroy()
			return
		}
		
		if (object == 0) // dispenser
		{
			AddThinkToEnt(building, "DispenserThink")
			SetPropInt(building, "m_iHighestUpgradeLevel", 1)
			::DispenserThink <- function()
			{
				if (!building.IsValid()) NetProps.SetPropString(building, "m_iszScriptThinkFunction", "")
				local metalcount = GetPropInt(building,"m_iAmmoMetal")
				local isbuilding = GetPropInt(building,"m_bBuilding")
				local touchtrig = Entities.FindByClassnameWithin(null,"dispenser_touch_trigger",building.GetCenter(),DISP_RADIUS);
				if (building.IsValid() && isbuilding == 0 && touchtrig != null)
				{
					if (!hasthestuff)
					{
						AddThinkToEnt(touchtrig, "DispenserTick")
						hasthestuff = true
					}
					if (metalcount == 0)
					{
						touchtrig.AcceptInput("Disable","",null,null)	// supposed to be for a check that drains ammometal when a player touches dispenser_touch_trigger
					}
					else
					touchtrig.AcceptInput("Enable","",null,null)		// I can't get it to work so it's dummied out entirely, more OBSOLETE
				}
			}
			::DispenserTick <- function()	// find players snooping around dispenser_touch_trigger and take away metal
			{
				local metalcount = GetPropInt(building,"m_iAmmoMetal")
				for (local players; players = FindByClassnameWithin(players, "player", self.GetOrigin(), (RADIUS + 402)); )
				{
					if (players.IsAlive && players.GetTeam() == 2)
					{
						local scope = players.GetScriptScope().Preserved
						local HasMaxedAmmo = false
						if ((GetPropIntArray(players,"m_iAmmo",1) < CustomWeapons.GetMaxAmmo(players, 1)) || (GetPropIntArray(players,"m_iAmmo",2) < CustomWeapons.GetMaxAmmo(players, 2)))
						{
							HasMaxedAmmo = false
						}
						else
						{
							HasMaxedAmmo = true
						}
						if (scope.ammotime < Time() && metalcount > 0 && !HasMaxedAmmo)
						{
							metalcount -= 25
							if (metalcount < 0) metalcount = 0
							NetProps.SetPropInt(building, "m_iAmmoMetal", metalcount)
							scope.ammotime = Time() + (DISP_COOLDOWN);
						}
					}
				}
			}
		}
	//	if (object == 2) // sentry gun
	//	{
	//		SetPropInt(building, "m_iHighestUpgradeLevel", 2)
	//	}
		if (object == 1) // teleporters
		{
	//		building.SetModelSimple("models/props_frontline/mine_norock.mdl")	// doesn't work but kept for precaching
	//		SpawnTemplate("Engineer_Landmine",null,building.GetOrigin())	// ,building.GetAngles() causes errors
	//		EmitSoundEx
	//		({
	//			sound_name = "Building_Teleporter.Build1",	// this also needs to be precached???
	//			origin = building.GetCenter(),
	//			filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
	//		});
			building.Destroy()	// don't allow teleporters
		}					
	}
	function OnGameEvent_player_hurt(params) // WOW! it's money
	{
		local victim = GetPlayerFromUserID(params.userid)
		local attacker = GetPlayerFromUserID(params.attacker)
		
		if (victim.GetTeam() == 2 && victim.InCond(129))
		{
			if (params.damageamount > victim.GetHealth())
			{
				victim.AddCondEx(5,2.5,null)
				victim.AddCondEx(11,2.5,null)
				victim.SetHealth(500)
				victim.RemoveCond(129)
				victim.RemoveCond(70)
				PopExtUtil.PlaySoundOnClient(victim,"misc/halloween/merasmus_stun.wav",1.0,100)
				EntFireByHandle(victim,"runscriptcode","UpdateHUDForPerks(self)",0.1,null,victim);
			}
		}	
		if (victim.GetTeam() == 3) // we can probably do something more with this
		{
			if (attacker != null)
			{
				if (attacker.InCond(56)) // gib anything hit by instakill // || or
				{
					params.damageamount = victim.GetHealth();
					victim.SetScaleOverride(1.01); // make bigger to force gib
					victim.SetHealth(-400)
				}
				if (params.damageamount > 4 && attacker.GetTeam() == 2) // player_hurt can't check damagetype
				{
					local currency = GetPropInt(FindByClassname(null, "tf_mann_vs_machine_stats"),"m_currentWaveStats.nCreditsAcquired")
					attacker.RemoveCurrency(-10 * attacker.GetScriptScope().Preserved.multiplier) // the rest of the cash is handled by player_death below
					currency = currency + (10 * attacker.GetScriptScope().Preserved.multiplier)
					SetPropInt(FindByClassname(null, "tf_mann_vs_machine_stats"),"m_currentWaveStats.nCreditsAcquired",currency)
					SetPropInt(FindByClassname(null, "tf_mann_vs_machine_stats"),"m_currentWaveStats.nCreditsDropped",currency)	// writing into creditsacquired affects this too
				}
				if (victim.GetScriptScope().Preserved.zombie_type == 5 && (victim.GetHealth() / victim.GetMaxHealth().tofloat()) <= 0.2 && victim.IsAllowedToTaunt())
				{
					victim.GetScriptScope().Preserved.voicecooldown = Time() + 5
					victim.GetScriptScope().Preserved.attackcooldown = Time() + 5
					victim.AddCustomAttribute("gesture speed increase" ,0.3, -1);
					victim.Taunt(1,92)
					EntFireByHandle(victim, "SetHealth", "-300", 2, victim, victim) 
					EmitSoundEx
					({
						sound_name = "Fat.BlastOff",
						origin = victim.GetCenter(),
						filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
					});
				}
				if (params.damageamount > victim.GetHealth()) // death sounds
				{
					if (victim.GetScriptScope().Preserved.zombie_type <= 3)
					{
						EmitSoundEx
						({
							sound_name = "Zombie.Death",
							origin = victim.GetCenter(),
							filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
						});
					}
					if (victim.GetScriptScope().Preserved.zombie_type == 4)
					{
						EmitSoundEx
						({
							sound_name = "Sock.Death",
							origin = victim.GetCenter(),
							filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
						});
					}
					if (victim.GetScriptScope().Preserved.zombie_type == 5)
					{
						EmitSoundEx
						({
							sound_name = "Fat.Death",
							origin = victim.GetCenter(),
							filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
						});
					}
					if (victim.GetScriptScope().Preserved.zombie_type == 8)
					{
						EmitSoundEx
						({
							sound_name = "Shotgunner.Death",
							origin = victim.GetCenter(),
							filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
						});
					}
				}
			}
		}
	}
	function OnGameEvent_player_death(params)
	{
		local deadguy = GetPlayerFromUserID(params.userid)
		local damagebits = params.damagebits
		local attacker = GetPlayerFromUserID(params.attacker)
		local assister = GetPlayerFromUserID(params.assister)
		local botcount = NetProps.GetPropInt(PopExtUtil.ObjectiveResource, "m_nMannVsMachineWaveClassCounts")
		local playerclass = deadguy.GetPlayerClass()
		if (deadguy.GetTeam() == 3)
		{
			ExitStageLeft()
			SpawnPowerup(deadguy)
			local payout = 0
			local assist = 0
			for (local wearable = deadguy.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
			{
				if (wearable.GetClassname() != "tf_wearable")
				continue
				SetPropInt(wearable,"m_nRenderMode",10)
			}
			if (deadguy.GetPlayerClass() == 2)
			{
				if (botcount <= 1)
				{
					ForceMaxAmmo(deadguy)
				}
			}
			if (deadguy.GetScriptScope().Preserved.zombie_type == 5)
			{
				EntFireByHandle(deadguy, "runscriptcode", "SpawnEntityFromTable(`npc_handgrenade`{origin = self.GetCenter()})",0, deadguy, deadguy) 
			}
			// kill money
			if (attacker == null) return
			if (attacker.GetTeam() == 2)
			{
				local currency = GetPropInt(FindByClassname(null, "tf_mann_vs_machine_stats"),"m_currentWaveStats.nCreditsAcquired")
				payout = -40
				assist = -25
				local multiplier = attacker.GetScriptScope().Preserved.multiplier
				if (multiplier == null)
				{
					printl("wtf??")
					multiplier = 0
				}
				if (damagebits & DMG_CRITICAL) // fancy bullet
				{
					payout = -90
					assist = -50
				}
				if (damagebits & DMG_CLUB) // melee
				{
					payout = -120
					assist = -75
				}
				attacker.RemoveCurrency(payout * multiplier)
				if (assister != null && assister.IsAlive())
				{
					assister.RemoveCurrency(assist * multiplier) // assist money
				}
				currency = currency + (payout*-1)
				SetPropInt(FindByClassname(null, "tf_mann_vs_machine_stats"),"m_currentWaveStats.nCreditsAcquired",currency)
				SetPropInt(FindByClassname(null, "tf_mann_vs_machine_stats"),"m_currentWaveStats",currency)
			}
		}
		if (deadguy.GetTeam() == 2)
		{
			deadguy.SetCustomModelWithClassAnimations(PlayerModels[playerclass])
			deadguy.RemoveCurrency(deadguy.GetCurrency() * 0.05)
			if ("gasheld" in deadguy.GetScriptScope().Preserved) DropGascans(deadguy)
			if (PopExtUtil.CountAlivePlayers() == 1) LastManWarning()
			EntFire("tf_gamerules", "RunScriptCode", "if (PopExtUtil.CountAlivePlayers() == 0) EntFire(`gameover_relay`, `trigger`)")
			EntFireByHandle(deadguy,"runscriptcode","for (local entity; entity = Entities.FindByClassname(entity, `entity_revive_marker`);){SetPropBool(entity,`m_bGlowEnabled`,true)}",0.2,null,deadguy);
		}
	}
	function OnGameEvent_player_disconnect(params)
	{
		local quitter = GetPlayerFromUserID(params.userid)
		if (quitter == null) return
		if (quitter.GetTeam() == 2)	// no no, no no no no
		{
			local scope = quitter.GetScriptScope();
			if ("gasheld" in scope.Preserved) DropGascans(quitter)
		}
	}
	function OnGameEvent_teamplay_round_win(params)
	{
		if (params.team == 3) SendGlobalGameEvent("tf_game_over", {})
	}
}

__CollectGameEventCallbacks(RedRidgeEvents)
