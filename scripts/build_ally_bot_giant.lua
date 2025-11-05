--Originally made by royal, modified by therealscroob/crilly
--I have only edited the templates, copy-pasted a function 4 times,and added a gross if statement brick.

local PlayersWithCallbacks = {}

local BOTS_VARIANTS = { --duplicate or redundant templates are here as parking space for variants once the script is functional
	soldier = {
		Display = "Giant Soldier",
		Class = "Soldier",
		Model = "models/bots/soldier_boss/bot_soldier_boss.mdl",
		Scale = 1.75,

		-- I don't know what this line does, and I am too afraid to get rid of it
		MaxClip = 4,
		
		HealthIncrease = 1600,

		MiniBoss = true,		

		DefaultAttributes = {
			["move speed bonus"] = 0.6, --persumably faster than an actual gsoldier for convenience
			["damage force reduction"] = 0.4,
			["airblast vulnerability multiplier"] = 0.4,
			["override footstep sound set"] = 3,			
			["cannot taunt"] = 1,
			["cannot pick up intelligence"] = 1,
			["health from healers increased"] = 3,
		},

		Tiers = {
			[1] = {
				Display = "Giant Soldier",
				Class = "Soldier",
				Model = "models/bots/soldier_boss/bot_soldier_boss.mdl",
				Scale = 1.75,
				Items = {"Upgradeable TF_WEAPON_ROCKETLAUNCHER"},
				
				HealthIncrease = 1600,

				MiniBoss = true,

				Attributes = {
					["move speed bonus"] = 0.6,
					["damage force reduction"] = 0.4,
					["airblast vulnerability multiplier"] = 0.4,
					["override footstep sound set"] = 3,
					["cannot pick up intelligence"] = 1,
					["health from healers increased"] = 3,
				},
			},	
			[2] = {
				Display = "Giant Burst Soldier",
				Class = "Soldier",
				Model = "models/bots/soldier_boss/bot_soldier_boss.mdl",
				Scale = 1.75,
				Items = {"Upgradeable TF_WEAPON_ROCKETLAUNCHER"},

				HealthIncrease = 1600,

				MiniBoss = true,
				HoldFireUntilFullReload = true,

				Attributes = {
					["faster reload rate"] = 0.6,
					["fire rate bonus"] = 0.1,
					["Projectile speed increased"] = 0.65,
					["clip size upgrade atomic"] = 5.0,

					["move speed bonus"] = 0.6,

					["damage force reduction"] = 0.4,
					["airblast vulnerability multiplier"] = 0.4,
					["override footstep sound set"] = 3,
					["cannot pick up intelligence"] = 1,
					["health from healers increased"] = 3,
				},
			},			
			[3] = {
				Display = "Giant Charged Soldier",
				Class = "Soldier",
				Model = "models/bots/soldier_boss/bot_soldier_boss.mdl",
				Scale = 1.75,
				Items = {"Upgradeable TF_WEAPON_ROCKETLAUNCHER", "The Buff Banner"},
				--No original, caused issues when upgrading to the next tier
				Conds = { 37 },
				HealthIncrease = 1600,

				MiniBoss = true,

				Attributes = {
					["damage bonus"] = 1.5,
					["faster reload rate"] = 0.2,
					["fire rate bonus"] = 2,
					["Projectile speed increased"] = 0.5,

					["move speed bonus"] = 0.6,

					["damage force reduction"] = 0.4,
					["airblast vulnerability multiplier"] = 0.4,
					["override footstep sound set"] = 3,
					["cannot pick up intelligence"] = 1,
					["health from healers increased"] = 3,
					["special damage type"] = 2,
				},
			},
			[4] = {
				Display = "Giant Rapid Soldier",
				Class = "Soldier",
				Model = "models/bots/soldier_boss/bot_soldier_boss.mdl",
				Scale = 1.75,

				Items = { "Upgradeable TF_WEAPON_ROCKETLAUNCHER", "The Buff Banner" },

				HealthIncrease = 1600,

				MiniBoss = true,
				SpawnWithFullCharge = true,

				Attributes = {
					["faster reload rate"] = -0.8,
					["fire rate bonus"] = 0.5,

					["move speed bonus"] = 0.6,

					["damage force reduction"] = 0.4,
					["airblast vulnerability multiplier"] = 0.4,
					["override footstep sound set"] = 3,
					["cannot pick up intelligence"] = 1,
					["health from healers increased"] = 3,
					["special damage type"] = 2,
				},
			},
		},
	},
	demo ={
		Display = "Giant Demoman",
		Class = "Demoman",
		Model = "models/bots/demo_boss/bot_demo_boss.mdl",
		Scale = 1.75,
		
		HealthIncrease = 1450,

		MiniBoss = true,
		HoldFireUntilFullReload = true, --remember this being listed as a default attribute, explicitly declare it false when it doesn't need to be here

		DefaultAttributes = {
					["faster reload rate"] = -0.4,
					["fire rate bonus"] = 0.75,
					["move speed bonus"] = 0.62, --slightly increased to compensate for lower health compared to soldiers
					["damage force reduction"] = 0.4,
					["airblast vulnerability multiplier"] = 0.4,
					["override footstep sound set"] = 4,	
					["cannot taunt"] = 1,
					["cannot pick up intelligence"] = 1,
					["health from healers increased"] = 3,
		},
		
		Tiers = {
				[1] = {
				Display = "Giant Demoman",
				Class = "Demoman",
				Model = "models/bots/demo_boss/bot_demo_boss.mdl",
				Scale = 1.75,

				HealthIncrease = 1450,

				MiniBoss = true,
				HoldFireUntilFullReload = true,		

				Attributes = {
					["faster reload rate"] = -0.4,
					["fire rate bonus"] = 0.75,
					["move speed bonus"] = 0.62,

					["damage force reduction"] = 0.2,
					["airblast vulnerability multiplier"] = 0.4,
					["override footstep sound set"] = 4,
					["cannot pick up intelligence"] = 1,
					["cannot taunt"] = 1,
					["health from healers increased"] = 3,
					
				},
			},		
				[2] = {
				Display = "Giant Hybrid Knight",
				Class = "Demoman",
				Model = "models/bots/demo_boss/bot_demo_boss.mdl",
				Scale = 1.75,
				
				Items = {"The Chargin' Targe", "Upgradeable TF_WEAPON_GRENADELAUNCHER"},

				HealthIncrease = 1450,

				MiniBoss = true,
				HoldFireUntilFullReload = true,		

				Attributes = {
					["faster reload rate"] = -0.4,
					["fire rate bonus"] = 0.75,
					["charge impact damage increased"] = 10,
					["move speed bonus"] = 0.64, --slightly from base demo
					["mult charge turn control"] = 3.0, --meant to simulate having the boots
					["charge time increased" ] = 4.0, --it always feels weird when gknights charge like 2 forward feet then give up

					["damage force reduction"] = 0.2,
					["airblast vulnerability multiplier"] = 0.2,
					["override footstep sound set"] = 4,
					["cannot pick up intelligence"] = 1,
					["cannot taunt"] = 1,
					["health from healers increased"] = 3,
					
				},
			},
				[3] = {
				Display = "Giant Rammer Knight",
				Class = "Demoman",
				Model = "models/bots/demo_boss/bot_demo_boss.mdl",
				Scale = 1.75,
				
				Items = {"The Splendid Screen", "Hazard Headgear", "Upgradeable TF_WEAPON_GRENADELAUNCHER"},

				HealthIncrease = 1450,

				MiniBoss = true,
				HoldFireUntilFullReload = true,	

				Attributes = {
					["faster reload rate"] = -0.8, --buffs to ranged damage dealing tool
					["fire rate bonus"] = 0.5, 
					
					["charge impact damage increased"] = 20, --will fuck up giants quite bad, potentially too much
					["move speed bonus"] = 0.64, --slightly from base demo
					["full charge turn control"] = 1.0, --most significant buff when combined with charge damage
					["charge time increased" ] = 4.0, --buffed further to try and give a more visible improvement from tier 1

					["damage force reduction"] = 0.2,
					["airblast vulnerability multiplier"] = 0.2,
					["override footstep sound set"] = 4,
					["cannot pick up intelligence"] = 1,
					["cannot taunt"] = 1,
					["health from healers increased"] = 3,
					["special damage type"] = 2,
					
				},
			},
				[4] = {
				Display = "Giant Burst Knight",
				Class = "Demoman",
				Model = "models/bots/demo_boss/bot_demo_boss.mdl",
				Scale = 1.75,
				
				Items = {"The Splendid Screen", "Hazard Headgear", "The Juggernaut Jacket", "Upgradeable TF_WEAPON_GRENADELAUNCHER"},

				HealthIncrease = 1450,

				MiniBoss = true,
				HoldFireUntilFullReload = true,		

				Attributes = {
					["faster reload rate"] = 0.75,
					["fire rate bonus"] = 0.1, 
					["Projectile speed increased"] = 1.1,
					["clip size upgrade atomic"] = 9.0, --increased from base gburst demo because I can
					["projectile spread angle penalty"] = 5,					
					
					["charge impact damage increased"] = 30, 
					["move speed bonus"] = 0.64,
					["full charge turn control"] = 1.0,
					["charge time increased" ] = 4.0,

					["damage force reduction"] = 0.2,
					["airblast vulnerability multiplier"] = 0.2,
					["override footstep sound set"] = 4,
					["cannot pick up intelligence"] = 1,
					["cannot taunt"] = 1,
					["health from healers increased"] = 3,
					["special damage type"] = 2,
					
				},
			},					
		},
	},
	pyro ={
		Display = "Giant Pyro",
		Class = "Pyro",
		Model = "models/bots/pyro_boss/bot_pyro_boss.mdl",
		Scale = 1.75,
		
		HealthIncrease = 1625,

		MiniBoss = true,

		DefaultAttributes = {
					["move speed bonus"] = 0.62, 
					["damage force reduction"] = 0.4,
					["airblast vulnerability multiplier"] = 0.4,
					["override footstep sound set"] = 6,
					
					["damage bonus"] = 1.5,
					["cannot taunt"] = 1,
					["cannot pick up intelligence"] = 1,
					["health from healers increased"] = 3,
					["airblast disabled"] = 1,
		},
		Tiers = {
			[1] = {
				Display = "Giant Pyro",
				Class = "Pyro",
				Model = "models/bots/pyro_boss/bot_pyro_boss.mdl",
				Scale = 1.75,
				Items ={"Upgradeable TF_WEAPON_FLAMETHROWER"},
					
				
				HealthIncrease = 1625, --Pyros are weak giants, their HP has been increased to compensate while retaining the demo's speed boost

				MiniBoss = true,

				Attributes = {
					["move speed bonus"] = 0.62,
					["damage force reduction"] = 0.4,
					["airblast vulnerability multiplier"] = 0.4,
					["override footstep sound set"] = 6,
					["flame_drag"] = 2,
					["lunchbox adds minicrits"] = 2,
					["cannot pick up intelligence"] = 1,
					["health from healers increased"] = 3,
					["airblast disabled"] = 1,
					
					["damage bonus"] = 1.5,
				},
			},		
			[2] = {
				Display = "Giant Airblast Pyro",
				Class = "Pyro",
				Model = "models/bots/pyro_boss/bot_pyro_boss.mdl",
				Scale = 1.75,
				Items ={"The U-clank-a", "Upgradeable TF_WEAPON_FLAMETHROWER"},
				
				HealthIncrease = 1625, --Pyros are weak giants, their HP has been increased to compensate while retaining the demo's speed boost

				MiniBoss = true,				

				Attributes = {
					["move speed bonus"] = 0.62,
					["damage force reduction"] = 0.4,
					["airblast vulnerability multiplier"] = 0.4,
					["override footstep sound set"] = 6,
					["cannot pick up intelligence"] = 1,
					["flame_drag"] = 2,
					["lunchbox adds minicrits"] = 2,					
					["cannot taunt"] = 1,
					["health from healers increased"] = 3,
					
					["damage bonus"] = 1.5,
					["airblast pushback scale"] = 2.0,
					["mult airblast refire time"] = 1.5,
					["airblast disabled"] = 0,
				},
			},
			[3] = {
				Display = "Giant Fuel Injected Pyro",
				Class = "Pyro",
				Model = "models/bots/pyro_boss/bot_pyro_boss.mdl",
				Scale = 1.75,
				Items ={"The U-clank-a", "Upgradeable TF_WEAPON_FLAMETHROWER", "Jupiter Jetpack", "The Rusty Reaper"},
				
				HealthIncrease = 1625, --No health debuff, unlike real Fuel Injected pyros back on goldpit

				MiniBoss = true,				

				Attributes = {
					["move speed bonus"] = 0.78,
					["damage force reduction"] = 0.4,
					["flame_drag"] = 2,
					["lunchbox adds minicrits"] = 2,					
					["airblast vulnerability multiplier"] = 0.4,
					["override footstep sound set"] = 6,
					["cannot pick up intelligence"] = 1,
					["health from healers increased"] = 3,
					
					["damage bonus"] = 1.75, --raised to make it an even bigger boost over T1
					["airblast pushback scale"] = 2.0,
					["mult airblast refire time"] = 1.25,
					["airblast disabled"] = 0,
					["special damage type"] = 2,
				},
			},
			[4] = {
				Display = "Fury",
				Class = "Pyro",
				Model = "models/bots/pyro_boss/bot_pyro_boss.mdl",
				Scale = 1.75,
				Items ={"The Dragon's Fury", "Jupiter Jetpack", "The Rusty Reaper"},
				
				HealthIncrease = 1625, --no health increase, because the speed and damage got massivley upgraded

				MiniBoss = true,

				Attributes = {
					["move speed bonus"] = 0.78,
					["damage force reduction"] = 0.4,
					["airblast vulnerability multiplier"] = 0.4,
					["override footstep sound set"] = 6,
					["cannot pick up intelligence"] = 1,
					["health from healers increased"] = 3,
					
					["fire rate bonus"] = 0.6, --increased firing speed sampled from Chief Pyro's Revenge, keeping with the theme of T4s using boss weapons
					["faster reload rate"] = 0.6,
					["mult_item_meter_charge_rate"] = 0.6, --repressurization rate
					["damage bonus"] = 1.5,
					["special damage type"] = 2,
				},
			},				
		},
	},
	scout ={
		Display = "Giant Scout",
		Class = "Scout",
		Model = "models/bots/scout_boss/bot_scout_boss.mdl",
		Scale = 1.75,
		
		HealthIncrease = 1075, --Slight health buff compared to a real gscout, so they don't get vaporized immediately after being spawned

		MiniBoss = true,

		DefaultAttributes = {
					["move speed bonus"] = 1,
					["damage force reduction"] = 0.7,
					["airblast vulnerability multiplier"] = 0.7,
					["override footstep sound set"] = 5,
					["cannot taunt"] = 1,
					["cannot pick up intelligence"] = 1,
					["health from healers increased"] = 3,
		},
		
		Tiers = {
			[1] = {
				Display = "Giant Scout",
				Class = "Scout",
				Model = "models/bots/scout_boss/bot_scout_boss.mdl",
				Scale = 1.75,
				Items={"Upgradeable TF_WEAPON_SCATTERGUN"},
				
				HealthIncrease = 1075, --Slight health buff compared to a real gscout, so they don't get vaporized immediately after being spawned

				MiniBoss = true,
				

				Attributes = {
					["move speed bonus"] = 1,
					["damage force reduction"] = 0.7,
					["airblast vulnerability multiplier"] = 0.7,
					["override footstep sound set"] = 5,
					["cannot taunt"] = 1,
					["cannot pick up intelligence"] = 1,
					["health from healers increased"] = 3,
				},
			},
			[2] = {
				Display = "Giant Shortstop Scout",
				Class = "Scout",
				Model = "models/bots/scout_boss/bot_scout_boss.mdl",
				Scale = 1.75,
				Items ={"the shortstop"},

				HealthIncrease = 1175, --Slight buff from previous templates, as a reference to the minigiant shortstop scouts.

				MiniBoss = true,

				Attributes = {
					["move speed bonus"] = 1,
					["damage force reduction"] = 0.7,
					["airblast vulnerability multiplier"] = 0.7,
					["override footstep sound set"] = 5,
					
					["deploy time increased"] = 0.5,
					["effect bar recharge rate increased"] = 0.45,
					["cannot pick up intelligence"] = 1,
					["health from healers increased"] = 3,
				},
			},
			[3] = {
				Display = "Giant Shove-Stop Scout",
				Class = "Scout",
				Model = "models/bots/scout_boss/bot_scout_boss.mdl",
				Scale = 1.75,
				Items ={"the shortstop"},

				HealthIncrease = 1175, --Slight buff from previous templates, as a reference to the minigiant shortstop scouts.

				MiniBoss = true,

				Attributes = {
					["move speed bonus"] = 1,
					["damage force reduction"] = 0.7,
					["airblast vulnerability multiplier"] = 0.7,
					["override footstep sound set"] = 5,
					["cannot pick up intelligence"] = 1,
					
					["deploy time increased"] = 0.5,
					
					["stomp player damage"] = 125,
					["stomp player force"] = 300,
					["stomp player time"] = 2,
					["health from healers increased"] = 3,
					["special damage type"] = 2,
				},
			},
			[4] = {
				Display = "Giant Giga Scout",
				Class = "Scout",
				Model = "models/bots/scout_boss/bot_scout_boss.mdl",
				Scale = 1.75,
				Items ={"the shortstop"},
				Conds = { 37 },

				HealthIncrease = 1175, --Slight buff from previous templates, as a reference to the minigiant shortstop scouts.

				MiniBoss = true,

				Attributes = {
					["move speed bonus"] = 1,
					["damage force reduction"] = 0.7,
					["airblast vulnerability multiplier"] = 0.7,
					["override footstep sound set"] = 5,
					["cannot pick up intelligence"] = 1,
					
					["stomp player damage"] = 200,
					["stomp player force"] = 600,
					["stomp player time"] = 2,
					["special damage type"] = 2,
				},
			},					
		},
	},
	heavy ={
		Display = "Giant Heavy",
		Class = "Soldier", --here because heavies break super hard when they are used as the default class. I don't know why
		Model = "models/bots/heavy_boss/bot_heavy_boss.mdl",
		Scale = 1.75,
		Items = { "Upgradeable TF_WEAPON_MINIGUN"} ,
		
		HealthIncrease = 2000, --significantly nerfed considering that building health upgrades apply to robots
		MiniBoss = true,

		DefaultAttributes = {
					["move speed bonus"] = 0.5,
					["damage force reduction"] = 0.3,
					["airblast vulnerability multiplier"] = 0.3,
					["override footstep sound set"] = 2,
			
					["cannot taunt"] = 1,
					["cannot pick up intelligence"] = 1,
					["health from healers increased"] = 3,
		},
		
		Tiers = {
			[1] = {
				Display = "Giant Heavy",
				Class = "Heavy",
				Model = "models/bots/heavy_boss/bot_heavy_boss.mdl",
				Scale = 1.75,
				Items = { "Upgradeable TF_WEAPON_MINIGUN"} ,

				HealthIncrease = 2000, --significantly nerfed considering that building health upgrades apply to robots
				MiniBoss = true,

				Attributes = {
					["move speed bonus"] = 0.5,
					["damage force reduction"] = 0.3,
					["airblast vulnerability multiplier"] = 0.3,
					["override footstep sound set"] = 2,
					
					["cannot pick up intelligence"] = 1,
					["health from healers increased"] = 3,
					["cannot taunt"] = 1,
				},
			},			
			[2] = {
				Display = "Giant Deflector Heavy",
				Class = "Heavy",
				Model = "models/bots/heavy_boss/bot_heavy_boss.mdl",
				Scale = 1.75,
				Items = { "The u-clank-a", "Deflector"} ,

				HealthIncrease = 2000, --significantly nerfed considering that building health upgrades apply to robots
				MiniBoss = true,

				Attributes = {
					["move speed bonus"] = 0.5,
					["damage force reduction"] = 0.3,
					["airblast vulnerability multiplier"] = 0.3,
					["override footstep sound set"] = 2,
					["cannot pick up intelligence"] = 1,
					["health from healers increased"] = 3,
					["cannot taunt"] = 1,
					
				},
			},
			[3] = {
				Display = "Giant Heater Heavy",
				Class = "Heavy",
				Model = "models/bots/heavy_boss/bot_heavy_boss.mdl",
				Scale = 1.75,
				Items = { "The Bunsen Brave", "The Huo Long Heatmaker"} ,

				HealthIncrease = 2000, --significantly nerfed considering that building health upgrades apply to robots
				MiniBoss = true,

				Attributes = {
					["move speed bonus"] = 0.5,
					["damage force reduction"] = 0.3,
					["airblast vulnerability multiplier"] = 0.3,
					["override footstep sound set"] = 2,
					["cannot pick up intelligence"] = 1,
					["health from healers increased"] = 3,
					["cannot taunt"] = 1,
					["attack projectiles"] = 2,
					["weapon burn time increased"] = 3.0,
					["weapon burn dmg increased"] = 2,					
					
					["damage bonus"] = 1.1,	
					["special damage type"] = 2,
				},
			},			
			[4] = {
				Display = "Giant EMP Heavy",
				Class = "Heavy",
				Model = "models/bots/heavy_boss/bot_heavy_boss.mdl",
				Scale = 1.75, --tokamak added in-popfile
				Items = { "the virtual viewfinder", "Tokamak"},
				Conds = { 37 }, --tokamak has nullified crits

				HealthIncrease = 2000, --significantly nerfed considering that building health upgrades apply to robots
				MiniBoss = true,

				Attributes = {
					["move speed bonus"] = 0.5,
					["damage force reduction"] = 0.3,
					["airblast vulnerability multiplier"] = 0.3,
					["override footstep sound set"] = 2,
					["cannot pick up intelligence"] = 1,
					["health from healers increased"] = 3,
					["cannot taunt"] = 1,
					
					["damage bonus"] = 1.1, --not as high as a real gheavy	
					["special damage type"] = 2,
				},
			},			
		},
	},			
}

