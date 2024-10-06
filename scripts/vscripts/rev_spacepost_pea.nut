for (local ent; ent = Entities.FindByName(ent, "intel_ironman"); ) ent.Kill()
for (local ent; ent = Entities.FindByName(ent, "portablestation*"); ) ent.Kill() // upgrade stations are preserved entities!

::PEA <-
{
	mission = NetProps.GetPropString(Entities.FindByClassname(null, "tf_objective_resource"), "m_iszMvMPopfileName")

	debug = false
	debug_stage = 3
	debug_objective = true

	draw_worldtext = false
	draw_debugchat = false

	tick = 1

	gamerules_entity 			= Entities.FindByName(null, "gamerules")
	objective_resource_entity 	= Entities.FindByClassname(null, "tf_objective_resource")
	intel_entity 				= Entities.FindByName(null, "intel")

	pop_interface_ent 			= SpawnEntityFromTable("point_populator_interface", {} )

	players_joining_array = []

	in_setup = function() { return NetProps.GetPropBool(objective_resource_entity, "m_bMannVsMachineBetweenWaves") }

	scout = 		Constants.ETFClass.TF_CLASS_SCOUT, 		soldier = 	Constants.ETFClass.TF_CLASS_SOLDIER, 	pyro = 	Constants.ETFClass.TF_CLASS_PYRO, 	demoman = 	Constants.ETFClass.TF_CLASS_DEMOMAN, 	heavyweapons = 	Constants.ETFClass.TF_CLASS_HEAVYWEAPONS,
	engineer = 		Constants.ETFClass.TF_CLASS_ENGINEER, 	sniper = 	Constants.ETFClass.TF_CLASS_SNIPER, 	medic = Constants.ETFClass.TF_CLASS_MEDIC, 	spy = 		Constants.ETFClass.TF_CLASS_SPY,		no_class = 		Constants.ETFClass.TF_CLASS_UNDEFINED

	class_integers = ["", "scout", "sniper", "soldier", "demo", "medic", "heavy", "pyro", "spy", "engineer", "civilian"]

	WAVE = NetProps.GetPropInt(Entities.FindByClassname(null, "tf_objective_resource"), "m_nMannVsMachineWaveCount")

	hud_separate_giantpoints_from_bloodheld = "\n               "

	timetable_raw = {}
	timetable = {}

	tank_time = 0

	bloodbot_path_speed = 150.0

	blood_tank = null
	stage1_check = null
	stage2_check = null
	stage3_check = null

	tank_blood_level = 45
	empty_blood_level = 0

	tank_blood_level_increment_threshold = 0 // w3 only

	tank_tnt_level = 45
	empty_tnt_level = 0

	cur_tankspeed = 250.0

	tank_pause_speed = 0.0
	tank_stage1_speed = 0.0
	tank_stage2_speed = 0.0
	tank_stage3_speed = 0.0

	tank_speedboost = 0
	tank_speedboostticks = 0

	fullbar = "███████████████" // IMPORTANT: for some reason game_text considers 1 █ as three characters
	emptybar = "░░░░░░░░░░░░░░░" // same here

	blood_tank_healthdrain_dmg = 1
	tank_healthdrain_alarm_timer = 0
	tank_healthdrain_penalty_timer = 0
	bloodtank_took_damage_recently = false

	extraction_cooldown = 0.5
	deplete_blood_cooldown = 2

	supplysound_cooldown = 0.1
	overhealsound_cooldown = 0.1

	tank_objective_explosion_cooldown = 8.0
	tank_objective_explosion_time = 3600.0
	tank_objective_explosion_imminent = false
	tank_objective_explosion_leftovers = 0.0

	prev_reds_near_bloodtank = 0
	reds_near_bloodtank = 0

	next_red_proximity_blink_time = 0

	extraction_mode = "blood"

	game_over = false

	nextvoicesuppressiontime = 0

	barricade_destroyed_recently = false

	active_spawns = []

	pathbranch_array =
	[
		Entities.FindByName(null, "tank_path_a_31"), Entities.FindByName(null, "tank_path_a_11"), Entities.FindByName(null, "tank_path_a_34"), Entities.FindByName(null, "tank_path_a_35"), Entities.FindByName(null, "tank_path_a_36"), Entities.FindByName(null, "tank_path_a_12"),
		Entities.FindByName(null, "tank_path_a_37"), Entities.FindByName(null, "tank_path_a_38"), Entities.FindByName(null, "tank_path_a_39"), Entities.FindByName(null, "tank_path_a_40"), Entities.FindByName(null, "tank_path_a_41"), Entities.FindByName(null, "tank_path_a_42"),
		Entities.FindByName(null, "tank_path_a_43"), Entities.FindByName(null, "tank_path_a_44"), Entities.FindByName(null, "tank_path_a_45"), Entities.FindByName(null, "tank_path_a_46"), Entities.FindByName(null, "tank_path_a_47"), Entities.FindByName(null, "tank_path_a_48"),
		Entities.FindByName(null, "tank_path_a_49"), Entities.FindByName(null, "tank_path_a_50"), Entities.FindByName(null, "tank_path_a_51"), Entities.FindByName(null, "tank_path_a_52"), Entities.FindByName(null, "tank_path_a_53"), Entities.FindByName(null, "tank_path_a_54"),
		Entities.FindByName(null, "tank_path_a_55"), Entities.FindByName(null, "tank_path_a_56"), Entities.FindByName(null, "tank_path_a_57"), Entities.FindByName(null, "tank_path_a_58"), Entities.FindByName(null, "tank_path_a_59"), Entities.FindByName(null, "tank_path_a_13"),
		Entities.FindByName(null, "tank_path_a_14"), Entities.FindByName(null, "tank_path_a_15")
	]

	nav_avoid_upper_left = null
	nav_avoid_jumpdown_middle = null
	nav_avoid_dropdown_middle = null
	nav_avoid_walkdown_middle = null
	nav_avoid_upper_right = null
	nav_avoid_upper_exit = null
	nav_avoid_middle_exit = null
	nav_avoid_right_exit = null
	nav_avoid_outside_rightflank = null
	nav_avoid_walkdown_back = null
	nav_avoid_walkdown_back_right = null
	nav_avoid_back_corridor_right = null
	nav_avoid_back_corridor_left = null
	nav_avoid_back_corridor_middle = null
	nav_avoid_back_overpass = null
	nav_avoid_middle_corridor_left = null
	nav_avoid_back_sidepath = null
	nav_avoid_alienhunter_special = null

	huntbot_target = null

	barricadebomb = null

	//////////// WAVE 3 TNT

	bombs_satisfied = 0
	bombs_remaining = 20
	tnt_to_connect_beam_to = 1

	current_bombs_remaining = 6

	tnt_satisfied = false
	tnt_cleanup = false

	tntspot_amounts_array = [ 12, 12, 10, 10, 10, 12, 9, 8, 8, 9, 9, 8, 9, 8, 10, 10, 10, 10, 5, 10 ]

	//////////// BLOOD BOTS

	bloodbots_spawned = 0
	bloodbots_alive = 0.0
	max_bloodbot_count = 12

	bloodbot_dispatchtime = Time() + 99999
	next_bloodbot_dispatchtime_min = 6.0
	next_bloodbot_dispatchtime_max = 10.0

	bloodbot_highlight_cooldown = Time()

	roambots_dispatched = 0

	//////////// OBJECTIVES

	current_stage = 1
	objective_type = null
	objective_amount = 0
	objectives_reached = 0

	briefcases_spawned = 1
	briefcases_active = 0

	is_blu_player_near_escortbot = false
	is_blu_player_near_bombcart = false
	escortbot_reached_destination = false

	blu_players_near_bloodtank = 0

	is_red_player_near_bloodtank = false

	stage1_objective = null
	stage2_objective = null
	stage3_objective = null

	stage1_cash_reward = 0
	stage2_cash_reward = 0
	stage3_cash_reward = 0

	obj_control_timer_start = "0:10"
	obj_control_digit = 9
	obj_control_holdtime = "0:10"

	obj_control_redcapture_rate = 3.5
	obj_control_blucapture_rate = 7.0

	obj_control_a_captured = false
	obj_control_b_captured = false
	obj_control_c_captured = false

	bombcart_train_reached_destination = false
	bombcart_explosion_tick = 0

	in_cutscene = false
	iceblock_prop = null

	in_endgame = false
	player_has_escaped = false
	obj_end_text = "Detonate the explosives"

	player_stood_on_boombox = false
	escapestatus_hud = null
	players_escaped = 0
	escapestatus_rows = null

	reentry_gates_down = 0
	reentry_gates_sound_playing = false

	ending_cutscene_status = "inactive"

	ufo_renderamt = 0
	ufo_accelrate = 0.03
	ufo_movestatus = "descending"

	//////////// TIPS

	tip_header = "\x07FFD700"

	settings_tip_descriptions_1 =
	[
		"Defend the Blood Tank from enemy RED attackers!"
		"Pick up blood from killed enemies!"
		"Take all blood you collect\nto the Blood Tank!"
		"Carrying too much makes\nyou slow and fragile"
		"Blood Tank drains its own health\nwhile it has no blood"
		"Giving the Blood Tank more blood\nthan it can hold will heal and speed it up"
		"Grouping together around the Blood Tank\nwill make it give and take more resources"
		"Destroy Blood-Bots\nto get extra blood"
		"You get 1 giant point each time\nyou put blood in the Blood Tank"
		"Once you have 30 giant points, hold your\nProjectile Shield key to become giant!"
		"While giant, hold the Projectile Shield\nkey again to turn back to normal"
		"The 'Recall' canteen can teleport you between\nthe Blood Tank and the Upgrade Station"
		"Bomb bots deal heavy damage to the\nBlood Tank when they get close!"
		"Stationary bombs destroy the Blood\nTank whole when run over!"
		"Rotten blood doubles your carried\nblood and applies bleeding"
	]

	settings_tip_descriptions_2 =
	[
		"Stand near the Blood Tank to get TNT"
		"Carrying too much makes\nyou slow and fragile"
		"Take all TNT you collect\nto any glowing barrel!"
		"Fill all 20 barrels to beat the mission!"
		"Grouping together around the Blood Tank\nwill make it give and take more resources."
		"Pick up blood from killed enemies!"
		"Take all blood you collect\nto the Blood Tank!"
		"Bringing blood to the Blood Tank\nwill make it refill its TNT faster"
		"Bringing blood to the Blood Tank while the whistle\nis blowing will also heal and speed it up"
		"While there are no barrels left to be filled, you can still\nbring blood to the Blood Tank to heal and speed it up."
		"Destroy Blood-Bots\nto get extra blood"
		"You get 1 giant point each time\nyou arm a barrel with 1 TNT."
		"Once you have 30 giant points, hold your\nProjectile Shield key to become giant!"
		"While giant, hold the Projectile Shield\nkey again to turn back to normal"
		"The 'Recall' canteen can teleport you between\nthe Blood Tank and the Upgrade Station"
		"Blood Tank creates explosions\nwhile it's not moving"
		"Bomb bots deal heavy damage to the\nBlood Tank when they get close!"
		"Rotten blood doubles your carried\nblood and applies bleeding."
	]

	//////////// MISC

	blu_spawn_1_booth = SpawnEntityFromTable("prop_dynamic",
	{
		targetname              = "infobooth"
		origin                  = Vector(750, 1850, -380)
		model                   = "models/props_medieval/ticket_booth/ticket_booth.mdl"
		angles                  = QAngle(0, 120, 0)
	})

	blu_spawn_1_booth_bbox = SpawnEntityFromTable("func_button",
	{
		origin                  = Vector(750, 1850, -380)
		angles                  = QAngle(0, 120, 0)
	})

	blu_spawn_1_booth_keeper = SpawnEntityFromTable("prop_dynamic",
	{
		targetname              = "infobooth_keeper"
		origin                  = Vector(750, 1840, -380)
		model                   = "models/bots/spy/bot_spy.mdl"
		angles                  = QAngle(0, -150, 0)
		DefaultAnim             = "stand_melee"
		skin 					= 1
		DisableBoneFollowers    = 1
	})

	blu_spawn_1_booth_board = SpawnEntityFromTable("prop_dynamic",
	{
		origin                  = Vector(720, 1826, -250)
		model                   = "models/props_gameplay/sign_wood_cap001.mdl"
		angles                  = QAngle(0, 27, 0)
		modelscale				= 0.5
		disableshadows			= 1
	})

	blu_spawn_1_booth_text = SpawnEntityFromTable("point_worldtext",
	{
		textsize       = 12
		message        = "SETTINGS"
		font           = 1
		orientation    = 0
		textspacingx   = 1
		textspacingy   = 10
		spawnflags     = 0
		origin         = Vector(705, 1851, -245)
		angles         = QAngle(0, 27, 0)
		rendermode     = 3
		targetname	   = "infobooth_text"
	})

	blu_spawn_2_booth = SpawnEntityFromTable("prop_dynamic",
	{
		targetname              = "infobooth"
		origin                  = Vector(-1370, 680, -137)
		model                   = "models/props_medieval/ticket_booth/ticket_booth.mdl"
		angles                  = QAngle(0, 0, 0)
	})

	blu_spawn_2_booth_bbox = SpawnEntityFromTable("func_button",
	{
		origin                  = Vector(-1370, 680, -137)
		angles                  = QAngle(0, 120, 0)
	})

	blu_spawn_2_booth_keeper = SpawnEntityFromTable("prop_dynamic",
	{
		targetname              = "infobooth_keeper"
		origin                  = Vector(-1380, 680, -137)
		model                   = "models/bots/spy/bot_spy.mdl"
		angles                  = QAngle(0, 90, 0)
		DefaultAnim             = "stand_melee"
		skin 					= 1
		DisableBoneFollowers    = 1
	})

	blu_spawn_2_booth_board = SpawnEntityFromTable("prop_dynamic",
	{
		origin                  = Vector(-1380, 717, 0)
		model                   = "models/props_gameplay/sign_wood_cap001.mdl"
		angles                  = QAngle(0, -90, 0)
		modelscale				= 0.5
		disableshadows			= 1
	})

	blu_spawn_2_booth_text = SpawnEntityFromTable("point_worldtext",
	{
		textsize       = 12
		message        = "SETTINGS"
		font           = 1
		orientation    = 0
		textspacingx   = 1
		textspacingy   = 10
		spawnflags     = 0
		origin         = Vector(-1350, 720, 0)
		angles         = QAngle(0, -90, 0)
		rendermode     = 3
		targetname	   = "infobooth_text"
	})

	infobooth = SpawnEntityFromTable("logic_case",
	{
		targetname              = "infobooth_menu"
		case16                  = "Welcome to the settings booth!|0|Cancel"
		case01                  = "How to play (>)"
		case02                  = "How to play (<)"
		case03                  = "Toggle robot viewmodels"
		case04                  = "!All credit goes to CTriggerHurt for creating the viewmodels"
		case05                  = "Audio settings"
		case06                  = "Toggle tips"

		OnCase01                = "!activator,RunScriptCode,ReceiveRandomVisTip(0),0.0,-1"
		OnCase02                = "!activator,RunScriptCode,ReceiveRandomVisTip(1),0.0,-1"
		OnCase03                = "!activator,CallScriptFunction,ToggleRobotViewmodels,0.0,-1"
		OnCase05                = "!activator,CallScriptFunction,DisplayAudioSettings,0.0,-1"
		OnCase06                = "resettips_prompt,$DisplayMenu,!activator,0.0,-1"
	})

	infobooth2 = SpawnEntityFromTable("logic_case",
	{
		targetname              = "resettips_prompt"
		case16                  = "You will no longer receive messages on how to play. Proceed?|0|Cancel"
		case01                  = "Yes"
		case02                  = "Go back"
		OnCase01                = "!activator,CallScriptFunction,ResetTips,0.0,-1"
		OnCase02                = "infobooth_menu,$DisplayMenu,!activator,0.0,-1"
	})

	InfoBooth_Think = function()
	{
		foreach (bluplayer in bluplayer_array)
		{
			if (bluplayer.IsFakeClient()) continue

			local scope = bluplayer.GetScriptScope().bloodstorage

			if (Entities.FindByNameWithin(null, "infobooth", bluplayer.GetOrigin(), 100.0) == null)
			{
				if (scope.reading_infobooth)
				{
					scope.reading_infobooth = false
					EntFire("infobooth_menu", "$HideMenu", "!activator", -1.0, bluplayer)
				}
			}

			else if (!scope.reading_infobooth)
			{
				scope.reading_infobooth = true
				EntFire("infobooth_menu", "$DisplayMenu", "!activator", -1.0, bluplayer)
			}
		}

		return 0.1
	}

	ReloadMapForChanges = function()
	{
		ClientPrint(null,3,"\x07FFA500WARNING: This map will reload in 10 seconds. Typing '!continue' after you join back will restore your progress.")
		ClientPrint(null,4,"WARNING: This map will reload in 10 seconds. Typing '!continue' after you join back will restore your progress.")

		EntFireByHandle(gamerules_entity, "$ChangeLevel", "mvm_spacepost_rc1", 10.0, null, null)

		EmitGlobalSound("ui/system_message_alert.wav")
	}

	ResetTips = function()
	{
		local scope = self.GetScriptScope().bloodstorage

		if (scope.wants_tips) { scope.wants_tips = false; ClientPrint(self, 4, "Tips are now OFF") }
		else
		{
			scope.wants_tips = true
			foreach (tip, value in scope.tip_table) scope.tip_table[tip] = false

			ClientPrint(self, 4, "Tips are now ON")
		}
	}

	ToggleRobotViewmodels = function() // all credit goes to CTriggerHurt for creating the viewmodels
	{
		local scope = self.GetScriptScope().bloodstorage

		if (!scope.wants_robot_viewmodels) scope.wants_robot_viewmodels = true
		else						 	   scope.wants_robot_viewmodels = false

		local has_gunslinger = false

		for (local i = 0; i < 8; i++)
		{
			local weapon = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i)

			if (weapon == null) continue

			if (NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 142) has_gunslinger = true
		}

		for (local i = 0; i < 8; i++)
		{
			local weapon = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i)

			if (weapon == null) continue

			if (has_gunslinger)
			{
				if (scope.wants_robot_viewmodels) NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel("models/mvm/weapons/c_models/c_engineer_bot_gunslinger.mdl"))
				else							  NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel("models/weapons/c_models/c_engineer_gunslinger.mdl"))
			}

			else
			{
				local vm = NetProps.GetPropEntity(self, "m_hViewModel")

				local weaponid = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex")

				switch (weaponid)
				{
					case 27: // disguise kit
					{
						if (scope.wants_robot_viewmodels) NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel("models/mvm/weapons/v_models/v_pda_spy_bot.mdl"))
						else 							  NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel("models/weapons/v_models/v_pda_spy.mdl"))

						break
					}

					case 30: // invis watch
					{
						if (scope.wants_robot_viewmodels) NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel("models/mvm/weapons/v_models/v_watch_spy_bot.mdl"))
						else 							  NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel("models/weapons/v_models/v_watch_spy.mdl"))

						break
					}

					case 59: // dead ringer
					{
						if (scope.wants_robot_viewmodels) NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel("models/mvm/weapons/v_models/v_watch_pocket_spy_bot.mdl"))
						else 							  NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel("models/weapons/v_models/v_watch_pocket_spy.mdl"))

						break
					}

					case 60: // cloak and dagger
					{
						if (scope.wants_robot_viewmodels) NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel("models/mvm/weapons/v_models/v_watch_leather_spy_bot.mdl"))
						else 							  NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel("models/weapons/v_models/v_watch_leather_spy.mdl"))

						break
					}

					case 212: // disguise kit (strange)
					{
						if (scope.wants_robot_viewmodels) NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel("models/mvm/weapons/v_models/v_pda_spy_bot.mdl"))
						else 							  NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel("models/weapons/v_models/v_pda_spy.mdl"))

						break
					}

					case 297: // enthusiast's timepiece
					{
						if (scope.wants_robot_viewmodels) NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel("models/mvm/weapons/v_models/v_ttg_watch_spy_bot.mdl"))
						else 							  NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel("models/weapons/v_models/v_ttg_watch_spy.mdl"))

						break
					}

					case 947: // quackenbirdt
					{
						if (scope.wants_robot_viewmodels) NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel("models/mvm/workshop_partner/weapons/v_models/v_hm_watch/v_hm_watch_bot.mdl"))
						else 							  NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel("models/weapons/v_models/v_hm_watch/v_hm_watch.mdl"))

						break
					}

					default:
					{
						if (scope.wants_robot_viewmodels) NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel(format("models/mvm/weapons/c_models/c_%s_bot_arms.mdl", class_integers[self.GetPlayerClass()])))
						else NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel(format("models/weapons/c_models/c_%s_arms.mdl", class_integers[self.GetPlayerClass()])))
					}
				}
			}
		}

		local wep = self.GetActiveWeapon()
		NetProps.SetPropEntity(self, "m_hActiveWeapon", null)
		self.Weapon_Switch(wep)

		EntFire("infobooth_menu", "$DisplayMenu", "!activator", -1.0, self)
	}

	ReceiveRandomVisTip = function(order)
	{
		local scope = self.GetScriptScope().bloodstorage

		local settings_tiptable = getroottable()["settings_tip_descriptions_" + ((WAVE < 3) ? 1 : 2)]

		if (scope.current_settings_tip != -1)
		{
			if (order == 0) scope.current_settings_tip++
			if (order == 1) scope.current_settings_tip--
		}

		else scope.current_settings_tip = 0

		if (scope.current_settings_tip > (settings_tiptable.len() - 1)) scope.current_settings_tip = 0
		if (scope.current_settings_tip < 0) scope.current_settings_tip = (settings_tiptable.len() - 1)

		SendGlobalGameEvent("show_annotation",
		{
			id = scope.tutorial_box.entindex()
			text = settings_tiptable[scope.current_settings_tip]
			follow_entindex = scope.tutorial_box.entindex()
			visibilityBitfield = (1 << self.entindex())
			play_sound = "misc/null.wav"
			show_distance = false
			show_effect = false
			lifetime = 7.5
		})

		EntFire("infobooth_menu", "$DisplayMenu", "!activator", -1.0, self)
	}

	DisplayAudioSettings = @() EntFireByHandle(self.GetScriptScope().bloodstorage.audiosettings, "$DisplayMenu", "!activator", -1.0, self, null)

	AudioExcludeListControl = function(num)
	{
		local scope = self.GetScriptScope().bloodstorage

		local excludearray =
		[
			"ui/item_as_parasite_drop.wav",
			"passtime/ball_dropped.wav",
			[ "weapons/samurai/TF_marked_for_death_indicator.wav", "player/pl_impact_stun.wav" ]
			"misc/rd_finale_beep01.wav",
			"MVM.BombWarning",
			"mvm.cpoint_alarm",
			[ "ui/duel_challenge.wav", "ui/quest_status_tick_novice.wav", "ui/quest_status_tick_advanced.wav", "ui/quest_status_tick_expert.wav", "ui/quest_status_tick_novice_complete.wav", "ui/quest_status_tick_advanced_complete.wav", "ui/quest_status_tick_expert_complete.wav" ],
			"mvm/mvm_used_powerup.wav",
			"MVM.GiantHeavyEntrance",
			"ui/rd_2base_alarm.wav",
			"ui/chime_rd_2base_neg.wav",
			"ui/killsound_beepo.wav",
			"misc/cp_harbor_red_whistle.wav",
			[ "weapons/loose_cannon_explode.wav", "pl_hoodoo/alarm_clock_ticking_3.wav", "pl_hoodoo/alarm_clock_alarm_3.wav", "mvm/mvm_bomb_explode.wav", "MVM.TankExplodes" ]
		]

		if (num == 99)
		{
			if (!scope.audio_excludelist_toggledoff)
			{
				foreach (thing in excludearray)
				{
					if (typeof thing == "array") { foreach (entry in thing) { if (scope.audio_excludelist.find(entry) == null) scope.audio_excludelist.append(entry) } }

					else if (scope.audio_excludelist.find(thing) == null) scope.audio_excludelist.append(thing)
				}

				for (local i = 0; i <= (scope.audio_preferences.len() - 1); i++) scope.audio_preferences[i] = "[X]"

				scope.audio_excludelist_toggledoff = true
			}

			else
			{
				foreach (thing in excludearray)
				{
					if (typeof thing == "array")
					{
						foreach (entry in thing) { if (scope.audio_excludelist.find(entry) != null) scope.audio_excludelist.remove(scope.audio_excludelist.find(entry)) }
					}

					else if (scope.audio_excludelist.find(thing) != null) scope.audio_excludelist.remove(scope.audio_excludelist.find(thing))

					for (local i = 0; i <= 10; i++) scope.audio_preferences[i] = "[X]"

				}

				for (local i = 0; i <= (scope.audio_preferences.len() - 1); i++) scope.audio_preferences[i] = "[✔]"

				scope.audio_excludelist_toggledoff = false
			}
		}

		for (local i = 0; i <= (excludearray.len() - 1); i++)
		{
			if ((num - 1) == i)
			{
				if (typeof excludearray[i] == "array")
				{
					foreach (entry in excludearray[i])
					{
						if (scope.audio_excludelist.find(entry) == null)
						{
							scope.audio_excludelist.append(entry)
							scope.audio_preferences[i] = "[X]"
						}
						else
						{
							scope.audio_excludelist.remove(scope.audio_excludelist.find(entry))
							scope.audio_preferences[i] = "[✔]"
						}
					}
				}

				else
				{
					if (scope.audio_excludelist.find(excludearray[i]) == null)
					{
						scope.audio_excludelist.append(excludearray[i])
						scope.audio_preferences[i] = "[X]"
					}
					else
					{
						scope.audio_excludelist.remove(scope.audio_excludelist.find(excludearray[i]))
						scope.audio_preferences[i] = "[✔]"
					}
				}
			}
		}

		for (local i = 2; i <= 15; i++)
		{
			if (i < 10)
			{
				if (NetProps.GetPropString(scope.audiosettings, "m_nCase[" + (i - 1) + "]").find("X") != null) scope.audiosettings.KeyValueFromString("case0" + i, scope.audio_preferences[i - 2] + " " + NetProps.GetPropString(scope.audiosettings, "m_nCase[" + (i - 1) + "]").slice(4))
				else																						   scope.audiosettings.KeyValueFromString("case0" + i, scope.audio_preferences[i - 2] + " " + NetProps.GetPropString(scope.audiosettings, "m_nCase[" + (i - 1) + "]").slice(6))

			}
			else
			{
				if (NetProps.GetPropString(scope.audiosettings, "m_nCase[" + (i - 1) + "]").find("X") != null) scope.audiosettings.KeyValueFromString("case" + i, scope.audio_preferences[i - 2] + " " + NetProps.GetPropString(scope.audiosettings, "m_nCase[" + (i - 1) + "]").slice(4))
				else																						   scope.audiosettings.KeyValueFromString("case" + i, scope.audio_preferences[i - 2] + " " + NetProps.GetPropString(scope.audiosettings, "m_nCase[" + (i - 1) + "]").slice(6))
			}
		}

		EntFireByHandle(scope.audiosettings, "$DisplayMenu", "!activator", -1.0, self, null)
	}

	debug_menu = SpawnEntityFromTable("logic_case",
	{
		targetname              = "debug_menu"
		case16                  = "Debug Menu|0|Cancel"
		case01                  = "See tips status"
		case02                  = "Print tank speed"
		OnCase01 				= "!activator,CallScriptFunction,SeeTipStatus,0.0,-1"
	})

	SeeTipStatus = function()
	{
		local scope = self.GetScriptScope().bloodstorage

		foreach (tip, value in scope.tip_table) ClientPrint(self, 3, tip + ": " + value)

		ClientPrint(self, 3, "-----")
	}

	spyalert_cooldown = 0

	RespawnIfDead = function() { if (NetProps.GetPropInt(self, "m_lifeState") != 0) self.ForceRespawn() }

	red_filter = SpawnEntityFromTable("filter_activator_tfteam",
	{
		targetname = "red_filter"
		TeamNum    = 2
		Negated	   = 0
	})

	VectorAngles = function(forward)
	{
		local yaw, pitch;

		if (forward.y == 0.0 && forward.x == 0.0)
		{
			yaw = 0.0

			if (forward.z > 0.0) pitch = 270.0
			else				 pitch = 90.0
		}

		else
		{
			yaw = (atan2(forward.y, forward.x) * 180.0 / Constants.Math.Pi)
			if (yaw < 0.0) yaw += 360.0

			pitch = (atan2(-forward.z, forward.Length2D()) * 180.0 / Constants.Math.Pi)
			if (pitch < 0.0) pitch += 360.0
		}

		return QAngle(pitch, yaw, 0.0);
	}

	DecrementIcon = function()
	{
		if (NetProps.GetPropBool(objective_resource_entity, "m_bMannVsMachineBetweenWaves") == true) return // don't do cleanup if the enemy was the last one in the wave

		local name = NetProps.GetPropString(self, "m_PlayerClass.m_iszClassIcon")

		for (local i = 0; i <= 11; i++)
		{
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames", i) == name) NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts", NetProps.GetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts", i) - 1, i)
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames2", i) == name) NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts2", NetProps.GetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts2", i) - 1, i)
		}
	}

	EmitGlobalSound = function(sound, setpitch = 100)
	{
		if (!IsSoundPrecached(sound)) PrecacheSound(sound)

		foreach (bluplayer in bluplayer_array)
		{
			if (bluplayer.IsFakeClient()) continue

			local scope = bluplayer.GetScriptScope().bloodstorage

			if (scope.audio_excludelist.find(sound) != null) continue

			EmitSoundEx({ sound_name = sound, filter_type = 4, entity = bluplayer, pitch = setpitch, flags = 0, channel = 6 })
		}
	}

	StopGlobalSound = function(sound)
	{
		SendGlobalGameEvent("teamplay_broadcast_audio",
		{
			team             = 1,
			sound            = sound,
			additional_flags = 4,
			player           = -1
		})

		SendGlobalGameEvent("teamplay_broadcast_audio",
		{
			team             = 3,
			sound            = sound,
			additional_flags = 4,
			player           = -1
		})
	}

	TeleportPlayer = function(where, who = null)
	{
		if (who == null) who = self

		who.Teleport(true, where, false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
	}

	ProperSetParent = function(entity, target)
	{
		NetProps.SetPropInt(entity, "m_fEffects", 1 | 128)

		NetProps.SetPropEntity(entity, "m_hMovePeer", target.FirstMoveChild())
		NetProps.SetPropEntity(target, "m_hMoveChild", entity)
		NetProps.SetPropEntity(entity, "m_hMoveParent", target)

		local origPos = entity.GetLocalOrigin()
		entity.SetLocalOrigin(origPos + Vector(0, 0, 1))
		entity.SetLocalOrigin(origPos)

		local origAngles = entity.GetLocalAngles()
		entity.SetLocalAngles(origAngles + QAngle(0, 0, 1))
		entity.SetLocalAngles(origAngles)

		local origVel = entity.GetVelocity()
		entity.SetVelocity(origVel + Vector(0, 0, 1))
		entity.SetVelocity(origVel)

		EntFireByHandle(entity, "SetParent", "!activator", 0, target, target)
	}

	AttachGlow = function()
	{
		local scope = self.GetScriptScope()

		self.KeyValueFromString("targetname", "glow_target")

		if (!self.HasBotTag("alienhunter"))
		{
			scope.selfglow <- SpawnEntityFromTable("tf_glow",
			{
				target           	  = "glow_target"
				GlowColor             = "255 0 0 255"
			})
		}

		else
		{
			scope.selfglow <- SpawnEntityFromTable("tf_glow",
			{
				target           	  = "glow_target"
				GlowColor             = "0 0 255 255"
			})
		}

		self.KeyValueFromString("targetname", "")

		EntFireByHandle(scope.selfglow, "SetParent", "!activator", -1.0, self, null) // parenting a tf_glow fixes issues where it doesn't render if it's too far from you
	}

	digitsize_table = { "1": "₁", "2": "₂", "3": "₃", "4": "₄", "5": "₅", "6": "₆", "7": "₇", "8": "₈", "9": "₉", "0": "₀" }

	SmallDigits = function(number, spacemode = "cash")
	{
		local result = ""
		local format = number + ""

		foreach (char in format) result += digitsize_table[char.tochar()]

		switch (spacemode)
		{
			case "cash":
			{
				local spaces = ""

				if (result.len() == 3) spaces = "           "
				if (result.len() == 6) spaces = "         "
				if (result.len() == 9) spaces = "       "
				if (result.len() == 12) spaces = "     "
				if (result.len() == 15) spaces = "    "

				return result + spaces

				break
			}

			case "blood":
			{
				local spaces = ""

				if (result.len() == 3) spaces = "     "
				if (result.len() == 6) spaces = "   "

				return result + spaces

				break
			}

			case "tnt":
			{
				local spaces = ""

				if (result.len() == 3) spaces = "   "
				if (result.len() == 6) spaces = " "

				return result + spaces

				break
			}

			case "none": return result; break
		}
	}

	redspawnarray =
	[
		Vector(2300, -200, -422), Vector(2500, -1400, -358), Vector(2900, -300, -38), Vector(2400, -1200, -38),  Vector(2300, 600, 26),    Vector(4400, -1200, -38), Vector(2700, -1900, -100), Vector(3400, -300, -353), Vector(4000, 100, -353), Vector(4700, -400, -33), Vector(3800, 550, 50),
		Vector(5000, 100, -100),  Vector(4100, 1500, -28), 	 Vector(3100, 100, -28),  Vector(1850, -1200, -124), Vector(500, -1500, -252), Vector(3800, 2300, 124),  Vector(4500, 2300, 124)
	]

	explosion_soundarray =
	[
		"ambient/explosions/explode_1.wav", "ambient/explosions/explode_2.wav", "ambient/explosions/explode_3.wav", "ambient/explosions/explode_4.wav",
		"ambient/explosions/explode_5.wav", "ambient/explosions/explode_7.wav", "ambient/explosions/explode_8.wav", "ambient/explosions/explode_9.wav"
	]

	wormhole_spawn_screams = // only for pyro, engineer, and sniper as they don't come with halloweenlongfall responses
	{
		pyro = [ "scenes/Player/Pyro/low/1578.vcd", "scenes/Player/Pyro/low/1579.vcd", "scenes/Player/Pyro/low/1580.vcd" ],
		engineer = [ "scenes/Player/Engineer/low/40.vcd", "scenes/Player/Engineer/low/44.vcd", "scenes/Player/Engineer/low/130.vcd", "scenes/Player/Engineer/low/131.vcd", "scenes/Player/Engineer/low/1259.vcd", "scenes/Player/Engineer/low/1260.vcd", "scenes/Player/Engineer/low/3703.vcd" ],
		sniper = [ "scenes/Player/Sniper/low/1697.vcd", "scenes/Player/Sniper/low/1699.vcd", "scenes/Player/Sniper/low/6564.vcd", "scenes/Player/Sniper/low/8487.vcd", "scenes/Player/Sniper/low/8488.vcd" ]
	}

	player_died_shouts = [ [4246, 4254], [3962, 3969], [4110, 4118], [4173, 4181] ] // soldier, heavy, engineer, medic

	unicorn_sapper_voicelines =
	{
		scout =
		[
			"scenes/Player/Scout/low/7018.vcd", "scenes/Player/Scout/low/7019.vcd", "scenes/Player/Scout/low/7020.vcd", "scenes/Player/Scout/low/7021.vcd", "scenes/Player/Scout/low/7022.vcd", "scenes/Player/Scout/low/7025.vcd", "scenes/Player/Scout/low/7026.vcd",
			"scenes/Player/Scout/low/7028.vcd", "scenes/Player/Scout/low/7029.vcd", "scenes/Player/Scout/low/7030.vcd", "scenes/Player/Scout/low/7031.vcd", "scenes/Player/Scout/low/7032.vcd", "scenes/Player/Scout/low/7033.vcd", "scenes/Player/Scout/low/7034.vcd",
			"scenes/Player/Scout/low/7035.vcd", "scenes/Player/Scout/low/7036.vcd", "scenes/Player/Scout/low/7037.vcd", "scenes/Player/Scout/low/7038.vcd", "scenes/Player/Scout/low/8517.vcd"
		],

		soldier =
		[
			"scenes/Player/Soldier/low/7452.vcd", "scenes/Player/Soldier/low/7453.vcd", "scenes/Player/Soldier/low/7454.vcd", "scenes/Player/Soldier/low/7455.vcd", "scenes/Player/Soldier/low/7456.vcd", "scenes/Player/Soldier/low/7457.vcd", "scenes/Player/Soldier/low/7458.vcd",
			"scenes/Player/Soldier/low/7459.vcd", "scenes/Player/Soldier/low/7460.vcd", "scenes/Player/Soldier/low/7463.vcd", "scenes/Player/Soldier/low/8562.vcd", "scenes/Player/Soldier/low/8563.vcd", "scenes/Player/Soldier/low/8564.vcd"
		],

		demoman =
		[
			"scenes/Player/Demoman/low/7773.vcd", "scenes/Player/Demoman/low/7776.vcd", "scenes/Player/Demoman/low/7777.vcd", "scenes/Player/Demoman/low/7778.vcd", "scenes/Player/Demoman/low/7779.vcd", "scenes/Player/Demoman/low/7780.vcd", "scenes/Player/Demoman/low/7781.vcd",
			"scenes/Player/Demoman/low/7784.vcd", "scenes/Player/Demoman/low/7785.vcd", "scenes/Player/Demoman/low/7786.vcd", "scenes/Player/Demoman/low/7787.vcd", "scenes/Player/Demoman/low/7788.vcd", "scenes/Player/Demoman/low/7790.vcd"
		],

		heavyweapons =
		[
			"scenes/Player/Heavy/low/6688.vcd", "scenes/Player/Heavy/low/6689.vcd", "scenes/Player/Heavy/low/6690.vcd", "scenes/Player/Heavy/low/6691.vcd", "scenes/Player/Heavy/low/6693.vcd",
			"scenes/Player/Heavy/low/6694.vcd", "scenes/Player/Heavy/low/6695.vcd", "scenes/Player/Heavy/low/6696.vcd", "scenes/Player/Heavy/low/6698.vcd", "scenes/Player/Heavy/low/8497.vcd"
		],

		engineer =
		[
			"scenes/Player/Engineer/low/7951.vcd", "scenes/Player/Engineer/low/7957.vcd", "scenes/Player/Engineer/low/7958.vcd", "scenes/Player/Engineer/low/7960.vcd", "scenes/Player/Engineer/low/7961.vcd",
			"scenes/Player/Engineer/low/7964.vcd", "scenes/Player/Engineer/low/7967.vcd", "scenes/Player/Engineer/low/7968.vcd", "scenes/Player/Engineer/low/8473.vcd"
		],

		sniper =
		[
			"scenes/Player/Sniper/low/7282.vcd", "scenes/Player/Sniper/low/7283.vcd", "scenes/Player/Sniper/low/7286.vcd", "scenes/Player/Sniper/low/7287.vcd", "scenes/Player/Sniper/low/7288.vcd", "scenes/Player/Sniper/low/7289.vcd",
			"scenes/Player/Sniper/low/7291.vcd", "scenes/Player/Sniper/low/7292.vcd", "scenes/Player/Sniper/low/7293.vcd", "scenes/Player/Sniper/low/7295.vcd", "scenes/Player/Sniper/low/8484.vcd"
		],

		spy =
		[
			"scenes/Player/Spy/low/7540.vcd", "scenes/Player/Spy/low/7541.vcd", "scenes/Player/Spy/low/7542.vcd", "scenes/Player/Spy/low/7543.vcd", "scenes/Player/Spy/low/7544.vcd", "scenes/Player/Spy/low/7545.vcd", "scenes/Player/Spy/low/7546.vcd",
			"scenes/Player/Spy/low/7548.vcd", "scenes/Player/Spy/low/7688.vcd", "scenes/Player/Spy/low/7690.vcd", "scenes/Player/Spy/low/8477.vcd", "scenes/Player/Spy/low/8551.vcd", "scenes/Player/Spy/low/8552.vcd"
		]
	}

	portablestation_keeper_voicelines = [ "scenes/Player/Medic/low/651.vcd", "scenes/Player/Medic/low/4167.vcd", "scenes/Player/Medic/low/4168.vcd", "scenes/Player/Medic/low/4323.vcd", "scenes/Player/Medic/low/6736.vcd", "scenes/Player/Medic/low/8503.vcd" ]

	Distance = function(vec1, vec2)
	{
		local x1 = vec1.x; local y1 = vec1.y; local z1 = vec1.z
		local x2 = vec2.x; local y2 = vec2.y; local z2 = vec2.z

		return pow(pow((x2 - x1), 2) + pow((y2 - y1), 2) + pow((z2 - z1), 2), 0.5)
	}

	IsInside = function(vector, min, max) { return vector.x >= min.x && vector.x <= max.x && vector.y >= min.y && vector.y <= max.y && vector.z >= min.z && vector.z <= max.z }

	SetIconCount = function(name, amount)
	{
		for (local i = 1; i <= 11; i++)
		{
			local iconname = NetProps.GetPropIntArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames", i)
			local iconname2 = NetProps.GetPropIntArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames2", i)

			local iconamount = NetProps.GetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts", i)
			local iconamount2 = NetProps.GetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts2", i)

			if (iconname == name) NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts", amount, i)
			if (iconname2 == name) NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts2", amount, i)
		}
	}

	DeliverVisualTipToPlayer = function(player, tip_name, tip_description, repeatable = false, repeat_cooldown = 0)
	{
		if (player.IsFakeClient()) return

		local scope = player.GetScriptScope().bloodstorage

		if (!scope.wants_tips) return

		// ClientPrint(debugger, 3, "Delivering visual tip to " + NetProps.GetPropString(player, "m_szNetname") + "...")

		if (!scope.tip_table[tip_name] && NetProps.GetPropInt(player, "m_lifeState") == 0 && !scope.in_vistip_cooldown)
		{
			if (debugger != null)
			{
				ClientPrint(debugger, 3, "Successfully delivered visual tip (" + tip_name + ") to: " + NetProps.GetPropString(player, "m_szNetname"))
				ClientPrint(debugger, 3, "Recipient's bitfield is " + (1 << player.entindex()))
			}

			SendGlobalGameEvent("show_annotation",
			{
				id = scope.tutorial_box.entindex()
				text = tip_description
				follow_entindex = scope.tutorial_box.entindex()
				visibilityBitfield = (1 << player.entindex())
				play_sound = "misc/null.wav"
				show_distance = false
				show_effect = false
				lifetime = 7.5
			})

			scope.tip_table[tip_name] = true
			scope.tips_unlocked_during_wave.append(tip_name)

			if (repeatable)
			{
				EntFireByHandle(player, "RunScriptCode", "self.GetScriptScope().bloodstorage.tip_table." + tip_name + " = false", repeat_cooldown, null, null)
				scope.repeatable_tips.append(tip_name)
			}

			scope.in_vistip_cooldown = true
			EntFireByHandle(player, "RunScriptCode", "self.GetScriptScope().bloodstorage.in_vistip_cooldown = false", scope.desired_vistip_cooldown, null, null)

			return true
		}

		else return false

		// else ClientPrint(debugger, 3, "Failed to deliver visual tip (in cooldown or already saw tip)")

		// ClientPrint(debugger, 3, "\n\n\n")
	}

	DeliverTipToPlayer = function(player, tip_name, tip_description)
	{
		local scope = player.GetScriptScope().bloodstorage

		if (scope.in_tip_cooldown) return
		if (!scope.tip_table[tip_name])
		{
			EmitSoundEx({ sound_name = "ui/chat_display_text.wav", filter_type = 4, entity = player, channel = 6 })

			ClientPrint(player, 3, tip_header + tip_description)
			scope.tip_table[tip_name] = true

			scope.in_tip_cooldown = true
			EntFireByHandle(player, "RunScriptCode", "self.GetScriptScope().bloodstorage.in_tip_cooldown = false", scope.desired_tip_cooldown, null, null)
		}
	}

	DeliverTipToBLU = function(tip_name, tip_description)
	{
		foreach (bluplayer in bluplayer_array)
		{
			if (bluplayer.IsFakeClient()) continue

			local scope = bluplayer.GetScriptScope().bloodstorage

			if (scope.in_tip_cooldown) continue
			if (!scope.tip_table[tip_name])
			{
				EmitSoundEx({ sound_name = "ui/chat_display_text.wav", filter_type = 4, entity = bluplayer, channel = 6 })

				ClientPrint(bluplayer, 3, tip_header + tip_description)
				scope.tip_table[tip_name] = true

				scope.in_tip_cooldown = true
				EntFireByHandle(bluplayer, "RunScriptCode", "self.GetScriptScope().bloodstorage.in_tip_cooldown = false", scope.desired_tip_cooldown, null, null)
			}
		}
	}

	tnt_barrel_spawned = 1

	SpawnTNTBarrel = function(x, y, z)
	{
		local ent = SpawnEntityFromTable("prop_physics_multiplayer", { targetname = "tnt_spot_" + tnt_barrel_spawned, origin = Vector(x, y, z), model = "models/props_badlands/barrel03.mdl" })

		EntFireByHandle(ent, "DisableMotion", null, 1.0, null, null)
		ent.SetCollisionGroup(5)

		tnt_barrel_spawned = tnt_barrel_spawned + 1
	}

	SpawnSniperHint = function(x, y, z, xyz1, xyz2)
	{
		local ent = SpawnEntityFromTable("func_tfbot_hint", { origin = Vector(x, y, z), hint = 0, TeamNum = 2 })

		ent.KeyValueFromInt("solid", 2)
		ent.KeyValueFromString("mins", xyz1); ent.KeyValueFromString("maxs", xyz2)
	}

	engineer_hint_spawned = 1

	SpawnEngineerHint = function(x1, y1, z1, x2, y2, z2, a2)
	{
		SpawnEntityFromTable("bot_hint_engineer_nest", { targetname = "red_engineer_nest_" + engineer_hint_spawned, origin = Vector(x1, y1, z1), TeamNum = 2 })
		SpawnEntityFromTable("bot_hint_sentrygun", { targetname = "red_engineer_nest_" + engineer_hint_spawned, origin = Vector(x2, y2, z2), TeamNum = 2, angles = QAngle(0, a2, 0) })

		engineer_hint_spawned = engineer_hint_spawned + 1
	}

	SpawnNavBrush = function(name, x, y, z, xyz1, xyz2)
	{
		getroottable()[name] = SpawnEntityFromTable("func_nav_avoid", { targetname = name, origin = Vector(x, y, z), tags = name.slice(4) })
		getroottable()[name].KeyValueFromInt("solid", 2)
		getroottable()[name].KeyValueFromString("mins", xyz1); getroottable()[name].KeyValueFromString("maxs", xyz2)
	}

	blu_spawn_scenery = SpawnEntityFromTable("prop_dynamic",
	{
		origin        = Vector(170, 1420, -231)
		angles        = QAngle(0, 0, 270)
		modelscale	  = 1.9
		model         = "models/props_trainyard/crane_platform001.mdl"
	})

	blu_spawn_scenery = SpawnEntityFromTable("prop_dynamic",
	{
		origin        = Vector(-1350, 1260, -272)
		angles        = QAngle(0, -90, 90)
		modelscale	  = 2.15
		model         = "models/props_trainyard/crane_platform001.mdl"
	})

	blu_spawn_scenery = SpawnEntityFromTable("prop_dynamic",
	{
		origin        = Vector(-1400, 1700, -165)
		angles        = QAngle(-20, -75, 90)
		modelscale	  = 1.2
		model         = "models/props_trainyard/crane_platform001.mdl"
	})

	robots_lose = SpawnEntityFromTable("game_round_win",
	{
		targetname		= "robots_lose"
		TeamNum			= 2
		switch_teams	= 0
		force_map_reset	= 1
		"OnUser1":		"gamerules,CallScriptFunction,LossHandler,0,-1"
	})

	spawnbot_red_1_visual = SpawnEntityFromTable("point_worldtext", { origin = Vector(2300, -200, -422) })
	spawnbot_red_2_visual = SpawnEntityFromTable("point_worldtext", { origin = Vector(2500, -1400, -358) })
	spawnbot_red_3_visual = SpawnEntityFromTable("point_worldtext", { origin = Vector(2900, -300, -38) })
	spawnbot_red_4_visual = SpawnEntityFromTable("point_worldtext", { origin = Vector(2400, -1200, -38) })
	spawnbot_red_5_visual = SpawnEntityFromTable("point_worldtext", { origin = Vector(2300, 600, 26) })
	spawnbot_red_6_visual = SpawnEntityFromTable("point_worldtext", { origin = Vector(4400, -1200, -38) })
	spawnbot_red_7_visual = SpawnEntityFromTable("point_worldtext", { origin = Vector(2700, -1900, -38) })
	spawnbot_red_8_visual = SpawnEntityFromTable("point_worldtext", { origin = Vector(3400, -300, -353) })
	spawnbot_red_9_visual = SpawnEntityFromTable("point_worldtext", { origin = Vector(4000, 100, -353) })
	spawnbot_red_10_visual = SpawnEntityFromTable("point_worldtext", { origin = Vector(4700, -400, -33) })
	spawnbot_red_11_visual = SpawnEntityFromTable("point_worldtext", { origin = Vector(3800, 550, 50) })
	spawnbot_red_12_visual = SpawnEntityFromTable("point_worldtext", { origin = Vector(5000, 100, -100) })
	spawnbot_red_13_visual = SpawnEntityFromTable("point_worldtext", { origin = Vector(4100, 1500, -28) })
	spawnbot_red_14_visual = SpawnEntityFromTable("point_worldtext", { origin = Vector(3100, 100, -28) })
	spawnbot_red_15_visual = SpawnEntityFromTable("point_worldtext", { origin = Vector(1850, -1200, -124) })
	spawnbot_red_16_visual = SpawnEntityFromTable("point_worldtext", { origin = Vector(500, -1500, -252) })
	spawnbot_red_17_visual = SpawnEntityFromTable("point_worldtext", { origin = Vector(3800, 2300, 124) })
	spawnbot_red_18_visual = SpawnEntityFromTable("point_worldtext", { origin = Vector(4500, 2300, 124) })

	vistext_nav_upper_left = SpawnEntityFromTable("point_worldtext", { message = "nav_upper_left", origin = Vector(2200, -900, 0) })
	vistext_nav_jumpdown_middle = SpawnEntityFromTable("point_worldtext", { message = "nav_jumpdown_middle", origin = Vector(2800, -600, 0) })
	vistext_nav_dropdown_middle = SpawnEntityFromTable("point_worldtext", { message = "nav_dropdown_middle", origin = Vector(3000, -1200, 0) })
	vistext_nav_walkdown_middle = SpawnEntityFromTable("point_worldtext", { message = "nav_walkdown_middle", origin = Vector(2000, -200, 0) })
	vistext_nav_upper_right = SpawnEntityFromTable("point_worldtext", { message = "nav_upper_right", origin = Vector(1800, -300, 0) })
	vistext_nav_upper_exit = SpawnEntityFromTable("point_worldtext", { message = "nav_upper_exit", origin = Vector(1700, -600, 0) })
	vistext_nav_middle_exit = SpawnEntityFromTable("point_worldtext", { message = "nav_middle_exit", origin = Vector(1200, -750, 0) })
	vistext_nav_right_exit = SpawnEntityFromTable("point_worldtext", { message = "nav_right_exit", origin = Vector(350, -1100, 0) })
	vistext_nav_outside_rightflank = SpawnEntityFromTable("point_worldtext", { message = "nav_outside_rightflank", origin = Vector(800, 400, -350) })
	vistext_nav_walkdown_back = SpawnEntityFromTable("point_worldtext", { message = "nav_walkdown_back", origin = Vector(4000, 100, -400) })
	vistext_nav_walkdown_back_right = SpawnEntityFromTable("point_worldtext", { message = "nav_walkdown_back_right", origin = Vector(3900, -1200, -250) })
	vistext_nav_back_corridor_right = SpawnEntityFromTable("point_worldtext", { message = "nav_back_corridor_right", origin = Vector(2800, 600, 0) })
	vistext_nav_back_corridor_left = SpawnEntityFromTable("point_worldtext", { message = "nav_back_corridor_left", origin = Vector(4000, -1500, 0) })
	vistext_nav_back_corridor_middle = SpawnEntityFromTable("point_worldtext", { message = "nav_back_corridor_middle", origin = Vector(3500, -600, 0) })
	vistext_nav_back_corridor_middle = SpawnEntityFromTable("point_worldtext", { message = "nav_back_overpass", origin = Vector(3700, 100, 0) })
	vistext_nav_middle_corridor_left = SpawnEntityFromTable("point_worldtext", { message = "nav_middle_corridor_left", origin = Vector(2700, 100, 0) })
	vistext_nav_back_sidepath = SpawnEntityFromTable("point_worldtext", { message = "nav_back_sidepath", origin = Vector(5400, 200, 0) })

	SetUpCustomNavigation = function()
	{
		SpawnNavBrush("nav_avoid_upper_left", 2200, -900, 0, "-100 -200 -250", "550 100 1000"); SpawnNavBrush("nav_avoid_jumpdown_middle", 2800, -600, 0, "-300 -200 -250", "150 200 1000"); SpawnNavBrush("nav_avoid_dropdown_middle", 3050, -1300, -400, "-50 -50 -50", "50 50 50");
		SpawnNavBrush("nav_avoid_walkdown_middle", 2000, -200, 0, "-150 -150 -500", "150 150 1000"); SpawnNavBrush("nav_avoid_upper_right", 1800, -300, 0, "-100 -200 -500", "150 50 1000"); SpawnNavBrush("nav_avoid_upper_exit", 1700, -600, 0, "-100 -150 -400", "100 100 1000");
		SpawnNavBrush("nav_avoid_middle_exit", 1200, -750, 0, "-300 -100 -1000", "300 100 1000"); SpawnNavBrush("nav_avoid_right_exit", 350, -1100, 0, "-100 -200 -1000", "200 100 1000"); SpawnNavBrush("nav_avoid_outside_rightflank", 800, 400, -350, "-200 -200 -200", "200 200 200");
		SpawnNavBrush("nav_avoid_walkdown_back", 4000, 100, -400, "-400 -300 -200", "200 300 200"); SpawnNavBrush("nav_avoid_walkdown_back_right", 3900, -1200, -250, "-400 -200 -400", "350 200 400"); SpawnNavBrush("nav_avoid_back_corridor_right", 2800, 600, 0, "-400 -250 -400", "600 200 400");
		SpawnNavBrush("nav_avoid_back_corridor_left", 4000, -1500, 0, "-500 -200 -400", "250 150 400"); SpawnNavBrush("nav_avoid_back_corridor_middle", 3500, -600, 0, "-200 -200 -400", "200 200 400"); SpawnNavBrush("nav_avoid_back_overpass", 3700, 100, 0, "-200 -275 -100", "200 275 400");
		SpawnNavBrush("nav_avoid_middle_corridor_left", 2700, 100, 0, "-300 -250 -200", "200 150 200"); SpawnNavBrush("nav_avoid_back_sidepath", 5400, 200, 0, "-150 -200 -200", "150 200 200"); SpawnNavBrush("nav_avoid_alienhunter_special", 2800, -800, -400, "-150 -100 -100", "150 100 100")
	}

	w1_hatch_box = null

	w2_s3_minigame_bombcart_prop = null
	w2_s3_minigame_bombcart_prop_bbox = null

	stage1_blockade_center = SpawnEntityFromTable("prop_dynamic", { origin = Vector(1400, -800, -325), model = "models/props_gameplay/security_fence512.mdl", solid = 6, disableshadows = 1 })
	stage1_blockade_left = SpawnEntityFromTable("prop_dynamic", { origin = Vector(1700, -450, -150), angles = QAngle(0, 90, 0), model = "models/props_gameplay/security_fence512.mdl", solid = 6, disableshadows = 1 })
	stage1_blockade_right = SpawnEntityFromTable("prop_dynamic", { origin = Vector(450, -1150, -300), model = "models/props_gameplay/security_fence512.mdl", solid = 6, disableshadows = 1 })

	stage1_blockade_center_nobuild = SpawnEntityFromTable("func_nobuild", { origin = Vector(1214, -749, -380) })
	stage1_blockade_left_nobuild = SpawnEntityFromTable("func_nobuild", { origin = Vector(1677, -620, -179) })
	stage1_blockade_right_nobuild = SpawnEntityFromTable("func_nobuild", { origin = Vector(376, -1125, -284) })

	stage1_blockade_deathpit = SpawnEntityFromTable("prop_dynamic", { origin = Vector(2600, -100, -400), model = "models/props_gameplay/security_fence512.mdl", solid = 6 })

	blood_tank_outofblood_healthdrain = SpawnEntityFromTable("trigger_hurt",
	{
		targetname  = "tank_outofblood_healthdrain"
		damage 		= 50
		damagecap   = 9999
		damagetype  = 1
		damagemodel = 0
		spawnflags  = 64
	})

	blood_tank_heal_hud_update = SpawnEntityFromTable("trigger_hurt",
	{
		targetname  = "tank_heal_hud_update"
		damage 		= 1
		damagecap   = 9999
		damagetype  = 1
		damagemodel = 0
		spawnflags  = 64
	})

	blood_tank_minidispenser_trigger = SpawnEntityFromTable("dispenser_touch_trigger",
	{
		targetname    	   = "blood_tank_minidispenser_trigger"
		spawnflags         = 1
		origin             = Vector(0, 0, 9999)
	})

	blood_tank_minidispenser_mapobj = SpawnEntityFromTable("mapobj_cart_dispenser",
	{
		targetname    	   = "blood_tank_minidispenser_mapobj"
		TeamNum            = 3,
		spawnflags         = 12
		touch_trigger      = "blood_tank_minidispenser_trigger"
		origin             = Vector(0, 0, 9999)
	})

	blood_tank_blood_trail = SpawnEntityFromTable("env_blood",
	{
		spraydir                = QAngle(90, 0, 0)
		color                   = 0
		amount                  = 1000
		spawnflags              = 8
		StartDisabled           = 1
	})

	tank_blood_level_hud = SpawnEntityFromTable("game_text",
	{
		channel      = 2
		color        = "255 0 0"
		effect       = 0
		fadein       = 0
		fadeout      = 0
		fxtime       = 0
		message      = "███████████████"
		holdtime     = 1.0
		spawnflags   = 1
		x            = 0.803
		y            = 0.615
	})

	WaveStartFunctions = function()
	{
		previous_wave = WAVE

		EntFireByHandle(tank_blood_level_hud, "Display", null, -1.0, null, null)

		deplete_blood_cooldown = Time() + 4
		bloodbot_dispatchtime = Time() + RandomFloat(next_bloodbot_dispatchtime_min, next_bloodbot_dispatchtime_max)

		local think_stage1_blockade_rise = SpawnEntityFromTable("logic_relay", {targetname = "think_stage1_blockade_rise"})
		AddThinkToEnt(think_stage1_blockade_rise, "Stage1_RiseBlockade_Think")

		stage1_blockade_center_nobuild.Kill()
		stage1_blockade_right_nobuild.Kill()
		stage1_blockade_left_nobuild.Kill()

		SetUpCustomNavigation(); SetUpCustomNavigation() // calling this twice to make sure bots never disobey the funcs

		// foreach (bluplayer in bluplayer_array) bluplayer.GetScriptScope().bloodstorage.turngiantreminder_cooldown = Time() + RandomInt(30, 120)

		foreach (bluplayer in bluplayer_array)
		{
			if (WAVE == 3) DeliverVisualTipToPlayer(bluplayer, "vis_collecttnt", "Stand near the Blood Tank to get TNT", true, 45.0)

			DeliverVisualTipToPlayer(bluplayer, "vis_howtoplay", "Prevent the enemy RED attackers\nfrom destroying your Blood Tank!")

			SendGlobalGameEvent("hide_annotation", { id = bluplayer.entindex() })
			SendGlobalGameEvent("hide_annotation", { id = bluplayer.entindex() * 500 })
			SendGlobalGameEvent("hide_annotation", { id = bluplayer.entindex() * 1000 })
		}

		switch (WAVE)
		{
			case 1: active_spawns = [1, 2, 6, 8]; break
			case 2: active_spawns = [1, 2, 3, 5, 9]; break
			case 3: active_spawns = [1, 2, 3, 6, 12]; break
		}

		UpdateSpawnIndicators()
	}

	bloodbot_path_p1_vectorarray = // bloodbot path a stays the same for all 3 waves
	[
		Vector(-1000, 1000, -265), Vector(-1000, 540, -265), Vector(-1000, 240, -425), Vector(-1000, -230, -425), Vector(-1000, -350, -435), Vector(-1000, -600, -435)
		Vector(-1000, -750, -415), Vector(-841, -750, -415), Vector(-694, -750, -352), Vector(-610, -750, -352), Vector(-298, -1000, -352), Vector(400, -1000, -352)
		Vector(400, -1400, -352), Vector(1079, -1400, -352), Vector(1289, -1400, -448), Vector(1500, -1400, -448)
	]

	bloodbot_path_p2_vectorarray = null
	bloodbot_path_p3_vectorarray = null

	bloodbot_path_p1 = []
	bloodbot_path_p2 = []
	bloodbot_path_p3 = []

	bloodbot_path_p1_name_picker = []
	bloodbot_path_p2_name_picker = []
	bloodbot_path_p3_name_picker = []

	bloodbot_path_p1_origin_picker = []
	bloodbot_path_p2_origin_picker = []
	bloodbot_path_p3_origin_picker = []

	CALLBACKS =
	{
		OnGameEvent_recalculate_holidays = function(params) // do cleanup after mission switch
		{
			if (GetRoundState() == 3)
			{
				if (NetProps.GetPropString(objective_resource_entity, "m_iszMvMPopfileName") != mission)
				{
					foreach (thing, var in PEA) if (thing in getroottable()) delete getroottable()[thing]
					foreach (thing, var in PEA_ONETIME) if (thing in getroottable()) delete getroottable()[thing]

					for (local i = 1; i <= MaxClients().tointeger(); i++)
					{
						local player = PlayerInstanceFromIndex(i)
						if (player == null) continue

						player.SetScriptOverlayMaterial(null)

						if (player.GetScriptScope() != null)
						{
							foreach (thing in player.GetScriptScope())
							{
								try { thing.GetClassname() }
								catch (e) { continue }

								if (!thing.IsPlayer()) thing.Kill()
							}
						}

						player.TerminateScriptScope()

						player.SetGravity(1)
					}

					delete ::PEA
					delete ::PEA_ONETIME
					return
				}
			}
		}

		OnGameEvent_player_spawn = function(params)
		{
			local spawned_player = GetPlayerFromUserID(params.userid);

			if (spawned_player.IsFakeClient())
			{
				spawned_player.AddCond(43)
				EntFireByHandle(spawned_player, "CallScriptFunction", "BotTagCheck", -1.0, null, null)
				return
			}

			if (NetProps.GetPropString(spawned_player, "m_szNetworkIDString") == "[U:1:95064912]") debugger = spawned_player

			if (spawned_player.GetTeam() <= 1) return // when a player joins server, player_spawn fires twice: once when the player is at the initial class choice screen (as team 0 undefined), and then again when they actually spawn on blu side

			if (players_joining_array.find(spawned_player) != null) players_joining_array.remove(players_joining_array.find(spawned_player))

			if (bluplayer_array.find(spawned_player) == null) bluplayer_array.append(spawned_player)

			spawned_player.ValidateScriptScope()
			local scope = spawned_player.GetScriptScope()

			// ClientPrint(null,3,"player spawned: team " + spawned_player.GetTeam())

			if (!("bloodstorage" in scope))
			{
				EntFireByHandle(gamerules_entity, "CallScriptFunction", "WormholeCloseCheck", 5.0, null, null)

				scope.bloodstorage <- BloodStorage(spawned_player)

				// ClientPrint(null,3,"class setup")

				spawned_player.Teleport(true, Vector(0, 0, 1900), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
				spawned_player.SetAbsVelocity(Vector(0, 0, -500))

				switch (spawned_player.GetPlayerClass())
				{
					case pyro: spawned_player.PlayScene(wormhole_spawn_screams.pyro[RandomInt(0, wormhole_spawn_screams.pyro.len() - 1)], -1.0); break
					case engineer: spawned_player.PlayScene(wormhole_spawn_screams.engineer[RandomInt(0, wormhole_spawn_screams.engineer.len() - 1)], -1.0); break
					case sniper: spawned_player.PlayScene(wormhole_spawn_screams.sniper[RandomInt(0, wormhole_spawn_screams.sniper.len() - 1)], -1.0); break

					default: EntFireByHandle(spawned_player, "SpeakResponseConcept", "HalloweenLongFall", -1.0, null, null)
				}
			}

			else
			{
				if (scope.bloodstorage.used_recall) { scope.bloodstorage.used_recall = false; return }

				scope.bloodstorage.ResetBloodCounter()
			}

			scope = scope.bloodstorage

			EntFireByHandle(spawned_player, "CallScriptFunction", "PostSpawnFunctions", 1.0, null, null)

			if (scope.wants_robot_viewmodels) EntFireByHandle(spawned_player, "CallScriptFunction", "OverrideRobotArms", -1.0, null, null)

			if (in_setup() && scope.firsttimeplayer) EntFireByHandle(spawned_player, "CallScriptFunction", "ReceiveHowToPlayAnnotations", 0.1, null, null)

			if (spawned_player.GetPlayerClass() == spy) EntFireByHandle(spawned_player, "CallScriptFunction", "OverrideSapper", -1.0, null, null)

			if (objective_type == "deliver") EntFireByHandle(gamerules_entity, "CallScriptFunction", "RefreshDeliverAnnotations", -1.0, null, null)

			if (scope.escaped != "[X]") spawned_player.Teleport(true, Vector(0, 1700, -300), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))

			if (in_endgame && scope.escaped != "[X]") spawned_player.Teleport(true, Vector(0, 1600, -200), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
		}

		OnGameEvent_player_death = function(params)
		{
			local dead_player = GetPlayerFromUserID(params.userid);

			dead_player.ValidateScriptScope()

			local scope

			if (!dead_player.IsFakeClient())
			{
				scope = dead_player.GetScriptScope().bloodstorage

				SpawnGrayBlood(dead_player.GetOrigin(), "human", scope.blood_count / 2, scope.poisoned)

				if (WAVE == 3) SpawnGrayBlood(dead_player.GetOrigin(), "human", scope.tnt_count / 2, false, true)

				if (scope.blood_count >= 2) DeliverTipToPlayer(dead_player, "deathandblood", "When you die, half of the blood that you carried at the time is dropped to the ground, allowing your teammates to pick it up.")

				scope.ResetBloodCounter()

				for (local marker; marker = Entities.FindByClassname(marker, "entity_revive_marker"); ) { if (marker.GetModelName() != "models/props_mvm/mvm_revive_tombstone_blu.mdl") marker.SetModelSimple("models/props_mvm/mvm_revive_tombstone_blu.mdl") }

				if (draw_debugchat) ClientPrint(null,3,"temp vars reset (from player_death)")
			}

			else
			{
				scope = dead_player.GetScriptScope()

				NetProps.SetPropBool(dead_player, "m_bForcedSkin", false); NetProps.SetPropInt(dead_player, "m_nForcedSkin", 0)

				if (dead_player.GetPlayerClass() == spy) EntFireByHandle(gamerules_entity, "CallScriptFunction", "CheckForDeadSpies", -1.0, null, null)

				if (!dead_player.IsMiniBoss() && !dead_player.HasBotTag("escortbot")) SpawnGrayBlood(dead_player.GetOrigin(), "bot", 1, (dead_player.HasBotTag("zombie_bot") ? true : false))

				if (dead_player.HasBotTag("squad_leader"))
				{
					dead_player.DisbandCurrentSquad()

					for (local i = 1; i <= MaxClients().tointeger(); i++)
					{
						local bot = PlayerInstanceFromIndex(i)

						if (bot == null) continue
						if (!bot.IsFakeClient()) continue
						if (bot.GetTeam() != 2) continue
						if (NetProps.GetPropInt(bot, "m_lifeState") != 0) continue
						if (bot.HasBotTag("aggrobot")) continue
						if (bot.IsInASquad()) continue

						if ((bot.GetPlayerClass() == soldier || bot.GetPlayerClass() == demoman) && !bot.HasWeaponRestriction(1)) EntFireByHandle(bot, "$BotCommand", "interrupt_action -posent blood_tank -lookposent blood_tank -killlook -delay 0 -duration 3600 -cooldown 3600 -distance 500", 0.05, null, null)
						else																		  						   	  EntFireByHandle(bot, "$BotCommand", "interrupt_action -posent blood_tank -lookposent blood_tank -killlook -delay 0 -duration 3600 -cooldown 3600", 0.05, null, null)
					}
				}

				local skipcashteleport = false

				try { params.weaponid }
				catch (e) { skipcashteleport = true }

				if (!skipcashteleport && (params.weaponid == 17 || params.weaponid == 77 || params.weaponid == 99 || (params.weapon_def_index != 171 && params.weapon == "bleed_kill"))) // sniper rifle cash teleport code
				{
					local killer = GetPlayerFromUserID(params.attacker)

					if (NetProps.GetPropInt(killer, "m_PlayerClass") == sniper)
					{
						EmitSoundEx({ sound_name = "sniper_cashteleport.wav", filter_type = 5, volume = 0.2, entity = killer, pitch = 100, flags = 0, channel = 6 })

						for (local cash; cash = Entities.FindByNameWithin(cash, "gray_blood_*", dead_player.EyePosition(), 250.0); )
						{
							local killer_unique_string = UniqueString()

							local dest = SpawnEntityFromTable("info_teleport_destination", { targetname = "dest2", origin = cash.GetOrigin() })

							DispatchParticleEffect("wrenchmotron_teleport_sparks", dest.GetOrigin(), Vector(0, 90, 0))

							killer.KeyValueFromString("targetname", killer_unique_string)

							local beam = SpawnEntityFromTable("env_beam",
							{
								life                    = 0
								boltwidth               = 1
								LightningStart			= killer_unique_string
								LightningEnd			= "dest2"
								NoiseAmplitude          = 1
								rendercolor				= "153 194 216"
								texture					= "sprites/laserbeam.spr"
								spawnflags				= 1
							})

							killer.KeyValueFromString("targetname", "")

							EntFireByHandle(beam, "Kill", null, 0.25, null, null)
							dest.Kill()

							cash.Teleport(true, killer.EyePosition(), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
						}
					}
				}

				if (dead_player.HasBotTag("huntbot")) ObjectiveProgress()

				if (dead_player.HasBotTag("iceblock_healthbar")) DestroyIceBlock_P1()

				local child_array = []

				for (local child = dead_player.FirstMoveChild(); child != null; child = child.NextMovePeer()) child_array.append(child)

				foreach (child in child_array)
				{
					if (child.GetClassname() == "tf_glow") SendGlobalGameEvent("hide_annotation", { id = child.entindex() })

					if (child.GetClassname() != "tf_wearable") continue // causes complications with mediguns (patients retain healing and uber of killed healer)

					if (child in scope) delete scope.child

					child.Kill()
				}

				if (dead_player.HasBotTag("barricadebomb")) return

				if (dead_player.HasBotTag("alienhunter"))
				{
					if (bluplayer_array.find(dead_player) != null) bluplayer_array.remove(bluplayer_array.find(dead_player))
					dead_player.SetGravity(1)
				}

				NetProps.SetPropString(dead_player, "m_iszScriptThinkFunction", "")

				foreach (thing in scope)
				{
					try { thing.GetClassname() }
					catch (e) { continue }

					if (thing.GetClassname() != "player") thing.Kill()
				}

				dead_player.TerminateScriptScope()
			}
		}

		//// Make sure that players can turn giant if the round was restarted while they were giant

		OnGameEvent_teamplay_round_start = function(params)
		{
			// ClientPrint(null,3,"round restarted")

			for (local i = 1; i <= MaxClients().tointeger(); i++)
			{
				local player = PlayerInstanceFromIndex(i)

				local scope

				if (player == null) continue

				if (player.IsFakeClient()) player.ForceChangeTeam(1, true)

				if (player.GetTeam() == 1) // bots not in play are spectators!
				{
					if (player.IsFakeClient())
					{
						NetProps.SetPropBool(player, "m_bForcedSkin", false); NetProps.SetPropInt(player, "m_nForcedSkin", 0)

						if (bluplayer_array.find(player) != null) bluplayer_array.remove(bluplayer_array.find(player)) // alien hunter

						scope = player.GetScriptScope()

						if (!scope) continue

						local child_array = []

						for (local child = player.FirstMoveChild(); child != null; child = child.NextMovePeer()) child_array.append(child)

						foreach (child in child_array)
						{
							if (child.GetClassname() != "tf_wearable") continue // causes complications with mediguns (patients retain healing and uber of killed healer)

							if (child in scope) delete scope.child
							NetProps.SetPropString(child, "m_iszScriptThinkFunction", "")
							child.Kill()
						}

						foreach (thing in scope)
						{
							try { thing.GetClassname() }
							catch (e) { continue }

							if (thing.GetClassname() != "player") thing.Kill()
						}

						player.TerminateScriptScope()
						NetProps.SetPropString(player, "m_iszScriptThinkFunction", "")

						continue
					}

					if (bluplayer_array.find(player) == null) continue
				}

				// if (bluplayer_array.find(player) == null) bluplayer_array.append(player)

				if (!("bloodstorage" in player.GetScriptScope())) continue

				scope = player.GetScriptScope().bloodstorage

				if ("selfglow" in scope) delete scope.selfglow

				scope.in_tip_cooldown = false
				scope.escaped = "[X]"

				scope.GiantRobot_Control("end_cooldown")
			}

			EntFireByHandle(gamerules_entity, "CallScriptFunction", "UndoTipUnlocks", 0.03, null, null)
		}

		//// Kill all entities related to disconnecting players

		OnGameEvent_player_disconnect = function(params)
		{
			local disconnected_player = GetPlayerFromUserID(params.userid)

			if (IsPlayerABot(disconnected_player)) return

			if (players_joining_array.find(disconnected_player) != null) players_joining_array.remove(players_joining_array.find(disconnected_player))

			if (disconnected_player == debugger) debugger = null

			EntFireByHandle(gamerules_entity, "CallScriptFunction", "WormholeCloseCheck", 5.0, null, null)

			local disc_player_id = NetProps.GetPropString(disconnected_player, "m_szNetworkIDString")

			for (local ent; ent = Entities.FindByName(ent, disc_player_id + "_player_*"); ) ent.Kill()

			if (bluplayer_array.find(disconnected_player) != null) bluplayer_array.remove(bluplayer_array.find(disconnected_player))
		}

		OnGameEvent_player_team = function(params)
		{
			local player = GetPlayerFromUserID(params.userid)

			if (player.IsFakeClient()) return

			// printl("player_team procced: team " + player.GetTeam())

			if (params.team == 1)
			{
				if (players_joining_array.find(player) != null) players_joining_array.remove(players_joining_array.find(player))
				if (bluplayer_array.find(player) != null) bluplayer_array.remove(bluplayer_array.find(player))
			}

			EntFireByHandle(gamerules_entity, "CallScriptFunction", "WormholeCloseCheck", 5.0, null, null)
		}

		OnGameEvent_player_activate = function(params)
		{
			local activated_player = GetPlayerFromUserID(params.userid)

			if (!activated_player.IsFakeClient() && bluplayer_array.len() < 6)
			{
				players_joining_array.append(activated_player)

				if (!NetProps.GetPropBool(Entities.FindByName(null, "ptcs_wormhole"), "m_bActive")) EntFire("wormhole_start_relay", "Trigger")
			}
		}

		OnGameEvent_mvm_wave_complete = function(params)
		{
			suppress_waveend_music = true
			EntFireByHandle(gamerules_entity, "RunScriptCode", "suppress_waveend_music = false", 10.0, null, null)

			if (WAVE == 1) EmitGlobalSound("music.mvm_end_wave")
			if (WAVE == 2) EmitGlobalSound("music.mvm_end_mid_wave")
			if (WAVE == 3) EmitGlobalSound("ui/mm_level_six_achieved.wav")
		}

		OnGameEvent_player_builtobject = function(params)
		{
			local bot = GetPlayerFromUserID(params.userid)

			if (bot.IsFakeClient() && params.object == 2)
			{
				EntIndexToHScript(params.index).KeyValueFromString("targetname", "glow_target")

				local sentry_glow = SpawnEntityFromTable("tf_glow",
				{
					target           	  = "glow_target"
					GlowColor             = "255 255 0 255"
				})

				EntIndexToHScript(params.index).KeyValueFromString("targetname", "")

				AddThinkToEnt(sentry_glow, "DangerBlink_Think")

				EntFireByHandle(sentry_glow, "SetParent", "!activator", -1.0, EntIndexToHScript(params.index), null)
			}

			if (params.object == 3) EntFireByHandle(gamerules_entity, "CallScriptFunction", "UnicornSapper", 0.1, null, null)
		}

		OnGameEvent_object_destroyed = function(params)
		{
			if (bluplayer_array.find(GetPlayerFromUserID(params.attacker)) == null) return

			GetPlayerFromUserID(params.attacker).GetScriptScope().bloodstorage.bloodbots_destroyed++
		}

		OnGameEvent_npc_hurt = function(params)
		{
			local victim = EntIndexToHScript(params.entindex)

			if (victim == blood_tank)
			{
				EntFireByHandle(blood_tank.GetScriptScope().dangerglow, "Enable", null, -1.0, null, null)
				EntFireByHandle(blood_tank.GetScriptScope().dangerglow, "Disable", null, 0.1, null, null)

				return
			}

			if (params.weaponid == 18) victim.SetHealth(victim.GetHealth() + (params.damageamount.tofloat() * 0.75)) // minigun
		}

		OnGameEvent_player_used_powerup_bottle = function(params)
		{
			local player = EntIndexToHScript(params.player)

			if (params.type == 3)
			{
				player.GetScriptScope().bloodstorage.used_recall = true

				local soundscape = NetProps.GetPropInt(player, "m_Local.m_audio.soundscapeIndex")

				if (soundscape == 154 || soundscape == 155) EntFireByHandle(player, "RunScriptCode", "RecallTeleport(true)", -1.0, null, null)
				else										EntFireByHandle(player, "RunScriptCode", "RecallTeleport(false)", -1.0, null, null)
			}
		}

		OnGameEvent_teamplay_point_captured = function(params)
		{
			for (local ent; ent = Entities.FindByClassname(ent, "trigger_capture_area"); )
			{
				EntFireByHandle(ent, "Disable", null, 0.05, null, null)
				EntFireByHandle(ent, "Enable", null, 0.1, null, null)
			}
		}
	}

	RecallTeleport = function(was_outside)
	{
		local scope = self.GetScriptScope().bloodstorage

		if (in_endgame)
		{
			if (scope.escaped == "[X]") self.Teleport(true, Vector(4100, 2200, 100), true, QAngle(0, -90, 0), false, Vector(0, 0, 0))
			else						self.Teleport(true, Vector(1150, -400, -400), true, QAngle(0, -90, 0), false, Vector(0, 0, 0))

			return
		}

		if (in_setup()) self.Teleport(true, Vector(100, 100, -400), true, QAngle(0, -90, 0), false, Vector(0, 0, 0))
		else
		{
			if (was_outside && NetProps.GetPropFloat(blood_tank, "m_speed") < 74.0)
			{
				self.Teleport(true, blood_tank.GetOrigin() + Vector(0, 0, 100), true, blood_tank.GetAbsAngles(), false, Vector(0, 0, 0))

				// credit goes to lite for this antistuck code below

				local origin = self.GetOrigin()

				local trace =
				{
					start = origin,
					end = origin,
					hullmin = self.GetBoundingMins(),
					hullmax = self.GetBoundingMaxs(),
					mask = 33636363,
					ignore = self
				}

				TraceHull(trace)

				if ("startsolid" in trace)
				{
					local dirs = [Vector(1, 0, 0), Vector(-1, 0, 0), Vector(0, 1, 0), Vector(0, -1, 0), Vector(0, 0, 1), Vector(0, 0, -1)]

					for (local i = 16; i <= 96; i += 16)
					{
						foreach (dir in dirs)
						{
							trace.start = origin + dir * i
							trace.end = trace.start

							delete trace.startsolid

							TraceHull(trace)

							if (!("startsolid" in trace)) { self.SetAbsOrigin(trace.end); break }
						}

						if (!("startsolid" in trace)) break
					}
				}
			}

			else self.Teleport(true, Vector(100, 100, -400), true, QAngle(0, -90, 0), false, Vector(0, 0, 0))
		}
	}

	BotTagCheck = function()
	{
		local turnhuman = true
		local goaftertank = true
		local goaftertank_delay = 0.05

		// self.TakeDamage(99999, 1, blood_tank_outofblood_healthdrain)
		// return

		if (in_endgame) { self.ForceChangeTeam(1, true); return }

		if (self.HasBotTag("aggrobot"))
		{
			goaftertank = false
			DeliverTipToBLU("aggrobots", "Defenders with distinctly colored helmets ignore the Blood Tank and hunt down the attackers instead.")

			if (self.HasBotTag("goaftercontrolpoints_any")) EntFireByHandle(self, "$BotCommand", "interrupt_action -posent control_point_" + RandomInt(1, 3) + " -delay 0 -duration 3600 -cooldown 3600", goaftertank_delay, null, null)
			if (self.HasBotTag("goaftercontrolpoints_b")) EntFireByHandle(self, "$BotCommand", "interrupt_action -posent control_point_2 -delay 0 -duration 3600 -cooldown 3600", goaftertank_delay, null, null)
			if (self.HasBotTag("goaftercontrolpoints_c")) EntFireByHandle(self, "$BotCommand", "interrupt_action -posent control_point_3 -delay 0 -duration 3600 -cooldown 3600", goaftertank_delay, null, null)

			if (self.HasBotTag("goaftericeblock")) EntFireByHandle(self, "$BotCommand", "interrupt_action -posent iceblock -delay 0 -duration 3600 -cooldown 3600", goaftertank_delay, null, null)
		}

		if (self.HasBotTag("support")) goaftertank = false
		if (self.HasBotTag("sniperrifle")) AddThinkToEnt(NetProps.GetPropEntityArray(self, "m_hMyWeapons", 0), "SniperRifleLaser_Think")
		if (self.GetPlayerClass() == spy) { if (Time() > spyalert_cooldown) EmitGlobalSound("Announcer.MVM_Spy_Alert"); spyalert_cooldown = Time() + 3.0 }

		if (self.HasBotTag("bombrunner")) AddThinkToEnt(self, "BombRunner_Think")
		if (self.HasBotTag("escortbot")) { self.RemoveCond(43); AddThinkToEnt(self, "EscortBot_Think"); turnhuman = false }
		if (self.HasBotTag("huntbot")) { goaftertank = false; AddThinkToEnt(self, "HuntBot_Think") }
		if (self.HasBotTag("barricadebomb")) { self.SetMoveType(0,0); AddThinkToEnt(self, "BarricadeBomb_Think"); return }
		if (self.HasBotTag("aoe_medic")) AddThinkToEnt(self, "AoEUber_Think")
		if (self.HasBotTag("iceblock_healthbar")) { self.SetMoveType(0,0); AddThinkToEnt(self, "DisplayIceblockHealthbar_Think") }
		if (self.HasBotTag("alienhunter"))
		{
			goaftertank = false

			if (bluplayer_array.find(self) == null) bluplayer_array.append(self)

			TeleportPlayer(Vector(0, 0, -180))
			self.RemoveCond(43)

			AddThinkToEnt(self, "AlienHunter_Think")

			if (debug && debug_stage == 3) TeleportPlayer(Vector(4500, 600, 100))
		}

		if (goaftertank)
		{
			if (!self.IsInASquad() || (self.IsInASquad() && self.HasBotTag("squad_leader")))
			{
				if (self.HasBotTag("has_banner")) goaftertank_delay = 1.0

				if ((self.GetPlayerClass() == soldier || self.GetPlayerClass() == demoman) && !self.HasWeaponRestriction(1)) EntFireByHandle(self, "$BotCommand", "interrupt_action -posent blood_tank -lookposent blood_tank -killlook -delay 0 -duration 3600 -cooldown 3600 -distance 500", goaftertank_delay, null, null)
				else																										 EntFireByHandle(self, "$BotCommand", "interrupt_action -posent blood_tank -lookposent blood_tank -killlook -delay 0 -duration 3600 -cooldown 3600", goaftertank_delay, null, null)
			}

			if (self.HasBotTag("w1_start"))
			{
				EntFireByHandle(self, "$BotCommand", "interrupt_action -pos -350 900 -450 -delay 0 -waituntildone -duration 0 -cooldown 3600", goaftertank_delay, null, null)
				EntFireByHandle(self, "$BotCommand", "interrupt_action -posent blood_tank -lookposent blood_tank -killlook -delay 0 -duration 3600 -cooldown 3600", 5.0, null, null)
			}
		}

		if (self.IsMiniBoss())
		{
			turnhuman = false
			self.AddCustomAttribute("damage force reduction", 0, -1.0)

			self.AddBotTag("avoid_dropdown_middle") // can't fit
			if (!self.HasBotTag("bombrunner") && !self.HasBotTag("alienhunter")) EmitGlobalSound("MVM.GiantHeavyEntrance")
			if (!self.HasBotTag("bombrunner") && !self.HasBotTag("huntbot")) AttachGlow()
		}

		else if (self.GetModelScale() > 1.0)
		{
			NetProps.SetPropBool(self, "m_bForcedSkin", true); NetProps.SetPropInt(self, "m_nForcedSkin", 4)
			GetWearable(format("models/player/items/%s/%s_zombie.mdl", class_integers[self.GetPlayerClass()], class_integers[self.GetPlayerClass()]))
			self.AddCustomAttribute("voice pitch scale", 0.5, -1.0)
			self.AddBotTag("zombie_bot")
		}

		if (turnhuman) self.SetCustomModelWithClassAnimations(format("models/player/%s.mdl", class_integers[self.GetPlayerClass()]))

		self.GetLocomotionInterface().Reset()
	}

	OverrideSapper = function()
	{
		for (local i = 0; i < 8; i++)
		{
			local weapon = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i)

			if (weapon == null) continue

			local weaponid = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex")

			if (weaponid == 810 || weaponid == 831)
			{
				weapon.AddAttribute("sapper degenerates buildings", 0, -1.0)
				weapon.AddAttribute("sapper damage penalty", 1, -1.0)
			}
		}
	}

	PostSpawnFunctions = function()
	{
		if (current_stage == 2 || current_stage == 3) DeliverVisualTipToPlayer(self, "vis_recall", "The 'Recall' canteen can teleport you between\nthe Blood Tank and the Upgrade Station", true, 90.0)
	}

	OverrideRobotArms = function()
	{
		local has_gunslinger = false

		for (local i = 0; i < 8; i++)
		{
			local weapon = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i)

			if (weapon == null) continue

			if (NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 142) has_gunslinger = true
		}

		for (local i = 0; i < 8; i++)
		{
			local weapon = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i)

			if (weapon == null) continue

			if (has_gunslinger) NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel("models/mvm/weapons/c_models/c_engineer_bot_gunslinger.mdl"))

			else
			{
				local weaponid = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex")

				switch (weaponid)
				{
					case 27: NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel("models/mvm/weapons/v_models/v_pda_spy_bot.mdl")); break // disguise kit
					case 30: NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel("models/mvm/weapons/v_models/v_watch_spy_bot.mdl")); break // invis watch
					case 59: NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel("models/mvm/weapons/v_models/v_watch_pocket_spy_bot.mdl")); break // dead ringer
					case 60: NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel("models/mvm/weapons/v_models/v_watch_leather_spy_bot.mdl")); break // cloak and dagger
					case 297: NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel("models/mvm/weapons/v_models/v_ttg_watch_spy_bot.mdl")); break // enthusiast's timepiece
					case 947: NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel("models/mvm/workshop_partner/weapons/v_models/v_hm_watch/v_hm_watch_bot.mdl")); break // quackenbirdt
					default: NetProps.SetPropInt(weapon, "m_nCustomViewmodelModelIndex", PrecacheModel(format("models/mvm/weapons/c_models/c_%s_bot_arms.mdl", class_integers[self.GetPlayerClass()]))); break
				}

				if (weaponid == 56 || weaponid == 1005 || weaponid == 1092) weapon.AddAttribute("reload time increased hidden", -5.0, -1.0) // very hacky fix for bow weapons not reloading properly with vscript-implemented robot viewmodels
			}
		}

		local wep = self.GetActiveWeapon()
		NetProps.SetPropEntity(self, "m_hActiveWeapon", null)
		self.Weapon_Switch(wep)
	}

	GetWeapon = function(className, itemID)
	{
		local weapon = Entities.CreateByClassname(className)

		NetProps.SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", itemID)
		NetProps.SetPropBool(weapon, "m_AttributeManager.m_Item.m_bInitialized", true)
		NetProps.SetPropBool(weapon, "m_bValidatedAttachedEntity", true)

		weapon.SetTeam(self.GetTeam())

		Entities.DispatchSpawn(weapon)

		for (local i = 0; i < 8; i++)
		{
			local heldWeapon = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i)

			if (heldWeapon == null) continue
			if (heldWeapon.GetSlot() != weapon.GetSlot()) continue

			heldWeapon.Destroy()

			NetProps.SetPropEntityArray(self, "m_hMyWeapons", null, i)
			break
		}

		self.Weapon_Equip(weapon)
		self.Weapon_Switch(weapon)
	}

	GetWearable = function(model, bonemerge = true)
	{
		local modelIndex = GetModelIndex(model)
		if (modelIndex == -1) modelIndex = PrecacheModel(model)

		local wearable = Entities.CreateByClassname("tf_wearable")

		NetProps.SetPropInt(wearable, "m_nModelIndex", modelIndex)

		wearable.SetSkin(self.GetTeam())
		wearable.SetTeam(self.GetTeam())
		wearable.SetSolidFlags(4)
		wearable.SetCollisionGroup(11)

		NetProps.SetPropBool(wearable, "m_bValidatedAttachedEntity", true)
		NetProps.SetPropBool(wearable, "m_AttributeManager.m_Item.m_bInitialized", true)
		NetProps.SetPropInt(wearable, "m_AttributeManager.m_Item.m_iEntityQuality", 0)
		NetProps.SetPropInt(wearable, "m_AttributeManager.m_Item.m_iEntityLevel", 1)
		NetProps.SetPropInt(wearable, "m_AttributeManager.m_Item.m_iItemIDLow", 2048)
		NetProps.SetPropInt(wearable, "m_AttributeManager.m_Item.m_iItemIDHigh", 0)

		wearable.SetOwner(self)
		Entities.DispatchSpawn(wearable)

		NetProps.SetPropInt(wearable, "m_fEffects", bonemerge ? 1 | 128 : 0)

		NetProps.SetPropEntity(wearable, "m_hMovePeer", self.FirstMoveChild())
		NetProps.SetPropEntity(self, "m_hMoveChild", wearable)
		NetProps.SetPropEntity(wearable, "m_hMoveParent", self)

		local origPos = wearable.GetLocalOrigin()
		wearable.SetLocalOrigin(origPos + Vector(0, 0, 1))
		wearable.SetLocalOrigin(origPos)

		local origAngles = wearable.GetLocalAngles()
		wearable.SetLocalAngles(origAngles + QAngle(0, 0, 1))
		wearable.SetLocalAngles(origAngles)

		local origVel = wearable.GetVelocity()
		wearable.SetVelocity(origVel + Vector(0, 0, 1))
		wearable.SetVelocity(origVel)

		EntFireByHandle(wearable, "SetParent", "!activator", 0, self, self)
	}

	LoseWearable = function(model)
	{
		local modelIndex = GetModelIndex(model)
		if (modelIndex == -1) modelIndex = PrecacheModel(model)

		local child_array = []

		for (local child = self.FirstMoveChild(); child != null; child = child.NextMovePeer()) child_array.append(child)

		foreach (child in child_array) if (NetProps.GetPropInt(child, "m_nModelIndex") == modelIndex) child.Kill()
	}

	UnicornSapper = function()
	{
		for (local i = 1; i <= MaxClients().tointeger(); i++)
		{
			local bot = PlayerInstanceFromIndex(i)

			if (bot == null) continue
			if (!bot.IsFakeClient()) continue
			if (bot.IsMiniBoss()) continue
			if (!bot.InCond(50)) continue

			EntFireByHandle(bot, "RunScriptCode", "GetWearable(`models/workshop/player/items/all_class/hw2013_the_magical_mercenary/hw2013_the_magical_mercenary_` + class_integers[self.GetPlayerClass()] + `.mdl`)", -1.0, null, null)
			EntFireByHandle(bot, "RunScriptCode", "LoseWearable(`models/workshop/player/items/all_class/hw2013_the_magical_mercenary/hw2013_the_magical_mercenary_` + class_integers[self.GetPlayerClass()] + `.mdl`)", 7.0, null, null)

			switch (NetProps.GetPropInt(bot, "m_PlayerClass"))
			{
				case scout: bot.PlayScene(unicorn_sapper_voicelines.scout[RandomInt(0, unicorn_sapper_voicelines.scout.len() - 1)], RandomFloat(0.0, 5.0)); break
				case soldier: bot.PlayScene(unicorn_sapper_voicelines.soldier[RandomInt(0, unicorn_sapper_voicelines.soldier.len() - 1)], RandomFloat(0.0, 5.0)); break
				case demoman: bot.PlayScene(unicorn_sapper_voicelines.demoman[RandomInt(0, unicorn_sapper_voicelines.demoman.len() - 1)], RandomFloat(0.0, 5.0)); break
				case heavyweapons: bot.PlayScene(unicorn_sapper_voicelines.heavyweapons[RandomInt(0, unicorn_sapper_voicelines.heavyweapons.len() - 1)], RandomFloat(0.0, 5.0)); break
				case engineer: bot.PlayScene(unicorn_sapper_voicelines.engineer[RandomInt(0, unicorn_sapper_voicelines.engineer.len() - 1)], RandomFloat(0.0, 5.0)); break
				case sniper: bot.PlayScene(unicorn_sapper_voicelines.sniper[RandomInt(0, unicorn_sapper_voicelines.sniper.len() - 1)], RandomFloat(0.0, 5.0)); break
				case spy: bot.PlayScene(unicorn_sapper_voicelines.spy[RandomInt(0, unicorn_sapper_voicelines.spy.len() - 1)], RandomFloat(0.0, 5.0)); break
			}
		}
	}

	WormholeCloseCheck = function()
	{
		if (players_joining_array.len() == 0) EntFire("wormhole_end_relay", "Trigger")

		else
		{
			local players_to_cull_array = []

			for (local i = 0; i <= players_joining_array.len() - 1; i++)
			{
				if (!players_joining_array[i].IsValid() || NetProps.GetPropInt(players_joining_array[i], "m_lifeState") == 0)
				{
					// printl(players_joining_array[i].GetTeam())
					players_to_cull_array.append(players_joining_array[i])
				}
			}

			foreach (player in players_to_cull_array) players_joining_array.remove(players_joining_array.find(player))

			if (players_joining_array.len() == 0) EntFire("wormhole_end_relay", "Trigger")
		}
	}

	ReceiveHowToPlayAnnotations = function()
	{
		SendGlobalGameEvent("show_annotation",
		{
			id = self.entindex()
			text = "How to play"
			worldPosX = blu_spawn_1_booth.GetOrigin().x
			worldPosY = blu_spawn_1_booth.GetOrigin().y
			worldPosZ = blu_spawn_1_booth.GetOrigin().z + 225
			visibilityBitfield = (1 << self.entindex())
			play_sound = "misc/null.wav"
			show_distance = false
			show_effect = false
			lifetime = -1
		})

		SendGlobalGameEvent("show_annotation",
		{
			id = self.entindex() * 500
			text = "How to play"
			worldPosX = blu_spawn_2_booth.GetOrigin().x
			worldPosY = blu_spawn_2_booth.GetOrigin().y
			worldPosZ = blu_spawn_2_booth.GetOrigin().z + 225
			visibilityBitfield = (1 << self.entindex())
			play_sound = "misc/null.wav"
			show_distance = false
			show_effect = false
			lifetime = -1
		})

		SendGlobalGameEvent("show_annotation",
		{
			id = self.entindex() * 1000
			text = "Upgrade Station"
			worldPosX = 60
			worldPosY = -150
			worldPosZ = -280
			visibilityBitfield = (1 << self.entindex())
			play_sound = "misc/null.wav"
			show_distance = false
			show_effect = false
			lifetime = -1
		})
	}

	RefreshDeliverAnnotations = function()
	{
		for (local ent; ent = Entities.FindByName(ent, "briefcase_pickup*"); )
		{
			SendGlobalGameEvent("show_annotation",
			{
				id = 10 + ent.GetName().slice(16)
				text = "Briefcase"
				follow_entindex = ent.entindex()
				play_sound = "misc/null.wav"
				show_distance = true
				show_effect = false
				lifetime = 3600
			})
		}
	}

	SniperRifleLaser_Think = function() // huge credit goes to royall for finding this out
	{
		local scope

		try { scope = self.GetScriptScope() }
		catch (e) { return }

		local weaponowner = NetProps.GetPropEntity(self, "m_hOwner")

		if (!("laser" in scope))
		{
			scope.laser <- SpawnEntityFromTable("info_particle_system",
			{
				targetname = "sniperrifle_laser"
				effect_name = "laser_sight_beam"
				start_active = 1
				flag_as_weather = 0
			})

			scope.pointer <- SpawnEntityFromTable("info_particle_system",
			{
				targetname = "sniperrifle_laserpointer"
				effect_name = "laser_sight_beam"
			})

			scope.color <- SpawnEntityFromTable("info_particle_system",
			{
				targetname = "sniperrifle_lasercolor"
				effect_name = "laser_sight_beam"
			})

			scope.color.SetAbsOrigin(Vector(255, 0, 0))

			NetProps.SetPropEntityArray(scope.laser, "m_hControlPointEnts", scope.pointer, 0)
			NetProps.SetPropEntityArray(scope.laser, "m_hControlPointEnts", scope.color, 1)

			scope.laser.SetOwner(weaponowner)
			scope.pointer.SetOwner(weaponowner)
			scope.color.SetOwner(weaponowner)

			NetProps.SetPropString(scope.laser, "m_iClassname", "env_sprite")
			NetProps.SetPropString(scope.pointer, "m_iClassname", "env_sprite")
		}

		if (weaponowner.InCond(1))
		{
			local tracetable =
			{
				start = weaponowner.EyePosition(),
				end = weaponowner.EyePosition() + (weaponowner.EyeAngles().Forward() * 32768.0)
				ignore = weaponowner
			}

			TraceLineEx(tracetable)

			if (!tracetable.hit) return

			scope.laser.SetAbsOrigin(weaponowner.EyePosition())
			scope.pointer.SetAbsOrigin(tracetable.pos)

			EntFireByHandle(scope.laser, "Start", null, -1, null, null)
		}

		else
		{
			EntFireByHandle(scope.laser, "Stop", null, -1, null, null)
			scope.laser.SetAbsOrigin(scope.pointer.GetOrigin())
		}
	}

	CheckForDeadSpies = function()
	{
		local spies_found = false

		for (local i = 1; i <= MaxClients().tointeger(); i++)
		{
			local bot = PlayerInstanceFromIndex(i)

			if (bot == null) continue
			if (!bot.IsFakeClient()) continue
			if (NetProps.GetPropInt(bot, "m_lifeState") != 0) continue

			if (bot.GetPlayerClass() == spy) spies_found = true
		}

		if (!spies_found) EmitGlobalSound("Announcer.mvm_spybot_death_all")
	}

	UndoTipUnlocks = function()
	{
		foreach (bluplayer in bluplayer_array)
		{
			local scope = bluplayer.GetScriptScope().bloodstorage

			if (previous_wave == WAVE)
			{
				foreach (tip in scope.tips_unlocked_during_wave) scope.tip_table[tip] = false
				scope.bloodbots_destroyed = 0
				scope.tnt_arm_count = 0
			}

			foreach (tip in scope.repeatable_tips) scope.tip_table[tip] = false

			scope.tips_unlocked_during_wave.clear()
			scope.repeatable_tips.clear()
		}

		previous_wave = WAVE
	}

	// â–ˆ = full block, â–‘ = shadowed block

	AcknowledgeBloodTank = function()
	{
		blood_tank = Entities.FindByName(blood_tank, "blood_tank")

		blood_tank.ValidateScriptScope()

		local scope = blood_tank.GetScriptScope()

		scope.dangerglow <- SpawnEntityFromTable("tf_glow",
		{
			target           	  = "blood_tank"
			GlowColor             = "255 0 0 255"
			StartDisabled		  = 1
		})

		EntFireByHandle(scope.dangerglow, "SetParent", "!activator", -1.0, blood_tank, null)

		scope.healglow <- SpawnEntityFromTable("tf_glow",
		{
			target           	  = "blood_tank"
			GlowColor             = "0 255 0 255"
			StartDisabled		  = 1
		})

		EntFireByHandle(scope.healglow, "SetParent", "!activator", -1.0, blood_tank, null)

		AddThinkToEnt(blood_tank, "BloodTank_Think")

		EntFireByHandle(tank_blood_level_hud, "Display", null, -1.0, null, null)

		if (!debug)
		{
			blood_tank.KeyValueFromFloat("speed", 250.0)

			EntFireByHandle(gamerules_entity, "CallScriptFunction", "SetUpBloodTank", 3.0, null, null)
		}

		else EntFireByHandle(gamerules_entity, "CallScriptFunction", "SetUpBloodTank", -1.0, null, null)

		AttachBloodDecals()

		stage1_check = Entities.FindByName(stage1_check, "tank_path_a_7")
		EntityOutputs.AddOutput(stage1_check, "OnPass", "gamerules", "CallScriptFunction", "Objective_Start", -1.0, -1)

		local displaytank = false

		foreach (bluplayer in bluplayer_array)
		{
			if (bluplayer.IsFakeClient()) continue

			local scope = bluplayer.GetScriptScope().bloodstorage
			if (scope.firsttimeplayer)
			{
				SendGlobalGameEvent("show_annotation",
				{
					id = blood_tank.entindex()
					text = "Blood Tank"
					follow_entindex = blood_tank.entindex()
					visibilityBitfield = (1 << bluplayer.entindex())
					play_sound = "misc/null.wav"
					show_distance = true
					show_effect = false
					lifetime = 3600
				})

				scope.firsttimeplayer = false
			}
		}

		if (WAVE == 3)
		{
			for (local i = 1; i <= 6; i++)
			{
				local ent = Entities.FindByName(null, "tnt_spot_" + i)
				AddThinkToEnt(ent, "ReceiveTNT_Think")
			}
		}
	}

	BloodTank_Think = function()
	{
		local scope = self.GetScriptScope()

		for (local player; player = Entities.FindByClassnameWithin(player, "player", self.GetOrigin(), 500.0); )
		{
			if (!player.IsFakeClient()) continue
			if (NetProps.GetPropInt(player, "m_lifeState") != 0) continue
			if (player.GetTeam() != 2) continue

			// if (!player.HasBotTag("aggrobot")) reds_near_bloodtank++

			if (player.IsInASquad() && !player.HasBotTag("squad_leader") && !player.HasBotTag("support")) player.SnapEyeAngles(VectorAngles(self.GetOrigin() - player.EyePosition()))
		}

		if (tank_speedboostticks > 0 && cur_tankspeed > 0)
		{
			blood_tank.KeyValueFromFloat("speed", cur_tankspeed + tank_speedboost)

			tank_speedboostticks--
		}

		if (tank_speedboostticks == 0 && NetProps.GetPropFloat(blood_tank, "m_speed") != cur_tankspeed) blood_tank.KeyValueFromFloat("speed", cur_tankspeed)

		// if (objective_type != null && NetProps.GetPropFloat(blood_tank, "m_speed") != 0) blood_tank.KeyValueFromFloat("speed", 0)

		// if (reds_near_bloodtank > 0)
		// {
			// if (prev_reds_near_bloodtank == 0)
			// {
				// EntFireByHandle(scope.dangerglow, "Enable", null, -1.0, null, null)
				// next_red_proximity_blink_time = Time() + RemapValClamped(reds_near_bloodtank, 1, 6, 1.0, 0.1)
			// }

			// else if (prev_reds_near_bloodtank < reds_near_bloodtank) next_red_proximity_blink_time -= RemapValClamped(reds_near_bloodtank, 1, 6, 1.0, 0.1)

			// if (Time() >= next_red_proximity_blink_time)
			// {
				// if (NetProps.GetPropBool(scope.dangerglow, "m_bDisabled")) EntFireByHandle(scope.dangerglow, "Enable", null, -1.0, null, null)
				// else													   EntFireByHandle(scope.dangerglow, "Disable", null, -1.0, null, null)

				// next_red_proximity_blink_time = Time() + RemapValClamped(reds_near_bloodtank, 1, 6, 1.0, 0.1)
			// }

			// ClientPrint(null,3,"" + (next_red_proximity_blink_time - Time()))
		// }

		// else if (prev_reds_near_bloodtank > 0) EntFireByHandle(scope.dangerglow, "Disable", null, -1.0, null, null)

		// prev_reds_near_bloodtank = reds_near_bloodtank
		// reds_near_bloodtank = 0

		if (objective_type != null && WAVE == 3)
		{
			// DeliverTipToBLU("volatilebloodtank", "The Blood Tank becomes highly volatile while it's not in motion, causing massive explosions to happen at random! Continue taking TNT and delivering blood to slow them down!")

			foreach (bluplayer in bluplayer_array)
			{
				if (bluplayer.IsFakeClient()) continue

				if (bluplayer.GetScriptScope().bloodstorage.audio_excludelist.find("pl_hoodoo/alarm_clock_ticking_3.wav") != null) continue

				EmitSoundEx({ sound_name = "pl_hoodoo/alarm_clock_ticking_3.wav", filter_type = 4, entity = bluplayer, volume = 0.6, pitch = 175 - ((tank_objective_explosion_time - Time()).tofloat() * 9.375), flags = 2, channel = 6 })
			}

			if (tank_objective_explosion_time - Time() <= 1.5)
			{
				tank_objective_explosion_imminent = true

				foreach (bluplayer in bluplayer_array)
				{
					if (bluplayer.IsFakeClient()) continue

					if (bluplayer.GetScriptScope().bloodstorage.audio_excludelist.find("pl_hoodoo/alarm_clock_alarm_3.wav") != null) continue

					EmitSoundEx({ sound_name = "pl_hoodoo/alarm_clock_alarm_3.wav", entity = bluplayer, volume = 0.6, filter_type = 4, pitch = 100, flags = 1, delay = -8, channel = 6 })
				}

			}

			if (Time() >= tank_objective_explosion_time)
			{
				tank_objective_explosion_imminent = false

				DispatchParticleEffect("fireSmoke_Collumn_mvmAcres", self.GetOrigin(), Vector(0, 90, 0))

				self.TakeDamage(1000, 1, blood_tank_outofblood_healthdrain)

				EmitGlobalSound("weapons/loose_cannon_explode.wav")

				tank_objective_explosion_cooldown = 8.0 + tank_objective_explosion_leftovers

				tank_objective_explosion_leftovers = 0.0

				tank_objective_explosion_time = Time() + tank_objective_explosion_cooldown
			}
		}

		return -1
	}

	SetUpBloodTank = function()
	{
		if (!debug) cur_tankspeed = tank_stage1_speed

		blood_tank.KeyValueFromFloat("speed", tank_stage1_speed)

		// else if (!debug_objective) blood_tank.KeyValueFromFloat("speed", 999.9)

		// local think_bloodtank_weaponswap_ent = SpawnEntityFromTable("logic_relay", {targetname = "think_bloodtank_weaponswap_ent"})
		// AddThinkToEnt(think_bloodtank_weaponswap_ent, "BloodTank_WeaponSwap_Think")

		blood_tank_minidispenser_trigger.Teleport(true, blood_tank.GetOrigin(), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
		EntFireByHandle(blood_tank_minidispenser_trigger, "SetParent", "blood_tank", -1.0, null, null)

		blood_tank_minidispenser_mapobj.Teleport(true, blood_tank.GetOrigin(), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
		EntFireByHandle(blood_tank_minidispenser_mapobj, "SetParent", "blood_tank", -1.0, null, null)

		EntFire("upgrade_front", "Enable")
	}

	AttachBloodDecals = function()
	{
		SpawnEntityGroupFromTable(
		{
			S1 =
			{
				env_sprite_oriented =
				{
					origin        = blood_tank.GetOrigin() + Vector(71, -40, 35)
					model         = "sprites/bloodtank_blood_decal1.vmt"
					angles        = QAngle(0, 0, 0)
				}
			}
			S2 =
			{
				env_sprite_oriented =
				{
					origin        = blood_tank.GetOrigin() + Vector(71, 40, 35)
					model         = "sprites/bloodtank_blood_decal3.vmt"
					angles        = QAngle(0, 0, 45)
				}
			}
			S3 =
			{
				env_sprite_oriented =
				{
					origin        = blood_tank.GetOrigin() + Vector(35, -25, 110)
					model         = "sprites/bloodtank_blood_decal5.vmt"
					angles        = QAngle(0, 0, 0)
				}
			}
			S4 =
			{
				env_sprite_oriented =
				{
					origin        = blood_tank.GetOrigin() + Vector(0, -83, 110)
					model         = "sprites/bloodtank_blood_decal6.vmt"
					angles        = QAngle(0, 90, 0)
				}
			}
			S5 =
			{
				env_sprite_oriented =
				{
					origin        = blood_tank.GetOrigin() + Vector(-71, -40, 35)
					model         = "sprites/bloodtank_blood_decal1.vmt"
					angles        = QAngle(0, 0, 0)
				}
			}
			S6 =
			{
				env_sprite_oriented =
				{
					origin        = blood_tank.GetOrigin() + Vector(-71, 40, 35)
					model         = "sprites/bloodtank_blood_decal3.vmt"
					angles        = QAngle(0, 0, 45)
				}
			}
			S7 =
			{
				env_sprite_oriented =
				{
					origin        = blood_tank.GetOrigin() + Vector(-35, -25, 110)
					model         = "sprites/bloodtank_blood_decal5.vmt"
					angles        = QAngle(0, 0, 0)
				}
			}
			S8 =
			{
				env_sprite_oriented =
				{
					origin        = blood_tank.GetOrigin() + Vector(0, 73, 110)
					model         = "sprites/bloodtank_blood_decal6.vmt"
					angles        = QAngle(0, 90, 0)
				}
			}
			S9 =
			{
				env_sprite_oriented =
				{
					origin        = blood_tank.GetOrigin() + Vector(0, -30, 142.5)
					model         = "sprites/bloodtank_blood_decal6.vmt"
					angles        = QAngle(90, 0, 0)
				}
			}
		})

		local number_array = [1, 2, 3, 4, 5, 6, 7, 8, 9]

		for (local ent; ent = Entities.FindByClassname(ent, "env_sprite_oriented"); )
		{
			local number_array_choice = RandomInt(0, number_array.len() - 1)

			ent.KeyValueFromString("targetname", "tank_blooddecal_" + number_array[number_array_choice])
			ent.KeyValueFromFloat("scale", 0.5)
			ent.KeyValueFromInt("rendermode", 1)

			number_array.remove(number_array_choice)

			EntFireByHandle(ent, "SetParent", "blood_tank", -1.0, null, null)
		}
	}

	boombox_box = null
	boombox_handle = null
	boombox_bbox = null
	boombox_glow = null

	Objective_Start = function()
	{
		if (draw_debugchat) ClientPrint(null,3,"stage check activated")

		in_cutscene = false

		for (local ent; ent = Entities.FindByClassname(ent, "tf_glow"); ) EntFireByHandle(ent, "Enable", null, -1.0, null, null)

		// S1O = debug 1, obj true, skip false
		// S2 = debug 2, obj false, skip true
		// S2O = debug 2, obj true, skip false
		// S3 = debug 3, obj false, skip true
		// S3O = debug 3, obj true, skip false
		// End = debug 3, obj false, skip true

		if (debug && current_stage < debug_stage)
		{
			Objective_Success()
			return
		}

		ControlTankProps(0.0)

		objectives_reached = 0

		if (current_stage != 3) ClientPrint(null,3, tip_header + "Complete the objective in order to progress to the next stage.")
		else					ClientPrint(null,3, tip_header + "Complete the objective in order to finish the wave.")

		EmitGlobalSound("ui/duel_challenge.wav", (95 + current_stage * 5))

		switch (current_stage)
		{
			case 1: objective_type = stage1_objective; break
			case 2: objective_type = stage2_objective; break
			case 3: objective_type = stage3_objective; break
		}

		EntFireByHandle(pop_interface_ent, "$FinishWavespawn", "W" + WAVE + "-S" + current_stage + "*", -1.0, null, null)
		EntFireByHandle(pop_interface_ent, "$ResumeWavespawn", "W" + WAVE + "-O" + current_stage + "*", -1.0, null, null)

		if (WAVE == 3) tank_objective_explosion_time = Time() + 8.0

		switch (objective_type)
		{
			case "destroy": objective_amount = 10; break
			case "deliver":
			{
				objective_amount = 5

				local think_deliver_objective = SpawnEntityFromTable("logic_relay", {targetname = "think_deliver_objective"})
				AddThinkToEnt(think_deliver_objective, "ObjectiveDeliver_Think")

				break
			}

			case "capture":
			{
				objective_amount = 1

				SetUpControlPoints()

				local think_capture_objective = SpawnEntityFromTable("logic_relay", {targetname = "think_capture_objective"})
				AddThinkToEnt(think_capture_objective, "ObjectiveCapture_Think")

				break
			}

			case "hunt":
			{
				objective_amount = 2

				break
			}

			case "supply":
			{
				objective_amount = 3

				EntFireByHandle(gamerules_entity, "CallScriptFunction", "DispatchRoamBot", -1.0, null, null)
				EntFireByHandle(gamerules_entity, "CallScriptFunction", "DispatchRoamBot", 3.0, null, null)
				EntFireByHandle(gamerules_entity, "CallScriptFunction", "DispatchRoamBot", 6.0, null, null)

				break
			}

			case "escort":
			{
				objective_amount = 1

				SetUpEscortRobot()

				break
			}

			case "push":
			{
				objective_amount = 1

				SetUpBombCart()

				local think_push_objective = SpawnEntityFromTable("logic_relay", {})
				AddThinkToEnt(think_push_objective, "ObjectivePush_Think")

				break
			}

			case "free":
			{
				SendGlobalGameEvent("show_annotation",
				{
					id = 7001
					text = "Shoot"
					worldPosX = iceblock_prop.GetOrigin().x
					worldPosY = iceblock_prop.GetOrigin().y
					worldPosZ = iceblock_prop.GetOrigin().z
					play_sound = "misc/null.wav"
					show_distance = true
					show_effect = true
					lifetime = 3600
				})

				objective_amount = 1

				break
			}

			case "end":
			{
				objective_amount = 1

				boombox_box = SpawnEntityFromTable("prop_dynamic",
				{
					targetname	  = "boombox_box"
					origin        = Vector(4100, 1050, -128)
					model         = "models/props_hydro/barrel_crate_half.mdl"
					modelscale	  = 0.4
				})

				boombox_handle = SpawnEntityFromTable("prop_dynamic",
				{
					origin                  = Vector(4100, 1050, -115)
					model                   = "models/workshop/player/items/scout/taunt_the_bunnyhopper/taunt_the_bunnyhopper.mdl"
					modelscale				= 0.65
					angles        			= QAngle(0, 90, 0)
				})

				boombox_bbox = SpawnEntityFromTable("func_button",
				{
					targetname = "boombox_bbox"
					origin = Vector(4100, 1050, -128)
				})

				boombox_bbox.KeyValueFromInt("solid", 2)
				boombox_bbox.KeyValueFromString("mins", "-5 -5 -40")
				boombox_bbox.KeyValueFromString("maxs", "5 5 40")

				boombox_glow = SpawnEntityFromTable("tf_glow",
				{
					target           	  = "boombox_box"
					GlowColor             = "255 255 0 255"
				})

				AddThinkToEnt(boombox_glow, "ObjectiveBlink_Think")

				// EntFireByHandle(boombox_handle, "SetParent", "!activator", -1.0, boombox_box, null)
				EntFireByHandle(boombox_glow, "SetParent", "!activator", -1.0, boombox_box, null)

				foreach (bluplayer in bluplayer_array) if (Entities.FindByNameWithin(null, "boombox_bbox", bluplayer.GetOrigin(), 64.0) != null) bluplayer.SetOrigin(Vector(4100 + RandomInt(-250, 250), 800 + RandomInt(-250, 250), 0))

				break
			}
		}

		local think_objective_status = SpawnEntityFromTable("logic_relay", {})
		AddThinkToEnt(think_objective_status, "ObjectiveStatus_Think")

		MarkRemainingEnemies()

		switch (WAVE)
		{
			case 1:
			{
				switch (current_stage)
				{
					case 1: active_spawns = [6, 8]; break
					case 2: active_spawns = [3, 4, 5, 12]; break
					case 3: active_spawns = [1, 2, 6, 7, 8, 9, 10, 11, 12, 13, 16]; break
				}

				break
			}
			case 2:
			{
				switch (current_stage)
				{
					case 1: active_spawns = [6, 12, 13]; break
					case 2: active_spawns = [11]; break
					case 3: active_spawns = [16, 17, 18]; break
				}

				break
			}
			case 3:
			{
				switch (current_stage)
				{
					case 1: active_spawns = [11, 13]; break
					case 2: active_spawns = [4, 11]; break
					case 3: active_spawns = [17, 18]; break
				}

				break
			}
		}

		UpdateSpawnIndicators()
	}

	// SpeedUpTank = function(stage)
	// {
		// if (objective_type != null || current_stage != stage) return

		// ClientPrint(null,3,"speeding up the tank! old speed = " + NetProps.GetPropFloat(blood_tank, "m_speed"))

		// blood_tank.KeyValueFromFloat("speed", NetProps.GetPropFloat(blood_tank, "m_speed") + 5)

		// ClientPrint(null,3,"speeding up the tank! new speed = " + NetProps.GetPropFloat(blood_tank, "m_speed"))

		// EmitGlobalSound("DisciplineDevice.PowerUp")
	// }

	ObjectiveProgress = function()
	{
		objectives_reached = objectives_reached + 1
		switch (current_stage)
		{
			case 1: EmitGlobalSound("ui/quest_status_tick_novice.wav"); break
			case 2: EmitGlobalSound("ui/quest_status_tick_advanced.wav"); break
			case 3: EmitGlobalSound("ui/quest_status_tick_expert.wav"); break
		}
	}

	SetUpControlPoints = function()
	{
		local control_point_1 = SpawnEntityFromTable("team_control_point",
		{
			origin                    = Vector(0, 0, -224)
			targetname                = "control_point_1"
			team_timedpoints_3        = 0
			team_timedpoints_2        = 0
			team_previouspoint_3_0    = "control_point_1"
			team_previouspoint_3_1    = "control_point_1"
			team_previouspoint_3_2    = "control_point_1"
			team_previouspoint_2_0    = "control_point_1"
			team_previouspoint_2_1    = "control_point_1"
			team_previouspoint_2_2    = "control_point_1"
			team_overlay_3            = "sprites/obj_icons/icon_obj_a"
			team_overlay_2            = "sprites/obj_icons/icon_obj_a"
			team_overlay_0            = "sprites/obj_icons/icon_obj_a"
			team_model_3              = "models/effects/cappoint_hologram.mdl"
			team_model_2              = "models/effects/cappoint_hologram.mdl"
			team_model_0              = "models/effects/cappoint_hologram.mdl"
			team_icon_3               = "sprites/obj_icons/icon_obj_blu_mannhattan"
			team_icon_2               = "sprites/obj_icons/icon_obj_red"
			team_icon_0               = "sprites/obj_icons/icon_obj_neutral"
			team_bodygroup_3          = 0
			team_bodygroup_2          = 1
			team_bodygroup_0          = 3
			spawnflags                = 4
			point_warn_sound          = "ControlPoint.CaptureWarn"
			point_warn_on_cap         = 2
			point_printname           = "Control Point A"
			point_index               = 0
			point_group               = 0
			point_default_owner       = 2
			point_start_locked        = 0
			OnCapTeam1                = "gamerules,RunScriptCode,obj_control_a_captured = false,-1,-1"
			OnCapTeam2                = "gamerules,RunScriptCode,obj_control_a_captured = true,-1,-1"
		})

		local control_point_1_trigger = SpawnEntityFromTable("trigger_capture_area",
		{
			targetname         = "control_point_1_trigger"
			origin             = Vector(0, 0, -224)
			mins               = Vector(-250, -250, -100)
			maxs               = Vector(250, 250, 250)
			solid              = 2
			team_startcap_3    = 1
			team_startcap_2    = 1
			team_numcap_3      = 1
			team_numcap_2      = 1
			team_cancap_3      = 1
			team_cancap_2      = 1
			area_time_to_cap   = obj_control_blucapture_rate
			area_cap_point     = "control_point_1"
		})

		local control_point_1_prop = SpawnEntityFromTable("prop_dynamic",
		{
			origin        = Vector(0, 0, -224)
			model         = "models/props_gameplay/cap_point_base.mdl"
		})

		EntFire("control_point_1_trigger", "SetControlPoint", "control_point_1")
		control_point_1_trigger.KeyValueFromFloat("area_time_to_cap", obj_control_blucapture_rate)
		NetProps.SetPropFloat(control_point_1_trigger, "m_flCapTime", obj_control_blucapture_rate)

		control_point_1_trigger.KeyValueFromInt("solid", 2)
		control_point_1_trigger.KeyValueFromString("mins", "-250 -250 -100")
		control_point_1_trigger.KeyValueFromString("maxs", "250 250 250")

		EntFire("control_point_1", "SetLocked", "0")

		local control_point_2 = SpawnEntityFromTable("team_control_point",
		{
			origin                    = Vector(2300, 100, -158)
			targetname                = "control_point_2"
			team_timedpoints_3        = 0
			team_timedpoints_2        = 0
			team_previouspoint_3_0    = "control_point_2"
			team_previouspoint_3_1    = "control_point_2"
			team_previouspoint_3_2    = "control_point_2"
			team_previouspoint_2_0    = "control_point_2"
			team_previouspoint_2_1    = "control_point_2"
			team_previouspoint_2_2    = "control_point_2"
			team_overlay_3            = "sprites/obj_icons/icon_obj_b"
			team_overlay_2            = "sprites/obj_icons/icon_obj_b"
			team_overlay_0            = "sprites/obj_icons/icon_obj_b"
			team_model_3              = "models/effects/cappoint_hologram.mdl"
			team_model_2              = "models/effects/cappoint_hologram.mdl"
			team_model_0              = "models/effects/cappoint_hologram.mdl"
			team_icon_3               = "sprites/obj_icons/icon_obj_blu_mannhattan"
			team_icon_2               = "sprites/obj_icons/icon_obj_red"
			team_icon_0               = "sprites/obj_icons/icon_obj_neutral"
			team_bodygroup_3          = 0
			team_bodygroup_2          = 1
			team_bodygroup_0          = 3
			spawnflags                = 4
			point_warn_sound          = "ControlPoint.CaptureWarn"
			point_warn_on_cap         = 2
			point_printname           = "Control Point B"
			point_index               = 1
			point_group               = 0
			point_default_owner       = 2
			point_start_locked        = 0
			OnCapTeam1                = "gamerules,RunScriptCode,obj_control_b_captured = false,-1,-1"
			OnCapTeam2                = "gamerules,RunScriptCode,obj_control_b_captured = true,-1,-1"
		})

		local control_point_2_trigger = SpawnEntityFromTable("trigger_capture_area",
		{
			targetname         = "control_point_2_trigger"
			origin             = Vector(2300, 100, -158)
			mins               = Vector(-250, -250, -100)
			maxs               = Vector(250, 250, 250)
			solid              = 2
			team_startcap_3    = 1
			team_startcap_2    = 1
			team_numcap_3      = 1
			team_numcap_2      = 1
			team_cancap_3      = 1
			team_cancap_2      = 1
			area_time_to_cap   = obj_control_blucapture_rate
			area_cap_point     = "control_point_2"
		})

		local control_point_2_base = SpawnEntityFromTable("prop_dynamic",
		{
			origin        = Vector(2300, 100, -158)
			model         = "models/props_gameplay/cap_point_base.mdl"
		})

		EntFire("control_point_2_trigger", "SetControlPoint", "control_point_2")
		control_point_2_trigger.KeyValueFromFloat("area_time_to_cap", obj_control_blucapture_rate)
		NetProps.SetPropFloat(control_point_2_trigger, "m_flCapTime", obj_control_blucapture_rate)

		control_point_2_trigger.KeyValueFromInt("solid", 2)
		control_point_2_trigger.KeyValueFromString("mins", "-250 -250 -100")
		control_point_2_trigger.KeyValueFromString("maxs", "250 250 250")

		EntFire("control_point_2", "SetLocked", "0")

		local control_point_3 = SpawnEntityFromTable("team_control_point",
		{
			origin                    = Vector(2000, -1000, -224)
			targetname                = "control_point_3"
			team_timedpoints_3        = 0
			team_timedpoints_2        = 0
			team_previouspoint_3_0    = "control_point_3"
			team_previouspoint_3_1    = "control_point_3"
			team_previouspoint_3_2    = "control_point_3"
			team_previouspoint_2_0    = "control_point_3"
			team_previouspoint_2_1    = "control_point_3"
			team_previouspoint_2_2    = "control_point_3"
			team_overlay_3            = "sprites/obj_icons/icon_obj_c"
			team_overlay_2            = "sprites/obj_icons/icon_obj_c"
			team_overlay_0            = "sprites/obj_icons/icon_obj_c"
			team_model_3              = "models/effects/cappoint_hologram.mdl"
			team_model_2              = "models/effects/cappoint_hologram.mdl"
			team_model_0              = "models/effects/cappoint_hologram.mdl"
			team_icon_3               = "sprites/obj_icons/icon_obj_blu_mannhattan"
			team_icon_2               = "sprites/obj_icons/icon_obj_red"
			team_icon_0               = "sprites/obj_icons/icon_obj_neutral"
			team_bodygroup_3          = 0
			team_bodygroup_2          = 1
			team_bodygroup_0          = 3
			spawnflags                = 4
			point_warn_sound          = "ControlPoint.CaptureWarn"
			point_warn_on_cap         = 2
			point_printname           = "Control Point C"
			point_index               = 2
			point_group               = 0
			point_default_owner       = 2
			point_start_locked        = 0
			OnCapTeam1                = "gamerules,RunScriptCode,obj_control_c_captured = false,-1,-1"
			OnCapTeam2                = "gamerules,RunScriptCode,obj_control_c_captured = true,-1,-1"
		})

		local control_point_3_trigger = SpawnEntityFromTable("trigger_capture_area",
		{
			targetname         = "control_point_3_trigger"
			origin             = Vector(2000, -1000, -224)
			mins               = Vector(-250, -250, -100)
			maxs               = Vector(250, 250, 250)
			solid              = 2
			team_startcap_3    = 1
			team_startcap_2    = 1
			team_numcap_3      = 1
			team_numcap_2      = 1
			team_cancap_3      = 1
			team_cancap_2      = 1
			area_time_to_cap   = obj_control_blucapture_rate
			area_cap_point     = "control_point_3"
		})

		local control_point_3_base = SpawnEntityFromTable("prop_dynamic",
		{
			origin        = Vector(2000, -1000, -224)
			model         = "models/props_gameplay/cap_point_base.mdl"
		})

		EntFire("control_point_3_trigger", "SetControlPoint", "control_point_3")
		control_point_3_trigger.KeyValueFromFloat("area_time_to_cap", obj_control_blucapture_rate)
		NetProps.SetPropFloat(control_point_3_trigger, "m_flCapTime", obj_control_blucapture_rate)

		control_point_3_trigger.KeyValueFromInt("solid", 2)
		control_point_3_trigger.KeyValueFromString("mins", "-250 -250 -100")
		control_point_3_trigger.KeyValueFromString("maxs", "250 250 250")

		EntFire("control_point_3", "SetLocked", "0")

		local control_point_controller = SpawnEntityFromTable("team_control_point_master",
		{
			targetname                   = "control_point_controller"
			team_base_icon_3             = "sprites/obj_icons/icon_base_blu"
			team_base_icon_2             = "sprites/obj_icons/icon_base_red"
			switch_teams                 = 0
			score_style                  = 1
			custom_position_y            = -1
			custom_position_x            = 0.2
			cpm_restrict_team_cap_win    = 1
			caplayout                    = "0, 1 2"
		})

		SendGlobalGameEvent("show_annotation",
		{
			id = 5001
			text = "Capture (A)"
			worldPosX = control_point_1.GetOrigin().x
			worldPosY = control_point_1.GetOrigin().y
			worldPosZ = control_point_1.GetOrigin().z
			play_sound = "misc/null.wav"
			show_distance = true
			show_effect = true
			lifetime = 3600
		})

		SendGlobalGameEvent("show_annotation",
		{
			id = 5002
			text = "Capture (B)"
			worldPosX = control_point_2.GetOrigin().x
			worldPosY = control_point_2.GetOrigin().y
			worldPosZ = control_point_2.GetOrigin().z
			play_sound = "misc/null.wav"
			show_distance = true
			show_effect = true
			lifetime = 3600
		})

		SendGlobalGameEvent("show_annotation",
		{
			id = 5003
			text = "Capture (C)"
			worldPosX = control_point_3.GetOrigin().x
			worldPosY = control_point_3.GetOrigin().y
			worldPosZ = control_point_3.GetOrigin().z
			play_sound = "misc/null.wav"
			show_distance = true
			show_effect = true
			lifetime = 3600
		})
	}

	DispatchRoamBot = function()
	{
		roambots_dispatched = roambots_dispatched + 1

		local pick = RandomInt(0, bloodbot_path_p2.len() - 1)

		local roambot_path_train = SpawnEntityFromTable("func_tracktrain",
		{
			targetname              = "roambot_path_train_" + roambots_dispatched
			target                  = bloodbot_path_p2_name_picker[pick]
			startspeed              = bloodbot_path_speed
			speed                   = bloodbot_path_speed
			origin                  = bloodbot_path_p2_origin_picker[pick]
			orientationtype         = 3
		})

		local roambot_robot = SpawnEntityFromTable("obj_teleporter",
		{
			targetname              = "roambot_robot_" + roambots_dispatched
			origin 		            = roambot_path_train.GetOrigin()
			teamnum                 = 3
			SolidToPlayer           = 0
			spawnflags				= 2
		})

		roambot_robot.SetCollisionGroup(0)
		EntFireByHandle(roambot_robot, "SetHealth", "9999", -1.0, null, null)

		EntityOutputs.AddOutput(roambot_robot, "OnDestroyed", "roambot_path_train_" + roambots_dispatched, "Kill", null, -1.0, -1)

		roambot_robot.SetModel("models/bots/bot_worker/bot_worker3.mdl")

		EntFireByHandle(roambot_robot, "SetParent", "!activator", -1.0, roambot_path_train, null)

		AddThinkToEnt(roambot_robot, "ObjectiveSupply_ExtractBlood_Think")
	}

	SetUpEscortRobot = function()
	{
		local escort_robot_point = SpawnEntityFromTable("logic_relay",
		{
			targetname = "escort_robot_point"
			origin = blood_tank.GetOrigin()
		})

		AddThinkToEnt(escort_robot_point, "EscortPoint_Think")
	}

	HuntBot_Think = function()
	{
		local scope = self.GetScriptScope()

		if (!("tick" in scope))
		{
			scope.tick <- 0

			scope.dests <- [ Vector(2900, -300, -100), Vector(2400, -1200, -100), Vector(4400, -1200, -100), Vector(2700, -1900, -100), Vector(3100, 100, -90) ]

			self.KeyValueFromString("targetname", "glow_target")

			scope.self_glow <- SpawnEntityFromTable("tf_glow",
			{
				target           	  = "glow_target"
				origin				  = self.EyePosition()
				GlowColor             = "184 56 59 255"
			})

			EntFireByHandle(scope.self_glow, "SetParent", "!activator", -1.0, self, null)

			SendGlobalGameEvent("show_annotation",
			{
				id = scope.self_glow.entindex()
				text = "Destroy"
				follow_entindex = scope.self_glow.entindex()
				play_sound = "misc/null.wav"
				show_distance = true
				show_effect = true
				lifetime = -1
			})

			AddThinkToEnt(scope.self_glow, "GlowSwitch_Think")

			self.KeyValueFromString("targetname", "")
		}

		if (scope.tick % 1000 == 0)
		{
			local dist = 0
			local winner

			foreach (entry in scope.dests)
			{
				local b_dist = dist

				if ((entry - self.EyePosition()).Length() < b_dist) continue
				else
				{
					dist = (entry - self.EyePosition()).Length()
					winner = entry
				}
			}

			local winnerdest = winner.x + ", " + winner.y + ", " + winner.z

			EntFireByHandle(self, "$BotCommand", "interrupt_action -pos " + winnerdest + " -delay 0 -duration 3600 -cooldown 3600", 0.05, null, null)
		}

		scope.tick = scope.tick + 1

		return -1
	}

	TutorialBlink_Think = function()
	{
		local scope

		try { scope = self.GetScriptScope() }
		catch (e) { return }

		if (!("blinkend" in scope)) scope.blinkend <- Time() + 5.0

		if (tick % 16 == 0)
		{
			if (NetProps.GetPropBool(self, "m_bDisabled")) EntFireByHandle(self, "Enable", null, -1.0, null, null)
			else										   EntFireByHandle(self, "Disable", null, -1.0, null, null)
		}

		if (Time() > scope.blinkend) self.Kill()

		return -1
	}

	GlowSwitch_Think = function()
	{
		EntFireByHandle(self, "SetGlowColor", "184 56 59 255", 0.0, null, null)
		EntFireByHandle(self, "SetGlowColor", "0 255 0 255", 0.5, null, null)

		return 1
	}

	IceBlockBlink_Think = function()
	{
		EntFireByHandle(self, "SetGlowColor", "153 194 216 255", 0.0, null, null)
		EntFireByHandle(self, "SetGlowColor", "0 255 0 255", 0.5, null, null)

		return 1
	}

	AoEUber_Think = function()
	{
		if (NetProps.GetPropInt(self, "m_lifeState") != 0)
		{
			NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
			return
		}

		local scope = self.GetScriptScope()

		if (!("spawned" in scope))
		{
			scope.spawned <- true
			scope.unique_id <- UniqueString()

			scope.uber_beam_1 <- SpawnEntityFromTable("dispenser_touch_trigger",
			{
				targetname    	   = "dispenser_trigger_" + scope.unique_id
				origin             = self.GetOrigin()
				spawnflags         = 1
			})

			scope.uber_beam_2 <- SpawnEntityFromTable("mapobj_cart_dispenser",
			{
				targetname    	   = "dispenser_mapobj_" + scope.unique_id
				origin             = self.GetOrigin()
				TeamNum            = 2,
				spawnflags         = 12
				touch_trigger      = "dispenser_trigger_" + scope.unique_id
			})

			scope.uber_beam_1.KeyValueFromInt("solid", 2)
			scope.uber_beam_1.KeyValueFromString("mins", "-250 -250 -250")
			scope.uber_beam_1.KeyValueFromString("maxs", "250 250 250")

			EntFireByHandle(scope.uber_beam_1, "SetParent", "!activator", -1.0, self, null)
			EntFireByHandle(scope.uber_beam_2, "SetParent", "!activator", -1.0, self, null)

			self.AddCond(55)
		}

		for (local player_to_shield; player_to_shield = Entities.FindByClassnameWithin(player_to_shield, "player", self.GetOrigin(), 250); )
		{
			if (player_to_shield == null) continue
			if (player_to_shield.GetTeam() == 2 && !player_to_shield.HasBotTag("aoe_medic")) player_to_shield.AddCondEx(52, 0.5, self)
		}

		return 0.1
	}

	StageCompleteReward = function()
	{
		local payout

		switch (current_stage)
		{
			case 2: payout = stage1_cash_reward; break
			case 3: payout = stage2_cash_reward; break
		}

		EntFireByHandle(pop_interface_ent, "$FinishWavespawn", "W" + WAVE + "-Cash-S" + (current_stage - 1) + "*", -1.0, null, null)

		ClientPrint(null,4,"Stage " + (current_stage - 1) + " complete! Reward: $" + payout)

		EmitGlobalSound("Announcer.MVM_Bonus")

		EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitGlobalSound(`mvm/mvm_money_pickup.wav`)", -1.0, null, null)
		EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitGlobalSound(`mvm/mvm_money_pickup.wav`)", 0.2, null, null)
		EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitGlobalSound(`mvm/mvm_money_pickup.wav`)", 0.4, null, null)
		EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitGlobalSound(`mvm/mvm_money_pickup.wav`)", 0.6, null, null)
		EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitGlobalSound(`mvm/mvm_money_pickup.wav`)", 0.8, null, null)
		EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitGlobalSound(`mvm/mvm_money_pickup.wav`)", 1.0, null, null)
	}

	Objective_Success = function()
	{
		ClientPrint(null,4,"Objective complete!")

		SendGlobalGameEvent("hide_annotation", { id = blood_tank.entindex() })

		foreach (bluplayer in bluplayer_array)
		{
			if (bluplayer.IsFakeClient()) continue
			if (bluplayer.GetScriptScope().bloodstorage.firsttimeplayer) bluplayer.GetScriptScope().bloodstorage.firsttimeplayer = false
		}

		if (current_stage < 3)
		{
			EntFireByHandle(gamerules_entity, "CallScriptFunction", "StageCompleteReward", 5.0, null, null)
			max_bloodbot_count += 2
		}

		switch (objective_type)
		{
			case "escort": EntFireByHandle(pop_interface_ent, "$PauseWavespawn", "W1-O2-Escort", -1.0, null, null); break

			case "deliver":
			{
				for (local briefcase_to_kill; briefcase_to_kill = Entities.FindByName(briefcase_to_kill, "briefcase_pickup*"); )
				{
					SendGlobalGameEvent("hide_annotation", { id = (10 + briefcase_to_kill.GetName().slice(16)) })
					NetProps.SetPropString(briefcase_to_kill, "m_iszScriptThinkFunction", "")
					briefcase_to_kill.Kill()
				}

				for (local i = 1; i <= MaxClients().tointeger(); i++)
				{
					local player = PlayerInstanceFromIndex(i)
					if (player == null) continue;
					if (player.GetTeam() == 1) continue
					if (player.IsFakeClient()) continue;

					local scope = player.GetScriptScope().bloodstorage

					if (scope.has_briefcase) scope.has_briefcase = false

					scope = player.GetScriptScope()

					if ("selfglow" in scope)
					{
						if (scope.selfglow.IsValid()) scope.selfglow.Kill()
						delete scope.selfglow
					}
				}

				break
			}

			case "capture":
			{
				SpawnEntityFromTable("team_control_point_master", { custom_position_x = 5 }) // calling a second master that hides the point hud

				for (local ent; ent = Entities.FindByModel(ent, "models/props_gameplay/cap_point_base.mdl"); ) ent.Kill()
				for (local ent; ent = Entities.FindByClassname(ent, "team_control_point"); ) ent.Kill()
				for (local ent; ent = Entities.FindByClassname(ent, "trigger_capture_area"); ) ent.Kill()
				for (local ent; ent = Entities.FindByClassname(ent, "team_control_point_master"); ) ent.Kill()

				SendGlobalGameEvent("hide_annotation", { id = 5001 })
				SendGlobalGameEvent("hide_annotation", { id = 5002 })
				SendGlobalGameEvent("hide_annotation", { id = 5003 })

				for (local i = 1; i <= MaxClients().tointeger(); i++)
				{
					local player = PlayerInstanceFromIndex(i)
					if (player == null) continue
					if (!player.IsFakeClient()) continue
					if (player.HasBotTag("goaftercontrolpoints_any") || player.HasBotTag("goaftercontrolpoints_b") || player.HasBotTag("goaftercontrolpoints_c")) EntFireByHandle(player, "$BotCommand", "stop interrupt action", -1.0, null, null)
				}

				break
			}

			case "free":
			{
				for (local i = 1; i <= MaxClients().tointeger(); i++)
				{
					local player = PlayerInstanceFromIndex(i)
					if (player == null) continue
					if (!player.IsFakeClient()) continue
					if (player.HasBotTag("goaftericeblock")) EntFireByHandle(player, "$BotCommand", "stop interrupt action", -1.0, null, null)
				}

				break
			}
		}

		objective_type = null
		objective_amount = 0
		objectives_reached = 0

		briefcases_spawned = 1

		switch (current_stage)
		{
			case 1:
			{
				EmitGlobalSound("ui/quest_status_tick_novice_complete.wav")

				if (!debug) EntFireByHandle(gamerules_entity, "RunScriptCode", "ControlTankProps(tank_stage2_speed)", 5.0, null, null)
				else		EntFireByHandle(gamerules_entity, "RunScriptCode", "ControlTankProps(tank_stage2_speed)", 0.0, null, null)

				EntFireByHandle(blood_tank, "RunScriptCode", "self.SetModelScale(0.85, 20.0)", 0.0, null, null)

				if (WAVE == 3)
				{
					current_bombs_remaining = current_bombs_remaining + 8

					for (local i = 7; i <= 14; i++)
					{
						local ent = Entities.FindByName(null, "tnt_spot_" + i)
						AddThinkToEnt(ent, "ReceiveTNT_Think")
					}
				}

				break
			}
			case 2:
			{
				EmitGlobalSound("ui/quest_status_tick_advanced_complete.wav")

				if (!debug) EntFireByHandle(gamerules_entity, "RunScriptCode", "ControlTankProps(tank_stage3_speed)", 5.0, null, null)
				else		EntFireByHandle(gamerules_entity, "RunScriptCode", "ControlTankProps(tank_stage3_speed)", 0.0, null, null)

				EntFireByHandle(blood_tank, "RunScriptCode", "self.SetModelScale(0.75, 20.0)", 0.0, null, null)

				if (WAVE == 3)
				{
					current_bombs_remaining = current_bombs_remaining + 6

					for (local i = 15; i <= 20; i++)
					{
						local ent = Entities.FindByName(null, "tnt_spot_" + i)
						AddThinkToEnt(ent, "ReceiveTNT_Think")
					}
				}

				break
			}
			case 3:
			{
				EmitGlobalSound("ui/quest_status_tick_expert_complete.wav")

				if (!debug) EntFireByHandle(gamerules_entity, "RunScriptCode", "ControlTankProps(75.0)", 5.0, null, null)
				else		EntFireByHandle(gamerules_entity, "RunScriptCode", "ControlTankProps(75.0)", 0.0, null, null)

				for (local i = 1; i <= MaxClients().tointeger(); i++)
				{
					local player = PlayerInstanceFromIndex(i)
					if (player == null) continue
					if (!player.IsFakeClient()) continue
					if (NetProps.GetPropInt(player, "m_lifeState") != 0) continue

					player.AddCondEx(71, 15.0, player)
				}

				break
			}
		}

		EntFireByHandle(pop_interface_ent, "$FinishWavespawn", "W" + WAVE + "-O" + current_stage + "*", -1.0, null, null)
		EntFireByHandle(pop_interface_ent, "$ResumeWavespawn", "W" + WAVE + "-S" + (current_stage + 1) + "*", -1.0, null, null)

		if (WAVE == 3 && current_stage < 3)
		{
			if (tnt_satisfied)
			{
				tnt_satisfied = false

				if (tank_tnt_level > 0) extraction_mode = "tnt"
				else					extraction_mode = "blood"
			}
		}

		MarkRemainingEnemies()

		current_stage = current_stage + 1

		switch (WAVE)
		{
			case 1:
			{
				switch (current_stage)
				{
					case 2: active_spawns = [9, 10, 11, 12]; break
					case 3: active_spawns = [5, 9, 11, 13]; break
				}

				break
			}
			case 2:
			{
				switch (current_stage)
				{
					case 2: active_spawns = [10, 11, 12, 13]; break
					case 3: active_spawns = [16, 17, 18]; break
				}

				break
			}
			case 3:
			{
				switch (current_stage)
				{
					case 2: active_spawns = [6, 11, 12, 13]; break
					case 3: active_spawns = [4, 13, 15, 17, 18]; break
				}

				break
			}
		}

		UpdateSpawnIndicators()
	}

	MarkRemainingEnemies = function()
	{
		for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
		{
			local player = PlayerInstanceFromIndex(i)
			if (player == null) continue;
			if (!player.IsFakeClient()) continue
			if (player.GetTeam() != 2) continue
			if (player.HasBotTag("alienhunter")) continue

			player.AddCond(30)
			player.AddCond(32)
			player.AddCustomAttribute("damage bonus HIDDEN", 0.5, -1)

			if (player.IsMiniBoss()) player.AddCustomAttribute("is suicide counter", 250, -1)
		}
	}

	SetUpSpawnIndicators = function()
	{
		for (local i = 1; i <= 18; i++)
		{
			local spawn = Entities.FindByName(null, "spawnbot_red_" + i)

			local tracetable =
			{
				start = spawn.GetOrigin() + Vector(0, 0, 100)
				end = spawn.GetOrigin() - Vector(0, 0, 500)
				ignore = spawn
			}

			TraceLineEx(tracetable)

			local indicator = SpawnEntityFromTable("prop_dynamic",
			{
				origin 	   = tracetable.pos
				model  	   = "models/props_mvm/robot_spawnpoint.mdl"
				targetname = "red_indicator_" + i
			})

			indicator.DisableDraw()
		}
	}

	UpdateSpawnIndicators = function()
	{
		for (local i = 1; i <= 18; i++)
		{
			local indicator = Entities.FindByName(null, "red_indicator_" + i)

			if (active_spawns.find(i) == null) indicator.DisableDraw()
			else							   indicator.EnableDraw()
		}
	}

	ControlTankProps = function(speed)
	{
		cur_tankspeed = speed
		blood_tank.KeyValueFromFloat("speed", cur_tankspeed)
	}

	SetUpBombCart = function()
	{
		w2_s3_minigame_bombcart_prop.Kill()
		w2_s3_minigame_bombcart_prop_bbox.Kill()

		SpawnEntityFromTable("prop_physics_multiplayer",
		{
			targetname	  = "w2_hatch_explosive"
			origin        = Vector(2350, 490, 0)
			model         = "models/props_badlands/barrel03.mdl"
		})

		SpawnEntityFromTable("prop_physics_multiplayer",
		{
			targetname	  = "w2_hatch_explosive"
			origin        = Vector(2275, 490, 0)
			model         = "models/props_badlands/barrel03.mdl"
		})

		SpawnEntityFromTable("prop_physics_multiplayer",
		{
			targetname	  = "w2_hatch_explosive"
			origin        = Vector(2200, 540, 0)
			model         = "models/props_badlands/barrel03.mdl"
		})

		SpawnEntityFromTable("prop_physics_multiplayer",
		{
			targetname	  = "w2_hatch_explosive"
			origin        = Vector(2200, 590, 0)
			model         = "models/props_badlands/barrel03.mdl"
		})

		SpawnEntityFromTable("prop_physics_multiplayer",
		{
			targetname	  = "w2_hatch_explosive"
			origin        = Vector(2275, 640, 0)
			model         = "models/props_badlands/barrel03.mdl"
		})

		SpawnEntityFromTable("prop_physics_multiplayer",
		{
			targetname	  = "w2_hatch_explosive"
			origin        = Vector(2350, 640, 0)
			model         = "models/props_badlands/barrel03.mdl"
		})

		for (local ent; ent = Entities.FindByName(ent, "w2_hatch_explosive"); )
		{
			EntFireByHandle(ent, "DisableMotion", null, 1.0, null, null)
			ent.SetCollisionGroup(5)
		}

		Entities.FindByName(null, "hatch_explo_kill_players").Teleport(true, Vector(2275, 565, 0), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
		Entities.FindByName(null, "hatch_magnet_pit").Teleport(true, Vector(2275, 565, 0), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
		Entities.FindByName(null, "pit_explosion_wav").Teleport(true, Vector(2275, 565, 0), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
		Entities.FindByName(null, "end_pit_destroy_particle").Teleport(true, Vector(2275, 565, 0), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
		Entities.FindByName(null, "trigger_hurt_hatch_fire").Teleport(true, Vector(2275, 565, 0), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))

		local bombcart_speed = 24

		if (debug) bombcart_speed = 200.0

		SpawnEntityGroupFromTable(
		{
			ent1 =
			{
				path_track =
				{
					origin 		 = Vector(2295, 550, -64)
					targetname   = "bombcart_endpath"
					speed        = bombcart_speed
				}
			},
			ent2 =
			{
				path_track =
				{
					origin 		 = Vector(3700, 550, -64)
					targetname   = "bombcart_startpath"
					target       = "bombcart_endpath"
					speed        = bombcart_speed
				}
			},
			ent3 =
			{
				func_tracktrain =
				{
					targetname              = "bombcart_train"
					target                  = "bombcart_startpath"
					startspeed              = bombcart_speed
					speed                   = bombcart_speed
					origin                  = Vector(3700, 550, -64)
					angles                  = QAngle(90, 0, 0)
					orientationtype         = 0
					spawnflags              = 128
					MoveSound				= "bombcart_moving.wav"
					volume					= 10
				}
			},
			ent4 =
			{
				prop_dynamic =
				{
					targetname              = "bombcart"
					parentname              = "bombcart_train"
					origin                  = Vector(3700, 550, -64)
					model                   = "models/props_medical/med_table002.mdl"
					solid                   = 6
					angles                  = QAngle(0, 0, 0)
				}
			},
			ent5 =
			{
				prop_dynamic =
				{
					origin                  = Vector(3700, 550, -22)
					targetname              = "bombcart_bomb"
					model                   = "models/props_td/atom_bomb.mdl"
					solid                   = 6
					angles                  = QAngle(0, -90, 0)
					modelscale              = 1.5
					parentname              = "bombcart"
				}
			},
			ent6 =
			{
				tf_glow =
				{
					target           	  = "bombcart_bomb"
					GlowColor             = "153 194 216 255"
				}
			},
			ent7 =
			{
				env_beam =
				{
					life                    = 0
					boltwidth               = 20
					LightningStart			= "blood_tank"
					LightningEnd			= "bombcart_bomb"
					NoiseAmplitude          = 0
					rendercolor				= "153 194 216"
					texture					= "sprites/laserbeam.spr"
					spawnflags				= 1
				}
			}
		})

		local cart_bbox = Entities.FindByName(null, "bombcart_train")

		cart_bbox.KeyValueFromInt("solid", 2)
		cart_bbox.KeyValueFromString("mins", "-35 -15 -55")
		cart_bbox.KeyValueFromString("maxs", "35 15 55")
	}

	SetUpIceBlock = function()
	{
		in_cutscene = true

		for (local ent; ent = Entities.FindByClassname(ent, "tf_glow"); ) EntFireByHandle(ent, "Disable", null, -1.0, null, null)

		ControlTankProps(0.0)

		local iceblockcam = SpawnEntityFromTable("point_viewcontrol",
		{
			origin	 = Vector(-581, 612, -37)
			angles	 = QAngle(8, -42, 0)
		})

		iceblockcam.ValidateScriptScope()
		iceblockcam.GetScriptScope().obj_free_camera_tick <- 0

		EntFireByHandle(iceblockcam, "$EnableAll", null, 1.0, null, null)

		EntFireByHandle(iceblockcam, "RunScriptCode", "AddThinkToEnt(self, `CameraMove_Think`)", 3.0, null, null)

		iceblock_prop = SpawnEntityFromTable("base_boss",
		{
			targetname	  = "iceblock"
			origin		  = Vector(0, 0, 3000)
			model         = "models/props_moonbase/moon_cube_crystal07.mdl"
			teamnum		  = 2
			solid		  = 6
			rendermode	  = 1
			rendercolor   = "255 255 255"
			renderamt	  = 0
			health		  = 50000
		})

		local iceblock_prop_dummy = SpawnEntityFromTable("prop_physics_override",
		{
			targetname	  			= "iceblock_dummy"
			origin                  = Vector(0, 0, 2000)
			model                   = "models/props_moonbase/moon_cube_crystal07.mdl"
			rendermode				= 1
			rendercolor				= "255 255 255"
			renderamt				= 80
			health					= 100
			spawnflags				= 2
		})

		local iceblock_glow = SpawnEntityFromTable("tf_glow",
		{
			target           	  = "iceblock"
			GlowColor             = "184 56 59 255"
			StartDisabled		  = 1
		})

		EntFireByHandle(iceblock_glow, "SetParent", "!activator", 5.4, iceblock_prop, null)

		AddThinkToEnt(iceblock_glow, "IceBlockBlink_Think")

		// iceblock_prop.SetSize(Vector(-60, -100, -100), Vector(60, 100, 100))

		AddThinkToEnt(iceblock_prop, "StayInPosition_Think")

		local pyro_prop = SpawnEntityFromTable("prop_dynamic",
		{
			origin                  = Vector(0, 0, 1900)
			targetname				= "pyro_dummy"
			model                   = "models/bots/pyro_boss/bot_pyro_boss.mdl"
			skin 					= 1
			modelscale				= 1.9
		})

		SpawnEntityFromTable("prop_dynamic_ornament",
		{
			model                   = "models/workshop_partner/player/items/all_class/ai_spacehelmet/ai_spacehelmet_pyro.mdl"
			skin 					= 1
			modelscale				= 1.9
			disablebonefollowers	= 1
			disableshadows			= 1
			initialowner			= "pyro_dummy"
		})

		EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitGlobalSound(`ambient/cp_harbor/furnace_1_shot_05.wav`)", 5.4, null, null)

		for (local i = 1; i <= MaxClients().tointeger(); i++)
		{
			local player = PlayerInstanceFromIndex(i)
			if (player == null) continue
			if (player.GetTeam() == 1) continue
			if (player.IsFakeClient()) player.AddCondEx(71, 8.0, player)
		}

		foreach (bluplayer in bluplayer_array)
		{
			local scope = bluplayer.GetScriptScope().bloodstorage

			if (NetProps.GetPropInt(bluplayer, "m_lifeState") != 0) scope.pos_before_iceblock_cutscene = Vector(100, 1700, 0) // prevent issues with dead spectator camera
			else												 	scope.pos_before_iceblock_cutscene = bluplayer.GetOrigin()

			EntFireByHandle(bluplayer, "RunScriptCode", "self.SetMoveType(0, 0)", -1.0, null, null)

			bluplayer.AddCustomAttribute("no_attack", 1, -1)
			bluplayer.AddCustomAttribute("voice pitch scale", 0, -1)

			EntFireByHandle(bluplayer, "RunScriptCode", "self.AddHudHideFlags(4)", -1.0, null, null)

			EntFireByHandle(bluplayer, "RunScriptCode", "self.Teleport(true, Vector(700, 1600, 0), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))", 1.0, null, null)

			EntFireByHandle(bluplayer, "RunScriptCode", "ScreenFade(self, 0, 0, 0, 255, 1.0, -1.0, 2)", -1.0, null, null)
			EntFireByHandle(bluplayer, "RunScriptCode", "ScreenFade(self, 0, 0, 0, 255, 1.0, -1.0, 1)", 1.0, null, null)

			EntFireByHandle(bluplayer, "RunScriptCode", "ScreenFade(self, 0, 0, 0, 255, 1.0, -1.0, 2)", 7.0, null, null)
			EntFireByHandle(bluplayer, "RunScriptCode", "ScreenFade(self, 0, 0, 0, 255, 1.0, -1.0, 1)", 8.0, null, null)

			EntFireByHandle(bluplayer, "RunScriptCode", "self.RemoveHudHideFlags(4)", 8.0, null, null)

			EntFireByHandle(bluplayer, "RunScriptCode", "self.SetMoveType(2, 0)", 8.0, null, null)

			EntFireByHandle(bluplayer, "RunScriptCode", "self.RemoveCustomAttribute(`no_attack`)", 8.0, null, null)
			EntFireByHandle(bluplayer, "RunScriptCode", "self.RemoveCustomAttribute(`voice pitch scale`)", 8.0, null, null)

			EntFireByHandle(bluplayer, "RunScriptCode", "self.Teleport(true, self.GetScriptScope().bloodstorage.pos_before_iceblock_cutscene, false, QAngle(0, 0, 0), false, Vector(0, 0, 0))", 8.0, null, null)
		}

		EntFireByHandle(iceblock_prop_dummy, "DisableMotion", null, -1.0, null, null)

		EntFireByHandle(pyro_prop, "SetParent", "!activator", -1.0, iceblock_prop_dummy, null)

		EntFire("wormhole_start_relay", "Trigger", null, 2.0)
		EntFire("wormhole_end_relay", "Trigger", null, 20.0)

		EntFireByHandle(iceblock_prop_dummy, "EnableMotion", null, 3.1, null, null)
		EntFireByHandle(iceblock_prop_dummy, "DisableMotion", null, 5.4, null, null)

		EntFireByHandle(iceblock_prop_dummy, "RunScriptCode", "DispatchParticleEffect(`heavy_ring_of_fire`, self.GetOrigin() - Vector(0, 0, 125), Vector(0, 90, 0))", 5.4, null, null)

		EntFireByHandle(pyro_prop, "SetParent", "!activator", 5.4, iceblock_prop, null)
		EntFireByHandle(iceblock_prop_dummy, "Kill", null, 5.4, null, null)
		EntFireByHandle(iceblock_prop, "RunScriptCode", "self.KeyValueFromInt(`renderamt`, 80)", 5.4, null, null)

		EntFireByHandle(gamerules_entity, "CallScriptFunction", "Objective_Start", 8.0, null, null)
		EntFireByHandle(pop_interface_ent, "$ResumeWavespawn", "iceblock_healthbar", 8.0, null, null)

		// EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitGlobalSound(`ui/rd_2base_alarm.wav`)", 13.0, null, null)
		// EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitGlobalSound(`ui/rd_2base_alarm.wav`)", 13.5, null, null)
		// EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitGlobalSound(`ui/rd_2base_alarm.wav`)", 14.0, null, null)
		// EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitGlobalSound(`ui/rd_2base_alarm.wav`)", 14.5, null, null)

		// EntFireByHandle(gamerules_entity, "CallScriptFunction", "IceBlock_WormholeDanger", 13.0, null, null)
	}

	IceBlock_WormholeDanger = function()
	{
		SendGlobalGameEvent("show_annotation",
		{
			id = 12001
			text = "Danger!"
			worldPosX = 0
			worldPosY = 0
			worldPosZ = 2208
			play_sound = "misc/null.wav"
			show_distance = true
			show_effect = true
			lifetime = 7.5
		})
	}

	DestroyIceBlock_P1 = function()
	{
		local pyro_dummy = Entities.FindByName(null, "pyro_dummy")

		local pyro_prop = SpawnEntityFromTable("prop_dynamic",
		{
			targetname     		 = "pyro_dummy_freed"
			origin         		 = pyro_dummy.GetOrigin()
			skin 		   		 = 1
			modelscale	   		 = 1.9
			model          		 = "models/player/pyro.mdl"
			defaultanim    		 = "taunt_bubbles"
			disablebonefollowers = 1
			renderamt			 = 0
			rendermode			 = 1
		})

		SpawnEntityFromTable("prop_dynamic_ornament",
		{
			model                   = "models/bots/pyro_boss/bot_pyro_boss.mdl"
			skin 					= 1
			modelscale				= 1.9
			disablebonefollowers	= 1
			initialowner			= "pyro_dummy_freed"
		})

		SpawnEntityFromTable("prop_dynamic_ornament",
		{
			model                   = "models/workshop_partner/player/items/all_class/ai_spacehelmet/ai_spacehelmet_pyro.mdl"
			skin 					= 1
			modelscale				= 1.9
			disablebonefollowers	= 1
			disableshadows			= 1
			initialowner			= "pyro_dummy_freed"
		})

		pyro_dummy.Kill()

		EntFireByHandle(gamerules_entity, "CallScriptFunction", "DestroyIceBlock_P2", 3.3, null, null)
	}

	DestroyIceBlock_P2 = function()
	{
		Entities.FindByName(null, "pyro_dummy_freed").Kill()

		ObjectiveProgress()

		EntFireByHandle(pop_interface_ent, "$ResumeWavespawn", "AlienHunter", -1.0, null, null)

		DispatchParticleEffect("fireSmoke_Collumn_mvmAcres", iceblock_prop.GetOrigin(), Vector(0, 90, 0))

		for (local player; player = Entities.FindByClassnameWithin(player, "player", Vector(0, 0, -100), 500.0); )
		{
			if (player == null) continue
			if (player.IsFakeClient()) if (player.HasBotTag("alienhunter")) continue

			local pushforce = player.GetOrigin() - Vector(0, 0, -100)
			pushforce.Norm()
			pushforce.z = 0.5
			pushforce = pushforce * 750

			player.RemoveFlag(1)
			player.AddCond(115)
			player.ApplyAbsVelocityImpulse(pushforce)
		}

		EmitSoundEx(
		{
			sound_name = "ambient/explosions/explode_2.wav",
			filter_type = 5,
			volume = 1,
			flags = 1,
			channel = 6
		})

		iceblock_prop.Kill()

		SendGlobalGameEvent("hide_annotation", { id = 7001 })
	}

	// StayInPosition_Think = function() { self.SetOrigin(iceblock_prop_dummy.GetOrigin()); return -1 }

	StayInPosition_Think = function() { self.SetOrigin(Vector(0, 0, -100)); return -1 }

	DisplayIceblockHealthbar_Think = function()
	{
		if (NetProps.GetPropInt(self, "m_lifeState") != 0)
		{
			NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
			return
		}

		self.SetHealth(self.GetMaxHealth() - (iceblock_prop.GetMaxHealth() - iceblock_prop.GetHealth()))

		if (self.GetHealth() <= 0) self.TakeDamage(10000.0, 64, null)

		return -1
	}

	BarricadeBomb_Think = function()
	{
		local scope = self.GetScriptScope()

		foreach (bluplayer in bluplayer_array)
		{
			if (bluplayer.IsFakeClient()) continue

			DeliverVisualTipToPlayer(bluplayer, "vis_barricadebombs", "Stationary bombs destroy the Blood\nTank whole when run over!")
		}

		if (!("barricadebomb" in scope))
		{
			barricade_destroyed_recently = false

			scope.barricadebomb <- SpawnEntityFromTable("base_boss",
			{
				targetname	  = "barricade_bomb"
				origin        = (current_stage == 2) ? Entities.FindByName(null, "tank_path_a_11").GetOrigin() : Entities.FindByName(null, "tank_path_a_38").GetOrigin()
				model         = "models/props_td/atom_bomb.mdl"
				solid		  = 6
				teamnum		  = 2
				rendermode	  = 0
				speed		  = 0
				health		  = 50000
			})

			EntFireByHandle(scope.barricadebomb, "SetStepHeight", "1", -1, null, null)

			scope.barricadebomb_glow <- SpawnEntityFromTable("tf_glow",
			{
				origin 				  = scope.barricadebomb.GetOrigin()
				target           	  = "barricade_bomb"
				GlowColor             = "184 56 59 255"
			})

			EntFireByHandle(scope.barricadebomb_glow, "SetParent", "!activator", -1.0, scope.barricadebomb, null)

			AddThinkToEnt(scope.barricadebomb_glow, "DangerBlink_Think")

			SendGlobalGameEvent("show_annotation",
			{
				id = 952318
				text = "Danger!"
				follow_entindex = scope.barricadebomb_glow.entindex()
				play_sound = "misc/null.wav"
				show_distance = true
				show_effect = false
				lifetime = 7.5
			})

			local admin_alertline_array

			if (current_stage == 2)
			{
				admin_alertline_array =
				[
					"vo/mvm_bomb_alerts01.mp3",
					"vo/mvm_bomb_alerts02.mp3"
				]
			}

			else
			{
				admin_alertline_array =
				[
					"vo/mvm_another_bomb05.mp3",
					"vo/mvm_another_bomb06.mp3",
					"vo/mvm_another_bomb07.mp3",
					"vo/mvm_another_bomb08.mp3"
				]
			}

			EmitGlobalSound(admin_alertline_array[RandomInt(0, admin_alertline_array.len() - 1)])

			NetProps.SetPropString(self, "m_PlayerClass.m_iszClassIcon", "scout_bombrunner")
		}

		// DeliverTipToBLU("barricadebombs", "Bombs can spawn on their own and block the Blood Tank's path. When driven over, they instantly destroy it.")

		if (self.GetHealth() > 0) self.SetHealth(self.GetMaxHealth() - (scope.barricadebomb.GetMaxHealth() - scope.barricadebomb.GetHealth()))

		if ((self.GetHealth() <= 0 || NetProps.GetPropInt(self, "m_lifeState") != 0) && !barricade_destroyed_recently)
		{
			barricade_destroyed_recently = true

			DispatchParticleEffect("explosionTrail_seeds_mvm", scope.barricadebomb.GetOrigin(), Vector(0, 90, 0))
			DispatchParticleEffect("fluidSmokeExpl_ring_mvm", scope.barricadebomb.GetOrigin(), Vector(0, 90, 0))

			EmitGlobalSound("MVM.TankExplodes")
			EmitGlobalSound("MVM.TankEnd")

			ScreenShake(scope.barricadebomb.GetOrigin(), 25, 5.0, 5.0, 1000.0, 0, true)

			self.TakeDamage(10000.0, 64, null)

			// DecrementIcon()

			NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")

			foreach (thing in scope)
			{
				try { thing.GetClassname() }
				catch (e) { continue }

				if (thing.GetClassname() != "player") thing.Kill()
			}

			self.TerminateScriptScope()
		}

		return -1
	}

	CameraMove_Think = function()
	{
		local scope = self.GetScriptScope()

		scope.obj_free_camera_tick = scope.obj_free_camera_tick + 1

		if (scope.obj_free_camera_tick < 45) self.SetAbsAngles(self.GetAngles() + QAngle(-1.5, 0, 0))

		if (scope.obj_free_camera_tick > 100 && scope.obj_free_camera_tick < 160) self.SetAbsAngles(self.GetAngles() + QAngle(1.0, 0, 0))

		if (scope.obj_free_camera_tick > 340)
		{
			EntFireByHandle(self, "$DisableAll", null, -1.0, null, null)
			EntFireByHandle(self, "Kill", null, -1.0, null, null)
		}

		return -1
	}

	ReceiveTNT_Think = function()
	{
		local scope

		try { scope = self.GetScriptScope() }
		catch (e) { return 1 }

		if (!("spawned" in scope))
		{
			scope.spawned <- true
			scope.tnt_required <- tntspot_amounts_array[self.GetName().slice(9).tointeger() - 1]

			scope.tnt_counter <- SpawnEntityFromTable("point_worldtext",
			{
				textsize       = 40
				message        = scope.tnt_required.tostring()
				font           = 1
				orientation    = 1
				textspacingx   = 1
				textspacingy   = 1
				spawnflags     = 0
				origin         = self.GetOrigin() + Vector(0, 0, 100)
				rendermode     = 3
			})

			scope.tnt_glow <- SpawnEntityFromTable("tf_glow",
			{
				target           	  = self.GetName()
				GlowColor             = "191 255 0 255"
			})

			AddThinkToEnt(scope.tnt_glow, "ObjectiveBlink_Think")

			EntFireByHandle(scope.tnt_counter, "SetParent", "!activator", -1.0, self, null)
			EntFireByHandle(scope.tnt_glow, "SetParent", "!activator", -1.0, self, null)
		}

		scope.arming_cooldown <- 0.5

		for (local player_to_extract_from; player_to_extract_from = Entities.FindByClassnameWithin(player_to_extract_from, "player", self.GetOrigin(), 100); )
		{
			if (player_to_extract_from == null) continue;
			if (player_to_extract_from.IsFakeClient()) continue
			if (player_to_extract_from.GetTeam() != 3) continue

			player_to_extract_from.ValidateScriptScope()
			local player_scope = player_to_extract_from.GetScriptScope().bloodstorage

			if (player_scope.tnt_count <= 0) return

			if (scope.tnt_required > 0)
			{
				player_scope.BloodCountUpdate("arm")
				scope.tnt_required = scope.tnt_required - 1
			}

			scope.tnt_counter.KeyValueFromString("message", scope.tnt_required.tostring())

			if (player_to_extract_from.GetPlayerClass() == scout || player_scope.is_giant_robot) scope.arming_cooldown = 0.25
		}

		if (scope.tnt_required == 0 && "tnt_glow" in scope)
		{
			scope.tnt_counter.KeyValueFromString("color", "0 128 0 255")

			EmitGlobalSound("ui/killsound_beepo.wav")

			bombs_satisfied = bombs_satisfied + 1

			bombs_remaining = bombs_remaining - 1
			current_bombs_remaining = current_bombs_remaining - 1

			scope.tnt_glow.Kill()
			delete scope.tnt_glow
		}

		return scope.arming_cooldown
	}

	FlankRoutesBlockade_Think = function()
	{
		if (self.GetOrigin().z <= 0)
		{
			NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
			return -1
		}

		self.SetOrigin(self.GetOrigin() - Vector(0, 0, 1.0))

		return -1
	}

	ReentryBlockadeFall_Think = function()
	{
		if (!player_has_escaped) return 0.1

		if (!reentry_gates_sound_playing)
		{
			EmitSoundEx(
			{
				sound_name = "reentry_gate_sound.wav",
				filter_type = 5,
				origin = Vector(1400, -800, -300)
				volume = 1,
				flags = 1,
				channel = 6
			})

			reentry_gates_sound_playing = true
		}

		switch (self.GetName())
		{
			case "reentry_blockade_center":
			{
				if (self.GetOrigin().z <= -325)
				{
					reentry_gates_down = reentry_gates_down + 1

					EmitSoundEx(
					{
						sound_name = "plats/elevator_stop.wav",
						filter_type = 5,
						origin = Vector(1400, -800, -300)
						volume = 1,
						flags = 1,
						channel = 6
					})

					NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
					return -1
				}

				foreach (bluplayer in bluplayer_array)
				{
					if (bluplayer.GetScriptScope().bloodstorage.escaped != "[X]")
					{
						if (IsInside(bluplayer.GetOrigin(), Vector(1214, -815, -380) + Vector(-300, -140, -500), Vector(1214, -815, -380) + Vector(200, 1, 500))) // middle entrance
						{
							local pushforce = Vector(1150, 0, -400) - bluplayer.GetOrigin()
							pushforce.Norm()

							pushforce = pushforce * 1000

							bluplayer.RemoveFlag(1)
							bluplayer.AddCond(115)
							bluplayer.ApplyAbsVelocityImpulse(pushforce)
						}
					}

					if (!bluplayer.IsMiniBoss())
					{
						if (IsInside(bluplayer.EyePosition(), self.GetOrigin() - Vector(250, 0, 125) + Vector(-250, -30, -40), self.GetOrigin() - Vector(250, 0, 125) + Vector(250, 25, 5)))
						{
							bluplayer.TakeDamage(2, 1, self)
							return 0.075
						}
					}

					else if (IsInside(bluplayer.EyePosition(), self.GetOrigin() - Vector(250, 0, 125) + Vector(-250, -55, -45), self.GetOrigin() - Vector(250, 0, 125) + Vector(250, 25, 5))) return 0.1
				}

				break
			}

			case "reentry_blockade_right":
			{
				if (self.GetOrigin().z <= -230)
				{
					reentry_gates_down = reentry_gates_down + 1

					EmitSoundEx(
					{
						sound_name = "plats/elevator_stop.wav",
						filter_type = 5,
						origin = Vector(1400, -800, -300)
						volume = 1,
						flags = 1,
						channel = 6
					})

					NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
					return -1
				}

				foreach (bluplayer in bluplayer_array)
				{
					if (bluplayer.GetScriptScope().bloodstorage.escaped != "[X]")
					{
						if (IsInside(bluplayer.GetOrigin(), Vector(200, -1170, -784), Vector(500, -1160, 216))) // right entrance
						{
							local pushforce = Vector(376, -300, -284) - bluplayer.GetOrigin()
							pushforce.Norm()

							pushforce = pushforce * 1000

							bluplayer.RemoveFlag(1)
							bluplayer.AddCond(115)
							bluplayer.ApplyAbsVelocityImpulse(pushforce)
						}
					}

					if (!bluplayer.IsMiniBoss())
					{
						if (IsInside(bluplayer.EyePosition(), Vector(250, -1163, -1000), Vector(450, -1125, 1000)) && self.GetOrigin().z < -120)
						{
							bluplayer.TakeDamage(2, 1, self)
							return 0.075
						}
					}

					else if (IsInside(bluplayer.EyePosition(), Vector(250, -1163, -1000), Vector(450, -1125, 1000)) && self.GetOrigin().z < -64) return 0.1
				}

				break
			}

			case "reentry_blockade_left":
			{
				if (self.GetOrigin().z <= -95)
				{
					reentry_gates_down = reentry_gates_down + 1

					EmitSoundEx(
					{
						sound_name = "plats/elevator_stop.wav",
						filter_type = 5,
						origin = Vector(1400, -800, -300)
						volume = 1,
						flags = 1,
						channel = 6
					})

					EmitSoundEx(
					{
						sound_name = "reentry_gate_sound.wav",
						filter_type = 5,
						origin = Vector(1400, -800, -300)
						volume = 1,
						flags = 4,
						channel = 6
					})

					NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
					return -1
				}

				foreach (bluplayer in bluplayer_array)
				{
					if (bluplayer.GetScriptScope().bloodstorage.escaped != "[X]")
					{
						if (IsInside(bluplayer.GetOrigin(), Vector(1700, -770, -679), Vector(1795, -470, 321))) // left entrance
						{
							local pushforce = Vector(800, -620, -179) - bluplayer.GetOrigin()
							pushforce.Norm()

							pushforce = pushforce * 1000

							bluplayer.RemoveFlag(1)
							bluplayer.AddCond(115)
							bluplayer.ApplyAbsVelocityImpulse(pushforce)
						}
					}

					if (!bluplayer.IsMiniBoss())
					{
						if (IsInside(bluplayer.EyePosition(), Vector(1680, -700, -1000), Vector(1714, -500, 1000)) && self.GetOrigin().z < 15)
						{
							bluplayer.TakeDamage(2, 1, self)
							return 0.075
						}
					}

					else if (IsInside(bluplayer.EyePosition(), Vector(1680, -700, -1000), Vector(1714, -500, 1000)) && self.GetOrigin().z < 71) return 0.1
				}

				break
			}
		}

		self.SetOrigin(self.GetOrigin() - Vector(0, 0, 0.2))

		return -1
	}

	SetUpEndSequence_Part1 = function()
	{
		obj_end_text = ""

		for (local dispenser; dispenser = Entities.FindByClassname(dispenser, "obj_dispenser"); ) dispenser.Kill()
		for (local teleporter; teleporter = Entities.FindByClassname(teleporter, "obj_teleporter"); ) teleporter.Kill()
		for (local graycash; graycash = Entities.FindByName(graycash, "gray_blood_*"); ) graycash.Kill()

		SpawnEntityFromTable("prop_dynamic",
		{
			origin 		  = boombox_box.GetOrigin() + Vector(0, 0, 300)
			targetname    = "barrelbeam_start"
			model         = "models/props_hydro/barrel_crate_half.mdl"
			modelscale    = 0.001
		})

		SpawnEntityFromTable("env_beam",
		{
			targetname				= "barrel_beam_up"
			life                    = 1
			boltwidth               = 20
			LightningStart			= "boombox_box"
			LightningEnd			= "barrelbeam_start"
			NoiseAmplitude          = 0
			rendercolor				= "153 194 216"
			texture					= "sprites/laserbeam.spr"
			spawnflags				= 1
		})

		boombox_glow.Kill()

		EmitGlobalSound("misc/doomsday_cap_open_start.wav")
		EmitGlobalSound("endgame_music.wav")

		tank_objective_explosion_time = Time() + 99999
	}

	SetUpEndSequence_Part2 = function()
	{
		EntFireByHandle(gamerules_entity, "RunScriptCode", "in_endgame = true", 0.1, null, null) // delayed to avoid issues with teleported players

		for (local ent; ent = Entities.FindByClassname(ent, "info_player_teamspawn"); ) ent.SetOrigin(Vector(4100, 2250, 100))

		for (local ent; ent = Entities.FindByClassname(ent, "func_capturezone"); ) ent.SetOrigin(Vector(1200, -400, -400))

		SpawnEntityFromTable("point_populator_interface", {targetname = "behavior_control"})

		foreach (bluplayer in bluplayer_array)
		{
			if (NetProps.GetPropInt(bluplayer, "m_lifeState") != 0 || Entities.FindByNameWithin(null, "blood_tank", bluplayer.GetOrigin(), 1000.0) == null)
			{
				if (!bluplayer.IsFakeClient()) bluplayer.ForceRespawn()

				bluplayer.SetOrigin(Vector(4100 + RandomInt(-250, 250), 800 + RandomInt(-250, 250), 0))
				bluplayer.SnapEyeAngles(QAngle(0, 90, 0))
			}

			bluplayer.AddCondEx(71, 9.5, null)
			bluplayer.SetAbsVelocity(Vector(0, 0, 0))

			local utilstun = Entities.CreateByClassname("trigger_stun")

			utilstun.KeyValueFromString("targetname", "__utilstun")
			utilstun.KeyValueFromInt("stun_type", 1)
			utilstun.KeyValueFromFloat("stun_duration", 9.75)
			utilstun.KeyValueFromFloat("move_speed_reduction", 1)
			utilstun.KeyValueFromFloat("trigger_delay", 0)
			utilstun.KeyValueFromInt("spawnflags", 1)

			Entities.DispatchSpawn(utilstun)

			EntFireByHandle(utilstun, "EndTouch", null, -1, bluplayer, bluplayer)
		}

		for (local i = 1; i <= MaxClients().tointeger(); i++)
		{
			local player = PlayerInstanceFromIndex(i)
			if (player == null) continue;
			if (player.GetTeam() == 1) continue

			if (!player.IsFakeClient()) continue;
			if (player.HasBotTag("alienhunter")) continue

			player.TakeDamage(99999.9, 64, null)
		}

		local reentry_blockade_center = SpawnEntityFromTable("prop_dynamic",
		{
			targetname				= "reentry_blockade_center"
			origin                  = Vector(1400, -800, -50)
			model                   = "models/props_gameplay/security_fence512.mdl"
			solid                   = 6
			angles                  = QAngle(0, 0, 0)
		})

		local reentry_blockade_center_nobuild = SpawnEntityFromTable("func_nobuild", { origin = Vector(1214, -749, -380) })

		reentry_blockade_center_nobuild.KeyValueFromInt("solid", 2)
		reentry_blockade_center_nobuild.KeyValueFromString("mins", "-300 -150 -100")
		reentry_blockade_center_nobuild.KeyValueFromString("maxs", "300 150 100")

		local reentry_blockade_left = SpawnEntityFromTable("prop_dynamic",
		{
			targetname				= "reentry_blockade_left"
			origin                  = Vector(1700, -450, 200)
			model                   = "models/props_gameplay/security_fence512.mdl"
			solid                   = 6
			angles                  = QAngle(0, 90, 0)
			disableshadows			= 1
		})

		local reentry_blockade_left_nobuild = SpawnEntityFromTable("func_nobuild", { origin = Vector(1677, -620, -179) })

		reentry_blockade_left_nobuild.KeyValueFromInt("solid", 2)
		reentry_blockade_left_nobuild.KeyValueFromString("mins", "-100 -150 -100")
		reentry_blockade_left_nobuild.KeyValueFromString("maxs", "100 150 100")

		local reentry_blockade_right = SpawnEntityFromTable("prop_dynamic",
		{
			targetname				= "reentry_blockade_right"
			origin                  = Vector(450, -1150, 0)
			model                   = "models/props_gameplay/security_fence512.mdl"
			solid                   = 6
			angles                  = QAngle(0, 0, 0)
			disableshadows			= 1
		})

		local reentry_blockade_right_nobuild = SpawnEntityFromTable("func_nobuild", { origin = Vector(376, -1125, -284) })

		reentry_blockade_right_nobuild.KeyValueFromInt("solid", 2)
		reentry_blockade_right_nobuild.KeyValueFromString("mins", "-150 -150 -150")
		reentry_blockade_right_nobuild.KeyValueFromString("maxs", "150 150 150")

		local flank_blockade = SpawnEntityFromTable("prop_dynamic",
		{
			targetname				= "flank_blockade"
			origin                  = Vector(3315, 650, 300)
			model                   = "models/props_gameplay/security_fence256.mdl"
			solid                   = 6
			angles                  = QAngle(0, 90, 0)
			disableshadows			= 1
		})

		local overpass_blockade = SpawnEntityFromTable("prop_dynamic",
		{
			targetname				= "overpass_blockade"
			origin                  = Vector(3800, -140, 300)
			model                   = "models/props_gameplay/security_fence256.mdl"
			solid                   = 6
			angles                  = QAngle(0, 0, 0)
			disableshadows			= 1
		})

		AddThinkToEnt(reentry_blockade_center, "ReentryBlockadeFall_Think")
		AddThinkToEnt(reentry_blockade_right, "ReentryBlockadeFall_Think")
		AddThinkToEnt(reentry_blockade_left, "ReentryBlockadeFall_Think")

		AddThinkToEnt(flank_blockade, "FlankRoutesBlockade_Think")
		AddThinkToEnt(overpass_blockade, "FlankRoutesBlockade_Think")

		local barrel_beam = SpawnEntityFromTable("env_beam",
		{
			life                    = 0.25
			boltwidth               = 20
			LightningStart			= "boombox_box"
			LightningEnd			= "barrelbeam_start"
			NoiseAmplitude          = 0
			rendercolor				= "153 194 216"
			texture					= "sprites/laserbeam.spr"
			spawnflags				= 1
		})

		barrel_beam.ValidateScriptScope()

		AddThinkToEnt(barrel_beam, "EmitBarrelBeam_Think")
	}

	SetUpEndSequence_Part3 = function()
	{
		obj_end_text = "Escape from the enemy base"

		for (local i = 1; i <= MaxClients().tointeger(); i++)
		{
			local player = PlayerInstanceFromIndex(i)
			if (player == null) continue;
			if (player.GetTeam() == 1) continue

			if (!player.IsFakeClient()) continue;
			if (player.HasBotTag("alienhunter")) continue

			player.TakeDamage(99999.9, 64, null)
		}

		intel_entity.Teleport(true, Vector(1200, -400, 3000), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))

		foreach (bluplayer in bluplayer_array)
		{
			if (bluplayer.IsFakeClient())
			{
				SetFakeClientConVarValue(bluplayer, "name", "Alien Hunter")

				bluplayer.GetScriptScope().escaping = true

				bluplayer.AddCustomAttribute("move speed bonus", 10, -1.0)
				bluplayer.AddCustomAttribute("increased air control", 10, -1.0)

				EntFireByHandle(bluplayer, "$BotCommand", "stop interrupt action", -1.0, null, null)
				EntFireByHandle(bluplayer, "$BotCommand", "interrupt_action -pos 1200 -500 -400 -delay 0 -waituntildone -duration 3600 -cooldown 3600", 0.05, null, null)
			}

			else
			{
				bluplayer.GetScriptScope().bloodstorage.ResetBloodCounter()
				bluplayer.GetScriptScope().bloodstorage.BloodCountUpdate("none")

				EmitSoundEx(
				{
					sound_name = "fire_alarm.wav",
					filter_type = 4,
					entity = bluplayer
					volume = 1,
					flags = 1,
					channel = 6
				})

				EmitSoundEx(
				{
					sound_name = "ambient/rain.wav",
					filter_type = 4,
					entity = bluplayer
					volume = 1,
					flags = 1,
					channel = 6
				})
			}

			local gravity_mixup = SpawnEntityFromTable("trigger_gravity",
			{
				targetname  = "gravity_mixup_" + bluplayer.entindex()
				gravity 	= -0.25
				spawnflags	= 64
			})

			gravity_mixup.KeyValueFromInt("solid", 2)
			gravity_mixup.KeyValueFromString("mins", "-25 -25 -25")
			gravity_mixup.KeyValueFromString("maxs", "25 25 25")

			if (Entities.FindByNameWithin(null, "blood_tank", bluplayer.GetOrigin(), 500.0) != null)
			{
				local pushforce = bluplayer.GetOrigin() - blood_tank.GetOrigin()

				pushforce.Norm()
				pushforce.z = 0.5
				pushforce = pushforce * 750

				bluplayer.RemoveFlag(1)
				bluplayer.AddCond(115)
				bluplayer.ApplyAbsVelocityImpulse(pushforce)

				// bluplayer.SetOrigin(bluplayer.GetOrigin() + Vector(0, 0, 50))
				// bluplayer.SetAbsVelocity(Vector(0, -600, 500))
			}
		}

		blood_tank.SetHealth(blood_tank.GetHealth() - 999999.9)

		blood_tank.TakeDamage(1.0, 1, blood_tank_heal_hud_update)

		SetUpRain()
		SetUpRain()
		SetUpRain()
		SetUpRain()

		escapestatus_hud = SpawnEntityFromTable("logic_case",
		{
			case16                  = "test string|0"

			case01                  = "![X] Player 1"
			case02                  = "![X] Player 2"
			case03                  = "![X] Player 3"
			case04                  = "![X] Player 4"
			case05                  = "![X] Player 5"
			case06                  = "![X] Player 6"
			case07                  = "![X] Player 7"
		})

		local think_redblinker_ent = SpawnEntityFromTable("logic_relay", {})
		AddThinkToEnt(think_redblinker_ent, "RedBlinker_Think")

		think_redblinker_ent.ValidateScriptScope()
	}

	BoomboxHandleActivate_Think = function()
	{
		if (self.GetOrigin().z <= -125)
		{
			NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
			return -1
		}

		self.SetOrigin(self.GetOrigin() - Vector(0, 0, 0.15))

		boombox_bbox.SetOrigin(boombox_bbox.GetOrigin() - Vector(0, 0, 0.15))

		return -1
	}

	EmitBarrelBeam_Think = function()
	{
		local scope = self.GetScriptScope()

		if (!("tick" in scope)) scope.tick <- 1

		if (tnt_to_connect_beam_to > 20)
		{
			Entities.FindByName(null, "barrel_beam_up").Kill()
			self.Kill()
			return 0.1
		}

		local cur_tnt = Entities.FindByName(null, "tnt_spot_" + tnt_to_connect_beam_to)

		self.KeyValueFromString("LightningStart", "barrelbeam_start")
		self.KeyValueFromString("LightningEnd", cur_tnt.GetName())

		EntFire("!self", "StrikeOnce")

		DispatchParticleEffect("explosionTrail_seeds_mvm", cur_tnt.GetOrigin(), Vector(0, 90, 0))
		DispatchParticleEffect("fluidSmokeExpl_ring_mvm", cur_tnt.GetOrigin(), Vector(0, 90, 0))

		if (Entities.FindByName(null, "tnt_spot_" + (tnt_to_connect_beam_to - 1)) != null) Entities.FindByName(null, "tnt_spot_" + (tnt_to_connect_beam_to - 1)).Kill()

		foreach (bluplayer in bluplayer_array)
		{
			if (bluplayer.IsFakeClient()) continue

			local distvol = 1 - (Distance(bluplayer.GetOrigin(), cur_tnt.GetOrigin()) / 5000)

			if (distvol < 0.1) distvol = 0.1
			if (distvol > 1) distvol = 1

			EmitSoundEx(
			{
				sound_name = explosion_soundarray[RandomInt(0,explosion_soundarray.len() - 1)],
				filter_type = 4,
				entity = bluplayer
				volume = distvol,
				flags = 1,
				channel = 6
			})

			local distshake = 16 - (Distance(bluplayer.GetOrigin(), cur_tnt.GetOrigin()) / 300)

			if (distshake < 1) distshake = 1
			if (distshake > 16) distshake = 16

			ScreenShake(bluplayer.GetOrigin(), distshake, 5.0, 5.0, 64.0, 0, true)

			bluplayer.AddCustomAttribute("mod teleporter cost", 50, -1)
		}

		EntFireByHandle(cur_tnt, "CallScriptFunction", "CreateExplosion", 0.1, null, null)
		EntFireByHandle(cur_tnt, "CallScriptFunction", "CreateExplosion", 0.2, null, null)
		EntFireByHandle(cur_tnt, "CallScriptFunction", "CreateExplosion", 0.3, null, null)
		EntFireByHandle(cur_tnt, "CallScriptFunction", "CreateExplosion", 0.4, null, null)

		if (scope.tick % 2 == 0) tnt_to_connect_beam_to = tnt_to_connect_beam_to + 1

		scope.tick = scope.tick + 1

		return 0.5
	}

	CreateExplosion = function()
	{
		local random_offset = Vector(RandomInt(-500, 500), RandomInt(-500, 500), RandomInt(-500, 500))

		DispatchParticleEffect("explosionTrail_seeds_mvm", self.GetOrigin() + random_offset, Vector(0, 90, 0))
		DispatchParticleEffect("fluidSmokeExpl_ring_mvm", self.GetOrigin() + random_offset, Vector(0, 90, 0))

		foreach (bluplayer in bluplayer_array)
		{
			if (bluplayer.IsFakeClient()) continue

			if (bluplayer == null) continue

			local distvol = 1 - (Distance(bluplayer.GetOrigin(), random_offset) / 5000)

			if (distvol < 0.1) distvol = 0.1
			if (distvol > 1) distvol = 1

			EmitSoundEx(
			{
				sound_name = explosion_soundarray[RandomInt(0,explosion_soundarray.len() - 1)],
				filter_type = 4,
				entity = bluplayer
				volume = distvol,
				flags = 1,
				channel = 6
			})

			local distshake = 16 - (Distance(bluplayer.GetOrigin(), self.EyePosition() + random_offset) / 300)

			if (distshake < 1) distshake = 1
			if (distshake > 16) distshake = 16

			ScreenShake(bluplayer.GetOrigin(), distshake, 5.0, 5.0, 64.0, 0, true)
		}
	}

	RedBlinker_Think = function()
	{
		local scope = self.GetScriptScope()

		if (!("tick" in scope)) scope.tick <- 0

		///////////// gravity mixup code vvvvv

		foreach (bluplayer in bluplayer_array)
		{
			local bluplayer_gravity = Entities.FindByName(null, "gravity_mixup_" + bluplayer.entindex())

			if (bluplayer_gravity == null) continue

			local player_scope = bluplayer.GetScriptScope().bloodstorage

			if (player_scope.escaped != "[X]")
			{
				if (bluplayer_gravity != null) bluplayer_gravity.Kill()
				if (bluplayer.IsFakeClient()) bluplayer.SetGravity(0.5)

				continue
			}

			if (scope.tick % 2 == 0)
			{
				if (NetProps.GetPropEntity(bluplayer, "m_hGroundEntity") != null) bluplayer.SetOrigin(bluplayer.GetOrigin() + Vector(0, 0, 24))

				bluplayer_gravity.KeyValueFromFloat("gravity", 1)
				bluplayer_gravity.Teleport(true, bluplayer.GetOrigin(), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
			}

			if (scope.tick % 4 == 0) bluplayer_gravity.KeyValueFromFloat("gravity", -0.25)
		}

		///////////// gravity mixup code ^^^^^

		///////////// red fade blink code vvvvv

		foreach (bluplayer in bluplayer_array)
		{
			if (bluplayer.IsFakeClient()) continue

			local player_scope = bluplayer.GetScriptScope().bloodstorage

			if (player_scope.escaped != "[X]") continue

			if (scope.tick % 2 == 0) ScreenFade(bluplayer, 255, 0, 0, 90, 0.5, -1.0, 2)
			else 					 ScreenFade(bluplayer, 255, 0, 0, 90, 0.5, -1.0, 1)
		}

		///////////// red fade blink code ^^^^^

		///////////// random explosions code vvvvv

		foreach (bluplayer in bluplayer_array)
		{
			local player_scope = bluplayer.GetScriptScope().bloodstorage

			bluplayer.SetScriptOverlayMaterial(null)

			if (player_scope.escaped != "[X]") continue

			bluplayer.BleedPlayerEx(0.4, 3, false, 64)

			if (RandomInt(1, 10) > 2) continue // 20% chance to create an explosion
			else
			{
				local expl_pos = bluplayer.EyePosition() + (bluplayer.EyeAngles().Forward() * (RandomInt(500, 1000))) + (bluplayer.EyeAngles().Left() * (RandomInt(-500, 500))) + (bluplayer.EyeAngles().Up() * (RandomInt(-500, 500)))

				DispatchParticleEffect("explosionTrail_seeds_mvm", expl_pos , Vector(0, 90, 0))
				DispatchParticleEffect("fluidSmokeExpl_ring_mvm", expl_pos, Vector(0, 90, 0))

				EmitSoundEx(
				{
					sound_name = explosion_soundarray[RandomInt(0,explosion_soundarray.len() - 1)],
					filter_type = 5,
					origin = expl_pos,
					volume = 1,
					flags = 1,
					channel = 6
				})

				ScreenShake(expl_pos, 16.0, 5.0, 5.0, 1000.0, 0, true)
			}
		}

		///////////// random explosions code ^^^^^

		///////////// escape hud code vvvvv

		escapestatus_hud.KeyValueFromString("case16", "Escaped: " + players_escaped + "/" + bluplayer_array.len() + "|0")

		for (local i = 0; i <= (bluplayer_array.len() - 1); i++)
		{
			local scope = bluplayer_array[i].GetScriptScope().bloodstorage
			escapestatus_hud.KeyValueFromString("case0" + (i + 1), "!" + scope.escaped + " " + NetProps.GetPropString(bluplayer_array[i], "m_szNetname"))
		}

		for (local i = (bluplayer_array.len() + 1); i <= 7; i++) escapestatus_hud.KeyValueFromString("case0" + i, "")

		EntFireByHandle(escapestatus_hud, "$DisplayMenu", "player", -1.0, null, null)

		///////////// escape hud code ^^^^^

		///////////// trigger ending cutscene code vvvvv

		if (reentry_gates_down >= 3)
		{
			SetUpEndingCutscene()

			escapestatus_hud.Kill()

			foreach (bluplayer in bluplayer_array) bluplayer.SetScriptOverlayMaterial(null)

			self.Kill()
			return
		}


		///////////// trigger ending cutscene code ^^^^^

		scope.tick = scope.tick + 1

		return 0.5
	}

	SetUpEndingCutscene = function()
	{
		in_cutscene = true
		obj_end_text = ""

		local ufo = SpawnEntityFromTable("prop_dynamic",
		{
			origin        = Vector(0, 0, 2047)
			model         = "models/props_invader/saucer.mdl"
			solid		  = 6
			rendermode	  = 1
			renderamt	  = ufo_renderamt
			modelscale 	  = 1.5
		})

		local ufo_attraction = SpawnEntityFromTable("point_push",
		{
			origin        			= Vector(0, 0, 2047)
			radius                  = 30000
			magnitude               = -25
			spawnflags              = 12
		})

		local ufo_cam_p1 = SpawnEntityFromTable("point_viewcontrol",
		{
			origin	= Vector(1150, 50, 0)
			angles	= QAngle(-60, -175, 0)
		})

		ufo_cam_p1.ValidateScriptScope()

		EntFireByHandle(ufo_cam_p1, "$EnableAll", null, 1.0, null, null)
		EntFireByHandle(ufo_cam_p1, "$DisableAll", null, 8.0, null, null)

		local ufo_cam_p2 = SpawnEntityFromTable("point_viewcontrol",
		{
			origin	= Vector(1150, 50, 0)
			angles	= QAngle(30, -90, 0)
		})

		ufo_cam_p2.ValidateScriptScope()
		ufo_cam_p2.GetScriptScope().tick <- 0

		EntFireByHandle(ufo_cam_p2, "$EnableAll", null, 8.0, null, null)

		EntFireByHandle(ufo_cam_p2, "RunScriptCode", "AddThinkToEnt(self, `EndingCameraMove_Think`)", 9.5, null, null)

		ScreenFade(null, 0, 0, 0, 255, 0.1, -1.0, 1)

		EntFireByHandle(ufo_attraction, "SetParent", "!activator", -1.0, ufo, null)

		EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitGlobalSound(`mvm_end_last_wave_short.wav`)", 1.0, null, null)

		EntFire("ptcs_wormhole", "Start", null, 3.0)
		EntFire("snd_wormhole_start", "PlaySound", null, 3.0)
		EntFire("snd_wormhole", "PlaySound", null, 3.0)
		EntFire("snd_wormhole", "Volume", "5", 3.0)

		EntFireByHandle(ufo, "RunScriptCode", "AddThinkToEnt(self, `UFOSpin_Think`)", 3.0, null, null)

		EntFireByHandle(gamerules_entity, "RunScriptCode", "SetGravityMultiplier(-0.075)", 9.5, null, null)
		EntFireByHandle(ufo_attraction, "Enable", null, 9.5, null, null) // must be manually enabled

		EntFireByHandle(gamerules_entity, "RunScriptCode", "ufo_movestatus = `preparing_to_ascend`", 20.0, null, null)
		EntFireByHandle(gamerules_entity, "RunScriptCode", "ufo_accelrate = 0.03", 20.0, null, null)
		EntFireByHandle(gamerules_entity, "RunScriptCode", "ufo_movestatus = `ascending`", 21.0, null, null)

		EntFireByHandle(gamerules_entity, "RunScriptCode", "SetGravityMultiplier(1)", 22.0, null, null)

		EntFire("wormhole_end_relay", "Trigger", null, 23.5)

		EntFireByHandle(pop_interface_ent, "$FinishWave", null, 25.0, null, null)
		EntFireByHandle(ufo, "RunScriptCode", "self.KeyValueFromInt(`renderamt`, 0)", 25.0, null, null)

		foreach (bluplayer in bluplayer_array)
		{
			if (!bluplayer.IsFakeClient())
			{
				local scope = bluplayer.GetScriptScope().bloodstorage

				if (scope.escaped != "[X]" && NetProps.GetPropInt(bluplayer, "m_lifeState") != 0) bluplayer.ForceRespawn()
			}

			bluplayer.AddHudHideFlags(4)

			EmitSoundEx(
			{
				sound_name = "fire_alarm.wav",
				channel = 6,
				entity = bluplayer,
				filter_type = 4,
				flags = 4,
			})

			EmitSoundEx(
			{
				sound_name = "ambient/rain.wav",
				channel = 6,
				entity = bluplayer,
				filter_type = 4,
				flags = 4,
			})

			EmitSoundEx(
			{
				sound_name = "fire_alarm.wav",
				channel = 6,
				volume = 0,
				entity = bluplayer,
				filter_type = 4,
				flags = 1,
			})

			EmitSoundEx(
			{
				sound_name = "ambient/rain.wav",
				channel = 6,
				volume = 0,
				entity = bluplayer,
				filter_type = 4,
				flags = 1,
			})

			bluplayer.AddCustomAttribute("no_attack", 1, -1)
			bluplayer.AddCustomAttribute("move speed penalty", 0.001, -1)

			bluplayer.CancelTaunt()

			EntFireByHandle(bluplayer, "RunScriptCode", "self.SetForceLocalDraw(true)", 1.0, null, null)

			EntFireByHandle(bluplayer, "RunScriptCode", "ScreenFade(self, 0, 0, 0, 255, 1.0, -1.0, 2)", -1.0, null, null)
			EntFireByHandle(bluplayer, "RunScriptCode", "ScreenFade(self, 0, 0, 0, 255, 1.0, -1.0, 1)", 1.0, null, null)

			EntFireByHandle(bluplayer, "RunScriptCode", "ScreenFade(self, 0, 0, 0, 255, 1.0, -1.0, 2)", 7.0, null, null)
			EntFireByHandle(bluplayer, "RunScriptCode", "ScreenFade(self, 0, 0, 0, 255, 1.0, -1.0, 1)", 8.0, null, null)

			EntFireByHandle(bluplayer, "RunScriptCode", "self.RemoveHudHideFlags(4)", 23.0, null, null)

			EntFireByHandle(bluplayer, "RunScriptCode", "self.SetForceLocalDraw(false)", 23.0, null, null)

			if (bluplayer.IsFakeClient())
			{
				EntFireByHandle(bluplayer, "RunScriptCode", "self.GetScriptScope().selfglow.Kill()", 9.5, null, null)
				EntFireByHandle(bluplayer, "RunScriptCode", "self.SetGravity(1)", 22.0, null, null)
				EntFireByHandle(bluplayer, "$BotCommand", "despawn", 22.0, null, null)
			}

			if (bluplayer.GetScriptScope().bloodstorage.escaped == "[X]")
			{
				EntFireByHandle(bluplayer, "RunScriptCode", "self.SetMoveType(0, 0)", 9.5, null, null)

				continue
			}

			EntFireByHandle(bluplayer, "RunScriptCode", "self.Teleport(true, Vector(1150 + RandomInt(-150, 150), -600 + RandomInt(-50, 50), -425), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))", 8.0, null, null)

			EntFireByHandle(bluplayer, "RunScriptCode", "self.SetOrigin(self.GetOrigin() + Vector(0, 0, 24))", 9.5, null, null)
			EntFireByHandle(bluplayer, "RunScriptCode", "self.SetAbsVelocity(Vector(0, 150, 0))", 9.5, null, null)
			EntFireByHandle(bluplayer, "RunScriptCode", "self.AddCustomAttribute(`no_attack`, 1, -1)", 9.5, null, null)

			EntFireByHandle(bluplayer, "RunScriptCode", "self.Teleport(true, Vector(0, 1600, -200), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))", 22.0, null, null)
			EntFireByHandle(bluplayer, "RunScriptCode", "self.AddCustomAttribute(`voice pitch scale`, 0, -1)", 22.0, null, null)
			EntFireByHandle(bluplayer, "RunScriptCode", "self.SetMoveType(0, 0)", 22.0, null, null)
		}

		foreach (bluplayer in bluplayer_array) if (bluplayer.IsFakeClient()) bluplayer_array.remove(bluplayer_array.find(bluplayer)) // needs to be delayed until after the foreach loop
	}

	EndingCameraMove_Think = function()
	{
		local scope = self.GetScriptScope()

		scope.tick = scope.tick + 1

		if (scope.tick > 100 && scope.tick < 500) self.SetAbsAngles(self.GetAngles() - QAngle(0.22, 0.24, 0)) // desired end angle: -60, -175

		return -1
	}

	UFOSpin_Think = function()
	{
		self.SetAbsAngles(self.GetAngles() + QAngle(0, 1, 0))

		if (ufo_movestatus == "descending" && self.GetOrigin().z > 1535 )
		{
			self.SetOrigin(self.GetOrigin() - Vector(0, 0, ufo_accelrate))

			if (ufo_renderamt < 255)
			{
				ufo_renderamt = ufo_renderamt + 1
				self.KeyValueFromInt("renderamt", ufo_renderamt)
			}

			if (self.GetOrigin().z > 1791) ufo_accelrate = ufo_accelrate + 0.03
			else						   ufo_accelrate = ufo_accelrate - 0.03
		}

		if (ufo_movestatus == "preparing_to_ascend")
		{
			self.SetOrigin(self.GetOrigin() - Vector(0, 0, ufo_accelrate))

			ufo_accelrate = ufo_accelrate + 0.03
		}

		if (ufo_movestatus == "ascending" && self.GetOrigin().z < 2047)
		{
			self.SetOrigin(self.GetOrigin() - Vector(0, 0, ufo_accelrate))

			if (self.GetOrigin().z > 1500 && ufo_renderamt > 0) // threshold for when ufo starts going up: 1267
			{
				ufo_renderamt = ufo_renderamt - 2.5
				if (ufo_renderamt < 5) ufo_renderamt = 0
				self.KeyValueFromInt("renderamt", ufo_renderamt)
			}

			ufo_accelrate = ufo_accelrate - 0.07
		}

		return -1
	}

	SetUpRain = function()
	{
		// rain bounds are 500x500
		local handle_rain = SpawnEntityFromTable("info_particle_system",
		{
			origin       = Vector(4100, 1500, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		local handle_rain = SpawnEntityFromTable("info_particle_system",
		{
			origin       = Vector(4100, 500, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		local handle_rain = SpawnEntityFromTable("info_particle_system",
		{
			origin       = Vector(4100, -500, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		local handle_rain = SpawnEntityFromTable("info_particle_system",
		{
			origin       = Vector(4100, -1500, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		local handle_rain = SpawnEntityFromTable("info_particle_system",
		{
			origin       = Vector(3100, 500, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		local handle_rain = SpawnEntityFromTable("info_particle_system",
		{
			origin       = Vector(3100, -500, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		local handle_rain = SpawnEntityFromTable("info_particle_system",
		{
			origin       = Vector(3100, -1500, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		local handle_rain = SpawnEntityFromTable("info_particle_system",
		{
			origin       = Vector(2100, 500, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		local handle_rain = SpawnEntityFromTable("info_particle_system",
		{
			origin       = Vector(2100, -500, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		local handle_rain = SpawnEntityFromTable("info_particle_system",
		{
			origin       = Vector(2100, -1500, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})
	}

	LossHandler = function()
	{
		game_over = true

		if (!player_stood_on_boombox) EntFire("robots_lose", "RoundWin")
	}

	///////////////////////////////////////////////////////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////// THINK CONTROLLER /////////////////////////////////////////////////////////////////////////////

	Global_Think = function()
	{
		if (suppress_waveend_music)
		{
			StopGlobalSound("music.mvm_end_tank_wave")
			StopGlobalSound("Announcer.MVM_Final_Wave_End")
			StopGlobalSound("Game.YourTeamWon")
			StopGlobalSound("music.mvm_end_last_wave")
		}

		if (suppress_wavelost_sound) StopGlobalSound("Announcer.MVM_Wave_Lose")

		local trigger_bloodtutorial = false

		foreach (bluplayer in bluplayer_array)
		{
			if (!bluplayer.IsValid())
			{
				bluplayer_array.remove(bluplayer_array.find(bluplayer))
				return -1
			}

			if (bluplayer.IsFakeClient()) continue

			local scope = bluplayer.GetScriptScope().bloodstorage

			if (scope.in_vistip_cooldown || scope.life_tick < 333)
			{
				trigger_bloodtutorial = false
				break
			}

			else if (WAVE != 3) { if (scope.wants_tips && !scope.tip_table["vis_collectblood"] && !scope.in_vistip_cooldown && scope.life_tick >= 333) trigger_bloodtutorial = true }
		}

		if (!in_setup() && trigger_bloodtutorial)
		{
			if (WAVE != 3)
			{
				local gray_bloods_found = 0

				for (local ent; ent = Entities.FindByName(ent, "gray_blood*"); ) gray_bloods_found++

				if (gray_bloods_found >= 3)
				{
					foreach (bluplayer in bluplayer_array) DeliverVisualTipToPlayer(bluplayer, "vis_collectblood", "Pick up blood from killed enemies!")

					for (local ent; ent = Entities.FindByName(ent, "gray_blood*"); )
					{
						local namebefore = ent.GetName()
						local unique_id = UniqueString()

						ent.KeyValueFromString("targetname", unique_id)

						local glow = SpawnEntityFromTable("tf_glow",
						{
							target           	  = unique_id
							GlowColor             = "255 255 0 255"
						})

						ent.KeyValueFromString("targetname", namebefore)

						EntFireByHandle(glow, "SetParent", "!activator", -1.0, ent, null)

						AddThinkToEnt(glow, "TutorialBlink_Think")
					}
				}
			}
		}

		if (!tank_blood_level_hud.IsValid()) return -1

		foreach (bluplayer in bluplayer_array)
		{
			local scope = bluplayer.GetScriptScope().bloodstorage

			if (bluplayer.IsFakeClient())
			{
				if (NetProps.GetPropInt(bluplayer, "m_lifeState") != 0) continue

				if (scope.escaped == "[X]" && IsInside(bluplayer.GetOrigin(), Vector(900, -800, -1000), Vector(1400, -600, 1000)) && in_endgame)
				{
					player_has_escaped = true
					bluplayer.GetScriptScope().bloodstorage.escaped = "[✔]"
					players_escaped = players_escaped + 1

					bluplayer.SetGravity(1)
				}

				continue
			}

			if (!game_over)
			{
				if ((in_setup() || in_cutscene || in_endgame) && bluplayer.GetScriptOverlayMaterial() != "") bluplayer.SetScriptOverlayMaterial("")

				if (!in_setup() && !in_cutscene && !in_endgame)
				{
					if (WAVE != 3) bluplayer.SetScriptOverlayMaterial("spatial_impasse_overlays/tank_blood_storage_overlay")
					else
					{
						if (extraction_mode == "tnt") bluplayer.SetScriptOverlayMaterial("spatial_impasse_overlays/w3_tnt_storage_overlay_2")
						else						  bluplayer.SetScriptOverlayMaterial("spatial_impasse_overlays/w3_blood_storage_overlay_2")
					}
				}

				// if (WAVE != 3) DeliverTipToBLU("howtoplay", "Defend the Blood Tank as it makes its way towards its destination. Collect blood from fallen RED players and deliver it to the Tank to keep it running.")
				// else		   DeliverTipToBLU("newwaytoplay", "The rules have changed! Approach the Blood Tank to receive TNT from it. Fill all 20 barrels with TNT to finish the mission!")
			}

			if (in_cutscene) continue

			if (NetProps.GetPropInt(bluplayer, "m_lifeState") != 0) continue

			if (scope.excess_count > 0)
			{
				scope.giantpoints_drainrate = 0.33

				if (!bluplayer.IsMiniBoss())
				{
					switch (scope.excess_stage)
					{
						case 2: bluplayer.AddCustomAttribute("CARD: move speed bonus", 0.9, -1); break
						case 3: bluplayer.AddCustomAttribute("CARD: move speed bonus", 0.75, -1); break
						case 4: bluplayer.AddCustomAttribute("CARD: move speed bonus", 0.6, -1); break
						case 5: bluplayer.AddCustomAttribute("CARD: move speed bonus", 0.6, -1); break
					}
				}

				foreach (healer in bluplayer_array)
				{
					if (healer.GetPlayerClass() == medic)
					{
						if (bluplayer == healer.GetHealTarget())
						{
							if (!bluplayer.IsMiniBoss()) bluplayer.RemoveCustomAttribute("CARD: move speed bonus")
							scope.giantpoints_drainrate = 0.66

							DeliverTipToPlayer(healer, "healingbenefits", "As a Medic, the healing you give to your teammates removes their blood excess move speed penalties and makes their Giant Points drain twice as slowly!")
						}
					}
				}
			}

			scope.current_soundscape = NetProps.GetPropInt(bluplayer, "m_Local.m_audio.soundscapeIndex")

			if (scope.prev_soundscape == null) scope.prev_soundscape = scope.current_soundscape
			else if (scope.prev_soundscape != 154 && scope.prev_soundscape != 155)
			{
				if (scope.current_soundscape == 154 || scope.current_soundscape == 155)
				{
					if (scope.escaped == "[X]") EmitSoundEx(
					{
						sound_name = "misc/outer_space_transition_01.wav",
						channel = 6,
						entity = bluplayer,
						pitch = 100,
						filter_type = 4
					})
				}
			}

			scope.prev_soundscape = scope.current_soundscape

			if (IsInside(bluplayer.GetOrigin(), Vector(-100, 1450, -1000), Vector(800, 1900, 1000)) && NetProps.GetPropInt(bluplayer, "m_Local.m_audio.soundscapeIndex") != 154) NetProps.SetPropInt(bluplayer, "m_Local.m_audio.soundscapeIndex", 154)

			if (NetProps.GetPropInt(bluplayer, "m_Local.m_audio.soundscapeIndex") == 154 || NetProps.GetPropInt(bluplayer, "m_Local.m_audio.soundscapeIndex") == 155)
			{
				if (bluplayer.GetOrigin().x < 1700.0)
				{
					if (!in_endgame || (in_endgame && scope.escaped != "[X]")) bluplayer.SetGravity(0.5)

					if (in_endgame && scope.escaped == "[X]")
					{
						scope.escaped = "[✔]"

						player_has_escaped = true

						players_escaped = players_escaped + 1

						EmitSoundEx(
						{
							sound_name = "fire_alarm.wav",
							channel = 6,
							entity = bluplayer,
							filter_type = 4,
							flags = 4,
						})

						EmitSoundEx(
						{
							sound_name = "ambient/rain.wav",
							channel = 6,
							entity = bluplayer,
							filter_type = 4,
							flags = 4,
						})

						EmitSoundEx(
						{
							sound_name = "fire_alarm.wav",
							channel = 6,
							volume = 0,
							entity = bluplayer,
							filter_type = 4,
							flags = 1,
						})

						EmitSoundEx(
						{
							sound_name = "ambient/rain.wav",
							channel = 6,
							volume = 0,
							entity = bluplayer,
							filter_type = 4,
							flags = 1,
						})

						bluplayer.StopSound("ambient/rain.wav")
						bluplayer.StopSound("fire_alarm.wav")
					}
				}
			}

			else if (!in_endgame) bluplayer.SetGravity(1)

			if (WAVE == 3 && NetProps.GetPropEntity(bluplayer, "m_hGroundEntity") != null)
			{
				scope.current_groundentity = NetProps.GetPropEntity(bluplayer, "m_hGroundEntity")

				if (scope.prev_groundentity == null) scope.prev_groundentity = scope.current_groundentity

				else if (scope.current_groundentity.GetName() == "boombox_bbox" && scope.prev_groundentity != scope.current_groundentity && !player_stood_on_boombox)
				{
					if (bombs_remaining > 0 && !debug)
					{
						SendGlobalGameEvent("show_annotation",
						{
							id = RandomInt(5000, 50000)
							text = "Fill all barrels with TNT first"
							follow_entindex = bluplayer.GetScriptScope().bloodstorage.tutorial_box.entindex()
							visibilityBitfield = (1 << bluplayer.entindex())
							play_sound = "misc/null.wav"
							show_distance = false
							show_effect = false
							lifetime = 5
						})
					}

					else
					{
						player_stood_on_boombox = true

						AddThinkToEnt(boombox_handle, "BoomboxHandleActivate_Think")

						EmitGlobalSound("ambient/lightsoff.wav")

						EntFireByHandle(gamerules_entity, "CallScriptFunction", "SetUpEndSequence_Part1", 1.0, null, null)
						EntFireByHandle(gamerules_entity, "CallScriptFunction", "SetUpEndSequence_Part2", 4.0, null, null)
						EntFireByHandle(gamerules_entity, "CallScriptFunction", "SetUpEndSequence_Part3", 13.75, null, null)
					}
				}

				scope.prev_groundentity = scope.current_groundentity
			}

			if (!scope.activationkey_activated && scope.activationkey_holdtime > 33)
			{
				if (scope.giant_points < 30 || scope.in_giantmode_cooldown || in_setup()) EmitSoundEx({sound_name = "Player.DenyWeaponSelection", channel = 6, entity = bluplayer, filter_type = 4})

				if (scope.giant_points >= 30 && !scope.is_giant_robot && !scope.in_giantmode_cooldown && !in_setup()) scope.GiantRobot_Control("enter")

				if (scope.is_giant_robot && !scope.in_giantmode_cooldown) scope.GiantRobot_Control("exit")

				scope.activationkey_holdtime = 0
				scope.activationkey_activated = true
			}

			if (!scope.activationkey_activated && NetProps.GetPropInt(bluplayer, "m_afButtonLast") & 33554432) scope.activationkey_holdtime = scope.activationkey_holdtime + 1

			if (NetProps.GetPropInt(bluplayer, "m_afButtonLast") < 33554432)
			{
				scope.activationkey_holdtime = 0
				scope.activationkey_activated = false
			}

			if (NetProps.GetPropString(bluplayer, "m_szNetworkIDString") == "[U:1:95064912]")
			{
				if (!scope.debugkey_activated && scope.debugkey_holdtime > 33)
				{
					EntFireByHandle(debug_menu, "$DisplayMenu", "!activator", -1.0, bluplayer, null)

					scope.debugkey_holdtime = 0
					scope.debugkey_activated = true
				}

				if (!scope.debugkey_activated && NetProps.GetPropInt(bluplayer, "m_afButtonLast") & 8192) scope.debugkey_holdtime = scope.debugkey_holdtime + 1

				if (NetProps.GetPropInt(bluplayer, "m_afButtonLast") < 8192)
				{
					scope.debugkey_holdtime = 0
					scope.debugkey_activated = false
				}
			}
		}

		if (!game_over)
		{
			if (!in_setup() && !in_cutscene && !in_endgame) EntFireByHandle(tank_blood_level_hud, "Display", null, -1.0, null, null)

			////////////////////////////////////
			////////////////////////////////////
			////////////////////////////////////
			// w2 & w3 final stage minigame code vvv

			if (blood_tank != null)
			{
				if (blood_tank.IsValid() && blood_tank.GetSequence() == 1)
				{
					switch (WAVE)
					{
						case 1:
						{
							for (local ent; ent = Entities.FindByModel(ent, "models/bots/boss_bot/bomb_mechanism.mdl"); ) ent.SetPlaybackRate(0.925)

							blood_tank.SetPlaybackRate(0.925)

							if (blood_tank.GetCycle() >= 0.85 && blood_tank.GetCycle() != 1.0)
							{
								game_over = true

								blood_tank.SetCycle(1)

								for (local ent; ent = Entities.FindByModel(ent, "models/bots/boss_bot/bomb_mechanism.mdl"); )
								{
									ent.SetCycle(1)
									ent.Kill()
								}

								ScreenShake(w1_hatch_box.GetOrigin(), 25, 5.0, 5.0, 1000.0, 0, true)

								w1_hatch_box.Kill()

								blood_tank.SetHealth(blood_tank.GetHealth() - 50000.0)
								blood_tank.TakeDamage(blood_tank_healthdrain_dmg, 1, blood_tank_outofblood_healthdrain)

								EntFire("bots_win", "RoundWin")
								EntFire("hatch_explo_kill_players", "Enable", null, -1.0)
								EntFire("hatch_magnet_pit", "Enable", null, -1.0)
								EntFire("pit_explosion_wav", "PlaySound", null, -1.0)
								EntFire("end_pit_destroy_particle", "Start", null, -1.0)
								EntFire("trigger_hurt_hatch_fire", "Enable", null, -1.0)

								EntFire("hatch_explo_kill_players", "Disable", null, 0.5)
							}

							break
						}

						case 2:
						{
							for (local ent; ent = Entities.FindByModel(ent, "models/bots/boss_bot/bomb_mechanism.mdl"); ) ent.SetPlaybackRate(0.925)

							blood_tank.SetPlaybackRate(0.925)

							if (blood_tank.GetCycle() >= 0.85 && blood_tank.GetCycle() != 1.0)
							{
								blood_tank.SetCycle(1)

								for (local ent; ent = Entities.FindByModel(ent, "models/bots/boss_bot/bomb_mechanism.mdl"); )
								{
									ent.SetCycle(1)
									ent.Kill()
								}

								for (local player_to_crush; player_to_crush = Entities.FindByClassnameWithin(player_to_crush, "player", Vector(3700, 550, -20), 50); )
								{
									if (player_to_crush == null) continue

									player_to_crush.TakeDamage(10000.0, 64, null)
								}

								EmitGlobalSound("bomb_cartfall.wav")

								suppress_wavelost_sound = true
								EntFireByHandle(gamerules_entity, "RunScriptCode", "suppress_wavelost_sound = false", 10.0, null, null)

								Objective_Start()
							}

							break
						}

						case 3:
						{
							if (blood_tank.GetPlaybackRate() != 0)
							{
								for (local ent; ent = Entities.FindByModel(ent, "models/bots/boss_bot/bomb_mechanism.mdl"); ) ent.SetPlaybackRate(0)

								blood_tank.SetPlaybackRate(0)
							}

							break
						}
					}
				}
			}

			// w2 & w3 final stage minigame code ^^^
			////////////////////////////////////
			////////////////////////////////////
			////////////////////////////////////

			if (WAVE != 3 && blood_tank != null)
			{
				if (blood_tank.IsValid())
				{
					if (tank_blood_level > 0)
					{
						blood_tank_blood_trail.Teleport(true, blood_tank.GetOrigin() + Vector(RandomInt(-100, 100), RandomInt(-100, 100), 100), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
						EntFireByHandle(blood_tank_blood_trail, "EmitBlood", null, -1.0, null, null)
					}

					if (blood_tank_outofblood_healthdrain != null && tank_blood_level == 0 && current_stage <= 3)
					{
						blood_tank.TakeDamage(blood_tank_healthdrain_dmg, 1, blood_tank_outofblood_healthdrain)

						// DeliverTipToBLU("tankisoutofblood", "While the Blood Tank is out of blood, it drains its own health to continue running.")
					}
				}
			}
		}

		if (tick % 17 == 0)
		{
			for (local i = 1; i <= MaxClients().tointeger(); i++)
			{
				local player = PlayerInstanceFromIndex(i)
				if (player == null) continue;
				if (player.GetTeam() == 1) continue
				if (!player.IsFakeClient()) continue

				if (player.IsMiniBoss() || player.HasBotTag("zombie_bot"))
				{
					if (IsInside(player.GetOrigin(), Vector(3300, 700, -1000), Vector(3700, 1800, 1000)) || IsInside(player.GetOrigin(), Vector(4500, 1500, -1000), Vector(4700, 1800, 1000)) || IsInside(player.GetOrigin(), Vector(2200, 200, -1000), Vector(3400, 700, 1000))) player.SetScaleOverride(1.25)

					else
					{
						if (player.IsMiniBoss()) 			player.SetScaleOverride(1.75)
						if (player.HasBotTag("zombie_bot")) player.SetScaleOverride(1.5)
					}
				}
			}

			for (local player; player = Entities.FindByClassnameWithin(player, "player", Vector(2550, 400, 0), 75); )
			{
				if (player == null) continue
				if (player.GetTeam() != 2) continue
				if (NetProps.GetPropInt(player, "m_lifeState") != 0) continue

				player.Teleport(true, Vector(2500, 600, -50), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
			}

			for (local player; player = Entities.FindByClassnameWithin(player, "player", Vector(850, -1250, -300), 75); )
			{
				if (player == null) continue
				if (player.GetTeam() != 2) continue
				if (NetProps.GetPropInt(player, "m_lifeState") != 0) continue

				player.Teleport(true, Vector(900, -1400, -350), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
			}

			for (local ent; ent = Entities.FindByClassname(ent, "base_boss"); )
			{
				if (Entities.FindByNameWithin(null, "blood_tank", ent.GetOrigin(), 32) != null)
				{
					ent.SetHealth(ent.GetHealth() - 99999.9)

					blood_tank.SetHealth(blood_tank.GetHealth() - 30000.0)

					blood_tank.TakeDamage(1.0, 1, blood_tank_heal_hud_update)
				}
			}
		}

		if (tick % 67 == 0)
		{
			tank_time = tank_time + 1

			if (WAVE != 3)
			{
				if (!game_over)
				{
					if (tank_blood_level <= 0)
					{
						tank_healthdrain_penalty_timer = tank_healthdrain_penalty_timer + 1
						tank_healthdrain_alarm_timer = tank_healthdrain_alarm_timer + 1

						if (tank_healthdrain_alarm_timer >= 8)
						{
							EmitGlobalSound("MVM.BombWarning")

							DeliverTipToBLU("bloodtankhealthdrainlevels", "The longer the Blood Tank runs without any blood, the more health it drains from itself.")

							tank_healthdrain_alarm_timer = 0
						}

						EntFireByHandle(tank_blood_level_hud, "AddOutput", "color 255 255 255", 0.0, null, null)
						EntFireByHandle(tank_blood_level_hud, "AddOutput", "color 255 0 0", 0.5, null, null)

						EntFireByHandle(blood_tank_minidispenser_mapobj, "Disable", null, -1.0, null, null)
					}

					else
					{
						if (tank_healthdrain_penalty_timer > 0) tank_healthdrain_penalty_timer = tank_healthdrain_penalty_timer - 1
						EntFireByHandle(blood_tank_minidispenser_mapobj, "Enable", null, -1.0, null, null)
					}

					if (tank_healthdrain_penalty_timer <= 9)                                          blood_tank_healthdrain_dmg = 1.0
					if (tank_healthdrain_penalty_timer >= 10 && tank_healthdrain_penalty_timer <= 19) blood_tank_healthdrain_dmg = 2.0
					if (tank_healthdrain_penalty_timer >= 20 && tank_healthdrain_penalty_timer <= 29) blood_tank_healthdrain_dmg = 3.0
					if (tank_healthdrain_penalty_timer >= 30 && tank_healthdrain_penalty_timer <= 39) blood_tank_healthdrain_dmg = 4.0
					if (tank_healthdrain_penalty_timer >= 40)                                         blood_tank_healthdrain_dmg = 5.0
				}
			}

			else if (extraction_mode == "blood")
			{
				EntFireByHandle(tank_blood_level_hud, "AddOutput", "color 255 255 255", 0.0, null, null)
				EntFireByHandle(tank_blood_level_hud, "AddOutput", "color 255 0 0", 0.5, null, null)
			}
		}

		if (tick % 167 == 0 && blood_tank != null) if (blood_tank.IsValid()) if (blood_tank.GetHealth() < 10000) EmitGlobalSound("mvm.cpoint_alarm")

		if (Time() >= deplete_blood_cooldown)
		{
			if (blood_tank != null && !in_cutscene)
			{
				if (blood_tank.IsValid())
				{
					if (tank_blood_level > 0 && WAVE != 3)
					{
						tank_blood_level = tank_blood_level - 3
						empty_blood_level = empty_blood_level + 3

						deplete_blood_cooldown = Time() + 2
					}

					if (extraction_mode == "blood" && WAVE == 3)
					{
						tank_blood_level = tank_blood_level + 3
						empty_blood_level = empty_blood_level - 3

						if (objective_type != null)
						{
							if (!tank_objective_explosion_imminent) tank_objective_explosion_time = tank_objective_explosion_time + 0.5
							else									tank_objective_explosion_leftovers += 0.5
						}

						// DeliverTipToBLU("refueling", "When the Blood Tank runs out of TNT, it takes a while to refuel itself. Delivering blood speeds up this process.")

						deplete_blood_cooldown = Time() + 4
					}
				}
			}
		}

		if (Time() >= extraction_cooldown)
		{
			if (blood_tank != null && !in_cutscene)
			{
				if (blood_tank.IsValid())
				{
					extraction_cooldown = Time() + 0.5

					for (local player_to_extract_from; player_to_extract_from = Entities.FindByClassnameWithin(player_to_extract_from, "player", blood_tank.GetOrigin(), 250); )
					{
						if (player_to_extract_from == null) continue;
						if (player_to_extract_from.IsFakeClient()) continue
						if (NetProps.GetPropInt(player_to_extract_from, "m_lifeState") != 0) continue

						player_to_extract_from.ValidateScriptScope()
						local scope = player_to_extract_from.GetScriptScope().bloodstorage

						if (scope.has_briefcase && objective_type == "deliver")
						{
							ObjectiveProgress()
							scope.has_briefcase = false
						}

						scope.BloodCountUpdate("transfer")

						if (current_stage > 1 && tank_blood_level > 0) DeliverTipToBLU("bloodtankisdispenser", "The Blood Tank functions as a Level 1 Dispenser while it has any amount of blood in it.")

						blu_players_near_bloodtank = blu_players_near_bloodtank + 1

						if (player_to_extract_from.GetPlayerClass() == scout || scope.is_giant_robot)
						{
							DeliverTipToBLU("scoutandtank", "While a friendly Scout or Giant Robot is close to the Blood Tank, all blood extractions happen twice as fast.")

							extraction_cooldown = Time() + 0.25
						}
					}

					// if (WAVE == 3 && blu_players_near_bloodtank >= 2) DeliverTipToBLU("multipleextractors", "The Blood Tank always loses only 1 TNT per extraction, regardless of how many players were near it at the time.")

					if (blu_players_near_bloodtank >= 2)
					{
						foreach (bluplayer in bluplayer_array)
						{
							if (bluplayer.IsFakeClient()) continue
							DeliverVisualTipToPlayer(bluplayer, "vis_grouping", "Grouping together around the Blood Tank\nwill make it give and take more resources.", true, 180.0)
						}
					}

					if (extraction_mode == "tnt" && blu_players_near_bloodtank > 0)
					{
						if (tank_tnt_level > 0) tank_tnt_level = tank_tnt_level - 3
						if (empty_tnt_level < 45) empty_tnt_level = empty_tnt_level + 3

						if (objective_type != null)
						{
							if (!tank_objective_explosion_imminent) tank_objective_explosion_time += (0.5 * blu_players_near_bloodtank)
							else									tank_objective_explosion_leftovers += (0.5 * blu_players_near_bloodtank)
						}

						EmitGlobalSound("ui/chime_rd_2base_neg.wav")
					}

					blu_players_near_bloodtank = 0

					if (WAVE == 3)
					{
						if (bombs_remaining > 0)
						{
							if (tank_tnt_level == 0 && extraction_mode == "tnt") extraction_mode = "blood"

							if (tank_blood_level == 45 && extraction_mode == "blood")
							{
								extraction_mode = "blood_heal"

								tank_blood_level = 0
								empty_blood_level = 45

								tank_tnt_level = 45
								empty_tnt_level = 0

								EmitGlobalSound("misc/cp_harbor_red_whistle.wav")

								foreach (bluplayer in bluplayer_array)
								{
									if (bluplayer.IsFakeClient()) continue

									DeliverVisualTipToPlayer(bluplayer, "vis_w3healwindow", "Bring blood to the Blood Tank while the\nwhistle is blowing to heal and speed it up")
								}

								EntFireByHandle(gamerules_entity, "RunScriptCode", "extraction_mode = `tnt`", 6.25, null, null)
							}
						}

						if (bombs_remaining == 0 || current_bombs_remaining == 0)
						{
							extraction_mode = "blood_heal"
							tnt_satisfied = true

							if (bombs_remaining == 0)
							{
								tank_tnt_level = 45
								empty_tnt_level = 0
							}

							// DeliverTipToBLU("armedallbombs", "While there are no barrels left to be filled, the Blood Tank only accepts blood, and converts any remaining TNT on all players into blood.")

							foreach (bluplayer in bluplayer_array)
							{
								if (bluplayer.IsFakeClient()) continue

								DeliverVisualTipToPlayer(bluplayer, "vis_armedallbombs", "No barrels left to fill. Bring blood to\nthe Blood Tank to heal and speed it up.")

								bluplayer.ValidateScriptScope()
								local scope = bluplayer.GetScriptScope().bloodstorage

								scope.BloodCountUpdate("tnt_cleanup")
							}

							for (local tnt; tnt = Entities.FindByName(tnt, "gray_blood_*"); ) if (tnt.GetModelName() == "models/weapons/w_models/w_cannonball.mdl") tnt.Kill()
						}
					}

					if (tank_blood_level <= 39) Entities.FindByName(null, "tank_blooddecal_1").DisableDraw()
					else						Entities.FindByName(null, "tank_blooddecal_1").EnableDraw()
					if (tank_blood_level <= 33) Entities.FindByName(null, "tank_blooddecal_2").DisableDraw()
					else						Entities.FindByName(null, "tank_blooddecal_2").EnableDraw()
					if (tank_blood_level <= 27) Entities.FindByName(null, "tank_blooddecal_3").DisableDraw()
					else						Entities.FindByName(null, "tank_blooddecal_3").EnableDraw()
					if (tank_blood_level <= 21) Entities.FindByName(null, "tank_blooddecal_4").DisableDraw()
					else						Entities.FindByName(null, "tank_blooddecal_4").EnableDraw()
					if (tank_blood_level <= 18) Entities.FindByName(null, "tank_blooddecal_5").DisableDraw()
					else						Entities.FindByName(null, "tank_blooddecal_5").EnableDraw()
					if (tank_blood_level <= 15) Entities.FindByName(null, "tank_blooddecal_6").DisableDraw()
					else						Entities.FindByName(null, "tank_blooddecal_6").EnableDraw()
					if (tank_blood_level <= 12) Entities.FindByName(null, "tank_blooddecal_7").DisableDraw()
					else						Entities.FindByName(null, "tank_blooddecal_7").EnableDraw()
					if (tank_blood_level <= 9)  Entities.FindByName(null, "tank_blooddecal_8").DisableDraw()
					else						Entities.FindByName(null, "tank_blooddecal_8").EnableDraw()
					if (tank_blood_level <= 6)  Entities.FindByName(null, "tank_blooddecal_9").DisableDraw()
					else						Entities.FindByName(null, "tank_blooddecal_9").EnableDraw()

					if (WAVE != 3) NetProps.SetPropString(tank_blood_level_hud, "m_iszMessage", "" + fullbar.slice(0, 45 - empty_blood_level) + emptybar.slice(0, 45 - tank_blood_level))
					else
					{
						if (extraction_mode == "tnt") NetProps.SetPropString(tank_blood_level_hud, "m_iszMessage", "" + fullbar.slice(0, 45 - empty_tnt_level) + emptybar.slice(0, 45 - tank_tnt_level))
						if (extraction_mode == "blood") NetProps.SetPropString(tank_blood_level_hud, "m_iszMessage", "" + fullbar.slice(0, 45 - empty_blood_level) + emptybar.slice(0, 45 - tank_blood_level))
						if (extraction_mode == "blood_heal")
						{
							if (tank_tnt_level > 0 && tank_blood_level == 0) NetProps.SetPropString(tank_blood_level_hud, "m_iszMessage", "" + fullbar.slice(0, 45 - empty_tnt_level) + emptybar.slice(0, 45 - tank_tnt_level))
							if (tank_tnt_level == 0 && tank_blood_level > 0) NetProps.SetPropString(tank_blood_level_hud, "m_iszMessage", "" + fullbar.slice(0, 45 - empty_blood_level) + emptybar.slice(0, 45 - tank_blood_level))
						}
					}
				}
			}
		}

		if (Time() >= bloodbot_dispatchtime)
		{
			DispatchBloodBot()
			bloodbot_dispatchtime = Time() + RandomFloat(next_bloodbot_dispatchtime_min, next_bloodbot_dispatchtime_max)
		}

		tick++

		return -1
	}

	ObjectiveStatus_Think = function()
	{
		if (objective_type == "capture")
		{
			for (local ent; ent = Entities.FindByClassname(ent, "trigger_capture_area"); )
			{
				if (ent.GetName() == "control_point_1_trigger")
				{
					if (obj_control_a_captured)
					{
						if (NetProps.GetPropEntity(ent, "m_hFilter") != red_filter)
						{
							NetProps.SetPropEntity(ent, "m_hFilter", red_filter)
							NetProps.SetPropFloat(ent, "m_flCapTime", obj_control_redcapture_rate)

							// EntFireByHandle(ent, "Disable", null, -1.0, null, null)
							// EntFireByHandle(ent, "Enable", null, 0.03, null, null)
						}
					}

					else
					{
						if (NetProps.GetPropEntity(ent, "m_hFilter") != null)
						{
							NetProps.SetPropEntity(ent, "m_hFilter", null)
							NetProps.SetPropFloat(ent, "m_flCapTime", obj_control_blucapture_rate)
						}
					}
				}

				if (ent.GetName() == "control_point_2_trigger")
				{
					if (obj_control_b_captured)
					{
						if (NetProps.GetPropEntity(ent, "m_hFilter") != red_filter)
						{
							NetProps.SetPropEntity(ent, "m_hFilter", red_filter)
							NetProps.SetPropFloat(ent, "m_flCapTime", obj_control_redcapture_rate)

							// EntFireByHandle(ent, "Disable", null, -1.0, null, null)
							// EntFireByHandle(ent, "Enable", null, 0.03, null, null)
						}
					}
					else
					{
						if (NetProps.GetPropEntity(ent, "m_hFilter") != null)
						{
							NetProps.SetPropEntity(ent, "m_hFilter", null)
							NetProps.SetPropFloat(ent, "m_flCapTime", obj_control_blucapture_rate)
						}
					}
				}

				if (ent.GetName() == "control_point_3_trigger")
				{
					if (obj_control_c_captured)
					{
						if (NetProps.GetPropEntity(ent, "m_hFilter") != red_filter)
						{
							NetProps.SetPropEntity(ent, "m_hFilter", red_filter)
							NetProps.SetPropFloat(ent, "m_flCapTime", obj_control_redcapture_rate)

							// EntFireByHandle(ent, "Disable", null, -1.0, null, null)
							// EntFireByHandle(ent, "Enable", null, 0.03, null, null)
						}
					}
					else
					{
						if (NetProps.GetPropEntity(ent, "m_hFilter") != null)
						{
							NetProps.SetPropEntity(ent, "m_hFilter", null)
							NetProps.SetPropFloat(ent, "m_flCapTime", obj_control_blucapture_rate)
						}
					}
				}
			}
		}

		if (objectives_reached < objective_amount)
		{
			switch (objective_type)
			{
				case "destroy": 		ClientPrint(null,4,"Destroy Blood-Bots: " + objectives_reached + "/" + objective_amount); break
				case "hunt":			ClientPrint(null,4,"Destroy target robots: " + objectives_reached + "/" + objective_amount); break
				case "supply":			ClientPrint(null,4,"Supply targets with blood: " + objectives_reached + "/" + objective_amount); break
				case "escort":			ClientPrint(null,4,"Guide the robot to the Blood Tank"); break
				case "push":			ClientPrint(null,4,"Push the bomb cart to its destination"); break
				case "capture":			ClientPrint(null,4,"Capture and hold all Control Points (" + obj_control_holdtime + ")"); break
				case "free":			ClientPrint(null,4,"Break the robot free from the block of ice"); break
				case "end":				ClientPrint(null,4,"" + obj_end_text); break
			}

			// deliver briefcases is in player class
		}

		else
		{
			Objective_Success()
			self.Kill()
		}

		return
	}

	briefcase_locations =
	[
		Vector(4300, -1500, -128),
		Vector(5400, 200, -128),
		Vector(4100, 1400, -128),
		Vector(2400, -1400, -448),
		Vector(3400, -600, -448),
		Vector(400, -1500, -352),
		Vector(0, 100, -416),
		Vector(700, 400, -416),
		Vector(-650, 600, -422),
		Vector(2300, 600, -64)
	]

	ObjectiveDeliver_Think = function()
	{
		try { self }
		catch (e) { return -1 }

		briefcases_active = 0

		if (objective_type != "deliver")
		{
			self.Kill()
			return
		}

		for (local briefcase; briefcase = Entities.FindByName(briefcase, "briefcase_pickup*"); ) briefcases_active = briefcases_active + 1

		if (briefcases_active > 8) return 5

		local pick = RandomInt(0, briefcase_locations.len() - 1)

		local x = briefcase_locations[pick].x
		local y = briefcase_locations[pick].y
		local z = briefcase_locations[pick].z

		local briefcase_pickup = SpawnEntityFromTable("prop_dynamic",
		{
			targetname              = "briefcase_pickup" + briefcases_spawned
			origin                  = Vector(x, y, z)
			model                   = "models/flag/briefcase.mdl"
		})

		local briefcase_glow = SpawnEntityFromTable("tf_glow",
		{
			targetname            = "briefcase_glow" + briefcases_spawned
			origin                = Vector(x, y, z)
			target           	  = "briefcase_pickup" + briefcases_spawned
			GlowColor             = "153 194 216 255"
		})

		EntFire("briefcase_glow" + briefcases_spawned, "SetParent", "!activator", -1.0, briefcase_pickup)

		AddThinkToEnt(briefcase_pickup, "Briefcase_Pickups_Think")

		SendGlobalGameEvent("show_annotation",
		{
			id = 10 + briefcase_pickup.GetName().slice(16)
			text = "Briefcase"
			follow_entindex = briefcase_pickup.entindex()
			play_sound = "misc/null.wav"
			show_distance = true
			show_effect = false
			lifetime = 3600
		})

		briefcase_locations.remove(pick)

		briefcases_spawned = briefcases_spawned + 1

		if (briefcases_spawned <= 3) return -1
		else return 10
	}

	ObjectiveCapture_Think = function()
	{
		if (obj_control_a_captured && obj_control_b_captured && obj_control_c_captured)
		{
			if (obj_control_holdtime == obj_control_timer_start) obj_control_holdtime = "0:09"
			else
			{
				obj_control_digit = obj_control_digit - 1
				obj_control_holdtime = "0:0" + obj_control_digit.tostring()
			}

		}

		if (obj_control_digit > 0) return 1

		else
		{
			ObjectiveProgress()
			self.Kill()
			return
		}
	}

	ObjectivePush_Think = function()
	{
		bombcart <- Entities.FindByName(null, "bombcart")

		if (bombcart == null) return

		is_blu_player_near_bombcart = false

		for (local bluplayer; bluplayer = Entities.FindByClassnameWithin(bluplayer, "player", bombcart.GetOrigin(), 200); )
		{
			if (bluplayer == null) continue
			if (NetProps.GetPropInt(bluplayer, "m_lifeState") != 0) continue
			if (bluplayer.GetTeam() != 3) continue

			is_blu_player_near_bombcart = true
			break
		}

		if (tank_blood_level <= 0 && !is_blu_player_near_bombcart)  EntFire("bombcart_train", "StartBackward")
		if (tank_blood_level <= 0 && is_blu_player_near_bombcart)	EntFire("bombcart_train", "Stop")

		if (tank_blood_level > 0 && !is_blu_player_near_bombcart)	EntFire("bombcart_train", "Stop")
		if (tank_blood_level > 0 && is_blu_player_near_bombcart)	EntFire("bombcart_train", "StartForward")

		if (bombcart.GetOrigin().x < 2300.0) bombcart_explosion_tick = bombcart_explosion_tick + 1

		else if (bombcart_explosion_tick > 0) bombcart_explosion_tick = bombcart_explosion_tick - 1

		if (bombcart.GetOrigin().x < 2300.0 && bombcart_explosion_tick >= 5)
		{
			EntFire("bots_win", "RoundWin")
			EntFire("hatch_explo_kill_players", "Enable", null, -1.0)
			EntFire("hatch_magnet_pit", "Enable", null, -1.0)
			EntFire("pit_explosion_wav", "PlaySound", null, -1.0)
			EntFire("end_pit_destroy_particle", "Start", null, -1.0)
			EntFire("trigger_hurt_hatch_fire", "Enable", null, -1.0)

			EntFire("hatch_explo_kill_players", "Disable", null, 0.5)

			for (local ent; ent = Entities.FindByName(ent, "w2_hatch_explosive"); ) ent.Kill()

			Entities.FindByName(null, "bombcart_bomb").Kill()

			self.Kill()
			return
		}

		if (bombcart_explosion_tick > 0)
		{
			EmitSoundEx({sound_name = "misc/rd_finale_beep01.wav", channel = 6, pitch = 95 + bombcart_explosion_tick * 5, filter_type = 5})
			EmitSoundEx({sound_name = "misc/rd_finale_beep01.wav", channel = 6, pitch = 95 + bombcart_explosion_tick * 5, filter_type = 5})
		}

		return 0.5
	}

	BloodBot_EmitSounds_Think = function()
	{
		(RandomInt(1, 2) == 1) ? self.EmitSound("Robot.Collide") : self.EmitSound("Robot.Greeting")

		for (local player; player = Entities.FindByClassnameWithin(player, "player", self.GetOrigin(), 500); )
		{
			if (player == null) continue
			if (player.IsFakeClient()) continue
			if (bluplayer_array.find(player) == null) continue

			local scope = player.GetScriptScope().bloodstorage

			if (scope.bloodbots_destroyed < 10) { if (DeliverVisualTipToPlayer(player, "vis_destroybloodbots", "Destroy Blood-Bots\nto get extra blood", true, 60.0)) HighlightBloodBots() }
		}

		return RandomFloat(2.5, 7.5)
	}

	Clamp = function(val, minVal, maxVal)
	{
		if (maxVal < minVal)   return maxVal
		else if (val < minVal) return minVal
		else if (val > maxVal) return maxVal
		else 				   return val
	}

	RemapValClamped = function(val, A, B, C, D)
	{
		if (A == B) return ((val >= B) ? D : C)

		local cVal = (val - A) / (B - A)

		cVal = Clamp(cVal, 0.0, 1.0)

		return (C + (D - C) * cVal)
	}

	BloodBot_Pickups_Think = function()
	{
		for (local player, origin = self.GetOrigin(); player = Entities.FindByClassnameWithin(player, "player", origin, 288.0); )
		{
			if (player.GetTeam() != 3) continue
			if (player.IsFakeClient()) continue
			if (NetProps.GetPropInt(player, "m_lifeState") != 0) continue

			player.ValidateScriptScope()
			local scope = player.GetScriptScope().bloodstorage

			if ("blood_amount" in self.GetScriptScope() && scope.blood_count >= 99) continue

			if (player.GetPlayerClass() == scout || scope.is_giant_robot)
			{
				if (scope.scout_collection_radius < (player.GetOrigin() - self.GetOrigin()).Length() && !scope.is_giant_robot) continue

				if (player.GetPlayerClass() == scout)
				{
					local curhealth = player.GetHealth()
					local maxhealth = player.GetMaxHealth()

					local healthgain = (curhealth < maxhealth) ? 50 : 25

					if (curhealth > (maxhealth * 4)) healthgain = RemapValClamped(curhealth, maxhealth, (maxhealth * 1.5), 20, 5)

					player.SetHealth(player.GetHealth() + healthgain)
				}

				player.GetScriptScope().valid_for_pickup <- true
			}

			else if ((player.GetOrigin() - self.GetOrigin()).Length() <= 72.0) player.GetScriptScope().valid_for_pickup <- true

			if ("valid_for_pickup" in player.GetScriptScope())
			{
				EmitGlobalSound("ui/item_as_parasite_drop.wav")

				if (self.GetScriptScope().poisoned)
				{
					if (self.GetScriptScope().blood_amount > 1) { for (local i = 1; i <= self.GetScriptScope().blood_amount; i++) scope.BloodCountUpdate("gain") }

					scope.BloodCountUpdate("double")
				}

				else
				{
					if ("blood_amount" in self.GetScriptScope()) for (local i = 1; i <= self.GetScriptScope().blood_amount; i++) scope.BloodCountUpdate("gain")
					if ("tnt_amount" in self.GetScriptScope()) for (local i = 1; i <= self.GetScriptScope().tnt_amount; i++) scope.BloodCountUpdate("gain", "tnt")
				}

				delete player.GetScriptScope().valid_for_pickup

				self.Kill(); return 1
			}
		}

		if (self.GetScriptScope().expired)
		{
			DispatchParticleEffect("mvm_cash_explosion", self.GetOrigin(), self.GetAngles())
			self.Kill()
			return 1
		}

		if (tick % 17 == 0 && self.GetScriptScope().blinking)
		{
			if (NetProps.GetPropInt(self, "m_nRenderMode") == 0) NetProps.SetPropInt(self, "m_nRenderMode", 1)
			else 												 NetProps.SetPropInt(self, "m_nRenderMode", 0)
		}

		return -1
	}

	Briefcase_Pickups_Think = function()
	{
		self.SetAbsAngles(self.GetAngles() + QAngle(0, 1, 0))

		for (local player; player = Entities.FindByClassnameWithin(player, "player", self.GetOrigin(), 72.0); )
		{
			if (player.GetTeam() != 3) continue
			if (player.IsFakeClient()) continue

			local scope = player.GetScriptScope().bloodstorage

			if (scope.has_briefcase) continue
			else
			{
				scope.has_briefcase = true

				SendGlobalGameEvent("hide_annotation", { id = 10 + self.GetName().slice(16) })

				briefcase_locations.append(self.GetOrigin())

				NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")

				self.Kill()

				break
			}
		}

		return -1
	}

	ObjectiveSupply_ExtractBlood_Think = function()
	{
		local scope = self.GetScriptScope()

		if (!("spawned" in scope))
		{
			scope.spawned <- true
			scope.blood_required <- 8

			scope.blood_counter <- SpawnEntityFromTable("point_worldtext",
			{
				textsize       = 40
				message        = "8"
				font           = 1
				orientation    = 1
				textspacingx   = 1
				textspacingy   = 1
				spawnflags     = 0
				origin         = self.GetOrigin() + Vector(0, 0, 100)
				rendermode     = 3
			})

			scope.self_glow <- SpawnEntityFromTable("tf_glow",
			{
				target           	  = self.GetName()
				GlowColor             = "191 255 0 255"
			})

			AddThinkToEnt(scope.self_glow, "ObjectiveBlink_Think")

			EntFireByHandle(scope.blood_counter, "SetParent", "!activator", 0.25, self, null)
			EntFireByHandle(scope.self_glow, "SetParent", "!activator", -1.0, self, null)
		}

		scope.cooldown <- 0.5

		for (local player_to_extract_from; player_to_extract_from = Entities.FindByClassnameWithin(player_to_extract_from, "player", self.GetOrigin(), 150); )
		{
			if (player_to_extract_from == null) continue;
			if (player_to_extract_from.IsFakeClient()) continue
			if (player_to_extract_from.GetTeam() != 3) continue

			player_to_extract_from.ValidateScriptScope()
			local player_scope = player_to_extract_from.GetScriptScope().bloodstorage

			if (player_scope.blood_count <= 0) continue

			if (scope.blood_required > 0)
			{
				player_scope.BloodCountUpdate("supply")
				scope.blood_required = scope.blood_required - 1
			}

			scope.blood_counter.KeyValueFromString("message", scope.blood_required.tostring())

			if (player_to_extract_from.GetPlayerClass() == scout || player_scope.is_giant_robot) scope.cooldown = 0.25
		}

		if (scope.blood_required == 0 && "self_glow" in scope)
		{
			scope.blood_counter.KeyValueFromString("color", "0 128 0 255")

			scope.self_glow.Kill()

			EntFire("!self", "RemoveHealth", "9999", 3.0)

			ObjectiveProgress()

			delete scope.self_glow
		}

		return scope.cooldown
	}

	EscortPoint_Think = function()
	{
		for (local escort_robot; escort_robot = Entities.FindByClassnameWithin(escort_robot, "player", self.GetOrigin(), 250); )
		{
			if (escort_robot == null) continue;
			if (!escort_robot.IsFakeClient()) continue;
			if (NetProps.GetPropInt(escort_robot, "m_lifeState") != 0) continue

			if (escort_robot.HasBotTag("escortbot"))
			{
				escortbot_reached_destination = true
				ObjectiveProgress()
				escort_robot.TakeDamage(10000.0, 64, null)
				self.Kill()
				return 1
			}
		}

		return
	}

	Stage1_RiseBlockade_Think = function()
	{
		stage1_blockade_center.SetOrigin(stage1_blockade_center.GetOrigin() + Vector(0, 0, 0.8))
		stage1_blockade_right.SetOrigin(stage1_blockade_right.GetOrigin() + Vector(0, 0, 0.8))
		stage1_blockade_left.SetOrigin(stage1_blockade_left.GetOrigin() + Vector(0, 0, 0.8))

		if (stage1_blockade_center.GetOrigin().z > 0)
		{
			stage1_blockade_center.Kill()
			stage1_blockade_right.Kill()
			stage1_blockade_left.Kill()
			self.Kill()
		}

		return -1
	}

	EscortBot_Think = function()
	{
		if (NetProps.GetPropInt(self, "m_lifeState") != 0)
		{
			NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
			return
		}

		local scope = self.GetScriptScope()

		if (!("spawned" in scope))
		{
			scope.spawned <- true

			self.KeyValueFromString("targetname", "glow_target")

			scope.selfglow <- SpawnEntityFromTable("tf_glow",
			{
				target           	  = "glow_target"
				origin				  = self.EyePosition()
				GlowColor             = "0 255 0 255"
			})

			self.KeyValueFromString("targetname", "")

			EntFireByHandle(scope.selfglow, "SetParent", "!activator", -1.0, self, null) // parenting a tf_glow fixes issues where it doesn't render if it's too far from you

			SendGlobalGameEvent("show_annotation",
			{
				id = scope.selfglow.entindex()
				text = "Guide"
				follow_entindex = scope.selfglow.entindex()
				play_sound = "misc/null.wav"
				show_distance = true
				show_effect = true
				lifetime = -1
			})

			AddThinkToEnt(scope.selfglow, "ObjectiveBlink_Think")
		}

		for (local blu_player; blu_player = Entities.FindByClassnameWithin(blu_player, "player", self.GetOrigin(), 250); )
		{
			if (blu_player == null) continue
			if (blu_player.IsFakeClient()) continue

			if (NetProps.GetPropInt(blu_player, "m_lifeState") != 0) continue

			is_blu_player_near_escortbot = true
		}

		if (is_blu_player_near_escortbot)
		{
			self.SetMoveType(2, 0)
			if (RandomInt(1, 100) == 1) self.PlayScene("scenes/Player/Scout/low/435.vcd", -1.0)
		}

		else self.SetMoveType(0, 0)

		is_blu_player_near_escortbot = false

		return 0.1
	}

	SniperRifleLaser_Think = function() // huge credit goes to royall for finding this out
	{
		local scope

		try { scope = self.GetScriptScope() }
		catch (e) { return }

		local weaponowner = NetProps.GetPropEntity(self, "m_hOwner")

		if (!("laser" in scope))
		{
			scope.laser <- SpawnEntityFromTable("info_particle_system",
			{
				targetname = "sniperrifle_laser"
				effect_name = "laser_sight_beam"
				start_active = 1
				flag_as_weather = 0
			})

			scope.pointer <- SpawnEntityFromTable("info_particle_system",
			{
				targetname = "sniperrifle_laserpointer"
				effect_name = "laser_sight_beam"
			})

			scope.color <- SpawnEntityFromTable("info_particle_system",
			{
				targetname = "sniperrifle_lasercolor"
				effect_name = "laser_sight_beam"
			})

			scope.color.SetAbsOrigin(Vector(255, 0, 0))

			NetProps.SetPropEntityArray(scope.laser, "m_hControlPointEnts", scope.pointer, 0)
			NetProps.SetPropEntityArray(scope.laser, "m_hControlPointEnts", scope.color, 1)

			scope.laser.SetOwner(weaponowner)
			scope.pointer.SetOwner(weaponowner)
			scope.color.SetOwner(weaponowner)

			NetProps.SetPropString(scope.laser, "m_iClassname", "env_sprite")
			NetProps.SetPropString(scope.pointer, "m_iClassname", "env_sprite")
		}

		if (weaponowner.InCond(1))
		{
			local tracetable =
			{
				start = weaponowner.EyePosition(),
				end = weaponowner.EyePosition() + (weaponowner.EyeAngles().Forward() * 32768.0)
				ignore = weaponowner
			}

			TraceLineEx(tracetable)

			if (!tracetable.hit) return

			scope.laser.SetAbsOrigin(weaponowner.EyePosition())
			scope.pointer.SetAbsOrigin(tracetable.pos)

			EntFireByHandle(scope.laser, "Start", null, -1, null, null)
		}

		else
		{
			EntFireByHandle(scope.laser, "Stop", null, -1, null, null)
			scope.laser.SetAbsOrigin(scope.pointer.GetOrigin())
		}
	}

	BombRunner_Think = function()
	{
		if (blood_tank == null) return

		local scope = self.GetScriptScope()

		foreach (bluplayer in bluplayer_array)
		{
			if (bluplayer.IsFakeClient()) continue

			DeliverVisualTipToPlayer(bluplayer, "vis_bombbots", "Bomb bots deal heavy damage to the\nBlood Tank when they get close!")
		}

		if (!("spawn_alert" in scope))
		{
			scope.spawn_alert <- true
			scope.default_model <- self.GetModelName()

			GetWearable("models/bots/gameplay_cosmetic/bot_light_bomb_helmet.mdl")

			EmitGlobalSound("ui/rd_2base_alarm.wav")

			self.KeyValueFromString("targetname", "glow_target")

			scope.bombglow <- SpawnEntityFromTable("tf_glow",
			{
				origin 				  = self.EyePosition()
				targetname            = "bombglow_" + self
				target           	  = "glow_target"
				GlowColor             = "255 255 0 255"
			})

			self.KeyValueFromString("targetname", "")

			EntFireByHandle(scope.bombglow, "SetParent", "!activator", -1.0, self, null) // parenting a tf_glow fixes issues where it doesn't render if it's too far from you

			AddThinkToEnt(scope.bombglow, "DangerBlink_Think")

			SendGlobalGameEvent("show_annotation",
			{
				id = scope.bombglow.entindex()
				text = "Destroy"
				follow_entindex = scope.bombglow.entindex()
				play_sound = "misc/null.wav"
				show_distance = true
				show_effect = false
				lifetime = -1
			})
		}

		if (!self.IsTaunting())
		{
			if ("deploy_dummy" in scope)
			{
				scope.deploy_dummy.Kill()

				delete scope.deploy_dummy
				delete scope.deploy_dummy_glow
				delete scope.deploy_dummy_ornament_1
				delete scope.deploy_dummy_ornament_2

				if ("deploy_dummy_ornament_3" in scope) delete scope.deploy_dummy_ornament_3
			}

			if (self.GetModelName() != scope.default_model)
			{
				self.SetCustomModelWithClassAnimations(scope.default_model)
				self.SetCustomModelOffset(Vector(0, 0, 0))
			}
		}

		else
		{
			if (!("deploy_dummy" in scope))
			{
				scope.deploy_dummy <- SpawnEntityFromTable("prop_dynamic",
				{
					targetname              = "deploy_dummy_" + self
					origin                  = self.GetOrigin()
					model                   = self.GetModelName()
					DefaultAnim             = "melee_deploybomb"
					modelscale              = 1.75
				})

				scope.deploy_dummy_ornament_1 <- SpawnEntityFromTable("prop_dynamic_ornament",
				{
					model                   = (scope.default_model == "models/bots/scout_boss/bot_scout_boss.mdl") ? "models/workshop/player/items/scout/bonk_mask/bonk_mask.mdl" : "models/player/items/heavy/pugilist_protector.mdl"
					disablebonefollowers	= 1
					disableshadows			= 1
					initialowner			= "deploy_dummy_" + self
				})

				scope.deploy_dummy_ornament_2 <- SpawnEntityFromTable("prop_dynamic_ornament",
				{
					model                   = "models/bots/gameplay_cosmetic/bot_light_bomb_helmet.mdl"
					disablebonefollowers	= 1
					disableshadows			= 1
					initialowner			= "deploy_dummy_" + self
				})

				if (scope.default_model == "models/bots/heavy_boss/bot_heavy_boss.mdl")
				{
					scope.deploy_dummy_ornament_3 <- SpawnEntityFromTable("prop_dynamic_ornament",
					{
						model                   = "models/weapons/c_models/c_boxing_gloves/c_boxing_gloves.mdl"
						disablebonefollowers	= 1
						disableshadows			= 1
						initialowner			= "deploy_dummy_" + self
					})
				}

				scope.deploy_dummy_glow <- SpawnEntityFromTable("tf_glow",
				{
					targetname            = "deploy_dummy_glow_" + self
					target           	  = "deploy_dummy_" + self
					GlowColor             = "255 255 0 255"
				})

				EntFireByHandle(scope.deploy_dummy_glow, "SetParent", "!activator", -1.0, scope.deploy_dummy, null)

				AddThinkToEnt(scope.deploy_dummy_glow, "DangerBlink_Think")

				EmitGlobalSound("mvm/mvm_deploy_giant.wav")

				self.SetCustomModel("models/empty.mdl")
				self.SetCustomModelOffset(Vector(0, 0, -500))
			}

			if ("deploy_dummy" in scope)
			{
				if (scope.deploy_dummy.GetCycle() > 0.4)
				{
					EmitGlobalSound("mvm/mvm_bomb_explode.wav")

					DispatchParticleEffect("fireSmoke_Collumn_mvmAcres", blood_tank.GetOrigin(), Vector(0, 90, 0))

					blood_tank.TakeDamage(10000.0, 1, blood_tank_heal_hud_update)

					self.RemoveCondEx(52, true)

					self.TakeDamage(10000.0, 64, null)

					foreach (bluplayer in bluplayer_array)
					{
						local player_scope = bluplayer.GetScriptScope().bloodstorage

						player_scope.tip_table["vis_bombbots"] = false
					}
				}
			}
		}

		if (Entities.FindByNameWithin(null, "blood_tank", self.GetOrigin(), 200.0) != null) self.Taunt(1, 91)

		// DeliverTipToBLU("bombrunners", "Certain enemies spawn with bombs that do massive damage to the Blood Tank. Their presence is indicated by a flashing yellow-red outline.")

		return -1
	}

	DangerBlink_Think = function()
	{
		EntFireByHandle(self, "SetGlowColor", "255 255 0 255", 0.0, null, null)
		EntFireByHandle(self, "SetGlowColor", "184 56 59 255", 0.5, null, null)

		return 1
	}

	ObjectiveBlink_Think = function()
	{
		EntFireByHandle(self, "SetGlowColor", "0 255 0 255", 0.0, null, null)
		EntFireByHandle(self, "SetGlowColor", "153 194 216 255", 0.5, null, null)

		return 1
	}

	BloodBlink_Think = function()
	{
		EntFireByHandle(self, "SetGlowColor", "255 255 0 255", 0.0, null, null)
		EntFireByHandle(self, "SetGlowColor", "153 194 216 255", 0.5, null, null)

		return 1
	}

	TankProximity_Think = function()
	{
		local owner = NetProps.GetPropEntity(self, "m_hTarget")

		if (Entities.FindByNameWithin(null, "blood_tank", owner.GetOrigin(), 500.0) == null) EntFireByHandle(self, "Disable", null, -1.0, null, null)
		else																				 EntFireByHandle(self, "Enable", null, -1.0, null, null)

		return 1
	}

	///////////////////////////////////////////////////////////////////////////// THINK CONTROLLER /////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	DispatchBloodBot = function()
	{
		if (bloodbots_alive >= max_bloodbot_count || in_endgame || WAVE > 3 || current_stage > 3) return

		bloodbots_spawned = bloodbots_spawned + 1
		if (draw_debugchat) ClientPrint(null,3,"dispatched")

		local bloodbot_number = bloodbots_spawned

		local group_pick = null

		switch (current_stage)
		{
			case 1: group_pick = 1; break 				  // 100% stage 1 bots
			case 2: group_pick = RandomInt(1, 5); break   // 80% stage 2 bots, 20% stage 1 bots
			case 3: group_pick = RandomInt(1, 10); break  // 50% stage 3 bots, 40% stage 2 bots, 10% stage 1 bots
		}

		local path_a_pick = RandomInt(0, bloodbot_path_p1.len() - 1)
		local path_b_pick = RandomInt(0, bloodbot_path_p2.len() - 1)
		local path_c_pick = RandomInt(0, bloodbot_path_p3.len() - 1)

		local bloodbot_path_group_name_picker =
		{
			[1] = bloodbot_path_p1_name_picker[path_a_pick],
			[2] = bloodbot_path_p2_name_picker[path_b_pick], [3] = bloodbot_path_p2_name_picker[path_b_pick], [4] = bloodbot_path_p2_name_picker[path_b_pick], [5] = bloodbot_path_p2_name_picker[path_b_pick],
			[6] = bloodbot_path_p3_name_picker[path_c_pick], [7] = bloodbot_path_p3_name_picker[path_c_pick], [8] = bloodbot_path_p3_name_picker[path_c_pick], [9] = bloodbot_path_p3_name_picker[path_c_pick], [10] = bloodbot_path_p3_name_picker[path_c_pick]
		}

		local bloodbot_path_group_origin_picker =
		{
			[1] = bloodbot_path_p1_origin_picker[path_a_pick],
			[2] = bloodbot_path_p2_origin_picker[path_b_pick], [3] = bloodbot_path_p2_origin_picker[path_b_pick], [4] = bloodbot_path_p2_origin_picker[path_b_pick], [5] = bloodbot_path_p2_origin_picker[path_b_pick],
			[6] = bloodbot_path_p3_origin_picker[path_c_pick], [7] = bloodbot_path_p3_origin_picker[path_c_pick], [8] = bloodbot_path_p3_origin_picker[path_c_pick], [9] = bloodbot_path_p3_origin_picker[path_c_pick], [10] = bloodbot_path_p3_origin_picker[path_c_pick]
		}

		local directionchoice = RandomInt(1, 2)

		SpawnEntityGroupFromTable(
		{
			S1 =
			{
				func_tracktrain =
				{
					targetname              = "bloodbot_path_train_" + bloodbot_number
					target                  = bloodbot_path_group_name_picker[group_pick]
					startspeed              = bloodbot_path_speed
					speed                   = bloodbot_path_speed
					origin                  = bloodbot_path_group_origin_picker[group_pick]
					orientationtype         = 3
				}
			}
			S2 =
			{
				obj_dispenser =
				{
					targetname              = "bloodbot_robot_" + bloodbot_number
					parentname				= "bloodbot_path_train_" + bloodbot_number
					origin 		            = bloodbot_path_group_origin_picker[group_pick]
					teamnum                 = 2
					SolidToPlayer           = 0
				}
			}
		})

		local bloodbot_path_train = Entities.FindByName(null, "bloodbot_path_train_" + bloodbot_number)
		local bloodbot_robot = Entities.FindByName(null, "bloodbot_robot_" + bloodbot_number)

		for (local vgui_to_kill; vgui_to_kill = Entities.FindInSphere(vgui_to_kill, bloodbot_path_train.GetOrigin(), 32); ) if (vgui_to_kill.GetClassname() == "vgui_screen") vgui_to_kill.Kill()

		EntityOutputs.AddOutput(bloodbot_robot, "OnDestroyed", "bloodbot_path_train_" + bloodbot_number, "Kill", null, -1.0, -1)

		if (group_pick == 1)
		{
			bloodbot_robot.SetModel("models/bots/bot_worker/bot_worker.mdl")
			EntFire("bloodbot_robot_" + bloodbot_number, "SetHealth", 100)

			EntityOutputs.AddOutput(bloodbot_robot, "OnDestroyed", "bloodbot_path_train_" + bloodbot_number, "RunScriptCode", "SpawnGrayBlood(self.GetOrigin(), `bloodbot`)", -1.0, -1)
		}
		if (group_pick >= 2 && group_pick <= 5)
		{
			bloodbot_robot.SetModel("models/bots/bot_worker/bot_worker2.mdl")
			EntFire("bloodbot_robot_" + bloodbot_number, "SetHealth", 200)

			EntityOutputs.AddOutput(bloodbot_robot, "OnDestroyed", "bloodbot_path_train_" + bloodbot_number, "RunScriptCode", "SpawnGrayBlood(self.GetOrigin(), `bloodbot`, 3)", -1.0, -1)
		}
		if (group_pick >= 6 && group_pick <= 10)
		{
			bloodbot_robot.SetModel("models/bots/bot_worker/bot_worker3.mdl")
			EntFire("bloodbot_robot_" + bloodbot_number, "SetHealth", 300)

			EntityOutputs.AddOutput(bloodbot_robot, "OnDestroyed", "bloodbot_path_train_" + bloodbot_number, "RunScriptCode", "SpawnGrayBlood(self.GetOrigin(), `bloodbot`, 5)", -1.0, -1)
		}

		bloodbot_path_train.SetSolidFlags(4)

		AddThinkToEnt(bloodbot_robot, "BloodBot_EmitSounds_Think")

		bloodbots_alive = bloodbots_alive + 1.0

		next_bloodbot_dispatchtime_min = 6.0 + (bloodbots_alive * 0.8)
		next_bloodbot_dispatchtime_max = 10.0 + (bloodbots_alive * 0.8)

		// if (bloodbot_number >= 3) DeliverTipToBLU("bloodbots", "Blood-Bots are mobile blood dispensers. Destroy them to gain extra blood to give to the Blood Tank.")
		if (current_stage > 1) DeliverTipToBLU("betterbloodbots", "Blood-Bots become more durable and profitable as the Blood Tank advances further into the enemy base.")
	}

	ReverseBloodBot = function() { if (RandomInt(1, 20) == 1) EntFireByHandle(self, "Reverse", null, -1.0, null, null) } // 5% chance for bloodbot to reverse direction when crossing a node

	HighlightBloodBots = function()
	{
		if (Time() < bloodbot_highlight_cooldown) return

		for (local ent; ent = Entities.FindByName(ent, "bloodbot_robot_*"); )
		{
			local namebefore = ent.GetName()
			local unique_id = UniqueString()

			ent.KeyValueFromString("targetname", unique_id)

			local glow = SpawnEntityFromTable("tf_glow",
			{
				target           	  = unique_id
				GlowColor             = "255 255 0 255"
			})

			ent.KeyValueFromString("targetname", namebefore)

			EntFireByHandle(glow, "SetParent", "!activator", -1.0, ent, null)

			AddThinkToEnt(glow, "TutorialBlink_Think")
		}

		bloodbot_highlight_cooldown = Time() + 10
	}

	SpawnGrayBlood = function(where, dropper, amount = 1, poisoned = false, is_tnt = false)
	{
		if (amount <= 0) return

		local unique_self_id = UniqueString()

		local gray_blood = SpawnEntityFromTable("prop_dynamic",
		{
			targetname              = "gray_blood_" + unique_self_id
			model					= (!is_tnt) ? "models/props_halloween/flask_vial.mdl" : "models/weapons/w_models/w_cannonball.mdl"
			origin 		            = where + Vector(0, 0, 50)
		})

		if (!is_tnt)
		{
			gray_blood.SetModelScale(2.0, 0.0)

			if (!poisoned) EntFireByHandle(gray_blood, "Color", "255 0 0 5000", -1.0, null, null)
		}

		gray_blood.KeyValueFromFloat("renderamt", 25.0)

		EntFireByHandle(gray_blood, "RunScriptCode", "blinking = true", (!poisoned) ? 25.0 : 5.0, null, null)
		EntFireByHandle(gray_blood, "RunScriptCode", "expired = true", (!poisoned) ? 30.0 : 10.0, null, null)

		local vecImpulse = Vector(RandomInt(-1, 1), RandomInt(-1, 1), 1)

		vecImpulse.Norm()

		local vecVelocity = vecImpulse * 250.0

		gray_blood.SetMoveType(5, 1)
		gray_blood.SetAbsVelocity(vecVelocity)
		gray_blood.SetSolid(2)

		if (dropper != "human")
		{
			local embers = SpawnEntityFromTable("trigger_particle",
			{
				particle_name = "mvm_cash_embers_red"
				attachment_type = 1
				spawnflags = 64
			})

			NetProps.SetPropBool(embers, "m_bForcePurgeFixedupStrings", true)

			EntFireByHandle(embers, "StartTouch", "!activator", -1, gray_blood, gray_blood)
			EntFireByHandle(embers, "Kill", null, -1, null, null)

			SpawnEntityGroupFromTable(
			{
				S1 =
				{
					env_sprite =
					{
						parentname = gray_blood.GetName()
						model = "sprites/glow02.vmt"
						origin = gray_blood.GetOrigin()
						rendermode = 9
						rendercolor = (!poisoned) ? "200 30 30" : "0 75 0"
						scale = 1
					}
				}
			})
		}

		NetProps.SetPropBool(gray_blood, "m_bForcePurgeFixedupStrings", true)

		gray_blood.ValidateScriptScope()
		local scope = gray_blood.GetScriptScope()

		if (!("blinking" in scope)) scope.blinking <- false
		if (!("expired" in scope)) scope.expired <- false

		if (!is_tnt && !("blood_amount" in scope)) scope.blood_amount <- amount
		if (is_tnt && !("tnt_amount" in scope)) scope.tnt_amount <- amount

		if (!("poisoned" in scope)) scope.poisoned <- poisoned

		switch (dropper)
		{
			case "bloodbot":
			{
				bloodbots_alive = bloodbots_alive - 1.0
				if (objective_type == "destroy") ObjectiveProgress()

				if (bloodbots_alive <= 5) bloodbot_dispatchtime -= (5.0 - bloodbots_alive.tofloat())

				break
			}

			case "human":
			{
				if (amount == 1) break

				local blood_glow = SpawnEntityFromTable("tf_glow",
				{
					target           	  = "gray_blood_" + unique_self_id
					GlowColor             = "153 194 216 255"
				})

				AddThinkToEnt(blood_glow, "BloodBlink_Think")

				NetProps.SetPropBool(blood_glow, "m_bForcePurgeFixedupStrings", true)

				EntFireByHandle(blood_glow, "SetParent", "!activator", -1.0, gray_blood, null)

				break
			}
		}

		if (amount > 1)
		{
			local gray_blood_amount_text = SpawnEntityFromTable("point_worldtext",
			{
				textsize       = 12
				message        = amount.tostring()
				font           = 1
				orientation    = 1
				textspacingx   = 1
				textspacingy   = 1
				spawnflags     = 0
				origin         = gray_blood.GetOrigin() + Vector(0, 0, is_tnt ? 24 : 20)
				rendermode     = 3
			})

			NetProps.SetPropBool(gray_blood_amount_text, "m_bForcePurgeFixedupStrings", true)

			EntFireByHandle(gray_blood_amount_text, "SetParent", "!activator", -1.0, gray_blood, null)
		}

		if (poisoned)
		{
			EntFireByHandle(gray_blood, "Color", "85 107 47 5000", -1.0, null, null)

			local gray_blood_amount_poisonsign = SpawnEntityFromTable("env_sprite",
			{
				origin        = gray_blood.GetOrigin() + Vector(0, 0, 35)
				scale		  = 0.5
				rendermode    = 1
				model         = "sprites/minimap_icons/death.vmt"
			})

			NetProps.SetPropBool(gray_blood_amount_poisonsign, "m_bForcePurgeFixedupStrings", true)

			EntFireByHandle(gray_blood_amount_poisonsign, "SetParent", "!activator", -1.0, gray_blood, null)
		}

		local child_array = []

		for (local child = gray_blood.FirstMoveChild(); child != null; child = child.NextMovePeer()) child_array.append(child)

		foreach (child in child_array) NetProps.SetPropBool(child, "m_bForcePurgeFixedupStrings", true)

		AddThinkToEnt(gray_blood, "BloodBot_Pickups_Think")
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////// BLOOD STORAGE CLASS //////////////////////////////////////////////////////////////////////////////////////////////////

	BloodStorage = class
	{
		owner = null

		blood_count = 0
		excess_stage = 0
		excess_stage_progression_requirement = 0
		prev_excess_stage = 0
		excess_bounds = 0
		excess_string = ""
		blood_hud_shift_amount = 0

		giant_points = 0

		tnt_count = 0
		tnt_arm_count = 0

		poisoned = false
		poison_count = 0
		nextbleedtick = 0
		poison_sources = 0
		blood_loss_tick = 0
		blood_loss_rate = 0
		poisoned_string = ""

		hud_x = 0
		hud_color = "255 255 255"

		max_empty_bloodbar = "aaaaaaaaa"
		message_format = ""
		excess_count = 0

		prev_soundscape = null
		current_soundscape = null

		prev_groundentity = null
		current_groundentity = null

		debugkey_activated = false
		debugkey_holdtime = 0

		received_stage1_cash_reward = false
		received_stage2_cash_reward = false

		used_recall = false

		bloodbots_destroyed = 0

		scout_collection_radius = 288.0

		/////////////// OBJECTIVE VARS (DEFINITIONS)

		has_briefcase = false
		obj_deliver_time = 9999
		obj_deliver_time_string = ""
		obj_deliver_text = ""
		obj_deliver_text = ""

		pos_before_iceblock_cutscene = null

		escaped = "[X]"

		/////////////// OBJECTIVE VARS (ENTITIES)

		think_deliver = null
		think_update_deliver_time = null
		think_giant = null
		think_poison = null

		/////////////// GIANT MODE

		activationkey_holdtime = 0
		activationkey_activated = false

		is_giant_robot = false
		in_giantmode_cooldown = false

		giantpoints_drainrate = 0.33
		giantpoints_nextdraintime = 0

		/////////////// TIPS

		firsttimeplayer = true

		wants_tips = true
		desired_tip_cooldown = 15.0
		in_tip_cooldown = false

		desired_vistip_cooldown = 15.0
		in_vistip_cooldown = false

		tip_table = {}
		tips_unlocked_during_wave = []
		repeatable_tips = []

		hasyettoturngiant = true
		turngiantreminder_cooldown = 60
		was_giant_robot = false

		blood_carried_hud = null
		blood_carried_hud_2 = null
		tutorial_box = null
		audiosettings = null
		excesspenalty_stunmarker = null

		audio_preferences = []
		audio_excludelist = []
		audio_excludelist_toggledoff = false

		wants_robot_viewmodels = false

		reading_infobooth = false
		current_settings_tip = -1

		life_tick = 0

		function constructor(player)
		{
			owner = player

			InitializeBloodCounter()

			tip_table =
			{
				// howtoplay = false,
				// collectblood = false,
				// tankisoutofblood = false,
				scoutandtank = false,
				// bloodexcess = false,
				// bloodfrombloodbots = false,
				// giantpoints = false,
				aggrobots = false,
				bloodtankhealthdrainlevels = false,
				// tankhealing = false,
				// bloodbots = false,
				// bombrunners = false,
				// zombieblood = false,
				deathandblood = false,
				// barricadebombs = false,
				// newwaytoplay = false,
				nobloodexcess = false,
				// refueling = false,
				// multipleextractors = false,
				// volatilebloodtank = false,
				// armedallbombs = false,
				// voluntarygiantexit = false,
				betterbloodbots = false,
				healingbenefits = false,
				bloodtankisdispenser = false,

				vis_howtoplay = false,
				vis_collectblood = false,
				vis_collecttnt = false,
				vis_deliverblood = false,
				vis_armbarrels = false,
				vis_armallbarrels = false,
				vis_bloodconversion = false,
				vis_giantpoints = false,
				vis_giantpoints_turnback = false,
				vis_bloodexcess = false,
				vis_destroybloodbots = false,
				vis_tankhasnoblood = false,
				vis_wave3objective = false,
				vis_bombbots = false,
				vis_barricadebombs = false,
				vis_tankhealing = false,
				vis_armedallbombs = false,
				vis_bloodbotreminder = false,
				vis_w3healwindow = false,
				vis_toomanypickups = false,
				vis_zombieblood = false,
				vis_grouping = false,
				vis_recall = false
			}

			audio_preferences =
			[
				"[✔]", // bloodpickups
				"[✔]", // blooddeposits
				"[✔]", // bloodexcess
				"[✔]", // tankhealing
				"[✔]", // nobloodalarm
				"[✔]", // lowhealthalarm
				"[✔]", // objectives
				"[✔]", // turngiant
				"[✔]", // giantrobot
				"[✔]", // bombrunner
				"[✔]", // tntpickups
				"[✔]", // tntbarrels
				"[✔]", // bloodtotntend
				"[✔]" // explosions
			]

			if (!in_setup() && !game_over)
			{
				if (Entities.FindByName(null, "blood_tank") != null)
				{
					SendGlobalGameEvent("show_annotation",
					{
						id = player.entindex()
						text = "Blood Tank"
						follow_entindex = blood_tank.entindex()
						visibilityBitfield = (1 << player.entindex())
						play_sound = "misc/null.wav"
						show_distance = true
						show_effect = false
						lifetime = 3600
					})

					firsttimeplayer = false
				}
			}

			AddThinkToEnt(player, "BLUPlayer_Think")
		}

		ResetBloodCounter = function()
		{
			blood_count = 0
			excess_stage = 0
			excess_stage_progression_requirement = 0
			prev_excess_stage = 0
			excess_bounds = 0
			excess_string = ""
			blood_hud_shift_amount = 0

			tnt_count = 0

			poisoned = false
			poison_count = 0
			poison_sources = 0
			blood_loss_rate = 0
			poisoned_string = ""

			hud_x = 0
			hud_color = "255 255 255"

			max_empty_bloodbar = "aaaaaaaaa"
			message_format = ""
			excess_count = 0

			has_briefcase = false
			obj_deliver_time = 9999
			obj_deliver_time_string = ""
			obj_deliver_text = ""

			is_giant_robot = false

			in_tip_cooldown = false
			in_vistip_cooldown = false

			reading_infobooth = false
			current_settings_tip = -1

			scout_collection_radius = 288.0

			InitializeBloodCounter()

			if (NetProps.GetPropBool(excesspenalty_stunmarker, "m_bActive")) EntFireByHandle(excesspenalty_stunmarker, "Stop", null, -1.0, null, null)

			life_tick = 0
		}

		InitializeBloodCounter = function()
		{
			local tf_class = owner.GetPlayerClass()

			if (tf_class == scout)
			{
				excess_bounds = 3
				excess_stage_progression_requirement = 2
				message_format = "▯▯▯"
			}

			if (tf_class == soldier || tf_class == pyro || tf_class == demoman || tf_class == spy)
			{
				excess_bounds = 5
				excess_stage_progression_requirement = 3
				message_format = "▯▯▯▯▯"
			}

			if (tf_class == engineer || tf_class == medic || tf_class == sniper)
			{
				excess_bounds = 7
				excess_stage_progression_requirement = 4
				message_format = "▯▯▯▯▯▯▯"
			}

			if (tf_class == heavyweapons)
			{
				excess_bounds = 9
				excess_stage_progression_requirement = 5
				message_format = "▯▯▯▯▯▯▯▯▯"
			}
		}

		ResetPlayerEntities = function()
		{
			owner.GetScriptScope().blood_carried_hud <- SpawnEntityFromTable("game_text",
			{
				targetname   = "bloodhud_counter"
				channel      = 3
				color        = "255 255 255"
				effect       = 0
				fadein       = 0
				fadeout      = 0
				fxtime       = 0
				message      = "sdasdasda"
				holdtime     = 1.0
				spawnflags   = 0
				x            = 0.850
				y            = 0.714
			})

			blood_carried_hud = owner.GetScriptScope().blood_carried_hud

			owner.GetScriptScope().blood_carried_hud_2 <- SpawnEntityFromTable("game_text",
			{
				targetname   = "bloodhud_counter"
				channel      = 1
				color        = "255 255 255"
				effect       = 0
				fadein       = 0
				fadeout      = 0
				fxtime       = 0
				message      = ""
				holdtime     = 1.0
				spawnflags   = 0
				x            = 0.756
				y            = 0.677
			})

			blood_carried_hud_2 = owner.GetScriptScope().blood_carried_hud_2

			owner.GetScriptScope().tutorial_box <- SpawnEntityFromTable("prop_dynamic",
			{
				origin         = owner.EyePosition() + (owner.EyeAngles().Forward() * 400)
				model          = "models/props_hydro/barrel_crate_half.mdl"
				modelscale	   = 0.001
				rendermode	   = 1
				renderamt	   = 0
				disableshadows = 1
			})

			tutorial_box = owner.GetScriptScope().tutorial_box

			tutorial_box.AcceptInput("SetParent", "!activator", owner, owner)

			owner.GetScriptScope().audiosettings <- SpawnEntityFromTable("logic_case",
			{
				targetname              = "audiosettings_prompt"
				case16                  = "Toggle which sounds you would like to hear as you play.|0|Cancel"
				case01                  = "Toggle all"
				case02                  = "Blood pickups"
				case03                  = "Blood deposits"
				case04                  = "Blood excess warnings"
				case05                  = "Tank healing"
				case06                  = "Tank low-blood alarm"
				case07                  = "Tank low-health alarm"
				case08                  = "Objectives"
				case09					= "Turning giant"
				case10                  = "Giant robot spawns"
				case11                  = "Bomb bot spawns"
				case12                  = "TNT pickups"
				case13                  = "TNT barrel fill-ups"
				case14                  = "End of blood-to-TNT conversion"
				case15                  = "Explosions"
				OnCase01                = "!activator,RunScriptCode,AudioExcludeListControl(99),0.0,-1"
				OnCase02                = "!activator,RunScriptCode,AudioExcludeListControl(1),0.0,-1"
				OnCase03                = "!activator,RunScriptCode,AudioExcludeListControl(2),0.0,-1"
				OnCase04                = "!activator,RunScriptCode,AudioExcludeListControl(3),0.0,-1"
				OnCase05                = "!activator,RunScriptCode,AudioExcludeListControl(4),0.0,-1"
				OnCase06                = "!activator,RunScriptCode,AudioExcludeListControl(5),0.0,-1"
				OnCase07                = "!activator,RunScriptCode,AudioExcludeListControl(6),0.0,-1"
				OnCase08                = "!activator,RunScriptCode,AudioExcludeListControl(7),0.0,-1"
				OnCase09                = "!activator,RunScriptCode,AudioExcludeListControl(8),0.0,-1"
				OnCase10                = "!activator,RunScriptCode,AudioExcludeListControl(9),0.0,-1"
				OnCase11                = "!activator,RunScriptCode,AudioExcludeListControl(10),0.0,-1"
				OnCase12                = "!activator,RunScriptCode,AudioExcludeListControl(11),0.0,-1"
				OnCase13                = "!activator,RunScriptCode,AudioExcludeListControl(12),0.0,-1"
				OnCase14                = "!activator,RunScriptCode,AudioExcludeListControl(13),0.0,-1"
				OnCase15                = "!activator,RunScriptCode,AudioExcludeListControl(14),0.0,-1"
			})

			audiosettings = owner.GetScriptScope().audiosettings

			for (local i = 2; i <= 15; i++)
			{
				if (i < 10) audiosettings.KeyValueFromString("case0" + i, audio_preferences[i - 2] + " " + NetProps.GetPropString(audiosettings, "m_nCase[" + (i - 1) + "]"))
				else		audiosettings.KeyValueFromString("case" + i, audio_preferences[i - 2] + " " + NetProps.GetPropString(audiosettings, "m_nCase[" + (i - 1) + "]"))
			}

			owner.GetScriptScope().excesspenalty_stunmarker <- SpawnEntityFromTable("info_particle_system",
			{
				effect_name = "conc_stars"
				start_active = 0
				flag_as_weather = 0
			})

			excesspenalty_stunmarker = owner.GetScriptScope().excesspenalty_stunmarker

			EntFireByHandle(excesspenalty_stunmarker, "SetParent", "!activator", -1.0, owner, owner)
			EntFireByHandle(excesspenalty_stunmarker, "SetParentAttachment", "head", 0.1, owner, owner)
		}

		GlobalThinker = function()
		{
			if 		 (blood_carried_hud == null) ResetPlayerEntities()
			else if (!blood_carried_hud.IsValid()) ResetPlayerEntities()

			if (WAVE == 3)
			{
				NetProps.SetPropString(blood_carried_hud, "m_iszMessage", "" + message_format + poisoned_string)
				NetProps.SetPropString(blood_carried_hud_2  , "m_iszMessage", "   " + giant_points + hud_separate_giantpoints_from_bloodheld + "   \n" + SmallDigits(owner.GetCurrency()) + SmallDigits(blood_count, "blood") + SmallDigits(bombs_satisfied, "tnt") + "₂₀")
			}
			else
			{
				NetProps.SetPropString(blood_carried_hud, "m_iszMessage", "" + message_format + poisoned_string)
				NetProps.SetPropString(blood_carried_hud_2, "m_iszMessage", "   " + giant_points + hud_separate_giantpoints_from_bloodheld + "   \n" + SmallDigits(owner.GetCurrency()))
			}

			blood_carried_hud.KeyValueFromString("color", hud_color)

			if (!in_setup() && !in_cutscene && !in_endgame)
			{
				EntFireByHandle(blood_carried_hud, "Display", null, -1.0, owner, owner)
				EntFireByHandle(blood_carried_hud_2, "Display", null, -1.0, owner, owner)
			}

			if (Time() >= giantpoints_nextdraintime)
			{
				if (is_giant_robot && !in_cutscene)
				{
					giant_points = giant_points - 1
					if (giant_points <= 0) GiantRobot_Control("exit")

					for (local bloodbot; bloodbot = Entities.FindByNameWithin(bloodbot, "bloodbot_robot_*", owner.GetOrigin(), 100); ) EntFireByHandle(bloodbot, "RemoveHealth", "300", -1.0, null, null)

					giantpoints_nextdraintime = Time() + giantpoints_drainrate
				}
			}

			// if (Time() >= blood_loss_tick)
			// {
				// if (poison_count > 0)
				// {
					// if (blood_loss_tick == 0) blood_loss_tick = Time() + blood_loss_rate
					// else
					// {
						// poisoned = true

						// if (poison_count < 100)
						// {
							// poison_count = poison_count - 1
							// BloodCountUpdate("leak")

							// blood_loss_tick = Time() + blood_loss_rate
						// }

						// else // failsafe for when we're carrying too much!
						// {
							// poison_count = poison_count - 3
							// BloodCountUpdate("leak"); BloodCountUpdate("leak"); BloodCountUpdate("leak")

							// blood_loss_tick = Time()
						// }

						// owner.BleedPlayer(0.05)
					// }
				// }

				// if (poison_count == 0)
				// {
					// poisoned = false
					// poisoned_string = ""

					// blood_loss_rate = 0
					// blood_loss_tick = 0
				// }
			// }

			if (poison_sources > 0)
			{
				if (poison_sources > 33) poison_sources = 33

				if (tick >= nextbleedtick)
				{
					nextbleedtick = tick + (33 / poison_sources).tointeger()
					owner.TakeDamage(4, 1, owner)
				}

				poisoned_string = " (☠)"
			}

			else
			{
				poisoned = false
				poisoned_string = ""
			}

			if (!in_setup() && wants_tips)
			{
				if (WAVE < 3 && blood_count >= 5) DeliverVisualTipToPlayer(owner, "vis_deliverblood", "Take all blood you collect\nto the Blood Tank!")
				if (tnt_count >= 1 && tnt_arm_count < 20) DeliverVisualTipToPlayer(owner, "vis_armbarrels", "You have some TNT! Take\nit to any glowing barrel!", true, 30.0)
				if (bombs_satisfied > 0) DeliverVisualTipToPlayer(owner, "vis_armallbarrels", "Fill all 20 barrels to beat the mission!")
				if (giant_points >= 30 && !was_giant_robot && life_tick > 1000) DeliverVisualTipToPlayer(owner, "vis_giantpoints", "Hold your Projectile Shield\nkey to become giant!", true, 90.0)
				if (is_giant_robot) DeliverVisualTipToPlayer(owner, "vis_giantpoints_turnback", "Hold the same key again\nto turn back to normal")
				if (excess_stage > 0) DeliverVisualTipToPlayer(owner, "vis_bloodexcess", "Carrying too much makes\nyou slow and fragile")
				if (WAVE < 3 && tank_blood_level == 0) DeliverVisualTipToPlayer(owner, "vis_tankhasnoblood", "Blood Tank drains its own health\nwhile it has no blood")
				if (blood_tank_healthdrain_dmg >= 3) { if (DeliverVisualTipToPlayer(owner, "vis_bloodbotreminder", "Blood-Bots contain blood that\ncan be given to the Blood Tank.", true, 60.0)) HighlightBloodBots() }
				if (excess_stage == 5)
				{
					if (WAVE < 3) DeliverVisualTipToPlayer(owner, "vis_toomanypickups", "You are carrying way too much!\nBring your blood to the Blood Tank!", true, 60.0)
					else		  DeliverVisualTipToPlayer(owner, "vis_toomanypickups", "You are carrying way too much!\nBring your TNT to any glowing barrel!", true, 5.0)
				}

				if (tnt_count == 0 && tnt_arm_count < 20 && extraction_mode == "tnt") DeliverVisualTipToPlayer(owner, "vis_collecttnt", "Stand near the Blood Tank to get TNT", true, 45.0)
				if (WAVE == 3 && extraction_mode == "blood") DeliverVisualTipToPlayer(owner, "vis_bloodconversion", "Bringing blood to the Blood Tank\nwill make it refill its TNT faster")
				if (WAVE == 3 && objective_type != null) DeliverVisualTipToPlayer(owner, "vis_wave3objective", "Blood Tank creates explosions\nwhile it's not moving")
			}

			if (objective_type == "deliver")
			{
				obj_deliver_text = "Deliver briefcases to the Tank (" + objectives_reached + "/" + objective_amount + ")" + obj_deliver_time_string

				local scope = owner.GetScriptScope()

				if (has_briefcase)
				{
					obj_deliver_time_string = "\nYou are currently carrying a briefcase"

					if (!("selfglow" in scope))
					{
						owner.KeyValueFromString("targetname", "glow_target")

						scope.selfglow <- SpawnEntityFromTable("tf_glow",
						{
							target           	  = "glow_target"
							GlowColor             = "0 0 255 255"
						})

						owner.KeyValueFromString("targetname", "")

						EntFireByHandle(scope.selfglow, "SetParent", "!activator", -1.0, owner, null)
					}
				}

				else
				{
					obj_deliver_time_string = ""
					if ("selfglow" in scope)
					{
						if (scope.selfglow.IsValid()) scope.selfglow.Kill()
						delete scope.selfglow
					}
				}

				ClientPrint(owner, 4, "" + obj_deliver_text)
			}

			if (escaped == "[✔]") owner.AddCustomAttribute("healing received penalty", 0, -1.0)

			if (NetProps.GetPropInt(owner, "m_lifeState") == 0 && !in_setup()) life_tick++

			return -1
		}

		BloodCountUpdate = function(operation, type = "blood")
		{
			switch (operation)
			{
				case "gain":
				{
					if (type == "blood")
					{
						blood_count = blood_count + 1

						if (WAVE == 3) DeliverTipToPlayer(owner, "nobloodexcess", "Blood acts as a secondary resource in this wave. You won't become slow or vulnerable if you carry too much of it.")
					}

					if (type == "tnt") tnt_count = tnt_count + 1

					break
				}

				case "double":
				{
					poisoned = true

					if (blood_count == 0) blood_count = blood_count + 1

					// poison_count = poison_count + blood_count

					blood_count = blood_count * 2

					if (blood_count > 99) blood_count = 99

					poison_sources += 1
					nextbleedtick = tick + (33 / poison_sources).tointeger()

					EntFireByHandle(owner, "RunScriptCode", "if (self.GetScriptScope().bloodstorage.poison_sources > 0) self.GetScriptScope().bloodstorage.poison_sources--", 4.995, null, null)

					// blood_loss_rate = 10.0 / poison_count

					// if (blood_loss_rate < 0.15) blood_loss_rate = 0.15

					// poisoned_string = " (☠)"

					// DeliverTipToPlayer(owner, "zombieblood", "Enemy zombies drop rotten blood. Rotten blood doubles and damages your blood storage, causing it to leak over time.")
					DeliverVisualTipToPlayer(owner, "vis_zombieblood", "Rotten blood doubles your carried\nblood and applies bleeding.", true, 90.0)

					break
				}

				case "transfer":
				{
					if (poison_count > 0) poison_count = poison_count - 1

					if (extraction_mode == "blood" && blood_count > 0) // tank grabs blood from players
					{
						blood_count = blood_count - 1
						giant_points = giant_points + 1

						if (tank_blood_level < 45)
						{
							if (WAVE != 3)
							{
								tank_blood_level = tank_blood_level + 3
								empty_blood_level = empty_blood_level - 3
							}

							else
							{
								if (objective_type != null)
								{
									if (!tank_objective_explosion_imminent) tank_objective_explosion_time = tank_objective_explosion_time + 0.5
									else									tank_objective_explosion_leftovers += 0.5
								}

								tank_blood_level_increment_threshold = tank_blood_level_increment_threshold + 1

								if (tank_blood_level_increment_threshold >= 3)
								{
									tank_blood_level = tank_blood_level + 3
									empty_blood_level = empty_blood_level - 3

									tank_blood_level_increment_threshold = 0
								}
							}

							if (supplysound_cooldown < Time()) { EmitGlobalSound("passtime/ball_dropped.wav"); supplysound_cooldown = Time() + 0.1 }
						}

						else
						{
							if (blood_tank.GetHealth() < 30000) blood_tank.SetHealth(blood_tank.GetHealth() + 301)
							else 								blood_tank.SetHealth(blood_tank.GetHealth() + 101)

							if (objective_type != null) 		blood_tank.SetHealth(blood_tank.GetHealth() + 51)

							tank_speedboost += 1.5
							tank_speedboostticks += 66

							EntFireByHandle(gamerules_entity, "RunScriptCode", "tank_speedboost -= 1.5", 1.0, null, null)

							blood_tank.TakeDamage(1, 1, blood_tank_heal_hud_update)

							EntFireByHandle(tank_blood_level_hud, "AddOutput", "color 0 128 0", 0.0, null, null)
							EntFireByHandle(tank_blood_level_hud, "AddOutput", "color 255 0 0", 0.1, null, null)

							EntFireByHandle(blood_tank.GetScriptScope().healglow, "Enable", null, -1.0, null, null)
							EntFireByHandle(blood_tank.GetScriptScope().healglow, "Disable", null, 0.1, null, null)

							if (overhealsound_cooldown < Time()) { EmitGlobalSound("misc/rd_finale_beep01.wav"); overhealsound_cooldown = Time() + 0.1 }

							// DeliverTipToBLU("tankhealing", "While the Blood Tank is at max blood capacity, all blood extracted by it turns into extra health.")

							foreach (bluplayer in bluplayer_array)
							{
								if (bluplayer.IsFakeClient()) continue

								DeliverVisualTipToPlayer(bluplayer, "vis_tankhealing", "Giving the Blood Tank more blood than\nit can hold will heal and speed it up.")
							}
						}

						if (draw_debugchat) ClientPrint(null,3,"" + blood_tank.GetHealth())

						// if (giant_points >= 30) DeliverTipToPlayer(owner, "giantpoints", "You have earned enough Giant Points to transform into a Giant Robot. Hold your Projectile Shield activation key to receive a power boost.")
					}

					if (extraction_mode == "tnt" && tank_tnt_level > 0) tnt_count = tnt_count + 1 // players grab tnt from tank

					if (extraction_mode == "blood_heal" && blood_count > 0) // players have a short window to heal the tank when it has received max blood
					{
						blood_count = blood_count - 1

						if (objective_type != null)
						{
							if (!tank_objective_explosion_imminent) tank_objective_explosion_time += 0.5
							else									tank_objective_explosion_leftovers += 0.5
						}

						if (blood_tank.GetHealth() < 30000) blood_tank.SetHealth(blood_tank.GetHealth() + 301)
						else 								blood_tank.SetHealth(blood_tank.GetHealth() + 101)

						if (objective_type != null) 		blood_tank.SetHealth(blood_tank.GetHealth() + 51)

						tank_speedboost += 1
						tank_speedboostticks += 66

						EntFireByHandle(gamerules_entity, "RunScriptCode", "tank_speedboost--", 1.0, null, null)

						blood_tank.TakeDamage(1, 1, blood_tank_heal_hud_update)

						EntFireByHandle(tank_blood_level_hud, "AddOutput", "color 0 128 0", 0.0, null, null)
						EntFireByHandle(tank_blood_level_hud, "AddOutput", "color 255 0 0", 0.1, null, null)

						EntFireByHandle(blood_tank.GetScriptScope().healglow, "Enable", null, -1.0, null, null)
						EntFireByHandle(blood_tank.GetScriptScope().healglow, "Disable", null, 0.1, null, null)

						if (overhealsound_cooldown < Time()) { EmitGlobalSound("misc/rd_finale_beep01.wav"); overhealsound_cooldown = Time() + 0.1 }

						if (bombs_remaining == 0) return
					}

					break
				}

				case "supply":
				{
					if (blood_count > 0)
					{
						blood_count = blood_count - 1
						if (supplysound_cooldown < Time()) { EmitGlobalSound("passtime/ball_dropped.wav"); supplysound_cooldown = Time() + 0.1 }
					}

					break
				}

				case "arm":
				{
					if (tnt_count > 0)
					{
						tnt_count = tnt_count - 1
						tnt_arm_count = tnt_arm_count + 1
						EmitSoundEx({ sound_name = "ui/item_helmet_pickup.wav", filter_type = 4, flags = 0, entity = owner, channel = 6 })
					}

					break
				}

				case "leak": blood_count = blood_count - 1; break

				case "tnt_cleanup":
				{
					blood_count = blood_count + tnt_count
					tnt_count = 0

					break
				}
			}

			message_format = ""

			local pickup_count = null

			if (WAVE != 3) pickup_count = blood_count
			else		   pickup_count = tnt_count

			if (pickup_count < 0) pickup_count = 0

			if (pickup_count > excess_bounds)
			{
				excess_count = pickup_count - excess_bounds
				excess_string = "+" + excess_count
				blood_hud_shift_amount = -0.01

				// if (WAVE != 3) DeliverTipToPlayer(owner, "bloodexcess", "While you carry an excess of blood, you get slower and more vulnerable.")
			}

			if (pickup_count <= excess_bounds)
			{
				excess_stage = 0
				excess_count = 0
				excess_string = ""
				blood_hud_shift_amount = 0
			}

			foreach (character in max_empty_bloodbar.slice(0, 0 + pickup_count - excess_count))
			{
				message_format += "▮" // full
			}

			foreach (character in max_empty_bloodbar.slice(0, excess_bounds - pickup_count + excess_count))
			{
				message_format += "▯" // empty
			}

			message_format = message_format.slice(0, 0 + excess_bounds * 3) + excess_string // each block character counts as 3

			prev_excess_stage = excess_stage

			for (local i = 1; i <= 5; i++) if (pickup_count >= excess_bounds - (excess_stage_progression_requirement - 1) + (excess_stage_progression_requirement * i)) excess_stage = i

				// excess_bounds = 3
				// excess_stage_progression_requirement = 2

				// if (4 >= 3 - 1 + 2) = 4 <- stage 1
				// if (6 >= 3 - 1 + 4) = 6 <- stage 2

			if (!is_giant_robot)
			{
				if (excess_stage == 0)
				{
					owner.RemoveCond(30)
					owner.RemoveCustomAttribute("CARD: move speed bonus")
					owner.RemoveCustomAttribute("dmg taken increased")
					hud_color = "255 255 255"
				}

				if (excess_stage >= 1 && !owner.InCond(30)) owner.AddCond(30)

				if (excess_stage == 1) hud_color = "255 204 0"
				if (excess_stage == 2) { owner.AddCustomAttribute("dmg taken increased", 1.25, -1); hud_color = "255 153 0" }
				if (excess_stage == 3) { owner.AddCustomAttribute("dmg taken increased", 1.25, -1); hud_color = "255 102 0" }
				if (excess_stage == 4) { owner.AddCustomAttribute("dmg taken increased", 1.5, -1); hud_color = "255 51 0" }
				if (excess_stage == 5)
				{
					owner.AddCustomAttribute("dmg taken increased", 2, -1)
					owner.AddCustomAttribute("no_attack", 1, -1)
					hud_color = "255 0 0"
					owner.SetForcedTauntCam(1)
					if (!NetProps.GetPropBool(excesspenalty_stunmarker, "m_bActive")) EntFireByHandle(excesspenalty_stunmarker, "Start", null, -1.0, null, null)

					if (prev_excess_stage < excess_stage) EmitSoundEx({sound_name = "player/pl_impact_stun.wav", channel = 1, entity = owner, filter_type = 4, volume = (audio_excludelist.find("player/pl_impact_stun.wav") == null) ? 1 : 0, sound_level = 100})
				}

				if (excess_stage < 5)
				{
					owner.RemoveCustomAttribute("no_attack")
					owner.SetForcedTauntCam(0)
					if (NetProps.GetPropBool(excesspenalty_stunmarker, "m_bActive")) EntFireByHandle(excesspenalty_stunmarker, "Stop", null, -1.0, null, null)

					if (excess_stage > 0 && prev_excess_stage < excess_stage) EmitSoundEx({sound_name = "weapons/samurai/TF_marked_for_death_indicator.wav", channel = 1, entity = owner, pitch = 95 + excess_stage * 5, filter_type = 4, volume = (audio_excludelist.find("weapons/samurai/TF_marked_for_death_indicator.wav") == null) ? 1 : 0, sound_level = 100})
				}

				scout_collection_radius = 288.0 - (excess_stage * 43.2)
			}

			else
			{
				owner.SetForcedTauntCam(0)
				if (NetProps.GetPropBool(excesspenalty_stunmarker, "m_bActive")) EntFireByHandle(excesspenalty_stunmarker, "Stop", null, -1.0, null, null)

				scout_collection_radius = 288.0
			}

			if (draw_debugchat) ClientPrint(null,3,"" + pickup_count)
		}

		GiantRobot_Control = function(operation)
		{
			local tf_class = owner.GetPlayerClass()

			local healthpercentage = owner.GetHealth().tofloat() / owner.GetMaxHealth().tofloat()

			if (healthpercentage > 1.0) healthpercentage = 1.0

			if (operation == "enter")
			{
				is_giant_robot = true
				in_giantmode_cooldown = true

				if (!was_giant_robot) was_giant_robot = true

				EntFireByHandle(owner, "RunScriptCode", "self.GetScriptScope().bloodstorage.GiantRobot_Control(`end_cooldown`)", 3.0, null, null)

				owner.SetIsMiniBoss(true)
				NetProps.SetPropBool(owner, "m_bIsMiniBoss", true)
				owner.AddCustomAttribute("is miniboss", 1, -1)

				owner.RemoveCond(30)
				owner.RemoveCustomAttribute("CARD: move speed bonus")
				owner.RemoveCustomAttribute("dmg taken increased")
				owner.RemoveCustomAttribute("no_attack")

				scout_collection_radius = 288.0

				owner.SetForcedTauntCam(0)

				if (NetProps.GetPropBool(excesspenalty_stunmarker, "m_bActive")) EntFireByHandle(excesspenalty_stunmarker, "Stop", null, -1.0, null, null)

				if (tf_class != scout && tf_class != engineer && tf_class != spy) owner.AddCustomAttribute("CARD: move speed bonus", 0.5, -1)

				if (tf_class == scout)
				{
					owner.SetCustomModelWithClassAnimations("models/bots/scout_boss/bot_scout_boss.mdl")
					owner.AddCustomAttribute("max health additive bonus", 1475, -1)
					owner.AddCustomAttribute("override footstep sound set", 5, -1)
					owner.SetHealth(1600 * healthpercentage)
				}

				if (tf_class == soldier)
				{
					owner.SetCustomModelWithClassAnimations("models/bots/soldier_boss/bot_soldier_boss.mdl")
					owner.AddCustomAttribute("max health additive bonus", 3800, -1)
					owner.AddCustomAttribute("override footstep sound set", 3, -1)
					owner.AddCustomAttribute("faster reload rate", -0.8, -1)

					if (NetProps.GetPropInt(NetProps.GetPropEntityArray(owner, "m_hMyWeapons", 0), "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 730) NetProps.GetPropEntityArray(owner, "m_hMyWeapons", 0).AddAttribute("can overload", 0, -1.0) // beggar's bazooka

					owner.SetHealth(4000 * healthpercentage)
				}

				if (tf_class == pyro)
				{
					owner.SetCustomModelWithClassAnimations("models/bots/pyro_boss/bot_pyro_boss.mdl")
					owner.AddCustomAttribute("max health additive bonus", 2825, -1)
					owner.AddCustomAttribute("override footstep sound set", 6, -1)
					owner.SetHealth(3000 * healthpercentage)
				}

				if (tf_class == demoman)
				{
					owner.SetCustomModelWithClassAnimations("models/bots/demo_boss/bot_demo_boss.mdl")
					owner.AddCustomAttribute("max health additive bonus", 2825, -1)
					owner.AddCustomAttribute("override footstep sound set", 4, -1)
					owner.AddCustomAttribute("faster reload rate", -0.8, -1)
					owner.SetHealth(3000 * healthpercentage)
				}

				if (tf_class == heavyweapons)
				{
					owner.SetCustomModelWithClassAnimations("models/bots/heavy_boss/bot_heavy_boss.mdl")
					owner.AddCustomAttribute("max health additive bonus", 4700, -1)
					owner.AddCustomAttribute("override footstep sound set", 2, -1)
					owner.AddCustomAttribute("damage bonus", 1.5, -1)
					owner.SetHealth(5000 * healthpercentage)
				}

				if (tf_class == engineer || tf_class == sniper || tf_class == spy)
				{
					owner.AddCustomAttribute("max health additive bonus", 1475, -1)
					owner.AddCustomAttribute("override footstep sound set", 4, -1)
					owner.SetHealth(1600 * healthpercentage)

					if (tf_class == sniper) owner.AddCustomAttribute("SRifle Charge rate decreased", 10, -1)
					if (tf_class == spy) owner.AddCustomAttribute("not solid to players", 1, -1)
				}

				if (tf_class == medic)
				{
					owner.AddCustomAttribute("max health additive bonus", 3850, -1)
					owner.AddCustomAttribute("heal rate bonus", 200, -1)
					owner.SetHealth(4000 * healthpercentage)
				}

				owner.SetModelScale(1.75, 2)

				owner.AddCustomAttribute("cannot be backstabbed", 1, -1)

				if (NetProps.GetPropEntity(owner, "m_hGroundEntity") == null) owner.SetAbsOrigin(owner.GetOrigin() - Vector(0, 0, 50))

				if (draw_debugchat) ClientPrint(null,3,"turned giant")

				ClientPrint(null,3,"\x079ACDFF" + NetProps.GetPropString(owner, "m_szNetname") + " \x07FBECCBhas turned into a \x079EC34FGIANT ROBOT\x07FBECCB!")

				EmitGlobalSound("mvm/mvm_used_powerup.wav")
			}

			if (operation == "exit")
			{
				if (!is_giant_robot) return

				owner.SetModelScale(1, 2)
				owner.AddCustomAttribute("CARD: move speed bonus", 1, -1)
				owner.RemoveCustomAttribute("cannot be backstabbed")
				owner.RemoveCustomAttribute("max health additive bonus")
				owner.RemoveCustomAttribute("override footstep sound set")

				owner.RemoveCustomAttribute("faster reload rate")
				owner.RemoveCustomAttribute("damage bonus")
				owner.RemoveCustomAttribute("heal rate bonus")

				owner.RemoveCustomAttribute("SRifle Charge rate decreased")
				owner.RemoveCustomAttribute("not solid to players")

				if (tf_class == scout)
				{
					owner.SetCustomModelWithClassAnimations("models/bots/scout/bot_scout.mdl")
					owner.SetHealth(125 * healthpercentage)
				}

				if (tf_class == soldier)
				{
					if (NetProps.GetPropInt(NetProps.GetPropEntityArray(owner, "m_hMyWeapons", 0), "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 730) NetProps.GetPropEntityArray(owner, "m_hMyWeapons", 0).RemoveAttribute("can overload") // beggar's bazooka

					owner.SetCustomModelWithClassAnimations("models/bots/soldier/bot_soldier.mdl")
					owner.SetHealth(200 * healthpercentage)
				}

				if (tf_class == pyro)
				{
					owner.SetCustomModelWithClassAnimations("models/bots/pyro/bot_pyro.mdl")
					owner.SetHealth(175 * healthpercentage)
				}

				if (tf_class == demoman)
				{
					owner.SetCustomModelWithClassAnimations("models/bots/demo/bot_demo.mdl")
					owner.SetHealth(175 * healthpercentage)
				}

				if (tf_class == heavyweapons)
				{
					owner.SetCustomModelWithClassAnimations("models/bots/heavy/bot_heavy.mdl")
					owner.SetHealth(300 * healthpercentage)
				}

				if (tf_class == engineer || tf_class == sniper || tf_class == spy) owner.SetHealth(125 * healthpercentage)
				if (tf_class == medic) owner.SetHealth(150 * healthpercentage)

				owner.SetIsMiniBoss(false)
				NetProps.SetPropBool(owner, "m_bIsMiniBoss", false)

				is_giant_robot = false
				in_giantmode_cooldown = true

				EntFireByHandle(owner, "RunScriptCode", "self.GetScriptScope().bloodstorage.BloodCountUpdate(`none`)", -1.0, null, null)

				EntFireByHandle(owner, "RunScriptCode", "self.GetScriptScope().bloodstorage.GiantRobot_Control(`end_cooldown`)", 3.0, null, null)

				if (draw_debugchat) ClientPrint(null,3,"exited giant")
			}

			if (operation == "end_cooldown")
			{
				if (!in_giantmode_cooldown) return

				// if (is_giant_robot) DeliverTipToPlayer(owner, "voluntarygiantexit", "Hold the Projectile Shield activation key again to exit the Giant transformation prematurely.")

				in_giantmode_cooldown = false

				if (draw_debugchat) ClientPrint(null,3,"giant cooldown lifted")
			}
		}
	}

	BLUPlayer_Think = function() { return self.GetScriptScope().bloodstorage.GlobalThinker() }

	AlienHunter_Think = function()
	{
		local scope = self.GetScriptScope()

		if (!("bloodstorage" in scope))
		{
			scope.bloodstorage <- {}
			scope.bloodstorage.escaped <- "[X]"

			scope.escaping <- false
			scope.hasthanked <- false

			scope.nexthelptime <- Time() + 8.0
		}

		if (scope.escaping)
		{
			if (Time() > scope.nexthelptime)
			{
				self.PlayScene("scenes/Player/Pyro/low/1463.vcd", -1.0)
				ClientPrint(null, 3, "\x0799CCFF(Voice) Alien Hunter\x07FBECCB: Help!")
				scope.nexthelptime = Time() + 8.0
			}
		}

		if (scope.bloodstorage.escaped != "[X]")
		{
			scope.escaping = false

			if (!scope.hasthanked)
			{
				self.PlayScene("scenes/Player/Pyro/low/1550.vcd", -1.0)
				ClientPrint(null, 3, "\x0799CCFF(Voice) Alien Hunter\x07FBECCB: Thanks!")

				scope.hasthanked = true
			}
		}

		return -1
	}

	AttachToTank_Think = function() { if (blood_tank != null) if (blood_tank.IsValid()) self.SetOrigin(blood_tank.GetOrigin() + Vector(0, 0, 50)) }

	TraceTest = function()
	{
		// local tracetable =
		// {
			// start = self.GetOrigin()
			// end = self.GetOrigin() + Vector(0, 0, -500)
			// mask = -1
			// ignore = self
		// }

		// TraceLineEx(tracetable)

		// ClientPrint(null,3,"" + tracetable.pos)

		return 0.1
	}
}

if (!("PEA_ONETIME" in getroottable()))
{
	::PEA_ONETIME <- // declare these variables only once on initial load, don't update them on any future loads
	{
		bluplayer_array = []
		suppress_waveend_music = false
		suppress_wavelost_sound = false
		previous_wave = 1
		debugger = null
	}

	foreach (thing, var in PEA_ONETIME) getroottable()[thing] <- getroottable()["PEA_ONETIME"][thing]

	EntFire("wormhole_start_relay", "Trigger")
	EntFire("wormhole_end_relay", "Trigger", null, 5.0)

	for (local i = 1; i <= MaxClients().tointeger(); i++)
	{
		local player = PlayerInstanceFromIndex(i)

		if (player == null) continue

		player.ValidateScriptScope()

		if (player.IsFakeClient()) continue

		EntFireByHandle(player, "RunScriptCode", "self.ForceRespawn()", -1.0, null, null)
	}
}

foreach (thing, var in PEA) getroottable()[thing] <- getroottable()["PEA"][thing]

AddThinkToEnt(gamerules_entity, "Global_Think")

//////////////////////////////////////////////////
//////////// PRECACHES
//////////////////////////////////////////////////

PrecacheModel("models/props_halloween/flask_vial.mdl"); PrecacheModel("materials/sprites/light_glow03.vmt")
PrecacheModel("models/bots/bot_worker/bot_worker.mdl"); PrecacheModel("models/bots/bot_worker/bot_worker2.mdl"); PrecacheModel("models/bots/bot_worker/bot_worker3.mdl"); PrecacheModel("models/bots/spy/bot_spy.mdl"); PrecacheModel("models/bots/heavy_boss/bot_heavy_boss.mdl")
PrecacheModel("models/workshop/player/items/all_class/hw2013_the_magical_mercenary/hw2013_the_magical_mercenary_scout.mdl")
PrecacheSound("mvm/giant_heavy/giant_heavy_entrance.wav"); PrecacheSound("mvm/mvm_bomb_warning.wav"); PrecacheSound("mvm/mvm_bought_upgrade.wav")
PrecacheSound("ui/duel_challenge.wav"); PrecacheSound("ui/item_helmet_pickup.wav")
PrecacheSound("bomb_cartfall.wav"); 	PrecacheSound("bombcart_moving.wav")
PrecacheSound("vo/mvm_bomb_alerts01.mp3"); PrecacheSound("vo/mvm_bomb_alerts02.mp3"); PrecacheSound("vo/mvm_another_bomb05.mp3"); PrecacheSound("vo/mvm_another_bomb06.mp3"); PrecacheSound("vo/mvm_another_bomb07.mp3"); PrecacheSound("vo/mvm_another_bomb08.mp3")
PrecacheSound("misc/outer_space_transition_01.wav"); PrecacheSound("misc/doomsday_cap_open_start.wav")
PrecacheSound("endgame_music.wav"); PrecacheSound("fire_alarm.wav"); PrecacheSound("pl_hoodoo/alarm_clock_ticking_3.wav"); PrecacheSound("plats/elevator_stop.wav"); PrecacheSound("reentry_gate_sound.wav"); PrecacheSound("sniper_cashteleport.wav")
PrecacheSound("ambient/cp_harbor/furnace_1_shot_05.wav"); PrecacheSound("ambient/rain.wav"); PrecacheSound("ambient/lightsoff.wav"); PrecacheSound("ambient/explosions/explode_1.wav"); PrecacheSound("ambient/explosions/explode_2.wav"); PrecacheSound("ambient/explosions/explode_3.wav");
PrecacheSound("ambient/explosions/explode_4.wav"); PrecacheSound("ambient/explosions/explode_5.wav"); PrecacheSound("ambient/explosions/explode_7.wav"); PrecacheSound("ambient/explosions/explode_8.wav"); PrecacheSound("ambient/explosions/explode_9.wav")
PrecacheScriptSound("Player.DenyWeaponSelection"); PrecacheScriptSound("MVM.GiantHeavyEntrance"); PrecacheSound("ui/item_as_parasite_drop.wav"); PrecacheSound("misc/rd_finale_beep01.wav"); PrecacheScriptSound("MVM.GiantHeavyExplodes"); PrecacheSound("mvm/mvm_used_powerup.wav")
PrecacheSound("ui/rd_2base_alarm.wav"); PrecacheScriptSound("Robot.Collide"); PrecacheScriptSound("Robot.Greeting"); PrecacheSound("ui/chime_rd_2base_neg.wav"); PrecacheSound("ui/item_helmet_pickup.wav"); PrecacheScriptSound("Weapon_Marked_for_Death.Indicator"); PrecacheSound("ui/killsound_beepo.wav")
PrecacheSound("ambient/cp_harbor/furnace_1_shot_05.wav"); PrecacheSound("ui/quest_status_tick_novice_complete.wav"); PrecacheSound("ui/quest_status_tick_advanced_complete.wav"); PrecacheSound("ui/quest_status_tick_expert_complete.wav"); PrecacheSound("ui/mm_level_six_achieved.wav")
PrecacheSound("mvm_end_last_wave_short.wav"); PrecacheScriptSound("Announcer.MVM_Bonus"); PrecacheSound("mvm/mvm_money_pickup.wav"); PrecacheSound("ui/quest_status_tick_novice.wav"); PrecacheSound("ui/quest_status_tick_advanced.wav"); PrecacheSound("ui/quest_status_tick_expert.wav")
PrecacheModel("models/bots/boss_bot/boss_tank.mdl"); PrecacheModel("models/bots/boss_bot/boss_tank_damage1.mdl"); PrecacheModel("models/bots/boss_bot/boss_tank_damage2.mdl"); PrecacheModel("models/bots/boss_bot/boss_tank_damage3.mdl"); PrecacheScriptSound("MVM.BombWarning")
PrecacheScriptSound("mvm.cpoint_alarm"); PrecacheSound("ui/chat_display_text.wav"); PrecacheSound("misc/cp_harbor_red_whistle.wav"); PrecacheSound("vo/mvm_final_wave_end01.mp3"); PrecacheSound("vo/mvm_final_wave_end02.mp3"); PrecacheSound("vo/mvm_final_wave_end03.mp3")
PrecacheSound("vo/mvm_final_wave_end04.mp3"); PrecacheSound("vo/mvm_final_wave_end05.mp3"); PrecacheSound("vo/mvm_final_wave_end06.mp3"); PrecacheScriptSound("Announcer.mvm_spybot_death_all"); PrecacheScriptSound("Announcer.MVM_Spy_Alert"); PrecacheScriptSound("Announcer.MVM_Wave_Lose")
PrecacheSound("weapons/samurai/TF_marked_for_death_indicator.wav"); PrecacheScriptSound("music.mvm_end_tank_wave"); PrecacheSound("pl_hoodoo/alarm_clock_alarm_3.wav"); PrecacheSound("weapons/loose_cannon_explode.wav"); PrecacheSound("DisciplineDevice.PowerUp"); PrecacheSound("ui/system_message_alert.wav")
PrecacheSound("player/pl_impact_stun.wav")

// PrecacheEntityFromTable({ classname = "instanced_scripted_scene", model = MODEL_NAME });(

//////////////////////////////////////////////////
//////////// AUTOEXECUTE
//////////////////////////////////////////////////

foreach (bluplayer in bluplayer_array)
{
	if (bluplayer.IsFakeClient()) continue

	if (!("scout_collection_radius" in bluplayer.GetScriptScope().bloodstorage)) { ReloadMapForChanges(); break }
}

EntityOutputs.AddOutput(debug_menu, "OnCase02", "gamerules", "RunScriptCode", "if (debugger != null) ClientPrint(debugger,3,`` + (cur_tankspeed + tank_speedboost))", -1.0, -1)

AddThinkToEnt(blu_spawn_1_booth, "InfoBooth_Think")
AddThinkToEnt(blu_spawn_2_booth, "InfoBooth_Think")

blu_spawn_1_booth_bbox.KeyValueFromInt("solid", 2)
blu_spawn_1_booth_bbox.KeyValueFromString("mins", "-50 -50 -300")
blu_spawn_1_booth_bbox.KeyValueFromString("maxs", "50 50 300")
blu_spawn_1_booth_bbox.KeyValueFromString("angles", "0 120 0")

blu_spawn_2_booth_bbox.KeyValueFromInt("solid", 2)
blu_spawn_2_booth_bbox.KeyValueFromString("mins", "-50 -50 -300")
blu_spawn_2_booth_bbox.KeyValueFromString("maxs", "50 50 300")
blu_spawn_2_booth_bbox.KeyValueFromString("angles", "0 120 0")

Convars.SetValue("sv_turbophysics", 0)
ForceEscortPushLogic(2)

//////////// debugging

if (debug)
{
	if (debug_objective) current_stage = debug_stage
	else				 current_stage = debug_stage - 1

	if (debug_stage >= 2)
	{
		EntFireByHandle(pop_interface_ent, "$FinishWavespawn", "W" + WAVE + "-S" + (debug_stage - 1) + "*", -1.0, null, null)
		EntFireByHandle(pop_interface_ent, "$FinishWavespawn", "W" + WAVE + "-O" + (debug_stage - 1) + "*", -1.0, null, null)
	}

	if (debug_stage >= 3)
	{
		EntFireByHandle(pop_interface_ent, "$FinishWavespawn", "W" + WAVE + "-S" + (debug_stage - 2) + "*", -1.0, null, null)
		EntFireByHandle(pop_interface_ent, "$FinishWavespawn", "W" + WAVE + "-O" + (debug_stage - 2) + "*", -1.0, null, null)
	}

	if (debug_objective) EntFireByHandle(pop_interface_ent, "$FinishWavespawn", "W" + WAVE + "-S" + debug_stage + "*", -1.0, null, null)
}

if (WAVE == 3)
{
	escapestatus_rows =
	[
		"Escaped: " + players_escaped + "/" + bluplayer_array.len() + "\n",
		"",
		"",
		"",
		"",
		"",
		"",
		""
	]
}

EntFire("spawnbot_boss", "Disable")

SetUpSpawnIndicators()

NavMesh.GetNavAreaByID(4509).UnblockArea(); NavMesh.GetNavAreaByID(4510).UnblockArea(); NavMesh.GetNavAreaByID(4511).UnblockArea(); NavMesh.GetNavAreaByID(4512).UnblockArea()
NavMesh.GetNavAreaByID(4703).UnblockArea(); NavMesh.GetNavAreaByID(4704).UnblockArea(); NavMesh.GetNavAreaByID(4705).UnblockArea(); NavMesh.GetNavAreaByID(4706).UnblockArea()
NavMesh.GetNavAreaByID(4721).UnblockArea(); NavMesh.GetNavAreaByID(4722).UnblockArea(); NavMesh.GetNavAreaByID(4723).UnblockArea(); NavMesh.GetNavAreaByID(4724).UnblockArea()
NavMesh.GetNavAreaByID(4747).UnblockArea(); NavMesh.GetNavAreaByID(4748).UnblockArea()

NavMesh.GetNavAreaByID(53).ConnectTo(NavMesh.GetNavAreaByID(12), NavMesh.GetNavAreaByID(53).ComputeDirection(NavMesh.GetNavAreaByID(12).GetCenter()))
NavMesh.GetNavAreaByID(53).ConnectTo(NavMesh.GetNavAreaByID(44), NavMesh.GetNavAreaByID(53).ComputeDirection(NavMesh.GetNavAreaByID(44).GetCenter()))
NavMesh.GetNavAreaByID(53).ConnectTo(NavMesh.GetNavAreaByID(124), NavMesh.GetNavAreaByID(53).ComputeDirection(NavMesh.GetNavAreaByID(124).GetCenter()))

NavMesh.GetNavAreaByID(80).ConnectTo(NavMesh.GetNavAreaByID(195), NavMesh.GetNavAreaByID(80).ComputeDirection(NavMesh.GetNavAreaByID(195).GetCenter()))
NavMesh.GetNavAreaByID(650).ConnectTo(NavMesh.GetNavAreaByID(195), NavMesh.GetNavAreaByID(650).ComputeDirection(NavMesh.GetNavAreaByID(195).GetCenter()))
NavMesh.GetNavAreaByID(905).ConnectTo(NavMesh.GetNavAreaByID(195), NavMesh.GetNavAreaByID(905).ComputeDirection(NavMesh.GetNavAreaByID(195).GetCenter()))
NavMesh.GetNavAreaByID(3617).ConnectTo(NavMesh.GetNavAreaByID(195), NavMesh.GetNavAreaByID(3617).ComputeDirection(NavMesh.GetNavAreaByID(195).GetCenter()))

NavMesh.GetNavAreaByID(266).ConnectTo(NavMesh.GetNavAreaByID(26), NavMesh.GetNavAreaByID(266).ComputeDirection(NavMesh.GetNavAreaByID(26).GetCenter()))
NavMesh.GetNavAreaByID(266).ConnectTo(NavMesh.GetNavAreaByID(576), NavMesh.GetNavAreaByID(266).ComputeDirection(NavMesh.GetNavAreaByID(576).GetCenter()))

NavMesh.GetNavAreaByID(71).Disconnect(NavMesh.GetNavAreaByID(12))
NavMesh.GetNavAreaByID(122).Disconnect(NavMesh.GetNavAreaByID(12))
NavMesh.GetNavAreaByID(3261).Disconnect(NavMesh.GetNavAreaByID(12))

NavMesh.GetNavAreaByID(67).Disconnect(NavMesh.GetNavAreaByID(5038))

NavMesh.GetNavAreaByID(112).Disconnect(NavMesh.GetNavAreaByID(4977))
NavMesh.GetNavAreaByID(112).Disconnect(NavMesh.GetNavAreaByID(4978))

NavMesh.GetNavAreaByID(312).Disconnect(NavMesh.GetNavAreaByID(4451))
NavMesh.GetNavAreaByID(4452).Disconnect(NavMesh.GetNavAreaByID(4451))
NavMesh.GetNavAreaByID(423).Disconnect(NavMesh.GetNavAreaByID(4451))

NavMesh.GetNavAreaByID(4537).Disconnect(NavMesh.GetNavAreaByID(312))
NavMesh.GetNavAreaByID(4538).Disconnect(NavMesh.GetNavAreaByID(312))

for (local i = 1; i <= 18; i++)
{
	getroottable()["spawnbot_red_" + i + "_visual"].KeyValueFromString("message", i.tostring())
	getroottable()["spawnbot_red_" + i + "_visual"].KeyValueFromInt("textsize", 40)
	getroottable()["spawnbot_red_" + i + "_visual"].KeyValueFromInt("font", 1)
	getroottable()["spawnbot_red_" + i + "_visual"].KeyValueFromInt("orientation", 1)
	getroottable()["spawnbot_red_" + i + "_visual"].KeyValueFromInt("rendermode", 3)
}

SpawnEntityFromTable("prop_dynamic", { origin = Vector(2580, -600, -155), angles = QAngle(40, 0, 90), model = "models/props_gameplay/security_fence64.mdl", solid = 6 })
SpawnEntityFromTable("prop_dynamic", { origin = Vector(3100, -1040, -110), angles = QAngle(40, 90, 90), model = "models/props_gameplay/security_fence64.mdl", solid = 6 })
SpawnEntityFromTable("prop_dynamic", { origin = Vector(3350, -1300, -110), angles = QAngle(40, 0, 90), model = "models/props_gameplay/security_fence64.mdl", solid = 6 })
SpawnEntityFromTable("prop_dynamic", { origin = Vector(400, -920, -330), angles = QAngle(40, -90, 90), model = "models/props_gameplay/security_fence64.mdl", solid = 6 })

for (local ent; ent = Entities.FindByClassname(ent, "point_worldtext"); )
{
	if (ent.GetName().find("nav_") != null)
	{
		ent.KeyValueFromInt("textsize", 20)
		ent.KeyValueFromInt("font", 1)
		ent.KeyValueFromInt("orientation", 1)
		ent.KeyValueFromInt("rendermode", 3)
	}
}

// for (local ent; ent = Entities.FindByModel(ent, "models/props_mvm/robot_spawnpoint.mdl"); ) ent.DisableDraw()
for (local ent; ent = Entities.FindByModel(ent, "models/props_mvm/hologram_projector.mdl"); ) ent.Kill()
for (local ent; ent = Entities.FindByModel(ent, "models/props_mvm/robot_hologram.mdl"); ) ent.Kill()

if (!draw_worldtext) for (local ent; ent = Entities.FindByClassname(ent, "point_worldtext"); ) if (ent.GetName() != "mobile_station_text" && ent.GetName() != "infobooth_text") ent.Kill()

//////////// delete the invisible wall next to spawnbot red 5

for (local ent; ent = Entities.FindByClassname(ent, "func_respawnroomvisualizer"); ) if (NetProps.GetPropInt(ent, "m_iHammerID") == 1051019) ent.Kill()

//////////// Fix "A wormhole has appeared!" notification appearing mid-wave with cl_hud_minmode 0.

for (local ent; ent = Entities.FindByName(ent, "hint_boss"); ) ent.Kill()

//////////// Kill all default nav_prefers, nav_avoids, and default sniper spots

for (local ent; ent = Entities.FindByClassname(ent, "func_tfbot_hint"); ) ent.Kill()
for (local ent; ent = Entities.FindByClassname(ent, "func_nav_prefer"); ) ent.Kill()
for (local ent; ent = Entities.FindByClassname(ent, "func_nav_avoid"); ) ent.Kill()

//////////// Implement custom nav funcs

SetUpCustomNavigation(); SetUpCustomNavigation() // calling this twice to make sure bots never disobey the fun

//////////// set up objective types and tank paths for each stage on each wave

for (local ent; ent = Entities.FindByClassname(ent, "trigger_multiple"); ) if (NetProps.GetPropInt(ent, "m_iHammerID") == 1072738) ent.Kill() // remove the imperfect default giant shrink trigger (doesn't revert the shrink after leaving it)

switch (WAVE)
{
	case 1:
	{
		tank_stage1_speed = 36.0
		tank_stage2_speed = 30.0
		tank_stage3_speed = 32.0

		stage1_cash_reward = 750
		stage2_cash_reward = 750
		stage3_cash_reward = 500

		stage1_objective = "destroy"
		stage2_objective = "escort"
		stage3_objective = "deliver"

		pathbranch_array[0].SetOrigin(Vector(2800, -544, -416)); pathbranch_array[1].SetOrigin(Vector(2800, -1200, -416)); pathbranch_array[2].SetOrigin(Vector(3400, -1200, -416)); pathbranch_array[3].SetOrigin(Vector(4350, -1200, -100)); pathbranch_array[4].SetOrigin(Vector(4350, -1500, -100)); 		pathbranch_array[5].SetOrigin(Vector(3450, -1500, -100));
		pathbranch_array[6].SetOrigin(Vector(3450, -900, -100)); pathbranch_array[7].SetOrigin(Vector(2700, -900, -100)); pathbranch_array[8].SetOrigin(Vector(2250, -900, -100)); pathbranch_array[9].SetOrigin(Vector(2070, -900, -100)); pathbranch_array[10].SetOrigin(Vector(2070, -1000, -100))

		for (local i = 11; i <= pathbranch_array.len() - 1; i++) pathbranch_array[i].SetOrigin(Vector(2070, -1010, -100))

		EntityOutputs.AddOutput(pathbranch_array[2], "OnPass", "gamerules", "CallScriptFunction", "Objective_Start", 0.0, -1)

		EntityOutputs.AddOutput(pathbranch_array[7], "OnPass", "!activator", "$SetGravity", "0.2", 0.0, -1) // fix issue with tank falling through stair grate
		EntityOutputs.AddOutput(pathbranch_array[8], "OnPass", "!activator", "$SetGravity", "1.0", 0.0, -1)

		EntityOutputs.AddOutput(pathbranch_array[10], "OnPass", "gamerules", "CallScriptFunction", "Objective_Start", 0.0, -1)

		SpawnEntityFromTable("prop_dynamic",
		{
			targetname 	  = "w1_hatch"
			origin        = Vector(2070, -1170, -218)
			angles        = QAngle(0, -90, 0)
			model         = "models/props_mvm/mann_hatch.mdl"
		})

		w1_hatch_box = SpawnEntityFromTable("prop_physics_multiplayer",
		{
			origin        = Vector(2070, -1170, -218)
			model         = "models/props_badlands/barrel03.mdl"
		})

		EntFireByHandle(w1_hatch_box, "DisableMotion", null, 1.0, null, null)
		w1_hatch_box.SetCollisionGroup(5)

		SpawnEngineerHint(1850, 0, -150, 2050, -250, -224, -90); 	SpawnEngineerHint(2600, -400, -125, 2600, -250, -176, 180); SpawnEngineerHint(3100, 100, -50, 3100, 0, -128, -90); 			SpawnEngineerHint(4200, -1700, -50, 4400, -1700, -112, 90)
		SpawnEngineerHint(2700, -1700, -50, 2650, -1900, -128, 90); SpawnEngineerHint(1750, -600, -175, 1550, -600, -224, 90); 	SpawnEngineerHint(2450, -1300, -400, 2400, -1500, -448, 90); 	SpawnEngineerHint(2400, -250, -450, 2150, -300, -512, 270)

		Entities.FindByName(null, "hatch_explo_kill_players").Teleport(true, w1_hatch_box.GetOrigin(), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
		Entities.FindByName(null, "hatch_magnet_pit").Teleport(true, w1_hatch_box.GetOrigin(), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
		Entities.FindByName(null, "pit_explosion_wav").Teleport(true, w1_hatch_box.GetOrigin(), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
		Entities.FindByName(null, "end_pit_destroy_particle").Teleport(true, w1_hatch_box.GetOrigin(), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
		Entities.FindByName(null, "trigger_hurt_hatch_fire").Teleport(true, w1_hatch_box.GetOrigin(), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))

		break
	}
	case 2:
	{
		tank_stage1_speed = 37.0
		tank_stage2_speed = 25.0
		tank_stage3_speed = 27.0

		stage1_cash_reward = 750
		stage2_cash_reward = 750
		stage3_cash_reward = 500

		stage1_objective = "hunt"
		stage2_objective = "supply"
		stage3_objective = "push"

		pathbranch_array[0].SetOrigin(Vector(2800, -544, -416)); pathbranch_array[1].SetOrigin(Vector(2800, -1200, -416)); pathbranch_array[2].SetOrigin(Vector(3400, -1200, -416)); pathbranch_array[3].SetOrigin(Vector(4350, -1200, -100))
		pathbranch_array[4].SetOrigin(Vector(4350, -750, -100)); pathbranch_array[5].SetOrigin(Vector(4350, -300, -100)); pathbranch_array[6].SetOrigin(Vector(3700, -300, -20)); pathbranch_array[7].SetOrigin(Vector(3700, 300, -20))

		for (local i = 8; i <= pathbranch_array.len() - 1; i++) pathbranch_array[i].SetOrigin(Vector(3700, 387.5, -20))

		EntityOutputs.AddOutput(pathbranch_array[2], "OnPass", "gamerules", "CallScriptFunction", "Objective_Start", 0.0, -1)

		EntityOutputs.AddOutput(pathbranch_array[4], "OnPass", "!activator", "RunScriptCode", "self.Teleport(true, self.GetOrigin() + Vector(0, 20, 0), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))", 0.0, -1)

		w2_s3_minigame_bombcart_prop = SpawnEntityFromTable("prop_dynamic",
		{
			origin                  = Vector(3700, 550, -64)
			model                   = "models/props_medical/med_table002.mdl"
			solid                   = 6
			angles                  = QAngle(0, 180, 0)
		})

		w2_s3_minigame_bombcart_prop_bbox = SpawnEntityFromTable("func_button",
		{
			origin 					= Vector(3700, 550, -64)
			angles                  = QAngle(0, 180, 0)
		})

		w2_s3_minigame_bombcart_prop_bbox.KeyValueFromInt("solid", 2)
		w2_s3_minigame_bombcart_prop_bbox.KeyValueFromString("mins", "-30 -15 -40")
		w2_s3_minigame_bombcart_prop_bbox.KeyValueFromString("maxs", "30 15 40")

		break
	}

	case 3:
	{
		tank_stage1_speed = 27.0
		tank_stage2_speed = 27.0
		tank_stage3_speed = 20.0

		stage1_cash_reward = 800
		stage2_cash_reward = 800
		stage3_cash_reward = 0

		stage1_objective = "capture"
		stage2_objective = "free"
		stage3_objective = "end"

		extraction_mode = "tnt"

		tank_blood_level = 0
		empty_blood_level = 45

		EntityOutputs.AddOutput(pathbranch_array[5], "OnPass", "gamerules", "CallScriptFunction", "SetUpIceBlock", -1.0, -1)
		EntityOutputs.AddOutput(pathbranch_array[28], "OnPass", "gamerules", "CallScriptFunction", "Objective_Start", -1.0, -1)

		for (local ent; ent = Entities.FindByClassname(ent, "trigger_multiple"); ) if (NetProps.GetPropInt(ent, "m_iHammerID") == 102478 || NetProps.GetPropInt(ent, "m_iHammerID") == 102630) NetProps.SetPropEntity(ent, "m_hFilter", null)
		for (local ent; ent = Entities.FindByClassname(ent, "func_respawnroomvisualizer"); ) if (NetProps.GetPropInt(ent, "m_iHammerID") == 111420 || NetProps.GetPropInt(ent, "m_iHammerID") == 111455) ent.Kill()

		SpawnTNTBarrel(800, 1000, -500); 	SpawnTNTBarrel(0, 0, -400); 		SpawnTNTBarrel(-1000, 1000, -250); 	SpawnTNTBarrel(500, -1500, -350); 	SpawnTNTBarrel(1550, -600, -200);
		SpawnTNTBarrel(-1000, -750, -350); 	SpawnTNTBarrel(1800, 100, -200); 	SpawnTNTBarrel(2000, -1200, -200); 	SpawnTNTBarrel(2650, -1900, -100); 	SpawnTNTBarrel(4400, -1600, -100);
		SpawnTNTBarrel(3100, 0, -100); 		SpawnTNTBarrel(3900, -700, -150);	SpawnTNTBarrel(2450, -1400, -400); 	SpawnTNTBarrel(2600, -200, -100); 	SpawnTNTBarrel(2200, 600, -50);
		SpawnTNTBarrel(4350, -200, -100);	SpawnTNTBarrel(5400, 250, -100); 	SpawnTNTBarrel(4500, 1000, 50); 	SpawnTNTBarrel(4100, 2200, 50); 	SpawnTNTBarrel(3700, 550, 0)

		SpawnSniperHint(1550, -100, -200, "-150 -50 -200", "150 125 200"); 	SpawnSniperHint(2900, -400, -400, "-250 -125 -200", "50 100 200"); SpawnSniperHint(5300, 0, -100, "-100 -50 -200", "100 125 200");
		SpawnSniperHint(3500, 1700, 0, "-75 -50 -200", "50 100 200"); 		SpawnSniperHint(2300, 600, 0, "-200 -150 -200", "100 50 200")

		break
	}
}

for (local ent; ent = Entities.FindByClassname(ent, "func_nobuild"); ) ent.KeyValueFromInt("solid", 2)

stage1_blockade_center_nobuild.KeyValueFromString("mins", "-300 -150 -100"); stage1_blockade_center_nobuild.KeyValueFromString("maxs", "300 150 100")
stage1_blockade_left_nobuild.KeyValueFromString("mins", "-100 -150 -100"); stage1_blockade_left_nobuild.KeyValueFromString("maxs", "100 150 100")
stage1_blockade_right_nobuild.KeyValueFromString("mins", "-150 -150 -150"); stage1_blockade_right_nobuild.KeyValueFromString("maxs", "150 150 150")

blood_tank_minidispenser_trigger.KeyValueFromInt("solid", 2)
blood_tank_minidispenser_trigger.KeyValueFromString("mins", "-250 -250 -250")
blood_tank_minidispenser_trigger.KeyValueFromString("maxs", "250 250 250")

//////////// EXECUTE AT WAVE START

EntityOutputs.AddOutput(Entities.FindByName(null, "wave_start_relay"), "OnTrigger", "gamerules", "CallScriptFunction", "WaveStartFunctions", -1.0, -1)

switch (WAVE)
{
	case 1:
	{
		bloodbot_path_p2_vectorarray =
		[
			Vector(2300, 100, -160), Vector(2300, 100, -64), Vector(2300, 600, -64), Vector(3700, 600, -64), Vector(3700, -300, -64), Vector(3834, -300, -64),
			Vector(3939, -300, -128), Vector(4350, -300, -128), Vector(4350, -900, -128), Vector(4201, -900, -128), Vector(4096, -900, -192), Vector(3850, -900, -192),
			Vector(3850, -600, -192), Vector(3709, -600, -192), Vector(3604, -600, -128), Vector(3100, -600, -128), Vector(3100, 100, -128), Vector(2625, 100, -128), Vector(2552, 100, -160)
		]

		bloodbot_path_p3_vectorarray =
		[
			Vector(4500, 1000, 0), Vector(4500, 1850, 0), Vector(3700, 1850, 0), Vector(3700, 880, 0), Vector(3700, 775, -64), Vector(3700, -300, -64),
			Vector(3838, -300, -64), Vector(3943, -300, -128), Vector(5200, -300, -128), Vector(5400, 400, -128), Vector(5246, 471, -192), Vector(5000, 600, -192),
			Vector(5000, 100, -192), Vector(4712, 100, -192), Vector(4183, 100, -448), Vector(3400, 100, -448), Vector(3400, -500, -448)
		]

		break
	}
	case 2:
	{
		bloodbot_path_p2_vectorarray =
		[
			Vector(2300, 100, -160), Vector(2552, 100, -160), Vector(2625, 100, -128), Vector(3100, 100, -128), Vector(3100, -900, -128),
			Vector(3500, -900, -128), Vector(3500, -1700, -128), Vector(2750, -1700, -128), Vector(2750, -900, -128), Vector(2687, -900, -128),
			Vector(2320, -900, -224), Vector(1800, -900, -224), Vector(1800, 100, -224), Vector(1988, 100, -224), Vector(2093, 100, -160)
		]

		bloodbot_path_p3_vectorarray =
		[
			Vector(4100, 1500, -136), Vector(4100, 1416, -136), Vector(4100, 1322, -128), Vector(4100, 1028, -128), Vector(4100, 891, -64),
			Vector(4100, 600, -64), Vector(4470, 600, -64), Vector(4711, 600, -192), Vector(5000, 600, -192), Vector(5000, 100, -192),
			Vector(4712, 100, -192), Vector(4183, 100, -448), Vector(3400, 100, -448), Vector(3400, -500, -448)
		]

		break
	}
	case 3:
	{
		bloodbot_path_p2_vectorarray =
		[
			Vector(1800, -950, -224), Vector(2260, -950, -224), Vector(2750, -950, -128), Vector(2750, -1600, -128), Vector(4350, -1600, -128),
			Vector(4350, -1200, -128), Vector(4200, -1200, -128), Vector(3560, -1200, -448), Vector(3100, -1320, -448), Vector(3100, -1320, -128),
			Vector(3100, 100, -128), Vector(2600, 100, -128), Vector(2500, 100, -160), Vector(2100, 100, -160), Vector(1800, 100, -224)
		]

		bloodbot_path_p3_vectorarray = // copy of w1's b path
		[
			Vector(2300, 100, -160), Vector(2300, 100, -64), Vector(2300, 600, -64), Vector(3700, 600, -64), Vector(3700, -300, -64), Vector(3834, -300, -64),
			Vector(3939, -300, -128), Vector(4350, -300, -128), Vector(4350, -900, -128), Vector(4201, -900, -128), Vector(4096, -900, -192), Vector(3850, -900, -192),
			Vector(3850, -600, -192), Vector(3709, -600, -192), Vector(3604, -600, -128), Vector(3100, -600, -128), Vector(3100, 100, -128), Vector(2625, 100, -128), Vector(2552, 100, -160)
		]

		break
	}
}

if (WAVE <= 3)
{
	for (local stage = 1; stage <= 3; stage++)
	{
		for (local j = 1; j <= getroottable()["bloodbot_path_p" + stage + "_vectorarray"].len(); j++) local path = SpawnEntityFromTable("path_track", {targetname = "bloodbot_path_p" + stage + "_" + j})

		for (local j = 1; j <= getroottable()["bloodbot_path_p" + stage + "_vectorarray"].len(); j++)
		{
			Entities.FindByName(null, "bloodbot_path_p" + stage + "_" + j).KeyValueFromFloat("speed", bloodbot_path_speed)
			Entities.FindByName(null, "bloodbot_path_p" + stage + "_" + j).KeyValueFromVector("origin", getroottable()["bloodbot_path_p" + stage + "_vectorarray"][j - 1])

			if (j > 1) NetProps.SetPropEntity(Entities.FindByName(null, "bloodbot_path_p" + stage + "_" + j), "m_pprevious", Entities.FindByName(null, "bloodbot_path_p" + stage + "_" + (j - 1)))

			else if (stage == 2 || (stage == 3 && WAVE == 3)) NetProps.SetPropEntity(Entities.FindByName(null, "bloodbot_path_p" + stage + "_" + j), "m_pprevious", Entities.FindByName(null, "bloodbot_path_p" + stage + "_" + getroottable()["bloodbot_path_p" + stage + "_vectorarray"].len())) // looping path

			else // non-looping path
			{
				EntityOutputs.AddOutput(Entities.FindByName(null, "bloodbot_path_p" + stage + "_" + j), "OnPass", "!activator", "StartForward", null, -1.0, -1)
				EntityOutputs.AddOutput(Entities.FindByName(null, "bloodbot_path_p" + stage + "_" + j), "OnPass", "!activator", "AddOutput", "angles 0 0 0", -1.0, -1)
			}

			if (j < getroottable()["bloodbot_path_p" + stage + "_vectorarray"].len()) NetProps.SetPropEntity(Entities.FindByName(null, "bloodbot_path_p" + stage + "_" + j), "m_pnext", Entities.FindByName(null, "bloodbot_path_p" + stage + "_" + (j + 1)))

			else if (stage == 2 || (stage == 3 && WAVE == 3)) NetProps.SetPropEntity(Entities.FindByName(null, "bloodbot_path_p" + stage + "_" + j), "m_pnext", Entities.FindByName(null, "bloodbot_path_p" + stage + "_" + "1")) // looping path

			else // non-looping path
			{
				EntityOutputs.AddOutput(Entities.FindByName(null, "bloodbot_path_p" + stage + "_" + j), "OnPass", "!activator", "StartBackward", null, -1.0, -1)
				EntityOutputs.AddOutput(Entities.FindByName(null, "bloodbot_path_p" + stage + "_" + j), "OnPass", "!activator", "AddOutput", "angles 0 180 0", -1.0, -1)
			}

			if (j > 1 && j < getroottable()["bloodbot_path_p" + stage + "_vectorarray"].len()) EntityOutputs.AddOutput(Entities.FindByName(null, "bloodbot_path_p" + stage + "_" + j), "OnPass", "!activator", "CallScriptFunction", "ReverseBloodBot", -1.0, -1)

			getroottable()["bloodbot_path_p" + stage].append(Entities.FindByName(null, "bloodbot_path_p" + stage + "_" + j))
			getroottable()["bloodbot_path_p" + stage + "_name_picker"].append("bloodbot_path_p" + stage + "_" + j)
			getroottable()["bloodbot_path_p" + stage + "_origin_picker"].append(getroottable()["bloodbot_path_p" + stage][j - 1].GetOrigin())
		}
	}
}

//////////// CALLBACKS

//// Set up blood carry params that reset on death

intel_entity.Teleport(true, Vector(-352, 1824, -496), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))

EntityOutputs.AddOutput(intel_entity, "OnPickup1", "!activator", "RunScriptCode", "self.DropFlag(true)", -1.0, -1.0)

EntFireByHandle(intel_entity, "ForceGlowDisabled", "1", -1.0, null, null)

AddThinkToEnt(intel_entity, "AttachToTank_Think")

local control_point_controller_test = SpawnEntityFromTable("team_control_point_master",
{
	targetname                   = "control_point_controller"
	team_base_icon_3             = "sprites/obj_icons/icon_base_blu"
	team_base_icon_2             = "sprites/obj_icons/icon_base_red"
	switch_teams                 = 0
	score_style                  = 1
	custom_position_y            = -1
	custom_position_x            = 5
	cpm_restrict_team_cap_win    = 1
	caplayout                    = ""
})

for (local ent; ent = Entities.FindByClassname(ent, "team_control_point_master"); ) ent.Kill()

//////////////////////////////////////////////////
//////////// DEBUG
//////////////////////////////////////////////////

seterrorhandler(function(e)
{
	local Chat = @(m) (printl(m), ClientPrint(null, 2, m))
	ClientPrint(null, 3, format("\x07FF0000AN ERROR HAS OCCURRED [%s].\nCheck console for details", e))

	Chat(format("\n====== TIMESTAMP: %g ======\nAN ERROR HAS OCCURRED [%s]", Time(), e))
	Chat("CALLSTACK")
	local s, l = 2
	while (s = getstackinfos(l++)) Chat(format("*FUNCTION [%s()] %s line [%d]", s.func, s.src, s.line))

	Chat("LOCALS")

	if (s = getstackinfos(2))
	{
		foreach (n, v in s.locals)
		{
			local t = type(v)
			t ==    "null" ? Chat(format("[%s] NULL"  , n))    :
			t == "integer" ? Chat(format("[%s] %d"    , n, v)) :
			t ==   "float" ? Chat(format("[%s] %.14g" , n, v)) :
			t ==  "string" ? Chat(format("[%s] \"%s\"", n, v)) :
							 Chat(format("[%s] %s %s" , n, t, v.tostring()))
		}
	}

	return
})

SetGravityMultiplier(1)

for (local ent; ent = Entities.FindByClassname(ent, "point_viewcontrol"); ) ent.Kill() // preserved entities!

if (debug)
{
	for (local i = 1; i <= MaxClients().tointeger(); i++)
	{
		local player = PlayerInstanceFromIndex(i)

		if (NetProps.GetPropString(player, "m_szNetworkIDString") == "[U:1:95064912]")
		{
			player.SetHealth(90000)
			player.SetMoveType(8, 0)
			// player.GrantOrRemoveAllUpgrades(false, false)

			player.SetForceLocalDraw(false)
		}
	}
}

CALLBACKS.OnGameEvent_player_say <- function(params)
{
	local player = GetPlayerFromUserID(params.userid)

	if (NetProps.GetPropString(player, "m_szNetworkIDString") == "[U:1:95064912]")
	{
		if (params.text == "!poison")
		{
			player.GetScriptScope().bloodstorage.BloodCountUpdate("double")
			// player.GetScriptScope().bloodstorage.BloodCountUpdate("double")
		}

		if (params.text == "!p")
		{
			ClientPrint(null,3,"DebugMenu: Destroyed all REDs and Blood Bots")

			for (local i = 1; i <= MaxClients().tointeger(); i++)
			{
				local player = PlayerInstanceFromIndex(i)
				if (player == null) continue;
				if (!player.IsFakeClient()) continue
				if (player.GetTeam() != 2) continue

				player.TakeDamage(10000.0, 64, player)
			}

			for (local ent; ent = Entities.FindByName(ent, "bloodbot_robot_*"); ) EntFireByHandle(ent, "RemoveHealth", "300", -1.0, null, null)
		}

		if (params.text == "!h")
		{
			blood_tank.SetHealth((blood_tank.GetHealth() + 10000.0) > 30000 ? 30000 : (blood_tank.GetHealth() + 10000.0))
			blood_tank.TakeDamage(1.0, 1, blood_tank_heal_hud_update)

			if (WAVE < 3)
			{
				tank_blood_level = 45
				empty_blood_level = 0
			}

			ClientPrint(null,3,"DebugMenu: Healed Blood Tank")
		}

		if (params.text == "!g") player.GetScriptScope().bloodstorage.giant_points = 500
	}
}

for (local ent; ent = Entities.FindByClassname(ent, "*"); ) NetProps.SetPropBool(ent, "m_bForcePurgeFixedupStrings", true)

if (draw_debugchat) ClientPrint(null,3,"main file started")

__CollectGameEventCallbacks(CALLBACKS)
