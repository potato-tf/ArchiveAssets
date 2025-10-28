::ROOT <- getroottable();
if (!("ConstantNamingConvention" in ROOT)) // make sure folding is only done once
{
	foreach (a,b in Constants)
		foreach (k,v in b)
			if (v == null)
				ROOT[k] <- 0;
			else
				ROOT[k] <- v;
}

foreach (k, v in NetProps.getclass())
    if (k != "IsValid")
        ROOT[k] <- NetProps[k].bindenv(NetProps);

::TF_STUN_MOVEMENT <- 1
::TF_STUN_CONTROLS <- 2
::TF_STUN_NO_EFFECTS <- 32

::MiningOp <-
{
    Cleanup = function()
    {
        // cleanup any persistent changes here
        printl("Cleaning up MiningOp...")
        EntFire("operating_her_mine","UnpauseBotSpawning",0.03)
		// keep this at the end
        delete ::MiningOp
    }
	
    // mandatory events
    OnGameEvent_recalculate_holidays = function(_)
	{ if (GetRoundState() == 3) Cleanup() }
    OnGameEvent_mvm_wave_complete = function(_)
	{ Cleanup() }
	
	ALL_PLAYERS = MaxClients().tointeger()
	
	BossDeath = function(sTag)
	{
		local CTriggerHurt = Entities.CreateByClassname("trigger_hurt") //Is that the REAL CTriggerHurt?!
		CTriggerHurt.DispatchSpawn()
		for (local i = 1; i <= ALL_PLAYERS ; i++) //For all bots except those with sTag,
		{
			local hPlayer = PlayerInstanceFromIndex(i)
			if (hPlayer == null) continue
			if ( !(hPlayer.IsBotOfType(TF_BOT_TYPE)) ) continue
			if ( !(hPlayer.IsAlive()) ) continue
			if ( hPlayer.HasBotTag(sTag) ) continue;
			// Kill all living bots.
			hPlayer.TakeDamage(7175, 0, CTriggerHurt)
			
		}
		hInterface.AcceptInput("PauseBotSpawning","",null,null)
		EntFire("operating_her_mine","UnpauseBotSpawning","",10)
	}
}
__CollectGameEventCallbacks(MiningOp);

if ( !("hInterface" in MiningOp) )
	MiningOp.hInterface <- SpawnEntityFromTable("point_populator_interface",
	{
		targetname = "operating_her_mine"
	})
