//behavior tags
//why does this need to be included here when it's already included in the _main file?
IncludeScript("popextensions/botbehavior", getroottable())

PopExtUtil.PlayerManager.ValidateScriptScope()

local popext_funcs = {

    /**************************************************************************************************************************
     * ADD CONDITION                                                                                                          *
     *                                                                                                                        *
     * TF_COND_REPROGRAMMED will do the same thing as popext_reprogrammed, but does not automatically apply ammo regen 		  *
     *                                                                                                                        *
     * Duration is optional                                                                                                   *
     *                                                                                                                        *
     * Example: popext_addcond{ cond = TF_COND_SPEED_BOOST, duration = 15}                                                    *
     **************************************************************************************************************************/

	popext_addcond = function(bot, args) {

		local cond = "cond" in args ? args.cond.tointeger() : args.type.tointeger()
		if (cond == TF_COND_REPROGRAMMED)
			bot.ForceChangeTeam(TF_TEAM_PVE_DEFENDERS, true)
		else
			bot.AddCondEx(cond, args.duration.tointeger(), null)
	}


    /**********************************************************
     * REPROGRAMMED                                           *
     *                                                        *
     * No parameters required, only tag presence is necessary *
     **********************************************************/

	popext_reprogrammed = function(bot, args) {

		// EntFireByHandle(bot, "RunScriptCode", "self.ForceChangeTeam(TF_TEAM_PVE_DEFENDERS, true)", -1, null, null)
		bot.ForceChangeTeam(TF_TEAM_PVE_DEFENDERS, false)
		bot.AddCustomAttribute("ammo regen", 999.0, -1)
	}

	// popext_reprogrammed_neutral = function(bot, args) {
		// bot.ForceChangeTeam(TEAM_UNASSIGNED, true)
	// }

    /*********************************************************************************
     * PRESS SECONDARY FIRE                                                          *
     *                                                                               *
     * Example: popext_altfire{ duration = 30 } //hold for 30 seconds after spawning *
     *                                                                               *
     * Arguments are optional                                                        *
     *                                                                               *
     * Example: popext_altfire                                                       *
     *********************************************************************************/

	popext_altfire = function(bot, args) {

		bot.PressAltFireButton(args.duration.tointeger())
	}

    /*******************************************************************************************************
     * CUSTOM DEATH SOUND                                                                                  *
     *                                                                                                     *
     * See the EmitSoundEx page for valid arguments                                                        *
     * https://developer.valvesoftware.com/wiki/Team_Fortress_2/Scripting/Script_Functions/EmitSoundEx     *
     *                                                                                                     *
     * Example: popext_deathsound{sound = `ui/chime_rd_2base_neg.wav`}                                                               *
     *******************************************************************************************************/

	popext_deathsound = function(bot, args) {

		local sound = "sound" in args ? args.sound : args.type
		local volume = "volume" in args ? args.volume : 1
		local channel = "channel" in args ? args.channel : CHAN_AUTO
		local sound_level = "sound_level" in args ? args.sound_level : 0
		local flags = "flags" in args ? args.flags : SND_NOFLAGS
		local pitch = "pitch" in args ? args.pitch : 100
		local special_dsp = "special_dsp" in args ? args.special_dsp : 0
		local origin = "origin" in args ? args.origin : bot.GetOrigin()
		local delay = "delay" in args ? args.delay : 1 //does nothing with any positive value
		local sound_time = "sound_time" in args ? args.sound_time : 0.0 //maybe this should be Time()?
		local entity = "entity" in args ? args.entity : bot
		local speaker_entity = "speaker_entity" in args ? args.speaker_entity : null
		local filter_type = "filter_type" in args ? args.filter_type : 0
		local filter_param = "filter_param" in args ? args.filter_param : -1

		PopExtTags.DeathHookTable.DeathSound <- function(params) {

			local victim = GetPlayerFromUserID(params.userid)

			if (victim != bot) return

			EmitSoundEx({

				sound_name = sound
				volume = volume
				channel = channel
				sound_level = sound_level
				flags = flags
				pitch = pitch
				special_dsp = special_dsp
				origin = origin
				delay = delay
				sound_time = sound_time
				entity = entity
				speaker_entity = speaker_entity
				filter_type = filter_type
				filter_param = filter_param

			})

			// EmitSoundEx({sound_name = "sound" in args ? args.sound : args.type, entity = victim})
		}
	}

    /*******************************************************************************************************
     * CUSTOM STEP SOUND                                                                                   *
     *                                                                                                     *
     * !!!WARNING!!! Does not sync correctly with giant step sounds, or anything with reduced movespeed!   *
     * m_Local.m_nStepside seemingly does not take movespeed into account                                  *
     *                                                                                                     *
     * See the EmitSoundEx page for valid arguments                                                        *
     * https://developer.valvesoftware.com/wiki/Team_Fortress_2/Scripting/Script_Functions/EmitSoundEx     *
     *                                                                                                     *
     * Example: popext_stepsound{sound = `ui/chime_rd_2base_pos.wav`}                                                               *
     *******************************************************************************************************/

	popext_stepsound = function(bot, args) {

		local sound = "sound" in args ? args.sound : args.type
		local volume = "volume" in args ? args.volume : 1
		local channel = "channel" in args ? args.channel : CHAN_AUTO
		local sound_level = "sound_level" in args ? args.sound_level : 0
		local flags = "flags" in args ? args.flags : SND_NOFLAGS
		local pitch = "pitch" in args ? args.pitch : 100
		local special_dsp = "special_dsp" in args ? args.special_dsp : 0
		local origin = "origin" in args ? args.origin : bot.GetOrigin()
		local delay = "delay" in args ? args.delay : 1 //does nothing with any positive value
		local sound_time = "sound_time" in args ? args.sound_time : 0.0 //maybe this should be Time()?
		local entity = "entity" in args ? args.entity : bot
		local speaker_entity = "speaker_entity" in args ? args.speaker_entity : null
		local filter_type = "filter_type" in args ? args.filter_type : 0
		local filter_param = "filter_param" in args ? args.filter_param : -1

		scope.stepside <- GetPropInt(bot, "m_Local.m_nStepside")

		bot.GetScriptScope().PlayerThinkTable.Stepsound <- function() {

			if (GetPropInt(bot, "m_Local.m_nStepside") != stepside)

				EmitSoundEx({

					sound_name = sound
					volume = volume
					channel = channel
					sound_level = sound_level
					flags = flags
					pitch = pitch
					special_dsp = special_dsp
					origin = origin
					delay = delay
					sound_time = sound_time
					entity = entity
					speaker_entity = speaker_entity
					filter_type = filter_type
					filter_param = filter_param

				})

			scope.stepside = GetPropInt(bot, "m_Local.m_nStepside")
		}
	}

    /**********************************************************
     * USE HUMAN MODEL	                                      *
     *                                                        *
     * No parameters required, only tag presence is necessary *
     **********************************************************/

	popext_usehumanmodel = function(bot, args) {

		local class_string = PopExtUtil.Classes[bot.GetPlayerClass()]
		bot.SetCustomModelWithClassAnimations(format("models/player/%s.mdl", class_string))
		EntFireByHandle(bot, "SetCustomModelWithClassAnimations", format("models/player/%s.mdl", class_string), -1, null, null)
		bot.GetScriptScope().usingcustommodel <- true
	}

    /*********************************************************************
     * USE CUSTOM MODEL                                                  *
     *                                                                   *
     * Example: popext_usecustommodel{model = `models/player/heavy.mdl`} *
     *********************************************************************/

	popext_usecustommodel = function(bot, args) {
		local model = "model" in args ? args.model : args.type
		if (!IsModelPrecached(model)) PrecacheModel(model)
		EntFireByHandle(bot, "SetCustomModelWithClassAnimations", model, -1, null, null)
		bot.GetScriptScope().usingcustommodel <- true
	}

    /**************************************************************************************************************************
     * USE HUMAN ANIMATIONS                                                                                                   *
     *                                                                                                                        *
     * !!!WARNING!!! This tag is incompatible with UseCustomModel!!!                                                          *
     *                                                                                                                        *
     * Works by setting the bot model to a human model, then bonemerging a tf_wearable using the bot model to the human model *
     * Haven't actually checked if this messes up cosmetics lol                                                               *
     * Maybe a popext_customwearable tag would work alongside this to generate an additional wearable alongside the bot one?  *
	 * 																														  *
     * No parameters required, only tag presence is necessary 																  *
     **************************************************************************************************************************/

	popext_usehumananims = function(bot, args) {

		local class_string = PopExtUtil.Classes[bot.GetPlayerClass()]
		EntFireByHandle(bot, "SetCustomModelWithClassAnimations", format("models/player/%s.mdl", class_string), SINGLE_TICK, null, null)
		EntFireByHandle(bot, "RunScriptCode", format("PopExtUtil.PlayerRobotModel(self, `models/bots/%s/bot_%s.mdl`)", class_string, class_string), SINGLE_TICK, null, null)
		bot.GetScriptScope().usingcustommodel <- true
	}

    /**********************************************************
     * ALWAYS GLOW	                                          *
     *                                                        *
     * No parameters required, only tag presence is necessary *
     **********************************************************/
	popext_alwaysglow = function(bot, args) {

		SetPropBool(bot, "m_bGlowEnabled", true)
	}

    /**************************************************
     * STRIP SLOT:                                    *
     *                                                *
     * Example: popext_stripslot{ slot = SLOT_MELEE } *
     **************************************************/

	popext_stripslot = function(bot, args) {

		local slot = "slot" in args ? args.slot.tointeger() : args.type.tointeger()

		if (slot == -1) slot = bot.GetActiveWeapon().GetSlot()
		PopExtUtil.GetItemInSlot(bot, slot).Kill()
	}

    /*****************************************************************************************************************************
     * PRESS BUTTON                                                                                                              *
     * 				                                                                                                             *
     * !!!IFSEETARGET HAS NOT BEEN IMPLEMENTED YET!!!                                                                            *
     *                                                                                                                           *
     * All keyvalues besides "button" are optional, default values can be found in this file by searching for "local tagtable =" *
     * 																															 *
	 * Press the reload key for 2 seconds every 10 seconds 5 times if we're below 100 HP                                         *
     * Example: popext_fireweapon{ button = IN_RELOAD cooldown = 3 delay = 10 repeats = 5 ifhealthbelow = 100 duration = 2 }     *
     *****************************************************************************************************************************/
	popext_fireweapon = function(bot, args) {

		local button = "button" in args ? args.button.tointeger() : args.type.tointeger()
		local cooldown = args.cooldown.tointeger()
		local duration = args.duration.tointeger()
		local delay = args.delay.tointeger()
		local repeats = args.repeats.tointeger()
		local ifhealthbelow = args.ifhealthbelow.tointeger()
		local ifseetarget = args.ifseetarget.tointeger()

		local maxrepeats = 0
		local cooldowntime = Time() + cooldown
		local delaytime = Time() + delay

		bot.GetScriptScope().PlayerThinkTable.FireWeaponThink <- function()
		{
			if ((maxrepeats) >= repeats)
			{
				delete bot.GetScriptScope().PlayerThinkTable.FireWeaponThink
				return
			}

			if (Time() < delaytime || (Time() < cooldowntime) || bot.GetHealth() > ifhealthbelow || bot.HasBotAttribute(SUPPRESS_FIRE)) return

			maxrepeats++

			PopExtUtil.PressButton(bot, button)
			EntFireByHandle(bot, "RunScriptCode", format("PopExtUtil.ReleaseButton(self, %d)", button), duration, null, null)
			cooldowntime = Time() + cooldown
		}
	}


    /***************************************************************************************************************************
     * WEAPON SWITCHING                                                                                                        *
     * 				                                                                                                           *
     * !!!IFSEETARGET HAS NOT BEEN IMPLEMENTED YET!!!                                                                          *
     *                                                                                                                         *
     * All keyvalues besides "slot" are optional, default values can be found in this file by searching for "local tagtable =" *
     *                                                                                                                         *
     * Example: popext_weaponswitch{ slot = SLOT_SECONDARY cooldown = 3 delay = 10 repeats = 5 ifhealthbelow = 100 } 	       *
     ***************************************************************************************************************************/

	popext_weaponswitch = function(bot, args) {

		local slot = "slot" in args ? args.slot.tointeger() : args.type.tointeger()
		local cooldown = args.cooldown.tointeger()
		local duration = args.duration.tointeger()
		local delay = args.delay.tointeger()
		local repeats = args.repeats.tointeger()
		local ifhealthbelow = args.ifhealthbelow.tointeger()
		local ifseetarget = args.ifseetarget.tointeger()

		local maxrepeats = 0
		local cooldowntime = Time() + cooldown
		local delaytime = Time() + delay

		bot.GetScriptScope().PlayerThinkTable.WeaponSwitchThink <- function()
		{
			if ((maxrepeats) >= repeats)
			{
				delete bot.GetScriptScope().PlayerThinkTable.WeaponSwitchThink
				return
			}

			if (Time() < delaytime || (Time() < cooldowntime) || bot.GetHealth() > ifhealthbelow) return

			maxrepeats++

			bot.Weapon_Switch(PopExtUtil.GetItemInSlot(bot, slot))
			bot.AddCustomAttribute("disable weapon switch", 1, duration)
			EntFireByHandle(bot, "RunScriptCode","self.RemoveCustomAttribute(`disable weapon switch`)", duration, null, null)
			EntFireByHandle(bot, "RunScriptCode", format("self.Weapon_Switch(PopExtUtil.GetItemInSlot(self, %d))", slot), duration+SINGLE_TICK, null, null)
			cooldowntime = Time() + cooldown
		}
	}

    /***************************************************************************************************************************
     * SPELL CASTING                                                                                                           *
     * 				                                                                                                           *
     * !!!IFSEETARGET HAS NOT BEEN IMPLEMENTED YET!!!                                                                          *
     * see constants.nut for spell type values                                                                                 *
     *                                                                                                                         *
     * All keyvalues besides "type" are optional, default values can be found in this file by searching for "local tagtable =" *
     *                                                                                                                         *
     * Example: popext_spell{ type = SPELL_SKELETON cooldown = 3 delay = 10 repeats = 5 ifhealthbelow = 100 charges = 5 }      *
     ***************************************************************************************************************************/

	popext_spell = function(bot, args) {

		local type = args.type.tointeger()
		local cooldown = args.cooldown.tointeger()
		local duration = args.duration.tointeger()
		local delay = args.delay.tointeger()
		local repeats = args.repeats.tointeger()
		local ifhealthbelow = args.ifhealthbelow.tointeger()
		local ifseetarget = args.ifseetarget.tointeger()
		local charges = args.charges.tointeger()


		local spellbook = PopExtUtil.GetItemInSlot(bot, SLOT_PDA)

		//equip a spellbook if the bot doesn't have one
		if (spellbook == null)
		{
			local book = CreateByClassname("tf_weapon_spellbook")
			SetPropInt(book, STRING_NETPROP_ITEMDEF, ID_BASIC_SPELLBOOK)
			SetPropBool(book, "m_AttributeManager.m_Item.m_bInitialized", true)
			SetPropBool(book, "m_bValidatedAttachedEntity", true)
			SetPropEntityArray(bot, "m_hMyWeapons", book, book.GetSlot())

			book.SetTeam(bot.GetTeam())
			DispatchSpawn(book)

			bot.Weapon_Equip(book)

			//try again next think
			return
		}

		local cooldowntime = Time() + cooldown
		local delaytime = Time() + delay

		local maxrepeats = 0

		bot.GetScriptScope().PlayerThinkTable.SpellThink <- function()
		{
			if ((maxrepeats) >= repeats)
			{
				delete bot.GetScriptScope().PlayerThinkTable.SpellThink
				return
			}

			if (Time() < delaytime || (Time() < cooldowntime) || bot.GetHealth() > ifhealthbelow) return

			maxrepeats++

			SetPropInt(spellbook, "m_iSelectedSpellIndex", type)
			SetPropInt(spellbook, "m_iSpellCharges", charges)
			try {

				bot.Weapon_Switch(spellbook)
				spellbook.AddAttribute("disable weapon switch", 1, 1) // duration doesn't work here?
				spellbook.ReapplyProvision()
			} catch(e) printl("can't find spellbook!")

			EntFireByHandle(spellbook, "RunScriptCode", "self.RemoveAttribute(`disable weapon switch`)", 1, null, null)
			EntFireByHandle(spellbook, "RunScriptCode", "self.ReapplyProvision()", 1, null, null)

			cooldowntime = Time() + cooldown
		}
	}

    /******************************************************************************************
     * SPAWN TEMPLATE                                                                         *
     *                                                                                        *
     * Spawns a point template from the global PointTemplates table parented to the bot       *
     * See the PointTemplates examples for more information on how the template spawner works *
     *                                                                                        *
     * Example: popext_spawntemplate{template = `MyTemplateName`}                             *
     ******************************************************************************************/

	popext_spawntemplate = function(bot, args) {
		SpawnTemplate("template" in args ? args.template : args.type, bot)
	}

    /**********************************************************
     * FORCE ROMEVISION                                       *
     *                                                        *
     * No parameters required, only tag presence is necessary *
     **********************************************************/

	popext_forceromevision = function(bot, args) {

		//kill the existing romevision
		EntFireByHandle(bot, "RunScriptCode", @"
			local killrome = []

			if (self.IsBotOfType(TF_BOT_TYPE))
				for (local child = self.FirstMoveChild(); child != null; child = child.NextMovePeer())
					if (child.GetClassname() == `tf_wearable` && startswith(child.GetModelName(), `models/workshop/player/items/`+PopExtUtil.Classes[self.GetPlayerClass()]+`/tw`))
						killrome.append(child)

			for (local i = killrome.len() - 1; i >= 0; i--) killrome[i].Kill()

			local cosmetics = PopExtUtil.ROMEVISION_MODELS[self.GetPlayerClass()]

			if (self.GetModelName() == `models/bots/demo/bot_sentry_buster.mdl`)
			{
				PopExtUtil.CreatePlayerWearable(self, PopExtUtil.ROMEVISION_MODELS[self.GetPlayerClass()][2])
				return
			}
			foreach (cosmetic in cosmetics)
			{
				local wearable = PopExtUtil.CreatePlayerWearable(self, cosmetic)
				SetPropString(wearable, `m_iName`, `__bot_romevision_model`)
			}
		", -1, null, null)
	}

    /**********************************************************************************************************************************************************************
     * CUSTOM ATTRIBUTES                                                                                                                                                  *
     * See customattributes.nut for a list of valid custom attributes and what they do                                                                                    *
     *                                                                                                                                                                    *
     * Example: popext_customattr{attribute = `wet immunity`, value = 1}                                                                                                  *
     *                                                                                                                                                                    *
     * If no "weapon" keyvalue is supplied, attributes will be applied to the bots current active weapon only                                                             *
     * You can pass a weapon classname, item index, weapon handle, or english name to the weapon parameter and PopExtUtil.HasItemInLoadout will try to find it on the bot *
     * If it can't find any weapon, it it'll default back to the current active weapon                                                                                    *
     *                                                                                                                                                                    *
     * Example: popext_customattr{weapon = `tf_weapon_scattergun`, attribute = `last shot crits`, value = 1}                                                              *
	 *                                                                                                                                                                    *
	 * Inputting either "attribute" or "attr" into the tag is fine, since customattributes.nut refers to the attribute string as "attr"                                   *
	 *                                                                                                                                                                    *
	 * Example: popext_customattr{attr = `wet immunity`, value = 1}                                                                                                       *
     **********************************************************************************************************************************************************************/

	popext_customattr = function(bot, args) {

		local wep

		if ("weapon" in args) wep = PopExtUtil.HasItemInLoadout(bot, args.weapon)

		local weapon = wep ? wep : bot.GetActiveWeapon()

		if ("attr" in args)
			CustomAttributes.AddAttr(bot, args.attr, args.value, weapon)
		else
			CustomAttributes.AddAttr(bot, args.attribute, args.value, weapon)
	}

    /**********************************************************************************************************************************************
     * RING OF FIRE                                                                                                                               *
     *                                                                                                                                            *
     * Example: popext_ringoffire{damage = 20 interval = 3 radius = 150}                                                                          *
     *                                                                                                                                            *
     * NOTE: the huo-long particle effect is does not scale with radius! If you intend to use a custom effect, set "hide_particle_effect" to true *
	 * 																																			  *
     * Example: popext_ringoffire{damage = 20 interval = 3 radius = 150, hide_particle_effect = 1}                                                *
     **********************************************************************************************************************************************/

	popext_ringoffire = function(bot, args) {

		local damage = args.damage.tointeger()
		local interval = args.interval.tointeger()
		local radius = args.radius.tointeger()
		local hide_particle_effect = "hide_particle_effect" in args ? args.hide_particle_effect.tointeger() : false

		local cooldown = Time() + interval

		bot.GetScriptScope().PlayerThinkTable.RingOfFireThink <-  function() {

			if (Time() < cooldown) return

			local origin = bot.GetOrigin()

			if (!hide_particle_effect) DispatchParticleEffect("heavy_ring_of_fire", origin, bot.GetAngles())


			for (local player; player = FindByClassnameWithin(player, "player", origin, radius);)
			{
				if (player.GetTeam() == bot.GetTeam() || !PopExtUtil.IsAlive(player)) continue

				player.TakeDamage(damage, DMG_BURN, bot)
				PopExtUtil.Ignite(player)
			}
			cooldown = Time() + interval
		}
	}

	//FIX THIS

	popext_meleeai = function(bot, args) {

		local visionoverride = bot.GetMaxVisionRangeOverride() == -1 ? INT_MAX : bot.GetMaxVisionRangeOverride()

		bot.GetScriptScope().PlayerThinkTable.MeleeAIThink <- function() {

			local t = aibot.FindClosestThreat(visionoverride, false)

			if (t == null || t.IsFullyInvisible() || t.IsStealthed()) return

			if (aibot.threat != t)
			{
				// bot.AddBotAttribute(SUPPRESS_FIRE)
				aibot.SetThreat(t, false)
				aibot.LookAt(t.EyePosition(), 50, 50)
				bot.SetAttentionFocus(t)
			}
			// if (bot.hasbotattrEntFireByHandle(bot, "RunScriptCode", "self.RemoveBotAttribute(SUPPRESS_FIRE)", -1, null, null)
			// bot.RemoveBotAttribute(SUPPRESS_FIRE)

			if (!bot.HasBotTag("popext_mobber"))
				aibot.UpdatePathAndMove(t.GetOrigin())
		}
	}

	//FIX THIS

	popext_mobber = function(bot, args) {

		bot.GetScriptScope().PlayerThinkTable.MobberThink <- function() {
			local threat = aibot.threat;
			if (threat != null && threat.IsValid() && PopExtUtil.IsAlive(threat)) return

			local threats = aibot.CollectThreats()

			local t = threats[RandomInt(0, threats.len() - 1)]

			// Move(t)
			aibot.UpdatePathAndMove(t.GetOrigin())
		}
	}

    /***************************************************************************************************
     * !!!OBSOLETE!!! USE popext_actionpoint INSTEAD!!!                                                *
     * MOVE TO POINT                                                                                   *
     *                                                                                                 *
     * Example: "popext_movetopoint{target = `entity_to_move_to`}"                                     *
     *                                                                                                 *
     * You can also pass xyz parameters instead of a target entity                                     *
     *                                                                                                 *
     * Example: "popext_movetopoint{target = `500 500 500`}" - move to xyz coordinates (500, 500, 500) *
     ***************************************************************************************************/

	popext_movetopoint = function(bot, args) {

		local pos = Vector()
		local point = "target" in args ? args.target : args.type

		if (FindByName(null, point) != null)
			pos = FindByName(null, point).GetOrigin()
		else
		{
			local buf = ""
			point.find(",") ?  buf = split(point, ",") : buf = split(point, " ")
			buf.apply(function(v) { return v.tofloat()})

			pos = Vector(buf[0], buf[1], buf[2])
		}

		bot.GetScriptScope().PlayerThinkTable.MoveToPoint <- function() {
			aibot.UpdatePathAndMove(pos)
		}
	}

	/************************************************************************************************************************************************************************************************************
	 * ACTION POINT                                                                                                                                                                                             *
	 * 				                                                                                                                                                                                            *
	 * Example: "popext_actionpoint{target = `action_point_targetname`}"                                                                                                                                        *
	 *                                                                                                                                                                                                          *
	 * You can also create entirely new action points by passing x y z coordinates where you want it to be spawned                                                                                              *
	 *                                                                                                                                                                                                          *
	 * Example: "popext_actionpoint{target = `500 500 500`, next_action_point = `optional_next_action_point_targetname`, desired_distance = 50, stay_time = 5, command = `attack sentry at next action point`}" *
	 ************************************************************************************************************************************************************************************************************/

	popext_actionpoint = function(bot, args) {

		local pos = Vector()
		local point = "target" in args ? args.target : args.type
		local next_action_point = "next_action_point" in args ? args.next_action_point : ""
		local desired_distance = "desired_distance" in args ? args.desired_distance : args.duration
		local stay_time = "stay_time" in args ? args.stay_time : args.repeats
		local command = "command" in args ? args.command : "attack sentry at next action point"

		local action_point = FindByName(null, point)

		if (action_point) return

		if (pos == Vector())
		{
			local buf = ""
			point.find(",") ?  buf = split(point, ",") : buf = split(point, " ")
			buf.apply(function(v) { return v.tofloat()})

			pos = Vector(buf[0], buf[1], buf[2])
		}

		action_point = CreateByClassname("bot_action_point")

		action_point.KeyValueFromString("targetname", format("__popext_actionpoint_%d", bot.entindex()))
		action_point.KeyValueFromString("next_action_point", next_action_point)
		action_point.KeyValueFromString("command", command)

		action_point.KeyValueFromInt("desired_distance", desired_distance)
		action_point.KeyValueFromInt("stay_time", stay_time)

		action_point.SetOrigin(pos)

		if ("output" in args)
		{
			local target = args.output.target
			local action =  args.output.action
			local param = "param" in args.output ? args.output.param : ""
			local delay = "delay" in args.output ? args.output.delay : -1
			local repeats = "repeats" in args.output ? args.output.repeats : -1

			AddOutput(action_point, "OnBotReached", target, action, param, delay, repeats)
		}

		DispatchSpawn(action_point)
		bot.SetActionPoint(action_point)
	}

    /*******************************************************************************************************************************************************************************************************************************
     * FIRE ENTITY INPUT                                                                                                                                                                                                           *
     *                                                                                                                                                                                                                             *
     * Fires an entity input as soon as the bot spawns                                                                                                                                                                             *
     *                                                                                                                                                                                                                             *
     * !!!WARNING!!! Passing a null activator/caller to certain entities will crash the server!                                                                                                                                    *
     * trigger_stun and trigger_player_respawn_override are two notable examples                                                                                                                                                   *
     *                                                                                                                                                                                                                             *
     * param, delay, activator, and caller are all optional                                                                                                                                                                        *
     *                                                                                                                                                                                                                             *
     * Example: popext_fireinput{target = `bignet`, action = `RunScriptCode`, param = `ClientPrint(null, 3, `I spawned one second ago!`)`, delay = 1, activator = `activator_targetname_here`, caller = `caller_targetname_here` } *
     *******************************************************************************************************************************************************************************************************************************/

	popext_fireinput = function(bot, args) {

		DoEntFire(
			"target" in args ? args.target : args.type,
			"action" in args ? args.action : args.cooldown,
			"param" in args ? args.param : "",
			"delay" in args ? args.delay : -1,
			"activator" in args ? FindByName(null, args.activator) : null,
			"caller" in args ? FindByName(null, args.caller) : null
		 )
	}

    /*****************************************************************************
     * WEAPON RESIST                                                             *
     *                                                                           *
     * Accepts item index, item classname, and string name found in item_map.nut *
     *                                                                           *
     * 50% damage resistance to miniguns                                         *
     *                                                                           *
     * Example: popext_weaponresist{weapon = `tf_weapon_minigun`, amount = 0.5 } *
     *****************************************************************************/

	popext_weaponresist = function(bot, args) {

		local weapon = args.weapon ? args.weapon : args.type
		local amount = ("amount" in args) ? args.amount.tofloat() : args.cooldown.tofloat()

		PopExtTags.TakeDamageTable.WeaponResistTakeDamage <- function(params)
		{
			local player = params.const_entity
			if (!player.IsPlayer() || params.attacker == null || params.weapon == null || !PopExtUtil.HasItemInLoadout(player, params.weapon)) return

			if (params.damage * amount < player.GetHealth()) params.damage *= amount
		}
	}
    /****************************************
     *                                      *
     * SET CUSTOM SKIN INDEX                *
     *                                      *
     * use the red team skin no matter what *
     *                                      *
     * Example: popext_setskin{ skin = 2 }  *
     ****************************************/

	popext_setskin = function(bot, args) {

		SetPropBool(bot, "m_bForcedSkin", true)
		SetPropInt(bot, "m_nForcedSkin", ("skin" in args) ? args.skin.tointeger() : args.type.tointeger() )

		PopExtTags.TakeDamageTable.ResetSkin <- function(params) {

			local victim = params.const_entity

			if (victim == bot && params.damage > victim.GetHealth()) {
				SetPropBool(bot, "m_bForcedSkin", true)
				SetPropInt(bot, "m_nForcedSkin", 1)
				SetPropInt(bot, "m_iPlayerSkinOverride", 1)
			}
		}
		PopExtTags.TeamSwitchTable.ResetSkin <- function(params) {

			local b = GetPlayerFromUserID(params.userid)

			if (b == bot && params.team == TEAM_SPECTATOR) {
				SetPropBool(bot, "m_bForcedSkin", true)
				SetPropInt(bot, "m_nForcedSkin", 1)
				SetPropInt(bot, "m_iPlayerSkinOverride", 1)
			}
		}
	}

	//UNFINIHSED
	popext_doubledonk = function(bot, args) {

		bot.GetScriptScope().PlayerThinkTable.DoubleDonker <- function() {
			local distance = GetThreatDistanceSqr()
			printl("holdtime: " + (2 * exp(-distance / 10) + 0.5))
		}
	}

    /******************************************************************
     * DISPENSER OVERRIDE                                             *
     *                                                                *
     * When an engi-bot builds something, replace it with a dispenser *
     *                                                                *
     * replace sentry gun with a dispenser                            *
	 * 																  *
     * Example: popext_dispenseroverride{ type = OBJ_SENTRYGUN }      *
     ******************************************************************/

	popext_dispenseroverride = function(bot, args) {

		local alwaysfire = bot.HasBotAttribute(ALWAYS_FIRE_WEAPON)

		//force deploy dispenser when leaving spawn and kill it immediately
		if (!alwaysfire && args.type.tointeger() == 1) bot.PressFireButton(INT_MAX)

		bot.GetScriptScope().PlayerThinkTable.DispenserBuildThink <- function() {

			//start forcing primary attack when near hint
			local hint = FindByClassnameWithin(null, "bot_hint*", bot.GetOrigin(), 16)
				if (hint && !alwaysfire) bot.PressFireButton(0.0)
		}

		bot.GetScriptScope().BuiltObjectTable.DispenserBuildOverride <- function(params) {

			local obj = params.object

			//dispenser built, stop force firing
			if (!alwaysfire) bot.PressFireButton(0.0)

			if ((args.type.tointeger() == 1 && obj == OBJ_SENTRYGUN) || (args.type.tointeger() == 2 && obj == OBJ_TELEPORTER)) {
				if (obj == OBJ_SENTRYGUN) bot.AddCustomAttribute("engy sentry radius increased", FLT_SMALL, -1)

				bot.AddCustomAttribute("upgrade rate decrease", 8, -1)
				local building = EntIndexToHScript(params.index)
				if (obj != OBJ_DISPENSER) {

					building.ValidateScriptScope()
					building.GetScriptScope().CheckBuiltThink <- function() {

						if (GetPropBool(building, "m_bBuilding")) return

						EntFireByHandle(building, "Disable", "", -1, null, null)
						delete building.GetScriptScope().CheckBuiltThink
					}
					AddThinkToEnt(building, "CheckBuiltThink")
				}

				//kill the first alwaysfire built dispenser when leaving spawn
				local hint = FindByClassnameWithin(null, "bot_hint*", building.GetOrigin(), 16)

				if (!hint) {
					building.Kill()
					return
				}

				//hide the building
				building.SetModelScale(0.01, 0.0)
				SetPropInt(building, "m_nRenderMode", kRenderTransColor)
				SetPropInt(building, "m_clrRender", 0)
				building.SetHealth(INT_MAX)
				building.SetSolid(SOLID_NONE)

				PopExtUtil.SetTargetname(building, format("building%d", building.entindex()))

				//create a dispenser
				local dispenser = CreateByClassname("obj_dispenser")

				SetPropEntity(dispenser, "m_hBuilder", bot)

				PopExtUtil.SetTargetname(dispenser, format("dispenser%d", dispenser.entindex()))

				dispenser.SetTeam(bot.GetTeam())
				dispenser.SetSkin(bot.GetSkin())

				dispenser.DispatchSpawn()

				//post-spawn stuff

				// SetPropInt(dispenser, "m_iHighestUpgradeLevel", 2) //doesn't work

				local builder = PopExtUtil.GetItemInSlot(bot, SLOT_PDA)

				local builtobj = GetPropEntity(builder, "m_hObjectBeingBuilt")
				SetPropInt(builder, "m_iObjectType", 0)
				SetPropInt(builder, "m_iBuildState", 2)
				// if (builtobj && builtobj.GetClassname() != "obj_dispenser") builtobj.Kill()
				SetPropEntity(builder, "m_hObjectBeingBuilt", dispenser) //makes dispenser a null reference

				bot.Weapon_Switch(builder)
				builder.PrimaryAttack()

				//m_hObjectBeingBuilt messes with our dispenser reference, do radius check to grab it again
				for (local d; d = FindByClassnameWithin(d, "obj_dispenser", building.GetOrigin(), 128);)
					if (GetPropEntity(d, "m_hBuilder") == bot)
						dispenser = d

				dispenser.SetLocalOrigin(building.GetLocalOrigin())
				dispenser.SetLocalAngles(building.GetLocalAngles())

				AddOutput(dispenser, "OnDestroyed", building.GetName(), "Kill", "", -1, -1) //kill it to avoid showing up in killfeed
				AddOutput(building, "OnDestroyed", dispenser.GetName(), "Destroy", "", -1, -1) //always destroy the dispenser
			}
		}
	}

    /*****************************************************************************************************************************
     * SIMPLE GIVEWEAPON                                                                                                         *
     *                                                                                                                           *
     * THIS DOES NOT WORK WITH CUSTOM WEAPONS!!!                                                                                 *
     *                                                                                                                           *
     * You can technically give bots cosmetics using this function as well, but it's not recommended and the syntax is different *
     * Use PopExtUtil.CreatePlayerWearable instead                                                                               *
     *                                                                                                                           *
     * Add this to a pyro bot to give them a family business                                                                     *
     *                                                                                                                           *
     * Example: popext_giveweapon{ weapon = `tf_weapon_shotgun_pyro` id = 425 }                                                  *
     *****************************************************************************************************************************/

	popext_giveweapon = function(bot, args) {

		local weapon = CreateByClassname(args.weapon ? args.weapon : args.type)
		SetPropInt(weapon, STRING_NETPROP_ITEMDEF, "id" in args ? args.id.tointeger() : args.cooldown.tointeger())
		SetPropBool(weapon, "m_AttributeManager.m_Item.m_bInitialized", true)
		SetPropBool(weapon, "m_bValidatedAttachedEntity", true)
		weapon.SetTeam(bot.GetTeam())
		DispatchSpawn(weapon)

		PopExtUtil.GetItemInSlot(bot, weapon.GetSlot()).Destroy()

		bot.Weapon_Equip(weapon)

		return weapon
	}

    /**************************************************************************
     * MELEE WHEN CLOSE                                                       *
     *                                                                        *
     * Distance is radius in Hammer Units                                     *
     *                                                                        *
     * Example: popext_meleewhenclose{ distance = 250 }                       *
     **************************************************************************/

	popext_meleewhenclose = function(bot, args) {

		local dist = "distance" in args ? args.distance.tofloat() : args.type.tofloat()
		local previouswep = bot.GetActiveWeapon().entindex()

		bot.GetScriptScope().PlayerThinkTable.MeleeWhenClose <- function() {
			if (bot.IsEFlagSet(EFL_BOT)) return
			for (local p; p = FindByClassnameWithin(p, "player", bot.GetOrigin(), dist);) {

				if (p.GetTeam() == bot.GetTeam()) continue
				local melee = PopExtUtil.GetItemInSlot(bot, SLOT_MELEE)

				bot.Weapon_Switch(melee)
				melee.AddAttribute("disable weapon switch", 1, 1)
				melee.ReapplyProvision()
				bot.AddEFlags(EFL_BOT)
				EntFireByHandle(melee, "RunScriptCode", "self.RemoveAttribute(`disable weapon switch`); self.ReapplyProvision(); self.GetOwner().RemoveEFlags(EFL_BOT)", 1.1, null, null)
			}
		}
	}

    /********************************************************************************************************
     * USE BEST WEAPON                                                                                      *
	 * 																										*
     * A simple hardcoded set of weapon switching rules										 				*
     * Replicates the rafmod UseBestWeapon 1 keyvalue                                                       *
     * UseBestWeapon 1 simply enables the CTFBot::EquipBestWeaponForThreat code found in non-MvM bots       *
     *                                                                                                      *
     * No parameters required, only tag presence is necessary                                               *
     ********************************************************************************************************/

	popext_usebestweapon = function(bot, args) {

		bot.GetScriptScope().PlayerThinkTable.BestWeaponThink <- function() {

			switch(bot.GetPlayerClass()) {
			case 1: //TF_CLASS_SCOUT

				//scout and pyro's UseBestWeapon is inverted
				//switch them to secondaries, then back to primary when enemies are close

				if (bot.GetActiveWeapon() != PopExtUtil.GetItemInSlot(bot, SLOT_SECONDARY))
					bot.Weapon_Switch(PopExtUtil.GetItemInSlot(bot, SLOT_SECONDARY))

				for (local p; p = FindByClassnameWithin(p, "player", bot.GetOrigin(), 500);) {
					if (p.GetTeam() == bot.GetTeam()) continue
					local primary = PopExtUtil.GetItemInSlot(bot, SLOT_PRIMARY)

					bot.Weapon_Switch(primary)
					primary.AddAttribute("disable weapon switch", 1, 1)
					primary.ReapplyProvision()
				}
			break

			case 2: //TF_CLASS_SNIPER
				for (local p; p = FindByClassnameWithin(p, "player", bot.GetOrigin(), 750);) {
					if (p.GetTeam() == bot.GetTeam() || bot.GetActiveWeapon().GetSlot() == 2) continue //potentially not break sniper ai

					local secondary = PopExtUtil.GetItemInSlot(bot, SLOT_SECONDARY)

					bot.Weapon_Switch(secondary)
					secondary.AddAttribute("disable weapon switch", 1, 1)
					secondary.ReapplyProvision()
				}
			break

			case 3: //TF_CLASS_SOLDIER
				for (local p; p = FindByClassnameWithin(p, "player", bot.GetOrigin(), 500);) {
					if (p.GetTeam() == bot.GetTeam() || bot.GetActiveWeapon().Clip1() != 0) continue

					local secondary = PopExtUtil.GetItemInSlot(bot, SLOT_SECONDARY)

					bot.Weapon_Switch(secondary)
					secondary.AddAttribute("disable weapon switch", 1, 2)
					secondary.ReapplyProvision()
				}
			break

			case 7: //TF_CLASS_PYRO

				//scout and pyro's UseBestWeapon is inverted
				//switch them to secondaries, then back to primary when enemies are close
				//TODO: check if we're targetting a soldier with a simple raycaster, or wait for more bot functions to be exposed
				if (bot.GetActiveWeapon() != PopExtUtil.GetItemInSlot(bot, SLOT_SECONDARY))
					bot.Weapon_Switch(PopExtUtil.GetItemInSlot(bot, SLOT_SECONDARY))

				for (local p; p = FindByClassnameWithin(p, "player", bot.GetOrigin(), 500);) {
					if (p.GetTeam() == bot.GetTeam()) continue

					local primary = PopExtUtil.GetItemInSlot(bot, SLOT_PRIMARY)

					bot.Weapon_Switch(primary)
					primary.AddAttribute("disable weapon switch", 1, 1)
					primary.ReapplyProvision()
				}
			break
			}
		}
	}

    /***********************************************************************************************************************************
     * HOMING PROJECTILE                                                                                                               *
     *                                                                                                                                 *
     * See "HomingProjectiles" in util.nut for which projectiles will work with this tag                                               *
     *                                                                                                                                 *
     * no turn power or speed multipliers, don't ignore disguised spies                                                                *
     * Example: popext_homingprojectile{turn_power = 1.0, speed_mult = 1.0, ignoreStealthedSpies = true, ignoreDisguisedSpies = false} *
     *                                                                                                                                 *
     ***********************************************************************************************************************************/

	popext_homingprojectile = function(bot, args) {

		// Tag homingprojectile |turnpower|speedmult|ignoreStealthedSpies|ignoreDisguisedSpies
		local turn_power = "turn_power" in args ? args.turn_power : args.type
		local speed_mult = "speed_mult" in args ? args.speed_mult : args.cooldown
		local ignoreStealthedSpies = "ignoreStealted" in args ? args.ignoreStealthed : args.duration
		local ignoreDisguisedSpies = "ignoreDisguise" in args ? args.ignoreDisguise : args.delay

		bot.GetScriptScope().PlayerThinkTable.HomingProjectileScanner <- function() {

			for (local projectile; projectile = FindByClassname(projectile, "tf_projectile_*");) {
				if (projectile.GetOwner() != bot || !Homing.IsValidProjectile(projectile, PopExtUtil.HomingProjectiles)) continue
				// Any other parameters needed by the projectile thinker can be set here
				Homing.AttachProjectileThinker(projectile, speed_mult, turn_power, ignoreDisguisedSpies, ignoreStealthedSpies)
			}
		}

		PopExtTags.TakeDamageTable.HomingTakeDamage <- function(params) {

			if (!params.const_entity.IsPlayer()) return

			local classname = params.inflictor.GetClassname()
			if (classname != "tf_projectile_flare" && classname != "tf_projectile_energy_ring") return

			EntFireByHandle(params.inflictor, "Kill", null, 0.5, null, null)
		}
	}

    /*******************************************************************
     * CUSTOM ROCKET TRAIL                                   		   *
     *                                                                 *
     * purple monoculus trail (recommended for homing projectiles)     *
     *                                                                 *
     * Example: popext_rocketcustomtrail{name = `eyeboss_projectile` } *
     *******************************************************************/

	popext_rocketcustomtrail = function (bot, args) {

		bot.GetScriptScope().PlayerThinkTable.ProjectileTrailThink <- function() {

			for (local projectile; projectile = FindByClassname(projectile, "tf_projectile_*");) {

				if (projectile.IsEFlagSet(EFL_PROJECTILE) || GetPropEntity(projectile, "m_hOwnerEntity") != bot) continue

				EntFireByHandle(projectile, "DispatchEffect", "ParticleEffectStop", -1, null, null)

				local particle = CreateByClassname("trigger_particle")

				particle.KeyValueFromString("particle_name", "name" in args ? args.name : args.type)
				particle.KeyValueFromInt("attachment_type", PATTACH_ABSORIGIN_FOLLOW)
				particle.KeyValueFromInt("spawnflags", SF_TRIGGER_ALLOW_ALL)

				DispatchSpawn(particle)

				EntFireByHandle(particle, "StartTouch", "!activator", -1, projectile, projectile)
				EntFireByHandle(particle, "Kill", "", -1, null, null)

				projectile.AddEFlags(EFL_PROJECTILE)
			}
		}
	}
    /*************************************************************************************************
     * CUSTOM WEAPON MODEL                                                                           *
     *                                                                                               *
     * If no slot argument is supplied, this will default to slot 0.                                 *
     *                                                                                               *
     * Example: popext_customweaponmodel{ model = `models/player/heavy.mdl`, slot = SLOT_SECONDARY } *
     *************************************************************************************************/

	popext_customweaponmodel = function(bot, args) {

		local wep = "slot" in args ? PopExtUtil.GetItemInSlot(bot, args.slot) : PopExtUtil.GetItemInSlot(bot, 0)

		wep.SetModelSimple("model" in args ? args.model : args.type)
	}

    /************************************************************************************
     * CUSTOM SPAWN POINT                                                               *
     *                                                                                  *
     * uber duration is optional                                                        *
     *                                                                                  *
     * Example: popext_spawnhere{where = `ent_to_spawn_at`, spawn_uber_duration = 5.0 } *
     *                                                                                  *
     * You can also supply an xyz coordinate string instead of an entity targetname     *
     *                                                                                  *
     * Example: popext_spawnhere{where = `500 500 500`}                                 *
     ************************************************************************************/

	popext_spawnhere = function(bot, args) {
		if (FindByName(null, args.where) != null)
			bot.Teleport(true, FindByName(null, args.where).GetOrigin(), true, bot.EyeAngles(), true, bot.GetAbsVelocity())
		else
		{
			local org = split(args.where, " ")
			org.apply(function(val) { return val.tofloat() })
			bot.Teleport(true, Vector(org[0], org[1], org[2]), true, bot.EyeAngles(), true, bot.GetAbsVelocity())
		}

		bot.AddCondEx(TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED, "spawn_uber_duration" in args ? args.spawn_uber_duration.tofloat() : args.cooldown.tofloat(), null)
	}

    /******************************************************************************************************************
     * IMPROVED AIRBLAST                                                                                              *
     *                                                                                                                *
     * Bots with this tag will have significantly improved airblast behavior based on difficulty                      *
     *                                                                                                                *
     * Normal: deflect all deflectable projectiles in FOV, not just rockets/short circuit orbs/dragons fury fireballs *
     * Advanced: Snap eye angles to the projectile and deflect it away, regardless of FOV                             *
     * Expert: Always deflect projectile back to sender, regardless of FOV                                            *
     *                                                                                                                *
     * This behavior can be manually controlled with the "level" keyvalue.                                            *
     * If no parameters are passed and just the tag itself is present, it will default to bot difficulty              *
     *                                                                                                                *
     * Example: popext_improvedairblast{ level = 3 }                                                                  *
     * Example: popext_improvedairblast <- behavior based on bot difficulty                                           *
     ******************************************************************************************************************/

	popext_improvedairblast = function (bot, args) {

		local airblast_level = "level" in args ? args.level.tointeger() : bot.GetDifficulty()

		bot.GetScriptScope().PlayerThinkTable.ImprovedAirblastThink <- function() {

			for (local projectile; projectile = FindByClassname(projectile, "tf_projectile_*");) {

				if (projectile.GetTeam() == bot.GetTeam() || !this.IsValidProjectile(projectile, PopExtUtil.DeflectableProjectiles))
					continue

				if (aibot.GetThreatDistanceSqr(projectile) <= 67000 && aibot.IsVisible(projectile)) {

					switch (airblast_level) {

						case 1: // Basic Airblast, only deflect if in FOV

							if (!aibot.IsInFieldOfView(projectile))
								return
							break
						case 2: // Advanced Airblast, deflect regardless of FOV

						aibot.LookAt(projectile.GetOrigin(), INT_MAX, INT_MAX)
							break

						case 3: // Expert Airblast, deflect regardless of FOV back to Sender

							local owner = projectile.GetOwner()
							if (owner != null) {

								local owner_head = owner.GetAttachmentOrigin(owner.LookupAttachment("head"))
								aibot.LookAt(owner_head, INT_MAX, INT_MAX)
							}

							break
					}
					bot.PressAltFireButton(0.0)
				}
			}
		}
	}

    /************************************************************
     * AIM AT                                                   *
     *                                                          *
     * Aim at a specific attachment point on the current target *
	 *
     *  valid attachment points for most playermodels:          *
     *     - head                                               *
     *     - eyes                                               *
     *     - righteye/lefteye                                   *
     *     - foot_L/_R                                          *
     *     - back_upper/lower                                   *
     *     - hand_L/R                                           *
     *     - partyhat                                           *
     *     - doublejumpfx (scout)                               *
     *     - eyeglow_L/R                                        *
     *     - weapon_bone                                        *
     *     - weapon_bone_2/3/4                                  *
     *     - effect_hand_R                                      *
     *     - flag                                               *
     *     - prop_bone                                          *
     *     - prop_bone_1/2/3/4/5/6                              *
     *                                                          *
     * dance for me cowboy                                      *
     *                                                          *
     * Example: popext_aimat{ target = `foot_L` }               *
     ************************************************************/

	popext_aimat = function(bot, args) {
		bot.GetScriptScope().PlayerThinkTable.AimAtThink <- function()
		{
			foreach (player in PopExtUtil.HumanArray)
			{
				if (aibot.IsInFieldOfView(player))
				{
					aibot.LookAt(player.GetAttachmentOrigin(player.LookupAttachment("target" in args ? args.target : args.type)))
					break
				}
			}
		}
	}


	/*********************************************************************************************************************************************
	 * WARPAINTS:                                                                                                                                *
	 * Applies a warpaint to give a bot a decorated weapon.                                                                                      *
	 *                                                                                                                                           *
	 * @param idx int        Warpaint index to apply to the weapon.                                                                              *
	 * @param slot int?      Slot to apply to paintkit to (Default: Slot 0).                                                                     *
	 * @param wear flt?      Texture wear to apply to the warpaint (Default: Refers to "set_item_texture_wear", 0.0 if not set).                 *
	 * @param seed int?      Warpaint seed to use (Default: Refers to "custom_paintkit_seed_lo" and "custom_paintkit_seed_hi", none if not set). *
	 *                                                                                                                                           *
	 *  Texture wear reference values:                                                                                                           *
	 *   0.2 = Factory New                                                                                                                       *
	 *   0.4 = Minimal Wear                                                                                                                      *
	 *   0.6 = Field-Tested                                                                                                                      *
	 *   0.8 = Well-Worn                                                                                                                         *
	 *   1.0 = Battle Scarred                                                                                                                    *
	 *                                                                                                                                           *
	 * The following popfile example with all optional parameters provided would apply a                                                         *
	 * Battle Scarred Macaw Masked warpaint to a bot soldier's rocket launcher, with the                                                         *
	 * "White Gem" seed set.                                                                                                                     *
	 *                                                                                                                                           *
	 * TFBot                                                                                                                                     *
	 * {                                                                                                                                         *
	 *     Class Soldier                                                                                                                         *
	 *     Item "Upgradeable TF_WEAPON_ROCKETLAUNCHER"                                                                                           *
	 *     Tag "popext_warpaint{ idx = 303, slot = 0, wear = 1.0, seed = `8873643875`}"                                                          *
	 * }                                                                                                                                         *
	 *                                                                                                                                           *
	 * Implementation note: seeds can be passed as strings or integers on 64-bit servers                                                         *
	 * (integers would be preferable), but they MUST be passed as strings on 32-bit servers.                                                     *
	 * Pass seeds as strings if you are uncertain of what version of TF2 you are targeting.                                                      *
	 *********************************************************************************************************************************************/

	popext_warpaint = function(bot, args) {

		local slot = 0
		// Check if the mission maker specified a slot.
		if ("slot" in args && args.slot != null)
			slot = args.slot.tointeger()
		// If no slot index is provided, use slot 0 as a default.
		//  We can't use bot.GetActiveWeapon() to guess the slot to apply to, as the bot
		//   will always have its first slot active pre-spawn if it has any weapons.

		// Get the weapon in the slot provided.
		local weapon = null
		local notfound = true
		for (local i = 0; i < SLOT_COUNT; ++i) {
			weapon = GetPropEntityArray(bot, "m_hMyWeapons", i)
			if (weapon == null || weapon.GetSlot() != slot) continue
			notfound = false
			break
		}
		// Throw an error and early return if the weapon in the specified slot could not be
		//  found.
		if (notfound) {
			local e = format("popext_warpaint: Bot '%%s' does not have a weapon in slot %i.", slot)
			// We must delay the error message by 1 tick in order to get the proper bot name.
			EntFireByHandle(bot, "RunScriptCode",
				format(@"local e = format(`%s`, GetPropString(self, `m_szNetname`))
				ClientPrint(null, HUD_PRINTCONSOLE, e)
				if (!GetListenServerHost()) printl(e)", e)
			, SINGLE_TICK, null, null)
			return
		}

		// Set "paintkit_proto_def_index" by interpreting the index as a float value, as the
		//  attribute type is set incorrectly by the game.
		weapon.AddAttribute("paintkit_proto_def_index", casti2f(args.idx.tointeger()), -1)

		// Set item texture wear.
		//  This must be present or the warpaint will not render, so we set to 0.0 if a
		//   value is not provided nor already present on the weapon.
		local wear = "wear" in args ? args.wear.tofloat() : weapon.GetAttribute("set_item_texture_wear", 0.0)
		weapon.AddAttribute("set_item_texture_wear", wear, -1)

		// Warpaint seeds are controlled by a single 64-bit integer, which is set through two
		//  32-bit integers interpreted as a float value (for the same reason as the
		//   warpaint index), which are:
		//    "custom_paintkit_seed_lo" (the lower bits),
		//    "custom_paintkit_seed_hi" (the higher bits).
		// A seed does not need to be provided in order for the warpaint to render.
		if ("seed" in args) {

			// Simple operation if we are on 64-bit.
			//  Split the 64-bit seed provided to two int32 values.
			if (_intsize_ == 8) {
				// This will overflow a Squirrel int as they're signed, but we don't care
				//  since we only want the bits; the value is irrelevant.
				local seed = args.seed.tointeger()
				weapon.AddAttribute("custom_paintkit_seed_lo", casti2f(seed & 0xFFFFFFFF), -1)
				weapon.AddAttribute("custom_paintkit_seed_hi", casti2f(seed >> 32), -1)
			}

			// More involved if we are on 32-bit.
			// DEPRECATED: This will be removed once 32-bit TF2 support is dropped.
			else {
				// Decompose a 64-bit decimal seed string in to four 16-bit integers,
				//  and then compile the resulting integers to two 32 bit integers.
				local seed = args.seed.tostring()
				local strlen = seed.len()
				local digitstore = array(strlen, 0)

				for (local i = 0; i < strlen; ++i) {
					local carry = seed[i] - 48
					local tmp = 0

					for (local i = (strlen - 1); (i >= 0); --i) {
						tmp = (digitstore[i] * 10) + carry
						digitstore[i] = tmp & 0xFFFF
						carry = tmp >> 16
					}
				}

				weapon.AddAttribute("custom_paintkit_seed_lo", casti2f(
					digitstore[strlen - 2] << 16 | digitstore[strlen - 1]
				), -1)
				weapon.AddAttribute("custom_paintkit_seed_hi", casti2f(
					digitstore[strlen - 4] << 16 | digitstore[strlen - 3]
				), -1)
			}
		}
	}

	// UNFINISHED
	// no way to get a table of all attributes on a given player/weapon in VScript
	// this can still be worked around by having the mission maker fill out the attributes they want manually re-applied to the weapon when it's picked up
	// too much work for such a niche feature for now

	popext_dropweapon = function(bot, args) {

		bot.GetScriptScope().DeathHookTable.DropWeaponDeath <- function(params) {

			printl("dropping weapon")
			local slot = args.type ? args.type.tointeger() : -1
			local wep  = (slot == -1) ? bot.GetActiveWeapon() : PopExtUtil.GetItemInSlot(bot, slot)
			if (wep == null) return

			local itemid = PopExtUtil.GetItemIndex(wep)
			local wearable = CreateByClassname("tf_wearable")

			SetPropBool(wearable, "m_AttributeManager.m_Item.m_bInitialized", true)
			SetPropInt(wearable, STRING_NETPROP_ITEMDEF, itemid)

			wearable.DispatchSpawn()

			local modelname = wearable.GetModelName()

			wearable.Destroy()

			local droppedweapon = CreateByClassname("tf_dropped_weapon")
			SetPropInt(droppedweapon, "m_Item.m_iItemDefinitionIndex", itemid)
			SetPropInt(droppedweapon, "m_Item.m_iEntityLevel", 5)
			SetPropInt(droppedweapon, "m_Item.m_iEntityQuality", 6)
			SetPropBool(droppedweapon, "m_Item.m_bInitialized", true)
			droppedweapon.SetModelSimple(modelname)
			droppedweapon.SetOrigin(bot.GetOrigin())

			droppedweapon.DispatchSpawn()

			// Store attributes in scope, when it gets picked up add the attributes to the real weapon

		}
	}

    /*****************************************************************************************************************************************************************
     * HALLOWEEN BOSS SPAWNER                                                                                                                                        *
     *                                                                                                                                                               *
     * Associate a halloween boss with this bot spawn.  Accepts halloween boss entity names				                                                             *
     *                                                                                                                                                               *
     * "Where" can be xyz coordinates or an entity targetname.  Duration is optional and is how long you want the boss to exist before escaping/dying on its own     *
     *                                                                                                                                                               *
     * Example: popext_halloweenboss{type = `headless_hatman`, where = `halloween_boss_spawnpoint`, health = 5000, duration = 100, boss_team = TF_TEAM_PVE_INVADERS} *
     *                                                                                                                                                               *
     * "Health" can also be set to "BOTHP" if you wish to use the spawned TFBots health value instead of a different one                                             *
     *                                                                                                                                                               *
     * Example: popext_halloweenboss{type = `merasmus`, where = `500 500 500`, health = `BOTHP`, duration = 60, boss_team = 5}                                       *
     *****************************************************************************************************************************************************************/

	popext_halloweenboss = function(bot, args) {

		if (!("bosskiller" in ROOT)) ::bosskiller <- null

		local scope = bot.GetScriptScope()

		if ("halloweenboss" in scope) return

		local boss = CreateByClassname(args.type)

		scope.halloweenboss <- boss

		local org = split(args.where, " ")

		if (org.len() > 1)
			org.apply(function(v) { return v.tofloat()})
		else
		{
			local entorg = FindByName(null, org[0]).GetOrigin()
			org = [entorg.x, entorg.y, entorg.z]
		}

		boss.SetOrigin(Vector(org[0], org[1], org[2]))

		boss.SetTeam(args.boss_team)

		DispatchSpawn(boss)

		local bosshealth = 0
		args.health == "BOTHP" ? bosshealth = bot.GetHealth() : bosshealth = args.health.tointeger()

		boss.SetHealth(bosshealth)

		if (args.type != "headless_hatman")
		{
			local eventname = ""
			args.type = "eyeball_boss" ? eventname = "eyeball_boss_escape_imminent" : eventname = "merasmus_escape_warning"
			SendGlobalGameEvent(eventname, {time_remaining 	= args.duration.tointeger()})
		}
		else
			EntFireByHandle(boss, "RunScriptCode", "self.TakeDamage(INT_MAX, DMG_GENERIC, self)", args.duration.tointeger(), null, null)

		PopExtUtil.MonsterResource.ValidateScriptScope()

		PopExtUtil.MonsterResource.GetScriptScope().HealthBarThink <- function() {

			if (!boss.IsValid())
			{
				delete PopExtUtil.MonsterResource.GetScriptScope().HealthBarThink
				return
			}

			local barvalue = (boss.GetHealth().tofloat() / bosshealth.tofloat()) * 255

			if (barvalue < 0) barvalue = 0

			SetPropInt(PopExtUtil.MonsterResource, "m_iBossHealthPercentageByte", barvalue)
			return -1
		}
		AddThinkToEnt(PopExtUtil.MonsterResource, "HealthBarThink")

		scope.PlayerThinkTable.BossHealthThink <- function() {

			if (scope.halloweenboss.IsValid() && boss.GetHealth() != bot.GetHealth() && args.health == "BOTHP")
				bot.SetHealth(boss.GetHealth())

			if (scope.halloweenboss.IsValid()) return

			local uberconds = [TF_COND_INVULNERABLE, TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED, TF_COND_INVULNERABLE_CARD_EFFECT, TF_COND_INVULNERABLE_USER_BUFF, TF_COND_PHASE]
			foreach (cond in uberconds)
					bot.RemoveCondEx(cond, true)

			bot.TakeDamage(INT_MAX, DMG_GENERIC, bosskiller)
		}
	}

    /**********************************************************
     * TELEPORT NEAR VICTIM                                   *
     *                                                        *
     * Similar to spy teleportation behavior                  *
     *                                                        *
     * No parameters required, only tag presence is necessary *
     **********************************************************/

	popext_teleportnearvictim = function(bot, args) {

		local bot_scope = bot.GetScriptScope()
		bot_scope.TeleportAttempt <- 0
		bot_scope.NextTeleportTime <- Time()
		bot_scope.Teleported <- false

		bot_scope.PlayerThinkTable.TeleportNearVictimThink <- function() {

			if (!bot_scope.Teleported && bot_scope.NextTeleportTime <= Time() && !bot.HasItem()) {
				local victim = null
				local players = []

				foreach (player in PopExtUtil.HumanArray)
					if (PopExtUtil.IsAlive(player))
						players.push(player)


				local n = players.len()
				while (n > 1) {
					local k = RandomInt(0, n - 1)
					n--

					local tmp = players[n]
					players[n] = players[k]
					players[k] = tmp
				}

				foreach (player in players) {
					if (PopExtUtil.TeleportNearVictim(bot, player, bot_scope.TeleportAttempt)) {
						victim = player
						break
					}
				}

				if (victim == null) {
					bot_scope.NextTeleportTime = Time() + 1.0
					++bot_scope.TeleportAttempt
					return
				}

				bot_scope.Teleported = true
			}
		}
	}
}
::Homing <- {
	// Modify the AttachProjectileThinker function to accept projectile speed adjustment if needed
	function AttachProjectileThinker(projectile, speed_mult, turn_power, ignoreDisguisedSpies = true, ignoreStealthedSpies = true) {

		projectile.ValidateScriptScope()
		local projectile_scope = projectile.GetScriptScope()
		if (!("speedmultiplied" in projectile_scope)) projectile_scope.speedmultiplied <- false

		local projectile_speed = projectile.GetAbsVelocity().Norm()

		if (!projectile_scope.speedmultiplied) {
			projectile_speed *= speed_mult
			projectile_scope.speedmultiplied = true
		}
		// printl("speed: " + projectile_speed)

		projectile_scope.turn_power			  <- turn_power
		projectile_scope.projectile_speed	  <- projectile_speed
		projectile_scope.ignoreDisguisedSpies <- ignoreDisguisedSpies
		projectile_scope.ignoreStealthedSpies <- ignoreStealthedSpies

		//this should be added in globalfixes.nut but sometimes this code tries to run before the table is created
		if (!("ProjectileThinkTable" in projectile_scope)) projectile_scope.ProjectileThinkTable <- {}

		projectile_scope.ProjectileThinkTable.HomingProjectileThink <- Homing.HomingProjectileThink
	}

	function HomingProjectileThink() {
		local new_target = Homing.SelectVictim(self)
		if (new_target != null && Homing.IsLookingAt(self, new_target))
			Homing.FaceTowards(new_target, self, projectile_speed)
	}

	function SelectVictim(projectile) {
		local target
		local min_distance = 32768.0
		foreach (player in PopExtUtil.HumanArray) {

			local distance = (projectile.GetOrigin() - player.GetOrigin()).Length()

			if (IsValidTarget(player, distance, min_distance, projectile)) {
				target = player
				min_distance = distance
			}
		}
		return target
	}

	function IsValidTarget(victim, distance, min_distance, projectile) {

		local projectile_scope = projectile.GetScriptScope()
		// Early out if basic conditions aren't met
		if (distance > min_distance || victim.GetTeam() == projectile.GetTeam() || !PopExtUtil.IsAlive(victim)) {
			return false
		}

		// Check for conditions based on the projectile's configuration
		if (victim.IsPlayer()) {
			if (victim.InCond(TF_COND_HALLOWEEN_GHOST_MODE)) {
				return false
			}

			// Check for stealth and disguise conditions if not ignored
			if (!projectile_scope.ignoreStealthedSpies && (victim.IsStealthed() || victim.IsFullyInvisible())) {
				return false
			}
			if (!projectile_scope.ignoreDisguisedSpies && victim.GetDisguiseTarget() != null) {
				return false
			}
		}

		return true
	}


	function FaceTowards(new_target, projectile, projectile_speed) {
		local scope = projectile.GetScriptScope()
		local desired_dir = new_target.EyePosition() - projectile.GetOrigin()

		desired_dir.Norm()

		local current_dir = projectile.GetForwardVector()
		local new_dir = current_dir + (desired_dir - current_dir) * scope.turn_power
		// printl("Dir: " + new_dir)
		new_dir.Norm()

		local move_ang = PopExtUtil.VectorAngles(new_dir)
		local projectile_velocity = move_ang.Forward() * projectile_speed

		projectile.SetAbsVelocity(projectile_velocity)
		projectile.SetLocalAngles(move_ang)
	}

	function IsLookingAt(projectile, new_target) {
		local target_origin = new_target.GetOrigin()
		local projectile_owner = projectile.GetOwner()
		local projectile_owner_pos = projectile_owner.EyePosition()

		if (TraceLine(projectile_owner_pos, target_origin, projectile_owner)) {
			local direction = (target_origin - projectile_owner.EyePosition())
				direction.Norm()
			local product = projectile_owner.EyeAngles().Forward().Dot(direction)

			if (product > 0.6)
				return true
		}

		return false
	}

	function IsValidProjectile(projectile, table) {
		if (projectile.GetClassname() in table)
			return true

		return false
	}

}

::PopExtTags <- {

	TakeDamageTable = {}
	DeathHookTable = {}
	TeamSwitchTable = {}

	function ParseTagArguments(bot, tag) {

		if (!tag.find("{") && !tag.find("|")) return {}

		//table of all possible keyvalues for all tags
		//required table values will still be filled in for efficiency sake, but given a null value to throw a type error
		//any newly added tags should similarly ensure any required keyvalues do not silently fail.
		local tagtable = {

			//required tags
			type = null
			button = null
			slot = null
			weapon = null
			where = null

			//default values
			health = 0.0
			delay = 0.0
			duration = INT_MAX
			cooldown = 3.0
			delay = 0.0
			repeats = INT_MAX
			ifhealthbelow = INT_MAX
			charges = INT_MAX
			ifseetarget = 1
			damage = 7.5
			radius = 135.0
			amount = 0.0
			interval = 0.5
			uber = 0.0
		}

		//these ones aren't as re-usable as other kv's
		if (startswith(tag, "popext_homing"))
		{
			tagtable.ignoreDisguisedSpies <- true
			tagtable.ignoreStealthedSpies <- true
			tagtable.speed_mult <- 1.0
			tagtable.turn_power <- 1.0
		}

		local separator = tag.find("{") ? "{" : "|"

		local splittag = split(tag, separator)

		if (separator ==  "|")
		{
			ClientPrint(null, 2, "Pipe syntax is deprecated! Newer tags will not use this syntax")
			local args = splittag
			local func = args.remove(0)

			local args_len = args.len()

			tagtable.type = args[0] //type will always be a generic reference to the first element, so we don't need to make a zillion one-off references for single-arg tags

			if (args_len > 1) tagtable.cooldown = args[1].tofloat()
			if (args_len > 1 && func == "popext_halloweenboss") tagtable.boss_health = args[1].tointeger()
			if (args_len > 2) tagtable.duration = args[2].tofloat()
			if (args_len > 3) tagtable.delay = func == "popext_spell" ? args[2].tofloat() : args[3].tofloat() //popext_spell is stupid and backwards, too late to change now
			if (args_len > 4) tagtable.repeats = func == "popext_spell" ? args[3].tointeger() : args[4].tointeger()
			if (args_len > 5) tagtable.ifhealthbelow = "popext_spell" ? args[4].tointeger() : args[5].tointeger()
			if (args_len > 5 && func == "popext_spell") tagtable.charges = args[5].tointeger()
			if (args_len > 6) tagtable.ifseetarget = args[6]

			if (func == "popext_ringoffire")
			{
				tagtable.damage = args[0].tofloat()
				if (args_len > 1) tagtable.interval = args[1].tofloat()
				if (args_len > 2) tagtable.radius = args[2].tofloat()

			} else if (func == "popext_spawnhere") {

				tagtable.where = args[0]
				if (args_len > 1) tagtable.spawn_uber_duration <- args[1].tofloat()

			} else if (func == "popext_halloweenboss") {

				if (args_len > 3) tagtable.boss_duration <- args[3].tofloat()
				if (args_len > 4) tagtable.boss_team <- args[4].tointeger()

			} else if (func == "popext_customattr" || func == "popext_giveweapon") {
				tagtable.attribute <- null
				tagtable.value <- null
				tagtable.weapon <- func == "popext_giveweapon" ? args[0] : args_len > 3 ? args[3] : tagtable.weapon <- bot.GetActiveWeapon()
			} else if (func ==  "popext_actionpoint") {
				tagtable.next_action_point <- ""
				tagtable. desired_distance <- 10
				tagtable.stay_time <- 3
				tagtable.command <- ""
			}

		} else if (separator == "{") {
			// Allow inputting strings in new-style tags using backticks.
			local arr = split(splittag[1], "`")
			local end = arr.len() - 1
			if (end > 1) {
				local str = ""
				foreach (i, sub in arr) {
					if (i == end) {
						str += sub
						break
					}
					str += sub + "\""
				}
				compilestring(format("::__popexttagstemp <- { %s", str))()
			} else {
				compilestring(format("::__popexttagstemp <- { %s", splittag[1]))()
			}

			foreach(k, v in ::__popexttagstemp) tagtable[k] <- v

			delete ::__popexttagstemp
		}
		if (!splittag.len()) return tagtable

		return tagtable
	}

	function EvaluateTags(bot) {

		local bottags = {}

		bot.GetAllBotTags(bottags)

		//bot has no tags
		if (!bottags.len()) return

		foreach(i, tag in bottags) {

			// local args = split(tag, "|")
			// local func = args.remove(0)

			local func = ""; tag.find("|") ? func = split(tag, "|")[0] : func = split(tag, "{")[0]
			local args = PopExtTags.ParseTagArguments(bot, tag)

			if (func in popext_funcs) popext_funcs[func](bot, args)

		}
	}

	function OnScriptHook_OnTakeDamage(params) {

		foreach (_, func in this.TakeDamageTable) { func(params) }
	}

	function OnGameEvent_player_team(params) {

		local bot = GetPlayerFromUserID(params.userid)
		if (params.team == TEAM_SPECTATOR) _AddThinkToEnt(bot, null)

		foreach (_, func in this.TeamSwitchTable) func(params)
	}

	function OnGameEvent_player_death(params) {

		local bot = GetPlayerFromUserID(params.userid)
		if (!bot.IsBotOfType(TF_BOT_TYPE)) return

		local scope = bot.GetScriptScope()
		bot.ClearAllBotTags()
		foreach (_, func in this.DeathHookTable) func(params)

		_AddThinkToEnt(bot, null)
	}
	function OnGameEvent_teamplay_round_start(params) {

		foreach (bot in PopExtUtil.BotArray)
			if (bot.GetTeam() != TEAM_SPECTATOR)
				bot.ForceChangeTeam(TEAM_SPECTATOR, true)
	}
	function OnGameEvent_halloween_boss_killed(params) {
		::bosskiller <- GetPlayerFromUserID(params.killer)
	}
}
__CollectGameEventCallbacks(PopExtTags)
