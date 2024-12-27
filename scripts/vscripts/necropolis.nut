if (!Entities.FindByName(null, "prop_locker_any_1")) {
	return;
}

// James0SSH Made functions and optimisations {
function SpawnHologramProjector(vec) 
{
	SpawnEntityFromTable("prop_dynamic",
	{
	model = "models/props_mvm/hologram_projector.mdl"
	origin = vec
	disableshadows = 1
	})
}

function SpawnRobotHologram(vec_angle, targetname) {
	SpawnEntityFromTable("prop_dynamic",
	{
		targetname = targetname
		model = "models/props_mvm/robot_hologram.mdl"
		origin = vec_angle[0]
		angles = vec_angle[1]
		disableshadows = 1
	})
}

function SpawnNavAvoid(table) {
	Assert(table.targetname, "Target name is null")
	Assert(table.vec3, "Origin is null")
	Assert(table.tags, "Tags is null")
	Assert(table.mins, "Mins is null")
	Assert(table.maxs, "Max is null")

	local nav = SpawnEntityFromTable("func_nav_avoid",
	{
		targetname = table.targetname
		origin = table.vec3
		tags = table.tags
		team = "3"
		start_disabled = "0"
	})
	nav.KeyValueFromInt("solid", 2)
	nav.KeyValueFromString("mins", table.mins)
	nav.KeyValueFromString("maxs", table.maxs)
}
// }

EntFire("entity_spawn_point","Kill")
EntFire("tf_pumpkin_bomb","Kill")
EntFire("func_respawnflag","Disable")
EntFire("func_regenerate","Kill")
EntFire("prop_locker_any_1","Kill")
// #region Projectors
foreach(vec in [
	Vector(4800, -2032, 553),
	Vector(4240, -1992, 619),
	Vector(3368, -2688, 597),
	Vector(2800, -2888, 465),
	Vector(2136, -2800, 271),
	Vector(3642, -2028, 611),
	Vector(2918, -1772, 419),
	Vector(2211, -1536, 288),
	Vector(1875, -2358, 257),
	Vector(3304, -3280, 582),
	Vector(2712, -3653, 448),
	Vector(1993, -3833, 247),
	Vector(1764, -3208, 202)
])
{
	//printl("Spawning Projector")
	SpawnHologramProjector(vec)
}
// #endregion
// #region Arrows
// #region Left Path
//printl("Spawning Left Holograms")
foreach(tuple in [
	[
		Vector(4800, -2032, 553),
		QAngle(0, 180, 0)
	],
	[
		Vector(4240, -1992, 619),
		QAngle(0, 180, 0)
	],
	[
		Vector(3642, -2028, 611),
		QAngle(0, 165, 0)
	],
	[
		Vector(2918, -1772, 419),
		QAngle(0, 165, 0)	
	],
    [
        Vector(2211, -1536, 288),
        QAngle(0, 250, 0)
    ],
    [
        Vector(1875, -2358, 257),
        QAngle(0, 230, 0)
    ]
])
{
    
	SpawnRobotHologram(tuple, "holograms_left")
}
// #endregion
// #region Middle Path
//printl("Spawning Middle Holograms")
foreach(tuple in [
    [
        Vector(4800, -2032, 553),
        QAngle(0, 180, 0)
    ],
    [
        Vector(4240, -1992, 619),
        QAngle(0, 180, 0)
    ],
    [
        Vector(3642, -2028, 611),
        QAngle(0, -125, 0)
    ],
    [
        Vector(3368, -2688, 597),
        QAngle(0, 210, 0)
    ],
    [
        Vector(2800, -2888, 465),
        QAngle(0, 165, 0)
    ],
    [
        Vector(2136, -2800, 271),
        QAngle(0, 190, 0)
    ]
])
{
    SpawnRobotHologram(tuple, "holograms_mid")
}
// #endregion
// #region Right Path
foreach(tuple in [
    [
        Vector(4800, -2032, 553),
        QAngle(0, 180, 0)
    ],
    [
        Vector(4240, -1992, 619),
		QAngle(0, 180, 0)
    ],
    [
        Vector(3642, -2028, 611),
		QAngle(0, -125, 0)
    ],
    [
        Vector(3368, -2688, 597),
		QAngle(0, -98, 0)
    ],
    [
        Vector(3304, -3280, 582),
		QAngle(0, -148, 0)
    ],
    [
        Vector(2712, -3653, 448),
		QAngle(0, -166, 0)
    ],
    [
        Vector(1993, -3833, 247),
        QAngle(0, 112, 0)
    ],
	[
        Vector(1764, -3208, 202),
        QAngle(0, 135, 0)
    ]
])
{
    SpawnRobotHologram(tuple, "holograms_right")
}
// #endregion
// #endregion
EntFire("wave_start_relay","AddOutput","OnTrigger holograms_*:disable")
// #region Nav Avoids
foreach(navavoid in [
	{
		targetname = "nav_left"
		vec3 = Vector(2304, -1792, 512)
		tags = "common bomb_carrier",
		mins = "-768 -384 -512",
		maxs = "768 768 512"
	},
	{
		targetname = "nav_mid"
		vec3 = Vector(2560, -2816, 512)
		tags = "common bomb_carrier"
		mins = "-512 -512 -512"
		maxs = "512 512 512"
	},
	{
		targetname = "nav_right"
		vec3 = Vector(2560, -3584, 512)
		tags = "common bomb_carrier"
		mins = "-512 -512 -512"
		maxs = "1024 512 512"
	},
	{
		targetname = ""
		vec3 = Vector(3968, -3584, 512)
		tags = "common bomb_carrier giant"
		mins = "-384 -256 -512"
		maxs = "384 256 512"
	},
	{
		targetname = ""
		vec3 = Vector(5872, -2928, 384)
		tags = "common bomb_carrier giant"
		mins = "-48 -496 -64"
		maxs = "48 496 64"
	},
	{
		targetname = ""
		vec3 = Vector(3888, -1120, 624)
		tags = "bomb_carrier giant"
		mins = "-688 -480 -80"
		maxs = "688 480 80"
	},
	{
		targetname = ""
		vec3 = Vector(5632, -1120, 384)
		tags = "common bomb_carrier giant"
		mins = "-256 -352 -64"
		maxs = "256 352 64"
	},
	{
		targetname = ""
		vec3 = Vector(4032, -2368, 624)
		tags = "common bomb_carrier giant"
		mins = "-224 -64 -16"
		maxs = "224 64 64"
	},
	{
		targetname = ""
		vec3 = Vector(5488, -2016, 352)
		tags = "common bomb_carrier giant"
		mins = "-400 -192 -160"
		maxs = "400 192 160"
	},
	{
		targetname = ""
		vec3 = Vector(4560, -3424, 624)
		tags = "bomb_carrier giant"
		mins = "-320 -288 -48"
		maxs = "40 960 128"
	},
	{
		targetname = ""
		vec3 = Vector(4848, -2992, 560)
		tags = "common bomb_carrier giant"
		mins = "-48 -560 -48"
		maxs = "48 560 48"
	},
	{
		targetname = ""
		vec3 = Vector(5568, -2720, 384)
		tags = "common bomb_carrier giant"
		mins = "-64 -288 -64"
		maxs = "64 288 64"
	}
])
{
	SpawnNavAvoid(navavoid)
}
// #endregion
// #region Logic relay
SpawnEntityFromTable("logic_relay",
{
	targetname = "path_left_relay"
	"OnTrigger": "holograms_left,Enable"
	"OnTrigger#2": "holograms_right,Disable"
	"OnTrigger#3": "holograms_mid,Disable"
	"OnTrigger#4": "nav_left,Disable"
	"OnTrigger#5": "nav_right,Enable"
	"OnTrigger#6": "nav_mid,Enable"
})