local SPEED_BOOST_DISTANCE = 400 -- apply speed boost to bot when it's far away from owner

--defined here for ease of access later

local botType

local BOTS_ATTRIBUTES = {
	-- ["not solid to players"] = 1, -- prevents bot from taking teleporter
	["collect currency on kill"] = 1,
	["ammo regen"] = 10,
	["cannot taunt"] = 1,
}

local BOTS_WRANGLED_ATTRIBUTES = {
	["SET BONUS: move speed set bonus"] = 1.3,
	["dmg taken increased"] = 0.35,
}

-- if owner has these conds, apply them on the bot
-- used to replicate canteen effects
--Here because you can find other ways to critboost yourself
local REPLICATE_CONDS = {
	TF_COND_MINICRITBOOSTED_ON_KILL,
	TF_COND_OFFENSEBUFF,
}

-- for making "sentry fire rate" upgrade replicate to bot as a different attribute
local SENTRY_FIRERATE_REPLICATE_ATTR = "halloween fire rate bonus" -- should be a unique attribute that isn't applied by anything else
local SENTRY_FIRERATE_REPLICATE_MULT = 0.6

-- we can't expect lua to do all the work - joshua graham
-- local BOT_SETUP_VSCRIPT = "activator.SetDifficulty(3); activator.SetMaxVisionRangeOverride(0.1)"
-- 16 -- disable dodge
local BOT_SETUP_VSCRIPT =
	"activator.SetDifficulty(3); activator.SetMaxVisionRangeOverride(100000); activator.AddBotAttribute(16)"
