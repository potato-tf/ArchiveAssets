::PointTemplates <- 
{
	Engineer_Landmine =
	{
		[0] =
		{
			tf_generic_bomb =
			{
				model = "models/props_frontline/mine_norock.mdl",
				damage = 100,
				radius = 150,
				TeamNum = 2,	// this does work but lets not use it for now
				friendlyfire = 1,
				explode_particle = "rd_robot_explosion",
				sound = "ambient/explosions/explode_4.wav",
				targetname = "mine",
			}
		},
		[1] =
		{
			trigger_once =
			{
				filtername = "filter_blue",
				targetname = "mine_bbox",
				mins = "-50 -50 0"
				maxs = "50 50 100"
				spawnflags = 1,
				"OnStartTouch#1" : "mine_snd,PlaySound,,0,-1",
				"OnStartTouch#2" : "mine,Detonate,,0.5,-1",
			}
		},
		[2] =
		{
			ambient_generic =
			{
				targetname = "mine_snd",
				origin = "0 0 16",
				health = 10,
				radius = 2000,
				spawnflags = 16,
				message = "player/cyoa_pda_beep4.wav",
				sourceentityname = "mine",
			}
		},
	}
	Gascan_Drop =
	{
		[0] =
		{
			prop_dynamic =
			{
				model = "models/weapons/c_models/c_gascan/c_gascan.mdl",
				solid = "0",
				targetname = "gascan_prop",
				parentname = "pickup_gascan_drop"
			}
		},
		[1] =
		{
			func_rot_button =
			{
				targetname = "pickup_gascan_drop"
				mins = "-8 -8 3"
				maxs = "8 8 3"
				spawnflags = 1,
				"OnPressed#1" : "!self,KillHierarchy,,0,-1",
			}
		},
	}
}