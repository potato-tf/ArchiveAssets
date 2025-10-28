// original "area52_newspawnbot.nut" written by PDA Expert

function blazeforwardspawn()
{
    SpawnEntityFromTable("info_teleport_destination" {
	    origin = "-2171 -2735 -80"
		angles = "0 0 0"
	    targetname = "spawnbot_main1_short"
		}
	)
	
	local teleport_trigger = SpawnEntityFromTable("trigger_teleport" {
	    origin = "-3303.58 -2100.01 234.5"
		target = "spawnbot_main1_short"
		targetname = "spawnbot_main1_short_teleport"
		SpawnFlags = "1"
		filtername = "filter_blueteam"
		}
	)
	
	teleport_trigger.KeyValueFromInt("solid", 2)
	teleport_trigger.KeyValueFromString("mins", "-429 -510 -134.5")
	teleport_trigger.KeyValueFromString("maxs", "429 510 134.5")
}

if(Entities.FindByName(null, "spawnbot_main1_short") == null) 
{
    printl("Spawnbot Teleporter 1 has been created!")
    blazeforwardspawn()
}

function blazeforwardspawn2()
{
    SpawnEntityFromTable("info_teleport_destination" {
	    origin = "2177 -2402 2"
		angles = "0 90 0"
	    targetname = "spawnbot_main2_short"
		}
	)
	
	local teleport_trigger = SpawnEntityFromTable("trigger_teleport" {
	    origin = "2682 -3511 80"
		target = "spawnbot_main2_short"
		targetname = "spawnbot_main2_short_teleport"
		SpawnFlags = "1"
		filtername = "filter_blueteam"
		}
	)
	
	teleport_trigger.KeyValueFromInt("solid", 2)
	teleport_trigger.KeyValueFromString("mins", "-971 -914 -80")
	teleport_trigger.KeyValueFromString("maxs", "971 914 80")
}

if(Entities.FindByName(null, "spawnbot_main2_short") == null) 
{
    printl("Spawnbot Teleporter 2 has been created!")
    blazeforwardspawn2()
}

function blazeforwardspawn3()
{
    SpawnEntityFromTable("info_teleport_destination" {
	    origin = "-2162 -1330 1"
		angles = "0 90 0"
	    targetname = "spawnbot_main3_short"
		}
	)
	
	local teleport_trigger = SpawnEntityFromTable("trigger_teleport" {
	    origin = "-1849.5 -1675.5 -30.5"
		target = "spawnbot_main3_short"
		targetname = "spawnbot_main3_short_teleport"
		SpawnFlags = "1"
		filtername = "filter_blueteam"
		}
	)
	
	teleport_trigger.KeyValueFromInt("solid", 2)
	teleport_trigger.KeyValueFromString("mins", "-134 -164 -134")
	teleport_trigger.KeyValueFromString("maxs", "134 164 134")
}

if(Entities.FindByName(null, "spawnbot_main3_short") == null) 
{
    printl("Spawnbot Teleporter 3 has been created!")
    blazeforwardspawn3()
}

//