local BOT_DISABLE_VISION_VSCRIPT = "activator.SetDifficulty(0); activator.SetMaxVisionRangeOverride(0.1)"
local BOT_ENABLE_VISION_VSCRIPT = "activator.SetDifficulty(3); activator.SetMaxVisionRangeOverride(100000)"
local BOT_SET_WEPRESTRICTION_VSCRIPT = "activator.AddWeaponRestriction(%s)"
local BOT_CLEAR_RESTRICTIONS_VSCRIPT = "activator.ClearAllWeaponRestrictions()"
--additional functionality
local BOT_HOLD_FIRE = "activator.AddBotAttribute(2048)"
local BOT_ALWAYS_FIRE = "activator.AddBotAttribute(8192)"
local BOT_SPAWN_FULL_CHARGE = "activator.AddBotAttribute(256)"

-- local BOT_CLEAR_FOCUS = "activator.ClearAttentionFocus()"

local BOT_ATTACK_VSCRIPT = "activator.PressFireButton(0.01)" --made shorter
local BOT_CHARGE_VSCRIPT = "activator.PressAltFireButton(0.1)"

local activeBots = {} -- bots alive

local activeBuiltBots = {} -- bot built by player
local activeBuiltBotsOwner = {}

local lingeringBuiltBots = {}

