::CONST       <- getconsttable()
::ROOT        <- getroottable()
::MAX_CLIENTS <- MaxClients().tointeger()

IncludeScript("alternatewaves", getroottable())
IncludeScript("tankextensions_main", getroottable())
IncludeScript("tankextensions/combattank", getroottable())
IncludeScript("tankextensions/combattank_weapons/minigun", getroottable())
PrecacheModel("models/bots/boss_bot/paintable_tank_v2/boss_tank.mdl")
PrecacheModel("models/bots/boss_bot/paintable_tank_v2/tank_track_l.mdl")
PrecacheModel("models/bots/boss_bot/paintable_tank_v2/tank_track_r.mdl")
PrecacheModel("models/bots/boss_bot/paintable_tank_v2/bomb_mechanism.mdl")
TankExt.NewTankScript("painttank*", {
	Model = {
		Default    = "models/bots/boss_bot/paintable_tank_v2/boss_tank.mdl"
		LeftTrack  = "models/bots/boss_bot/paintable_tank_v2/tank_track_l.mdl"
		RightTrack = "models/bots/boss_bot/paintable_tank_v2/tank_track_r.mdl"
		Bomb       = "models/bots/boss_bot/paintable_tank_v2/bomb_mechanism.mdl"
	}
	OnSpawn = function(hTank, sName, hPath)
	{
		local sParams = split(sName, "|")
		if(sParams.len() == 1) sParams.append("255 255 255")
		TankExt.SetTankColor(hTank, sParams[1])
	}
})
PrecacheModel("models/props_halloween/ghost_no_hat.mdl")
PrecacheModel("models/props_halloween/ghost_no_hat_red.mdl")
PrecacheModel("models/props_graveyard/healing_ghost.mdl")
PrecacheScriptSound("Halloween.GhostBoo")

if (!("ConstantNamingConvention" in ROOT))
	foreach (a,b in Constants)
		foreach (k,v in b)
		{
			CONST[k] <- v != null ? v : 0
			ROOT[k] <- v != null ? v : 0
		}