SpawnEntityFromTable("logic_relay",
{
	targetname = "path_right_relay"
	"OnTrigger": "holograms_left,Disable"
	"OnTrigger#2": "holograms_right,Enable"
	"OnTrigger#3": "holograms_mid,Disable"
	"OnTrigger#4": "nav_left,Enable"
	"OnTrigger#5": "nav_right,Disable"
	"OnTrigger#6": "nav_mid,Enable"
})

SpawnEntityFromTable("logic_relay",
{
	targetname = "path_mid_relay"
	"OnTrigger": "holograms_left,Disable"
	"OnTrigger#2": "holograms_right,Disable"
	"OnTrigger#3": "holograms_mid,Enable"
	"OnTrigger#4": "nav_left,Enable"
	"OnTrigger#5": "nav_right,Enable"
	"OnTrigger#6": "nav_mid,Disable"
})

SpawnEntityFromTable("logic_relay",
{
	targetname = "path_random_relay"
	"OnTrigger": "path_random_relay_c,PickRandom"
})
// #endregion
SpawnEntityFromTable("logic_case",
{
	targetname = "path_random_relay_c"
	"OnCase01": "path_left_relay,Trigger"
	"OnCase02": "path_right_relay,Trigger"
	"OnCase03": "path_mid_relay,Trigger"
})