local inWave = false

local PACK_ITEMS = {
	"item_currencypack_small",
	"item_currencypack_medium",
	"item_currencypack_large",
	"item_currencypack_custom",
}
-- delete cash dropped by bots that were built by players
-- due to inheriting TFBot's currency count
local function removeCashSafe(pack)
	pack:SetAbsOrigin(Vector(0, -100000, 0))
	local objectiveResource = ents.FindByClass("tf_objective_resource")

	local moneyBefore = objectiveResource.m_nMvMWorldMoney
	pack:Remove()
	local moneyAfter = objectiveResource.m_nMvMWorldMoney

	local packPrice = moneyBefore - moneyAfter
	-- print("price: "..tostring(packPrice))
	local mvmStats = ents.FindByClass("tf_mann_vs_machine_stats")

	local vscript =
		'NetProps.SetPropInt(activator, "%s.nCreditsDropped", NetProps.GetPropInt(activator, "%s.nCreditsDropped") - %s)'
	local curWave = "m_currentWaveStats"
	mvmStats:RunScriptCode(vscript:format(curWave, curWave, packPrice), mvmStats, mvmStats)
end

for _, packName in pairs(PACK_ITEMS) do
	ents.AddCreateCallback(packName, function(pack)
		local disablePickUp = pack:AddCallback(ON_SHOULD_COLLIDE, function()
			return false
		end)
		timer.Simple(0, function()
			-- failsafe for a glitch where spamming rebuild can very rarely drop cash
			if not inWave then
				removeCashSafe(pack)
				return
			end

			local handle = pack.m_hOwnerEntity:GetHandleIndex()

			if not lingeringBuiltBots[handle] then
				pack:RemoveCallback(disablePickUp)
				return
			end

			removeCashSafe(pack)

			lingeringBuiltBots[handle] = nil
		end)
	end)
end

function OnWaveInit()
	inWave = false

	for _, bot in pairs(activeBuiltBots) do
		bot:Suicide()
		bot.m_iTeamNum = 1
	end

	activeBuiltBots = {}
end

function OnWaveStart()
	inWave = true

	-- bots spawned in prewave are put to spectate/gray team so they don't take up slot
	for _, bot in pairs(activeBuiltBots) do
		bot:ResetFakeSendProp("m_iTeamNum")
		bot.m_iTeamNum = 3
		-- bot:RemoveCond(TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED)
		bot:SetAttributeValue("not solid to players", nil)
		bot:SetAttributeValue("ignored by enemy sentries", nil)
		bot:SetAttributeValue("ignored by bots", nil)
		bot:SetAttributeValue("damage bonus HIDDEN", nil)
	end
end

local function checkOnHit(parent, damageinfo)
	local attacker = damageinfo.Attacker

	if not attacker then
		return
	end

	local handle = attacker:GetHandleIndex()

	local owner = activeBuiltBotsOwner[handle]

	if not owner then
		return
	end

	if parent == owner then
		return
	end

	damageinfo.Attacker = owner

	return true
end

ents.AddCreateCallback("tank_boss", function(tank)
	tank:AddCallback(ON_DAMAGE_RECEIVED_PRE, function(_, damageinfo)
		return checkOnHit(tank, damageinfo)
	end)
end)

-- convert damage dealt by bots to owner
-- and nullify damage taken by built bot during prewave
local function addGlobalCallbacks(player)
	player:AddCallback(ON_DAMAGE_RECEIVED_PRE, function(_, damageinfo)
		local isBot = activeBots[player:GetHandleIndex()]
		if isBot and not inWave then
			-- nullify attacks in prewave
			damageinfo.Damage = 0
			damageinfo.Inflictor = nil
			damageinfo.Weapon = nil
			return true
		end

		return checkOnHit(player, damageinfo)
	end)

	-- failsafe for spawning bot in setup
	player:AddCallback(ON_SPAWN, function()
		if player:IsRealPlayer() then
			return
		end

		timer.Simple(0.1, function()
			if inWave then
				return
			end

			local owner = activeBuiltBots[player:GetHandleIndex()]

			if not owner then
				return
			end

			if player.m_iTeamNum == owner.m_iTeamNum then
				player:Suicide()
			end
		end)
	end)
end

AddEventCallback("player_spawn", function(eventTable)
	--print("Added callbacks")
	
	local spawnedPlayer = ents.GetPlayerByUserId(eventTable.userid)
	--print(spawnedPlayer)
	
	local revisedTable = {}
	local spawnedPlayerInTable = false
	
	for _, player in pairs(PlayersWithCallbacks) do
		--if IsValid(player) then
		--	table.insert(revisedTable, player)
		--end
		if player == spawnedPlayer then
			spawnedPlayerInTable = true
		end	
	end
	--if #revisedTable ~= #PlayersWithCallbacks then
	--	PlayersWithCallbacks = {}
	--	print("A player was invalid, rebuilding")
	--	for _, player in pairs(revisedTable) do
	--		table.insert(PlayersWithCallbacks, player)
	--	end	
	--end
	
	if spawnedPlayerInTable == false then
		print("Added spawning player to table and applied callbacks")
		addGlobalCallbacks(spawnedPlayer)
		table.insert(PlayersWithCallbacks, spawnedPlayer)
	end
end)

local function removeCallbacks(player, callbacks)
	if not IsValid(player) then
		return
	end

	for _, callbackId in pairs(callbacks) do
		player:RemoveCallback(callbackId)
	end
end

local function getEyeAngles(player)
	local pitch = player["m_angEyeAngles[0]"]
	local yaw = player["m_angEyeAngles[1]"]

	return Vector(pitch, yaw, 0)
end

local function getCursorPos(player, bot)
	local eyeAngles = getEyeAngles(player)

	util.StartLagCompensation(player)
	local DefaultTraceInfo = {
		start = player,
		distance = 100000,
		angles = eyeAngles,
		mask = MASK_SHOT,
		collisiongroup = COLLISION_GROUP_PLAYER, --COLLISION_GROUP_DEBRIS,
		filter = { player, bot },
	}
	local trace = util.Trace(DefaultTraceInfo)
	util.FinishLagCompensation(player)
	return trace.HitPos
end

--deleted clip checker, didn't really need to be here

local function applyName(bot, name, owner)
	local displayName = name .. " (" .. owner.m_szNetname .. ")"
	bot.m_szNetname = displayName

	bot:SetFakeClientConVar("name", displayName)
end

local function applyUniversalData(bot, data)
	if data.Model then
		bot:SetCustomModelWithClassAnimations(data.Model)
	end

	if data.Scale then
		local vscript = ("activator.SetScaleOverride(%s)"):format(tostring(data.Scale))
		bot:RunScriptCode(vscript, bot)
	end
	
	--apply the correct bitflags when these are set to true within a bot template
	if data.HoldFireUntilFullReload then
	bot:RunScriptCode(BOT_HOLD_FIRE, bot)
	end
	
	if data.SpawnWithFullCharge then
	bot:RunScriptCode(BOT_SPAWN_FULL_CHARGE, bot)
	end
	
	if data.AlwaysFireWeapon then
	bot:RunScriptCode(BOT_ALWAYS_FIRE, bot)
	end	
	
	if data.ItemAttributes then
			for slot, attributes in pairs(data.ItemAttributes) do
				local weapon = bot:GetPlayerItemBySlot(slot)
				print(slot)

				if weapon then
					for name, value in pairs(attributes) do
						weapon:SetAttributeValue(name, value)
						print("added" .. name)
					end
				end
			end
		end	

	if data.Items then
		for _, itemName in pairs(data.Items) do
			bot:GiveItem(itemName)
		end
	end

	if data.Attributes then
		for name, value in pairs(data.Attributes) do
			bot:SetAttributeValue(name, value)
		end
	end

	if data.MiniBoss then
		bot.m_bIsMiniBoss = 1
	else
		bot.m_bIsMiniBoss = 0
	end

	if data.Display then
		applyName(bot, data.Display, activeBuiltBotsOwner[bot:GetHandleIndex()])
	end
