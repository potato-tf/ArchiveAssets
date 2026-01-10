EntFire("bot_hint_sentrygun", "Disable")
EntFire("bot_hint_engineer_nest", "Disable")
//several of these nests are intentionally doubled from regular to prevent races

sentrygun <- {
	nest_alt_1 = {
		origin = [Vector(-7990, 5568, 896), Vector(-7824, 4695, 960)],
		angles = [QAngle(0, 135, 0), QAngle(0, 195, 0)]
	}
	nest_alt_2 = {
		origin = [Vector(-9811, 4115, 896), Vector(-8935, 4208, 896)],
		angles = [QAngle(0, 135, 0), QAngle(0, 90, 0)]
	}
	nest_alt_3 = {
		origin = [Vector(-9740, 3290, 832), Vector(-9888, 2784, 704)],
		angles = [QAngle(0, 195, 0), QAngle(0, 195, 0)]
	}
	nest_alt_4 = {
		origin = [Vector(-7888, 3344, 832), Vector(-7627, 3928, 960)],
		angles = [QAngle(0, 240, 0), QAngle(0, 240, 0)]
	}
	nest_alt_5 = {
		origin = [Vector(-9417, 3340, 1472), Vector(-9712, 2575, 1472)],
		angles = [QAngle(0, 15, 0), QAngle(0, 120, 0)]
	}
	nest_alt_6 = {
		origin = [Vector(-8464, 4288, 1408), Vector(-9440, 4352, 1536)]
		angles = [QAngle(0, 120, 0), QAngle(0, 120, 0)]
	}
	nest_alt_7 = {
		origin = [Vector(-7928, 4212, 1474), Vector(-7594, 5664, 1472)]
		angles = [QAngle(0, 120, 0), QAngle(0, 120, 0)]
	}
}

foreach(name, vals in sentrygun) {
	local count = vals.len()
	local originArray = vals.origin
	local anglesArray = vals.angles
	
	for(local i = 0; i < count; i++) {
		local table = {
			targetname = name + "_" + i
			startdisabled = true
			origin = originArray[i]
			angles = anglesArray[i]
			teamnum = TF_TEAM_BLUE
		}

		SpawnEntityFromTable("bot_hint_sentrygun", table)
		SpawnEntityFromTable("bot_hint_engineer_nest", table)
	}
}

SpawnEntityFromTable("filter_tf_bot_has_tag", {
	targetname = "engibotfilter"
	tags = "ws11"
})
local trigger = SpawnEntityFromTable("trigger_multiple", {
	origin = Vector(-9728, -320, 1463) //spawnbot_altmode
	filtername = "engibotfilter"
	spawnflags = 1
	"OnEndTouchAll" : "!caller,callscriptfunction,activateNests,0,-1"
})
trigger.SetSolid(2)
trigger.SetSize(Vector(-256, -256, -16), Vector(256, 256, 16))
trigger.ValidateScriptScope()
trigger.GetScriptScope().activateNests <- function() {
	local altmodeScope = Entities.FindByName(null, "altmode_chaos_script").GetScriptScope()
	if(altmodeScope.getContainmentBreakerState()) { //let them loose if containment breaker
		EntFire("nest_alt_*", "Enable")
	}
	else {
		local room = altmodeScope.getRoom("ws11")
		EntFire("nest_alt_" + room + "*", "Enable")
	}
}