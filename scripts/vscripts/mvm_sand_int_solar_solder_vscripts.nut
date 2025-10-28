//M1 made ::BotMitosis, cleanup added later on by me. I also expanded it from 5 tags to 20, there was probably a better way to go about doing it but I do not care because this is my script.
::BotMitosis <-
{
    Cleanup = function() { delete ::BotMitosis} 
	OnGameEvent_recalculate_holidays = function(_) { if (GetRoundState() == 3) Cleanup() }
	OnGameEvent_mvm_wave_complete = function(_) { Cleanup() }
    function RunBotMitosis()
    {
        foreach (k, v in ::NetProps.getclass())
            if (k != "IsValid")
                getroottable()[k] <- ::NetProps[k].bindenv(::NetProps)

        local maxplayers = MaxClients().tointeger()
        for(local i = 1; i<=maxplayers; i++) {
            local player = PlayerInstanceFromIndex(i)
            if(!player) continue
            player.TerminateScriptScope()
            AddThinkToEnt(player,null)
        }

        local position = [Vector(),Vector(),Vector(),Vector(),Vector(),Vector(),Vector(),Vector(),Vector(),Vector(),Vector(),Vector(),Vector(),Vector(),Vector(),Vector(),Vector(),Vector(),Vector(),Vector()]

        local angle = 0

        local startrelay = Entities.FindByName(null, "wave_start_relay")

        //ClearGameEventCallbacks() //M1 said he has no clue what this does so I commented it out. I sure hope it isn't important!!! :clueless:
        function OnGameEvent_player_spawn(args) {
            local player = GetPlayerFromUserID(args.userid)
            if(GetPropBool(player,"m_bIsABot")) {
                local code = "if(self.HasBotTag(`bot_multiplied1`)) {self.Teleport(true, Vector(" + position[0].x + "," + position[0].y + "," + position[0].z + "), false, QAngle(), false, Vector()); self.AddCondEx(52, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_multiplied2`)) {self.Teleport(true, Vector(" + position[1].x + "," + position[1].y + "," + position[1].z + "), false, QAngle(), false, Vector()); self.AddCondEx(52, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_multiplied3`)) {self.Teleport(true, Vector(" + position[2].x + "," + position[2].y + "," + position[2].z + "), false, QAngle(), false, Vector()); self.AddCondEx(52, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_multiplied4`)) {self.Teleport(true, Vector(" + position[3].x + "," + position[3].y + "," + position[3].z + "), false, QAngle(), false, Vector()); self.AddCondEx(52, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_multiplied5`)) {self.Teleport(true, Vector(" + position[4].x + "," + position[4].y + "," + position[4].z + "), false, QAngle(), false, Vector()); self.AddCondEx(52, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_multiplied6`)) {self.Teleport(true, Vector(" + position[5].x + "," + position[5].y + "," + position[5].z + "), false, QAngle(), false, Vector()); self.AddCondEx(52, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_multiplied7`)) {self.Teleport(true, Vector(" + position[6].x + "," + position[6].y + "," + position[6].z + "), false, QAngle(), false, Vector()); self.AddCondEx(52, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_multiplied8`)) {self.Teleport(true, Vector(" + position[7].x + "," + position[7].y + "," + position[7].z + "), false, QAngle(), false, Vector()); self.AddCondEx(52, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_multiplied9`)) {self.Teleport(true, Vector(" + position[8].x + "," + position[8].y + "," + position[8].z + "), false, QAngle(), false, Vector()); self.AddCondEx(52, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_multiplied10`)) {self.Teleport(true, Vector(" + position[9].x + "," + position[9].y + "," + position[9].z + "), false, QAngle(), false, Vector()); self.AddCondEx(52, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_multiplied11`)) {self.Teleport(true, Vector(" + position[10].x + "," + position[10].y + "," + position[10].z + "), false, QAngle(), false, Vector()); self.AddCondEx(52, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_multiplied12`)) {self.Teleport(true, Vector(" + position[11].x + "," + position[11].y + "," + position[11].z + "), false, QAngle(), false, Vector()); self.AddCondEx(52, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_multiplied13`)) {self.Teleport(true, Vector(" + position[12].x + "," + position[12].y + "," + position[12].z + "), false, QAngle(), false, Vector()); self.AddCondEx(52, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_multiplied14`)) {self.Teleport(true, Vector(" + position[13].x + "," + position[13].y + "," + position[13].z + "), false, QAngle(), false, Vector()); self.AddCondEx(52, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_multiplied15`)) {self.Teleport(true, Vector(" + position[14].x + "," + position[14].y + "," + position[14].z + "), false, QAngle(), false, Vector()); self.AddCondEx(52, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_multiplied16`)) {self.Teleport(true, Vector(" + position[15].x + "," + position[15].y + "," + position[15].z + "), false, QAngle(), false, Vector()); self.AddCondEx(52, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_multiplied17`)) {self.Teleport(true, Vector(" + position[16].x + "," + position[16].y + "," + position[16].z + "), false, QAngle(), false, Vector()); self.AddCondEx(52, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_multiplied18`)) {self.Teleport(true, Vector(" + position[17].x + "," + position[17].y + "," + position[17].z + "), false, QAngle(), false, Vector()); self.AddCondEx(52, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_multiplied19`)) {self.Teleport(true, Vector(" + position[18].x + "," + position[18].y + "," + position[18].z + "), false, QAngle(), false, Vector()); self.AddCondEx(52, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_multiplied20`)) {self.Teleport(true, Vector(" + position[19].x + "," + position[19].y + "," + position[19].z + "), false, QAngle(), false, Vector()); self.AddCondEx(52, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)
            }
        }
        function OnGameEvent_player_death(args) {
            local player = GetPlayerFromUserID(args.userid)
            if(!GetPropBool(player,"m_bIsABot")) return
            if(player.HasBotTag("bot_multiplier1")) position[0] = player.GetOrigin()
            else if(player.HasBotTag("bot_multiplier2")) position[1] = player.GetOrigin()
            else if(player.HasBotTag("bot_multiplier3")) position[2] = player.GetOrigin()
            else if(player.HasBotTag("bot_multiplier4")) position[3] = player.GetOrigin()
            else if(player.HasBotTag("bot_multiplier5")) position[4] = player.GetOrigin()
            else if(player.HasBotTag("bot_multiplier6")) position[5] = player.GetOrigin()
            else if(player.HasBotTag("bot_multiplier7")) position[6] = player.GetOrigin()
            else if(player.HasBotTag("bot_multiplier8")) position[7] = player.GetOrigin()
            else if(player.HasBotTag("bot_multiplier9")) position[8] = player.GetOrigin()
            else if(player.HasBotTag("bot_multiplier10")) position[9] = player.GetOrigin()
            else if(player.HasBotTag("bot_multiplier11")) position[10] = player.GetOrigin()
            else if(player.HasBotTag("bot_multiplier12")) position[13] = player.GetOrigin()
            else if(player.HasBotTag("bot_multiplier13")) position[14] = player.GetOrigin()
            else if(player.HasBotTag("bot_multiplier14")) position[15] = player.GetOrigin()
            else if(player.HasBotTag("bot_multiplier15")) position[16] = player.GetOrigin()
            else if(player.HasBotTag("bot_multiplier16")) position[17] = player.GetOrigin()
            else if(player.HasBotTag("bot_multiplier17")) position[18] = player.GetOrigin()
            else if(player.HasBotTag("bot_multiplier18")) position[16] = player.GetOrigin()
            else if(player.HasBotTag("bot_multiplier19")) position[17] = player.GetOrigin()
            else if(player.HasBotTag("bot_multiplier20")) position[18] = player.GetOrigin()
        }
        __CollectGameEventCallbacks(this)
    }
}

