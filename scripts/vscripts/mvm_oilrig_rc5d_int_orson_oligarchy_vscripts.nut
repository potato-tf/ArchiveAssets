//runs automatically
//NetProps.SetPropString(Entities.FindByClassname(null, "tf_objective_resource"), "m_iszMvMPopfileName", "(Intermediate) Expedited Refinement")
//^ sets mission name, but more concise.
//thx for help from m1 and ficool2 and fellen
::ExtraSpawnPoints <-
{
	Cleanup = function() { delete ::ExtraSpawnPoints; NavMesh.GetNavAreaByID(27).ClearAttributeTF(4) } 
	OnGameEvent_recalculate_holidays = function(_) { if (GetRoundState() == 3) Cleanup() }
	OnGameEvent_mvm_wave_complete = function(_) { Cleanup() }
	//^cleanup stuff idk ask ficool2
	

	function OnGameEvent_player_spawn(args) {
		local player = GetPlayerFromUserID(args.userid)
		if(NetProps.GetPropBool(player,"m_bIsABot")) {
			EntFireByHandle(player,"runscriptcode","if(self.HasBotTag(`spawnbot_mid`))self.Teleport(true,Vector(-330,-5270,1130),false,QAngle(),false,Vector())",-1,null,null)
			EntFireByHandle(player,"runscriptcode","if(self.HasBotTag(`spawnbot_titan`))self.Teleport(true,Vector(-1875,-4200,200),false,QAngle(),false,Vector())",-1,null,null)
            //^scale 15.
        }
	}
	OnGameEvent_player_death = function(params)
    {
        local player = GetPlayerFromUserID(params.userid)
        if (!player) return
        AddThinkToEnt(player, null)
    }
	//Provided by fellen of potato.tf discord. The only line i actually ended up using anyway.
	function SetupMidSpawn()
    {
        //local midspawn = SpawnEntityFromTable("func_respawnroom",
        //{
            //origin = "-520 -5450 1063"
            //TeamNum = 3
        //})
        //midspawn.SetSize(Vector(), Vector(400, 410, 200)) //Set size of the trigger.
		//^ this is all unecessary lmao
        NavMesh.GetNavAreaByID(27).SetAttributeTF(4) // Mark tank spawn nav square as BLU spawn
    }
} __CollectGameEventCallbacks(ExtraSpawnPoints)

ExtraSpawnPoints.SetupMidSpawn() //set up the nav square.

//next bit is wholly by M1, except the cleanup.
::TankBotMitosisBS <-
{
    Cleanup = function() { delete ::TankBotMitosisBS} 
	OnGameEvent_recalculate_holidays = function(_) { if (GetRoundState() == 3) Cleanup() }
	OnGameEvent_mvm_wave_complete = function(_) { Cleanup() }
    function RunTheBS()
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

        local position = [Vector(),Vector(),Vector(),Vector(),Vector()]

        local carposition = [Vector(), Vector()]

        local angle = 0

        local startrelay = Entities.FindByName(null, "wave_start_relay")
        AddThinkToEnt(startrelay, "CheckCarPosition")


        //ClearGameEventCallbacks() //M1 said he has no clue what this does so I commented it out. I sure hope it isn't important!!! :clueless:
        function OnGameEvent_player_spawn(args) {
            local player = GetPlayerFromUserID(args.userid)
            if(GetPropBool(player,"m_bIsABot")) {
                local code = "if(self.HasBotTag(`bot_multiplied1`)) {self.Teleport(true, Vector(" + position[0].x + "," + position[0].y + "," + position[0].z + "), false, QAngle(), false, Vector()); self.AddCondEx(51, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_multiplied2`)) {self.Teleport(true, Vector(" + position[1].x + "," + position[1].y + "," + position[1].z + "), false, QAngle(), false, Vector()); self.AddCondEx(51, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_multiplied3`)) {self.Teleport(true, Vector(" + position[2].x + "," + position[2].y + "," + position[2].z + "), false, QAngle(), false, Vector()); self.AddCondEx(51, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_multiplied4`)) {self.Teleport(true, Vector(" + position[3].x + "," + position[3].y + "," + position[3].z + "), false, QAngle(), false, Vector()); self.AddCondEx(51, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_multiplied5`)) {self.Teleport(true, Vector(" + position[4].x + "," + position[4].y + "," + position[4].z + "), false, QAngle(), false, Vector()); self.AddCondEx(51, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)


                code = "if(self.HasBotTag(`bot_clowncar1`)) {self.Teleport(true, Vector(" + carposition[0].x + "," + carposition[0].y + "," + carposition[0].z + "), false, QAngle(), false, Vector()); self.AddCondEx(51, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_clowncar2`)) {self.Teleport(true, Vector(" + carposition[1].x + "," + carposition[1].y + "," + carposition[1].z + "), false, QAngle(), false, Vector()); self.AddCondEx(51, 1.0, null)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                local randomdir = [800*cos(angle), 800*sin(angle), 200]
                angle += 3.8832 //pi/phi
                code = "if(self.HasBotTag(`bot_clowncarexplode`)) {self.Teleport(true, Vector(" + carposition[1].x + "," + carposition[1].y + "," + (carposition[1].z+10) + "), false, QAngle(), true, Vector(" + randomdir[0] + "," + randomdir[1] + "," + randomdir[2] + ")); self.AddCondEx(51, 1.0, null)}"
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
        }
        __CollectGameEventCallbacks(this)


        ::CheckCarPosition <- function()
        {
            local carent = Entities.FindByName(null, "clowncar_position1")
            if(carent) {
                carposition[0] = carent.GetOrigin()
            }

            carent = Entities.FindByName(null, "clowncar_position2")
            if(carent) {
                carposition[1] = carent.GetOrigin()
            }

            carent = Entities.FindByName(null, "clowncar_positionexplode")
            if(carent) {
                carposition[1] = carent.GetOrigin()
            }
            return 0.5
        }
    }
}

