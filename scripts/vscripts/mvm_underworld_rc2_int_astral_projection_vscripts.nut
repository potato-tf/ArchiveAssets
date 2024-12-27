//thanks to all others who did stuff for me. i am ceo of clueless.

//Make all the arrows red. Because.
EntFire("bombpath_holograms*","color","255 50 50") //Chrstin told me how to do these.
//Make the bomb into the Halloween Pass-Time JACK.
EntFire("intel","setmodel","models/passtime/ball/passtime_ball_halloween.mdl") //PDA Expert helped here.
EntFire("intel","setmodelscale",1.3) //Yoovy's mission "Boneworks", a 666 Medieval Intermediate on Mannworks inspired this btw.
//Here: https://testing.potato.tf/tf/scripts/population/mvm_mannworks_int_boneworks.pop

//function7
//lol just a changeattributes relay i prob could've put this in the pop but i don't care.
//anyway thanks for brain for pointing me to dynamic disaster for this.
//Seelpit's Icon Manipulator Script (SINS) used here btw.
//THE only remainder of astral projection redux v1. I made/repurposed six goddamn functions before this and they're all obsolete now.
function SpawnChangeAttributes()
{
	IncludeScript("seel_ins",getroottable())
	SpawnEntityFromTable("point_populator_interface" , {
			targetname = "pop_interface"
	})
	SpawnEntityFromTable("logic_relay" , {
			targetname = "boss_changeattributes_relay"
			spawnflags = 2
			"OnTrigger#1": "pop_interface,ChangeBotAttributes,Attr1,0.1,-1"
			"OnTrigger#2": "pop_interface,ChangeBotAttributes,Attr2,8.1,-1"
			"OnTrigger#3": "pop_interface,ChangeBotAttributes,Attr3,16.1,-1"
			"OnTrigger#4": "boss_changeattributes_relay,EnableRefire,,20,-1"
			"OnTrigger#5": "boss_changeattributes_relay,Trigger,,24.1,-1"
			//Icon Changing:
			"OnTrigger#6": "gamerules,CallScriptFunction,ChangeBossIconA,0.1,-1" //ent, action, param, delay, -1
			"OnTrigger#7": "gamerules,CallScriptFunction,ChangeBossIconB,8.1,-1"
			"OnTrigger#8": "gamerules,CallScriptFunction,ChangeBossIconC,16.1,-1"
	}) //"pop_interfaceRunScriptCodeSINS.ChangeIconByTag("boss_soldier","soldier_burstfire")0-1"
	::ChangeBossIconA <- function()
	{
		SINS.ChangeIconByTag("boss_soldier","soldier_infinite_blast",false)
	}
	::ChangeBossIconB <- function()
	{
		SINS.ChangeIconByTag("boss_soldier","soldier_burstfire",false)
	}
	::ChangeBossIconC <- function()
	{
		SINS.ChangeIconByTag("boss_soldier","soldier_spammer_burstfire",false)
	}
	//well since there's already a w7 specific function... don't mind if i do!
	//Royal's cool epic boss text
	SpawnEntityFromTable("game_text", {
		targetname = "top_text"
		message = "WRITHING MASS"
		x = -1
		y = 0.4
		spawnflags = 1
		effect = 2
		channel = 2
		color = "255 255 255"
		fxtime = 0.2
		fadeout = 1
		holdtime = 5
	})
	SpawnEntityFromTable("game_text", {
		targetname = "bottom_text"
		message = "SOUL HIVE"
		x = -1
		y = 0.45
		spawnflags = 1
		effect = 2
		channel = 3
		color = "255 255 255"
		fxtime = 0.2
		fadeout = 1
		holdtime = 4.8
	})
}

