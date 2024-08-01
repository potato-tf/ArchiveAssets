//written by watermelon
::milkRepellent <- {
	cleanup = function() {
		EntFire("milkRepellent", "kill") //this is only relevant for wave complete
		delete ::milkRepellent
    }
	
	OnGameEvent_recalculate_holidays = function(_) {if(GetRoundState() == 3) cleanup()}
	OnGameEvent_mvm_wave_complete = function(_) {cleanup()}
	
	OnGameEvent_player_spawn = function(params) {
		local player = GetPlayerFromUserID(params.userid)
		if(player.GetTeam() == 2) return
		
		EntFire("milkRepellent", "callscriptfunction", "checkBot", -1, player)
	}
}
__CollectGameEventCallbacks(milkRepellent)

local logicScript = SpawnEntityFromTable("logic_script", {
	targetname = "milkRepellent"
})
logicScript.ValidateScriptScope()
IncludeScript("milkrepellentthink.nut", logicScript.GetScriptScope())
AddThinkToEnt(logicScript, "think")