TankBotMitosisBS.RunTheBS()

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


function MakeMapChanges() //they're off centre. oh i also gave em a colour to justify it.
{
    if(Entities.FindByName(null, "repeatrun_checker") == null) //don't re-run everything outside of wave fail.
	{
			SpawnEntityFromTable("logic_relay", {
            targetname = "repeatrun_checker"
        })
        EntFire("bombpath_arrows_right","kill") 
        EntFire("bombpath_arrows_left","kill")
        //honestly cba with spawnentitygroupfromtable and that's the only reason why im not using it
        //RIGHTPATH HOLOS
		SpawnEntityFromTable("prop_dynamic",
		{
			targetname = "bombpath_arrows_right_custom"
			origin = "-327.624 -3780 1024.05"
            angles = "0 90 0"
			model = "models/props_mvm/robot_hologram.mdl"
			rendercolor = "100 100 100"
            startdisabled = 1
            disableshadows = 1
		})
		SpawnEntityFromTable("prop_dynamic",
		{
			targetname = "bombpath_arrows_right_custom"
			origin = "-330.006 -2725 1088.05"
            angles = "0 45 0"
			model = "models/props_mvm/robot_hologram.mdl"
			rendercolor = "100 100 100"
            startdisabled = 1
            disableshadows = 1
		})
		SpawnEntityFromTable("prop_dynamic",
		{
			targetname = "bombpath_arrows_right_custom"
			origin = "384 -2544 1088.05"
            angles = "0 45 0"
			model = "models/props_mvm/robot_hologram.mdl"
			rendercolor = "100 100 100"
            startdisabled = 1
            disableshadows = 1
		})
		SpawnEntityFromTable("prop_dynamic",
		{
			targetname = "bombpath_arrows_right_custom"
			origin = "706.553 -2000 1088.05"
            angles = "0 90 0"
			model = "models/props_mvm/robot_hologram.mdl"
			rendercolor = "100 100 100"
            startdisabled = 1
            disableshadows = 1
		})
		SpawnEntityFromTable("prop_dynamic",
		{
			targetname = "bombpath_arrows_right_custom"
			origin = "616 -1232 1088.05"
            angles = "0 90 0"
			model = "models/props_mvm/robot_hologram.mdl"
			rendercolor = "100 100 100"
            startdisabled = 1
            disableshadows = 1
		})
        
        //LEFTPATH HOLOS
        SpawnEntityFromTable("prop_dynamic",
		{
			targetname = "bombpath_arrows_left_custom"
			origin = "-327.624 -3780 1024.05"
            angles = "0 90 0"
			model = "models/props_mvm/robot_hologram.mdl"
			rendercolor = "100 100 100"
            startdisabled = 1
            disableshadows = 1
		})
        SpawnEntityFromTable("prop_dynamic",
		{
			targetname = "bombpath_arrows_left_custom"
			origin = "-330.006 -2725 1088.05"
            angles = "0 135 0"
			model = "models/props_mvm/robot_hologram.mdl"
			rendercolor = "100 100 100"
            startdisabled = 1
            disableshadows = 1
		})
        SpawnEntityFromTable("prop_dynamic",
		{
			targetname = "bombpath_arrows_left_custom"
			origin = "-784 -2343.8401 1088.05"
            angles = "0 104.5 0"
			model = "models/props_mvm/robot_hologram.mdl"
			rendercolor = "100 100 100"
            startdisabled = 1
            disableshadows = 1
		})
        SpawnEntityFromTable("prop_dynamic",
		{
			targetname = "bombpath_arrows_left_custom"
			origin = "-784 -1624 1088.05"
            angles = "0 74 0"
			model = "models/props_mvm/robot_hologram.mdl"
			rendercolor = "100 100 100"
            startdisabled = 1
            disableshadows = 1
		})
        SpawnEntityFromTable("prop_dynamic",
		{
			targetname = "bombpath_arrows_left_custom"
			origin = "-649.54 -878.371 1088.05"
            angles = "0 47.5 0"
			model = "models/props_mvm/robot_hologram.mdl"
			rendercolor = "100 100 100"
            startdisabled = 1
            disableshadows = 1
		})
        //adding the new arrows to the relays.
        EntityOutputs.AddOutput(Entities.FindByName(null, "bombpath_left_relay"), "OnTrigger","bombpath_arrows_left_custom","Enable",null,0,-1)
        EntityOutputs.AddOutput(Entities.FindByName(null, "bombpath_right_relay"), "OnTrigger","bombpath_arrows_right_custom","Enable",null,0,-1)
        EntityOutputs.AddOutput(Entities.FindByName(null, "bombpath_arrows_clear_relay"), "OnTrigger","bombpath_arrows_left_custom","Disable",null,0.1,-1)
        EntityOutputs.AddOutput(Entities.FindByName(null, "bombpath_arrows_clear_relay"), "OnTrigger","bombpath_arrows_right_custom","Disable",null,0.1,-1)
        
        //adding navavoids to prevent bots from flanking 25/7
        local leftnav = SpawnEntityFromTable("func_nav_avoid", //LEFTPATH, OUTSIDE
		{
			targetname = "bombpath_left_nav_avoid_custom"
			origin = "125 -2805 1050"
            startdisabled = 1
            tags = "bomb_carrier common"
            team = "3"
		})
        local leftnav2 = SpawnEntityFromTable("func_nav_avoid", //LEFTPATH, XING
		{
			targetname = "bombpath_left_nav_avoid_custom"
			origin = "-1500 -2900 1050"
            startdisabled = 1
            tags = "bomb_carrier common"
            team = "3"
		})
        local leftnav3 = SpawnEntityFromTable("func_nav_avoid", //LEFTPATH, DOORWAY
		{
			targetname = "bombpath_left_nav_avoid_custom"
			origin = "100 -3100 1050"
            startdisabled = 1
            tags = "bomb_carrier common"
            team = "3"
		})
        local rightnav = SpawnEntityFromTable("func_nav_avoid", //RIGHTPATH, OUTSIDE
		{
			targetname = "bombpath_right_nav_avoid_custom"
			origin = "-932 -2716 1088" //-576,-2368,1152 // 256, 448, 64 // 128, 224, 32
            startdisabled = 1
            tags = "bomb_carrier common"
            team = "3"
		})
        local rightnav2 = SpawnEntityFromTable("func_nav_avoid", //RIGHTPATH, XING
		{
			targetname = "bombpath_right_nav_avoid_custom"
			origin = "-1500 -2900 1050"
            startdisabled = 1
            tags = "bomb_carrier common"
            team = "3"
		})
        //define trigger volumes
        leftnav.SetSize(Vector(), Vector(300, 410, 200)) //Set size of the trigger.
        leftnav2.SetSize(Vector(), Vector(600, 610, 200)) //Set size of the trigger.
        leftnav3.SetSize(Vector(), Vector(1000, 300, 200)) //Set size of the trigger.
        rightnav.SetSize(Vector(), Vector(466, 658, 64)) //Set size of the trigger.
        rightnav2.SetSize(Vector(), Vector(600, 610, 200)) //Set size of the trigger.
        //set triggers to solid. this stumped me for HOURS.
        leftnav.KeyValueFromInt("solid", 2)
        leftnav2.KeyValueFromInt("solid", 2)
        leftnav3.KeyValueFromInt("solid", 2)
        rightnav.KeyValueFromInt("solid", 2)
        rightnav2.KeyValueFromInt("solid", 2)
        //adding the new triggers to the relays.
        EntityOutputs.AddOutput(Entities.FindByName(null, "bombpath_left_relay"), "OnTrigger","bombpath_left_nav_avoid_custom","Enable",null,0,-1)
        EntityOutputs.AddOutput(Entities.FindByName(null, "bombpath_right_relay"), "OnTrigger","bombpath_right_nav_avoid_custom","Enable",null,0,-1)
        //Couldn't stop the hatch alarm from nuking my avoids, so i did this.
        EntityOutputs.AddOutput(Entities.FindByName(null, "bombpath_left_relay"), "OnTrigger","bombpath_right_nav_avoid_custom","Disable",null,0.1,-1)
        EntityOutputs.AddOutput(Entities.FindByName(null, "bombpath_right_relay"), "OnTrigger","bombpath_left_nav_avoid_custom","Disable",null,0.1,-1)

        //guess i'll also handle some visual props here too.
        //SpawnEntityFromTable("prop_dynamic",
		//{
			//targetname = "prop"
			//origin = "-2900 0 8020"
            //angles = "-35 50 0"
			//model = "models/props_skybox/skybox_carrier.mdl"
            //disableshadows = 1
		//}) //this one sucks i can do better.

        SpawnEntityFromTable("prop_dynamic",
		{
			targetname = "prop"
			origin = "-1145 -160 7945"
            angles = "0 130 0"
			model = "models/props_skybox/skybox_carrier.mdl"
            disableshadows = 1
		})

        SpawnEntityFromTable("prop_dynamic",
		{
			targetname = "prop"
			origin = "-1085 -75 7945"
            angles = "0 130 0"
			model = "models/props_skybox/skybox_carrier.mdl"
            disableshadows = 1
		})

        SpawnEntityFromTable("prop_dynamic",
		{
			targetname = "prop"
			origin = "-1205 -245 7945"
            angles = "0 130 0"
			model = "models/props_skybox/skybox_carrier.mdl"
            disableshadows = 1
		})

        SpawnEntityFromTable("prop_dynamic" , 
        {
            targetname = "shopkeep"
			model = "models/bots/spy/bot_spy.mdl"
			origin = "332 450 992"
			angles = "0 90 0"
			defaultanim = "stand_sapper"
			fademindist = 200
			fademaxdist = 350
			disableshadows = 1
			disablebonefollowers = 1
		})

        SpawnEntityFromTable("prop_dynamic_ornament" , {
            targetname = "shopkeeper_fists"
			//model = "models/workshop/weapons/c_models/c_fists_of_steel/c_fists_of_steel.mdl"
			model = "models/weapons/c_models/c_sapper/c_sapper.mdl"
			disableshadows = 1
			disablebonefollowers = 1
			fademindist = 200
			fademaxdist = 350
			initialowner = "shopkeep"
		})
	}
}