BotMitosis.RunBotMitosis()

        ::PostPlayerSpawn <- function() // Thanks Chrstin!
        {    
            if(self.HasBotTag("bot_teleporter_fused") == true) {
                for (local wearable = self.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
            {
            if (wearable.GetClassname() != "tf_wearable")
                continue
                if ((wearable.GetModelName()) == "models/player/items/demo/crown.mdl")
                {
                    local modelIndex = GetModelIndex("models/buildables/teleporter_light.mdl")
                if (modelIndex == -1)
                        modelIndex = PrecacheModel("models/buildables/teleporter_light.mdl")
                    NetProps.SetPropInt(wearable, "m_nModelIndex", modelIndex)
                    NetProps.SetPropFloat(wearable,"m_flModelScale",3)
                    //here lies every failed attempt to put it on the head.
                    // NetProps.SetPropInt(wearable, "m_fEffects", 129)
                    // wearable.AcceptInput("SetParentAttachment","head",self,self)
                    //NetProps.SetPropInt(wearable, "m_fEffects", true ? EF_BONEMERGE|EF_BONEMERGE_FASTCULL : 0)
                    //^ game throws an errr asking what ef_bonemerge is so i guess i cant steal from popext.
                    //EntFireByHandle(wearable, "SetParentAttachment", "head", 0.1, self, self)
                    // NetProps.SetPropInt(wearable, "m_fEffects", NetProps.GetPropInt(wearable, "m_fEffects") & ~(1 | 128))
                    // wearable.SetLocalOrigin(self.EyePosition() - wearable.GetOrigin())
                    NetProps.SetPropInt(wearable, "m_fEffects", 0)
                    wearable.AcceptInput("SetParentAttachment","head",self,self) // Thanks ocet247!
                }
                if ((wearable.GetModelName()) == "models/player/items/all_class/awes_badge.mdl")
                {
                    local modelIndex = GetModelIndex("models/buildables/teleporter_light.mdl")
                if (modelIndex == -1)
                        modelIndex = PrecacheModel("models/buildables/teleporter_light.mdl")
                    NetProps.SetPropInt(wearable, "m_nModelIndex", modelIndex)
                    NetProps.SetPropFloat(wearable,"m_flModelScale",3)
                    NetProps.SetPropInt(wearable, "m_fEffects", 0)
                    wearable.AcceptInput("SetParentAttachment","head",self,self) // Thanks ocet247!
                }
            }    
                self.RemoveBotTag("bot_teleporter_fused")
            }
        }
        function OnGameEvent_player_spawn(params)
        {
            if(params.team == 3) //Is the player blue
            {
                local player = GetPlayerFromUserID(params.userid)
                EntFireByHandle(player, "CallScriptFunction", "PostPlayerSpawn", 0, null, null);
            }
        }
        __CollectGameEventCallbacks(this)