end

local function applyMaxHealthUpgrade(owner, bot)
	local pda = owner:GetPlayerItemBySlot(LOADOUT_POSITION_PDA)
	local healthBonusMult = pda:GetAttributeValue("engy building health bonus") or 1

	-- each upgrade gives 150 extra health
	local extraHealth = 500 * (healthBonusMult - 1)
	local curMaxHealthBuff = bot:GetAttributeValue("hidden maxhealth non buffed") or 0
	bot:SetAttributeValue("hidden maxhealth non buffed", curMaxHealthBuff + extraHealth)
end

local function applyDefaultData(owner, bot, class)
	local data = BOTS_VARIANTS[class]

	if data.DefaultAttributes then
		for name, value in pairs(data.DefaultAttributes) do
			bot:SetAttributeValue(name, value)
		end
	end

	bot:SwitchClassInPlace(data.Class)
	-- remove potential lingering health
	--out of place if statement here to correct a bug where this lingering health remover makes it impossible to add added health to default templates,
	--which is an issue that didn't manifest in any other version of the script due to all default templates being regular classes
	bot:SetAttributeValue("hidden maxhealth non buffed", nil)
	if bot:GetAttributeValue("hidden maxhealth non buffed") ~= data.HealthIncrease then
	bot:SetAttributeValue("hidden maxhealth non buffed", data.HealthIncrease)
	end	

	applyUniversalData(bot, data)

	applyMaxHealthUpgrade(owner, bot)
end

local function applyTierData(bot, data)
	applyUniversalData(bot, data)

	if data.HealthIncrease then
		bot:SetAttributeValue("hidden maxhealth non buffed", data.HealthIncrease)

		local owner = activeBuiltBotsOwner[bot:GetHandleIndex()]

		local sentry = Entity(tonumber(owner.BuiltBotSentry))
		sentry.m_iMaxHealth = owner.m_iMaxHealth + data.HealthIncrease
		sentry.m_iHealth = sentry.m_iHealth + data.HealthIncrease
	end

	if data.Conds then
		for _, id in pairs(data.Conds) do
			bot:AddCond(id)
		end
	end

	bot:RefillAmmo()
end

-- remove lingering stuff
local function removePreviousTier(bot, class, previousTier)
	local data = BOTS_VARIANTS[class].Tiers[previousTier]

	if data.Conds then
		for _, id in pairs(data.Conds) do
			bot:RemoveCond(id)
		end
	end

	if data.Items then
		for _, itemName in pairs(data.Items) do
			bot:RemoveItem(itemName)
		end
	end

	if data.Attributes then
		for name, _ in pairs(data.Attributes) do
			bot:SetAttributeValue(name, nil)
		end
	end
end

local function getCurBotTier(owner) --these functions are brilliant, you effectively use useless attributes as variables for your script
	return owner:GetPlayerItemBySlot(2):GetAttributeValue("throwable fire speed")
end

local function getCurBotCloak(owner)
	return owner:GetPlayerItemBySlot(2):GetAttributeValue("charge recharge rate increased")
end


local function applyBotTier(owner, bot, class, tier)
	if tier > 0 then
		removePreviousTier(bot, class, tier - 1)
	end

	local tierData = BOTS_VARIANTS[class].Tiers[tier]

	applyTierData(bot, tierData)

	applyMaxHealthUpgrade(owner, bot)
end

local function setupBot(bot, owner, handle, building)
	local callbacks = {}

	local botHandle = bot:GetHandleIndex()

	applyName(bot, "", owner)
	
	if IsValid(building) == false then
		bot:Suicide()
	end	

	bot.m_iTeamNum = owner.m_iTeamNum

	bot.m_iszClassIcon = "" -- don't remove from wave on death

	for name, value in pairs(BOTS_ATTRIBUTES) do
		bot:SetAttributeValue(name, value)
	end

	owner.BuiltBotHandle = tostring(botHandle)
	owner.BuiltBotSentry = tostring(building:GetHandleIndex())

	activeBots[botHandle] = true
	activeBuiltBots[handle] = bot
	lingeringBuiltBots[botHandle] = true
	activeBuiltBotsOwner[botHandle] = owner

	-- callbacks.shouldCollide = bot:AddCallback(ON_SHOULD_COLLIDE, function(other, cause)
	-- 	if cause == ON_SHOULD_COLLIDE_CAUSE_FIRE_WEAPON then
	-- 		return
	-- 	end

	-- 	if not other:IsPlayer() then
	-- 		return
	-- 	end

	-- 	return false
	-- end)
	callbacks.damaged = bot:AddCallback(ON_DAMAGE_RECEIVED_POST, function()
		if IsValid(building) then	
			building.m_iHealth = bot.m_iHealth
		end		
	end)
	callbacks.died = bot:AddCallback(ON_DEATH, function()
		-- attributes applied to bot spawned through script are not cleared automatically on death
		for name, _ in pairs(bot:GetAllAttributeValues()) do
			bot:SetAttributeValue(name, nil)
		end
		
		if owner:GetPlayerItemBySlot(0):GetItemName() == "The Frontier Justice" then
		
			if building.m_iKills then --gives accurate amount of revenge crits, easily modifiable to buff or nerf the frontier justice
			owner.m_iRevengeCrits = owner.m_iRevengeCrits + (building.m_iKills * 2)
			end
		end	

		owner.BuiltBotHandle = false
		owner.BuiltBotSentry = false

		activeBots[botHandle] = nil
		activeBuiltBots[handle] = nil
		activeBuiltBotsOwner[botHandle] = nil

		bot:ResetFakeSendProp("m_iTeamNum")
		bot.m_iTeamNum = 1
			
		bot.m_bGlowEnabled = 0		

		removeCallbacks(bot, callbacks)
		if IsValid(building) then
			building:Remove()
		end
	end)

	return callbacks
end

local function findFreeBot()
	local chosen

	for _, bot in pairs(ents.GetAllPlayers()) do
		if
			not bot:IsRealPlayer()
			and not bot:IsAlive()
			and (bot.m_iTeamNum == 1 or bot.m_iTeamNum == 0)
			and bot:GetPlayerName() ~= "Demo-Bot"
		then
			chosen = bot
			break
		end
	end

	return chosen
end

botType = "scout" --declared here as an anti crash mechanism, the exact second I removed it and did some solo testing the server imploded

function TierPurchaseSoldier(tier, activator)
	tier = tier + 1

	--print("purchasing tier", tier)

	-- activator.BotTier = tier

	local botHandle = activator.BuiltBotHandle
	local bot = botHandle and Entity(tonumber(botHandle))

	if tier <= 1 then
		if bot then
			bot:Suicide()
		end

		return
	end

	if not bot then
		return
	end
	
	botType = "soldier" --added to deal with a hard reference to soldier in the original script
	applyBotTier(activator, bot, "soldier", tier)
end

function TierPurchaseDemo(tier, activator)
	tier = tier + 1

	--print("purchasing tier", tier)

	-- activator.BotTier = tier

	local botHandle = activator.BuiltBotHandle
	local bot = botHandle and Entity(tonumber(botHandle))
	
	if tier <= 1 then
		if bot then
			bot:Suicide()
		end

		return
	end

	if not bot then
		return
	end
	
	botType = "demo" --added to deal with a hard reference to soldier in the original script
	applyBotTier(activator, bot, "demo", tier)
end

function TierPurchasePyro(tier, activator)
	tier = tier + 1

	--print("purchasing tier", tier)

	-- activator.BotTier = tier

	local botHandle = activator.BuiltBotHandle
	local bot = botHandle and Entity(tonumber(botHandle))

	if tier <= 1 then
		if bot then
			bot:Suicide()
		end

		return
	end

	if not bot then
		return
	end
	
	botType = "pyro" --added to deal with a hard reference to soldier in the original script
	applyBotTier(activator, bot, "pyro", tier)
end

