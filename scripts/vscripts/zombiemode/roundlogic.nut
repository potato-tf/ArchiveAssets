player_count <- 0;                        	// how many players we have
players_counted <- 0;                        // how many players we counted last time
zombie_count <- 4.5;                       	// how many zombies do we have to spawn
special_count <- 0;							// for boss rounds
round_number <- 0;
max_active <- (MaxClients().tointeger() - 11)
boss_timer <- RandomInt(5,6);
boss_multiplier <- 0						//	how many times has boss round come around
spawn_interval <- 1.90; 					// starting value, gap between spawns
local sfx_roundstart_normal = Entities.FindByName(null, "snd_start")
local sfx_roundstart_boss = Entities.FindByName(null, "snd_start_boss")

if (max_active > 24) max_active = 24

::ZM_SetupRound <- function() {

	IncrementWaveNumber();
    ZM_GetPlayerCount();
	if (boss_timer > 0)
	{
		SpawnEntityFromTable("point_commentary_node", {origin = "92 -598 -741"})
		if (round_number == 1)
		{
			local player_multiplier = 1.5 * player_count
			zombie_count = zombie_count + player_multiplier
			SpawnEntityFromTable("point_commentary_node", {origin = "92 -598 -741"})
			MissionAttributes.SetConvar("tf_bot_taunt_victim_chance",0);
			local text_gameover = Entities.FindByName(null, "text_gameover")
			local text_gameover_2 = Entities.FindByName(null, "text_gameover_2")
			text_gameover.AcceptInput("AddOutput","y 0.4",null,null)
			text_gameover_2.AcceptInput("AddOutput","y -1",null,null)
			Entities.FindByName(null, "respawner").AcceptInput("ForceTeamRespawn","2",null,null)
			Entities.FindByName(null, "checkpoint_relay").AcceptInput("AddOutput","OnTrigger gameover_relay:CancelPending::0:-1",null,null)
			Entities.FindByName(null, "gameover_relay").AcceptInput("AddOutput","OnTrigger fade_out:Fade::21:-1",null,null)
			delete GlobalFixes.TakeDamageTable.HolidayPunchFix
			spawn_interval = spawn_interval - (0.04 * player_count)
			if (player_count > 4)
			{
				Entities.FindByName(null,"quickrev_math").AcceptInput("SetValue","5",null,null)
			}
		}
		if (round_number > 1)
		{
			zombie_count = zombie_count * 1.2
			if (zombie_count > 255) zombie_count = 255
		}
		if (round_number <= 25)
		{
			spawn_interval = spawn_interval - 0.04
		}
		NetProps.SetPropInt(PopExtUtil.ObjectiveResource, "m_nMannVsMachineWaveClassCounts", zombie_count)
		NetProps.SetPropInt(PopExtUtil.ObjectiveResource, "m_nMannVsMachineWaveEnemyCount", zombie_count)
		// spawn a bot_generator later with values from here
		local generator = SpawnEntityFromTable("bot_generator"
		{
			useTeamSpawnPoint = 1
			maxActive = max_active
			difficulty = 2
			disableDodge = 1
			interval = spawn_interval // gap between spawns, adjust to be faster per wave?
	//		spawnflags = 512 // ignore sentries
			count = zombie_count
			team = "blue"
			targetname = "bot_spawner"
			"OnExpended#1" : "roundend_check,Trigger,,0,-1"
		})
		NetProps.SetPropString(generator, "m_className", "heavyweapons") // class is a reserved kv so we have to do this workaround to appease squirrel god
		EntFireByHandle(sfx_roundstart_normal,"playsound","",0,null,null);
		EntFireByHandle(Entities.FindByName(null, "bot_spawner"),"setdisabledodge","1",0,null,null);
	}
	if (boss_timer == 0)
	{
		EntFireByHandle(sfx_roundstart_boss,"playsound","",0,null,null);
		special_count = (6 + player_count * 2) + boss_multiplier
		if (special_count > 255) special_count = 255
		NetProps.SetPropInt(PopExtUtil.ObjectiveResource, "m_nMannVsMachineWaveClassCounts", special_count)
		NetProps.SetPropInt(PopExtUtil.ObjectiveResource, "m_nMannVsMachineWaveEnemyCount", special_count)
		SpawnEntityFromTable("point_commentary_node", {origin = "92 -598 -741"})
		boss_multiplier = special_count * 1.3
		local generator = SpawnEntityFromTable("bot_generator"
		{
			useTeamSpawnPoint = 1
			maxActive = max_active
			difficulty = 3
			disableDodge = 1
			interval = 1.3 // gap between spawns, adjust to be faster per wave?
	//		spawnflags = 512 // ignore sentries
			count = special_count
			team = "blue"
			targetname = "bot_spawner_boss"
			"OnExpended#1" : "roundend_check_boss,Trigger,,0,-1"
		})
		NetProps.SetPropString(generator, "m_className", "sniper") // class is a reserved kv so we have to do this workaround to appease squirrel god
		EntFireByHandle(Entities.FindByName(null, "bot_spawner_boss"),"setdisabledodge","1",0,null,null);
		boss_timer = RandomInt(5,6)
	}
}
function ZM_GetPlayerCount()
{
	if (!PopExtUtil.IsWaveStarted) return
	player_count = 0 // reset player_count before doing re-count

    foreach (player in PopExtUtil.HumanArray)
	{
		player_count++
		if ("Preserved" in player.GetScriptScope()) player.GetScriptScope().Preserved.timesrepaired = 0	// reset their barricade cap here while we're doing a headcount
	}
	if (round_number == 1) players_counted = player_count
	if (round_number > 1)
	{
		if (player_count > players_counted)
		{
			local diff = player_count - players_counted
			zombie_count = zombie_count + (1.5 * diff)
		}
		if (player_count < players_counted)
		{
			local diff2 = players_counted - player_count
			zombie_count = zombie_count - (1.5 * diff2)
		}
		players_counted = player_count
	}
}

function IncrementWaveNumber()
{
	local text_gameover_2 = Entities.FindByName(null, "text_gameover_2")
	round_number = NetProps.GetPropInt(PopExtUtil.ObjectiveResource, "m_nMannVsMachineWaveCount")
	round_number+= 1
	NetProps.SetPropInt(PopExtUtil.ObjectiveResource, "m_nMannVsMachineWaveCount", round_number)
	NetProps.SetPropString(text_gameover_2, "m_iszMessage", format("You survived %d waves", (round_number-1)))
	boss_timer -= 1
	ResetPowerupCount()
}