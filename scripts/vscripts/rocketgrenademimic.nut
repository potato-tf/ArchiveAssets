local rockets = {};
local originQueue = [];
local angleQueue = [];
local rocketLauncher = null;
const INTERVAL = 1;

for(local i = 0; i < NetProps.GetPropArraySize(self, "m_hMyWeapons"); i++) {
	local weapon = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i);
	if(weapon == null) continue;
	
	if(weapon.GetClassname() == "tf_weapon_rocketlauncher") {
		rocketLauncher = weapon;
	}
}

function Think() {
	if(NetProps.GetPropInt(self, "m_lifeState") != 0) {
		AddThinkToEnt(self, null);
		NetProps.SetPropString(self, "m_iszScriptThinkFunction", "");
		self.TerminateScriptScope();
	}

	if((Time() - NetProps.GetPropFloat(rocketLauncher, "m_flNextPrimaryAttack")) <= INTERVAL) {
		//if fired in the last second
		local rocket = null;
		while(rocket = Entities.FindByClassnameWithin(rocket, "tf_projectile_rocket", self.GetOrigin(), 2200)) {
			if(rocket.GetOwner() == self && !(rocket in rockets)) {
				rockets[rocket] <- {};
				rockets[rocket].origin <- rocket.GetOrigin();
				rockets[rocket].angles <- rocket.GetAbsAngles();
			}
		}
	}
	
	foreach(rocket, data in rockets) {
		if(!rocket.IsValid()) { //rocket blew up on something and isn't valid anymore
			//ClientPrint(null, 3, "rocket " + data.origin.tostring())
			
			originQueue.append(data.origin);
			angleQueue.append(data.angles);
			
			local mimic = SpawnEntityFromTable("tf_point_weapon_mimic", {
				teamnum = self.GetTeam(),
				["$preventshootparent"] = 1,
				["$weaponname"] = "caber_supernova", //edit here
				angles = angleQueue.remove(0)
			});
			mimic.SetOwner(self);
			mimic.SetAbsOrigin(originQueue.remove(0))
			
			//ClientPrint(null, 3, mimic.GetOrigin().tostring())
			
			mimic.ValidateScriptScope()
			mimic.GetScriptScope().first <- true
			mimic.GetScriptScope().Think <- function() {
				if(first) {
					first = false
				}
				else {
					self.Kill()
				}
				return 5
			}
			EntFireByHandle(mimic, "FireOnce", null, -1, null, null);
			AddThinkToEnt(mimic, "Think")
			
			delete rockets[rocket];
		}
		else { //update data
			rockets[rocket].origin = rocket.GetOrigin();
			rockets[rocket].angles = rocket.GetAbsAngles();
		}
	}
}

AddThinkToEnt(self, "Think");