MakeMapChanges()

//MANNPOWERSINIT IS ONLY RUN ON W5-6. CHECK THE POP.
::MannPowersInit <- //frankensteined from M1's mitosis stuff above, my own vscript knowledge and an old pointtemplate i used for a mission years ago. Oh and a cool thing Braindawg showed me.
{
    Cleanup = function() { delete ::MannPowersInit} 
	OnGameEvent_recalculate_holidays = function(_) { if (GetRoundState() == 3) Cleanup() }
	OnGameEvent_mvm_wave_complete = function(_) { Cleanup() }
    function Run(showtutorial)
    {
        function OnGameEvent_player_spawn(args) {
            local player = GetPlayerFromUserID(args.userid)
            if(GetPropBool(player,"m_bIsABot")) {
                local code = "if(self.HasBotTag(`bot_haste`)) {self.AddCond(91)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_strength`)) {self.AddCond(90)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)
                
                code = "if(self.HasBotTag(`bot_agility`)) {self.AddCond(97)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_precision`)) {self.AddCond(96)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)

                code = "if(self.HasBotTag(`bot_knockout`)) {self.AddCond(103)}"
                EntFireByHandle(player,"runscriptcode",code,-1,null,null)
            }
        } //well aware i could've used popext+ for this, but I already had the means in this nut and I didn't want to have to make a _tags.nut.

        SpawnEntityFromTable("logic_timer", //copied from an old ass mission, don't remember who initially showed me this, apologies.
		{
			targetname = "mannpower_kill"
			RefireTime = "0.1"
            spawnflags = "0"
			UseRandomTime = "0"
            OnTimer = "item_powerup_rune,kill,,0,-1"
		})

        // IncludeScript("seel_ins") //S.I.N.S by Seelpit. Manipulate the icons.
        // if(Entities.FindByName(null, "repeatrun_checker_MP") == null) //don't re-spawn everything outside of wave fail. repeatrun_checker_MP is spawned earlier in this namespace.
	    // {
        //     SpawnEntityFromTable("logic_relay" , {
        //         targetname = "icon_swapping_relay_w5A"
        //         spawnflags = 2
        //         //Icon Changing:
        //         "OnTrigger#1": "gamerules,CallScriptFunction,MannpowerIconsToggleShowPowerw5,0.1,-1" //ent, action, param, delay, -1
        //         "OnTrigger#2": "icon_swapping_relay_w5B,Trigger,,1,-1"
        //     })
        //     SpawnEntityFromTable("logic_relay" , {
        //         targetname = "icon_swapping_relay_w5B"
        //         spawnflags = 2
        //         //Icon Changing:
        //         "OnTrigger#1": "gamerules,CallScriptFunction,MannpowerIconsToggleShowTypew5,0.1,-1" //ent, action, param, delay, -1
        //         "OnTrigger#2": "icon_swapping_relay_w5A,Trigger,,1,-1"
        //     })
        // }
        // //Odering is very important cause there are dupe icons, but CIBN only goes for the first one by that name... ??????
        // ::MannpowerIconsToggleShowPowerw5 <- function() //Change icons to their mannpower types.
        // {
        //     SINS.ChangeIconByName("soldier_directhit_buff_lite","powerup_strength_lite")
        //     SINS.ChangeIconByName("medic_giant","powerup_agility_lite")
        //     SINS.ChangeIconByName("heavy_shotgun_burst_lite","powerup_precision_lite")
        //     SINS.ChangeIconByName("soldier_barrage","powerup_haste_lite")
        //     SINS.ChangeIconByName("scout_bat_nys","powerup_agility_lite")
        //     //SINS.ChangeIconByName("soldier","powerup_strength_lite") //cut
        //     SINS.ChangeIconByName("spy","powerup_agility_lite")
        //     SINS.ChangeIconByName("demoknight_samurai","powerup_knockout_lite")
        // }
        // ::MannpowerIconsToggleShowTypew5 <- function() //Change icons to their robot types.
        // {
        //     SINS.ChangeIconByName("powerup_strength_lite","soldier_directhit_buff_lite")
        //     SINS.ChangeIconByName("powerup_agility_lite","medic_giant")
        //     SINS.ChangeIconByName("powerup_precision_lite","heavy_shotgun_burst_lite")
        //     SINS.ChangeIconByName("powerup_agility_lite","scout_bat_nys")
        //     SINS.ChangeIconByName("powerup_haste_lite","soldier_barrage")
        //     //SINS.ChangeIconByName("powerup_strength_lite","soldier") //cut
        //     SINS.ChangeIconByName("powerup_agility_lite","spy")
        //     SINS.ChangeIconByName("powerup_knockout_lite","demoknight_samurai")
        // }

        // //W6 ICONS
        // if(Entities.FindByName(null, "repeatrun_checker_MP") == null) //don't re-spawn everything outside of wave fail. repeatrun_checker_MP is spawned earlier in this namespace.
	    // {
        //     SpawnEntityFromTable("logic_relay" , {
        //         targetname = "icon_swapping_relay_w6A"
        //         spawnflags = 2
        //         //Icon Changing:
        //         "OnTrigger#1": "gamerules,CallScriptFunction,MannpowerIconsToggleShowPowerw6,0.1,-1" //ent, action, param, delay, -1
        //         "OnTrigger#2": "icon_swapping_relay_w6B,Trigger,,1.0,-1"
        //     })
        //     SpawnEntityFromTable("logic_relay" , {
        //         targetname = "icon_swapping_relay_w6B"
        //         spawnflags = 2
        //         //Icon Changing:
        //         "OnTrigger#1": "gamerules,CallScriptFunction,MannpowerIconsToggleShowTypew6,0.1,-1" //ent, action, param, delay, -1
        //         "OnTrigger#2": "icon_swapping_relay_w6A,Trigger,,1.0,-1"
        //     })
        //     //Spawning this here, in the last if.
        //     SpawnEntityFromTable("logic_relay", {
        //         targetname = "repeatrun_checker_MP"
        //     })
        // }
        // //Odering is very important cause there are dupe icons, but CIBN only goes for the first one by that name... ??????
        // ::MannpowerIconsToggleShowPowerw6 <- function() //Change icons to their mannpower types.
        // {
            
        //     SINS.ChangeIconByName("soldier_rocketrain","powerup_haste_lite")
        //     SINS.ChangeIconByName("demo_scatter","powerup_haste_lite")
        //     SINS.ChangeIconByName("scout_giant","powerup_agility_lite")
        //     SINS.ChangeIconByName("heavy_giant","powerup_strength_lite")
        //     SINS.ChangeIconByName("scout_jumping_fan","powerup_agility_lite")
        //     SINS.ChangeIconByName("pyro_giant_support","powerup_strength_lite")
        //     SINS.ChangeIconByName("sniper","powerup_agility_lite")
        //     SINS.ChangeIconByName("engineer","powerup_haste_lite")
            
            
        // }
        // ::MannpowerIconsToggleShowTypew6 <- function() //Change icons to their robot types.
        // {
            
        //     SINS.ChangeIconByName("powerup_haste_lite","soldier_rocketrain")
        //     SINS.ChangeIconByName("powerup_haste_lite","demo_scatter")
        //     SINS.ChangeIconByName("powerup_agility_lite","scout_giant")
        //     SINS.ChangeIconByName("powerup_strength_lite","heavy_giant")
        //     SINS.ChangeIconByName("powerup_agility_lite","scout_jumping_fan")
        //     SINS.ChangeIconByName("powerup_strength_lite","pyro_giant_support")
        //     SINS.ChangeIconByName("powerup_agility_lite","sniper")
        //     SINS.ChangeIconByName("powerup_haste_lite","engineer")
            
            
        // }

        //Getting this to work during the wave would have been a massive pain 
        //(trying to use bybottags alongside this vomits errors unless i want to spend forever making like 10 logic relays, one for each goddamn icon. Not doing that when the majority of people don't even look at the wavebar before waves, let alone during them.)
        //(thinking about it, this would also present the problem of how to make sure it syncs up with the above setup, otherwise we just hit the same problem.)
        //

        if(showtutorial == true) //don't re-run after first wave of mp's.
        {
            SendGlobalGameEvent("show_annotation", { //add a pointer prewave, removed in the pop itself
                text = "Robots will now wield Mannpowers!"
                lifetime = -1
                worldPosX = -328
                worldPosY = -4804
                worldPosZ = 1152 //1184 //1120
                id = 111
                play_sound = "misc/null.wav"
            })
        }

        SpawnEntityFromTable("prop_dynamic",
        {
            targetname = "display_mannpower"
            origin = "-328 -4804 1076"
            model = "models/pickups/pickup_powerup_haste.mdl"
            defaultanim = "spin"
            skin = 2
            disableshadows = 1
            renderfx = 15
        })

        SpawnEntityFromTable("prop_dynamic",
        {
            targetname = "display_mannpower"
            origin = "-392 -4804 1076"
            model = "models/pickups/pickup_powerup_strength.mdl"
            defaultanim = "spin"
            skin = 2
            disableshadows = 1
            renderfx = 15
        })

        SpawnEntityFromTable("prop_dynamic",
        {
            targetname = "display_mannpower"
            origin = "-456 -4804 1076"
            model = "models/pickups/pickup_powerup_knockout.mdl"
            defaultanim = "spin"
            skin = 2
            disableshadows = 1
            renderfx = 15
        })

        SpawnEntityFromTable("prop_dynamic",
        {
            targetname = "display_mannpower"
            origin = "-264 -4804 1076"
            model = "models/pickups/pickup_powerup_precision.mdl"
            defaultanim = "spin"
            skin = 2
            disableshadows = 1
            renderfx = 15
        })

        SpawnEntityFromTable("prop_dynamic",
        {
            targetname = "display_mannpower"
            origin = "-200 -4804 1076"
            model = "models/pickups/pickup_powerup_agility.mdl"
            defaultanim = "spin"
            skin = 2
            disableshadows = 1
            renderfx = 15
        })

        EntityOutputs.AddOutput(Entities.FindByName(null, "wave_start_relay"), "OnTrigger","wave_start_relay","RunScriptCode", "SendGlobalGameEvent(`hide_annotation`, {id = 111})",0,-1)
        EntityOutputs.AddOutput(Entities.FindByName(null, "wave_start_relay"), "OnTrigger","display_mannpower","kill",null,0,-1)
        __CollectGameEventCallbacks(this)
    }
}