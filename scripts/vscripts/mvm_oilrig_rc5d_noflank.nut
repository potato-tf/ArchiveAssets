//runs automatically.
//include in every wave.
function MakeMapChanges()
{
    if(Entities.FindByName(null, "repeatrun_checker") == null) //don't re-run everything outside of wave fail.
	{
			SpawnEntityFromTable("logic_relay", {
            targetname = "repeatrun_checker"
        })
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
	}
}

MakeMapChanges()