function TierPurchaseScout(tier, activator)
	tier = tier + 1

	--print("purchasing tier", tier)

	-- activator.BotTier = tier

	local botHandle = activator.BuiltBotHandle
	local bot = botHandle and Entity(tonumber(botHandle))

	if tier <= 1 then
		if bot then
			bot:Suicide()
		end

		return
	end
	
	if not bot then
		return
	end

	botType = "scout" --added to deal with a hard reference to soldier in the original script
	applyBotTier(activator, bot, "scout", tier)
end

function TierPurchaseHeavy(tier, activator)
	tier = tier + 1

	--print("purchasing tier", tier)

	-- activator.BotTier = tier

	local botHandle = activator.BuiltBotHandle
	local bot = botHandle and Entity(tonumber(botHandle))

	if tier <= 1 then
		if bot then
			bot:Suicide()
		end

		return
	end

	if not bot then
		return
	end

	botType = "heavy" --added to deal with a hard reference to soldier in the original script
	applyBotTier(activator, bot, "heavy", tier)
end

local function startBotConstruction(owner, building, bot)
	if not inWave then
		building.m_iHealth = building.m_iMaxHealth
		return
	end

	building.m_bBuilding = 1
	bot.m_iHealth = 1

	local botTier = getCurBotTier(owner) or 1 
	local roboCloakDuration = getCurBotCloak(owner) or 0.01

	local healthIncrement = 3 --nerfed build speed of all giants
	
	--Removed tier health modifier, because every template is a giant here

	bot:AddCond(TF_COND_MVM_BOT_STUN_RADIOWAVE, 50000, owner)
	bot:AddCond(TF_COND_STEALTHED_USER_BUFF_FADING, roboCloakDuration)
	-- bot:StunPlayer(500000, 1, TF_STUNFLAG_NOSOUNDOREFFECT)

	local constructionTimer
	constructionTimer = timer.Create(0, function()
		if not IsValid(building) then
			timer.Stop(constructionTimer)
			return
		end

		building.m_bBuilding = 1

		bot.m_iHealth = bot.m_iHealth + healthIncrement

		building.m_iHealth = bot.m_iHealth

		local percent = building.m_iHealth / building.m_iMaxHealth
		building.m_flPercentageConstructed = percent

		building.m_bBuilding = 1

		if percent >= 1 then
			timer.Stop(constructionTimer)
			-- bot:RemoveCond(TF_COND_MVM_BOT_STUN_RADIOWAVE)
			bot:PlaySound("weapons/sentry_finish.wav")	
			bot:RemoveCond(TF_COND_STUNNED)
			bot:RemoveCond(TF_COND_STEALTHED_USER_BUFF_FADING)
			bot.m_bGlowEnabled = 1	
			building.m_bBuilding = 0
			return
		end
	end, 0)
end

