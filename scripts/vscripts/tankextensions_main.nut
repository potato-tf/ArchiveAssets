::ROOT        <- getroottable()
::CONST       <- getconsttable()
::MAX_CLIENTS <- MaxClients().tointeger()

if(!("ConstantNamingConvention" in ROOT))
	foreach(a, b in Constants)
		foreach(k, v in b)
		{
			CONST[k] <- v != null ? v : 0
			ROOT[k]  <- v != null ? v : 0
		}

foreach(k, v in ::NetProps.getclass())
	if(k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::NetProps[k].bindenv(::NetProps)

foreach(k, v in ::Entities.getclass())
	if(k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::Entities[k].bindenv(::Entities)

foreach(k, v in ::EntityOutputs.getclass())
	if(k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::EntityOutputs[k].bindenv(::EntityOutputs)

local UNOFFICIAL_CONSTANTS = {
	DONT_BLEED         = -1
	BLOOD_COLOR_RED    = 0
	BLOOD_COLOR_YELLOW = 1
	BLOOD_COLOR_GREEN  = 2
	BLOOD_COLOR_MECH   = 3

	CHAN_REPLACE    = -1
	CHAN_AUTO       = 0
	CHAN_WEAPON     = 1
	CHAN_VOICE      = 2
	CHAN_ITEM       = 3
	CHAN_BODY       = 4
	CHAN_STREAM     = 5
	CHAN_STATIC     = 6
	CHAN_VOICE2     = 7
	CHAN_VOICE_BASE = 8
	CHAN_USER_BASE  = 136

	DAMAGE_NO          = 0
	DAMAGE_EVENTS_ONLY = 1
	DAMAGE_YES         = 2
	DAMAGE_AIM         = 3

	FFADE_IN       = 1
	FFADE_OUT      = 2
	FFADE_MODULATE = 4
	FFADE_STAYOUT  = 8
	FFADE_PURGE    = 16

	kBonusEffect_Crit                = 0
	kBonusEffect_MiniCrit            = 1
	kBonusEffect_DoubleDonk          = 2
	kBonusEffect_WaterBalloonSploosh = 3
	kBonusEffect_None                = 4
	kBonusEffect_DragonsFury         = 5
	kBonusEffect_Stomp               = 6
	kBonusEffect_Count               = 7

	LIFE_ALIVE       = 0
	LIFE_DYING       = 1
	LIFE_DEAD        = 2
	LIFE_RESPAWNABLE = 3
	LIFE_DISCARDBODY = 4

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

	DEG2RAD = 0.0174532924
	RAD2DEG = 57.295779513
	FLT_MIN = 1.175494e-38
	FLT_MAX = 3.402823466e+38
	INT_MIN = -2147483648
	INT_MAX = 2147483647

	MP_CONCEPT_FIREWEAPON                   = 0
	MP_CONCEPT_HURT                         = 1
	MP_CONCEPT_PLAYER_EXPRESSION            = 2
	MP_CONCEPT_WINDMINIGUN                  = 3
	MP_CONCEPT_FIREMINIGUN                  = 4
	MP_CONCEPT_PLAYER_MEDIC                 = 5
	MP_CONCEPT_DETONATED_OBJECT             = 6
	MP_CONCEPT_KILLED_PLAYER                = 7
	MP_CONCEPT_KILLED_OBJECT                = 8
	MP_CONCEPT_PLAYER_PAIN                  = 9
	MP_CONCEPT_PLAYER_ATTACKER_PAIN         = 10
	MP_CONCEPT_PLAYER_TAUNT                 = 11
	MP_CONCEPT_PLAYER_HELP                  = 12
	MP_CONCEPT_PLAYER_GO                    = 13
	MP_CONCEPT_PLAYER_MOVEUP                = 14
	MP_CONCEPT_PLAYER_LEFT                  = 15
	MP_CONCEPT_PLAYER_RIGHT                 = 16
	MP_CONCEPT_PLAYER_YES                   = 17
	MP_CONCEPT_PLAYER_NO                    = 18
	MP_CONCEPT_PLAYER_INCOMING              = 19
	MP_CONCEPT_PLAYER_CLOAKEDSPY            = 20
	MP_CONCEPT_PLAYER_SENTRYAHEAD           = 21
	MP_CONCEPT_PLAYER_TELEPORTERHERE        = 22
	MP_CONCEPT_PLAYER_DISPENSERHERE         = 23
	MP_CONCEPT_PLAYER_SENTRYHERE            = 24
	MP_CONCEPT_PLAYER_ACTIVATECHARGE        = 25
	MP_CONCEPT_PLAYER_CHARGEREADY           = 26
	MP_CONCEPT_PLAYER_TAUNTS                = 27
	MP_CONCEPT_PLAYER_BATTLECRY             = 28
	MP_CONCEPT_PLAYER_CHEERS                = 29
	MP_CONCEPT_PLAYER_JEERS                 = 30
	MP_CONCEPT_PLAYER_POSITIVE              = 31
	MP_CONCEPT_PLAYER_NEGATIVE              = 32
	MP_CONCEPT_PLAYER_NICESHOT              = 33
	MP_CONCEPT_PLAYER_GOODJOB               = 34
	MP_CONCEPT_MEDIC_STARTEDHEALING         = 35
	MP_CONCEPT_MEDIC_CHARGEREADY            = 36
	MP_CONCEPT_MEDIC_STOPPEDHEALING         = 37
	MP_CONCEPT_MEDIC_CHARGEDEPLOYED         = 38
	MP_CONCEPT_FLAGPICKUP                   = 39
	MP_CONCEPT_FLAGCAPTURED                 = 40
	MP_CONCEPT_ROUND_START                  = 41
	MP_CONCEPT_SUDDENDEATH_START            = 42
	MP_CONCEPT_ONFIRE                       = 43
	MP_CONCEPT_STALEMATE                    = 44
	MP_CONCEPT_BUILDING_OBJECT              = 45
	MP_CONCEPT_LOST_OBJECT                  = 46
	MP_CONCEPT_SPY_SAPPER                   = 47
	MP_CONCEPT_TELEPORTED                   = 48
	MP_CONCEPT_LOST_CONTROL_POINT           = 49
	MP_CONCEPT_CAPTURED_POINT               = 50
	MP_CONCEPT_CAPTURE_BLOCKED              = 51
	MP_CONCEPT_HEALTARGET_STARTEDHEALING    = 52
	MP_CONCEPT_HEALTARGET_CHARGEREADY       = 53
	MP_CONCEPT_HEALTARGET_STOPPEDHEALING    = 54
	MP_CONCEPT_HEALTARGET_CHARGEDEPLOYED    = 55
	MP_CONCEPT_MINIGUN_FIREWEAPON           = 56
	MP_CONCEPT_DIED                         = 57
	MP_CONCEPT_PLAYER_THANKS                = 58
	MP_CONCEPT_CART_MOVING_FORWARD          = 59
	MP_CONCEPT_CART_MOVING_BACKWARD         = 60
	MP_CONCEPT_CART_STOP                    = 61
	MP_CONCEPT_ATE_FOOD                     = 62
	MP_CONCEPT_DOUBLE_JUMP                  = 63
	MP_CONCEPT_DODGING                      = 64
	MP_CONCEPT_DODGE_SHOT                   = 65
	MP_CONCEPT_GRAB_BALL                    = 66
	MP_CONCEPT_REGEN_BALL                   = 67
	MP_CONCEPT_DEFLECTED                    = 68
	MP_CONCEPT_BALL_MISSED                  = 69
	MP_CONCEPT_STUNNED                      = 70
	MP_CONCEPT_STUNNED_TARGET               = 71
	MP_CONCEPT_TIRED                        = 72
	MP_CONCEPT_BAT_BALL                     = 73
	MP_CONCEPT_ACHIEVEMENT_AWARD            = 74
	MP_CONCEPT_JARATE_HIT                   = 75
	MP_CONCEPT_JARATE_LAUNCH                = 76
	MP_CONCEPT_HIGHFIVE_SUCCESS             = 77
	MP_CONCEPT_HIGHFIVE_SUCCESS_FULL        = 78
	MP_CONCEPT_HIGHFIVE_FAILURE             = 79
	MP_CONCEPT_HIGHFIVE_FAILURE_FULL        = 80
	MP_CONCEPT_PLAYER_TAUNT2                = 81
	MP_CONCEPT_PICKUP_BUILDING              = 82
	MP_CONCEPT_REDEPLOY_BUILDING            = 83
	MP_CONCEPT_CARRYING_BUILDING            = 84
	MP_CONCEPT_DUEL_REQUEST                 = 85
	MP_CONCEPT_DUEL_TARGET_REJECT           = 86
	MP_CONCEPT_DUEL_REJECTED                = 87
	MP_CONCEPT_DUEL_TARGET_ACCEPT           = 88
	MP_CONCEPT_DUEL_ACCEPTED                = 89
	MP_CONCEPT_PLAYER_SHOW_ITEM_TAUNT       = 90
	MP_CONCEPT_TAUNT_REPLAY                 = 91
	MP_CONCEPT_TAUNT_LAUGH                  = 92
	MP_CONCEPT_TAUNT_HEROIC_POSE            = 93
	MP_CONCEPT_PARTNER_TAUNT_READY          = 94
	MP_CONCEPT_HOLDTAUNT                    = 95
	MP_CONCEPT_TAUNT_PYRO_ARMAGEDDON        = 96
	MP_CONCEPT_ROCKET_DESTOYED              = 97
	MP_CONCEPT_MVM_BOMB_DROPPED             = 98
	MP_CONCEPT_MVM_BOMB_CARRIER_UPGRADE1    = 99
	MP_CONCEPT_MVM_BOMB_CARRIER_UPGRADE2    = 100
	MP_CONCEPT_MVM_BOMB_CARRIER_UPGRADE3    = 101
	MP_CONCEPT_MVM_DEFENDER_DIED            = 102
	MP_CONCEPT_MVM_FIRST_BOMB_PICKUP        = 103
	MP_CONCEPT_MVM_BOMB_PICKUP              = 104
	MP_CONCEPT_MVM_SENTRY_BUSTER            = 105
	MP_CONCEPT_MVM_SENTRY_BUSTER_DOWN       = 106
	MP_CONCEPT_MVM_SNIPER_CALLOUT           = 107
	MP_CONCEPT_MVM_LAST_MAN_STANDING        = 108
	MP_CONCEPT_MVM_ENCOURAGE_MONEY          = 109
	MP_CONCEPT_MVM_MONEY_PICKUP             = 110
	MP_CONCEPT_MVM_ENCOURAGE_UPGRADE        = 111
	MP_CONCEPT_MVM_UPGRADE_COMPLETE         = 112
	MP_CONCEPT_MVM_GIANT_CALLOUT            = 113
	MP_CONCEPT_MVM_GIANT_HAS_BOMB           = 114
	MP_CONCEPT_MVM_GIANT_KILLED             = 115
	MP_CONCEPT_MVM_GIANT_KILLED_TEAMMATE    = 116
	MP_CONCEPT_MVM_SAPPED_ROBOT             = 117
	MP_CONCEPT_MVM_CLOSE_CALL               = 118
	MP_CONCEPT_MVM_TANK_CALLOUT             = 119
	MP_CONCEPT_MVM_TANK_DEAD                = 120
	MP_CONCEPT_MVM_TANK_DEPLOYING           = 121
	MP_CONCEPT_MVM_ATTACK_THE_TANK          = 122
	MP_CONCEPT_MVM_TAUNT                    = 123
	MP_CONCEPT_MVM_WAVE_START               = 124
	MP_CONCEPT_MVM_WAVE_WIN                 = 125
	MP_CONCEPT_MVM_WAVE_LOSE                = 126
	MP_CONCEPT_MVM_DEPLOY_RAGE              = 127
	MP_CONCEPT_MAGIC_BIGHEAD                = 128
	MP_CONCEPT_MAGIC_SMALLHEAD              = 129
	MP_CONCEPT_MAGIC_GRAVITY                = 130
	MP_CONCEPT_MAGIC_GOOD                   = 131
	MP_CONCEPT_MAGIC_DANCE                  = 132
	MP_CONCEPT_HALLOWEEN_LONGFALL           = 133
	MP_CONCEPT_TAUNT_GUITAR_RIFF            = 134
	MP_CONCEPT_PLAYER_CAST_FIREBALL         = 135
	MP_CONCEPT_PLAYER_CAST_MERASMUS_ZAP     = 136
	MP_CONCEPT_PLAYER_CAST_SELF_HEAL        = 137
	MP_CONCEPT_PLAYER_CAST_MIRV             = 138
	MP_CONCEPT_PLAYER_CAST_BLAST_JUMP       = 139
	MP_CONCEPT_PLAYER_CAST_STEALTH          = 140
	MP_CONCEPT_PLAYER_CAST_TELEPORT         = 141
	MP_CONCEPT_PLAYER_CAST_LIGHTNING_BALL   = 142
	MP_CONCEPT_PLAYER_CAST_MOVEMENT_BUFF    = 143
	MP_CONCEPT_PLAYER_CAST_MONOCULOUS       = 144
	MP_CONCEPT_PLAYER_CAST_METEOR_SWARM     = 145
	MP_CONCEPT_PLAYER_CAST_SKELETON_HORDE   = 146
	MP_CONCEPT_PLAYER_CAST_BOMB_HEAD_CURSE  = 147
	MP_CONCEPT_PLAYER_SPELL_FIREBALL        = 148
	MP_CONCEPT_PLAYER_SPELL_MERASMUS_ZAP    = 149
	MP_CONCEPT_PLAYER_SPELL_SELF_HEAL       = 150
	MP_CONCEPT_PLAYER_SPELL_MIRV            = 151
	MP_CONCEPT_PLAYER_SPELL_BLAST_JUMP      = 152
	MP_CONCEPT_PLAYER_SPELL_STEALTH         = 153
	MP_CONCEPT_PLAYER_SPELL_TELEPORT        = 154
	MP_CONCEPT_PLAYER_SPELL_LIGHTNING_BALL  = 155
	MP_CONCEPT_PLAYER_SPELL_MOVEMENT_BUFF   = 156
	MP_CONCEPT_PLAYER_SPELL_MONOCULOUS      = 157
	MP_CONCEPT_PLAYER_SPELL_METEOR_SWARM    = 158
	MP_CONCEPT_PLAYER_SPELL_SKELETON_HORDE  = 159
	MP_CONCEPT_PLAYER_SPELL_BOMB_HEAD_CURSE = 160
	MP_CONCEPT_PLAYER_SPELL_PICKUP_COMMON   = 161
	MP_CONCEPT_PLAYER_SPELL_PICKUP_RARE     = 162
	MP_CONCEPT_PLAYER_HELLTOWER_MIDNIGHT    = 163
	MP_CONCEPT_PLAYER_SKELETON_KING_APPEAR  = 164
	MP_CONCEPT_MANNHATTAN_GATE_ATK          = 165
	MP_CONCEPT_MANNHATTAN_GATE_TAKE         = 166
	MP_CONCEPT_RESURRECTED                  = 167
	MP_CONCEPT_MVM_LOOT_COMMON              = 168
	MP_CONCEPT_MVM_LOOT_RARE                = 169
	MP_CONCEPT_MVM_LOOT_ULTRARARE           = 170
	MP_CONCEPT_MEDIC_HEAL_SHIELD            = 171
	MP_CONCEPT_TAUNT_EUREKA_EFFECT_TELEPORT = 172
	MP_CONCEPT_COMBO_KILLED                 = 173
	MP_CONCEPT_PLAYER_ASK_FOR_BALL          = 174
	MP_CONCEPT_ROUND_START_COMP             = 175
	MP_CONCEPT_GAME_OVER_COMP               = 176
	MP_CONCEPT_MATCH_OVER_COMP              = 177

	OBJ_DISPENSER         = 0
	OBJ_TELEPORTER        = 1
	OBJ_SENTRYGUN         = 2
	OBJ_ATTACHMENT_SAPPER = 3
	OBJ_LAST              = 4

	PATTACH_ABSORIGIN        = 0
	PATTACH_ABSORIGIN_FOLLOW = 1
	PATTACH_CUSTOMORIGIN     = 2
	PATTACH_POINT            = 3
	PATTACH_POINT_FOLLOW     = 4
	PATTACH_WORLDORIGIN      = 5
	PATTACH_ROOTBONE_FOLLOW  = 6

	RUNE_NONE      = -1
	RUNE_STRENGTH  = 0
	RUNE_HASTE     = 1
	RUNE_REGEN     = 2
	RUNE_RESIST    = 3
	RUNE_VAMPIRE   = 4
	RUNE_REFLECT   = 5
	RUNE_PRECISION = 6
	RUNE_AGILITY   = 7
	RUNE_KNOCKOUT  = 8
	RUNE_KING      = 9
	RUNE_PLAGUE    = 10
	RUNE_SUPERNOVA = 11
	RUNE_TYPES_MAX = 12

	SF_TRIGGER_ALLOW_CLIENTS                = 1
	SF_TRIGGER_ALLOW_NPCS                   = 2
	SF_TRIGGER_ALLOW_PUSHABLES              = 4
	SF_TRIGGER_ALLOW_PHYSICS                = 8
	SF_TRIGGER_ONLY_PLAYER_ALLY_NPCS        = 16
	SF_TRIGGER_ONLY_CLIENTS_IN_VEHICLES     = 32
	SF_TRIGGER_ALLOW_ALL                    = 64
	SF_TRIG_PUSH_ONCE                       = 128
	SF_TRIG_PUSH_AFFECT_PLAYER_ON_LADDER    = 256
	SF_TRIGGER_ONLY_CLIENTS_OUT_OF_VEHICLES = 512
	SF_TRIG_TOUCH_DEBRIS                    = 1024
	SF_TRIGGER_ONLY_NPCS_IN_VEHICLES        = 2048
	SF_TRIGGER_DISALLOW_BOTS                = 4096

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

	TF_AMMO_DUMMY     = 0
	TF_AMMO_PRIMARY   = 1
	TF_AMMO_SECONDARY = 2
	TF_AMMO_METAL     = 3
	TF_AMMO_GRENADES1 = 4
	TF_AMMO_GRENADES2 = 5
	TF_AMMO_GRENADES3 = 6
	TF_AMMO_COUNT     = 7

	TF_DEATH_DOMINATION          = 1
	TF_DEATH_ASSISTER_DOMINATION = 2
	TF_DEATH_REVENGE             = 4
	TF_DEATH_ASSISTER_REVENGE    = 8
	TF_DEATH_FIRST_BLOOD         = 16
	TF_DEATH_FEIGN_DEATH         = 32
	TF_DEATH_INTERRUPTED         = 64
	TF_DEATH_GIBBED              = 128
	TF_DEATH_PURGATORY           = 256
	TF_DEATH_MINIBOSS            = 512
	TF_DEATH_AUSTRALIUM          = 1024

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

	TFCOLLISION_GROUP_GRENADES                          = 20
	TFCOLLISION_GROUP_OBJECT                            = 21
	TFCOLLISION_GROUP_OBJECT_SOLIDTOPLAYERMOVEMENT      = 22
	TFCOLLISION_GROUP_COMBATOBJECT                      = 23
	TFCOLLISION_GROUP_ROCKETS                           = 24
	TFCOLLISION_GROUP_RESPAWNROOMS                      = 25
	TFCOLLISION_GROUP_PUMPKIN_BOMB                      = 26
	TFCOLLISION_GROUP_ROCKET_BUT_NOT_WITH_OTHER_ROCKETS = 27

	WL_NotInWater = 0
	WL_Feet       = 1
	WL_Waist      = 2
	WL_Eyes       = 3

	SHAKE_START            = 0
	SHAKE_STOP             = 1
	SHAKE_AMPLITUDE        = 2
	SHAKE_FREQUENCY        = 3
	SHAKE_START_RUMBLEONLY = 4
	SHAKE_START_NORUMBLE   = 5

	MVM_CLASS_FLAG_NONE            = 0
	MVM_CLASS_FLAG_NORMAL          = 1
	MVM_CLASS_FLAG_SUPPORT         = 2
	MVM_CLASS_FLAG_MISSION         = 4
	MVM_CLASS_FLAG_MINIBOSS        = 8
	MVM_CLASS_FLAG_ALWAYSCRIT      = 16
	MVM_CLASS_FLAG_SUPPORT_LIMITED = 32
	MVM_CLASS_TYPES_PER_WAVE_MAX   = 24

	SF_TRIGGER_ALLOW_CLIENTS            = 1
	SF_TRIGGER_ALLOW_NPCS               = 2
	SF_TRIGGER_ALLOW_PUSHABLES          = 4
	SF_TRIGGER_ALLOW_PHYSICS            = 8
	SF_TRIGGER_ONLY_PLAYER_ALLY_NPCS    = 16
	SF_TRIGGER_ONLY_CLIENTS_IN_VEHICLES = 32
	SF_TRIGGER_ALLOW_ALL                = 64

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
foreach(k,v in UNOFFICIAL_CONSTANTS)
	if(!(k in ROOT))
	{
		CONST[k] <- v
		ROOT[k] <- v
	}

::MarkForPurge <- @(hEnt) SetPropBool(hEnt, "m_bForcePurgeFixedupStrings", true)
::CreateByClassnameSafe <- function(sClassname)
{
	local hEnt = CreateByClassname(sClassname)
	MarkForPurge(hEnt)
	return hEnt
}
::SpawnEntityFromTableSafe <- function(sClassname, KeyValues)
{
	local hEnt = SpawnEntityFromTable(sClassname, KeyValues)
	MarkForPurge(hEnt)
	return hEnt
}

////////////////////////////////////////////////////////////////////////////////////////////

// cleanup if the script is called again
if("TankExt" in ROOT)
{
	if(TankExt.hThinkEnt.IsValid()) TankExt.hThinkEnt.Kill()
}

local hGameRules = FindByClassname(null, "tf_gamerules")
local hObjectiveResource = FindByClassname(null, "tf_objective_resource")
::TankExt <- {
	hThinkEnt   = null
	RevertPaths = []
	function OnGameEvent_recalculate_holidays(_) { if(GetRoundState() == 3) { delete ::TankExt } }
	function OnGameEvent_mvm_begin_wave(_)
	{
		// iterate through all path_tracks and offset them by a tiny amount if they overlap
		local Paths = []
		for(local hPath; hPath = FindByClassname(hPath, "path_track");)
			Paths.append([hPath, hPath.GetOrigin()])

		local iLength = Paths.len()
		while(iLength > 1)
		{
			local vecPath  = Paths[0][1]
			local flOffset = 1e-5
			foreach(i, array in Paths)
			{
				if(i == 0) continue
				if((vecPath - array[1]).LengthSqr() == 0)
				{
					array[0].SetAbsOrigin(array[1] + Vector(0, 0, flOffset))
					flOffset += 1e-5
					RevertPaths.append(array)
					Paths.remove(i)
					iLength--
				}
			}
			Paths.remove(0)
			iLength--
		}

		local TankIcons = clone QueuedTankIcons
		foreach(array in TankIcons)
			AddTankIcon(array[0], array[1], null, array[3], array[4])
		QueuedTankIcons.clear()
	}
	function OnGameEvent_mvm_wave_complete(params)
	{
		QueuedTankIcons.clear()
		CustomTankIcons.clear()
		CustomTankIconsWild.clear()

		bTankSpawnedThisWave = false

		foreach(array in RevertPaths)
			array[0].SetAbsOrigin(array[1])
		RevertPaths.clear()
	}

	PlayerArray = []
	function OnGameEvent_player_activate(params)
	{
		local hPlayer = GetPlayerFromUserID(params.userid)
		PlayerArray.append(hPlayer)
		PlayerArray.sort(function(hCurrent, hNext)
		{
			local iCurrent = hCurrent.entindex()
			local iNext    = hNext.entindex()
			if(iCurrent > iNext)
				return 1
			else if(iCurrent < iNext)
				return -1
			return 0
		})
	}
	function OnGameEvent_player_disconnect(params)
	{
		local hPlayer = GetPlayerFromUserID(params.userid)
		local iIndex  = PlayerArray.find(hPlayer)
		if(iIndex != null)
			PlayerArray.remove(iIndex)
	}
	function CollectPlayers(TeamArray, bAlive)
	{
		return PlayerArray.filter(function(i, hPlayer)
		{
			if(TeamArray && TeamArray.find(hPlayer.GetTeam()) == null)
				return false

			if(bAlive && !hPlayer.IsAlive())
				return false

			return true
		})
	}

	ActiveTanks          = {}
	TanksThisTick        = {}
	bTankSpawnedThisWave = false
	function OnGameEvent_teamplay_broadcast_audio(params)
	{
		if(params.sound == "Announcer.MVM_Tank_Alert_Multiple")
		{
			for(local hTank; hTank = FindByClassname(hTank, "tank_boss");)
				if(hTank != hThinkEnt)
				{
					if(!(hTank in TanksThisTick))
						TanksThisTick[hTank] <- null

					if(!(hTank.GetEFlags() & EFL_NO_MEGAPHYSCANNON_RAGDOLL))
					{
						hTank.AddEFlags(EFL_NO_MEGAPHYSCANNON_RAGDOLL)

						// tank icons
						local sTankName = hTank.GetName().tolower()

						local CustomTankIcons = CustomTankIcons
						local CustomTankIconsWild = CustomTankIconsWild

						local ReturnIconArray
						if(sTankName in CustomTankIcons)
							ReturnIconArray = function()
							{
								if(sTankName in CustomTankIcons)
									return CustomTankIcons[sTankName]
							}
						else foreach(sTankNameShort, Array in CustomTankIconsWild)
							if(startswith(sTankName, sTankNameShort))
							{
								local sTankNameShort = sTankNameShort
								ReturnIconArray = function()
								{
									if(sTankNameShort in CustomTankIconsWild)
										return CustomTankIconsWild[sTankNameShort]
								}
								break
							}

						ActiveTanks[hTank] <- ReturnIconArray // all tanks go in here, custom icon or not

						// find the starting path node then apply the tank
						local vecOrigin = hTank.GetOrigin()
						for(local hPath; hPath = FindByClassname(hPath, "path_track");) // FindByClassnameNearest and FindByClassnameWithin do not work with server side entities (rafmod specific issue)
							if((vecOrigin - hPath.GetOrigin()).LengthSqr() == 0)
							{
								ApplyTankType(hTank, hPath)
								break
							}
					}
				}

			TankExt.DelayFunction(null, this, -1, function()
			{
				local iTanks = TanksThisTick.len()
				if(iTanks == 0)
					return

				if(iTanks == 1)
					if(bTankSpawnedThisWave)
						hGameRules.AcceptInput("PlayVO", "Announcer.MVM_Tank_Alert_Another", null, null)
					else
						hGameRules.AcceptInput("PlayVO", "Announcer.MVM_Tank_Alert_Spawn", null, null)

				bTankSpawnedThisWave = true
				TanksThisTick.clear()
			})
		}
		else if(params.sound == "Announcer.MVM_Tank_Alert_Halfway_Multiple")
		{
			local iTanks = 0
			for(local hTank; hTank = FindByClassname(hTank, "tank_boss");)
				if(hTank != hThinkEnt)
				{
					iTanks++
					if(iTanks > 1)
						return // already playing the right sound
				}

			EntFireByHandle(hGameRules, "PlayVO", "Announcer.MVM_Tank_Alert_Halfway", -1, null, null)
		}
	}

	ValueOverrides  = {}
	TankScripts     = {}
	TankScriptsWild = {}
	function CreateLoopPaths(PathTable)
	{
		foreach(sPathName, OriginArray in PathTable)
		{
			if(FindByName(null, format("%s_1", sPathName)))
				continue

			local iArrayLength   = OriginArray.len() - 1
			local vecFinalOrigin = OriginArray.top()
			local iLoopStart
			foreach(i, vecOrigin in OriginArray)
				if(i != iArrayLength && (vecOrigin - vecFinalOrigin).LengthSqr() == 0)
					{ iLoopStart = i; break }

			if(iLoopStart == null)
				return ClientPrint(null, 3, format("\x07ffb2b2[ERROR] Looping path (%s) endpoint does not connect to itself", sPathName))

			local hPath1 = SpawnEntityFromTableSafe("path_track", {
				origin     = OriginArray[0]
				targetname = format("%s_1", sPathName)
				OnPass     = format("%s_2,CallScriptFunction,LoopInitialize,0,-1", sPathName)
			})
			local hPath2 = SpawnEntityFromTableSafe("path_track", {
				origin     = OriginArray[1]
				targetname = format("%s_2", sPathName)
			})
			local hPath3 = SpawnEntityFromTableSafe("path_track", {
				origin     = Vector(99999)
				targetname = format("%s_3", sPathName)
			})
			TankExt.SetPathConnection(hPath1, hPath2)
			TankExt.SetPathConnection(hPath2, hPath3)

			hPath2.ValidateScriptScope()
			local hPath_scope = hPath2.GetScriptScope()
			IncludeScript("tankextensions/misc/loopingpath_think", hPath_scope)
			hPath_scope.OriginArray  <- OriginArray
			hPath_scope.sPathName    <- sPathName
			hPath_scope.iArrayLength <- iArrayLength
			hPath_scope.iLoopStart   <- iLoopStart
			TankExt.AddThinkToEnt(hPath2, "PathThink")
		}
	}
	function CreatePaths(PathTable)
	{
		foreach(sPathName, OriginArray in PathTable)
		{
			if(FindByName(null, format("%s_1", sPathName)))
				continue

			local PathGroup = {}
			local iArrayLength = OriginArray.len() - 1
			foreach(i, vecOrigin in OriginArray)
			{
				PathGroup[i] <- {}
				PathGroup[i].path_track <- {
					origin     = vecOrigin
					targetname = format("%s_%i", sPathName, i + 1)
					target     = i != iArrayLength ? format("%s_%i", sPathName, i + 2) : ""
				}
				if(i == iArrayLength - 1)
				{
					local vecOriginNext = OriginArray[i + 1]
					local hPath = FindByClassnameNearest("path_track", vecOriginNext, 1)
					if(hPath != null)
						{ PathGroup[i].path_track.target = hPath.GetName(); break }
				}
			}
			SpawnEntityGroupFromTable(PathGroup)
		}
	}
	function NewTankType(sName, Table)
	{
		sName = sName.tolower()
		if(sName[sName.len() - 1] == '*')
		{
			sName = sName.slice(0, sName.len() - 1)
			TankExt.TankScriptsWild[sName] <- Table
		}
		else
			TankExt.TankScripts[sName] <- Table
	}
	function ApplyTankType(hTank, hPath)
	{
		local sTankName = hTank.GetName().tolower()
		MarkForPurge(hTank)

		// legacy
		local UseLegacy = function()
		{
			hTank.RemoveEFlags(EFL_NO_MEGAPHYSCANNON_RAGDOLL)
			hTank.AcceptInput("RunScriptCode", "TankExt.RunTankScript(self)", hTank, hPath)
		}
		if(sTankName in TankScriptsLegacy) UseLegacy()
		else
			foreach(sName, Table in TankScriptsWildLegacy)
				if(startswith(sTankName, sName))
					{ UseLegacy(); break }

		local vecMins = hTank.GetBoundingMins(), vecMaxs = hTank.GetBoundingMaxs()

		local iCustomParamsBegin = sTankName.find("$")
		if(iCustomParamsBegin != null)
		{
			local CustomParams = split(sTankName.slice(iCustomParamsBegin + 1), "^")
			sTankName = sTankName.slice(0, iCustomParamsBegin)

			local ParamTable = {}
			foreach(CustomParam in CustomParams)
			{
				local Params = split(CustomParam, "|")

				local ParamName = Params[0].tolower()
				local ValidKeyValues = {
					"Color"                  : null
					"DisableBomb"            : "tointeger"
					"DisableChildModels"     : "tointeger"
					"DisableOutline"         : "tointeger"
					"DisableSmokestack"      : "tointeger"
					"DisableTracks"          : "tointeger"
					"EngineLoopSound"        : null
					"Model"                  : null
					"NoDestructionModel"     : "tointeger"
					"NoGravity"              : "tointeger"
					"NoScreenShake"          : "tointeger"
					"PingSound"              : null
					"ReplaceModelCollisions" : "tointeger"
					"Scale"                  : "tofloat"
					"TeamNum"                : "tointeger"
				}
				foreach(sName, sType in ValidKeyValues)
					if(sName.tolower() == ParamName)
					{
						local Value = Params[1]
						if(sType) Value = Value[sType]()
						ParamTable[sName] <- Value
					}
			}
			ExtraTankKeyValues(hTank, hPath, ParamTable)
		}

		if(sTankName.find("^") != null)
		{
			foreach(sTankName in split(sTankName, "^"))
				ApplyTankTableByName(hTank, hPath, sTankName)
		}
		else
			ApplyTankTableByName(hTank, hPath, sTankName)

		local hTank_scope  = hTank.GetScriptScope()
		local flModelScale = hTank.GetModelScale()
		if(!("bReplaceModelCollisions" in hTank_scope && hTank_scope.bReplaceModelCollisions))
			hTank.SetSize(vecMins * (1 / flModelScale), vecMaxs * (1 / flModelScale))
	}
	function ExtraTankKeyValues(hTank, hPath, TankTable)
	{
		hTank.ValidateScriptScope()
		local hTank_scope = hTank.GetScriptScope()

		if(!("UsedKeyValues" in hTank_scope))
			hTank_scope.UsedKeyValues <- {}

		if(!("MultiOnDeath" in hTank_scope))
		{
			hTank_scope.MultiOnDeath <- []
			SetDestroyCallback(hTank, function()
			{
				foreach(OnDeathFunction in MultiOnDeath)
					if(typeof OnDeathFunction == "function")
						OnDeathFunction()
				if("MultiScope" in this)
					foreach(sName, Table in MultiScope)
						if("OnDeath" in Table)
						{
							Table.self <- self
							Table.OnDeath()
						}
			})
		}

		local Check = @(string) !(string in hTank_scope.UsedKeyValues) && string in TankTable
		local Add   = @(string) hTank_scope.UsedKeyValues[string] <- null

		if(Check("Model"))
		{
			Add("Model")
			if(typeof TankTable.Model == "string")
				TankTable.Model = { Default = TankTable.Model }

			local bModel  = false
			local bVisual = false
			if("Default" in TankTable.Model)
			{
				bModel = true
				if(!("Damage1" in TankTable.Model))
					TankTable.Model.Damage1 <- TankTable.Model.Default
				if(!("Damage2" in TankTable.Model))
					TankTable.Model.Damage2 <- TankTable.Model.Damage1
				if(!("Damage3" in TankTable.Model))
					TankTable.Model.Damage3 <- TankTable.Model.Damage2
			}

			TankExt.SetTankModel(hTank, {
				Tank       = bModel ? TankTable.Model.Default : null
				LeftTrack  = "LeftTrack" in TankTable.Model ? TankTable.Model.LeftTrack : null
				RightTrack = "RightTrack" in TankTable.Model ? TankTable.Model.RightTrack : null
				Bomb       = "Bomb" in TankTable.Model ? TankTable.Model.Bomb : null
			})

			local iModelIndex = 0
			if("Visual" in TankTable.Model)
			{
				bVisual = true
				iModelIndex = PrecacheModel(TankTable.Model.Visual)
				SetPropIntArray(hTank, "m_nModelIndexOverrides", iModelIndex, 0)
				SetPropIntArray(hTank, "m_nModelIndexOverrides", iModelIndex, 3)
			}

			hTank_scope.sModelLast <- hTank.GetModelName()
			hTank_scope.ModelThink <- function()
			{
				local sModel = self.GetModelName()
				if(sModel != sModelLast)
				{
					if(bModel)
					{
						local sNewModel = sModel

						if(sModel == "models/bots/boss_bot/boss_tank.mdl")
							sNewModel = TankTable.Model.Default
						else if(sModel == "models/bots/boss_bot/boss_tank_damage1.mdl")
							sNewModel = TankTable.Model.Damage1
						else if(sModel == "models/bots/boss_bot/boss_tank_damage2.mdl")
							sNewModel = TankTable.Model.Damage2
						else if(sModel == "models/bots/boss_bot/boss_tank_damage3.mdl")
							sNewModel = TankTable.Model.Damage3

						TankExt.SetTankModel(hTank, { Tank = sNewModel })
						sModel = sNewModel
					}
					if(bVisual)
					{
						SetPropIntArray(hTank, "m_nModelIndexOverrides", iModelIndex, 0)
						SetPropIntArray(hTank, "m_nModelIndexOverrides", iModelIndex, 3)
					}
				}
				sModelLast = sModel
			}
			TankExt.AddThinkToEnt(hTank, "ModelThink")
		}

		local DisableModels = function(iFlags)
		{
			for(local hChild = hTank.FirstMoveChild(); hChild != null; hChild = hChild.NextMovePeer())
			{
				local sChildModel = hChild.GetModelName().tolower()
				if((iFlags & 1 && sChildModel.find("track_")) || (iFlags & 2 && sChildModel.find("bomb_mechanism")))
					hChild.DisableDraw()
			}
		}

		if(Check("DisableChildModels") && TankTable.DisableChildModels)
			DisableModels(3), Add("DisableChildModels")

		if(Check("DisableTracks") && TankTable.DisableTracks)
			DisableModels(1), Add("DisableTracks")

		if(Check("DisableBomb") && TankTable.DisableBomb)
			DisableModels(2), Add("DisableBomb")

		if(Check("Color"))
			TankExt.SetTankColor(hTank, TankTable.Color), Add("Color")

		if(Check("TeamNum"))
		{
			Add("TeamNum")
			hTank.SetTeam(TankTable.TeamNum)
			EntFireByHandle(hTank, "RunScriptCode", "SetPropBool(self, `m_bGlowEnabled`, true)", 0.066, null, null)
		}

		if(Check("DisableOutline") && TankTable.DisableOutline)
		{
			Add("DisableOutline")
			SetPropBool(hTank, "m_bGlowEnabled", false)
			EntFireByHandle(hTank, "RunScriptCode", "SetPropBool(self, `m_bGlowEnabled`, false)", 0.066, null, null)
		}

		if(Check("DisableSmokestack") && TankTable.DisableSmokestack)
		{
			Add("DisableSmokestack")
			hTank_scope.DisableSmokestackThink <- function() { self.AcceptInput("DispatchEffect", "ParticleEffectStop", null, null) }
			TankExt.AddThinkToEnt(hTank, "DisableSmokestackThink")
		}

		if(Check("NoScreenShake") && TankTable.NoScreenShake)
		{
			Add("NoScreenShake")
			hTank_scope.NoScreenShakeThink <- function() { ScreenShake(self.GetOrigin(), 2.0, 5.0, 1.0, 500.0, SHAKE_STOP, true) }
			TankExt.AddThinkToEnt(hTank, "NoScreenShakeThink")
		}

		if(Check("EngineLoopSound"))
		{
			Add("EngineLoopSound")
			local sSound = TankTable.EngineLoopSound
			TankExt.PrecacheSound(sSound)
			StopSoundOn("MVM.TankEngineLoop", hTank)
			local Sound = @(hEnt, iFlags) EmitSoundEx({
				sound_name  = sSound
				channel     = CHAN_STATIC
				sound_level = 85
				entity      = hEnt
				filter_type = RECIPIENT_FILTER_GLOBAL
				flags       = iFlags
			})
			Sound(hTank, SND_NOFLAGS)
			local iDeploySeq = hTank.LookupSequence("deploy")
			hTank_scope.EngineLoopSound <- sSound
			hTank_scope.EngineLoopSoundThink <- function()
			{
				if(iDeploySeq && self.GetSequence() == iDeploySeq)
				{
					iDeploySeq = null
					Sound(hTank, SND_STOP)
				}
			}
			TankExt.AddThinkToEnt(hTank, "EngineLoopSoundThink")
			hTank_scope.MultiOnDeath.append(function()
			{
				Sound(self, SND_STOP)
			})
		}

		if(Check("PingSound"))
		{
			Add("PingSound")
			local sSound = TankTable.PingSound
			TankExt.PrecacheSound(sSound)
			hTank_scope.flLastPingTime <- Time()
			hTank_scope.PingSoundThink <- function()
			{
				local flTime = Time()
				if(flTime - flLastPingTime >= 5.0)
				{
					flLastPingTime = flTime
					StopSoundOn("MVM.TankPing", self)
					EmitSoundEx({
						sound_name  = sSound
						channel     = CHAN_STATIC
						sound_level = 150
						entity      = self
						filter_type = RECIPIENT_FILTER_GLOBAL
					})
				}
			}
			TankExt.AddThinkToEnt(hTank, "PingSoundThink")
		}

		if(Check("Scale"))
			SetPropFloat(hTank, "m_flModelScale", TankTable.Scale), Add("Scale")

		if(Check("NoDestructionModel") && TankTable.NoDestructionModel)
		{
			Add("NoDestructionModel")
			hTank_scope.MultiOnDeath.append(function()
			{
				local hDestruction = FindByClassnameNearest("tank_destruction", self.GetOrigin(), 16)
				if(hDestruction)
				{
					local hParticle = SpawnEntityFromTableSafe("info_particle_system", {
						origin       = hDestruction.GetOrigin() + Vector(0, 0, 100)
						effect_name  = "mvm_tank_destroy"
						start_active = 1
					})
					EntFireByHandle(hParticle, "Kill", null, 0.5, null, null)
					hDestruction.Kill()
				}
			})
		}

		if(Check("NoGravity") && TankTable.NoGravity)
		{
			Add("NoGravity")
			hTank.SetAbsAngles(QAngle(0, hTank.GetAbsAngles().y, 0))
			local vecFakeOrigin = hTank.GetOrigin()
			local hGoal         = TankExt.GetNextPath(hPath)
			local Players       = []

			for(local i = 1; i <= MAX_CLIENTS; i++)
			{
				local hPlayer = PlayerInstanceFromIndex(i)
				if(hPlayer) Players.append(hPlayer)
			}

			hTank.AcceptInput("SetStepHeight", "18", null, null)
			hTank_scope.bNoGravity <- true
			hTank_scope.NoGravityThink <- function()
			{
				if(bNoGravity)
				{
					if(hGoal && hGoal.IsValid())
					{
						local vecGoal      = hGoal.GetOrigin()
						local flDistSqr    = (vecFakeOrigin - vecGoal).LengthSqr()
						local flSpeedDelta = GetPropFloat(self, "m_speed") * FrameTime()
						if(flSpeedDelta < 0) flSpeedDelta = 0
						local vecDifference = vecFakeOrigin
						if(flDistSqr < flSpeedDelta * flSpeedDelta)
						{
							vecFakeOrigin = vecGoal
							hGoal         = TankExt.GetNextPath(hGoal)
						}
						else
						{
							local vecDirection = vecGoal - vecFakeOrigin
							vecDirection.Norm()
							vecDirection *= flSpeedDelta
							vecFakeOrigin += vecDirection
						}

						vecDifference -= vecFakeOrigin
						vecDifference *= -1
						local vecMins = self.GetBoundingMins()
						local vecMaxs = self.GetBoundingMaxs()
						foreach(hPlayer in Players)
							if(hPlayer.IsValid() && hPlayer.IsAlive())
							{
								local vecPlayer = hPlayer.GetOrigin()
								if(TankExt.IntersectionBoxBox(vecFakeOrigin, vecMins, vecMaxs, vecPlayer, hPlayer.GetPlayerMins(), hPlayer.GetPlayerMaxs()))
									hPlayer.SetAbsOrigin(vecPlayer + (hPlayer.GetFlags() & FL_ONGROUND ? Vector(0, 0, vecDifference.z + 0.01) : vecDifference))
							}
					}
					self.SetAbsOrigin(vecFakeOrigin)
					self.GetLocomotionInterface().Reset()
				}
				else if(hGoal)
				{
					vecFakeOrigin = self.GetOrigin()
					if((vecFakeOrigin - hGoal.GetOrigin()).Length2D() < 20.0)
						hGoal = TankExt.GetNextPath(hGoal)
				}
				self.AcceptInput("SetStepHeight", bNoGravity || !(self.GetFlags() & FL_ONGROUND) ? "18" : "100", null, null)
			}
			TankExt.AddThinkToEnt(hTank, "NoGravityThink")
		}

		if(Check("ReplaceModelCollisions") && TankTable.ReplaceModelCollisions)
		{
			Add("ReplaceModelCollisions")
			hTank_scope.bReplaceModelCollisions <- true
		}
	}
	function ApplyTankTableByName(hTank, hPath, sTankName)
	{
		local TankTable
		local sTableName

		if(sTankName in TankScripts)
		{
			TankTable  = TankScripts[sTankName]
			sTableName = sTankName
		}
		else
			foreach(sName, Table in TankScriptsWild)
				if(startswith(sTankName, sName))
					{
						TankTable  = Table
						sTableName = sName
						break
					}

		if(TankTable)
		{
			hTank.ValidateScriptScope()
			local hTank_scope = hTank.GetScriptScope()

			if(!("MultiScope" in hTank_scope))
			{
				local bDeploying = false
				hTank_scope.MultiScope <- {}
				hTank_scope.MultiScopeThink <- function()
				{
					if(!bDeploying && self.GetSequenceName(self.GetSequence()) == "deploy")
					{
						bDeploying = true
						if("MultiScope" in this)
							foreach(sName, Table in MultiScope)
								if("OnStartDeploy" in Table)
								{
									Table.self <- self
									Table.OnStartDeploy()
								}
					}

					local flTime      = Time()
					local vecOrigin   = self.GetOrigin()
					local angRotation = self.GetAbsAngles()
					local iTeamNum    = self.GetTeam()
					local iHealth     = self.GetHealth()
					local iMaxHealth  = self.GetMaxHealth()
					foreach(sName, Table in MultiScope)
						if("Think" in Table)
						{
							Table.flTime      <- flTime
							Table.vecOrigin   <- vecOrigin
							Table.angRotation <- angRotation
							Table.iTeamNum    <- iTeamNum
							Table.iHealth     <- iHealth
							Table.iMaxHealth  <- iMaxHealth
							Table.bDeploying  <- bDeploying
							Table.Think()
						}
				}
				TankExt.AddThinkToEnt(hTank, "MultiScopeThink")
			}

			ExtraTankKeyValues(hTank, hPath, TankTable)

			local MakeScope = function()
			{
				local NewScope = {
					self      = hTank
					sTankName = sTankName
					hTankPath = hPath
				}
				hTank_scope.MultiScope[sTableName] <- NewScope
				return NewScope
			}

			if("OnSpawn" in TankTable)
				TankTable.OnSpawn.call(MakeScope())

			if("OnDeath" in TankTable)
			{
				if(!(sTableName in hTank_scope.MultiScope)) MakeScope()
				hTank_scope.MultiScope[sTableName].OnDeath <- TankTable.OnDeath
			}

			if("OnStartDeploy" in TankTable)
			{
				if(!(sTableName in hTank_scope.MultiScope)) MakeScope()
				hTank_scope.MultiScope[sTableName].OnStartDeploy <- TankTable.OnStartDeploy
			}
		}
	}

	QueuedTankIcons      = []
	CustomTankIcons      = {}
	CustomTankIconsWild  = {}
	function AddTankIcon(iCount, sIcon, sTankName = null, iPlacement = null, iFlagOverrides = MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_MINIBOSS)
	{
		local PreviousIcon
		local iCurrentPlacement = 0
		IterateIcons(function(iIndex, sNames, sCounts, sFlags)
		{
			local sIconName = GetPropStringArray(hObjectiveResource, sNames, iIndex)
			if(sIcon == "tank")
			{
				if(sIconName == "tank")
				{
					SetPropIntArray(hObjectiveResource, sFlags, iFlagOverrides, iIndex)
					return true
				}
				return
			}

			local Set = function(sIcon, iCount, iFlags)
			{
				SetPropStringArray(hObjectiveResource, sNames, sIcon, iIndex)
				SetPropIntArray(hObjectiveResource, sCounts, iCount, iIndex)
				SetPropIntArray(hObjectiveResource, sFlags, iFlags, iIndex)
			}
			if(PreviousIcon)
			{
				local PreviousIconTemp = [
					GetPropStringArray(hObjectiveResource, sNames, iIndex),
					GetPropIntArray(hObjectiveResource, sCounts, iIndex),
					GetPropIntArray(hObjectiveResource, sFlags, iIndex)
				]
				Set(PreviousIcon[0], PreviousIcon[1], PreviousIcon[2])
				PreviousIcon = PreviousIconTemp
			}

			local iIconCount = GetPropIntArray(hObjectiveResource, sCounts, iIndex)
			if(sIconName == "tank")
				SetPropIntArray(hObjectiveResource, sCounts, iIconCount - iCount, iIndex)
			if(iPlacement != null && iPlacement == iCurrentPlacement)
			{
				PreviousIcon = [
					sIconName,
					iIconCount,
					GetPropIntArray(hObjectiveResource, sFlags, iIndex)
				]
				Set(sIcon, iCount, iFlagOverrides)
			}
			else if(iPlacement == null && ((sIconName == "" && iIconCount == 0) || sIconName == sIcon))
			{
				Set(sIcon, iCount, iFlagOverrides)
				return true
			}
			iCurrentPlacement++
		})
		if(sTankName && sIcon != "tank")
		{
			sTankName = sTankName.tolower()
			if(sTankName[sTankName.len() - 1] == '*')
			{
				sTankName = sTankName.slice(0, sTankName.len() - 1)
					CustomTankIconsWild[sTankName] <- [iCount, sIcon]
			}
			else
				CustomTankIcons[sTankName] <- [iCount, sIcon]
		}
		QueuedTankIcons.append([iCount, sIcon, null, iPlacement, iFlagOverrides])
	}

	//////////////////////// Utilities ////////////////////////

	function IterateIcons(func)
	{
		for(local i = 0; i < MVM_CLASS_TYPES_PER_WAVE_MAX; i++)
		{
			local iIndex = i

			local bTwo = iIndex > 11
			if(bTwo) iIndex -= 12
			local sTwo = bTwo ? "2." : "."

			local sNames  = format("m_iszMannVsMachineWaveClassNames%s", sTwo)
			local sCounts = format("m_nMannVsMachineWaveClassCounts%s", sTwo)
			local sFlags  = format("m_nMannVsMachineWaveClassFlags%s", sTwo)

			if(func(iIndex, sNames, sCounts, sFlags)) break
		}
	}
	function SetTankModel(hTank, Model)
	{
		local ApplyModel = function(hEntity, sModel)
		{
			local bSmokeStack = hEntity == hTank && sModel != hTank.GetModelName() && GetPropInt(hTank, "touchStamp") >= 2 && !("DisableSmokestackThink" in hTank.GetScriptScope())
			local iModelIndex = PrecacheModel(sModel)
			local sSequence   = hEntity.GetSequenceName(hEntity.GetSequence())
			hEntity.SetModel(sModel)
			SetPropInt(hEntity, "m_nModelIndex", iModelIndex)
			SetPropIntArray(hEntity, "m_nModelIndexOverrides", iModelIndex, 0)
			hEntity.SetSequence(hEntity.LookupSequence(sSequence))
			if(bSmokeStack)
			{
				local iAttachment = hTank.LookupAttachment("smoke_attachment")
				if(iAttachment != 0)
				{
					local vecSmoke = hTank.GetAttachmentOrigin(iAttachment)
					local Trace = {
						start  = vecSmoke
						end    = vecSmoke + Vector(0, 0, 300)
						mask   = MASK_SOLID_BRUSHONLY
						ignore = hTank
					}
					TraceLineEx(Trace)
					if(!Trace.hit)
					{
						DispatchParticleEffectOn(hTank, null)
						DispatchParticleEffectOn(hTank, "smoke_train", "smoke_attachment")
					}
				}
			}
		}
		if(typeof Model == "string")
			{ ApplyModel(hTank, Model); return }

		if("Tank" in Model && Model.Tank)
		{
			ApplyModel(hTank, Model.Tank)
			SetPropIntArray(hTank, "m_nModelIndexOverrides", GetPropIntArray(hTank, "m_nModelIndexOverrides", 0), 3)
		}
		for(local hChild = hTank.FirstMoveChild(); hChild; hChild = hChild.NextMovePeer())
		{
			local sChildModel = hChild.GetModelName().tolower()
			if("LeftTrack" in Model && Model.LeftTrack && sChildModel.find("track_l"))
				ApplyModel(hChild, Model.LeftTrack)
			else if("RightTrack" in Model && Model.RightTrack && sChildModel.find("track_r"))
				ApplyModel(hChild, Model.RightTrack)
			else if("Bomb" in Model && Model.Bomb && sChildModel.find("bomb_mechanism"))
				ApplyModel(hChild, Model.Bomb)

			SetPropIntArray(hChild, "m_nModelIndexOverrides", GetPropIntArray(hChild, "m_nModelIndexOverrides", 0), 3)
		}
	}
	function SetTankColor(hTank, sColor)
	{
		hTank.AcceptInput("Color", sColor, null, null)
		for(local hChild = hTank.FirstMoveChild(); hChild != null; hChild = hChild.NextMovePeer())
		{
			local sChildModel = hChild.GetModelName().tolower()
			if(sChildModel.find("track_"))
				hChild.AcceptInput("Color", sColor, null, null)
			else if(sChildModel.find("bomb_mechanism"))
				hChild.AcceptInput("Color", sColor, null, null)
		}
	}
	function SetPathConnection(hPath1, hPath2, hPathAlt = null)
	{
		if(hPath2)
		{
			SetPropEntity(hPath1, "m_pnext", hPath2)
			SetPropEntity(hPath2, "m_pprevious", hPath1)
		}
		else
		{
			SetPropEntity(hPath1, "m_pnext", null)
			SetPropEntity(hPath1, "m_pprevious", null)
			SetPropEntity(hPath1, "m_paltpath", null)
			return
		}
		if(hPathAlt)
			SetPropEntity(hPath1, "m_paltpath", hPathAlt)
	}
	function SetValueOverrides(ValueTable)
	{
		ValueOverrides = ValueTable
		foreach(k,v in ValueTable)
			ROOT[k] <- v
	}
	function SetDestroyCallback(entity, callback)
	{
		entity.ValidateScriptScope()
		local scope = entity.GetScriptScope()
		scope.setdelegate({}.setdelegate({
				parent   = scope.getdelegate()
				id       = entity.GetScriptId()
				index    = entity.entindex()
				callback = callback
				_get = function(k)
				{
					return parent[k]
				}
				_delslot = function(k)
				{
					if (k == id)
					{
						entity = EntIndexToHScript(index)
						local scope = entity.GetScriptScope()
						scope.self <- entity
						callback.pcall(scope)
					}
					delete parent[k]
				}
			})
		)
	}
	function SetParentArray(hChildren, hParent, sAttachment = null)
	{
		local iAttachment
		if(sAttachment) iAttachment = hParent.LookupAttachment(sAttachment)
		foreach(hChild in hChildren)
		{
			local vecOrigin   = hChild.GetOrigin()
			local angRotation = hChild.GetAbsAngles()
			hChild.AcceptInput("SetParent", "!activator", hParent, null)
			// SetPropEntity(hChild, "m_hMovePeer", hParent.FirstMoveChild())
			// SetPropEntity(hParent, "m_hMoveChild", hChild)
			// SetPropEntity(hChild, "m_pParent", hParent)
			// SetPropEntity(hChild, "m_hMoveParent", hParent)
			// SetPropEntity(hChild, "m_Network.m_hParent", hParent)
			SetPropEntity(hChild, "m_hLightingOrigin", hParent)
			if(sAttachment)
				SetPropInt(hChild, "m_iParentAttachment", iAttachment)
			hChild.SetLocalOrigin(vecOrigin)
			hChild.SetLocalAngles(angRotation)
		}
	}
	function DelayFunction(hTarget, Scope, flDelay, func)
	{
		local sFuncName = UniqueString()
		hThinkEnt.GetScriptScope()[sFuncName] <- function()
		{
			delete this[sFuncName]
			if(!hTarget)
				func.call(Scope || ROOT)
			else if(hTarget.IsValid())
				func.call(Scope || { self = hTarget })
		}
		EntFireByHandle(hThinkEnt, "CallScriptFunction", sFuncName, flDelay, null, null)
	}
	function GetMultiScopeTable(Scope, sName)
	{
		if("MultiScope" in Scope)
			foreach(sScope, Table in Scope.MultiScope)
				if(sScope == sName)
					return Table
		return null
	}
	function GetNextPath(hPath)
	{
		local iSpawnflags = GetPropInt(hPath, "m_spawnflags")
		if(GetPropEntity(hPath, "m_paltpath") && iSpawnflags & 32768 && !(iSpawnflags & 4)) // SF_PATH_ALTERNATE, SF_PATH_ALTREVERSE
			return GetPropEntity(hPath, "m_paltpath")
		else
			return GetPropEntity(hPath, "m_pnext")
	}
	function NormalizeAngle(target)
	{
		target %= 360.0
		if (target > 180.0)
			target -= 360.0
		else if (target < -180.0)
			target += 360.0
		return target
	}
	function ApproachAngle(target, value, speed)
	{
		target = NormalizeAngle(target)
		value = NormalizeAngle(value)
		local delta = NormalizeAngle(target - value)
		if (delta > speed)
			return value + speed
		else if (delta < -speed)
			return value - speed
		return value
	}
	function VectorAngles(forward)
	{
		local yaw, pitch
		if ( forward.y == 0.0 && forward.x == 0.0 )
		{
			yaw = 0.0
			if (forward.z > 0.0)
				pitch = 270.0
			else
				pitch = 90.0
		}
		else
		{
			yaw = (atan2(forward.y, forward.x) * 180.0 / Pi)
			if (yaw < 0.0)
				yaw += 360.0
			pitch = (atan2(-forward.z, forward.Length2D()) * 180.0 / Pi)
			if (pitch < 0.0)
				pitch += 360.0
		}

		return QAngle(pitch, yaw, 0.0)
	}
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
	function Clamp(value, low, high)
	{
		if (value < low)
			return low
		if (value > high)
			return high
		return value
	}
	function SetEntityColor(entity, r, g, b, a)
	{
		local color = (r) | (g << 8) | (b << 16) | (a << 24)
		NetProps.SetPropInt(entity, "m_clrRender", color)
	}
	function DispatchParticleEffectOn(entity, name, attachment = null)
	{
		if(entity == null) return
		if(name == null)
			{ entity.AcceptInput("DispatchEffect", "ParticleEffectStop", null, null); return }
		local hParticle = CreateByClassnameSafe("trigger_particle")
		hParticle.KeyValueFromString("particle_name", name)
		if(attachment)
			hParticle.KeyValueFromString("attachment_name", attachment)
		hParticle.KeyValueFromInt("attachment_type", attachment ? 4 : 1)
		hParticle.KeyValueFromInt("spawnflags", 64)
		hParticle.DispatchSpawn()
		hParticle.AcceptInput("StartTouch", null, entity, entity)
		hParticle.Kill()
	}
	function PrecacheParticle(name)
	{
		PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = name })
	}
	function IsPlayerStealthedOrDisguised(hPlayer)
	{
		if(!hPlayer.IsPlayer()) return false
		return (hPlayer.IsStealthed() || hPlayer.InCond(TF_COND_DISGUISED)) &&
		!hPlayer.InCond(TF_COND_BURNING) &&
		!hPlayer.InCond(TF_COND_URINE) &&
		!hPlayer.InCond(TF_COND_STEALTHED_BLINK) &&
		!hPlayer.InCond(TF_COND_BLEEDING)
	}
	function PathMaker(hPlayer)
	{
		Convars.SetValue("sig_etc_path_track_is_server_entity", 0)
		local ExistsInScope = @(scope, string) string in scope && (typeof(scope[string]) == "instance" || typeof(scope[string]) == "null" ? (scope[string] != null && scope[string].IsValid()) : true)
		hPlayer.ValidateScriptScope()
		local hPlayer_scope = hPlayer.GetScriptScope()

		local flTimeNext   = 0
		local iGridSize    = 64
		local iButtonsLast = 0
		local iPrintMode   = 0
		local sndPlace     = "buttons/blip1.wav"
		local sndRemove    = "buttons/button15.wav"
		local sndChange    = "buttons/button16.wav"
		local sndComplete1 = "buttons/button18.wav"
		local sndComplete2 = "buttons/button9.wav"
		PrecacheSound(sndPlace)
		PrecacheSound(sndRemove)
		PrecacheSound(sndChange)
		PrecacheSound(sndComplete1)
		PrecacheSound(sndComplete2)

		if(ExistsInScope(hPlayer_scope, "PathArray"))
			foreach(array in hPlayer_scope.PathArray)
				if(array[1].IsValid())
					array[1].Kill()
		hPlayer_scope.PathArray <- []

		if(ExistsInScope(hPlayer_scope, "hGlow")) hPlayer_scope.hGlow.Kill()
		hPlayer_scope.hGlow <- null

		if(ExistsInScope(hPlayer_scope, "hPathVisual")) hPlayer_scope.hPathVisual.Kill()
		hPlayer_scope.hPathVisual <- null

		if(ExistsInScope(hPlayer_scope, "hPathBeam")) hPlayer_scope.hPathBeam.Kill()
		hPlayer_scope.hPathBeam <- null

		if(ExistsInScope(hPlayer_scope, "hPathTrackVisual")) hPlayer_scope.hPathTrackVisual.Kill()
		hPlayer_scope.hPathTrackVisual <- null

		if(ExistsInScope(hPlayer_scope, "hPathHatchVisual")) hPlayer_scope.hPathHatchVisual.Kill()
		hPlayer_scope.hPathHatchVisual <- null

		if(ExistsInScope(hPlayer_scope, "hText")) hPlayer_scope.hText.Kill()
		hPlayer_scope.hText <- null


		hPlayer_scope.PathMakerThink <- function()
		{
			local iButtons         = GetPropInt(self, "m_nButtons")
			local iButtonsChanged  = iButtonsLast ^ iButtons
			local iButtonsPressed  = iButtonsChanged & iButtons
			local iButtonsReleased = iButtonsChanged & (~iButtons)
			iButtonsLast = iButtons
			local vecEye = self.EyePosition()
			local angEye = self.EyeAngles()

			local vecTarget = (vecEye + angEye.Forward() * 128) * (1.0 / iGridSize)
			local GridMath = @(value) floor(value + 0.5) * iGridSize
			vecTarget.x = GridMath(vecTarget.x)
			vecTarget.y = GridMath(vecTarget.y)
			vecTarget.z = GridMath(vecTarget.z)

			local hLastPath
			local PathArrayLength = PathArray.len()
			if(PathArrayLength > 0) hLastPath = PathArray.top()[1]
			local hNearestPathTrack = FindByClassnameNearest("path_track", vecTarget, 1024)

			self.AddCustomAttribute("no_attack", 1, 0.1)

			if(ExistsInScope(this, "hText"))
			{
				local sPlaceText = format("Grid Size : %i\nReload : Cycle Grid Size\nMouse1 : Add Path\nMouse2 : Undo Path\nReload + Crouch : Print Path", iGridSize)
				local sPrintText = format("[Export Method]\nReload : Rafmod\nMouse1 : TankExt\nMouse2 : PopExt+\nCrouch : Cancel", iGridSize)
				hText.KeyValueFromString("message", iPrintMode > 0 ? sPrintText : sPlaceText)
				EntFireByHandle(hText, "Display", null, -1, self, null)
			}
			else
				hText = SpawnEntityFromTableSafe("game_text", {
					targetname = "pathmakertext"
					message    = "test"
					channel    = 0
					color      = "255 255 255"
					holdtime   = 0.3
					x          = -1
					y          = 0.7
				})

			if(iPrintMode > 0)
			{
				if(iPrintMode > 1)
				{
					EmitSoundEx({
						sound_name  = sndComplete2
						entity      = self
						filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
					})
					ClientPrint(self, HUD_PRINTCENTER, "Path printed to console")

					local TextArray = []
					switch(iPrintMode)
					{
						case 2:
							TextArray.append("tank_path = [")
							foreach(k, array in PathArray)
								TextArray.append(format("\tVector(%i, %i, %i)    // tank_path_%i", array[0].x, array[0].y, array[0].z, k + 1))
							TextArray.append("]")
							break
						case 3:
							TextArray.append("\"ExtraTankPath\" : [\n\t[")
							foreach(k, array in PathArray)
								TextArray.append(format("\t\t\"%i %i %i\"    // extratankpath1_%i", array[0].x, array[0].y, array[0].z, k + 1))
							TextArray.append("\t]\n]")
							break
						case 4:
							TextArray.append("ExtraTankPath\n{\n\tName \"tank_path\"")
							foreach(k, array in PathArray)
								TextArray.append(format("\tNode \"%i %i %i\"    // tank_path_%i", array[0].x, array[0].y, array[0].z, k + 1))
							TextArray.append("}")
							break
					}
					local flDelay = 0
					foreach(sText in TextArray)
					{
						local sPrint = sText
						TankExt.DelayFunction(null, null, flDelay += 0.03, function() { ClientPrint(null, HUD_PRINTCONSOLE, sPrint) })
					}

					if(ExistsInScope(this, "hGlow")) hGlow.Kill()
					if(ExistsInScope(this, "hPathVisual")) hPathVisual.Kill()
					if(ExistsInScope(this, "hPathBeam")) hPathBeam.Kill()
					if(ExistsInScope(this, "hPathTrackVisual")) hPathTrackVisual.Kill()
					if(ExistsInScope(this, "hPathHatchVisual")) hPathHatchVisual.Kill()
					if(ExistsInScope(this, "hText")) hText.Kill()
					if(ExistsInScope(this, "PathArray"))
						foreach(array in PathArray)
							if(array[1].IsValid())
								array[1].Kill()

					delete PathMakerThink
					Convars.SetValue("sig_etc_path_track_is_server_entity", 1)
				}

				if(iButtonsPressed & IN_ATTACK)
					iPrintMode = 2
				if(iButtonsPressed & IN_ATTACK2)
					iPrintMode = 3
				if(iButtonsPressed & IN_RELOAD)
					iPrintMode = 4
				if(iButtonsPressed & IN_DUCK)
					iPrintMode = 0

				return -1
			}

			if(iButtonsPressed & IN_RELOAD && iButtons & IN_DUCK)
			{
				EmitSoundEx({
					sound_name  = sndComplete1
					entity      = self
					filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
				})
				iPrintMode = 1
				return -1
			}
			if(iButtonsPressed & IN_ATTACK)
			{
				EmitSoundEx({
					sound_name = sndPlace
					entity = self
					filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
				})
				local hPath = SpawnEntityFromTableSafe("prop_dynamic", {
					origin         = vecTarget
					targetname     = "pathmakerpath"
					model          = "models/editor/axis_helper_thick.mdl"
					disableshadows = 1
				})
				PathArray.append([vecTarget, hPath])
			}
			if(iButtonsPressed & IN_ATTACK2 && PathArrayLength > 0)
			{
				EmitSoundEx({
					sound_name  = sndRemove
					entity      = self
					filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
				})
				local PathArrayEnd = PathArray.pop()
				PathArrayEnd[1].Destroy()
			}
			if(iButtonsPressed & IN_RELOAD)
			{
				EmitSoundEx({
					sound_name  = sndChange
					entity      = self
					filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
				})
				switch(iGridSize)
				{
					case 8:
						iGridSize = 16
						break
					case 16:
						iGridSize = 32
						break
					case 32:
						iGridSize = 64
						break
					case 64:
						iGridSize = 128
						break
					case 128:
						iGridSize = 8
				}
			}

			if(ExistsInScope(this, "hPathVisual"))
				hPathVisual.SetAbsOrigin(vecTarget)
			else
				hPathVisual = SpawnEntityFromTableSafe("prop_dynamic", {
					model          = "models/editor/axis_helper_thick.mdl"
					disableshadows = 1
					rendermode     = 1
					renderfx       = 4
					renderamt      = 127
				})

			if(ExistsInScope(this, "hPathBeam"))
			{
				local Trace = {
					start  = vecTarget
					end    = vecTarget + Vector(0, 0, -8192)
					mask   = MASK_SOLID
					ignore = self
				}
				TraceLineEx(Trace)
				hPathBeam.SetLocalOrigin(Trace.endpos)
			}
			else
			{
				hPathBeam = SpawnEntityFromTableSafe("env_beam", {
					lightningstart = "bignet"
					lightningend   = "bignet"
					boltwidth      = 1
					texture        = "sprites/laserbeam.vmt"
					rendercolor    = "50 50 50"
					spawnflags     = 1
				})
				SetPropEntityArray(hPathBeam, "m_hAttachEntity", hPathBeam, 0)
				SetPropEntityArray(hPathBeam, "m_hAttachEntity", hPathVisual, 1)
			}

			if(ExistsInScope(this, "hPathHatchVisual"))
			{
				if(PathArray.len() > 0)
				{
					local vecLastPath   = PathArray.top()[0]
					local vecHatch      = FindByClassname(null, "func_capturezone").GetCenter()
					local vecLastPathXY = Vector(vecLastPath.x, vecLastPath.y, 0)
					local vecHatchXY    = Vector(vecHatch.x, vecHatch.y, 0)
					local vecDirection  = vecLastPathXY - vecHatchXY
					vecDirection.Norm()
					hPathHatchVisual.SetAbsOrigin(Vector(vecHatch.x, vecHatch.y, vecTarget.z) + vecDirection * 176)
					hPathHatchVisual.SetForwardVector(vecDirection * -1)
				}
			}
			else
				hPathHatchVisual = SpawnEntityFromTableSafe("prop_dynamic", {
					model          = "models/editor/cone_helper.mdl"
					rendercolor    = "255 0 255"
					disableshadows = 1
				})

			if(ExistsInScope(this, "hPathTrackVisual"))
			{
				if(hNearestPathTrack)
				{
					local vecPathTrack     = hNearestPathTrack.GetOrigin()
					local vecPathTrackNext = GetPropEntity(hNearestPathTrack, "m_pnext")
					local vecDirection     = vecPathTrackNext ? GetPropEntity(hNearestPathTrack, "m_pnext").GetOrigin() - vecPathTrack : Vector(0, 0, -1)
					vecDirection.Norm()
					hPathTrackVisual.SetAbsOrigin(vecPathTrack)
					hPathTrackVisual.SetForwardVector(vecDirection)
					EntFireByHandle(hPathTrackVisual.FirstMoveChild(), "SetText", hNearestPathTrack.GetName(), -1, null, null)
				}
			}
			else
			{
				hPathTrackVisual = SpawnEntityFromTableSafe("prop_dynamic", {
					model          = "models/editor/cone_helper.mdl"
					disableshadows = 1
				})
				local hWorldText = SpawnEntityFromTableSafe("point_worldtext", {
					origin      = Vector(0, 0, 12)
					color       = "0 255 255 255"
					font        = 3
					orientation = 1
					textsize    = 6
				})
				TankExt.SetParentArray([hWorldText], hPathTrackVisual)
			}

			if(ExistsInScope(this, "hGlow"))
				SetPropEntity(hGlow, "m_hTarget", hLastPath)
			else
				hGlow = SpawnEntityFromTableSafe("tf_glow", {
					glowcolor  = "255 255 0 255"
					target     = "bignet"
				})

			local flTime = Time()
			if(flTime >= flTimeNext)
			{
				flTimeNext = flTime + 0.5
				local PathArrayMax = PathArray.len() - 1
				foreach(i, array in PathArray)
				{
					if(i == PathArrayMax) break
					local hPathNext = PathArray[i + 1][1]
					local vecDirection = hPathNext.GetOrigin() - array[0]
					vecDirection.Norm()
					local hParticle = SpawnEntityFromTableSafe("info_particle_system", {
						origin       = array[0]
						effect_name  = "spell_lightningball_hit_zap_blue"
						start_active = 1
					})
					hParticle.SetForwardVector(vecDirection)
					SetPropEntityArray(hParticle, "m_hControlPointEnts", hPathNext, 0)
					EntFireByHandle(hParticle, "Kill", null, 0.066, null, null)
				}
			}

			return -1
		}
		TankExt.AddThinkToEnt(hPlayer, "PathMakerThink")
	}
	function AddThinkToEnt(hEntity, sFunction)
	{
		local AddThink = @(ent, func) "_AddThinkToEnt" in ROOT ? ROOT._AddThinkToEnt(ent, func) : ROOT.AddThinkToEnt(ent, func)
		if(hEntity.GetClassname() == "tank_boss")
		{
			local hTank = hEntity
			hTank.ValidateScriptScope()
			local hTank_scope = hTank.GetScriptScope()
			if(!("MultiThink" in hTank_scope))
			{
				hTank_scope.ThinkTable <- {}
				hTank_scope.MultiThink <- function()
				{
					foreach(sName, func in ThinkTable)
						func()
					return -1
				}
				AddThink(hTank, "MultiThink")
			}

			if(sFunction == null)
				{ hTank_scope.ThinkTable.clear(); return }

			local Function
			if(sFunction in hTank_scope)
				Function = hTank_scope[sFunction]
			else if(sFunction in ROOT)
				Function = ROOT[sFunction]

			hTank_scope.ThinkTable[sFunction] <- Function.bindenv(hTank_scope)
		}
		else
			AddThink(hEntity, sFunction)
	}
	function PrecacheSound(sSound)
	{
		if(endswith(sSound, ".wav") || endswith(sSound, ".mp3"))
			ROOT.PrecacheSound(sSound)
		else
			ROOT.PrecacheScriptSound(sSound)
	}
	function SpawnEntityFromTableFast(sClassname, Table)
	{
		local hEnt = CreateByClassnameSafe(sClassname)
		foreach(sKey, Value in Table)
			switch(typeof Value)
			{
				case "string"  : hEnt.KeyValueFromString(sKey, Value); break
				case "QAngle"  : hEnt.KeyValueFromString(sKey, format("%f %f %f", Value.x, Value.y, Value.z)); break
				case "Vector"  : hEnt.KeyValueFromVector(sKey, Value); break
				case "float"   : hEnt.KeyValueFromFloat(sKey, Value); break
				case "integer" : hEnt.KeyValueFromInt(sKey, Value); break
				case "bool"    : hEnt.KeyValueFromInt(sKey, Value ? 1 : 0); break
			}
		hEnt.DispatchSpawn()
		return hEnt
	}

	DefaultTankIconsLast = 0
	function ThinkEntEndOfTick()
	{
		local iDestroyedTanks    = 0
		local iTankIconDecrement = 0
		foreach(hTank, ReturnIconArray in ActiveTanks)
			if(!hTank.IsValid())
			{
				delete ActiveTanks[hTank]

				iDestroyedTanks++
				if(!ReturnIconArray) // this tank has no custom icon
				{
					iTankIconDecrement++
					continue
				}

				local IconArray = ReturnIconArray()
				if(!(IconArray && IconArray[0] > 0)) continue
				IconArray[0]--
				local sTankIcon = IconArray[1]
				IterateIcons(function(iIcon, sNames, sCounts, sFlags)
				{
					local sIconName = GetPropStringArray(hObjectiveResource, sNames, iIcon)
					if(sIconName == sTankIcon)
						SetPropIntArray(hObjectiveResource, sCounts, GetPropIntArray(hObjectiveResource, sCounts, iIcon) - 1, iIcon)
				})
			}

		IterateIcons(function(iIcon, sNames, sCounts, sFlags)
		{
			if(GetPropStringArray(hObjectiveResource, sNames, iIcon) == "tank")
			{
				local iCount          = GetPropIntArray(hObjectiveResource, sCounts, iIcon)
				local iPredictedCount = DefaultTankIconsLast - iDestroyedTanks
				if(iPredictedCount < 0)
					iPredictedCount = 0
				if(iCount != iPredictedCount)
					DefaultTankIconsLast = iCount
				else
				{
					local DefaultTankIcons = DefaultTankIconsLast - iTankIconDecrement
					if(DefaultTankIcons < 0) DefaultTankIcons = 0
					SetPropIntArray(hObjectiveResource, sCounts, DefaultTankIcons, iIcon)
					DefaultTankIconsLast = DefaultTankIcons
				}
				return true
			}
		})
	}
}
__CollectGameEventCallbacks(TankExt)

// replace the packed version of the script if it exists and move the tank types over
if("TankExtPacked" in ROOT)
{
	if(TankExtPacked.hThinkEnt.IsValid()) TankExtPacked.hThinkEnt.Kill()

	foreach(k, v in TankExtPacked.TankScripts)
		TankExt.TankScripts[k] <- v
	foreach(k, v in TankExtPacked.TankScriptsWild)
		TankExt.TankScriptsWild[k] <- v

	TankExtPacked = TankExt
}

for(local i = 1; i <= MAX_CLIENTS; i++)
{
	local hPlayer = PlayerInstanceFromIndex(i)
	if(hPlayer)
		TankExt.PlayerArray.append(hPlayer)
}

local hThinkEnt = CreateByClassnameSafe("logic_relay")
hThinkEnt.ValidateScriptScope()
local hThinkEnt_scope = hThinkEnt.GetScriptScope()
hThinkEnt_scope.Think <- function()
{
	EntFireByHandle(self, "RunScriptCode", "TankExt.ThinkEntEndOfTick()", -1, null, null) // not using SetDestroyCallback to avoid conflicts
	return -1
}
TankExt.AddThinkToEnt(hThinkEnt, "Think")
TankExt.hThinkEnt = hThinkEnt

SetPropString(hThinkEnt, "m_iClassname", "tank_boss") // this makes teamplay_broadcast_audio always get called when a tank spawns

local TankExtLegacy = {
	TankScriptsLegacy = {}
	TankScriptsWildLegacy = {}
	function StartingPathNames(PathArray)
	{
	}
	function NewTankScript(sName, Table)
	{
		sName = sName.tolower()
		local bWild = sName[sName.len() - 1] == '*'
		if(bWild)
		{
			sName = sName.slice(0, sName.len() - 1)
			TankExt.TankScriptsWildLegacy[sName] <- Table
		}
		else
			TankExt.TankScriptsLegacy[sName] <- Table
	}
	function RunTankScript(hTank)
	{
		if(hTank.GetEFlags() & EFL_NO_MEGAPHYSCANNON_RAGDOLL || hTank.GetClassname() != "tank_boss") return
		local hPath = caller
		local sTankName = hTank.GetName().tolower()
		hTank.ValidateScriptScope()
		hTank.SetEFlags(EFL_NO_MEGAPHYSCANNON_RAGDOLL)
		SetPropBool(hTank, "m_bForcePurgeFixedupStrings", true)

		local TankTable

		if(sTankName in TankExt.TankScriptsLegacy)
			TankTable = TankExt.TankScriptsLegacy[sTankName]
		else
			foreach(sName, Table in TankExt.TankScriptsWildLegacy)
				if(startswith(sTankName, sName))
					{
						TankTable = Table
						hTank.KeyValueFromString("targetname", sName)
						break
					}

		if(TankTable)
		{
			local hTank_scope = hTank.GetScriptScope()
			if("Model" in TankTable)
			{
				if(typeof TankTable.Model == "string")
					TankTable.Model = { Default = TankTable.Model }
				TankExt.SetTankModel(hTank, {
					Tank = TankTable.Model.Default
					LeftTrack = "LeftTrack" in TankTable.Model ? TankTable.Model.LeftTrack : null
					RightTrack = "RightTrack" in TankTable.Model ? TankTable.Model.RightTrack : null
					Bomb = "Bomb" in TankTable.Model ? TankTable.Model.Bomb : null
				})

				if(!("Damage1" in TankTable.Model))
					TankTable.Model.Damage1 <- TankTable.Model.Default
				if(!("Damage2" in TankTable.Model))
					TankTable.Model.Damage2 <- TankTable.Model.Damage1
				if(!("Damage3" in TankTable.Model))
					TankTable.Model.Damage3 <- TankTable.Model.Damage2

				hTank_scope.sModelLast <- hTank.GetModelName()
				hTank_scope.CustomModelThink <- function()
				{
					local sModel = self.GetModelName()
					if(sModel != sModelLast)
					{
						local sNewModel = sModel

						if(sModel.find("damage1"))
							sNewModel = TankTable.Model.Damage1
						else if(sModel.find("damage2"))
							sNewModel = TankTable.Model.Damage2
						else if(sModel.find("damage3"))
							sNewModel = TankTable.Model.Damage3
						else
							sNewModel = TankTable.Model.Default

						TankExt.SetTankModel(hTank, { Tank = sNewModel })
						sModel = sNewModel
					}
					sModelLast = sModel
				}
				TankExt.AddThinkToEnt(hTank, "CustomModelThink")
			}

			local DisableModels = function(iFlags)
			{
				for(local hChild = hTank.FirstMoveChild(); hChild != null; hChild = hChild.NextMovePeer())
				{
					local sChildModel = hChild.GetModelName().tolower()
					if((sChildModel.find("track_") && iFlags & 1) || (sChildModel.find("bomb_mechanism") && iFlags & 2))
						hChild.DisableDraw()
				}
			}

			if("DisableChildModels" in TankTable && TankTable.DisableChildModels == 1)
				DisableModels(3)

			if("DisableTracks" in TankTable && TankTable.DisableTracks == 1)
				DisableModels(1)

			if("DisableBomb" in TankTable && TankTable.DisableBomb == 1)
				DisableModels(2)

			if("Color" in TankTable)
				hTank.AcceptInput("Color", TankTable.Color, null, null)

			if("TeamNum" in TankTable)
			{
				hTank.SetTeam(TankTable.TeamNum)
				EntFireByHandle(hTank, "RunScriptCode", "SetPropBool(self, `m_bGlowEnabled`, true)", 0.066, null, null)
			}

			if("DisableOutline" in TankTable && TankTable.DisableOutline == 1)
			{
				SetPropBool(hTank, "m_bGlowEnabled", false)
				EntFireByHandle(hTank, "RunScriptCode", "SetPropBool(self, `m_bGlowEnabled`, false)", 0.066, null, null)
			}

			if("DisableSmokestack" in TankTable && TankTable.DisableSmokestack == 1)
			{
				hTank_scope.DisableSmokestack <- function()	{ hTank.AcceptInput("DispatchEffect", "ParticleEffectStop", null, null)	}
				TankExt.AddThinkToEnt(hTank, "DisableSmokestack")
			}

			if("OnSpawn" in TankTable)
				TankTable.OnSpawn(hTank, sTankName, hPath)

			if("OnDeath" in TankTable)
				TankExt.SetDestroyCallback(hTank, TankTable.OnDeath)
		}
	}
}
foreach(k,v in TankExtLegacy)
	if(!(k in TankExt))
		TankExt[k] <- v