foreach(k, v in ::Entities.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::Entities[k].bindenv(::Entities)

foreach(k, v in ::NetProps.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::NetProps[k].bindenv(::NetProps)

local OTHER_CONSTANTS = {
	MASK_ALL                   = -1
	MASK_SPLITAREAPORTAL       = 48
	MASK_SOLID_BRUSHONLY       = 16395
	MASK_WATER                 = 16432
	MASK_BLOCKLOS              = 16449
	MASK_OPAQUE                = 16513
	MASK_DEADSOLID             = 65547
	MASK_PLAYERSOLID_BRUSHONLY = 81931
	MASK_NPCWORLDSTATIC        = 131083
	MASK_NPCSOLID_BRUSHONLY    = 147467
	MASK_CURRENT               = 16515072
	MASK_SHOT_PORTAL           = 33570819
	MASK_SOLID                 = 33570827
	MASK_BLOCKLOS_AND_NPCS     = 33570881
	MASK_OPAQUE_AND_NPCS       = 33570945
	MASK_VISIBLE_AND_NPCS      = 33579137
	MASK_PLAYERSOLID           = 33636363
	MASK_NPCSOLID              = 33701899
	MASK_SHOT_HULL             = 100679691
	MASK_SHOT                  = 1174421507

	LIFE_ALIVE       = 0
	LIFE_DYING       = 1
	LIFE_DEAD        = 2
	LIFE_RESPAWNABLE = 3
	LIFE_DISCARDBODY = 4

	TF_STUN_NONE                  = 0
	TF_STUN_MOVEMENT              = 1
	TF_STUN_CONTROLS              = 2
	TF_STUN_MOVEMENT_FORWARD_ONLY = 4
	TF_STUN_SPECIAL_SOUND         = 8
	TF_STUN_DODGE_COOLDOWN        = 16
	TF_STUN_NO_EFFECTS            = 32
	TF_STUN_LOSER_STATE           = 64
	TF_STUN_BY_TRIGGER            = 128
	TF_STUN_SOUND                 = 256

	SND_NOFLAGS                              = 0
	SND_CHANGE_VOL                           = 1
	SND_CHANGE_PITCH                         = 2
	SND_STOP                                 = 4
	SND_SPAWNING                             = 8
	SND_DELAY                                = 16
	SND_STOP_LOOPING                         = 32
	SND_SPEAKER                              = 64
	SND_SHOULDPAUSE                          = 128
	SND_IGNORE_PHONEMES                      = 256
	SND_IGNORE_NAME                          = 512
	SND_DO_NOT_OVERWRITE_EXISTING_ON_CHANNEL = 1024

	DEG2RAD = 0.0174532924
	RAD2DEG = 57.295779513
	FLT_MIN = 1.175494e-38
	FLT_MAX = 3.402823466e+38
	INT_MIN = -2147483648
	INT_MAX = 2147483647

	DAMAGE_NO          = 0
	DAMAGE_EVENTS_ONLY = 1
	DAMAGE_YES         = 2
	DAMAGE_AIM         = 3

	OBJ_DISPENSER         = 0
	OBJ_TELEPORTER        = 1
	OBJ_SENTRYGUN         = 2
	OBJ_ATTACHMENT_SAPPER = 3
	OBJ_LAST              = 4

	TF_AMMO_DUMMY     = 0
	TF_AMMO_PRIMARY   = 1
	TF_AMMO_SECONDARY = 2
	TF_AMMO_METAL     = 3
	TF_AMMO_GRENADES1 = 4
	TF_AMMO_GRENADES2 = 5
	TF_AMMO_GRENADES3 = 6

	TFCOLLISION_GROUP_GRENADES                          = 20
	TFCOLLISION_GROUP_OBJECT                            = 21
	TFCOLLISION_GROUP_OBJECT_SOLIDTOPLAYERMOVEMENT      = 22
	TFCOLLISION_GROUP_COMBATOBJECT                      = 23
	TFCOLLISION_GROUP_ROCKETS                           = 24
	TFCOLLISION_GROUP_RESPAWNROOMS                      = 25
	TFCOLLISION_GROUP_PUMPKIN_BOMB                      = 26
	TFCOLLISION_GROUP_ROCKET_BUT_NOT_WITH_OTHER_ROCKETS = 27

	// damagefilter redefinitions
	DMG_USE_HITLOCATIONS                    = DMG_AIRBOAT
	DMG_HALF_FALLOFF                        = DMG_RADIATION
	DMG_CRITICAL                            = DMG_ACID
	DMG_RADIUS_MAX                          = DMG_ENERGYBEAM
	DMG_IGNITE                              = DMG_PLASMA
	DMG_USEDISTANCEMOD                      = DMG_SLOWBURN
	DMG_NOCLOSEDISTANCEMOD                  = DMG_POISON
	DMG_MELEE                               = DMG_BLAST_SURFACE
	DMG_DONT_COUNT_DAMAGE_TOWARDS_CRIT_RATE = DMG_DISSOLVE
}
foreach(k,v in OTHER_CONSTANTS)
	if(!(k in ROOT))
	{
		CONST[k] <- v
		ROOT[k] <- v
	}

PrecacheSound("#trespasser_v2/music_spawnroom.wav")
for(local i = 1; i <= MAX_PLAYERS; i++)
{
	local hPlayer = PlayerInstanceFromIndex(i)
	if(!hPlayer || hPlayer.IsFakeClient()) continue
	EmitSoundEx({
		sound_name  = "#trespasser_v2/music_spawnroom.wav"
		volume      = 0.65
		pitch       = 85
		entity      = hPlayer
		filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
	})
}

if(!("TrespasserLosses" in ROOT))
	::TrespasserLosses <- 0

if(!("TrespasserSeenMerasmusWarning" in ROOT))
	::TrespasserSeenMerasmusWarning <- []

local SpawnSkull = function(pos, ang, mdltype)
	SpawnEntityFromTable("prop_dynamic", {
		origin         = pos
		angles         = ang
		model          = mdltype == 0 ? "models/props_mvm/mvm_human_skull.mdl" : "models/props_mvm/mvm_human_skull_collide.mdl"
		disableshadows = 1
	})

switch(TrespasserLosses > 24 ? 24 : TrespasserLosses)
{
	case 24:
		SpawnSkull("985 1574 237.5", "-30 255 0", 0)
		SpawnEntityFromTable("prop_dynamic", {
			origin         = "973.75 1532 171.5"
			angles         = "-30 255 0"
			model          = "models/player/items/all_class/sd_glasses_sniper_cigar.mdl"
			disableshadows = 1
		})
		SpawnEntityFromTable("prop_dynamic", {
			origin         = "974 1533.5 163"
			angles         = "-30 255 0"
			model          = "models/player/items/demo/top_hat.mdl"
			modelscale     = 1.1
			disableshadows = 1
		})
	case 23:
		SpawnSkull("976 1582 237.5", "-30 255 0", 0)
	case 22:
		SpawnSkull("967 1581 238", "-30 270 0", 1)
	case 21:
		SpawnSkull("957 1582 238", "-30 255 0", 1)
	case 20:
		SpawnSkull("948 1582 237.5", "-30 270 0", 0)
	case 19:
		SpawnSkull("939 1582 237.5", "-30 285 0", 0)
	case 18:
		SpawnSkull("929 1583 238", "-30 270 0", 1)
	case 17:
		SpawnSkull("919 1581 237.5", "-30 255 0", 0)
	case 16:
		SpawnSkull("910 1583 238", "-30 255 0", 1)
	case 15:
		SpawnSkull("901 1582 238", "-30 285 0", 1)
	case 14:
		SpawnSkull("891 1581 238", "-30 270 0", 1)
	case 13:
		SpawnSkull("882 1585 238", "-27 255 0", 1)
	case 12:
		SpawnSkull("873 1582 237.5", "-27 300 0", 0)
	case 11:
		SpawnSkull("862 1580 237.5", "-27 240 0", 0)
	case 10:
		SpawnSkull("853 1582 238", "-30 270 0", 1)
	case 9:
		SpawnSkull("844 1582 237.5", "-27 285 0", 0)
	case 8:
		SpawnSkull("834 1585 237.5", "-30 255 0", 0)
	case 7:
		SpawnSkull("825 1585 237.5", "-30 285 0", 0)
	case 6:
		SpawnSkull("816 1583 238", "-30 285 0", 1)
	case 5:
		SpawnSkull("806 1585 238", "-27 285 0", 1)
	case 4:
		SpawnSkull("796 1585 237.5", "-27 275 0", 0)
	case 3:
		SpawnSkull("786 1584 237.5", "-27 265 0", 0)
	case 2:
		SpawnSkull("776 1584 238", "-30 255 0", 1)
	case 1:
		SpawnSkull("766 1584 237.5", "-27 285 0", 0)
}

local hObjectiveResource = FindByClassname(null, "tf_objective_resource")
local hPlayerManager     = FindByClassname(null, "tf_player_manager")
local hGameRules         = FindByClassname(null, "tf_gamerules")
if(hObjectiveResource) hObjectiveResource.AcceptInput("$SetClientProp$m_iszMvMPopfileName", "(Expert) Trespasser Remaster", null, null)
::Trespasser <- {
	// Cleanup
	function OnGameEvent_recalculate_holidays(_)
	{
		if(GetRoundState() == 3)
		{
			local hObjectiveResource = FindByClassname(null, "tf_objective_resource")
			local hGameRules = FindByClassname(null, "tf_gamerules")

			if(hObjectiveResource && hObjectiveResource.IsValid())
			{
				hObjectiveResource.AcceptInput("$ResetClientProp$m_iszMvMPopfileName", null, null, null)
				if(GetPropString(FindByClassname(null, "tf_objective_resource"), "m_iszMvMPopfileName").find("trespasser_remaster") == null)
				{
					Convars.SetValue("sig_etc_unintended_class_weapon_display_meters", 1)
					Convars.SetValue("tf_ghost_xy_speed", 300)
				}
			}
			if(hGameRules)
			{
				SetPropInt(hGameRules, "m_halloweenScenario", 0)
				SetPropBool(hGameRules, "m_bShowMatchSummary", false)
			}

			for(local i = 1; i <= MAX_PLAYERS; i++)
			{
				local hPlayer = PlayerInstanceFromIndex(i)
				if(!hPlayer) continue
				CleanupPlayer(hPlayer)
				if(hPlayer.IsBotOfType(TF_BOT_TYPE)) continue

				if(hPlayer.GetTeam() == TF_TEAM_BLUE)
				{
					hPlayer.ForceChangeTeam(TF_TEAM_RED, true)
					hPlayer.ForceRespawn()
				}

				EmitSoundEx({
					sound_name  = "#trespasser_v2/music_spawnroom.wav"
					entity      = hPlayer
					filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
					flags       = SND_STOP
				})
			}
			ClientPrint(null, HUD_PRINTCENTER, "")

			if(hThinkEnt && hThinkEnt.IsValid())
				hThinkEnt.Kill()

			EntFire("target_alwaystransmit", "Kill")

			delete ::Trespasser
		}
	}

	Wins = {}
	iProxyMineModelIndex = PrecacheModel("models/pickups/emitter.mdl")
	iBugBaitModelIndex = PrecacheModel("models/weapons/w_bugbait.mdl")

	function GetPlayerWins()
	{
		Wins.clear()
		for(local i = 1; i <= MAX_PLAYERS; i++)
		{
			local hPlayer = PlayerInstanceFromIndex(i)
			if(!hPlayer || hPlayer.IsFakeClient()) continue
			local sNetworkID = GetPropString(hPlayer, "m_szNetworkIDString")
			if(sNetworkID == "" || sNetworkID == "BOT") continue

			local sNetworkIDSlice = sNetworkID.slice(5, sNetworkID.find("]"))
			// local sScriptData = FileToString(format("trespasser_remaster_wins/updated/player_%s.txt", sNetworkIDSlice))
			// if(sScriptData != null)
			// 	compilestring(format("Trespasser.Wins[\"%s\"] <- %s", sNetworkID, sScriptData))()

			//test database read
			if ("VPI" in ROOT)
				VPI.AsyncCall({
					func="VPI_DB_Trespasser_ReadWrite",
					kwargs= {
						query_mode="read",
						network_id=sNetworkIDSlice
					},
					callback=function(response, error) {

						if (typeof(response) != "array" || !response.len())
						{
							Trespasser.Wins[sNetworkID] <- [0, false, false]
							printl("empty win data for " + sNetworkID + ": " + response)
							return;
						}
						local r = response[0]
						printl("READ: Win data for " + sNetworkID + ": "+r[0]+"|"+r[1]+"|"+r[2])

						Trespasser.Wins[sNetworkID] <- [r[0], r[1], r[2]]
					}
				})
			// Wins[sNetworkID] <- [10, true, true] // debug
		}
	}
	function SavePlayerWins()
	{
		local PlayerNames = {}
		for(local i = 1; i <= MAX_PLAYERS; i++)
		{
			local hPlayer = PlayerInstanceFromIndex(i)
			if(!hPlayer || hPlayer.IsFakeClient()) continue
			local sNetworkID = GetPropString(hPlayer, "m_szNetworkIDString")
			PlayerNames[sNetworkID] <- GetPropString(hPlayer, "m_szNetname")
		}
		foreach(sNetworkID, Array in Wins)
		{
			local sName = ""
			if(sNetworkID in PlayerNames)
				sName = PlayerNames[sNetworkID]
			StringToFile(format("trespasser_remaster_wins/updated/player_%s.txt", sNetworkID.slice(5, sNetworkID.find("]"))), format("[%i, %s, %s] // %s\n", Array[0], Array[1].tostring(), Array[2].tostring(), sName))

			local sNetworkIDSlice = sNetworkID.slice(5, sNetworkID.find("]"))
			//test database write
			if ("VPI" in ROOT)
				VPI.AsyncCall({
					func="VPI_DB_Trespasser_ReadWrite",
					kwargs= {
						query_mode="write",
						network_id=sNetworkIDSlice,
						wins=Array[0],
						solo_win=Array[1],
						all_survivors_alive_win=Array[2]
					}
				})
		}
	}

	function IsAliveExtra(hPlayer)
	{
		return hPlayer.IsAlive() && !hPlayer.InCond(TF_COND_HALLOWEEN_GHOST_MODE) && hPlayer.GetHealth() > 0
	}

	bAllSurvivorsAlive = true
	function OnGameEvent_mvm_mission_complete(_)
	{
		GetPlayerWins()
		for(local i = 1; i <= MAX_PLAYERS; i++)
		{
			local hPlayer = PlayerInstanceFromIndex(i)
			if(!hPlayer || hPlayer.IsFakeClient() || hPlayer.GetTeam() <= TEAM_SPECTATOR) continue
			local sNetworkID = GetPropString(hPlayer, "m_szNetworkIDString")

			if(sNetworkID in Wins)
				Wins[sNetworkID][0]++
			else
				Wins[sNetworkID] <- [1, false, false]

			local sPlayerName = GetPropString(hPlayer, "m_szNetname")

			local bSoloUnlock = false
			if(bSoloMode && !Wins[sNetworkID][1])
			{
				bSoloUnlock = true
				Wins[sNetworkID][1] = true
			}

			local bAllSurvivorsAliveUnlock = false
			if(bAllSurvivorsAlive && !Wins[sNetworkID][2])
			{
				bAllSurvivorsAliveUnlock = true
				Wins[sNetworkID][2] = true
			}

			EntFire("bignet", "RunScriptCode", format("Trespasser.UnlockText(%i, `%s`, %s, %s)", Wins[sNetworkID][0], sPlayerName, bSoloUnlock ? "true" : "false", bAllSurvivorsAliveUnlock ? "true" : "false"), 1, hPlayer)
		}
		SavePlayerWins()
	}
	function UnlockText(iWins, sPlayerName, bSoloMode, bAllSurvivorsAlive)
	{
		local hPlayer = activator
		local bPlayedSoundThisTick = false
		local AchievementSound = function()
		{
			if(!bPlayedSoundThisTick)
			{
				bPlayedSoundThisTick = true
				PrecacheSound("misc/achievement_earned.wav")
				EmitSoundEx({
					sound_name = "misc/achievement_earned.wav"
					entity = hPlayer
					filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
				})
				EmitSoundEx({
					sound_name = "misc/achievement_earned.wav"
					entity = hPlayer
					filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
				})
			}
		}
		switch(iWins)
		{
			case 1:
				ClientPrint(null, HUD_PRINTTALK, format("\x07FF3F3F%s \x01has earned the weapon \x079EC34FHeavy Machine Gun \x01for Sniper", sPlayerName))
				AchievementSound()
				break
			case 2:
				ClientPrint(null, HUD_PRINTTALK, format("\x07FF3F3F%s \x01has earned the weapon \x079EC34FIncendiary Rifle \x01for Pyro", sPlayerName))
				AchievementSound()
				break
			case 3:
				ClientPrint(null, HUD_PRINTTALK, format("\x07FF3F3F%s \x01has earned the weapon \x079EC34FSlug Rifle \x01for Soldier", sPlayerName))
				AchievementSound()
				break
			case 4:
				ClientPrint(null, HUD_PRINTTALK, format("\x07FF3F3F%s \x01has earned the weapon \x079EC34FDustbowl Eagle \x01for Engineer", sPlayerName))
				AchievementSound()
				break
			case 5:
				ClientPrint(null, HUD_PRINTTALK, format("\x07FF3F3F%s \x01has earned the weapon \x079EC34FChainsaw \x01for Heavy", sPlayerName))
				AchievementSound()
				break
			case 10:
				ClientPrint(null, HUD_PRINTTALK, format("\x07FF3F3F%s \x01has earned the weapon \x079EC34FCeremonial Bow \x01for Sniper", sPlayerName))
				AchievementSound()
				break
		}
		if(bSoloMode)
		{
			ClientPrint(null, HUD_PRINTTALK, format("\x07FF3F3F%s \x01has earned the item \x079EC34FDeathly Canteen", sPlayerName))
			AchievementSound()
		}
		if(bAllSurvivorsAlive)
		{
			ClientPrint(null, HUD_PRINTTALK, format("\x07FF3F3F%s \x01has earned the weapon \x079EC34FGrappling Hook", sPlayerName))
			AchievementSound()
		}
	}

	// Setup Music
	bMusic = true
	function SetMusicState(bool)
	{
		bMusic = bool
		for(local i = 1; i <= MAX_PLAYERS; i++)
		{
			local hPlayer = PlayerInstanceFromIndex(i)
			if(!hPlayer || hPlayer.IsFakeClient()) continue
			EmitSoundEx({
				sound_name  = "#trespasser_v2/music_spawnroom.wav"
				volume      = 0.65
				pitch       = 85
				entity      = hPlayer
				filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
				flags       = bool ? SND_NOFLAGS : SND_STOP
			})
		}
	}

	// OnKilled functions
	function SetDestroyCallback(entity, callback)
	{
		entity.ValidateScriptScope();
		local scope = entity.GetScriptScope();
		scope.setdelegate({}.setdelegate({
				parent   = scope.getdelegate()
				id       = entity.GetScriptId()
				index    = entity.entindex()
				callback = callback
				_get = function(k)
				{
					return parent[k];
				}
				_delslot = function(k)
				{
					if (k == id)
					{
						entity = EntIndexToHScript(index);
						local scope = entity.GetScriptScope();
						scope.self <- entity;
						callback.pcall(scope);
					}
					delete parent[k];
				}
			})
		);
	}

	// quit getting stuck in stuff
	function UnstuckEntity(hEntity, vecBoundingMins = null, vecBoundingMaxs = null)
	{
		local vecOrigin = hEntity.GetOrigin()
		local Trace = {
			start = vecOrigin
			end = vecOrigin
			hullmin = vecBoundingMins == null ? hEntity.GetBoundingMins() : vecBoundingMins
			hullmax = vecBoundingMaxs == null ? hEntity.GetBoundingMaxs() : vecBoundingMaxs
			mask = MASK_PLAYERSOLID
			ignore = hEntity
		}
		TraceHull(Trace)
		if("startsolid" in Trace)
		{
			local Dirs = [Vector(1, 0, 0), Vector(-1, 0, 0), Vector(0, 1, 0), Vector(0, -1, 0), Vector(0, 0, 1), Vector(0, 0, -1)]
			for (local i = 16; i <= 128; i += 16)
			{
				foreach (vecDir in Dirs)
				{
					Trace.start = vecOrigin + vecDir * i
					Trace.end = Trace.start
					delete Trace.startsolid
					TraceHull(Trace)
					if (!("startsolid" in Trace))
					{
						hEntity.SetAbsOrigin(Trace.end)
						return true
					}
				}
			}
			return false
		}
		return true
	}
	function UnstuckEntityIgnorePlayers(hEntity, vecBoundingMins = null, vecBoundingMaxs = null)
	{
		local NotSolidList = {}
		for(local i = 0; i <= MAX_CLIENTS; i++)
		{
			local hPlayer = PlayerInstanceFromIndex(i)
			if(hPlayer && hPlayer.IsAlive() && hPlayer.GetSolid() != FSOLID_NOT_SOLID)
				NotSolidList[hPlayer] <- hPlayer.GetSolid(), hPlayer.SetSolid(FSOLID_NOT_SOLID)
		}
		UnstuckEntity(hEntity, vecBoundingMins, vecBoundingMaxs)
		foreach(hPlayer, iSolid in NotSolidList)
			hPlayer.SetSolid(iSolid)
	}

	// If box is within other box
	function IntersectionBoxBox(xorigin, xmins, xmaxs, yorigin, ymins, ymaxs)
	{
		xmins += xorigin
		xmaxs += xorigin
		ymins += yorigin
		ymaxs += yorigin
		return (xmins.x <= ymaxs.x && xmaxs.x >= ymins.x) &&
			(xmins.y <= ymaxs.y && xmaxs.y >= ymins.y) &&
			(xmins.z <= ymaxs.z && xmaxs.z >= ymins.z)
	}

	// to revert the few things set on players that need to go away
	function CleanupPlayer(hPlayer)
	{
		SetPropBool(hPlayer, "m_bForcedSkin", false)
		SetPropInt(hPlayer, "m_nForcedSkin", 0)
		hPlayer.KeyValueFromInt("rendermode", 0)
		hPlayer.KeyValueFromInt("renderfx", 0)
		hPlayer.KeyValueFromInt("renderamt", 255)
		hPlayer.AcceptInput("color", "255 255 255", null, null)
		DispatchParticleEffectOn(hPlayer, null)
		SetPropIntArray(hPlayer, "m_nModelIndexOverrides", 0, 0)
		AddThinkToEnt(hPlayer, null)
		hPlayer.TerminateScriptScope()
		if(!hPlayer.IsBotOfType(TF_BOT_TYPE))
		{
			SetPropInt(hPlayer, "m_iFOV", 0)
			hPlayer.SetForceLocalDraw(false)
			hPlayer.SetScriptOverlayMaterial(null)
			hPlayer.SetCustomModelWithClassAnimations(null)
		}
	}

	// Camera Intro Sequence
	function StartCamera()
	{
		ScreenFade(null, 0, 0, 0, 255, 1, 0.033, 2)
		local hCameraProp = SpawnEntityFromTable("prop_dynamic", {
			model          = "models/props_mvm/trespasser_camera.mdl"
			startdisabled  = 1
			disableshadows = 1
			"OnAnimationDone" : "!self,Kill,,-1,-1"
		})
		local hCamera = SpawnEntityFromTable("point_viewcontrol", { targetname = "trespasser_camera" })

		hCamera.AcceptInput("SetParent", "!activator", hCameraProp, null)
		hCamera.AcceptInput("SetParentAttachment", "camera", null, null)
		SetDestroyCallback(hCamera, function()
		{
			self.AcceptInput("$DisableAll", null, null, null)
			SetPropBool(hGameRules, "m_bShowMatchSummary", false)
			ScreenFade(null, 0, 0, 0, 255, 1, 0, 1)

			for(local i = 1; i <= MAX_CLIENTS; i++)
			{
				local hPlayer = PlayerInstanceFromIndex(i)
				if(!hPlayer || hPlayer.IsFakeClient()) continue
				if(hPlayer.GetTeam() >= 2)
				{
					hPlayer.RemoveCond(TF_COND_TAUNTING)
					hPlayer.SetForceLocalDraw(false)
					hPlayer.SetHudHideFlags(0)
				}
				SetPropInt(hPlayer, "m_iFOV", 0)
			}
		})

		EntFireByHandle(hCamera, "RunScriptCode", "Trespasser.InitializeCamera(activator, self)", 1, hCameraProp, null)
	}
	function InitializeCamera(hCameraProp, hCamera)
	{
		SetPropBool(hGameRules, "m_bShowMatchSummary", true)
		hCameraProp.AcceptInput("SetAnimation", "camera", null, null)
		hCameraProp.AcceptInput("Enable", null, null, null)
		hCamera.AcceptInput("$EnableAll", null, null, null)

		for(local i = 1; i <= MAX_CLIENTS; i++)
		{
			local hPlayer = PlayerInstanceFromIndex(i)
			if(!hPlayer || hPlayer.IsFakeClient()) continue
			if(hPlayer.GetTeam() >= 2)
			{
				hPlayer.RemoveCond(TF_COND_TAUNTING)
				hPlayer.SetForceLocalDraw(true)
				local hWeapon = hPlayer.GetActiveWeapon()
				if(hWeapon) hWeapon.EnableDraw()
				hPlayer.SetHudHideFlags(0xffffffff & ~(HIDEHUD_CHAT | HIDEHUD_ALL))
			}
		}

		hCamera.ValidateScriptScope()
		hCamera.GetScriptScope().Think <- function()
		{
			for(local i = 1; i <= MAX_CLIENTS; i++)
			{
				local hPlayer = PlayerInstanceFromIndex(i)
				if(!hPlayer || hPlayer.IsFakeClient()) continue
				hPlayer.SetForcedTauntCam(0)
				SetPropInt(hPlayer, "m_iFOV", 75)
			}
			return -1
		}
		AddThinkToEnt(hCamera, "Think")
	}

	// Red-Tape Recorder : Reprogrammed Neutral
	function OnGameEvent_player_stunned(params)
	{
		local hStunner
		if("stunner" in params)
			hStunner = GetPlayerFromUserID(params.stunner)

		local hVictim
		if("victim" in params)
			hVictim = GetPlayerFromUserID(params.victim)

		if(!hStunner || !hVictim || !hVictim.IsBotOfType(TF_BOT_TYPE)) return

		if(hVictim.HasBotTag("bot_nogray")) return

		local bHasRTR = false
		for(local i = 0; i <= 8; i++)
		{
			local hWeapon = GetPropEntityArray(hStunner, "m_hMyWeapons", i)
			if(hWeapon && GetPropInt(hWeapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 810)
				{ bHasRTR = true; break }
		}
		if(bHasRTR)
		{
			local hObjSapper
			while(hObjSapper = FindByClassname(hObjSapper, "obj_attachment_sapper"))
				if(GetPropEntity(hObjSapper, "m_hBuilder") == hStunner)
					break

			if(!hObjSapper) return

			hObjSapper.ValidateScriptScope()
			local hObjSapper_scope = hObjSapper.GetScriptScope()
			if(!("hBots" in hObjSapper_scope))
			{
				hObjSapper.AcceptInput("ClearParent", null, null, null)
				hObjSapper_scope.hSappedBot <- GetPropEntity(hObjSapper, "m_hBuiltOnEntity")
				hObjSapper_scope.hBots <- {}
				hObjSapper_scope.Think <- function()
				{
					local PlayerAlive = @(handle) handle && handle.IsValid() && handle.IsAlive()
					foreach(hBot, Array in hBots)
					{
						local bBotValid = hBot.IsValid()
						if(!bBotValid || !hBot.IsAlive())
						{
							if(bBotValid)
							{
								local hParticle = Array[0]
								if(hParticle && hParticle.IsValid()) hParticle.Kill()
								local hGlow = Array[3]
								if(hGlow && hGlow.IsValid()) hGlow.Kill()
								SetPropBool(hBot, "m_bForcedSkin", false)
								SetPropInt(hBot, "m_nForcedSkin", 0)
								hBot.AcceptInput("$ResetClientProp$m_iTeamNum", null, null, null)
							}
							delete hBots[hBot]
							continue
						}

						if(!PlayerAlive(hSappedBot))
						{
							hSappedBot = hBot
							SetPropEntity(hObjSapper, "m_hBuiltOnEntity", hBot)
						}
						hBot.RemoveCond(TF_COND_STUNNED)
						hBot.RemoveCond(TF_COND_SAPPED)
					}
					if(!PlayerAlive(hSappedBot))
						{ self.AcceptInput("RemoveHealth", "9999", null, null); return }
					self.SetAbsOrigin(hSappedBot.GetAttachmentOrigin(1))
					self.SetAbsAngles(hSappedBot.GetAttachmentAngles(1))
					return -1
				}
				AddThinkToEnt(hObjSapper, "Think")
				Trespasser.SetDestroyCallback(hObjSapper, function()
				{
					foreach(hBot, Array in hBots)
					{
						hBot.AcceptInput("$RemoveCond", "159", null, null)
						hBot.AcceptInput("$ChangeAttributes", "RevertGray", null, null)

						foreach(Attribute, Value in Array[1])
						{
							if(typeof Value == "function")
								Value(hBot)
							else
								hVictim.AcceptInput("$RemoveItemAttribute", format("%s|%i", Attribute, Array[2]), null, null)
						}

						local hParticle = Array[0]
						if(hParticle && hParticle.IsValid()) hParticle.Kill()
						local hGlow = Array[3]
						if(hGlow && hGlow.IsValid()) hGlow.Kill()
						SetPropBool(hBot, "m_bForcedSkin", false)
						SetPropInt(hBot, "m_nForcedSkin", 0)
						hBot.AcceptInput("$ResetClientProp$m_iTeamNum", null, null, null)

						local iTeamNum = hBot.GetTeam()
						for(local i = 0; i <= 8; i++)
						{
							local hWeapon = GetPropEntityArray(hBot, "m_hMyWeapons", i)
							if(hWeapon) hWeapon.SetTeam(iTeamNum)
						}
					}
				})
			}

			local hParticle = SpawnEntityFromTable("info_particle_system", {
				origin = hVictim.GetOrigin()
				effect_name = "medic_resist_bullet"
				start_active = 1
			})
			hParticle.AcceptInput("SetParent", "!activator", hVictim, null)

			// the gray models felt like wasted space
			local hGlow = SpawnEntityFromTable("tf_glow", {
				GlowColor = "194 194 194 255"
				target = "bignet"
			})
			SetPropEntity(hGlow, "m_hTarget", hVictim)
			SetPropBool(hVictim, "m_bForcedSkin", true)
			SetPropInt(hVictim, "m_nForcedSkin", hVictim.GetSkin())
			hVictim.AcceptInput("$ChangeAttributes", "Gray", null, null)
			hVictim.AcceptInput("$SetClientProp$m_iTeamNum", "3", null, null)
			hVictim.AcceptInput("$AddCond", "159", null, null)
			local Attributes = {}
			if(hVictim.HasBotTag("gray_generic"))
			{
				Attributes["ammo regen"]            <- 1
				Attributes["crit mod disabled"]     <- 0
				Attributes["use robot voice"]       <- 1
				Attributes["additional step sound"] <- "MVM.BotStep"
				Attributes["set item tint RGB"]     <- 8289918
				Attributes["receive friendly fire"] <- 1
			}
			if(hVictim.HasBotTag("gray_robrute"))
			{
				EntFire("player", "$PlaySoundToSelf", "ambient/machines/thumper_shutdown1.wav")
				for(local hChild = hVictim.FirstMoveChild(); hChild; hChild = hChild.NextMovePeer())
					if(GetPropInt(hChild, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 31279)
					{
						hChild.AddAttribute("set item tint rgb", 16711680, -1)
						hChild.AddAttribute("attach particle effect", 0, -1)
						break
					}
				Attributes["callback"] <- function(hBot)
				{
					EntFire("player", "$PlaySoundToSelf", "ambient/machines/thumper_startup1.wav")
					for(local hChild = hBot.FirstMoveChild(); hChild; hChild = hChild.NextMovePeer())
						if(GetPropInt(hChild, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 31279)
						{
							hChild.AddAttribute("set item tint rgb", 3329330, -1)
							hChild.AddAttribute("attach particle effect", 0, -1)
							break
						}
				}
			}
			if(hVictim.HasBotTag("gray_medic"))
			{
				Attributes["medigun particle"] <- "~medicgun_beam_machinery"
			}
			foreach(Attribute, Value in Attributes)
				hVictim.AcceptInput("$AddItemAttribute", Attribute + "|" + Value, null, null)

			hObjSapper_scope.hBots[hVictim] <- [hParticle, Attributes, hVictim.GetActiveWeapon().GetSlot(), hGlow]
		}
	}

	// Infected Sniper Viewmodel
	// except now its completely different
	function SetInfectedSniperViewmodel()
	{
		local hPlayer = self
		local hWeapon
		for(local i = 0; i <= 8; i++)
		{
			local hWeaponTemp = GetPropEntityArray(hPlayer, "m_hMyWeapons", i)
			if(hWeaponTemp && hWeaponTemp.GetSlot() == 2)
				{ hWeapon = hWeaponTemp; break }
		}
		if(!hWeapon) return

		hPlayer.SetForcedTauntCam(1)
		hPlayer.RemoveCond(TF_COND_TAUNTING)
		hPlayer.Weapon_Switch(hWeapon)
		hPlayer.AcceptInput("$TauntFromItem", "Taunt: Burstchester", null, null)
		hPlayer.AddCustomAttribute("dmg taken increased", 0.25, -1)
		SetPropBool(hPlayer, "m_bForcedSkin", true)
		SetPropInt(hPlayer, "m_nForcedSkin", hPlayer.GetPlayerClass() == TF_CLASS_SPY ? 23 : 5)

		local ZombieCosmetics = [5617, 5617, 5625, 5618, 5620, 5622, 5619, 5624, 5623, 5621, 5621]
		SetPropInt(hWeapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", ZombieCosmetics[hPlayer.GetPlayerClass()])

		local hTemp = CreateByClassname("tf_weapon_parachute")
		SetPropInt(hTemp, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 1101)
		SetPropBool(hTemp, "m_AttributeManager.m_Item.m_bInitialized", true)
		hTemp.SetTeam(hPlayer.GetTeam())
		hTemp.DispatchSpawn()
		hPlayer.Weapon_Equip(hTemp)
		local hCosmetic = GetPropEntity(hTemp, "m_hExtraWearable")
		hTemp.Kill()
		SetPropInt(hCosmetic, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", ZombieCosmetics[hPlayer.GetPlayerClass()])
		SetPropBool(hCosmetic, "m_AttributeManager.m_Item.m_bInitialized", true)
		hCosmetic.DispatchSpawn()

		hWeapon.ValidateScriptScope()
		local hWeapon_scope = hWeapon.GetScriptScope()
		hWeapon_scope.bEffects <- false
		hWeapon_scope.Think <- function()
		{
			if(!self.IsValid()) return
			local hWeapon = hPlayer.GetActiveWeapon()
			if(!bEffects && hWeapon == self && !hPlayer.InCond(TF_COND_TAUNTING))
			{
				bEffects = true
				hPlayer.RemoveCustomAttribute("dmg taken increased")
				local hCommand = CreateByClassname("point_clientcommand")
				hCommand.AcceptInput("Command", "r_screenoverlay effects/stealth_overlay", hPlayer, null)
				hCommand.Kill()
				hPlayer.SetScriptOverlayMaterial("debug/hsv")
				hPlayer.SetIsMiniBoss(true)
				ScreenFade(hPlayer, 0, 0, 0, 255, 1, 0, 1)
			}
			return -1
		}
		AddThinkToEnt(hWeapon, "Think")
		Trespasser.SetDestroyCallback(hWeapon, function()
		{
			if(bEffects)
			{
				local hCommand = CreateByClassname("point_clientcommand")
				hCommand.AcceptInput("Command", "r_screenoverlay /", hPlayer, null)
				hCommand.Kill()
				hPlayer.SetScriptOverlayMaterial(null)
				hPlayer.SetIsMiniBoss(false)
			}
			if(hCosmetic && hCosmetic.IsValid()) hCosmetic.Kill()
			SetPropBool(hPlayer, "m_bForcedSkin", false)
			SetPropInt(hPlayer, "m_nForcedSkin", 0)
			SetPropInt(hPlayer, "m_iPlayerSkinOverride", 0)
			hPlayer.SetForcedTauntCam(0)
			hPlayer.RemoveCustomAttribute("dmg taken increased")
		})
	}

	// Merasmus's Staff VFX
	function MerasmusZap()
	{
		local hAttacker = activator
		local hVictim = self
		if(hAttacker == hVictim) return
		hVictim.AcceptInput("IgnitePlayer", null, null, null)
		PrecacheScriptSound("Halloween.Merasmus_Spell")
		hVictim.AcceptInput("$PlaySound", "Halloween.Merasmus_Spell", null, null)
		hVictim.ApplyAbsVelocityImpulse(Vector(0, 0, 256))

		PrecacheScriptSound("Halloween.MerasmusStaffAttack")
		hAttacker.AcceptInput("$PlaySound", "Halloween.MerasmusStaffAttack", null, null)

		local iEffectHandR   = hAttacker.LookupAttachment("effect_hand_R")
		local vecEffectHandR = hAttacker.GetAttachmentOrigin(iEffectHandR)
		local angEffectHandR = hAttacker.GetAttachmentAngles(iEffectHandR)
		local hParticleZap   = SpawnEntityFromTable("info_particle_system", {
			origin = vecEffectHandR + angEffectHandR.Up() * 64
			effect_name = "merasmus_zap"
			start_active = 1
		})
		hParticleZap.SetForwardVector(hAttacker.EyeAngles().Forward())

		SetPropBool(hParticleZap, "m_bForcePurgeFixedupStrings", true)
		local hZapTarget = SpawnEntityFromTable("info_target", { origin = hVictim.GetCenter(), spawnflags = 0x01 })
		SetPropBool(hZapTarget, "m_bForcePurgeFixedupStrings", true)
		SetPropEntityArray(hParticleZap, "m_hControlPointEnts", hZapTarget, 0)
		EntFireByHandle(hParticleZap, "Kill", null, 0.066, null, null)
		EntFireByHandle(hZapTarget, "Kill", null, 0.066, null, null)
	}

	// Merasmus's Bombinomicon (Bombonomicon?)
	function GiveBombinomicon()
	{
		local hPlayer = self
		local hBook
		for(local hChild = hPlayer.FirstMoveChild(); hChild; hChild = hChild.NextMovePeer())
			if(GetPropInt(hChild, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 5606)
				{ hBook = hChild; break }
		if(!hBook) return

		local hGameText = SpawnEntityFromTable("game_text", {
			channel = 0
			color = "255 0 0"
			holdtime = 1
			x = 0.8
			y = 0.8
		})

		SetPropBool(hBook, "m_bForcePurgeFixedupStrings", true)
		hBook.ValidateScriptScope()
		local hBook_scope = hBook.GetScriptScope()
		if("Cleanup" in hBook_scope) hBook_scope.Cleanup()
		hBook_scope.hSpellbook             <- null
		hBook_scope.flRechargeTime         <- Time() + 12
		hBook_scope.flRechargeTimeDuration <- 0
		hBook_scope.Think <- function()
		{
			local flTime = Time()

			if(flRechargeTime == 0 && hSpellbook && hSpellbook.IsValid() && GetPropBool(hSpellbook, "m_bFiredAttack") == true)
			{
				flRechargeTime = flTime + 12
				EntFireByHandle(hSpellbook, "Kill", null, 0.75, null, null)
			}

			if(flRechargeTime > 0 && flRechargeTimeDuration == 0)
			{
				flRechargeTimeDuration = flRechargeTime - flTime
				hGameText.KeyValueFromString("color", "255 0 0")
			}

			if(flRechargeTimeDuration > 0)
			{
				local iMessageMaxLength = 14
				local sMessage = "BOMBINOMICON!\n"
				if(flTime >= flRechargeTime)
				{
					flRechargeTime = 0
					flRechargeTimeDuration = 0
					hGameText.KeyValueFromString("color", "0 255 0")
					hPlayer.AcceptInput("$PlaySoundToSelf", "TFPlayer.ReCharged", null, null)

					hSpellbook = CreateByClassname("tf_weapon_spellbook")
					SetPropInt(hSpellbook, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 1070)
					SetPropBool(hSpellbook, "m_AttributeManager.m_Item.m_bInitialized", true)
					hSpellbook.DispatchSpawn()
					hPlayer.Weapon_Equip(hSpellbook)
					hPlayer.AcceptInput("$SetSpell", "pumpkin mirv", null, null)

					for(local i = 1; i <= iMessageMaxLength; i++)
						sMessage += "▰"
					sMessage += " READY"
				}
				else
				{
					local flTimeRemaining        = flRechargeTime - flTime
					local flTimeRemainingPercent = 1 - flTimeRemaining / flRechargeTimeDuration
					local flMessagePercent       = 1.0 / iMessageMaxLength
					local iRechargeMeter         = (flTimeRemainingPercent / flMessagePercent).tointeger()

					for(local i = 1; i <= iRechargeMeter; i++)
						sMessage += "▰", iMessageMaxLength--
					for(local i = 1; i <= iMessageMaxLength; i++)
						sMessage += "▱"

					sMessage += format(" %i", ceil(flTimeRemaining))
				}
				SetPropString(hGameText, "m_iszMessage", sMessage)
			}
			hGameText.AcceptInput("Display", null, hPlayer, null)
			return -1
		}
		AddThinkToEnt(hBook, "Think")
		hBook_scope.Cleanup <- function()
		{
			if(hGameText && hGameText.IsValid())
				hGameText.Kill()
			if(hSpellbook && hSpellbook.IsValid())
				hSpellbook.Kill()
		}
		Trespasser.SetDestroyCallback(hBook, hBook_scope.Cleanup)
	}

	function PowderBombs()
	{
		local hPlayer = self
		local hPowder
		for(local i = 0; i <= 8; i++)
		{
			local hWeapon = GetPropEntityArray(hPlayer, "m_hMyWeapons", i)
			if(hWeapon && hWeapon.GetSlot() == 1)
				{ hPowder = hWeapon; break }
		}
		if(!hPowder) return

		SetPropBool(hPowder, "m_bForcePurgeFixedupStrings", true)
		hPowder.ValidateScriptScope()
		local hPowder_scope = hPowder.GetScriptScope()
		if("Cleanup" in hPowder_scope) hPowder_scope.Cleanup()
		local hGameText = SpawnEntityFromTable("game_text", {
			channel = 1
			color = "255 0 0"
			holdtime = 1
			x = 0.8
			y = 0.72
		})
		hPowder_scope.flRechargeTimeDuration <- 1
		hPowder_scope.Think <- function()
		{
			local flTime = Time()
			local flRechargeTime = GetPropFloat(self, "m_flEffectBarRegenTime")

			if(flRechargeTime > 0 && flRechargeTimeDuration == 0)
			{
				flRechargeTimeDuration = flRechargeTime - flTime
				hGameText.KeyValueFromString("color", "255 0 0")
			}

			if(flRechargeTimeDuration > 0)
			{
				local iMessageMaxLength = 14
				local sMessage = "Powder Bombs\n"
				if(flRechargeTime == 0)
				{
					flRechargeTimeDuration = 0
					hGameText.KeyValueFromString("color", "0 255 0")
					hPlayer.AcceptInput("$SetSpell", "pumpkin mirv", null, null)
					hPlayer.AcceptInput("$PlaySoundToSelf", "TFPlayer.ReCharged", null, null)

					for(local i = 1; i <= iMessageMaxLength; i++)
						sMessage += "▰"
					sMessage += " READY"
				}
				else
				{
					local flTimeRemaining        = flRechargeTime - flTime
					local flTimeRemainingPercent = 1 - flTimeRemaining / flRechargeTimeDuration
					local flMessagePercent       = 1.0 / iMessageMaxLength
					local iRechargeMeter         = (flTimeRemainingPercent / flMessagePercent).tointeger()

					for(local i = 1; i <= iRechargeMeter; i++)
						sMessage += "▰", iMessageMaxLength--
					for(local i = 1; i <= iMessageMaxLength; i++)
						sMessage += "▱"

					sMessage += format(" %i", ceil(flTimeRemaining))
				}
				SetPropString(hGameText, "m_iszMessage", sMessage)
			}
			hGameText.AcceptInput("Display", null, hPlayer, null)
			return -1
		}
		AddThinkToEnt(hPowder, "Think")
		hPowder_scope.Cleanup <- function()
		{
			if(hGameText && hGameText.IsValid())
				hGameText.Destroy()
		}
		Trespasser.SetDestroyCallback(hPowder, hPowder_scope.Cleanup)
	}

	function DispatchParticleEffectOn(entity, name)
	{
		if(entity == null) return
		if(name == null)
			{ entity.AcceptInput("DispatchEffect", "ParticleEffectStop", null, null); return }
		local hParticle = CreateByClassname("trigger_particle")
		SetAlwaysTransmit(hParticle)
		hParticle.KeyValueFromString("particle_name", name)
		hParticle.KeyValueFromInt("attachment_type", 1)
		hParticle.KeyValueFromInt("spawnflags", 64)
		hParticle.DispatchSpawn()
		hParticle.AcceptInput("StartTouch", null, entity, entity)
		hParticle.Kill()
	}
	function DispatchParticleEffectClient(player, name, origin, angles)
	{
		local hProxy = CreateByClassname("obj_teleporter")
		hProxy.SetAbsOrigin(origin)
		hProxy.SetForwardVector(angles)
		hProxy.DispatchSpawn()
		hProxy.DisableDraw()
		hProxy.AddEFlags(EFL_NO_THINK_FUNCTION)
		hProxy.SetSolid(SOLID_NONE)
		SetPropBool(hProxy, "m_bPlacing", true)
		SetPropInt(hProxy, "m_fObjectFlags", 2)
		SetPropInt(hProxy, "m_lifeState", LIFE_DEAD)
		SetPropEntity(hProxy, "m_hBuilder", player)

		local hParticle = CreateByClassname("trigger_particle")
		hParticle.KeyValueFromString("particle_name", name)
		hParticle.KeyValueFromInt("attachment_type", 1)
		hParticle.KeyValueFromInt("spawnflags", 64)
		hParticle.DispatchSpawn()
		hParticle.AcceptInput("StartTouch", null, hProxy, hProxy)

		EntFireByHandle(hProxy, "Kill", null, 0.066, null, null)
		hParticle.Kill()
	}

	bHHHAttackedThisTick = false
	function OnScriptHook_OnTakeDamage(params)
	{
		local hVictim              = params.const_entity
		local iVictimModelIndex    = GetPropInt(hVictim, "m_nModelIndex")
		local hAttacker            = params.attacker
		local iAttackerModelIndex  = GetPropInt(hAttacker, "m_nModelIndex")
		local hInflictor           = params.inflictor
		local iInflictorModelIndex = GetPropInt(hInflictor, "m_nModelIndex")
		local hWeapon              = params.weapon
		local vecHit               = params.damage_position

		if(hVictim && hInflictor)
		{
			if(hInflictor.GetClassname() == "tf_pumpkin_bomb" && hVictim == hAttacker)
			{
				hAttacker.ApplyAbsVelocityImpulse(params.damage_force * 0.03)
				params.damage *= 0
			}

			// makes planted proxy mines deal 500% damage
			if
			(
				iInflictorModelIndex == Trespasser.iProxyMineModelIndex &&
				hInflictor.GetSkin() == 1 &&
				hInflictor.GetForwardVector().x == 1 &&
				GetPropEntity(hInflictor, "m_hThrower") != hVictim
			)
			params.damage *= 5

			// pull players into the viro
			if(iInflictorModelIndex == Trespasser.iBugBaitModelIndex && hVictim.IsPlayer())
			{
				local hThrower = GetPropEntity(hInflictor, "m_hThrower")
				if(hThrower && hThrower != hVictim)
				{
					local vecTowardsThrower = hThrower.GetOrigin() - hVictim.GetOrigin()
					vecTowardsThrower.z = 0
					vecTowardsThrower.Norm()
					hVictim.SetAbsVelocity(vecTowardsThrower * 400 + Vector(0, 0, 400))
				}
			}

			if(hInflictor.GetClassname() == "saw_kill")
				params.damage_type = params.damage_type | DMG_ALWAYSGIB
		}
		if(hVictim && hAttacker)
		{
			local sVictimClassname   = hVictim.GetClassname()
			local iVictimTeam        = "GetTeam" in hVictim ? hVictim.GetTeam() : -1
			local sAttackerClassname = hAttacker.GetClassname()
			local iAttackerTeam      = "GetTeam" in hAttacker ? hAttacker.GetTeam() : -1

			// incendiary rifle
			if(hVictim.IsPlayer() && params.damage_type & DMG_BUCKSHOT && hWeapon.GetAttribute("add damage type", 0) == DMG_NEVERGIB)
			{
				hVictim.AddCondEx(TF_COND_LOST_FOOTING, 0.25, hAttacker)
				hVictim.StunPlayer(0.5, 1, TF_STUN_MOVEMENT, hAttacker)
				local vecDirection = hVictim.GetOrigin() - hAttacker.GetOrigin()
				vecDirection.z = 0
				vecDirection.Norm()
				hVictim.ApplyAbsVelocityImpulse(vecDirection * 150)
			}

			// prevents MiniBosses from trampling over buildings that arent a sentrygun (except minis)
			if
			(
				HasProp(hVictim, "m_iObjectType") &&
				GetPropBool(hVictim, "m_bMiniBuilding") == false &&
				"IsMiniBoss" in hAttacker &&
				hAttacker.IsMiniBoss() &&
				hWeapon == null &&
				params.damage_type == DMG_BLAST &&
				params.damage_custom == TF_DMG_CUSTOM_NONE &&
				params.force_friendly_fire == false
			)
			params.damage = 0

			// Gives gray bots crit damage against blue bots
			if(iVictimTeam == TF_TEAM_BLUE && iAttackerTeam == TEAM_SPECTATOR)
				params.damage_type = params.damage_type | DMG_ACID

			local bIsMiniCrit =
				"InCond" in hAttacker &&
				(
					hAttacker.InCond(TF_COND_OFFENSEBUFF) ||
					hAttacker.InCond(TF_COND_ENERGY_BUFF)
				)

			// increase melee effectiveness against horsemann, monoculus, and skeletons
			// makes horsemann headshottable
			// allows crit vfx to play on npc entities
			if
			(
				(
					sVictimClassname == "headless_hatman" ||
					sVictimClassname == "eyeball_boss" ||
					sVictimClassname == "merasmus" ||
					sVictimClassname == "tf_zombie" ||
					sVictimClassname == "tank_boss"
				)
				&&
				iVictimTeam != iAttackerTeam
			)
			{
				if(sVictimClassname != "tank_boss")
				{
					if("GetSlot" in hWeapon)
					{
						if(hWeapon.GetSlot() == 2)
						{
							params.damage_type = params.damage_type | DMG_ACID
							if((bSoloMode && sVictimClassname == "headless_hatman") || sVictimClassname == "eyeball_boss")
								params.damage *= 2
						}
						else if((sVictimClassname == "headless_hatman" || sVictimClassname == "tf_zombie") && (hWeapon.GetAttribute("can headshot", 0) || hWeapon.GetAttribute("revolver use hit locations", 0)))
						{
							local iHead = hVictim.LookupBone("bip_head")
							local vecHead = hVictim.GetBoneOrigin(iHead)
							local angHead = hVictim.GetBoneAngles(iHead)

							if
							(
								(sVictimClassname == "headless_hatman" && (vecHead + angHead.Up() * -2.25 + angHead.Left() * 2.25 - vecHit).Length() <= 14)
								||
								(sVictimClassname == "tf_zombie" && (vecHead + angHead.Up() * -1.05 + angHead.Left() * 3.5 - vecHit).Length() <= 12)
							)
							params.damage_type = params.damage_type | DMG_ACID
						}
					}

					if(params.damage_type & DMG_ACID)
					{
						if(sVictimClassname == "tf_zombie") params.damage *= 3
						if("GetAttribute" in hWeapon) params.damage *= hWeapon.GetAttribute("mult crit dmg", 1)
					}
					else if(bIsMiniCrit) params.damage *= 1.35
				}

				local CritEffect = function(bMiniCrit)
				{
					DispatchParticleEffectClient(hAttacker, bMiniCrit ? "minicrit_text" : "crit_text", hVictim.GetOrigin() + Vector(0, 0, hVictim.GetBoundingMaxs().z), Vector(1))
					local sRNG = RandomInt(1, 5).tostring()
					local sSound = format("player/crit_hit%s%s.wav", bMiniCrit ? "_mini" : "", sRNG == "1" ? "" : sRNG)
					PrecacheSound(sSound)
					EmitSoundEx({
						sound_name = sSound
						filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
						entity = hAttacker
					})
				}
				if(hVictim != hAttacker)
				{
					if(params.damage_type & DMG_ACID)
						CritEffect(false)
					else if(bIsMiniCrit)
						CritEffect(true)
				}
			}

			// make crits deal their normal 3x damage against monoculus
			if(sVictimClassname == "eyeball_boss" && params.damage_type & DMG_ACID) params.damage *= 1.5

			// i dont think a lot of people know that mono instantly kills whoever is occupying where he spawns from
			if(sAttackerClassname == "eyeball_boss" && params.damage_custom == TF_DMG_CUSTOM_PLASMA) params.damage *= 0

			if(hVictim.IsPlayer() && hVictim.IsBotOfType(TF_BOT_TYPE))
			{
				if(hVictim.HasBotTag("metal_hit"))
					DispatchParticleEffect("lowv_sparks1", vecHit, Vector(0, 0, 1))
				if(hVictim.HasBotTag("blood_hit_green"))
					DispatchParticleEffect("spell_skeleton_goop_green", hVictim.GetCenter(), Vector(1))
				if(hVictim.HasBotTag("blood_hit_big"))
					DispatchParticleEffect("tfc_sniper_mist", hVictim.GetCenter(), Vector(1))
				if(hVictim.HasBotTag("bot_receivemeleecrit") && "GetSlot" in hWeapon && hWeapon.GetSlot() == 2)
					params.damage_type = params.damage_type | DMG_ACID
			}

			if(sAttackerClassname == "headless_hatman")
			{
				if(iVictimTeam == TF_TEAM_BLUE)
					params.damage *= 2
				if(hAttacker == hInflictor && GetPropInt(hGameRules, "m_halloweenScenario") == 5)
				{
					if(!bHHHAttackedThisTick)
					{
						bHHHAttackedThisTick = true
						EntFireByHandle(hAttacker, "RunScriptCode", "Trespasser.bHHHAttackedThisTick = false", 0.033, null, null)

						local vecVictimOrigin = hVictim.GetOrigin()
						local vecAttackerOrigin = hAttacker.GetOrigin()

						local hHammerKillIcon = SpawnEntityFromTable("info_target", { classname = "necro_smasher", origin = vecVictimOrigin })
						EntFireByHandle(hHammerKillIcon, "Kill", null, -1, null, null)

						local vecAttackerEye = hAttacker.EyePosition()
						local vecTrace = hVictim.GetCenter()
						local flAttackRange = Convars.GetFloat("tf_halloween_hhh_attack_kart_radius")
						for(local hPlayer; hPlayer = FindByClassnameWithin(hPlayer, "player", vecVictimOrigin, flAttackRange);)
							if(hPlayer.IsAlive() && TraceLine(vecTrace, vecAttackerEye, hAttacker) == 1)
							{
								EntFireByHandle(hAttacker, "RunScriptCode", "activator.TakeDamageEx(caller, self, null, Vector(), Vector(), activator.GetMaxHealth() * 0.4, DMG_CLUB)", -1, hPlayer, hHammerKillIcon)
								local vecAway = hPlayer.GetOrigin() - vecAttackerOrigin
								vecAway.Norm()
								hPlayer.ApplyAbsVelocityImpulse(vecAway * 500)
								hPlayer.AddCustomAttribute("increased air control", 2, 2)
							}
					}
					params.damage = 0

					// very very gross
					hAttacker.StopSound("Halloween.HeadlessBossAxeHitWorld")
					EntFireByHandle(hAttacker, "RunScriptCode", "self.StopSound(`Halloween.HeadlessBossAxeHitWorld`)", -1, null, null)
					EntFireByHandle(hAttacker, "RunScriptCode", "self.StopSound(`Halloween.HeadlessBossAxeHitWorld`)", 0.033, null, null)
					hAttacker.StopSound("Halloween.HeadlessBossAxeHitFlesh")
					EntFireByHandle(hAttacker, "RunScriptCode", "self.StopSound(`Halloween.HeadlessBossAxeHitFlesh`)", -1, null, null)
					EntFireByHandle(hAttacker, "RunScriptCode", "self.StopSound(`Halloween.HeadlessBossAxeHitFlesh`)", 0.033, null, null)
				}
			}

			// nullify combattank knockback force
			if(sAttackerClassname == "tank_boss" && hVictim.IsPlayer())
				hVictim.AddCustomAttribute("damage force increase hidden", 0, 0.033)
		}
	}

	function OnGameEvent_teamplay_round_win(params)
	{
		bLastMan  = false
		bSoloMode = false
		bGameOver = true
		if(params.team == TF_TEAM_BLUE)
		{
			for(local i = 1; i <= MAX_PLAYERS; i++)
			{
				local hPlayer = PlayerInstanceFromIndex(i)
				if(hPlayer && !hPlayer.IsFakeClient() && GetPropInt(hPlayer, "m_iObserverMode") <= 1)
				{
					SetPropEntity(hPlayer, "m_hObserverTarget", null)
					EntFire("bignet", "RunScriptCode", "SetPropEntity(activator, `m_hObserverTarget`, null)", 0.033, hPlayer)
				}
			}
			EntFire("gameover_relay", "Trigger")
			TrespasserLosses++
		}
	}

	// Chainsaw Sounds
	function Chainsaw()
	{
		local hPlayer = self
		local hChainsaw
		for(local i = 0; i <= 8; i++)
		{
			local hWeapon = GetPropEntityArray(hPlayer, "m_hMyWeapons", i)
			if(hWeapon && hWeapon.GetSlot() == 0)
				{ hChainsaw = hWeapon; break }
		}
		if(!hChainsaw) return

		local hViewmodel = GetPropEntity(hPlayer, "m_hViewModel")

		hChainsaw.ValidateScriptScope()
		local hChainsaw_scope = hChainsaw.GetScriptScope()
		hChainsaw_scope.iWeaponStateLast <- 0
		hChainsaw_scope.Think <- function()
		{
			if(!self.IsValid()) return
			local iWeaponState = GetPropInt(self, "m_iWeaponState")

			if(hPlayer && hPlayer.IsValid())
			{
				local hViewmodel = GetPropEntity(hPlayer, "m_hViewModel")
				if(hViewmodel && hViewmodel.IsValid())
					hViewmodel.AcceptInput("DispatchEffect", "ParticleEffectStop", null, null)
			}

			EmitSoundEx({ sound_name = "common/null.wav", channel = CHAN_WEAPON, entity = self, flags = SND_STOP | SND_IGNORE_NAME, filter_type = RECIPIENT_FILTER_GLOBAL })
			if(iWeaponState != iWeaponStateLast)
			{
				iWeaponStateLast = iWeaponState
				switch(iWeaponState)
				{
					case 0:
						hViewmodel.StopSound("Chainsaw.Start")
						hViewmodel.StopSound("Chainsaw.Run")
						hViewmodel.EmitSound("Chainsaw.Stop")
						break
					case 1:
						hViewmodel.EmitSound("Chainsaw.Start")
						hViewmodel.StopSound("Chainsaw.Run")
						hViewmodel.StopSound("Chainsaw.Stop")
						break
					case 2:
						hViewmodel.StopSound("Chainsaw.Start")
						hViewmodel.EmitSound("Chainsaw.Run")
						hViewmodel.StopSound("Chainsaw.Stop")
						break
					default:
						hViewmodel.StopSound("Chainsaw.Start")
						hViewmodel.StopSound("Chainsaw.Run")
						hViewmodel.StopSound("Chainsaw.Stop")
						break
				}
			}
			return -1
		}
		AddThinkToEnt(hChainsaw, "Think")
		Trespasser.SetDestroyCallback(hChainsaw, function()
		{
			if(hViewmodel && hViewmodel.IsValid())
			{
				hViewmodel.StopSound("Chainsaw.Start")
				hViewmodel.StopSound("Chainsaw.Run")
				hViewmodel.StopSound("Chainsaw.Stop")
			}
		})
		Trespasser.SetDestroyCallback(hViewmodel, function()
		{
			self.StopSound("Chainsaw.Start")
			self.StopSound("Chainsaw.Run")
			self.StopSound("Chainsaw.Stop")
		})
	}
	// Chainsaw fire input on attack
	function ChainsawHit()
	{
		local hPlayer = self
		local vecEye = hPlayer.EyePosition()
		local Trace = {
			start   = vecEye
			end     = vecEye + hPlayer.EyeAngles().Forward() * (72 * hPlayer.GetCustomAttribute("melee range multiplier", 1))
			mask    = MASK_SHOT_HULL
			ignore  = hPlayer
			hullmin = Vector(-10, -10, -10)
			hullmax = Vector(10, 10, 10)
		}
		TraceHull(Trace)
		if("enthit" in Trace)
		{
			local iTeamNum = hPlayer.GetTeam()
			local sSound = "Wood.Loud"
			if(Trace.enthit.IsPlayer())
			{
				if(Trace.enthit.GetTeam() == iTeamNum) return
				sSound = "Chainsaw.Hit"
			}
			EmitSoundEx({
				sound_name = sSound
				origin = Trace.endpos
			})

			local flDamageBonus = hPlayer.GetCustomAttribute("damage bonus", 1) * hPlayer.GetCustomAttribute("damage penalty", 1)
			local flBlastRadius = hPlayer.GetCustomAttribute("Blast radius increased", 1) * hPlayer.GetCustomAttribute("Blast radius decreased", 1)

			local hExplosion = CreateByClassname("env_explosion")
			hExplosion.SetAbsOrigin(Trace.endpos)
			SetPropInt(hExplosion, "m_iMagnitude", 25 * flDamageBonus)
			SetPropInt(hExplosion, "m_iRadiusOverride", 20 * flBlastRadius)
			SetPropInt(hExplosion, "m_spawnflags", 18300)
			SetPropInt(hExplosion, "m_iTeamNum", iTeamNum)
			SetPropEntity(hExplosion, "m_hEntityIgnore", hPlayer)
			hExplosion.SetOwner(hPlayer)
			hExplosion.DispatchSpawn()
			hExplosion.KeyValueFromString("classname", "saw_kill")
			hExplosion.AcceptInput("Explode", null, null, null)

			// weird particle bug which needs to be at the end of the tick
			EntFire("bignet", "RunScriptCode", format("DispatchParticleEffect(`versus_door_slam`, Vector(%i, %i, %i), Vector(1))", Trace.endpos.x, Trace.endpos.y, Trace.endpos.z), -1)
			hPlayer.ApplyAbsVelocityImpulse((Trace.endpos - self.GetOrigin()) * 2.5)
		}
	}

	function ParatrooperRifle()
	{
		local hPlayer = self
		local hRifle
		for(local i = 0; i <= 8; i++)
		{
			local hWeapon = GetPropEntityArray(hPlayer, "m_hMyWeapons", i)
			if(hWeapon && hWeapon.GetSlot() == 1)
				{ hRifle = hWeapon; break }
		}
		if(!hRifle) return

		hRifle.ValidateScriptScope()
		local hRifle_scope = hRifle.GetScriptScope()

		if("hPack" in hRifle_scope && hRifle_scope.hPack && hRifle_scope.hPack.IsValid())
			hRifle_scope.hPack.Kill()

		local MakeParachute = function(player)
		{
			local parachute = CreateByClassname("tf_weapon_parachute")
			SetPropInt(parachute, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 1101)
			SetPropBool(parachute, "m_AttributeManager.m_Item.m_bInitialized", true)
			parachute.DispatchSpawn()
			player.Weapon_Equip(parachute)
			return parachute
		}
		local hTemp = MakeParachute(hPlayer)
		local hParachute = GetPropEntity(hTemp, "m_hExtraWearable")
		hTemp.Kill()
		hParachute.SetModelSimple("models/workshop/weapons/c_models/c_paratooper_pack/c_paratrooper_parachute.mdl")
		SetPropBool(hParachute, "m_bClientSideAnimation", false)
		SetPropInt(hParachute, "m_fEffects", EF_BONEMERGE | EF_NODRAW | EF_BONEMERGE_FASTCULL)

		hRifle_scope.bDeployed <- false
		hRifle_scope.Think <- function()
		{
			local bParaCond = hPlayer.InCond(80)
			if(bParaCond && !bDeployed)
			{
				bDeployed = true
				hParachute.ResetSequence(hParachute.LookupSequence("deploy"))
				SetPropInt(hParachute, "m_fEffects", EF_BONEMERGE | EF_BONEMERGE_FASTCULL)
			}
			else if(!bParaCond && bDeployed)
			{
				bDeployed = false
				hParachute.ResetSequence(hParachute.LookupSequence("retract"))
			}
			if(!bDeployed && hParachute.GetCycle() == 1)
				SetPropInt(hParachute, "m_fEffects", EF_BONEMERGE | EF_NODRAW | EF_BONEMERGE_FASTCULL)
			if(bParaCond)
				hPlayer.AddCustomAttribute("increased air control", -4, 0.1)
			hParachute.StudioFrameAdvance()
			return -1
		}
		local bGivePack = true
		for(local hChild = hPlayer.FirstMoveChild(); hChild; hChild = hChild.NextMovePeer())
		{
			local iItemIndex = GetPropInt(hChild, "m_AttributeManager.m_Item.m_iItemDefinitionIndex")
			if(iItemIndex == 231 || iItemIndex == 57 || iItemIndex == 642)
				{ bGivePack = false; break }
		}
		if(bGivePack)
		{
			local hTempParachute = MakeParachute(hPlayer)
			hRifle_scope.hPack <- GetPropEntity(hTempParachute, "m_hExtraWearable")
			hTempParachute.Kill()
			Trespasser.SetDestroyCallback(hRifle, function()
			{
				if(hPack && hPack.IsValid()) hPack.Kill()
			})
		}
		AddThinkToEnt(hRifle, "Think")
	}

	function Eyelander() // eyelander nerf
	{
		local hPlayer = self
		local hEyelander
		for(local i = 0; i <= 8; i++)
		{
			local hWeapon = GetPropEntityArray(hPlayer, "m_hMyWeapons", i)
			if(hWeapon && hWeapon.GetSlot() == 2)
				{ hEyelander = hWeapon; break }
		}
		if(!hEyelander) return

		hEyelander.ValidateScriptScope()
		local hEyelander_scope = hEyelander.GetScriptScope()
		hEyelander_scope.flTimeNext <- 0
		hEyelander_scope.iHeadsLast <- 0
		hEyelander_scope.Hit <- function()
		{
			SetPropInt(hPlayer, "m_Shared.m_iDecapitations", GetPropInt(hPlayer, "m_Shared.m_iDecapitations") + 1)
		}
		hEyelander_scope.Think <- function()
		{
			if(!self.IsValid()) return
			local flTime = Time()
			local iHeads = GetPropInt(hPlayer, "m_Shared.m_iDecapitations")
			if(iHeads > 0)
			{
				if(iHeads > iHeadsLast)
					flTimeNext = flTime + 5
				if(iHeads > 6)
					SetPropInt(hPlayer, "m_Shared.m_iDecapitations", iHeads = 6)
				if(iHeadsLast > 0 && flTime >= flTimeNext)
				{
					hPlayer.AcceptInput("$PlaySoundToSelf", "physics/flesh/flesh_bloody_impact_hard1.wav", null, null)
					hPlayer.AcceptInput("$PlaySoundToSelf", "physics/flesh/flesh_bloody_impact_hard1.wav", null, null)
					DispatchParticleEffect("blood_impact_red_01", hPlayer.EyePosition(), Vector())
					SetPropInt(hPlayer, "m_Shared.m_iDecapitations", iHeads - 1)
					hPlayer.AddCustomAttribute("move speed penalty", 1, 0.033)
					flTimeNext = flTime + 1
				}
				if(iHeads > iHeadsLast)
					EmitSoundOnClient("Cleaver.ImpactFlesh", hPlayer)
			}
			iHeadsLast = iHeads
			return -1
		}
		AddThinkToEnt(hEyelander, "Think")
	}

	// annotations are nice but i will not allow it to make this file look dirty
	function SendAnnotationOn(hEnt, sText, flDuration, bVisibleToOthers = false, flDelay = -1)
	{
		if(flDelay < 0.033) flDelay = 0.033
		local bPlayer     = hEnt.IsPlayer()
		local bRealClient = bPlayer && !hEnt.IsFakeClient()
		local hAnnotationFollow
		if(bRealClient)
		{
			hAnnotationFollow = SpawnEntityFromTable("prop_dynamic", { model = "models/props_hydro/barrel_crate_half.mdl", origin = "400 0 60", disableshadows = 1 })
			hAnnotationFollow.DisableDraw()
			SetAlwaysTransmit(hAnnotationFollow)
			SetPropEntity(hAnnotationFollow, "m_hMovePeer", hEnt.FirstMoveChild())
			SetPropEntity(hEnt, "m_hMoveChild", hAnnotationFollow)
			SetPropEntity(hAnnotationFollow, "m_hMoveParent", hEnt)
			EntFireByHandle(hAnnotationFollow, "Kill", null, flDelay + flDuration + 0.2, null, null)
			SetPropBool(hAnnotationFollow, "m_bForcePurgeFixedupStrings", true)
		}

		EntFireByHandle(SetAlwaysTransmit(hEnt), "Kill", null, flDelay + flDuration + 0.2, null, null)

		DoEntFire("bignet", "RunScriptCode" format(@"
			local index = activator.entindex()
			local anno = function(entindex1, entindex2){
				SendGlobalGameEvent(`show_annotation`,
				{
					id = RandomInt(5000, 50000)
					text = `%s`
					follow_entindex = entindex1
					visibilityBitfield = entindex2
					play_sound = `misc/null.wav`
					show_distance = false
					show_effect = false
					lifetime = %f
				})}
			%s
			%s", sText, flDuration, bVisibleToOthers ? "anno(activator.entindex(), ((1 << 31) - 1) & ~(1 << (index > 30 ? 0 : index)))" : "", bRealClient ? "anno(caller.entindex(), 1 << (index > 30 ? 30 : index))" : ""
		), flDelay, hEnt, hAnnotationFollow)
	}

	// Last Man Standing / Solo Mode
	bInWave            = false
	bInBreak           = false
	bGameOver          = false
	bLastTwo           = false
	bLastMan           = false
	bAboutToBeLastMan  = false
	bSoloMode          = false
	bAboutToBeSoloMode = false
	hLastRed           = null
	function AliveCountCheck(bBegin = true)
	{
		if(!bInWave || bInBreak) return
		local iAliveRedsInfected = 0
		local iAliveReds         = 0
		local iAliveRedBots      = 0
		local bEngineer          = false
		local hRedPlayer
		for(local i = 1; i <= MAX_CLIENTS; i++)
		{
			local hPlayer = PlayerInstanceFromIndex(i)
			if
			(
				hPlayer &&
				IsAliveExtra(hPlayer) &&
				(hPlayer.GetTeam() == TF_TEAM_RED || (hPlayer.GetTeam() == TF_TEAM_BLUE && hPlayer.InCond(TF_COND_REPROGRAMMED))) &&
				!(hPlayer.IsBotOfType(TF_BOT_TYPE) && hPlayer.HasBotTag("bot_ignoreredcount"))
			)
			{
				if(hPlayer.IsBotOfType(TF_BOT_TYPE)) iAliveRedBots++
				else
				{
					if(!bBegin) ActivePlayers[hPlayer] <- null

					iAliveReds++
					if(hPlayer.InCond(TF_COND_REPROGRAMMED)) iAliveRedsInfected++

					hRedPlayer = hPlayer

					if(hPlayer.GetPlayerClass() == TF_CLASS_ENGINEER)
						bEngineer = true
				}
			}
		}
		// iAliveReds = 6 // debug
		if(!bGameOver && iAliveRedsInfected == iAliveReds)
			{ EntFire("bots_win", "RoundWin"); EntFire("player", "$StopSound", "Game.YourTeamWon", -1); return }

		FindByName(null, "ai_go_sentry").SetAbsOrigin(bEngineer ? Vector(-200, 460, 192) : Vector(-482, 610, 192))
		FindByName(null, "ai_look_sentry").SetAbsOrigin(bEngineer ? Vector(-200, 532, 192) : Vector(-482, 682, 192))

		local iRedIcon
		local iBlankIcon
		AlternateWaves.IterateIcons(function(iIcon, sNames, sCounts, sFlags)
		{
			local sIcon = GetPropStringArray(hObjectiveResource, sNames, iIcon)
			if(!iRedIcon && sIcon == "red2_lite") iRedIcon = [iIcon, sNames, sFlags]
			else if(!iBlankIcon && sIcon == "") iBlankIcon = [iIcon, sNames, sFlags]
		})
		if(iAliveRedBots > 0 && iRedIcon == null && iBlankIcon != null)
		{
			SetPropStringArray(hObjectiveResource, iBlankIcon[1], "red2_lite", iBlankIcon[0])
			SetPropIntArray(hObjectiveResource, iBlankIcon[2], MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT, iBlankIcon[0])
		}
		else if(iAliveRedBots == 0 && iRedIcon != null)
		{
			SetPropStringArray(hObjectiveResource, iRedIcon[1], "", iRedIcon[0])
			SetPropIntArray(hObjectiveResource, iRedIcon[2], MVM_CLASS_FLAG_NONE, iRedIcon[0])
		}

		if(bSoloMode || bAboutToBeSoloMode)
			return

		if(iAliveReds == 2) bLastTwo = true
		else bLastTwo = false

		if(iAliveReds == 1)
		{
			bLastTwo = false
			hLastRed = hRedPlayer
			if(bBegin && !bLastMan && !bAboutToBeLastMan)
			{
				bAboutToBeLastMan = true
				SendAnnotationOn(hRedPlayer, "YOU ARE THE LAST...", 8, false, 2.75)
				EntFire("bignet", "RunScriptCode", "Trespasser.bAboutToBeLastMan = false", 2.75)
				EntFire("lastman_relay", "Trigger", null, -1)
			}
			else if(!bBegin)
			{
				bAboutToBeSoloMode = true
				SendAnnotationOn(hRedPlayer, "YOU ARE ALONE...", 8, false, 3)
			}
			return true
		}
		else
		{
			if(iAliveReds == 0 && !bGameOver)
				EntFire("bots_win", "RoundWin")
			EntFire("lastman_relay", "CancelPending")
			if(bBegin && bLastMan)
				EntFire("lastman_relay_disable", "Trigger", null, -1)
			bLastMan = false
			bAboutToBeLastMan = false
			return false
		}
	}
	function OnGameEvent_mvm_begin_wave(params)
	{
		if(bInWave) return
		EntFire("bignet", "RunScriptCode", "Trespasser.SetWavebar(1)", -1)
		ForceRespawnDeadRed()
		bInWave = true
		if(AliveCountCheck(false))
		{
			EntFire("solomode_relay", "Trigger", null, -1, hLastRed)
			for(local i = 0; i <= 8; i++)
			{
				local hWeapon = GetPropEntityArray(hLastRed, "m_hMyWeapons", i)
				if(!hWeapon) continue
				local sClassname = hWeapon.GetClassname()
				local iItemIndex = GetPropInt(hWeapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex")
				if(iItemIndex == 129 || iItemIndex == 1001) // buff banner
					hWeapon.AddAttribute("effect cond override", 34, -1)
				else if(iItemIndex == 311) // steak
					hWeapon.AddAttribute("effect cond override", 34 + 41 * 256, -1)
				else if(iItemIndex == 751) // carbine
					hWeapon.AddAttribute("effect cond override", 19 + 34 * 256 + 32 * 65536, -1)
				else if(iItemIndex == 43) // kgb
					hWeapon.AddAttribute("critboost on kill", 3, -1), hWeapon.RemoveAttribute("minicritboost on kill")
				else if(startswith(sClassname, "tf_weapon_jar")) // jarate, milk, gas
					hWeapon.AddAttribute("applies snare effect", 0.65, -1)
			}
		}
	}

	// player joining
	function OnGameEvent_player_activate(params)
	{
		local hPlayer = GetPlayerFromUserID(params.userid)
		if(hPlayer.IsFakeClient()) return

		GetPlayerWins()

		if(bMusic)
			EmitSoundEx({
				sound_name  = "#trespasser_v2/music_spawnroom.wav"
				pitch       = 85
				entity      = hPlayer
				filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
			})
	}

	// player leaving
	DisconnectedPlayerClass = {}
	function OnGameEvent_player_disconnect(params)
	{
		local hPlayer = GetPlayerFromUserID(params.userid)
		if(hPlayer && hPlayer.IsValid())
		{
			DisconnectedPlayerClass[GetPropString(hPlayer, "m_szNetworkIDString")] <- hPlayer.GetPlayerClass()
			if(bInWave && IsAliveExtra(hPlayer))
			{
				ScreenShake(Vector(), 40, 16, 2, 0, 0, true)
				local sSound = format("misc/halloween/skeletons/skelly_giant_0%i.wav", RandomInt(1, 3))
				PrecacheSound(sSound)
				EmitSoundEx({
					sound_name = sSound
					pitch = 75
					filter_type = RECIPIENT_FILTER_GLOBAL
					special_dsp = 20
				})

				local vecOrigin = hPlayer.GetOrigin()
				hPlayer.EmitSound("Zombie.Break")
				DispatchParticleEffect("env_sawblood", vecOrigin, Vector(1))
				DispatchParticleEffect("env_sawblood", hPlayer.GetCenter(), Vector(1))
				DispatchParticleEffect("env_sawblood", hPlayer.EyePosition(), Vector(1))
				local hSkeleton = SpawnEntityFromTable("tf_zombie", { origin = vecOrigin, angles = hPlayer.GetAbsAngles(), teamnum = TF_TEAM_RED })
				hSkeleton.SetSkin(4)
				hSkeleton.SetMaxHealth(1500)
				hSkeleton.SetHealth(1500)
				SendAnnotationOn(hSkeleton, format("%s's remains fight on...", GetPropString(hPlayer, "m_szNetname")), 5, true)
			}
		}
		EntFire("bignet", "RunScriptCode", "Trespasser.AliveCountCheck()", -1)
	}

	// player spawning
	ActivePlayers = {}
	GivenWeapon   = {}
	bViroFog      = false
	function OnGameEvent_player_spawn(params)
	{
		local hPlayer  = GetPlayerFromUserID(params.userid)
		local bBot     = hPlayer.IsBotOfType(TF_BOT_TYPE)
		local iTeamNum = params.team

		if(!bBot && (bSoloMode || bAboutToBeSoloMode) && hPlayer != hLastRed)
			{ hPlayer.ForceChangeTeam(TEAM_SPECTATOR, true); return }

		if(hPlayer in BecomingGhost)
			return

		CleanupPlayer(hPlayer)

		if(iTeamNum == TF_TEAM_RED)
		{
			if(bInWave && !bInBreak && !bBot && !(hPlayer in ActivePlayers))
			{
				ActivePlayers[hPlayer] <- null
				local vecOrigin = hPlayer.GetOrigin()
				local angEyes   = hPlayer.EyeAngles()
				EntFire("bignet", "RunScriptCode", format("if(activator.IsValid()) { SetPropInt(activator, `m_lifeState`, LIFE_DEAD); Trespasser.BecomeGhost(activator, Vector(%f, %f, %f), QAngle(%f, %f, 0)) }", vecOrigin.x, vecOrigin.y, vecOrigin.z, angEyes.x, angEyes.y), -1, hPlayer)
				return
			}

			AliveCountCheck()
			if(!bBot)
			{
				if(bViroFog) hPlayer.AcceptInput("SetFogController", "virophage_fog", null, null)
				DispatchParticleEffect(hPlayer.GetPlayerClass() == TF_CLASS_CIVILIAN ? "merasmus_tp" : "teleportedin_red", hPlayer.GetOrigin(), Vector(1))

				local sNetworkID = GetPropString(hPlayer, "m_szNetworkIDString")
				if(!(sNetworkID in GivenWeapon))
					GivenWeapon[sNetworkID] <- 0

				local ITEM_HMG              = 1 << 0
				local ITEM_INCENDIARY_RIFLE = 1 << 1
				local ITEM_SLUG_RIFLE       = 1 << 2
				local ITEM_DUSTBOWL_EAGLE   = 1 << 3
				local ITEM_CHAINSAW         = 1 << 4
				local ITEM_CEREMONIAL_BOW   = 1 << 5
				local ITEM_GRAPPLING_HOOK   = 1 << 6
				local ITEM_DEATHLY_CANTEEN  = 1 << 7

				if(sNetworkID in Wins)
				{
					local iWins               = Wins[sNetworkID][0]
					local bWonSolo            = Wins[sNetworkID][1]
					local bKeptSurvivorsAlive = Wins[sNetworkID][2]
					local iGivenWeapon        = GivenWeapon[sNetworkID]
					if(iWins >= 1 && !(iGivenWeapon & ITEM_HMG))
					{
						iGivenWeapon = iGivenWeapon | ITEM_HMG
						hPlayer.AcceptInput("$AwardExtraItem", "Heavy Machine Gun", null, null)

						// very gross method to not automatically equip the awarded weapon after its been given
						hPlayer.AcceptInput("$AwardExtraItem", "Upgradeable TF_WEAPON_PISTOL", null, null)
						hPlayer.AcceptInput("$StripExtraItem", "Upgradeable TF_WEAPON_PISTOL", null, null)
					}
					if(iWins >= 2 && !(iGivenWeapon & ITEM_INCENDIARY_RIFLE))
					{
						iGivenWeapon = iGivenWeapon | ITEM_INCENDIARY_RIFLE
						hPlayer.AcceptInput("$AwardExtraItem", "Incendiary Rifle", null, null)

						hPlayer.AcceptInput("$AwardExtraItem", "Upgradeable TF_WEAPON_PISTOL", null, null)
						hPlayer.AcceptInput("$StripExtraItem", "Upgradeable TF_WEAPON_PISTOL", null, null)
					}
					if(iWins >= 3 && !(iGivenWeapon & ITEM_SLUG_RIFLE))
					{
						iGivenWeapon = iGivenWeapon | ITEM_SLUG_RIFLE
						hPlayer.AcceptInput("$AwardExtraItem", "Slug Rifle", null, null)

						hPlayer.AcceptInput("$AwardExtraItem", "Upgradeable TF_WEAPON_SCATTERGUN", null, null)
						hPlayer.AcceptInput("$StripExtraItem", "Upgradeable TF_WEAPON_SCATTERGUN", null, null)
					}
					if(iWins >= 4 && !(iGivenWeapon & ITEM_DUSTBOWL_EAGLE))
					{
						iGivenWeapon = iGivenWeapon | ITEM_DUSTBOWL_EAGLE
						hPlayer.AcceptInput("$AwardExtraItem", "Dustbowl Eagle", null, null)

						hPlayer.AcceptInput("$AwardExtraItem", "Upgradeable TF_WEAPON_PISTOL", null, null)
						hPlayer.AcceptInput("$StripExtraItem", "Upgradeable TF_WEAPON_PISTOL", null, null)
					}
					if(iWins >= 5 && !(iGivenWeapon & ITEM_CHAINSAW))
					{
						iGivenWeapon = iGivenWeapon | ITEM_CHAINSAW
						hPlayer.AcceptInput("$AwardExtraItem", "Chainsaw", null, null)

						hPlayer.AcceptInput("$AwardExtraItem", "Upgradeable TF_WEAPON_SCATTERGUN", null, null)
						hPlayer.AcceptInput("$StripExtraItem", "Upgradeable TF_WEAPON_SCATTERGUN", null, null)
					}
					if(iWins >= 10 && !(iGivenWeapon & ITEM_CEREMONIAL_BOW))
					{
						iGivenWeapon = iGivenWeapon | ITEM_CEREMONIAL_BOW
						hPlayer.AcceptInput("$AwardExtraItem", "Ceremonial Bow", null, null)

						hPlayer.AcceptInput("$AwardExtraItem", "Upgradeable TF_WEAPON_SCATTERGUN", null, null)
						hPlayer.AcceptInput("$StripExtraItem", "Upgradeable TF_WEAPON_SCATTERGUN", null, null)
					}
					if(bKeptSurvivorsAlive && !(iGivenWeapon & ITEM_GRAPPLING_HOOK))
					{
						iGivenWeapon = iGivenWeapon | ITEM_GRAPPLING_HOOK
						hPlayer.AcceptInput("$AwardExtraItem", "Grappling Hook", null, null)

						hPlayer.AcceptInput("$AwardExtraItem", "Battery Canteens", null, null)
						hPlayer.AcceptInput("$StripExtraItem", "Battery Canteens", null, null)
					}
					if(bWonSolo && !(iGivenWeapon & ITEM_DEATHLY_CANTEEN))
					{
						iGivenWeapon = iGivenWeapon | ITEM_DEATHLY_CANTEEN
						hPlayer.AcceptInput("$AwardExtraItem", "Deathly Canteen", null, null)

						hPlayer.AcceptInput("$AwardExtraItem", "Battery Canteens", null, null)
						hPlayer.AcceptInput("$StripExtraItem", "Battery Canteens", null, null)
					}
					GivenWeapon[sNetworkID] = iGivenWeapon
				}
			}
		}

		if(bBot)
		{
			EntFire("bignet", "RunScriptCode", format("Trespasser.PostBotSpawn(GetPlayerFromUserID(%i))", params.userid), -1)
			if(bSoloMode)
				EntFireByHandle(hPlayer, "$ChangeAttributes", "Solo", -1, null, null)
		}
	}
	function PostBotSpawn(hBot)
	{
		local Tags = {}
		hBot.GetAllBotTags(Tags)
		foreach(i, sTag in Tags)
			if(startswith(sTag, "bot_viro_"))
			{
				hBot.AcceptInput("$TeleportToEntity", "viro_base", null, null)
				if(hBot.GetCustomAttribute("not solid to players", 0) == 0)
					hBot.AddCustomAttribute("not solid to players", 1, 2)
				hBot.AddCondEx(TF_COND_SPEED_BOOST, 3, null)
				local sType = sTag.slice(9).toupper()
				if(sType in ViroScript.Summons1)
				{
					ViroScript.Summons1[sType]--
					ViroScript.iActiveSummons1++
				}
				else
				{
					ViroScript.Summons2[sType]--
					ViroScript.iActiveSummons2++
				}
			}
	}

	// player dying
	SeenGhostAnno = []
	BecomingGhost = {}
	function BecomeGhost(hPlayer, vecOrigin, angEyes)
	{
		if(bGameOver || bInBreak || !bInWave || bSoloMode || bAboutToBeSoloMode || !hPlayer || !hPlayer.IsValid() || hPlayer.InCond(TF_COND_HALLOWEEN_GHOST_MODE) || IsAliveExtra(hPlayer)) return
		DispatchParticleEffect("ghost_appearation", vecOrigin, Vector(1))
		BecomingGhost[hPlayer] <- null
		hPlayer.ForceRespawn()
		delete BecomingGhost[hPlayer]

		hPlayer.SetAbsOrigin(vecOrigin)
		hPlayer.SnapEyeAngles(angEyes)
		hPlayer.AddCond(TF_COND_HALLOWEEN_GHOST_MODE)
		hPlayer.AddCond(TF_COND_TEAM_GLOWS)
		hPlayer.SetModelScale(0.5, 0)
		hPlayer.AddCustomAttribute("voice pitch scale", 1.75, -1)
		hPlayer.AddCustomAttribute("ignored by bots", 1, -1)
		hPlayer.AddCustomAttribute("mult credit collect range", 0, -1)
		SetPropIntArray(hPlayer, "m_nModelIndexOverrides", PrecacheModel("models/props_graveyard/healing_ghost.mdl"), 0)
		EntFireByHandle(hPlayer, "Color", "255 65 25", -1, null, null)
		EntFireByHandle(hPlayer, "Color", "255 65 25", 0.033, null, null)
		DispatchParticleEffectOn(hPlayer, "ghost_glow_red")

		local hTouch = SpawnEntityFromTable("dispenser_touch_trigger", {
			targetname = "ghosttrigger"
			spawnflags = 1
		})
		hTouch.SetSolid(SOLID_BBOX)
		hTouch.SetSize(Vector(-128, -128, -128), Vector(128, 128, 128))

		local hDisp = SpawnEntityFromTable("pd_dispenser", {
			origin         = Vector(0, 0, 32)
			defaultupgrade = 0
			teamnum        = TF_TEAM_RED
			touch_trigger  = "ghosttrigger"
			"$ratemult"    : 0.6
		})

		hDisp.ValidateScriptScope()
		local hDisp_scope = hDisp.GetScriptScope()
		hDisp_scope.flBooTime    <- 0
		hDisp_scope.iButtonsLast <- 0
		hDisp_scope.bCamera      <- false
		local iEntIndex = hPlayer.entindex()
		hDisp_scope.Think <- function()
		{
			if(!hPlayer.IsAlive() || hPlayer.GetTeam() != 2)
				{ self.Kill(); return }

			local iButtons         = GetPropInt(hPlayer, "m_nButtons")
			local iButtonsChanged  = iButtonsLast ^ iButtons
			local iButtonsPressed  = iButtonsChanged & iButtons
			local iButtonsReleased = iButtonsChanged & (~iButtons)
			iButtonsLast = iButtons

			if(iButtonsPressed & IN_ATTACK && Time() >= flBooTime)
			{
				flBooTime = Time() + 1
				hPlayer.EmitSound("Halloween.GhostBoo")
			}

			EmitSoundEx({
				sound_name = "misc/null.wav"
				flags      = SND_CHANGE_PITCH | SND_IGNORE_NAME
				pitch      = 120
				entity     = hDisp
			})

			EntFireByHandle(self, "RunScriptCode", format("SetPropBoolArray(activator, `m_bAlive`, false, %i)", iEntIndex), -1, hPlayerManager, null)
			local bCameraNow = false
			for(local hCamera; hCamera = FindByClassname(hCamera, "point_viewcontrol");)
				if(GetPropInt(hCamera, "m_state") == 1)
					{ bCameraNow = true; break}

			if(bCameraNow && !bCamera) // ghosts dont like cameras
			{
				bCamera = true
				local hCameraFix = SpawnEntityFromTable("point_viewcontrol", {})
				SetPropEntity(hCameraFix, "m_hPlayer", hPlayer)
				hCameraFix.AcceptInput("Disable", null, hPlayer, null)
				hCameraFix.Kill()
			}
			else if(!bCameraNow && bCamera)
				bCamera = false

			return -1
		}
		AddThinkToEnt(hDisp, "Think")

		SetPropEntity(hDisp, "m_hMovePeer", hPlayer.FirstMoveChild())
		SetPropEntity(hPlayer, "m_hMoveChild", hDisp)
		SetPropEntity(hDisp, "m_hMoveParent", hPlayer)

		SetPropString(hTouch, "m_iName", "")
		SetPropEntity(hTouch, "m_hMovePeer", hDisp.FirstMoveChild())
		SetPropEntity(hDisp, "m_hMoveChild", hTouch)
		SetPropEntity(hTouch, "m_hMoveParent", hDisp)

		if(SeenGhostAnno.find(hPlayer) == null)
		{
			SendAnnotationOn(hPlayer, "Chase your allies to support them", 5, false, 2)
			SeenGhostAnno.append(hPlayer)
		}
	}
	function OnGameEvent_player_death(params)
	{
		local hAttacker = GetPlayerFromUserID(params.attacker)
		local hVictim   = GetPlayerFromUserID(params.userid)
		local bBot      = hVictim.IsBotOfType(TF_BOT_TYPE)

		DispatchParticleEffectOn(hVictim, null)
		hVictim.SetScriptOverlayMaterial(null)

		// eyelander
		local EyelanderIndexes = {
			[132]  = null,
			[266]  = null,
			[482]  = null,
			[1082] = null
		}
		if(hAttacker && params.weapon_def_index in EyelanderIndexes)
			EntFire("bignet", "RunScriptCode", "SetPropInt(activator, `m_Shared.m_iDecapitations`, GetPropInt(activator, `m_Shared.m_iDecapitations`) - 1); activator.SetHealth(activator.GetHealth() - 15)", -1, hAttacker)

		// candy cane nerf
		local hPack = FindByClassnameNearest("item_healthkit_small", hVictim.GetCenter(), 1)
		if(hPack && hPack.GetAbsVelocity().Length() > 0)
		{
			SetPropInt(hPack, "m_nRenderMode", kRenderTransAlpha)
			hPack.ValidateScriptScope()
			local hPack_scope = hPack.GetScriptScope()
			hPack_scope.flTimeNext <- Time() + 3
			hPack_scope.iState     <- 0
			hPack_scope.Think <- function()
			{
				if(!self.IsValid()) return
				local flTime = Time()
				if(flTime >= flTimeNext)
				{
					flTimeNext = flTime + 0.15
					iState++
					self.AcceptInput("Alpha", iState & 1 ? "25" : "255", null, null)
					if(iState >= 20) self.Kill()
				}
				return -1
			}
			AddThinkToEnt(hPack, "Think")
		}

		if(!bBot)
		{
			if(!bInWave || bInBreak)
				EntFire("bignet", "RunScriptCode", "if(activator && activator.IsValid() && !activator.IsAlive() && activator.GetTeam() == TF_TEAM_RED) activator.ForceRespawn()", 3, hVictim)
			else
			{
				AliveCountCheck()
				EmitSoundEx({
					sound_name  = "npc/stalker/go_alert2.wav"
					filter_type = RECIPIENT_FILTER_GLOBAL
				})
				EmitSoundEx({
					sound_name  = "npc/stalker/go_alert2.wav"
					filter_type = RECIPIENT_FILTER_GLOBAL
					volume      = 0.75
				})
				local vecOrigin = hVictim.GetOrigin()
				local angEyes = hVictim.EyeAngles()
				EntFire("bignet", "RunScriptCode", format("Trespasser.BecomeGhost(activator, Vector(%f, %f, %f), QAngle(%f, %f, 0))", vecOrigin.x, vecOrigin.y, vecOrigin.z, angEyes.x, angEyes.y), 6, hVictim)
			}
		}
		else
		{
			// delayed to the end of the tick due to a weird issue with explosives
			local DispatchParticleEffectDelay = @(particle, position, forward) EntFire("bignet", "RunScriptCode", format("DispatchParticleEffect(`%s`, %s, %s)", particle, position, forward), -1, hVictim)
			if(hVictim.HasBotTag("blood_death"))
				DispatchParticleEffectDelay("env_sawblood", "activator.GetCenter()", "Vector(1)")
			if(hVictim.HasBotTag("blood_death_big"))
				DispatchParticleEffectDelay("tfc_sniper_mist", "activator.GetCenter()", "Vector(1)")
			if(hVictim.HasBotTag("blood_death_huge"))
			{
				local hTempParticle = SpawnEntityFromTable("info_particle_system", {
					origin = hVictim.GetOrigin() + Vector(0, 0, -256)
					angles = QAngle(-90, 0, 0)
					effect_name = "bonzo_vomit2_red"
					start_active = 1
				})
				EntFireByHandle(hTempParticle, "Kill", null, 5, null, null)
				hVictim.EmitSound("vehicles/airboat/pontoon_splash1.wav")
			}
			if(hVictim.HasBotTag("blood_death_green"))
				DispatchParticleEffectDelay("duck_collect_blood_green", "activator.GetCenter()", "Vector(1)")
			if(hVictim.HasBotTag("explosive_death"))
				DispatchParticleEffectDelay("rd_robot_explosion_smoke_linger", "activator.GetOrigin()", "Vector(1)")
			if(hVictim.HasBotTag("explosive_death_sound"))
				hVictim.EmitSound("Zombie.Boss.Explode")
			if(hVictim.HasBotTag("metal_death"))
				DispatchParticleEffectDelay("bot_death", "activator.GetOrigin()", "Vector(1)")
			if(hVictim.HasBotTag("emissary_cash"))
				EntFire("p_custom_money_1", "ForceSpawnAtEntityOrigin", "!activator", -1, hVictim)

			local Tags = {}
			hVictim.GetAllBotTags(Tags)
			foreach(i, sTag in Tags)
				if(startswith(sTag, "bot_viro_"))
				{
					local sType = sTag.slice(9).toupper()
					if(sType in ViroScript.Summons1)
						ViroScript.iActiveSummons1--
					else
						ViroScript.iActiveSummons2--
				}

			if(hVictim.GetTeam() != TF_TEAM_RED && RandomFloat(0, 1) < 0.01)
				SpawnCrumpkin(hVictim.GetCenter())
		}
		if(hVictim.GetTeam() == TF_TEAM_RED && params.userid != params.attacker && RandomFloat(0, 1) < 0.3)
			SpawnCrumpkin(hVictim.GetCenter())
	}

	// make reds scream once theyve reached under a certain amount of health
	ScreamTimeTable = {}
	function OnGameEvent_player_hurt(params)
	{
		local hPlayer = GetPlayerFromUserID(params.userid)
		if(hPlayer.GetTeam() == TF_TEAM_RED)
		{
			local flTime = Time()
			local iHealth = hPlayer.GetHealth()
			if(iHealth > 0 && iHealth <= 25 && iHealth + params.damageamount > 25 && (!(hPlayer in ScreamTimeTable) || flTime >= ScreamTimeTable[hPlayer]))
			{
				ScreamTimeTable[hPlayer] <- flTime + 60
				hPlayer.AcceptInput("SpeakResponseConcept", "HalloweenLongFall", null, null)
			}
		}
	}

	// sets all monoculus rockets to be the same speed and removes crits
	function MonoculusScript()
	{
		Trespasser.SendAnnotationOn(self, "Melee attacks can reflect eyeball rockets", 7, true, 5)
		EntFire("@f@filter_red_alive@player", "$AddPlayerAttribute", "melee airblast|1")

		local hMonoculus = self
		if(Trespasser.bSoloMode)
			if(hMonoculus)
			{
				hMonoculus.SetHealth(5000)
				hMonoculus.SetMaxHealth(5000)
			}

		local iEyeRocketModelIndex = PrecacheModel("models/props_halloween/eyeball_projectile.mdl")
		local flEyeRocketSpeed = 715.0
		hMonoculus.GetScriptScope().Think <- function()
		{
			for(local hRocket; hRocket = FindByClassname(hRocket, "tf_projectile_rocket");)
				if(GetPropInt(hRocket, "m_nModelIndex") == iEyeRocketModelIndex && GetPropBool(hRocket, "m_bCritical"))
				{
					hRocket.StopSound("Weapon_RPG.SingleCrit")
					hRocket.EmitSound("Weapon_RPG.Single")
					SetPropBool(hRocket, "m_bCritical", false)
					local vecVelocity = hRocket.GetAbsVelocity()
					if(vecVelocity.Length() != flEyeRocketSpeed)
					{
						vecVelocity.Norm()
						hRocket.SetAbsVelocity(vecVelocity * flEyeRocketSpeed)
					}
				}
			return -1
		}
		AddThinkToEnt(hMonoculus, "Think")
	}

	// converts spies to be perma cloaked at 15% visibility while still being able to attack
	function SetSpecialCloak()
	{
		local hPlayer = self
		local hItem   = hPlayer.GetActiveWeapon()
		for(local hChild = hPlayer.FirstMoveChild(); hChild; hChild = hChild.NextMovePeer())
			if(hChild != hItem && hChild.GetScriptThinkFunc() == "")
				{ hItem = hChild; break }
		if(!hItem) return

		hPlayer.AddCond(TF_COND_STEALTHED_USER_BUFF_FADING)
		hItem.ValidateScriptScope()
		local hItem_scope = hItem.GetScriptScope()
		hItem_scope.Think <- function()
		{
			if(!self.IsValid()) return
			if(hPlayer.InCond(TF_COND_STEALTHED))
				hPlayer.RemoveCond(TF_COND_STEALTHED)
			SetPropFloat(hPlayer, "m_Shared.m_flInvisChangeCompleteTime", Time() + 0.15)
			return -1
		}
		AddThinkToEnt(hItem, "Think")
	}

	// works exactly like the hot hand except animations will play properly on other classes
	function SetZombieSlap()
	{
		local hPlayer = self
		local hMelee
		for(local i = 0; i <= 8; i++)
		{
			local hWeapon = GetPropEntityArray(hPlayer, "m_hMyWeapons", i)
			if(hWeapon && hWeapon.GetSlot() == 2)
				{ hMelee = hWeapon; break }
		}
		if(!hMelee) return

		hMelee.ValidateScriptScope()
		local hMelee_scope = hMelee.GetScriptScope()
		hMelee_scope.flNextPrimaryAttackLast <- GetPropFloat(hMelee, "m_flNextPrimaryAttack")
		hMelee_scope.flNextPrimaryAttackAgain <- -1
		hMelee_scope.Think <- function()
		{
			local flNextPrimaryAttack = GetPropFloat(self, "m_flNextPrimaryAttack")
			if(flNextPrimaryAttack != flNextPrimaryAttackLast)
			{
				flNextPrimaryAttackLast = flNextPrimaryAttack
				if(flNextPrimaryAttackAgain >= 0)
					flNextPrimaryAttackAgain = -1
				else
					flNextPrimaryAttackAgain = Time() + 0.315
			}
			if(flNextPrimaryAttackAgain >= 0)
			{
				local flTime = Time()
				if(flTime >= flNextPrimaryAttackAgain)
				{
					SetPropInt(self, "m_flNextPrimaryAttack", 0)
					self.PrimaryAttack()
				}
			}
			return -1
		}
		AddThinkToEnt(hMelee, "Think")
	}

	function OnGameEvent_player_team(params)
	{
		local hPlayer = GetPlayerFromUserID(params.userid)
		if(!hPlayer || hPlayer.IsBotOfType(TF_BOT_TYPE)) return

		if(params.team == TF_TEAM_RED)
		{
			local sNetworkID = GetPropString(hPlayer, "m_szNetworkIDString")

			local iPlayerClass
			if(sNetworkID in DisconnectedPlayerClass && (!bInWave ? DisconnectedPlayerClass[sNetworkID] != TF_CLASS_CIVILIAN : true))
				iPlayerClass = DisconnectedPlayerClass[sNetworkID]

			if(iPlayerClass != null)
			{
				SetPropInt(hPlayer, "m_Shared.m_iDesiredPlayerClass", iPlayerClass)
				EntFire("bignet", "RunScriptCode", "if(activator && activator.IsValid() && !activator.IsAlive()) activator.ForceRespawn()", -1, hPlayer)
			}
		}

		if(params.team == TEAM_SPECTATOR && hPlayer in ActivePlayers)
			delete ActivePlayers[hPlayer]

		if(params.oldteam == TEAM_SPECTATOR)
			EntFire("bignet", "RunScriptCode", "if(activator && activator.IsValid() && !activator.IsAlive()) activator.ForceRespawn()", -1, hPlayer)

		if(params.autoteam == 1 && params.oldteam == TF_TEAM_BLUE)
		{
			PrecacheSound("vo/eli_lab/eli_handle_b.wav")
			local SoundTable = {
				sound_name  = "vo/eli_lab/eli_handle_b.wav"
				entity      = hPlayer
				filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
			}
			EmitSoundEx(SoundTable)
			EmitSoundEx(SoundTable)
			EmitSoundEx(SoundTable)
			hPlayer.AcceptInput("$ResetInventory", null, null, null)
			EntFire("bignet", "RunScriptCode", "activator.SetScriptOverlayMaterial(`effects/tp_eyefx/tp_eyefx_eli`); activator.SetHudHideFlags(-1); activator.ForceChangeTeam(TF_TEAM_RED, true)", -1, hPlayer)
			EntFire("bignet", "RunScriptCode", "activator.SetScriptOverlayMaterial(null); activator.SetHudHideFlags(0)", 3, hPlayer)
		}
	}

	function Virophage()
	{
		local hViro      = activator
		local hBase      = self
		local hPopulator = FindByClassname(null, "point_populator_interface")
		Summons1 <- {
			GENERIC  = 0
			UNCOMMON = 0
			HEADLESS = 0
			SKELETON = 0
			BURNING  = 0
			POISON   = 0
		}
		flTimeSummon1   <- Time()
		iActiveSummons1 <- 0
		iMaxSummons1    <- 10

		Summons2 <- {
			LEAPER = 0
			BRUTE  = 0
			PLAGUE = 0
		}
		flTimeSummon2   <- Time() + 30
		iActiveSummons2 <- 0
		iMaxSummons2    <- 1

		flTimeSlow <- 0
		local RNGNormal        = ["GENERIC", "UNCOMMON", "HEADLESS", "SKELETON", "BURNING", "POISON"]
		local RNGBig           = ["LEAPER", "PLAGUE", "BRUTE"]
		local iRNGNormalLength = RNGNormal.len()
		local iRNGBigLength    = RNGBig.len()

		flTimeNom <- 0
		Trespasser.ViroScript <- this
		function Think()
		{
			local flTime = Time()
			//////////////// IDLE NOISE ////////////////
			if(flTime >= flTimeNom)
			{
				flTimeNom = flTime + 1
				ScreenShake(hViro.GetOrigin(), 16, 32, 3, 64, 0, true)
				self.AcceptInput("$PlaySound", "Virophage.Excited", null, null)
			}
			//////////////// IDLE NOISE ////////////////

			//////////////// SUMMONING ////////////////
			local iHealth         = hViro.GetHealth()
			local flHealthPercent = iHealth / hViro.GetMaxHealth().tofloat()
			if(flHealthPercent <= 0) flHealthPercent = 0.01
			local flHealthPercentInverse = 1 - flHealthPercent

			local bCanSummon1 = iActiveSummons1 < iMaxSummons1
			local bCanSummon2 = iActiveSummons2 < iMaxSummons2

			local sNormal = RNGNormal[floor(flHealthPercentInverse * iRNGNormalLength)]
			local sBig    = RNGBig[floor(flHealthPercentInverse * iRNGBigLength)]

			if(flTime >= flTimeSummon1)
			{
				flTimeSummon1 = flTime + 1
				if(bCanSummon1)
				{
					Summons1[sNormal]++
				}
			}
			if(flTime >= flTimeSummon2)
			{
				flTimeSummon2 = flTime + 30
				if(bCanSummon2)
				{
					hViro.AcceptInput("$PlaySound", "npc/zombie_poison/pz_pain2.wav", null, null)
					Summons2[sBig]++
				}
			}

			if(flTime >= flTimeSlow)
			{
				flTimeSlow = flTime + 0.5
				AlternateWaves.AddWaveIcons([
					[ "heavy_zombie_lite",      0, sNormal == "GENERIC" || sNormal == "UNCOMMON" ? MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT : MVM_CLASS_FLAG_NONE ],
					[ "pyro_scout_fireaxe_bat", 0, sNormal == "HEADLESS" ? MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT : MVM_CLASS_FLAG_NONE ],
					[ "dead_multi_lite",        0, sNormal == "SKELETON" ? MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT : MVM_CLASS_FLAG_NONE ],
					[ "dead_flame_lite",        0, sNormal == "BURNING" ? MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT : MVM_CLASS_FLAG_NONE ],
					[ "pyro_membrain_lite",     0, sNormal == "POISON" || sBig == "PLAGUE" ? MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT : MVM_CLASS_FLAG_NONE ],
					[ "spy_facepeel_lite",      0, sBig == "LEAPER" ? MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT : MVM_CLASS_FLAG_NONE ],
					[ "heavy_zombie_arm2_lite", 0, sBig == "BRUTE" ? MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT : MVM_CLASS_FLAG_NONE ]
				])
			}

			local Wavespawn = @(bResume, sType) hPopulator.AcceptInput(bResume ? "$ResumeWavespawn" : "$PauseWavespawn", format("VIRO_%s", sType), null, null)
			foreach(sType, Params in Summons1)
				Wavespawn(bCanSummon1 && Params > 0, sType)
			foreach(sType, Params in Summons2)
				Wavespawn(bCanSummon2 && Params > 0, sType)
			//////////////// SUMMONING ////////////////
			return -1
		}
		AddThinkToEnt(self, "Think")
	}

	function ForceRespawnDeadRed()
	{
		if(bGameOver || bSoloMode) return
		EntFire("pd_dispenser", "Kill", null, -1)
		for(local i = 1; i <= MAX_CLIENTS; i++)
		{
			local hPlayer = PlayerInstanceFromIndex(i)
			if(hPlayer && !hPlayer.IsFakeClient() && !IsAliveExtra(hPlayer) && hPlayer.GetTeam() == TF_TEAM_RED)
			{
				hPlayer.ForceRespawn()
				ScreenFade(hPlayer, 0, 0, 0, 255, 1, 0, 1)
			}
		}
	}

	function GetAllPlayersOfType(iTeamNums = null, bAlive = null, bBot = null)
	{
		local Players       = []
		local bCheckTeamNum = iTeamNums != null
		local bCheckAlive   = bAlive    != null
		local bCheckBot     = bBot      != null
		for(local i = 1; i <= MAX_CLIENTS; i++)
		{
			local hPlayer = PlayerInstanceFromIndex(i)
			if(hPlayer && (bCheckTeamNum ? iTeamNums.find(hPlayer.GetTeam()) != null : true) && (bCheckAlive ? IsAliveExtra(hPlayer) == bAlive : true) && (bCheckBot ? hPlayer.IsBotOfType(TF_BOT_TYPE) == bBot : true))
				Players.append(hPlayer)
		}
		return Players
	}

	function GetRandomPlayer(iTeamNums = null, bAlive = null, bBot = null)
	{
		local Players     = GetAllPlayersOfType(iTeamNums, bAlive, bBot)
		local ArrayLength = Players.len()
		if(ArrayLength > 0) return Players[RandomInt(0, ArrayLength - 1)]
		else return null
	}

	SelectedFromShuffle = []
	function GetRandomPlayerShuffle(iTeamNums = null, bAlive = null, bBot = null)
	{
		local Players = GetAllPlayersOfType(iTeamNums, bAlive, bBot)

		local Delete = []
		foreach(hPlayer in SelectedFromShuffle)
		{
			local Index = Players.find(hPlayer)
			if(Index != null)
				Players.remove(Index)
		}

		local ArrayLength = Players.len()
		if(ArrayLength > 0)
		{
			local hSelectedPlayer = Players[RandomInt(0, ArrayLength - 1)]
			SelectedFromShuffle.append(hSelectedPlayer)
			return hSelectedPlayer
		}
		else if(SelectedFromShuffle.len() == 0) return null
		else
		{
			SelectedFromShuffle.clear()
			return GetRandomPlayerShuffle(iTeamNums, bAlive, bBot)
		}
	}

	function SetDoppelganger(hBot, hPlayer)
	{
		if(!hPlayer && hBot) { hBot.TakeDamage(hBot.GetHealth() + 10, DMG_ALWAYSGIB, hBot); return }
		else if(!hBot) return
		local iPlayerClass = hPlayer.GetPlayerClass()
		local sClassIcon   = GetPropString(hBot, "m_PlayerClass.m_iszClassIcon")
		local bGiant       = hBot.IsMiniBoss()
		local bHealthBar   = GetPropBool(hBot, "m_bUseBossHealthBar")
		local vecOrigin    = hBot.GetOrigin()
		local angRotation  = hBot.EyeAngles()

		SetPropInt(hBot, "m_Shared.m_iDesiredPlayerClass", iPlayerClass)
		hBot.SetPlayerClass(iPlayerClass)
		hBot.DispatchSpawn()

		local OldItems = []
		for(local hChild = hBot.FirstMoveChild(); hChild; hChild = hChild.NextMovePeer())
			if(HasProp(hChild, "m_AttributeManager") && hChild.GetClassname() != "tf_wearable")
				OldItems.append(hChild)
		foreach(hItem in OldItems) hItem.Kill()

		hBot.SetAbsOrigin(vecOrigin)
		hBot.SnapEyeAngles(angRotation)

		SetPropString(hBot, "m_PlayerClass.m_iszClassIcon", sClassIcon)
		hBot.SetIsMiniBoss(bGiant)
		hBot.SetUseBossHealthBar(bHealthBar)
		if(bSoloMode) hBot.SetDifficulty(EASY)

		SetFakeClientConVarValue(hBot, "name", format("%s%s", "็", GetPropString(hPlayer, "m_szNetname")))
		hBot.SetHealth(hBot.GetMaxHealth())
		hBot.SetCustomModelWithClassAnimations(hPlayer.GetModelName())
		local hWeapon = hPlayer.GetActiveWeapon()
		if(!hWeapon) return
		local iCurrentSlot = hWeapon.GetSlot()

		local CopyAttributes = [
			"always crit"
			"blast radius increased"
			"minicrits become crits"
			"mod_maxhealth_drain_rate"
			"mult bleeding delay"
			"mult bleeding dmg"
			"mult crit dmg"
			"mult_player_movespeed_active"
			"speed_boost_on_hit"
			"stickybomb charge rate"
			"unique craft index"

			"airblast pushback scale"
			"ammo regen"
			"applies snare effect"
			"armor piercing"
			"attack projectiles"
			"bidirectional teleport"
			"bleeding duration"
			"building instant upgrade"
			"canteen specialist"
			"charge recharge rate increased"
			"clip size bonus upgrade"
			"clip size upgrade atomic"
			"critboost on kill"
			"damage bonus"
			"damage force reduction"
			"dmg taken from blast reduced"
			"dmg taken from bullets reduced"
			"dmg taken from crit reduced"
			"dmg taken from fire reduced"
			"effect bar recharge rate increased"
			"engy building health bonus"
			"engy dispenser radius increased"
			"engy disposable sentries"
			"engy sentry fire rate increased"
			"explode_on_ignite"
			"explosive sniper shot"
			"falling_impact_radius_stun"
			"faster reload rate"
			"fire rate bonus"
			"fire rate bonus"
			"generate rage on damage"
			"generate rage on heal"
			"heal on kill"
			"healing mastery"
			"health regen"
			"increase buff duration"
			"mad milk syringes"
			"mark for death"
			"max health additive bonus"
			"maxammo grenades1 increased"
			"maxammo metal increased"
			"maxammo primary increased"
			"maxammo secondary increased"
			"melee attack rate bonus"
			"move speed bonus"
			"mult_item_meter_charge_rate"
			"overheal expert"
			"projectile penetration heavy"
			"projectile penetration"
			"projectile speed increased"
			"robo sapper"
			"rocket specialist"
			"SRifle Charge rate increased"
			"thermal_thruster_air_launch"
			"uber duration bonus"
			"ubercharge rate bonus"
			"weapon burn dmg increased"
			"weapon burn time increased"

			"attach particle effect static"
			"attach particle effect"
			"custom_paintkit_seed_hi"
			"custom_paintkit_seed_lo"
			"is australium item"
			"item style override"
			"killstreak effect"
			"killstreak idleeffect"
			"killstreak tier"
			"paintkit_proto_def_index"
			"set item tint RGB 2"
			"set item tint RGB"
			"set_item_texture_wear"
			"style changes on strange level"
		]

		local GiveItem = function(hPlayer, sClassname, iItemIndex)
		{
			local bWearable      = !startswith(sClassname, "tf_weapon")
			local iItemIndexReal = iItemIndex
			local sClassnameReal = sClassname
			if(bWearable)
			{
				iItemIndex = 1101
				sClassname = "tf_weapon_parachute"
			}

			local hItem = CreateByClassname(sClassname)
			SetPropInt(hItem, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", iItemIndex)
			SetPropBool(hItem, "m_AttributeManager.m_Item.m_bInitialized", true)
			SetPropBool(hItem, "m_bValidatedAttachedEntity", true)
			hItem.SetTeam(hPlayer.GetTeam())
			hItem.DispatchSpawn()

			if(bWearable)
			{
				hPlayer.Weapon_Equip(hItem)
				local hWearable = GetPropEntity(hItem, "m_hExtraWearable")
				hItem.Kill()
				SetPropString(hWearable, "m_iClassname", sClassnameReal)
				SetPropInt(hWearable, "m_nModelIndex", 0)
				SetPropInt(hWearable, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", iItemIndexReal)
				SetPropBool(hWearable, "m_AttributeManager.m_Item.m_bInitialized", true)
				hWearable.DispatchSpawn()

				SetPropBool(hWearable, "m_bForcePurgeFixedupStrings", true)
				hWearable.ValidateScriptScope()
				hWearable.GetScriptScope().Think <- function()
				{
					if("Shield" in this) Shield()
					if(!hPlayer.IsAlive())
					{
						SetPropString(self, "m_iszScriptThinkFunction", "")
						EntFireByHandle(self, "RunScriptCode", "self.Kill()", 0.033, null, null)
					}
					return -1
				}
				if(sClassnameReal == "tf_wearable_demoshield")
				{
					hWearable.AddAttribute("Attack not cancel charge", 1, -1)
					hWearable.GetScriptScope().Shield <- function()
					{
						if(GetPropInt(hPlayer, "m_nButtons") & IN_ATTACK && GetPropFloat(hPlayer, "m_Shared.m_flChargeMeter") >= 100)
							hPlayer.AddCond(TF_COND_SHIELD_CHARGE)
					}
				}
				AddThinkToEnt(hWearable, "Think")
				hItem = hWearable
			}
			else
			{
				hPlayer.Weapon_Equip(hItem)
			}
			return hItem
		}

		local WeaponBlacklist = [
			"tf_weapon_builder"
			"tf_weapon_sapper"
			"tf_weapon_pda_engineer_build"
			"tf_weapon_pda_engineer_destroy"
			"tf_weapon_jar_milk"
			"tf_weapon_lunchbox"
			"tf_weapon_lunchbox_drink"
			"tf_weapon_buff_item"
			"tf_weapon_rocketpack"
			265
		]

		local iUserID = GetPropIntArray(hPlayerManager, "m_iUserID", hBot.entindex())
		for(local hChild = hPlayer.FirstMoveChild(); hChild; hChild = hChild.NextMovePeer())
			if(HasProp(hChild, "m_AttributeManager"))
			{
				local iWeaponSlot = "GetSlot" in hChild ? hChild.GetSlot() : -1
				local sClassname = hChild.GetClassname()
				local iItemIndex = GetPropInt(hChild, "m_AttributeManager.m_Item.m_iItemDefinitionIndex")
				if(WeaponBlacklist.find(sClassname) != null || WeaponBlacklist.find(iItemIndex) != null) continue
				if(sClassname == "tf_weapon_laser_pointer" && iItemIndex == 0) continue

				local hItem
				local flAttribute = hChild.GetAttribute("is commodity", 0)
				if(flAttribute < 0) continue
				local bIsCustomWeapon = flAttribute != 0 // we applied this to all custom weapons, no real way to check for a custom weapon without it
				if(bIsCustomWeapon)
				{
					hChild.KeyValueFromString("targetname", "whatisyouritemname")
					local hLua = CreateByClassname("$script_manager")
					hLua.AcceptInput("$ExecuteScript", format("ents.GetPlayerByUserId(%i):GiveItem(ents.FindByName('whatisyouritemname'):GetItemName()):SetName('heresdoppelsweaponcopy')", iUserID), null, null)
					hLua.Kill()
					hChild.KeyValueFromString("targetname", "")
					hItem = FindByName(null, "heresdoppelsweaponcopy")
					hItem.KeyValueFromString("targetname", "")
				}
				else
				{
					hItem = GiveItem(hBot, sClassname, iItemIndex)
					hItem.EnableDraw()
				}
				if(iWeaponSlot != -1 && hItem.GetSlot() == iCurrentSlot)
				{
					hBot.Weapon_Switch(hItem)
					hBot.AddCustomAttribute("disable weapon switch", 1, -1)
				}
				foreach(sAttr in CopyAttributes)
				{
					local Attr = hChild.GetAttribute(sAttr, 1337)
					if(Attr != 1337)
						hItem.AddAttribute(sAttr, Attr, -1)
				}

				if(sClassname == "tf_weapon_cannon")
					hItem.AddAttribute("grenade launcher mortar mode", 0, -1)
				if(sClassname == "tf_weapon_medigun" && iPlayerClass == TF_CLASS_CIVILIAN)
					hItem.AcceptInput("SetBodyGroup", "1", null, null)
			}

		foreach(sAttr in CopyAttributes)
		{
			local Attr = hPlayer.GetCustomAttribute(sAttr, 1337)
			if(Attr != 1337)
				hBot.AddCustomAttribute(sAttr, Attr, -1)
		}

		local ZombieCosmetics = [
			5617
			5617
			5625
			5618
			5620
			5622
			5619
			5624
			5623
			5621
			5621
		]
		local hZombie = GiveItem(hBot, "tf_wearable", ZombieCosmetics[iPlayerClass])
		hZombie.GetScriptScope().CopyThink <- function()
		{
			if(!hPlayer || !hPlayer.IsValid() || !hPlayer.IsAlive()) return

			local hWeapon = hBot.GetActiveWeapon()
			local hPlayerWeapon = hPlayer.GetActiveWeapon()
			if(hWeapon && hPlayerWeapon)
			{
				local iSlot = hWeapon.GetSlot()
				local iPlayerSlot = hPlayerWeapon.GetSlot()
				if(iSlot != iPlayerSlot)
				{
					hBot.RemoveCustomAttribute("disable weapon switch")
					hBot.AcceptInput("$WeaponSwitchSlot", iPlayerSlot.tostring(), null, null)
					hBot.AddCustomAttribute("disable weapon switch", 1, -1)
				}
			}

			if(!Trespasser.bSoloMode)
			{
				local iPlayerCond    = GetPropInt(hPlayer, "m_Shared.m_nPlayerCond")
				local iPlayerCondEx  = GetPropInt(hPlayer, "m_Shared.m_nPlayerCondEx")
				local iPlayerCondEx2 = GetPropInt(hPlayer, "m_Shared.m_nPlayerCondEx2")
				local iPlayerCondEx3 = GetPropInt(hPlayer, "m_Shared.m_nPlayerCondEx3")
				local iPlayerCondEx4 = GetPropInt(hPlayer, "m_Shared.m_nPlayerCondEx4")
				for(local i = 0; i <= 31; i++)
				{
					local iBit = 1 << i
					if(iPlayerCond & iBit && i != 7) hBot.AddCondEx(i, 0.03, null)
					if(iPlayerCondEx & iBit) hBot.AddCondEx(i + 32, 0.03, null)
					if(iPlayerCondEx2 & iBit && i != 13) hBot.AddCondEx(i + 64, 0.03, null)
					if(iPlayerCondEx3 & iBit) hBot.AddCondEx(i + 96, 0.03, null)
					if(iPlayerCondEx4 & iBit) hBot.AddCondEx(i + 128, 0.03, null)
				}
			}
		}
		if(iPlayerClass == TF_CLASS_CIVILIAN)
		{
			hZombie.AddAttribute("never gib", 1, -1)
			SetPropBool(hBot, "m_bForcedSkin", true)
			hZombie.DisableDraw()
			hZombie.GetScriptScope().Think <- function()
			{
				CopyThink()
				SetPropInt(hBot, "m_nForcedSkin", 3)
				if(!hBot.IsAlive())
				{
					SetPropString(self, "m_iszScriptThinkFunction", "")
					SetPropBool(hBot, "m_bForcedSkin", false)
					SetPropInt(hBot, "m_nForcedSkin", 0)
					EntFireByHandle(self, "RunScriptCode", "self.Kill()", 0.033, null, null)
				}
				return -1
			}
		}
		else
		{
			SetPropInt(hBot, "m_iPlayerSkinOverride", 1)
			hZombie.GetScriptScope().Think <- function()
			{
				CopyThink()
				if(!hBot.IsAlive())
				{
					SetPropString(self, "m_iszScriptThinkFunction", "")
					SetPropInt(hBot, "m_iPlayerSkinOverride", 0)
					EntFireByHandle(self, "RunScriptCode", "self.Kill()", 0.033, null, null)
				}
				return -1
			}
		}
		SendGlobalGameEvent("post_inventory_application", { userid = iUserID })
	}

	function TeleportWithinCircle(hEnt, vecOrigin, flRadius)
	{
		local vecForward = QAngle(0, RandomFloat(0, 360), 0).Forward() * RandomFloat(0, flRadius)
		hEnt.SetAbsOrigin(vecOrigin + vecForward)
	}

	HalloweenBossIcon = ["special_blimp", 404, MVM_CLASS_FLAG_MINIBOSS]
	function SetWavebar(iWave)
	{
		local bWave0 = iWave == 0
		EntFire("tf_objective_resource", "$SetClientProp$m_nMvMEventPopfileType", bWave0 ? "1" : "0", -1)
		EntFire("tf_objective_resource", "$SetClientProp$m_nMannVsMachineWaveCount", bWave0 ? "1" : iWave.tostring(), -1)
		EntFire("tf_objective_resource", "$SetClientProp$m_nMannVsMachineMaxWaveCount", bWave0 ? "0" : "7", -1)
		AlternateWaves.ClearWaveIcons()
		switch(iWave)
		{
			case 1:
				AlternateWaves.AddWaveIcons([
					[ "heavy_zombie_arm1_lite", 3,   MVM_CLASS_FLAG_MINIBOSS ],
					[ "heavy_zombie_lite",      175, MVM_CLASS_FLAG_MINIBOSS ],
					[ "heavy_zombie_arm2_lite", 1,   MVM_CLASS_FLAG_MINIBOSS | MVM_CLASS_FLAG_ALWAYSCRIT ]
				])
				break
			case 2:
				AlternateWaves.AddWaveIcons([
					[ "heavy_zombie_arm2_lite", 3,  MVM_CLASS_FLAG_MINIBOSS ],
					[ "heavy_zombie_lite",      43, MVM_CLASS_FLAG_NORMAL ],
					[ "spy_facepeel_lite",      4,  MVM_CLASS_FLAG_MINIBOSS ],
					[ "pyro_scout_fireaxe_bat", 75, MVM_CLASS_FLAG_NORMAL ],
					[ "dead_multi_lite",        50, MVM_CLASS_FLAG_NORMAL ]
				])
				break
			case 3:
				AlternateWaves.AddWaveIcons([
					[ "heavy_zombie_arm2_lite", 1,  MVM_CLASS_FLAG_MINIBOSS ],
					[ "spy_facepeel_lite",      1,  MVM_CLASS_FLAG_MINIBOSS ],
					[ "dead_multi_lite",        50, MVM_CLASS_FLAG_NORMAL ],
					[ "pyro_scout_fireaxe_bat", 0, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT ],
					HalloweenBossIcon,
					[ "dead_flame_lite",        55, MVM_CLASS_FLAG_NORMAL ],
					[ "heavy_zombie_lite",      82, MVM_CLASS_FLAG_NORMAL ]
				])
				break
			case 4:
				AlternateWaves.AddWaveIcons([
					[ "pyro_membrain_lite",     125, MVM_CLASS_FLAG_NORMAL ],
					[ "heavy_zombie_arm2_lite", 4,   MVM_CLASS_FLAG_MINIBOSS ],
					[ "dead_flame_lite",        20,  MVM_CLASS_FLAG_NORMAL ],
					[ "random_lite",            1,   MVM_CLASS_FLAG_MINIBOSS ]
				])
				break
			case 5:
				AlternateWaves.AddWaveIcons([
					[ "soldier_gib_lite",    100, MVM_CLASS_FLAG_NORMAL   ],
					[ "soldier",             8,   MVM_CLASS_FLAG_MINIBOSS ],
					[ "shotgun_lite",        25,  MVM_CLASS_FLAG_NORMAL   ],
					[ "medic_uber",          35,  MVM_CLASS_FLAG_NORMAL   ],
					[ "heavy_steelfist_nys", 16,  MVM_CLASS_FLAG_NORMAL   ],
					[ "soldier_burstfire",   2,   MVM_CLASS_FLAG_MINIBOSS | MVM_CLASS_FLAG_ALWAYSCRIT ],
					[ "scout_bombrunner",    0,   MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT ],
					bSoloMode ? [ "tank_black", 1, MVM_CLASS_FLAG_MINIBOSS] : ["tank_combat_minigun", 1, MVM_CLASS_FLAG_MINIBOSS ]
				])
				break
			case 6:
				AlternateWaves.AddWaveIcons([
					[ "pyro_scout_fireaxe_bat", 50, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_ALWAYSCRIT ],
					[ "dead_multi_lite",        50, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_ALWAYSCRIT ],
					[ "heavy_chainsaw",         50, MVM_CLASS_FLAG_NORMAL ],
					[ "dead_flame_lite",        25, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_ALWAYSCRIT ],
					[ "shotgun_lite",           25, MVM_CLASS_FLAG_NORMAL   ],
					[ "spy_facepeel_lite",      3,  MVM_CLASS_FLAG_MINIBOSS ],
					[ "heavy_steelfist_cash",   9,  MVM_CLASS_FLAG_NORMAL   ],
					[ "sentry_gun",             0,  MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT ]
				])
				break
			case 7:
				AlternateWaves.AddWaveIcons([
					[ "heavy_zombie_breach_lite", 0, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT ],
					[ "soldier_spammer",          4, MVM_CLASS_FLAG_MINIBOSS ],
					[ "dead2_ylw_lite",           0, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT ],
					[ "heavy_head_nys",           1, MVM_CLASS_FLAG_MINIBOSS ],
					[ "osprey",                   0, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT ]
				])
				break
			default:
				AlternateWaves.AddWaveIcons([
					[ "heavy_zombie_lite",            300, MVM_CLASS_FLAG_NORMAL ],
					[ "heavy_zombie_arm2_lite",       12,  MVM_CLASS_FLAG_MINIBOSS ],
					[ "spy_facepeel_lite",            8,   MVM_CLASS_FLAG_MINIBOSS ],
					[ "pyro_scout_fireaxe_bat",       125, MVM_CLASS_FLAG_NORMAL ],
					[ "pyro_scout_fireaxe_bat_giant", 0,   MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT ],
					[ "dead_multi_lite",              150, MVM_CLASS_FLAG_NORMAL ],
					HalloweenBossIcon,
					[ "dead_flame_lite",              100, MVM_CLASS_FLAG_NORMAL ],
					[ "pyro_membrain_lite",           125, MVM_CLASS_FLAG_NORMAL ],
					[ "heavy_chainsaw",               50,  MVM_CLASS_FLAG_NORMAL ],
					[ "random_lite",                  1,   MVM_CLASS_FLAG_MINIBOSS ],
					[ "soldier_gib_lite",             100, MVM_CLASS_FLAG_NORMAL   ],
					[ "soldier",                      8,   MVM_CLASS_FLAG_MINIBOSS ],
					[ "shotgun_lite",                 50,  MVM_CLASS_FLAG_NORMAL   ],
					[ "medic_uber",                   35,  MVM_CLASS_FLAG_NORMAL   ],
					[ "heavy_steelfist_nys",          25,  MVM_CLASS_FLAG_NORMAL   ],
					[ "soldier_burstfire",            2,   MVM_CLASS_FLAG_MINIBOSS | MVM_CLASS_FLAG_ALWAYSCRIT ],
					[ "soldier_spammer",              4,   MVM_CLASS_FLAG_MINIBOSS ],
					[ "heavy_zombie_breach_lite",     0,   MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT ],
					[ "tank_combat_minigun",          1,   MVM_CLASS_FLAG_MINIBOSS ],
					[ "dead2_ylw_lite",               0,   MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT ],
					[ "heavy_head_nys",               1,   MVM_CLASS_FLAG_MINIBOSS ],
					[ "scout_bombrunner",             0,   MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT ]
				])
				break
		}
		EntFire("bignet", "RunScriptCode", "Trespasser.AliveCountCheck()", 0.033)
	}

	function Emissary()
	{
		local hPlayer = self
		local hWearable
		for(local hChild = hPlayer.FirstMoveChild(); hChild; hChild = hChild.NextMovePeer())
			if(hChild.GetClassname() == "tf_wearable")
				{ hWearable = hChild; break }
		if(!hWearable) return

		hWearable.ValidateScriptScope()
		local hWearable_scope = hWearable.GetScriptScope()
		hWearable_scope.bTaunting     <- false
		hWearable_scope.hIndicator    <- null
		hWearable_scope.hPlatform     <- null
		hWearable_scope.hPlatformFake <- null
		hWearable_scope.Cleanup       <- function()
		{
			if(hIndicator && hIndicator.IsValid())
				hIndicator.Kill()

			// if(hPlatform && hPlatform.IsValid())
			// {
			// 	local vecOrigin = hPlatform.GetOrigin()
			// 	PrecacheSound("physics/metal/metal_grate_impact_hard3.wav")
			// 	EmitSoundEx({ sound_name = "physics/metal/metal_grate_impact_hard3.wav", sound_level = 90, origin = vecOrigin, filter_type = RECIPIENT_FILTER_GLOBAL })
			// 	Trespasser.ShakeIt()

			// 	if(hPlatformFake && hPlatformFake.IsValid())
			// 		DispatchParticleEffect("merasmus_object_spawn", hPlatformFake.GetOrigin() + hPlatformFake.GetRightVector() * -60, Vector(1))

			// 	hPlatform.Kill()
			// }
			// if(hPlatformFake && hPlatformFake.IsValid())
			// 	hPlatformFake.Kill()
		}
		hWearable_scope.Think <- function()
		{
			local bTauntCond = hPlayer.InCond(TF_COND_TAUNTING)
			if(bTauntCond && !bTaunting)
			{
				bTaunting = true

				if(hIndicator && hIndicator.IsValid())
					hIndicator.Kill()

				hIndicator = CreateByClassname("prop_dynamic")
				hIndicator.SetModelSimple("models/props_mvm/indicator/indicator_circle_long.mdl")
				hIndicator.SetModelScale(0.5, 0)
				hIndicator.KeyValueFromInt("disableshadows", 1)
				hIndicator.SetSkin(1)
				hIndicator.DispatchSpawn()
				hIndicator.AcceptInput("SetAnimation", "start", null, null)
			}
			else if(!bTauntCond && bTaunting)
			{
				bTaunting = false
				Cleanup()
			}
			if(hIndicator && hIndicator.IsValid())
			{
				local vecOrigin = hPlayer.GetOrigin()
				local vecForward = hPlayer.GetForwardVector()
				local vecDestination = vecOrigin + vecForward * 142

				// local bPlatform = hPlatform && hPlatform.IsValid()
				// if(!bPlatform)
				// {
				// 	local Trace = {
				// 		start = vecDestination + Vector(0, 0, 96)
				// 		end = vecDestination + Vector(0, 0, -96)
				// 		hullmin = Vector(-24, -24, 0)
				// 		hullmax = Vector(24, 24, 0)
				// 		mask = MASK_PLAYERSOLID
				// 	}
				// 	TraceHull(Trace)
				// 	if("enthit" in Trace && Trace.enthit.IsPlayer())
				// 	{
				// 		Trace.ignore <- Trace.enthit
				// 		TraceHull(Trace)
				// 	}
				// 	if((vecDestination - Trace.endpos).Length() >= 4)
				// 	{
				// 		local vecRight = hPlayer.GetRightVector()
				// 		local iDestZ = ceil(vecDestination.z < Trace.endpos.z ? Trace.endpos.z + 6 : vecOrigin.z + 6)
				// 		local vecAbove = vecOrigin
				// 		vecAbove.z = iDestZ
				// 		hPlayer.SetAbsOrigin(vecAbove)

				// 		local vecPlatform = vecAbove + vecForward * 80 + vecRight * 32 + Vector(0, 0, -9)
				// 		hPlatform = SpawnEntityFromTable("prop_dynamic", {
				// 			origin         = vecPlatform
				// 			angles         = QAngle(0, 270 + hPlayer.GetAbsAngles().y, 90)
				// 			model          = "models/props_coalmines/wood_fence_128.mdl"
				// 			solid          = 6
				// 			disableshadows = 1
				// 			rendermode     = 1
				// 			renderamt      = 0
				// 			OnTakeDamage   = "!selfRunScriptCodeif(!activator.IsPlayer())return;local w=activator.GetActiveWeapon();if(w&&w.GetSlot()==2)activator.ApplyAbsVelocityImpulse(Vector(0,0,300))-1-1"
				// 		})
				// 		hPlatformFake = SpawnEntityFromTable("prop_dynamic", {
				// 			origin         = vecAbove + vecForward * 81 + vecRight * -60 + Vector(0, 0, -6)
				// 			angles         = QAngle(90, 180 + hPlayer.GetAbsAngles().y, 0)
				// 			model          = "models/props_vehicles/train_flatcar_container_doorl.mdl"
				// 			disableshadows = 1
				// 			modelscale     = 1.95
				// 		})

				// 		PrecacheSound("physics/metal/metal_grate_impact_hard2.wav")
				// 		EmitSoundEx({ sound_name = "physics/metal/metal_grate_impact_hard2.wav", sound_level = 90, entity = hPlatform, filter_type = RECIPIENT_FILTER_GLOBAL })
				// 		Trespasser.ShakeIt()
				// 		DispatchParticleEffect("merasmus_object_spawn", vecAbove + vecForward * 80 + Vector(0, 0, -6), Vector(1))

				// 		for(local hPlayer; hPlayer = FindByClassnameWithin(hPlayer, "player", vecAbove, 512);)
				// 		{
				// 			if(!hPlayer.IsAlive()) continue
				// 			if(!Trespasser.UnstuckEntity(hPlayer))
				// 			{
				// 				local vecPlayerOrigin = hPlayer.GetOrigin()
				// 				hPlayer.SetAbsOrigin(Vector(vecPlayerOrigin.x, vecPlayerOrigin.y, iDestZ + 8))
				// 			}
				// 		}
				// 	}
				// }

				local bOnIndicator = false
				for(local hPlayer; hPlayer = FindByClassnameWithin(hPlayer, "player", vecDestination, 4);)
					if(hPlayer.IsAlive())
						{ bOnIndicator = true; break }

				hIndicator.SetSkin(bOnIndicator ? 3 : 1)
				hIndicator.SetOrigin(vecDestination + Vector(0, 0, 6))
			}
			return -1
		}
		AddThinkToEnt(hWearable, "Think")
		Trespasser.SetDestroyCallback(hWearable, hWearable_scope.Cleanup)
	}

	function OnGameEvent_player_used_powerup_bottle(params) // Deathly Canteen
	{
		if(params.type == 5) // POWERUP_BOTTLE_BUILDINGS_INSTANT_UPGRADE
		{
			local hPlayer = PlayerInstanceFromIndex(params.player)
			EntFire("bignet", "RunScriptCode", "activator.AddCustomAttribute(`building max level`, 3, 0.2)", -1, hPlayer)
			for(local hBuilding; hBuilding = FindByClassname(hBuilding, "obj_*");)
				if(GetPropEntity(hBuilding, "m_hBuilder") == hPlayer)
				{
					if(GetPropInt(hBuilding, "m_iHighestUpgradeLevel") < 3)
					{
						if(GetPropBool(hBuilding, "m_bMiniBuilding"))
						{
							if(GetPropBool(hBuilding, "m_bBuilding"))
							{
								SetPropFloat(hBuilding, "m_flPercentageConstructed", 1)
								SetPropBool(hBuilding, "m_bBuilding", false)
								SetPropInt(hBuilding, "m_iState", 2)
							}
						}
						else
						{
							SetPropInt(hBuilding, "m_iHighestUpgradeLevel", 3)
							hBuilding.ValidateScriptScope()
							local hBuilding_scope = hBuilding.GetScriptScope()
							hBuilding_scope.iHealth      <- hBuilding.GetHealth()
							hBuilding_scope.iMaxHealth   <- hBuilding.GetMaxHealth()
							hBuilding_scope.bPlacingLast <- GetPropBool(hBuilding, "m_bPlacing")
							hBuilding_scope.Think <- function()
							{
								if(!self.IsValid()) return
								local bPlacing = GetPropBool(self, "m_bPlacing")
								if(bPlacingLast && !bPlacing)
									self.SetMaxHealth(iMaxHealth), self.SetHealth(iHealth)
								else if(!bPlacingLast && bPlacing)
									iMaxHealth = self.GetMaxHealth(), iHealth = self.GetHealth()

								if(!bPlacing && GetPropInt(self, "m_iUpgradeLevel") < 3)
								{
									if(GetPropInt(self, "m_iHighestUpgradeLevel") != 3)
									{
										SetPropString(self, "m_iszScriptThinkFunction", "")
										self.TerminateScriptScope()
										return
									}
									hPlayer.AddCustomAttribute("building max level", 3, 0.2)
									EntFireByHandle(self, "RunScriptCode", "activator.AddCustomAttribute(`building max level`, 3, 0.2)", -1, hPlayer, null)
									SetPropInt(self, "m_iHighestUpgradeLevel", 3)
									SetPropInt(self, "m_iUpgradeLevel", 2)
									SetPropFloat(self, "m_flPercentageConstructed", 1)
								}

								bPlacingLast = bPlacing
								return -1
							}
							AddThinkToEnt(hBuilding, "Think")
						}
					}
					hBuilding.SetHealth(hBuilding.GetMaxHealth())
				}
		}
	}

	function GrapplingHook()
	{
		local hPlayer = self
		local hGrapple
		for(local i = 0; i < 8; i++)
		{
			local hWeapon = GetPropEntityArray(hPlayer, "m_hMyWeapons", i)
			if(hWeapon && hWeapon.GetClassname() == "tf_weapon_grapplinghook")
				{ hGrapple = hWeapon; break }
		}
		if(!hGrapple) return

		local hGameText = SpawnEntityFromTable("game_text", {
			channel = 0
			color = "0 255 0"
			holdtime = 1
			x = 0.8
			y = 0.8
			message = "Grappling Hook\n▰▰▰▰▰▰▰▰▰▰▰▰▰▰ READY"
		})

		SetPropBool(hGrapple, "m_bForcePurgeFixedupStrings", true)
		hGrapple.ValidateScriptScope()
		local hGrapple_scope = hGrapple.GetScriptScope()
		if("Cleanup" in hGrapple_scope) hGrapple_scope.Cleanup()
		hGrapple_scope.hWeaponLast            <- null
		hGrapple_scope.hWeaponLastFrame       <- null
		hGrapple_scope.hProjectileLast        <- null
		hGrapple_scope.flRechargeTime         <- 0
		hGrapple_scope.flRechargeTimeDuration <- 0
		hGrapple_scope.bActionSlotLast        <- false
		hGrapple_scope.Think <- function()
		{
			local hWeapon = hPlayer.GetActiveWeapon()
			local bActionSlot = hPlayer.IsUsingActionSlot()
			if(flRechargeTime == 0)
			{
				if(bActionSlot && !bActionSlotLast)
					hPlayer.Weapon_Switch(self)
				else if(!bActionSlot && bActionSlotLast)
					hPlayer.Weapon_Switch(hWeaponLast)
			}
			bActionSlotLast = bActionSlot

			if(flRechargeTime != 0 && hWeapon == self)
				hPlayer.Weapon_Switch(hWeaponLast)

			if(hWeaponLastFrame != hWeapon)
			{
				hWeaponLast = hWeaponLastFrame
				hWeaponLastFrame = hWeapon
			}

			local flTime = Time()
			local hProjectile = GetPropEntity(self, "m_hProjectile")
			if(flRechargeTime == 0 && hProjectileLast && !hProjectile)
			{
				flRechargeTime = flTime + 30
				flRechargeTimeDuration = flRechargeTime - flTime
				hGameText.KeyValueFromString("color", "255 0 0")

				EmitSoundOnClient("Weapon_Sapper.Removed", hPlayer)
				hPlayer.Weapon_Switch(hWeaponLast)
			}
			hProjectileLast = hProjectile

			if(flRechargeTimeDuration > 0)
			{
				local iMessageMaxLength = 14
				local sMessage = "Grappling Hook\n"
				if(flTime >= flRechargeTime)
				{
					flRechargeTime = 0
					flRechargeTimeDuration = 0
					hGameText.KeyValueFromString("color", "0 255 0")
					hPlayer.AcceptInput("$PlaySoundToSelf", "TFPlayer.ReCharged", null, null)

					for(local i = 1; i <= iMessageMaxLength; i++)
						sMessage += "▰"
					sMessage += " READY"
				}
				else
				{
					local flTimeRemaining        = flRechargeTime - flTime
					local flTimeRemainingPercent = 1 - flTimeRemaining / flRechargeTimeDuration
					local flMessagePercent       = 1.0 / iMessageMaxLength
					local iRechargeMeter         = (flTimeRemainingPercent / flMessagePercent).tointeger()

					for(local i = 1; i <= iRechargeMeter; i++)
						sMessage += "▰", iMessageMaxLength--
					for(local i = 1; i <= iMessageMaxLength; i++)
						sMessage += "▱"

					sMessage += format(" %i", ceil(flTimeRemaining))
				}
				SetPropString(hGameText, "m_iszMessage", sMessage)
			}
			hGameText.AcceptInput("Display", null, hPlayer, null)
			return -1
		}
		AddThinkToEnt(hGrapple, "Think")
		hGrapple_scope.Cleanup <- function()
		{
			if(hGameText && hGameText.IsValid())
				hGameText.Kill()
		}
		Trespasser.SetDestroyCallback(hGrapple, hGrapple_scope.Cleanup)
	}

	function SpellbookHud()
	{
		local hPlayer = self
		local hSpellbook
		for(local i = 0; i < 8; i++)
		{
			local hWeapon = GetPropEntityArray(hPlayer, "m_hMyWeapons", i)
			if(hWeapon && hWeapon.GetSlot() == 5)
				{ hSpellbook = hWeapon; break }
		}
		if(!hSpellbook || hSpellbook.GetScriptThinkFunc() != "") return

		hSpellbook.ValidateScriptScope()
		local hSpellbook_scope = hSpellbook.GetScriptScope()
		hSpellbook_scope.bTickSound      <- true
		hSpellbook_scope.iSpellIndexLast <- -1
		hSpellbook_scope.flNextTickSound <- -1
		hSpellbook_scope.flTickGap       <- 0.01
		hSpellbook_scope.Think <- function()
		{
			local flTime = Time()
			local iSpellIndex = GetPropInt(hSpellbook, "m_iSelectedSpellIndex")
			if(iSpellIndex != iSpellIndexLast)
			{
				if(iSpellIndex == -2)
				{
					flTickGap = 0.01
					flNextTickSound = flTime + flTickGap
				}
				else if(iSpellIndexLast == -2 && iSpellIndex >= 0)
				{
					EmitSoundOnClient("Halloween.spelltick_set", hPlayer)
					local sString = "\x01Acquired Spell: "
					switch(iSpellIndex)
					{
						case 0: sString += "\x0738F3ABFireball (2)"; break
						case 1: sString += "\x0738F3ABSwarm of Bats (2)"; break
						case 2: sString += "\x0738F3ABOverheal (1)"; break
						case 3: sString += "\x0738F3ABPumpkin MIRV (1)"; break
						case 4: sString += "\x0738F3ABBlast Jump (2)"; break
						case 5: sString += "\x0738F3ABStealth (1)"; break
						case 6: sString += "\x0738F3ABShadow Leap (2)"; break
						case 7: sString += "\x078650ACBall o' Lightning (1)"; break
						case 8: sString += "\x078650ACMinify (1)"; break
						case 9: sString += "\x078650ACMeteor Shower (1)"; break
					}
					ClientPrint(hPlayer, HUD_PRINTTALK, sString)
				}
			}
			if(iSpellIndex == -2 && flTime >= flNextTickSound)
			{
				flTickGap += 0.025
				flNextTickSound = flTime + flTickGap
				EmitSoundOnClient(bTickSound ? "Halloween.spelltick_a" : "Halloween.spelltick_b", hPlayer)
				bTickSound = !bTickSound
			}
			iSpellIndexLast = iSpellIndex
			return -1
		}
		AddThinkToEnt(hSpellbook, "Think")
	}

	function OnGameEvent_player_say(params)
	{
		local sText = params.text.tolower()
		if(sText == "!wins")
		{
			local hPlayer    = GetPlayerFromUserID(params.userid)
			local sName      = GetPropString(hPlayer, "m_szNetname")
			local sNetworkID = GetPropString(hPlayer, "m_szNetworkIDString")
			local sExtra     = " "
			local iWins      = 0
			local iWinFlags  = 0
			if(sNetworkID in Wins)
			{
				iWins = Wins[sNetworkID][0]
				iWinFlags = (Wins[sNetworkID][1] ? 1 : 0) | (Wins[sNetworkID][2] ? 2 : 0)
				sExtra += Wins[sNetworkID][2] ? "\x07FFD700★" : "   "
				sExtra += Wins[sNetworkID][1] ? "\x07FFD700★" : "   "
				sExtra += Wins[sNetworkID][0] >= 50 ? "\x07FFD700★" : "   "
			}
			ClientPrint(hPlayer, HUD_PRINTTALK, format("\x07f19e53All Survivors Win \x01: %sGrappling Hook \x01(All-Class)", iWinFlags & 2 ?  "\x079EC34F" : "\x07C34F4F"))
			ClientPrint(hPlayer, HUD_PRINTTALK, format("\x07f19e53Solo Win \x01: %sDeathly Canteen \x01(All-Class)",         iWinFlags & 1 ?  "\x079EC34F" : "\x07C34F4F"))
			ClientPrint(hPlayer, HUD_PRINTTALK, format("\x07f19e531 Win \x01: %sHeavy Machine Gun \x01(Sniper)",             iWins >= 1 ?     "\x079EC34F" : "\x07C34F4F"))
			ClientPrint(hPlayer, HUD_PRINTTALK, format("\x07f19e532 Wins \x01: %sIncendiary Rifle \x01(Pyro)",               iWins >= 2 ?     "\x079EC34F" : "\x07C34F4F"))
			ClientPrint(hPlayer, HUD_PRINTTALK, format("\x07f19e533 Wins \x01: %sSlug Rifle \x01(Soldier)",                  iWins >= 3 ?     "\x079EC34F" : "\x07C34F4F"))
			ClientPrint(hPlayer, HUD_PRINTTALK, format("\x07f19e534 Wins \x01: %sDustbowl Eagle \x01(Engineer)",             iWins >= 4 ?     "\x079EC34F" : "\x07C34F4F"))
			ClientPrint(hPlayer, HUD_PRINTTALK, format("\x07f19e535 Wins \x01: %sChainsaw \x01(Heavy)",                      iWins >= 5 ?     "\x079EC34F" : "\x07C34F4F"))
			ClientPrint(hPlayer, HUD_PRINTTALK, format("\x07f19e5310 Wins \x01: %sCeremonial Bow \x01(Sniper)",              iWins >= 10 ?    "\x079EC34F" : "\x07C34F4F"))
			ClientPrint(null, HUD_PRINTTALK, format("\x07FF3F3F%s\x01's Win Count: \x07f19e53%i%s", sName, iWins, sExtra))
		}
	}

	function OnGameEvent_pumpkin_lord_summoned(_)
	{
		local hHHH = FindByClassname(null, "headless_hatman")
		if(hHHH) BossGlow(hHHH)
	}

	function OnGameEvent_eyeball_boss_summoned(_)
	{
		local hMonoculus = FindByClassname(null, "eyeball_boss")
		if(hMonoculus)
		{
			hMonoculus.SetSolid(FSOLID_NOT_SOLID)
			EntFireByHandle(hMonoculus, "RunScriptCode", "self.SetSolid(SOLID_BBOX)", 1, null, null)
			BossGlow(hMonoculus)
		}
	}

	function OnGameEvent_eyeball_boss_killed(_)
	{
		EntFire("@f@filter_red_alive@player", "$RemovePlayerAttribute", "melee airblast")
		EntFire("teleport_vortex", "Kill") // no bombinomicon book teleport
	}

	function BossGlow(hBoss)
	{
		local hGlow = SpawnEntityFromTable("tf_glow", {
			GlowColor = "200 75 255 220"
			target    = "bignet"
		})
		SetPropEntity(hGlow, "m_hTarget", hBoss)
		SetPropEntity(hGlow, "m_hMovePeer", hBoss.FirstMoveChild())
		SetPropEntity(hBoss, "m_hMoveChild", hGlow)
		SetPropEntity(hGlow, "m_hMoveParent", hBoss)
		SetAlwaysTransmit(hBoss)
	}

	function GiveTempWeapon()
	{
		local hPlayer = self
		local hPrimary
		for(local i = 0; i < 8; i++)
		{
			local hWeapon = GetPropEntityArray(hPlayer, "m_hMyWeapons", i)
			if(hWeapon && hWeapon.GetSlot() == 0)
				{ hPrimary = hWeapon; break }
		}
		if(!hPrimary)
		{
			local vecOrigin = hPlayer.GetOrigin()
			hPlayer.SetAbsOrigin(Vector(0, 0, 9999)) // so standing in a dispenser doesnt prevent having a dummy primary
			hPlayer.AcceptInput("$GiveItem", "deflector", null, null)
			hPlayer.SetAbsOrigin(vecOrigin)
		}
	}

	function SummonCoffin(hTarget, hPlayer)
	{
		EmitSoundEx({
			sound_name  = "misc/null.wav"
			entity      = hPlayer
			filter_type = RECIPIENT_FILTER_GLOBAL
			flags       = SND_STOP | SND_IGNORE_NAME
		})

		for(local hRagdoll; hRagdoll = FindByClassname(hRagdoll, "tf_ragdoll");)
			if(GetPropEntity(hRagdoll, "m_hPlayer") == hPlayer)
				{ hRagdoll.Kill(); break }

		local vecOrigin   = hPlayer.GetOrigin()
		local angRotation = hPlayer.GetAbsAngles()
		local hDeathProp  = SpawnEntityFromTable("prop_dynamic", {
			origin           = vecOrigin + angRotation.Forward() * 20
			angles           = angRotation + QAngle(-15, 0, 0)
			model            = "models/player/soldier.mdl"
			defaultanim      = "primary_death_headshot"
			OnAnimationBegun = "!self,Kill,,1.5,-1"
			renderamt        = 0
			rendermode       = 1
		})

		SetPropInt(hDeathProp, "m_nBody", GetPropInt(hPlayer, "m_nBody"))
		hDeathProp.SetPlaybackRate(0.8)

		SpawnEntityFromTable("prop_dynamic_ornament", {
			origin = vecOrigin
			model  = hPlayer.GetModelName()
		}).AcceptInput("SetAttached", "!activator", hDeathProp, null)
		for(local hChild = hPlayer.FirstMoveChild(); hChild; hChild = hChild.NextMovePeer())
			if(hChild.GetClassname() == "tf_wearable")
				SpawnEntityFromTable("prop_dynamic_ornament", {
					origin = vecOrigin
					model  = hChild.GetModelName()
				}).AcceptInput("SetAttached", "!activator", hDeathProp, null)

		local hCoffin = SpawnEntityFromTable("prop_dynamic", {
			origin = vecOrigin
			angles = angRotation
			model  = "models/workshop/player/items/spy/taunt_the_crypt_creeper/taunt_the_crypt_creeper.mdl"
		})
		hDeathProp.AcceptInput("SetParent", "!activator", hCoffin, null)
		hTarget.AcceptInput("SetParent", "!activator", hCoffin, null)
		hTarget.SetLocalOrigin(Vector(0, 0, 4))
		hCoffin.SetMoveType(MOVETYPE_FLYGRAVITY, MOVECOLLIDE_FLY_BOUNCE)
		hCoffin.AcceptInput("SetAnimation", "taunt_the_crypt_creeper_intro", null, null)
		EntFireByHandle(hCoffin, "SetPlaybackRate", "0", 3, null, null)
		EntFireByHandle(hCoffin, "Skin", "1", 3, null, null)
		EntFireByHandle(hCoffin, "SetAnimation", "taunt_the_crypt_creeper_A1", 6, null, null)
		EntFireByHandle(hCoffin, "SetAnimation", "taunt_the_crypt_creeper_outro", 7.9, null, null)
		EntFireByHandle(hCoffin, "Kill", null, 9.75, null, null)

		UnstuckEntityIgnorePlayers(hCoffin, Vector(-55, -55, 0), Vector(55, 55, 24))

		// sounds
		EntFireByHandle(hCoffin, "$PlaySound", "Wood_Furniture.Break", -1, null, null)
		EntFireByHandle(hCoffin, "$PlaySound", "Wood.ImpactHard", 1, null, null)
		EntFireByHandle(hCoffin, "$PlaySound", "Wood.ImpactHard", 1.5, null, null)
		EntFireByHandle(hCoffin, "$PlaySound", "Wood.ImpactHard", 1.8, null, null)
		EntFireByHandle(hCoffin, "$PlaySound", "Wood.ImpactHard", 6, null, null)
		EntFireByHandle(hCoffin, "$PlaySound", "Wood.ImpactHard", 6.8, null, null)
		EntFireByHandle(hCoffin, "$PlaySound", "Wood_Furniture.Break", 7.8, null, null)
	}

	function BotDisplace(hPlayer)
	{
		local hTouch = SpawnEntityFromTable("trigger_multiple", {
			spawnflags   = 1
			OnStartTouch = "!self,RunScriptCode,Trigger(),-1,-1"
		})
		hTouch.SetSolid(SOLID_BBOX)
		hTouch.ValidateScriptScope()
		local hTouch_scope = hTouch.GetScriptScope()
		hTouch_scope.flTimeNext <- 0
		hTouch_scope.Think <- function()
		{
			self.SetAbsOrigin(hPlayer.GetOrigin())
			self.SetSize(hPlayer.GetPlayerMins() * 1.05, hPlayer.GetPlayerMaxs() * 1.05)
			local flTime = Time()
			self.AcceptInput("Disable", null, null, null)
			EntFireByHandle(self, "Enable", null, -1, null, null)
			if(!hPlayer || !hPlayer.IsValid() || !hPlayer.IsAlive()) self.Kill()
			return -1
		}
		hTouch_scope.Trigger <- function()
		{
			local hActivator = activator
			if(hActivator.GetTeam() != hPlayer.GetTeam())
			{
				local vecDir = hActivator.GetOrigin() - hPlayer.GetOrigin()
				vecDir.Norm()
				hActivator.ApplyAbsVelocityImpulse(vecDir * 300)
			}
		}
		AddThinkToEnt(hTouch, "Think")
	}

	function SpawnCustomSpell(vecOrigin)
	{
		local hPickup = SpawnEntityFromTable("tf_halloween_pickup", {
			powerup_model = "models/props_medieval/medieval_scroll.mdl"
			teamnum       = 5
		})
		hPickup.SetMoveType(MOVETYPE_FLYGRAVITY, MOVECOLLIDE_FLY_BOUNCE)
		hPickup.SetAbsOrigin(vecOrigin)
		hPickup.SetAbsVelocity(QAngle(-70, RandomFloat(0, 360), 0).Forward() * 300)
		hPickup.EmitSound("Halloween.PumpkinDrop")
		hPickup.ValidateScriptScope()
		local hPickup_scope = hPickup.GetScriptScope()
		hPickup_scope.Think <- function()
		{
			local vecOrigin = self.GetOrigin()
			local vecMins = self.GetBoundingMins()
			local vecMaxs = self.GetBoundingMaxs()
			for(local i = 1; i <= MAX_CLIENTS; i++)
			{
				local hPlayer = PlayerInstanceFromIndex(i)
				if(!hPlayer) continue

				if(Trespasser.IsAliveExtra(hPlayer) && hPlayer.GetTeam() == TF_TEAM_RED && Trespasser.IntersectionBoxBox(vecOrigin, vecMins, vecMaxs, hPlayer.GetOrigin(), hPlayer.GetPlayerMins(), hPlayer.GetPlayerMaxs()))
				{
					local hSpellbook
					for(local hEnt = hPlayer.FirstMoveChild(); hEnt; hEnt = hEnt.NextMovePeer())
						if(hEnt.GetClassname() == "tf_weapon_spellbook")
							{ hSpellbook = hEnt; break }

					if(hSpellbook)
					{
						if(GetPropInt(hSpellbook, "m_iSpellCharges") == 0 && GetPropInt(hSpellbook, "m_iSelectedSpellIndex") != -2)
						{
							EntFireByHandle(hPlayer, "$RollCommonSpell", null, -1, null, null)
							hPickup.EmitSound("Halloween.spell_pickup")
							hPickup.Kill()
							return
						}
					}
					else ClientPrint(hPlayer, HUD_PRINTCENTER, "#TF_SpellBook_Equip")
				}
			}
			return -1
		}
		AddThinkToEnt(hPickup, "Think")
	}

	function SpawnCrumpkin(vecOrigin)
	{
		local hPickup = SpawnEntityFromTable("tf_halloween_pickup", {
			powerup_model = "models/props_halloween/pumpkin_loot.mdl"
			teamnum       = 5
		})
		hPickup.SetMoveType(MOVETYPE_FLYGRAVITY, MOVECOLLIDE_FLY_BOUNCE)
		hPickup.SetAbsOrigin(vecOrigin)
		hPickup.SetAbsVelocity(QAngle(-70, RandomFloat(0, 360), 0).Forward() * 300)
		hPickup.EmitSound("Halloween.PumpkinDrop")
		hPickup.ValidateScriptScope()
		local hPickup_scope = hPickup.GetScriptScope()
		hPickup_scope.Think <- function()
		{
			local vecOrigin = self.GetOrigin()
			local vecMins = self.GetBoundingMins()
			local vecMaxs = self.GetBoundingMaxs()
			for(local i = 1; i <= MAX_CLIENTS; i++)
			{
				local hPlayer = PlayerInstanceFromIndex(i)
				if(!hPlayer) continue

				if(Trespasser.IsAliveExtra(hPlayer) && hPlayer.GetTeam() == TF_TEAM_RED && hPlayer.GetTeam() == TF_TEAM_RED && Trespasser.IntersectionBoxBox(vecOrigin, vecMins, vecMaxs, hPlayer.GetOrigin(), hPlayer.GetPlayerMins(), hPlayer.GetPlayerMaxs()))
				{
					hPlayer.AddCondEx(TF_COND_CRITBOOSTED_PUMPKIN, 3, null)
					hPickup.EmitSound("Halloween.PumpkinPickup")
					hPickup.Kill()
					return
				}
			}
			return -1
		}
		AddThinkToEnt(hPickup, "Think")
		EntFireByHandle(hPickup, "Kill", null, 30, null, null)
	}

	function SetAlwaysTransmit(hEnt)
	{
		local hEdict = SpawnEntityFromTable("info_target", {targetname = "target_alwaystransmit"})
		hEdict.AddEFlags(EFL_IN_SKYBOX | EFL_FORCE_CHECK_TRANSMIT)
		hEdict.AcceptInput("SetParent", "!activator", hEnt, null)
		hEdict.SetLocalOrigin(Vector())
		return hEdict
	}

	function GetPlayerClassLimits()
	{
		local PlayerClassLimits = {
			[TF_CLASS_UNDEFINED]    = [0, "Undefined"],
			[TF_CLASS_SCOUT]        = [2, "Scout"],
			[TF_CLASS_SOLDIER]      = [2, "Soldier"],
			[TF_CLASS_PYRO]         = [2, "Pyro"],
			[TF_CLASS_DEMOMAN]      = [2, "Demoman"],
			[TF_CLASS_HEAVYWEAPONS] = [2, "Heavy"],
			[TF_CLASS_ENGINEER]     = [2, "Engineer"],
			[TF_CLASS_MEDIC]        = [2, "Medic"],
			[TF_CLASS_SNIPER]       = [2, "Sniper"],
			[TF_CLASS_SPY]          = [2, "Spy"],
			[TF_CLASS_CIVILIAN]     = [1, "Merasmus"]
		}
		for(local i = 1; i <= MAX_CLIENTS; i++)
		{
			local hPlayer = PlayerInstanceFromIndex(i)
			if(hPlayer && !hPlayer.IsBotOfType(TF_BOT_TYPE))
				PlayerClassLimits[hPlayer.GetPlayerClass()][0]--
		}
		return PlayerClassLimits
	}

	function SetDesiredClass(hPlayer, iPlayerClass)
	{
		local PlayerClassLimits = GetPlayerClassLimits()
		if(PlayerClassLimits[iPlayerClass][0] > 0)
		{
			SetPropInt(hPlayer, "m_Shared.m_iDesiredPlayerClass", iPlayerClass)
			ClientPrint(hPlayer, HUD_PRINTTALK, format("*You will spawn as %s", PlayerClassLimits[iPlayerClass][1]))
			EmitSoundOnClient("Vote.Cast.Yes", hPlayer)
		}
		else
		{
			ClientPrint(hPlayer, HUD_PRINTCENTER, format("Exceeded the %s class limit in this mission", PlayerClassLimits[iPlayerClass][1]))
			EmitSoundOnClient("Vote.Cast.No", hPlayer)
			caller.AcceptInput("$DisplayMenu", "!activator", hPlayer, null)
		}
	}

	// warn about using merasmus
	function OnGameEvent_player_changeclass(params)
	{
		local hPlayer = GetPlayerFromUserID(params.userid)
		if(!hPlayer.IsBotOfType(TF_BOT_TYPE))
		{
			if(params["class"] == TF_CLASS_CIVILIAN && TrespasserSeenMerasmusWarning.find(hPlayer) == null)
			{
				TrespasserSeenMerasmusWarning.append(hPlayer)
				if(!bInWave)
				{
					PrecacheSound("vo/halloween_merasmus/sf14_merasmus_necromasher_08.mp3")
					EmitSoundEx({
						sound_name = "vo/halloween_merasmus/sf14_merasmus_necromasher_08.mp3"
						entity = hPlayer
						filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
					})
					local PlayerClassLimits = GetPlayerClassLimits()
					local PossibleClasses = []
					foreach(iClass, Array in PlayerClassLimits)
						if(Array[0] >= 0)
							PossibleClasses.append(iClass)
					SetPropInt(hPlayer, "m_Shared.m_iDesiredPlayerClass", PossibleClasses[RandomInt(0, PossibleClasses.len() - 1)])
					hPlayer.DispatchSpawn()
				}
				local sArg = "ClientPrint(activator, HUD_PRINTCENTER, `READ TO AVOID CRASHES BEFORE PLAYING AS MERASMUS\\n\\nUse cl_hud_playerclass_use_playermodel 0 (Player Model in Player Class HUD)\\nto not crash when viewing the UPGRADE PANEL or SCOREBOARD\\n\\nDO NOT use your CHARACTER LOADOUT KEY as it will always crash!`)"
				EntFire("bignet", "RunScriptCode", sArg, -1, hPlayer)
				EntFire("bignet", "RunScriptCode", sArg, 5, hPlayer)
				EntFire("bignet", "RunScriptCode", sArg, 10, hPlayer)
				EntFire("bignet", "RunScriptCode", sArg, 15, hPlayer)
				EntFire("bignet", "RunScriptCode", sArg, 20, hPlayer)
				EntFire("bignet", "RunScriptCode", sArg, 25, hPlayer)
			}
			else if(!(hPlayer in ActivePlayers) && !IsAliveExtra(hPlayer))
				EntFire("bignet", "RunScriptCode", "activator.ForceRespawn()", -1, hPlayer)
		}
		// TrespasserSeenMerasmusWarning.clear() // debug
	}

	function RemoveCondReprogrammed(hPlayer)
	{
		if(!hPlayer || !hPlayer.IsValid()) return
		SetPropBool(hPlayer, "m_bIsCoaching", true)
		hPlayer.RemoveCond(TF_COND_REPROGRAMMED)
		SetPropBool(hPlayer, "m_bIsCoaching", false)
	}

	function DisableSentries(bool)
	{
		if(!bool) for(local hSentry; hSentry = FindByClassname(hSentry, "obj_sentrygun");) if(GetPropInt(hSentry, "m_iHighestUpgradeLevel") == 3) hSentry.DispatchSpawn()
		bDisableSentries = bool
	}

	function BomberRocket()
	{
		local hPlayer = self
		EntFireByHandle(hPlayer, "$TauntFromItem", "Taunt: Rocket Jockey", 0.25, null, null)
		local hWeapon = hPlayer.GetActiveWeapon()
		hWeapon.ValidateScriptScope()
		local hWeapon_scope = hWeapon.GetScriptScope()
		hWeapon_scope.vecFakeForward <- hPlayer.GetForwardVector()
		hWeapon_scope.vecOriginLast  <- hPlayer.GetOrigin()
		hWeapon_scope.iNoMovement    <- 0
		hWeapon_scope.Think <- function()
		{
			if(hPlayer.InCond(TF_COND_TAUNTING))
			{
				local vecTarget = hPlayer.GetAbsVelocity()
				vecTarget.Norm()
				vecFakeForward = vecFakeForward + (vecTarget - vecFakeForward) * 0.1
				hPlayer.SnapEyeAngles(TankExt.VectorToQAngle(vecFakeForward))
				if(endswith(hPlayer.GetSequenceName(hPlayer.GetSequence()), "deploybomb")) hPlayer.RemoveCond(TF_COND_TAUNTING)

				local vecOrigin = hPlayer.GetOrigin()
				if((vecOrigin - vecOriginLast).Length() < 1) iNoMovement++
				else iNoMovement = 0
				vecOriginLast = vecOrigin
				if(iNoMovement >= 133)
				{
					local vecMins = hPlayer.GetPlayerMins()
					local vecMaxs = hPlayer.GetPlayerMaxs()
					vecMins.x *= 1.3
					vecMins.y *= 1.3
					vecMaxs.x *= 1.3
					vecMaxs.y *= 1.3
					Trespasser.UnstuckEntityIgnorePlayers(hPlayer, vecMins, vecMaxs)
				}
			}
			return -1
		}
		AddThinkToEnt(hWeapon, "Think")
	}

	function ChangeAttributesSafe(hPlayer, sAttribute)
	{
		if(!hPlayer.IsBotOfType(TF_BOT_TYPE)) return
		local vecOrigin = hPlayer.GetOrigin()
		hPlayer.SetAbsOrigin(Vector(0, 0, 9999))
		hPlayer.AcceptInput("$ChangeAttributes", sAttribute, null, null)
		hPlayer.SetAbsOrigin(vecOrigin)
	}

	function StopAllMusic(bStopBeats = false)
	{
		for(local hSound; hSound = FindByClassname(hSound, "ambient_generic");)
		{
			local sName = hSound.GetName()
			local Beats = {
				"beat_mvm"        : null
				"beat_saw"        : null
				"beat_helicopter" : null
				"beat_sewers_1"   : null
				"beat_sewers_2"   : null
			}
			if(startswith(sName, "music_") || (bStopBeats ? sName in Beats : false))
				EmitSoundEx({
					sound_name  = "misc/null.wav"
					entity      = hSound
					filter_type = RECIPIENT_FILTER_GLOBAL
					flags       = SND_STOP | SND_IGNORE_NAME
				})
		}
	}

	function Decoy()
	{
		local hPlayer = self
		local hSapper
		for(local i = 0; i < 8; i++)
		{
			local hWeapon = GetPropEntityArray(hPlayer, "m_hMyWeapons", i)
			if(hWeapon && hWeapon.GetSlot() == 1)
				{ hSapper = hWeapon; break }
		}
		if(!hSapper) return
		hSapper.ValidateScriptScope()
		local hSapper_scope = hSapper.GetScriptScope()
		if("Cleanup" in hSapper_scope) hSapper_scope.Cleanup()

		local RechargeTime = 15
		hSapper.AddAttribute("effect bar recharge rate increased", RechargeTime / 15.0, -1)

		hSapper_scope.hProjectile  <- null
		hSapper_scope.iButtonsLast <- 0
		hSapper_scope.bReady       <- true
		hSapper_scope.Think <- function()
		{
			local iButtons         = GetPropInt(hPlayer, "m_nButtons")
			local iButtonsChanged  = iButtonsLast ^ iButtons
			local iButtonsPressed  = iButtonsChanged & iButtons
			local iButtonsReleased = iButtonsChanged & (~iButtons)
			iButtonsLast = iButtons

			local hWeapon = hPlayer.GetActiveWeapon()

			local flTime = Time()
			if(hWeapon == self && iButtonsPressed & IN_ATTACK && GetPropIntArray(hPlayer, "m_iAmmo", TF_AMMO_GRENADES2) > 0)
			{
				SetPropIntArray(hPlayer, "m_iAmmo", 0, TF_AMMO_GRENADES2)
				SetPropFloat(self, "m_flEffectBarRegenTime", flTime + RechargeTime)
				bReady = false

				if(hProjectile && hProjectile.IsValid())
					hProjectile.Kill()

				PrecacheScriptSound("spy_taunt_flip_random_flipExert")
				EmitSoundOn("spy_taunt_flip_random_flipExert", hPlayer)

				local angEyes = hPlayer.EyeAngles()
				hProjectile = SpawnEntityFromTable("obj_dispenser", {
					origin = hPlayer.EyePosition()
					angles = QAngle(0, angEyes.y, 0)
					teamnum = 2
					"$maxlevel" : 1
					"$cannotbesapped" : 1
				})

				local Kill = []
				for(local hChild = hProjectile.FirstMoveChild(); hChild; hChild = hChild.NextMovePeer())
					Kill.append(hChild)
				foreach(hEnt in Kill)
					hEnt.Kill()
				FindByClassnameNearest("dispenser_touch_trigger", hProjectile.GetOrigin(), 1).Kill()

				SetPropIntArray(hProjectile, "m_nModelIndexOverrides", PrecacheModel("models/props_2fort/miningcrate001.mdl"), 0)
				hProjectile.SetSize(Vector(-16, -16, 0), Vector(16, 16, 23))
				hProjectile.KeyValueFromString("rendercolor", "250 230 200")
				hProjectile.KeyValueFromFloat("modelscale", 0.6)

				SetPropEntity(hProjectile, "m_hBuilder", hPlayer)
				hProjectile.AcceptInput("Disable", null, null, null)
				hProjectile.SetOwner(hPlayer)
				hProjectile.SetMoveType(MOVETYPE_FLYGRAVITY, MOVECOLLIDE_FLY_BOUNCE)
				hProjectile.SetSolid(SOLID_NONE)
				hProjectile.SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
				hProjectile.SetAbsVelocity((angEyes + QAngle(-15)).Forward() * 512)
				SetPropInt(hProjectile, "m_takedamage", DAMAGE_NO)
				EntityOutputs.AddOutput(hProjectile, "OnObjectHealthChanged", "!self", "$PlaySound", "Wood.ImpactHard", -1, -1)
				hProjectile.AcceptInput("SetHealth", "350", null, null)

				local iSapperPower = self.GetAttribute("robo sapper", 0)

				hProjectile.ValidateScriptScope()
				local hProjectile_scope = hProjectile.GetScriptScope()
				hProjectile_scope.flTimeUnbox <- flTime + 2
				hProjectile_scope.flTimeBreak <- flTime + 8 + 1 * iSapperPower
				hProjectile_scope.flTimeSlow  <- 0
				hProjectile_scope.bActive     <- false
				hProjectile_scope.Think <- function()
				{
					if(!self.IsValid()) return
					local flTime = Time()
					local vecOrigin = self.GetOrigin()
					if(flTime >= flTimeUnbox && !bActive)
					{
						bActive = true
						local vecMins = Vector(-8, -8, 0)
						local vecMaxs = Vector(8, 8, 83)
						SetPropIntArray(self, "m_nModelIndexOverrides", PrecacheModel("models/props_training/target_spy.mdl"), 0)
						self.SetSize(vecMins, vecMaxs)
						self.SetModelScale(1, 0)
						self.SetOwner(null)
						self.SetSolid(SOLID_BBOX)
						self.SetCollisionGroup(TFCOLLISION_GROUP_OBJECT)
						SetPropInt(self, "m_takedamage", DAMAGE_YES)
						SetPropInt(self, "m_iObjectType", OBJ_LAST)
						self.AcceptInput("$PlaySound", "Wood.Break", null, null)
						DispatchParticleEffect("target_break_initial_dust", vecOrigin, self.GetForwardVector())

						for(local i = 1; i <= MAX_CLIENTS; i++)
						{
							local hPlayer = PlayerInstanceFromIndex(i)
							if(hPlayer && hPlayer.IsAlive() && Trespasser.IntersectionBoxBox(vecOrigin, vecMins, vecMaxs, hPlayer.GetOrigin(), hPlayer.GetPlayerMins(), hPlayer.GetPlayerMaxs()))
								Trespasser.UnstuckEntityIgnorePlayers(hPlayer)
						}
					}

					if(bActive && flTime >= flTimeSlow)
					{
						flTimeSlow = flTime + 0.5
						SetPropString(self, "m_iName", "decoytarget")
						local flRange = 96 + 22 * iSapperPower
						for(local hPlayer; hPlayer = FindByClassnameWithin(hPlayer, "player", vecOrigin, flRange);)
							if(hPlayer.IsAlive() && hPlayer.IsBotOfType(TF_BOT_TYPE) && hPlayer.GetTeam() != TF_TEAM_RED && !hPlayer.HasBotTag("bot_ignoredecoy"))
								hPlayer.AcceptInput("$BotCommand", "interrupt_action -posent decoytarget -lookposent decoytarget -killlook -alwayslook -duration 0.5", null, null)
					}

					if(flTime >= flTimeBreak) self.Kill()
					return -1
				}
				AddThinkToEnt(hProjectile, "Think")
				Trespasser.SetDestroyCallback(hProjectile, function()
				{
					local vecOrigin = self.GetOrigin()
					self.AcceptInput("$PlaySound", "Breakable.MatWood", null, null)
					DispatchParticleEffect("target_break", vecOrigin, self.GetForwardVector())
					local Kill = []
					for(local hGib; hGib = FindByClassnameWithin(hGib, "tf_ammo_pack", vecOrigin, 4);)
						Kill.append(hGib)
					foreach(hGib in Kill)
						hGib.Kill()
				})
			}

			if(!bReady && flTime >= GetPropFloat(self, "m_flEffectBarRegenTime"))
				hPlayer.AcceptInput("$PlaySoundToSelf", "TFPlayer.ReCharged", null, null), bReady = true

			return -1
		}
		AddThinkToEnt(hSapper, "Think")
		hSapper_scope.Cleanup <- function()
		{
			if(hProjectile && hProjectile.IsValid())
				hProjectile.Kill()
		}
		Trespasser.SetDestroyCallback(hSapper, hSapper_scope.Cleanup)
	}

	// a think ent for per tick checks
	hThinkEnt          = SpawnEntityFromTable("logic_relay", {})
	BruteHealTable     = {}
	PullDownTable      = {}
	SlowedPlayersArray = []
	hITLast            = null
	flTimeCountdown    = -1
	flTimeNext_Slow    = 0
	bBlockerCade       = false
	bBlockerStairs     = false
	bBlockerTable      = true
	bDisableSentries   = false
	bMalletHHH         = false
	bNoSmallSkeletons  = false

	function ThinkEntThink()
	{
		local flTime = Time()

		// countdown
		if(flTimeCountdown > 0)
		{
			// if(Convars.GetInt("host_timescale") == 1) // debug
			// 	SendToServerConsole("host_timescale 60")
			if(flTime >= flTimeCountdown)
			{
				flTimeCountdown = -1, ClientPrint(null, HUD_PRINTCENTER, "")
				ForceRespawnDeadRed()
				bInBreak = false
			}
			else ClientPrint(null, HUD_PRINTCENTER, format("%i", ceil(flTimeCountdown - flTime)))
		}
		// else if(Convars.GetInt("host_timescale") == 60) // debug
		// 	SendToServerConsole("host_timescale 1")

		// player checks
		for(local i = 1; i <= MAX_PLAYERS; i++)
		{
			local hPlayer = PlayerInstanceFromIndex(i)
			if(!hPlayer) continue

			local iTeamNum    = hPlayer.GetTeam()
			local bBot        = hPlayer.IsBotOfType(TF_BOT_TYPE)
			local bFakeClient = hPlayer.IsFakeClient()
			local bAlive      = IsAliveExtra(hPlayer)

			if(iTeamNum == TF_TEAM_RED) // reds
			{
				if(bAlive) // alive
				{
					// dirt slow
					if(!bSoloMode)
					{
						local vecOrigin = hPlayer.GetOrigin()
						local vecMins   = hPlayer.GetPlayerMins()
						local vecMaxs   = hPlayer.GetPlayerMaxs()
						local bStun     = false
						if(!IntersectionBoxBox(vecOrigin, vecMins, vecMaxs, Vector(0, 1092, 288), Vector(-696, -828, -352), Vector(696, 828, 352)))
						{
							local Trace = {
								start   = vecOrigin
								end     = vecOrigin + Vector(0, 0, -128)
								hullmin = vecMins
								hullmax = Vector(vecMaxs.x, vecMaxs.y, vecMins.z)
								mask    = MASK_PLAYERSOLID
								ignore  = hPlayer
							}
							TraceHull(Trace)
							if(Trace.surface_props == 9 && Trace.enthit.entindex() == 0)
							{
								bStun = true
								hPlayer.StunPlayer(1, 0.8, TF_STUN_MOVEMENT, null)
								if(SlowedPlayersArray.find(hPlayer) == null)
									SlowedPlayersArray.append(hPlayer)
							}
						}

						if(!bStun && hPlayer.InCond(TF_COND_STUNNED))
						{
							local Index = SlowedPlayersArray.find(hPlayer)
							if(Index != null)
							{
								SlowedPlayersArray.remove(Index)
								hPlayer.RemoveCond(TF_COND_STUNNED)
							}
						}
					}

					// last man/solo mode red changes
					if(!bBot)
					{
						local iPlayerClass = hPlayer.GetPlayerClass()
						local hWeapon      = hPlayer.GetActiveWeapon()
						local iItemIndex   = hWeapon ? GetPropInt(hWeapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") : -1

						// hellmet considers engineer, medic, and spy "primaries" as secondaries so theyll be ignored
						local bPrimary  = hWeapon && hWeapon.GetSlot() == 0 && iPlayerClass != TF_CLASS_ENGINEER && iPlayerClass != TF_CLASS_MEDIC && iPlayerClass != TF_CLASS_SPY
						local bMiniCrit = iItemIndex == 656 // Holiday Punch

						if(bLastTwo || bAboutToBeLastMan)
						{
							if(!bPrimary)
								hPlayer.AddCondEx(TF_COND_OFFENSEBUFF, 0.2, null)
						}
						else if(bLastMan)
						{
							if(!bPrimary)
								hPlayer.AddCondEx(!bMiniCrit ? TF_COND_CRITBOOSTED_USER_BUFF : TF_COND_OFFENSEBUFF, 0.2, null)
						}
						else if(bSoloMode)
						{
							if(!bPrimary)
								hPlayer.AddCondEx(TF_COND_OFFENSEBUFF, 0.2, null)
							hPlayer.AddCustomAttribute("projectile penetration", 1, 0.2)
							hPlayer.AddCustomAttribute("melee cleave attack", 1, 0.2)
							EntFire("bignet", "RunScriptCode", "activator.AddCustomAttribute(`engy sentry fire rate increased`, 1, 0.2)", -1, hPlayer)
						}

						if((bLastTwo || bLastMan || bSoloMode) && hPlayer.InCond(TF_COND_OFFENSEBUFF))
							hPlayer.AcceptInput("DispatchEffect", "ParticleEffectStop", null, null)
					}
				}
				else // dead
				{
					if((bSoloMode || bAboutToBeSoloMode) && hPlayer != hLastRed)
					{
						hPlayer.ForceChangeTeam(TEAM_SPECTATOR, true)
						ClientPrint(hPlayer, HUD_PRINTCENTER, "Singleplayer Mode in progress...\n              Please wait...")
					}
				}
			}
			else // blues/grays
			{
				if(bLastMan && !(bBot && hPlayer.HasBotTag("bot_nolastmanspeed")))
					hPlayer.AddCondEx(TF_COND_SPEED_BOOST, 0.2, null)
				if(bFakeClient && !bAlive)
					SetPropEntity(hPlayer, "m_hObserverTarget", null)
				if(bSoloMode && hPlayer.GetCustomAttribute("force distribute currency on death", 0) == 0)
					hPlayer.AddCustomAttribute("force distribute currency on death", 1, -1)
			}
		}

		// dont allow players to build through prop_dynamics
		for(local hBuilding; hBuilding = FindByClassname(hBuilding, "obj_*");)
		{
			if(bDisableSentries && hBuilding.GetClassname() == "obj_sentrygun")
				hBuilding.AcceptInput("Disable", null, null, null)
			if(GetPropBool(hBuilding, "m_bPlacing"))
			{
				local hPlayer = GetPropEntity(hBuilding, "m_hBuilder")
				if(!hPlayer) continue
				local vecPlayer = hPlayer.GetCenter()
				local Trace = {
					start  = vecPlayer + QAngle(0, hPlayer.EyeAngles().y, 0).Forward() * 72 + Vector(0, 0, 33)
					end    = vecPlayer
					ignore = hPlayer
					mask   = MASK_PLAYERSOLID
				}
				TraceLineEx(Trace)
				if("enthit" in Trace && Trace.enthit.GetClassname() == "prop_dynamic")
					SetPropFloat(hPlayer.GetActiveWeapon(), "m_flNextPrimaryAttack", Time() + 0.1)
			}
		}

		// (hopefully) fix trapped money
		for(local hCash; hCash = FindByClassname(hCash, "item_currencypack_custom");)
			if(!(hCash.GetEFlags() & EFL_NO_MEGAPHYSCANNON_RAGDOLL) && hCash.GetFlags() & FL_ONGROUND)
			{
				hCash.SetEFlags(EFL_NO_MEGAPHYSCANNON_RAGDOLL) // only do 1 trace
				local vecOrigin = hCash.GetOrigin()
				local Trace = {
					start = vecOrigin
					end   = vecOrigin + Vector(0, 0, 24)
					mask  = MASK_PLAYERSOLID
				}
				TraceLineEx(Trace)
				if("enthit" in Trace && Trace.enthit.GetClassname() == "prop_dynamic")
				{
					local hHurt = SpawnEntityFromTable("trigger_hurt", { origin = hCash.GetOrigin(), damage = 0 })
					hHurt.SetSolid(SOLID_BBOX)
					hHurt.SetSize(Vector(-4, -4, -4), Vector(4, 4, 4))
					EntFireByHandle(hHurt, "Kill", null, 1, null, null)
				}
			}

		// make proxy mines stick to the ground
		for(local hMine; hMine = FindByClassname(hMine, "tf_projectile_pipe");)
		{
			if(GetPropInt(hMine, "m_nModelIndex") == iProxyMineModelIndex)
			{
				local vecOrigin = hMine.GetOrigin()
				local Trace = {
					start  = vecOrigin
					end    = vecOrigin + Vector(0, 0, -8)
					mask   = MASK_SHOT
					ignore = hMine
				}
				TraceLineEx(Trace)
				if("enthit" in Trace && (Trace.enthit.GetClassname() == "worldspawn" || Trace.enthit.GetClassname() == "prop_dynamic"))
				{
					if(hMine.GetSkin() == 1) EntFireByHandle(hMine, "RunScriptCode", "SetPropBool(self, `m_bTouched`, false)", -1, null, null)
					hMine.SetForwardVector(Vector(1))
					hMine.SetPhysVelocity(Vector())
					hMine.SetPhysAngularVelocity(Vector())
				}
				else SetPropBool(hMine, "m_bTouched", true)
			}
		}

		// tf_zombie is yellow now, and tiny tf_zombie is optional
		for(local hSkeleton; hSkeleton = FindByClassname(hSkeleton, "tf_zombie");)
		{
			local iTeamNum = hSkeleton.GetTeam()
			if(iTeamNum != TF_TEAM_RED) hSkeleton.SetSkin(3)
			if(bNoSmallSkeletons && hSkeleton.GetScriptScope() == null)
				SetDestroyCallback(hSkeleton, function()
				{
					local vecOrigin = self.GetOrigin()
					for(local i = 0; i < 3; i++)
					{
						local hSkullProjectile = FindByClassnameNearest("tf_projectile_spellspawnzombie", vecOrigin, 128)
						if(hSkullProjectile)
						{
							hSkullProjectile.SetAbsOrigin(Vector(999999))
							hSkullProjectile.Kill()
						}
					}
				})
		}

		// really need mallet hhh to not crash
		local iScenario = GetPropInt(hGameRules, "m_halloweenScenario")
		if(!bMalletHHH && iScenario == 5)
			bMalletHHH = true
		if(bMalletHHH && !bHHHAttackedThisTick && FindByClassname(null, "headless_hatman") != null)
		{
			local hIT = GetPropEntity(hGameRules, "m_itHandle")
			if(!hIT && iScenario == 5)
				SetPropInt(hGameRules, "m_halloweenScenario", 0)
			else if(hIT && iScenario == 0)
				SetPropInt(hGameRules, "m_halloweenScenario", 5)

			if(iScenario == 5 && hIT != hITLast)
			{
				if(hIT)
				{
					ClientPrint(hIT, HUD_PRINTTALK, "#TF_HALLOWEEN_BOSS_WARN_VICTIM")
					ClientPrint(hIT, HUD_PRINTCENTER, "#TF_HALLOWEEN_BOSS_WARN_VICTIM")
					EmitSoundOnClient("Player.YouAreIT", hIT)
					hIT.EmitSound("Halloween.PlayerScream")
				}

				if(hITLast && hITLast.IsAlive())
				{
					ClientPrint(hITLast, HUD_PRINTTALK, "#TF_HALLOWEEN_BOSS_LOST_AGGRO")
					ClientPrint(hITLast, HUD_PRINTCENTER, "#TF_HALLOWEEN_BOSS_LOST_AGGRO")
					EmitSoundOnClient("Player.TaggedOtherIT", hITLast)
				}
			}
			hITLast = hIT
		}

		// brute heal
		local RemoveFromBruteHealTable = []
		foreach(hBrute, iHealAmount in BruteHealTable)
		{
			if(hBrute && hBrute.IsValid() && hBrute.IsAlive() && iHealAmount > 0)
			{
				if(!hBrute.InCond(TF_COND_RADIUSHEAL)) hBrute.AddCond(TF_COND_RADIUSHEAL)
				local iHealBy    = 1
				local iMaxHealth = hBrute.GetMaxHealth()
				local iHealth    = hBrute.GetHealth()
				if(iHealth < iMaxHealth)
					hBrute.SetHealth(iHealth + iHealBy > iMaxHealth ? iMaxHealth : iHealth + iHealBy)
				BruteHealTable[hBrute] = iHealAmount - iHealBy
			}
			else
			{
				if(iHealAmount <= 0) hBrute.RemoveCond(TF_COND_RADIUSHEAL)
				RemoveFromBruteHealTable.append(hBrute)
			}
		}
		foreach(hBrute in RemoveFromBruteHealTable)
			delete BruteHealTable[hBrute]

		// bring them to hell
		local RemovePlayerFromPullDownTable = []
		foreach(hPlayer, iDist in PullDownTable)
		{
			local bExists = hPlayer && hPlayer.IsValid()
			if(bExists && hPlayer.IsAlive() && iDist > 0)
			{
				local vecOrigin = hPlayer.GetOrigin()
				if(hPlayer.GetMoveType() != MOVETYPE_NONE)
				{
					local Trace = {
						start  = vecOrigin
						end    = vecOrigin + Vector(0, 0, -256)
						mask   = MASK_PLAYERSOLID
						ignore = hPlayer
					}
					TraceLineEx(Trace)
					vecOrigin = Trace.endpos
					hPlayer.SetAbsOrigin(vecOrigin)
					local hParticle = SpawnEntityFromTable("info_particle_system", { origin = vecOrigin, effect_name = "utaunt_portalswirl_purple_cloud", start_active = 1 })
					EntFireByHandle(hParticle, "Kill", null, 0.5, null, null)
					SetPropInt(hPlayer, "m_afButtonDisabled", IN_DUCK)
					DoEntFire("bignet", "RunScriptCode", "SetPropInt(activator, `m_afButtonDisabled`, 0)", 0.5, hPlayer, null)
					SetPropInt(hPlayer, "movetype", MOVETYPE_NONE)
				}
				hPlayer.SetAbsOrigin(vecOrigin + Vector(0, 0, -2))
				PullDownTable[hPlayer] = iDist - 2
			}
			else
			{
				if (bExists)
				{
					if (hPlayer.IsBotOfType(TF_BOT_TYPE))
						hPlayer.ForceChangeTeam(TEAM_SPECTATOR, true)
					else
					{
						player.SetHealth(0)
						player.TakeDamage(1, 0, null)
					}
				}
				RemovePlayerFromPullDownTable.append(hPlayer)
			}
		}
		foreach(hPlayer in RemovePlayerFromPullDownTable)
			delete PullDownTable[hPlayer]

		// slower think just in case of performance issues
		if(flTime >= flTimeNext_Slow)
		{
			flTimeNext_Slow = flTime + 0.25

			local NavAreas = {}
			local hNavArea

			// broken stairs near red spawn
			NavAreas.clear()
			NavMesh.GetNavAreasInRadius(Vector(448, 1264, 192), 20, NavAreas)
			foreach(sName, hNav in NavAreas)
				bBlockerStairs ? hNav.SetAttributeTF(TF_NAV_BLOCKED) : hNav.ClearAttributeTF(TF_NAV_BLOCKED)

			// right side barricade
			hNavArea = NavMesh.GetNavArea(Vector(-687.5, 800, -64), 1)
			bBlockerCade ? hNavArea.SetAttributeTF(TF_NAV_BLOCKED) : hNavArea.ClearAttributeTF(TF_NAV_BLOCKED)

			// table
			NavAreas.clear()
			NavMesh.GetNavAreasInRadius(Vector(0, 550, 256), 128, NavAreas)
			foreach(sName, hNav in NavAreas)
				bBlockerTable ? hNav.SetAttributeTF(TF_NAV_BLOCKED) : hNav.ClearAttributeTF(TF_NAV_BLOCKED)

			for(local hHHH; hHHH = FindByClassnameWithin(hHHH, "headless_hatman", Vector(560, 1264, 192), 128);)
			{
				local Motion = hHHH.GetLocomotionInterface()
				if(Motion.GetVelocity().x >= 300)
					Motion.Reset()
			}
		}
	}
}
__CollectGameEventCallbacks(Trespasser)
Trespasser.hThinkEnt.ValidateScriptScope()
Trespasser.hThinkEnt.GetScriptScope().Think <- function()
{
	Trespasser.ThinkEntThink()
	return -1
}
AddThinkToEnt(Trespasser.hThinkEnt, "Think")

AlternateWaves.IterateIcons(function(iIcon, sNames, sCounts, sFlags)
{
	local sIconName = GetPropStringArray(hObjectiveResource, sNames, iIcon)
	switch(sIconName)
	{
		case "horsemann_lite":
			Trespasser.HalloweenBossIcon = ["horsemann_lite", 1, MVM_CLASS_FLAG_MINIBOSS]
			break
		case "mallet_lite":
			Trespasser.HalloweenBossIcon = ["mallet_lite", 1, MVM_CLASS_FLAG_MINIBOSS]
			break
		case "monoculus_nys":
			Trespasser.HalloweenBossIcon = ["monoculus_nys", 1, MVM_CLASS_FLAG_MINIBOSS]
			break
	}
})
AlternateWaves.bTrackIcons = false
Trespasser.GetPlayerWins()
for(local i = 1; i <= MAX_CLIENTS; i++)
{
	local hPlayer = PlayerInstanceFromIndex(i)
	if(hPlayer && hPlayer.IsAlive())
		SendGlobalGameEvent("player_spawn", {
			userid  = GetPropIntArray(hPlayerManager, "m_iUserID", i)
			team    = hPlayer.GetTeam()
			"class" : hPlayer.GetPlayerClass()
		})
}

// no more reds hitting props intended for blu
local hFilterBlu = FindByName(null, "filter_blu")
for(local hProp; hProp = FindByClassname(hProp, "prop_dynamic");)
	if(GetPropEntity(hProp, "m_hDamageFilter") == null)
		SetPropEntity(hProp, "m_hDamageFilter", hFilterBlu)

// no more lingering noises (besides those played through $playsound or $playsoundtoclient)
for(local hSound; hSound = FindByClassname(hSound, "ambient_generic");)
{
	Trespasser.SetDestroyCallback(hSound, function()
	{
		EmitSoundEx({
			sound_name  = "misc/null.wav"
			entity      = self
			filter_type = RECIPIENT_FILTER_GLOBAL
			flags       = SND_STOP | SND_IGNORE_NAME
		})
	})
}

Convars.SetValue("sig_etc_unintended_class_weapon_display_meters", 0)
Convars.SetValue("tf_ghost_xy_speed", 400)