function SentrySpawned(_, building)
	if not IsValid(building) then
		--print("building was destroyed before logic could register lol")
		return
	end

	local owner = building.m_hBuilder
	local handle = owner:GetHandleIndex()

	local origin = building:GetAbsOrigin()

	local newBuilding = ents.CreateWithKeys("obj_sentrygun", {
		defaultupgrade = 0,
		team = owner.m_iTeamNum,
		SolidToPlayer = 0,
	}, true)

	newBuilding.m_bBuilding = 1

	building:Remove()
	newBuilding:SetBuilder(owner, owner, owner)

	newBuilding:SetAbsOrigin(Vector(0, 0, -10000))
	newBuilding:Disable()

	if activeBuiltBots[handle] and activeBuiltBots[handle]:IsAlive() then
		newBuilding:Remove()
		return
	end

	local botSpawn = findFreeBot()

	if not botSpawn then
		owner:Print(PRINT_TARGET_CENTER, "GLOBAL BOT LIMIT REACHED")
		newBuilding:Remove()
		return
	end

	local callbacks = setupBot(botSpawn, owner, handle, newBuilding)

	timer.Simple(0, function()
		if not IsValid(newBuilding) then
			--print("newBuilding was destroyed before logic could happen")
			botSpawn:Suicide()
			return
		end
		botSpawn:SetAbsOrigin(origin)
		
		local botTier = getCurBotTier(owner)
		
		local ownerMelee = owner:GetPlayerItemBySlot(LOADOUT_POSITION_MELEE)
			if ownerMelee:GetAttributeValue("cloak consume rate decreased") == 1 then		
			botType = "demo"
			elseif  ownerMelee:GetAttributeValue("cloak consume rate decreased") == 2 then
			botType = "pyro"
			elseif ownerMelee:GetAttributeValue("cloak consume rate decreased") == 3 then
			botType = "scout"		
			elseif ownerMelee:GetAttributeValue("cloak consume rate decreased") == 4 then
			botType = "heavy"
			else 																									 
			botType = "soldier"		
			end					--this code is very inefficient
			
		botSpawn:SwitchClassInPlace("data.Class") --maybe running it twice will fix the problem? I don't know
		botSpawn:SwitchClassInPlace("data.Class")	
		

		if botTier and botTier > 1 then
			--print("applying tier", botTier)
			applyBotTier(owner, botSpawn, botType, botTier)
		else
			applyDefaultData(owner, botSpawn, botType)
		end

		botSpawn:RunScriptCode(BOT_SETUP_VSCRIPT, botSpawn, botSpawn)

		-- botSpawn:RunScriptCode((BOT_SET_WEPRESTRICTION_VSCRIPT):format("0"), botSpawn, botSpawn)
		botSpawn:RunScriptCode(BOT_CLEAR_RESTRICTIONS_VSCRIPT, botSpawn, botSpawn)

		-- set max health
		newBuilding.m_iMaxHealth = botSpawn.m_iHealth

		local teleParticle = ents.CreateWithKeys("info_particle_system", {
			effect_name = "teleportedin_blue",
			start_active = 1,
			flag_as_weather = 0,
		}, true, true)	
		teleParticle:SetAbsOrigin(botSpawn:GetAbsOrigin())
		teleParticle:Start()
			
		botSpawn.m_bGlowEnabled = 1		
	
		timer.Simple(1, function ()
			teleParticle:Remove()
		end)
			
			

		startBotConstruction(owner, newBuilding, botSpawn)

		newBuilding:AddCallback(ON_REMOVE, function()
			if not activeBuiltBots[handle] then
				return
			end

			botSpawn:Suicide()
		end)

		if not inWave then
			botSpawn:SetFakeSendProp("m_iTeamNum", 3)
			botSpawn.m_iTeamNum = 1
			-- botSpawn:AddCond(TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED)
			botSpawn:SetAttributeValue("not solid to players", 1)
			botSpawn:SetAttributeValue("ignored by enemy sentries", 1)
			botSpawn:SetAttributeValue("ignored by bots", 1)
			botSpawn:SetAttributeValue("damage bonus HIDDEN", 0.0001)
		end

		-- callbacks.spawned = botSpawn:AddCallback(ON_SPAWN, function()
		-- 	removeCallbacks(botSpawn, callbacks)
		-- 	if IsValid(newBuilding) then
		-- 		newBuilding:Remove()
		-- 	end
		-- end)
		local spawnedCallback
		spawnedCallback = botSpawn:AddCallback(ON_SPAWN, function()
			if IsValid(newBuilding) then
				newBuilding:Remove()
			end

			botSpawn:ResetFakeSendProp("m_iTeamNum")

			lingeringBuiltBots[handle] = nil

			botSpawn:RemoveCallback(spawnedCallback)
			spawnedCallback = nil
		end)

		local cursorPos = Vector(0, 0, 0)

		local lastWrangled = false
			
		local kneecapGiant = false	
			
		local kneecapCooldown = 0	
		local autoKneecapNotified = false	

		-- bot behavior
		-- default behavior is always following you
		local logicLoop
		logicLoop = timer.Create(0.2, function()
			if not activeBuiltBots[handle] then
				timer.Stop(logicLoop)
				return
			end
				

			if not owner:IsAlive() and autoKneecapNotified == false then		
				owner:AcceptInput("$displaytextchat", "{FFFF00}Giant OS{reset} {FFFFFF} : Engineer death detected. Giant is now {Blue}Parked")	
				owner:PlaySoundToSelf("radio5.mp3")
				owner:PlaySoundToSelf("mvm/giant_demoman/giant_demoman_step_01.wav")				
				autoKneecapNotified = true	
				kneecapGiant = true
				botSpawn:RemoveCond(17)	
				botSpawn.m_flChargeMeter = 0		
			end
		
					
			if owner:IsAlive() then
				autoKneecapNotified = false		
			end			
			
			local botMisc
			botMisc = timer.Create(0.2, function() --a while loop for this crashed the server			
			 	if not activeBuiltBots[handle] then
					timer.Stop(botMisc)
				return
				end
			 
				if lastWrangled == true then
					return
				end				

					if botSpawn.m_flChargeMeter >= 100 and kneecapGiant == false then
						if botSpawn:GetPlayerItemBySlot(1) then		
							if botSpawn:GetPlayerItemBySlot(1):GetItemName() == "The Splendid Screen" or botSpawn:GetPlayerItemBySlot(1):GetItemName() == "The Chargin' Targe" then 

								botSpawn:RunScriptCode(BOT_CHARGE_VSCRIPT, botSpawn)
							end		
						end			
				end			
				
				if botSpawn:GetPlayerItemBySlot(1) then
					if botSpawn:GetPlayerItemBySlot(1):GetItemName() == "The Buff Banner" or botSpawn:GetPlayerItemBySlot(1):GetItemName() == "The Concheror"  then
						local bannerActive	
						local secondary = botSpawn:GetPlayerItemBySlot(1) 			

						if botSpawn.m_flRageMeter == 0 then
						bannerActive = false
						end
							if botSpawn.m_flRageMeter > 100 then
								botSpawn.m_flRageMeter = 100		
							end			
							if botSpawn.m_flRageMeter == 100  then			
								if botSpawn:GetPlayerItemBySlot(0) then
									botSpawn:WeaponSwitchSlot(1)
									secondary:SetAttributeValue("disable weapon switch", 1)		
								end
							botSpawn:RunScriptCode("activator.PressFireButton(0.01)", botSpawn)

							else
								if botSpawn:InCond(29) or botSpawn:InCond(16) or botSpawn:InCond(26) then
									secondary:SetAttributeValue("disable weapon switch", 0)		
									botSpawn:WeaponSwitchSlot(0)		
									bannerActive = true
								end
							end			
					end
				end				
				
			end)

			if owner:InCond(TF_COND_TAUNTING) then
				botSpawn:SetAttributeValue("cannot taunt", nil)
				botSpawn["$Taunt"](botSpawn)
				botSpawn:SetAttributeValue("cannot taunt", 1)
			end

			for _, cond in pairs(REPLICATE_CONDS) do
				if owner:InCond(cond) then
					botSpawn:AddCond(cond, 4, owner)
				end
			end

			local pda = owner:GetPlayerItemBySlot(LOADOUT_POSITION_PDA)
				
			if IsValid(newBuilding) then		
				newBuilding.m_iAmmoShells = 150 --to stop annoying interaction with the wrangler
			end			
			local ownerFireRateUpgrade = pda:GetAttributeValue("sentry fire rate")

			if ownerFireRateUpgrade then
				botSpawn:SetAttributeValue(
					SENTRY_FIRERATE_REPLICATE_ATTR,
					ownerFireRateUpgrade * SENTRY_FIRERATE_REPLICATE_MULT
				)							
						
			else
				botSpawn:SetAttributeValue(SENTRY_FIRERATE_REPLICATE_ATTR, nil)															
			end
							

			if owner:IsAlive() and owner.m_hActiveWeapon.m_iClassname == "tf_weapon_laser_pointer" then						
				-- wrangle behavior:
				-- if attack is held: fire weapon
				-- if alt fire is held: move toward cursor while attacking independently						

				if not lastWrangled then
					-- botSpawn:BotCommand("stop interrupt action")

					botSpawn:RunScriptCode(BOT_DISABLE_VISION_VSCRIPT, botSpawn)			

					for name, value in pairs(BOTS_WRANGLED_ATTRIBUTES) do
						botSpawn:SetAttributeValue(name, value)
					end

					lastWrangled = true
				end						

				botSpawn:RunScriptCode("activator.ClearAttentionFocus()", botSpawn)

				local altFireHeld = owner.m_nButtons & IN_ATTACK2 ~= 0
				local attackHeld = owner.m_nButtons & IN_ATTACK ~= 0

				cursorPos = getCursorPos(owner, botSpawn)

				if attackHeld then
					if botSpawn:GetPlayerItemBySlot(0).m_iClassname == "tf_weapon_minigun" then
							botSpawn:RunScriptCode("activator.PressFireButton(0.5)", botSpawn)	
					else			
					botSpawn:RunScriptCode(BOT_ATTACK_VSCRIPT, botSpawn)
					end			
						if botSpawn:GetPlayerItemBySlot(1):GetItemName() == "The Splendid Screen" or botSpawn:GetPlayerItemBySlot(1):GetItemName() == "The Chargin' Targe" then --I hope these can run concurrently
								botSpawn:RunScriptCode(BOT_CHARGE_VSCRIPT, botSpawn)
						end
				end

				if altFireHeld then
					local interruptAction = ("interrupt_action -pos %s %s %s -distance 1 -duration 0.1"):format(
						cursorPos[1],
						cursorPos[2],
						cursorPos[3]
					)

					botSpawn:BotCommand(interruptAction)

					-- allow bot to attack when alt fire is held
					botSpawn:RunScriptCode(BOT_ENABLE_VISION_VSCRIPT, botSpawn)

					-- botSpawn:RemoveCond(TF_COND_ENERGY_BUFF)
					-- for name, _ in pairs(BOTS_WRANGLED_ATTRIBUTES) do
					-- 	botSpawn:SetAttributeValue(name, nil)
					-- end
				else
					botSpawn:RunScriptCode(BOT_DISABLE_VISION_VSCRIPT, botSpawn)

					-- botSpawn:AddCond(TF_COND_ENERGY_BUFF)
					-- for name, value in pairs(BOTS_WRANGLED_ATTRIBUTES) do
					-- 	botSpawn:SetAttributeValue(name, value)
					-- end
				end

				return
			end

			if lastWrangled then

				for name, _ in pairs(BOTS_WRANGLED_ATTRIBUTES) do
					botSpawn:SetAttributeValue(name, nil)
				end

				-- botSpawn:BotCommand("stop interrupt action")

				botSpawn:RunScriptCode(BOT_ENABLE_VISION_VSCRIPT, botSpawn)

				lastWrangled = false
				--print("Last wrangled is now false")		
			end

			local pos = owner:GetAbsOrigin()
			local distance = pos:Distance(botSpawn:GetAbsOrigin())

			if distance >= SPEED_BOOST_DISTANCE then
				botSpawn:AddCond(TF_COND_SPEED_BOOST, 1)
			end		

			local stringStart = "interrupt_action -switch_action Default"
					
				
					
			if owner.m_nButtons >= 33554432 and kneecapCooldown <= 0 then
						
					if kneecapGiant == false then	
						kneecapGiant = true		
						owner:AcceptInput("$displaytextchat", "{FFFF00}Giant OS{reset} {FFFFFF} : Your giant is now {Blue}Parked")	
						owner:PlaySoundToSelf("radio5.mp3")
						owner:PlaySoundToSelf("mvm/giant_demoman/giant_demoman_step_01.wav")	
					else
						kneecapGiant = false	
						owner:AcceptInput("$displaytextchat", "{FFFF00}Giant OS{reset} {FFFFFF} : Your giant is now {Green}Mobile")	
						owner:PlaySoundToSelf("radio4.mp3")
						owner:PlaySoundToSelf("sentry_spot_low.mp3")	
					end
				kneecapCooldown = 0.35		
			end
					
			if kneecapCooldown > 0 then
				kneecapCooldown = kneecapCooldown - 0.1		
			end			
					

			-- don't move if already close, or if you are told to not move
			if distance <= 150 or kneecapGiant == true then
				botSpawn:BotCommand(stringStart .. " -duration 0.1")
				--print(owner.m_nButtons)
				if kneecapGiant == true and botSpawn:InCond(17) then
					botSpawn:RemoveCond(17)	
					botSpawn.m_flChargeMeter = 0		
				end			
				return
			end

			local interruptAction = ("%s -pos %s %s %s -duration 0.1"):format(stringStart, pos[1], pos[2], pos[3])

			botSpawn:BotCommand(interruptAction)
		end, 0)

		local wranglerLogic
		wranglerLogic = timer.Create(0, function()
			if not activeBuiltBots[handle] or not IsValid(owner) then
				timer.Stop(wranglerLogic)
				return
			end

			if not owner.m_hActiveWeapon then
				return
			end

			if owner.m_hActiveWeapon.m_iClassname == "tf_weapon_laser_pointer" then
				-- wrangle behavior:
				-- if attack is held: fire weapon
				-- if alt fire is held: move toward cursor while attacking independently
				local altFireHeld = owner.m_nButtons & IN_ATTACK2 ~= 0
						
				if botSpawn:GetPlayerItemBySlot(0).m_iClassname == "tf_weapon_minigun" then
							botSpawn:RunScriptCode("activator.PressAltFireButton(1)", botSpawn)
				end						

				cursorPos = getCursorPos(owner, botSpawn)

				if not altFireHeld then
					-- local interruptAction = ("interrupt_action -lookpos %s %s %s -alwayslook -duration 0.14"):format(
					-- 	cursorPos[1],
					-- 	cursorPos[2],
					-- 	cursorPos[3]
					-- )

					-- botSpawn:BotCommand(interruptAction)

					-- thanks mince
					local targetAngles = (cursorPos - (botSpawn:GetAbsOrigin() + Vector(
						0,
						0,
						botSpawn["m_vecViewOffset[2]"]
					))):ToAngles()
					targetAngles = Vector(targetAngles[1], targetAngles[2], 0)

					botSpawn:SnapEyeAngles(targetAngles)
				end

				return
			end
		end, 0)
	end)
