EntFire("xdd","Kill")
	
::PostPlayerSpawn <- function()
{
    if(self.HasBotTag("tank_icon") == true) {
		self.SetOrigin(Vector(-1604,-173,-500))
		self.RemoveBotTag("tank_icon")
	}
	
	if(self.HasBotTag("buster") == true) {	
		for (local wearable = self.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
	{
    if (wearable.GetClassname() != "tf_wearable")
        continue
		if ((wearable.GetModelName()) == "models/player/items/demo/crown.mdl")
		{
		wearable.ValidateScriptScope()
        local scope = wearable.GetScriptScope()
		local modelIndex = GetModelIndex("models/weapons/w_models/w_baseball.mdl")
		if (modelIndex == -1)
		modelIndex = PrecacheModel("models/weapons/w_models/w_baseball.mdl")
		NetProps.SetPropInt(wearable, "m_fEffects", 0)
        wearable.AcceptInput("SetParentAttachment","head",self,self)
		NetProps.SetPropInt(wearable, "m_nModelIndex", modelIndex)
		NetProps.SetPropFloat(wearable,"m_flModelScale",3.2)

			scope.BotModelThink <- function() {
			local owner = self.GetMoveParent()
        	if(NetProps.GetPropInt(owner, "m_lifeState") != 0){self.Kill()}
          	return -1
        	}
        	AddThinkToEnt(wearable, "BotModelThink")
		}
	self.RemoveBotTag("buster")
	}
	}
}	
		
function OnGameEvent_player_spawn(params)
{
	if(params.team == 3) //Is the player blue
	{
		local player = GetPlayerFromUserID(params.userid)
		player.SetOrigin(player.GetOrigin()+Vector(0,0,16)) //Teleport player 16 units up
		EntFireByHandle(player, "CallScriptFunction", "PostPlayerSpawn", 0, null, null);
	}
}

__CollectGameEventCallbacks(this)