//Nobuilds
//Left tank spawn
local nobuild=SpawnEntityFromTable("func_nobuild",
{
	origin = Vector(5600, -1600, 736)
})
nobuild.KeyValueFromInt("solid", 2)
nobuild.KeyValueFromString("mins", "-224 -192 -96")
nobuild.KeyValueFromString("maxs", "224 192 96")
//Right tank spawn
local nobuild=SpawnEntityFromTable("func_nobuild",
{
	origin = Vector(5313, -3392, 736)
})
nobuild.KeyValueFromInt("solid", 2)
nobuild.KeyValueFromString("mins", "-192 -256 -96")
nobuild.KeyValueFromString("maxs", "192 256 96")
//Front fences
local nobuild=SpawnEntityFromTable("func_nobuild",
{
	origin = Vector(4560, -2168, 744)
})
nobuild.KeyValueFromInt("solid", 2)
nobuild.KeyValueFromString("mins", "-32 -1000 -40")
nobuild.KeyValueFromString("maxs", "32 1000 40")
//Left of front shack
local nobuild=SpawnEntityFromTable("func_nobuild",
{
	origin = Vector(3856, -1128, 814)
})
nobuild.KeyValueFromInt("solid", 2)
nobuild.KeyValueFromString("mins", "-128 -184 -50")
nobuild.KeyValueFromString("maxs", "128 184 50")
//Tires next to shack
local nobuild=SpawnEntityFromTable("func_nobuild",
{
	origin = Vector(4184, -1536, 736)
})
nobuild.KeyValueFromInt("solid", 2)
nobuild.KeyValueFromString("mins", "-88 -64 -96")
nobuild.KeyValueFromString("maxs", "88 64 96")

local forcefield=SpawnEntityFromTable("trigger_push",
{
	targetname = "push"
	origin = "7050 -2560 814.85"
	spawnflags = "1"
	pushdir = "0 270 0"
	speed = 200
})
forcefield.KeyValueFromInt("solid", 2)
forcefield.KeyValueFromString("mins", "-82 -24 -123")
forcefield.KeyValueFromString("maxs", "82 24 123")

SpawnEntityFromTable("info_particle_system",
{
	origin = Vector(3968, -2516, 1636)
	targetname = "bats"
	effect_name = "hwn_bats01"
	start_active = "0"
})
SpawnEntityFromTable("ambient_generic",
{
	origin = Vector(3968, -2516, 1636)
	targetname = "bell"
	message = "misc/halloween/strongman_bell_01.wav"
	health = 8
	pitch = 60
	pitchstart = 60
	radius = 9999
	spawnflags = "33"
})
SpawnEntityFromTable("ambient_generic",
{
	origin = Vector(3968, -2516, 1636)
	targetname = "scream"
	message = "ambient/halloween/male_scream_14.wav"
	health = 10
	pitch = 70
	pitchstart = 70
	radius = 9999
	spawnflags = "33"
})
SpawnEntityFromTable("ambient_generic",
{
	origin = Vector(3968, -2516, 1636)
	targetname = "scream2"
	message = "ambient/creatures/town_zombie_call1.wav"
	health = 10
	pitch = 100
	pitchstart = 100
	radius = 9999
	spawnflags = "33"
})
local shaker = SpawnEntityFromTable("env_shake",
{
	origin = Vector(3968, -2516, 1636)
	targetname = "shake"
	spawnflags = "5"
	amplitude = 8
	duration = 2.5
	frequency = 2.5
})
shaker.DispatchSpawn()