end
--commented out due to mission not having canteens on it
--also to investigate issues with heavy templates

--AddEventCallback("player_used_powerup_bottle", function(eventTable)
--	local netId = eventTable.player
--	local canteenType = eventTable.type

--	local AMMO_CANTEEN = 4

--	local player = ents.GetAllPlayers()[netId]
--	local bot = activeBuiltBots[player:GetHandleIndex()]

--	if not bot then
--		return
--	end

	--if canteenType == AMMO_CANTEEN then
	--	local botWeapon = bot.m_hActiveWeapon
	--	local botWeaponClip = botWeapon.m_iClip1
	--	if botWeaponClip then
	--		local maxClip = getMaxClip(bot)

	--		botWeapon.m_iClip1 = maxClip
	--	end
	--end
--end)
AddEventCallback("player_death", function(eventTable)
	local attacker = eventTable.attacker
	local player = ents.GetPlayerByUserId(attacker)
	
	if not player then
		return
	end
		
	local attackerBot = activeBuiltBots[player:GetHandleIndex()]
		
	if not IsValid(attackerBot) then
			return
	end		

	local isBotKill = false

	local inflictor = Entity(eventTable.inflictor_entindex)

	if not inflictor then
	return
	end		
			
	if inflictor == attackerBot.m_hActiveWeapon then
		-- weapon
		isBotKill = true
	elseif inflictor.m_hLauncher then
		-- projectile
		local weaponOwner = inflictor.m_hLauncher.m_hOwnerEntity
		if weaponOwner == attackerBot then
			isBotKill = true
		end
	end

	if not isBotKill then
		return
	end

	local victim = Entity(eventTable.victim_entindex)

	local killAddition = 1

	if victim.m_bIsMiniBoss ~= 0 then
		killAddition = 5
	end
	
	--heal 100 when euthanizing a common, heal 500 when euthanizing a giant
	attackerBot.m_iHealth = attackerBot.m_iHealth + 100 * killAddition
	
	--20 banner charge from a common, 50 from a giant
	if attackerBot:GetPlayerItemBySlot(1):GetItemName() == "The Buff Banner" or attackerBot:GetPlayerItemBySlot(1):GetItemName() == "The Concheror" then
		if attackerBot:InCond(29) or attackerBot:InCond(16) or attackerBot:InCond(26) and attackerBot:GetConditionProvider(29) == attackerBot  or attackerBot:GetConditionProvider(16) == attackerBot or attackerBot:GetConditionProvider(2) == attackerBot then				
		attackerBot.m_flRageMeter = attackerBot.m_flRageMeter
	--	print (attackerBot.m_flRageMeter)		
		else
		attackerBot.m_flRageMeter = attackerBot.m_flRageMeter + killAddition * 5 + 20			
		--print("We just got banner charge")
		--print (attackerBot.m_flRageMeter)		
		end		
	end		
	
	local particlelocation = activeBuiltBots[player:GetHandleIndex()]:GetAbsOrigin() + Vector(0, 0, 125) --taken from bbox_heal_on_building_hit.lua
	util.ParticleEffect("healthgained_blu_giant", particlelocation, nil, activeBuiltBots[player:GetHandleIndex()])

	local sentry = Entity(tonumber(player.BuiltBotSentry))
	sentry.m_iKills = sentry.m_iKills + killAddition	
end)
function checkIfMeleeHitAlly(param, activator, calller)
		if not util.IsLagCompensationActive() then
			util.StartLagCompensation(activator)	
		end
	
		--ripped from red_sniper_laser.lua
	
		local function getEyeAngles(player)
			local pitch = player["m_angEyeAngles[0]"]
			local yaw = player["m_angEyeAngles[1]"]

			return Vector(pitch, yaw, 0)
		end
	
		--ripped from my med hunter script, hybrid of red sniper laser check and some original work on my end
	
		local TraceLineOfSight = {
			start = activator, -- Start position vector. Can also be set to entity, in this case the trace will start from entity eyes position
			distance = 100, -- Used if endpos is nil
			angles = getEyeAngles(activator), -- Used if endpos is nil
			mask = MASK_SOLID, -- Solid type mask, see MASK_* globals
			collisiongroup = COLLISION_GROUP_PLAYER, -- Pretend the trace to be fired by an entity belonging to this group. See COLLISION_GROUP_* globals
		}
		local lineOfSightTraceTable = util.Trace(TraceLineOfSight)
		
		local hitEntity = lineOfSightTraceTable.Entity
	
		if IsValid(hitEntity) and hitEntity:IsPlayer() and hitEntity:IsBot() and hitEntity.m_iTeamNum == activator.m_iTeamNum then
			local healedMaxHealth = hitEntity.m_iMaxHealth + hitEntity:GetAttributeValueByClass("add_maxhealth_nonbuffed", 0)
			+ hitEntity:GetAttributeValueByClass("add_maxhealth", 0)
			--code to consume metal taken from b8's tank repair script
		
			local METAL_TO_HEALTH_RATIO = 16
		
			if hitEntity:GetPlayerName() == "Giant VIP Heavy" then
				METAL_TO_HEALTH_RATIO = 8
			end
		
			--Metal before hit
			local oldMetal = activator.m_iAmmo[TF_AMMO_METAL]
		
			--metal after hit, tracked so you can't go into negative metal
			local newMetal = activator.m_iAmmo[TF_AMMO_METAL] - 20
			if newMetal < 0 then
				newMetal = 0
			end		
		
			local metalLost = (oldMetal - newMetal)
			hitEntity.m_iHealth = hitEntity.m_iHealth + 1 + (metalLost * METAL_TO_HEALTH_RATIO * activator:GetAttributeValueByClass("mult_repair_value", 1))
		
			hitEntity:TakeDamage({ -- make the bot take 1 damage so the sentry healthbar updates.
				Damage = 1,
				Attacker = activator,
				Weapon = none,
			})
		
			if hitEntity.m_iHealth < healedMaxHealth and metalLost > 0 then
				activator:PlaySoundToSelf("Weapon_Wrench.HitBuilding_Success")
				activator.m_iAmmo[TF_AMMO_METAL] = newMetal
			else
				activator:PlaySoundToSelf("Weapon_Wrench.HitBuilding_Failure")
			end
		
			if hitEntity.m_iHealth > healedMaxHealth then
				hitEntity.m_iHealth = healedMaxHealth
			end
		
			if IsValid(building) then	
				building.m_iHealth = bot.m_iHealth
			end
		end	
	util.FinishLagCompensation(activator)
end