//function8
//literally just precaching models and sounds. Don't mind me.
function Precache()
{
	PrecacheSound("misc/halloween/skeleton_break.wav") //Will not play otherwise.

	PrecacheModel("models/bots/boss_bot/paintable_tank_v2/boss_tank.mdl") //Must be precached.
	PrecacheModel("models/bots/boss_bot/paintable_tank_v2/boss_tank_damage1.mdl")
	PrecacheModel("models/bots/boss_bot/paintable_tank_v2/boss_tank_damage2.mdl")
	PrecacheModel("models/bots/boss_bot/paintable_tank_v2/boss_tank_damage3.mdl")
	PrecacheModel("models/bots/boss_bot/paintable_tank_v2/tank_track_L.mdl")
	PrecacheModel("models/bots/boss_bot/paintable_tank_v2/tank_track_R.mdl")
	PrecacheModel("models/bots/boss_bot/paintable_tank_v2/bomb_mechanism.mdl")

	if(Entities.FindByName(null, "tankprecache") == null) //If these props exist don't spawn them in.
	{
		SpawnEntityGroupFromTable({		
			ModelA1 = {
				prop_dynamic = {
					model = "models/bots/boss_bot/paintable_tank_v2/boss_tank.mdl"
					targetname = "tankprecache"
					modelscale = "0.0"
					skin = "0"
					origin = "260 4600 -30"
				}
			}
			ModelB1 = {
				prop_dynamic = {
					model = "models/bots/boss_bot/paintable_tank_v2/boss_tank_damage1.mdl"
					targetname = "tankprecache"
					modelscale = "0.0"
					skin = "0"
					origin = "260 4600 -30"
				}
			}
			ModelC1 = {
				prop_dynamic = {
					model = "models/bots/boss_bot/paintable_tank_v2/boss_tank_damage2.mdl"
					targetname = "tankprecache"
					modelscale = "0.0"
					skin = "0"
					origin = "260 4600 -30"
				}
			}
			ModelD1 = {
				prop_dynamic = {
					model = "models/bots/boss_bot/paintable_tank_v2/boss_tank_damage3.mdl"
					targetname = "tankprecache"
					modelscale = "0.0"
					skin = "0"
					origin = "260 4600 -30"
				}
			}
			ModelA2 = {
				prop_dynamic = {
					model = "models/bots/boss_bot/paintable_tank_v2/boss_tank.mdl"
					targetname = "tankprecache"
					modelscale = "0.0"
					skin = "1"
					origin = "260 4600 -30"
				}
			}
			ModelB2 = {
				prop_dynamic = {
					model = "models/bots/boss_bot/paintable_tank_v2/boss_tank_damage1.mdl"
					targetname = "tankprecache"
					modelscale = "0.0"
					skin = "1"
					origin = "260 4600 -30"
				}
			}
			ModelC2 = {
				prop_dynamic = {
					model = "models/bots/boss_bot/paintable_tank_v2/boss_tank_damage2.mdl"
					targetname = "tankprecache"
					modelscale = "0.0"
					skin = "1"
					origin = "260 4600 -30"
				}
			}
			ModelD2 = {
				prop_dynamic = {
					model = "models/bots/boss_bot/paintable_tank_v2/boss_tank_damage3.mdl"
					targetname = "tankprecache"
					modelscale = "0.0"
					skin = "1"
					origin = "260 4600 -30"
				}
			}
			ModelE = {
				prop_dynamic = {
					model = "models/bots/boss_bot/paintable_tank_v2/tank_track_L.mdl"
					targetname = "tankprecache"
					modelscale = "0.0"
					origin = "260 4600 -30"
				}
			}
			ModelF = {
				prop_dynamic = {
					model = "models/bots/boss_bot/paintable_tank_v2/tank_track_R.mdl"
					targetname = "tankprecache"
					modelscale = "0.0"
					origin = "260 4600 -30"
				}
			}
			ModelG = {
				prop_dynamic = {
					model = "models/bots/boss_bot/paintable_tank_v2/bomb_mechanism.mdl"
					targetname = "tankprecache"
					modelscale = "0.0"
					origin = "260 4600 -30"
				}
			}
		})
	}
}

//function9
//The Raveyard.
function FinaleGraveyard()
{
	PrecacheModel("models/props_manor/gravestone_02.mdl")
	PrecacheModel("models/props_manor/gravestone_01.mdl")
	PrecacheModel("models/props_manor/gravestone_04.mdl")
	PrecacheModel("models/props_manor/gravestone_07.mdl")
	
	SendGlobalGameEvent("show_annotation", { //add a pointer prewave, removed in the pop itself
        text = "Grave"
        lifetime = -1
        worldPosX = 655
        worldPosY = 515
        worldPosZ = 284
        id = 112
        play_sound = "misc/null.wav" //655 515 284
    })
	SendGlobalGameEvent("show_annotation", { //add a pointer prewave, removed in the pop itself
        text = "Grave"
        lifetime = -1
        worldPosX = -950
        worldPosY = 1500
        worldPosZ = 270
        id = 113
        play_sound = "misc/null.wav" //-950 1500 270
    })
	SendGlobalGameEvent("show_annotation", { //add a pointer prewave, removed in the pop itself
        text = "Skeletons will rise from graves!"
        lifetime = 15 //-1
        worldPosX = 0
        worldPosY = 1100
        worldPosZ = -100
        id = 111
        play_sound = "misc/null.wav" //0 1100 100
    })

	SpawnEntityGroupFromTable({
		Grave1 = {
			prop_dynamic = {
				model = "models/props_manor/gravestone_02.mdl"
				targetname = "Grave"
				origin = "-920 1535 208"
				angles = "0 90 0"
				disableshadows = "1"
			}
		}
		Grave2 = {
			prop_dynamic = {
				model = "models/props_manor/gravestone_01.mdl"
				targetname = "Grave"
				origin = "-990 1495 216"
				angles = "0 -45 -5"
				disableshadows = "1"
			}
		}
		Grave3 = {
			prop_dynamic = {
				model = "models/props_manor/gravestone_04.mdl"
				targetname = "Grave"
				modelscale = "0.7"
				origin = "626 454 210"
				angles = "0 135 0"
				disableshadows = "1"
			}
		}
		Grave4 = {
			prop_dynamic = {
				model = "models/props_manor/gravestone_07.mdl"
				targetname = "Grave"
				modelscale = "0.5"
				origin = "709 540 216"
				angles = "0 45 0"
				disableshadows = "1"
			}
		}
	})
}