//Ammo and health packs
//Hatch
SpawnEntityFromTable("item_ammopack_medium",
{
	origin = Vector(768, -2448, 255)
})
SpawnEntityFromTable("item_ammopack_medium",
{
	origin = Vector(752, -3328, 255)
	//powerup_model = "models/props_halloween/halloween_medkit_medium.mdl"
})
SpawnEntityFromTable("item_ammopack_full",
{
	origin = Vector(1384, -3256, 191)
})
//SpawnEntityFromTable("item_healthkit_small",
//{
//	origin = Vector(1416, -3288, 202)
//	powerup_model = "models/props_halloween/halloween_medkit_small.mdl"
//})
SpawnEntityFromTable("item_ammopack_full",
{
	origin = Vector(320, -1656, 319)
})
SpawnEntityFromTable("item_healthkit_medium",
{
	origin = Vector(368, -1656, 319)
	powerup_model = "models/props_halloween/halloween_medkit_medium.mdl"
})
SpawnEntityFromTable("item_ammopack_full",
{
	origin = Vector(576, -3544, 384)
})
SpawnEntityFromTable("item_healthkit_medium",
{
	origin = Vector(624, -3544, 384)
	powerup_model = "models/props_halloween/halloween_medkit_medium.mdl"
})
SpawnEntityFromTable("item_ammopack_medium",
{
	origin = Vector(1272, -1936, 320)
})
SpawnEntityFromTable("item_healthkit_small",
{
	origin = Vector(1320, -1936, 320)
	powerup_model = "models/props_halloween/halloween_medkit_small.mdl"
})
//Right path
SpawnEntityFromTable("item_ammopack_medium",
{
	origin = Vector(2280, -3144, 432)
})
SpawnEntityFromTable("item_healthkit_medium",
{
	origin = Vector(2224, -3144, 434)
	powerup_model = "models/props_halloween/halloween_medkit_medium.mdl"
})
SpawnEntityFromTable("item_ammopack_full",
{
	origin = Vector(2748, -2132, 379)
})
for ( local ent; ent = Entities.FindByClassname(ent, "item_ammopack_small"); )
{
    local hammerid = NetProps.GetPropInt(ent, "m_iHammerID")
    if( hammerid == 316254 )
	{
		ent.Kill()
	}
}
SpawnEntityFromTable("item_healthkit_medium",
{
	origin = Vector(2700, -2108, 377)
	powerup_model = "models/props_halloween/halloween_medkit_medium.mdl"
})
for ( local ent; ent = Entities.FindByClassname(ent, "item_healthkit_small"); )
{
    local hammerid = NetProps.GetPropInt(ent, "m_iHammerID")
    if( hammerid == 316258 )
	{
		ent.Kill()
	}
}

//Fix some spots in blue spawn that don't have blue spawn attribute
NavMesh.GetNavAreaByID(9004).SetAttributeTF(4)
NavMesh.GetNavAreaByID(10069).SetAttributeTF(4)
NavMesh.GetNavAreaByID(111).SetAttributeTF(4)
NavMesh.GetNavAreaByID(1231).SetAttributeTF(4)
NavMesh.GetNavAreaByID(8451).SetAttributeTF(4)
NavMesh.GetNavAreaByID(8452).SetAttributeTF(4)
NavMesh.GetNavAreaByID(2609).SetAttributeTF(4)
NavMesh.GetNavAreaByID(5470).SetAttributeTF(4)
NavMesh.GetNavAreaByID(8453).SetAttributeTF(4)

//This should teleport bomb back up if it gets stuck in the underworld
//Whurr edited the nav after I made this so hopefully this shouldn't happen anyway but I'm keeping it just in case
//TODO : CHECK IF BOMB IS OVER A NAV SQUARE AND IF NOT THEN TP IT TO NEAREST NAV SQUARE
::PostDeath <- function()
{
	local bomb = Entities.FindByClassnameWithin(null,"item_teamflag",Vector(1741.615601, -1518.150757, -6330.281250),3000) //Is bomb in the underworld?
	if (bomb != null){
		bomb.SetOrigin(self.GetOrigin()) //Set bomb origin to temp entity origin
	}
	local bomb2 = Entities.FindByClassname(null,"item_teamflag")
	if (!NavMesh.GetNavArea(bomb2.GetOrigin(),9999)){
		printl(" ")
	}
	self.Kill() //Remove temp entity after we done
}
function OnGameEvent_player_death(params)
{
	local player = GetPlayerFromUserID(params.userid)
	if(NetProps.GetPropBool(player,"m_bIsABot")) //Did a bot die?
	{
		if(player.HasItem()) //Does bot that died have bomb?
		{
			//Spawn a temp entity where the bot died
			local playerorigin2 = SpawnEntityFromTable("info_target",
			{
				origin = player.GetOrigin()
			})
			EntFireByHandle(playerorigin2, "CallScriptFunction", "PostDeath", 0, null, null) //Use entfire to delay by a tick so we can grab proper bomb position
		}
	}
}

//Side spawns are on displacements so this is to stop bots getting stuck and spamming console
function OnGameEvent_player_spawn(params)
{
	if(params.team == 3) //Is the player blue
	{
		local player = GetPlayerFromUserID(params.userid)
		player.SetOrigin(player.GetOrigin()+Vector(0,0,16)) //Teleport player 16 units up
	}
}
__CollectGameEventCallbacks(this)

//Trigger to stop players getting stuck in ground on left path
local antistuck=SpawnEntityFromTable("trigger_multiple",
{
	origin = Vector(2032, -1944, 264)
	spawnflags = "1"
})
antistuck.KeyValueFromInt("solid", 2)
antistuck.KeyValueFromString("mins", "-16 -16 -4")
antistuck.KeyValueFromString("maxs", "16 16 5")
EntityOutputs.AddOutput(antistuck,"OnStartTouchAll","!activator","RunScriptCode","self.SetOrigin(self.GetOrigin()+Vector(0,0,16))",0,-1)

