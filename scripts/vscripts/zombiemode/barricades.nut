const BREAK_RADIUS = 120;

::BarricadeModel <-	// use prop_dynamic health to get model
[
	"models/empty.mdl",
	"models/empty.mdl",
	"models/empty.mdl",
	"models/propper/zm_redridge/barricade_2_0.mdl",
	"models/propper/zm_redridge/barricade_2.mdl",
	"models/propper/zm_redridge/barricade_3.mdl",
	"models/propper/zm_redridge/barricade_4.mdl",
	"models/propper/zm_redridge/barricade_5.mdl",
]

::Barricades <-
{
	function CheckBarricade(self)
	{
		local barricade = null
		local scope = self.GetScriptScope().Preserved
		if (!self.IsAlive() || scope.isenteringlevel == 0) return
		barricade; barricade = Entities.FindByNameWithin(barricade, "barricade*", self.GetOrigin(), BREAK_RADIUS);	// does this support fuzzy search?
		if (barricade == null)
		{
	//		printl(format("Bot at --(%s)-- couldn't find barricade!!", self.GetOrigin().tostring()))
			SetPropInt(self,"m_nRenderMode",0)
			return
		}
		local health = barricade.GetHealth()
		local botmodel = self.GetModelName()
		if (health > 2)
		{
			AttackBarricade(self,barricade)
		}
		else
		{
			if (scope.zombie_type <= 3)
			{
				// make invisible and do flip animation to go over door prop
				scope.isenteringlevel = 0
				self.AddCustomAttribute("no_jump", 1, 3)
				self.AddCustomAttribute("no_duck", 1, 3)
				self.AddCustomAttribute("no_attack", 1, 3)
				self.AddCustomAttribute("mult_player_movespeed_active", 0.0001, 0.7)
				self.AddCustomAttribute("move speed bonus", 0.6, 3)
				SetPropInt(self,"m_nRenderMode",10)
			
				local bot_anim = Entities.CreateByClassname("tf_wearable");
				NetProps.SetPropInt(bot_anim, "m_nModelIndex", PrecacheModel(botmodel));
				NetProps.SetPropBool(bot_anim, "m_bValidatedAttachedEntity", true);
				NetProps.SetPropBool(bot_anim, "m_AttributeManager.m_Item.m_bInitialized", true);
				bot_anim.SetOwner(self);
				bot_anim.DispatchSpawn();
				NetProps.SetPropInt(bot_anim, "m_fEffects", 0); bot_anim.SetAbsOrigin(self.GetOrigin());
				bot_anim.AcceptInput("SetParent", "!activator", self, null);
			
				bot_anim.ResetSequence(bot_anim.LookupSequence("taunt_flip_success_receiver"))
				EntFireByHandle(bot_anim, "Kill", "", 3, null, null)
				EntFireByHandle(self, "runscriptcode", "SetPropInt(self,`m_nRenderMode`,0)", 3, null, self)
				EntFireByHandle(self, "runscriptcode", "SetPropInt(self,`m_nRenderMode`,0)", 3.1, null, self)
				EntFireByHandle(self, "runscriptcode", "SetPropInt(self,`m_nRenderMode`,0)", 3.2, null, self)
			}
			if (scope.zombie_type > 3 && scope.zombie_type < 5 || scope.zombie_type == 11)
			{
				self.GetLocomotionInterface().Jump()
				scope.isenteringlevel = 0
			}
			if (scope.zombie_type > 7 && scope.zombie_type <= 9)
			{
				self.GetLocomotionInterface().Jump()
				scope.isenteringlevel = 0
			}
		}
	}
	function AttackBarricade(self,barricade)
	{
		self.StopTaunt(false)	// cancel active taunt before it loops back to starting
		local botmodel = self.GetModelName()
		local scope = self.GetScriptScope().Preserved
		self.AddCustomAttribute("no_jump", 1, 4)
		self.AddCustomAttribute("no_duck", 1, 4)
		self.AddCustomAttribute("move speed bonus", 0.000001, 4)
		self.GetLocomotionInterface().ClearStuckStatus("I'm not stuck, attacking a barricade")
		scope.warpcooldown = Time() + (BREAK_RADIUS - 100)	// reset teleport timer so the bot doesn't warp while whacking a barricade
		if (scope.zombie_type <= 3)
		{
			self.AddCustomAttribute("no_attack", 1, 4)
			SetPropInt(self,"m_nRenderMode",10)
			local bot_anim = Entities.CreateByClassname("tf_wearable");
			NetProps.SetPropInt(bot_anim, "m_nModelIndex", PrecacheModel(botmodel));
			NetProps.SetPropBool(bot_anim, "m_bValidatedAttachedEntity", true);
			NetProps.SetPropBool(bot_anim, "m_AttributeManager.m_Item.m_bInitialized", true);
			bot_anim.SetOwner(self);
			bot_anim.SetTeam(self.GetTeam());
			bot_anim.DispatchSpawn();
			NetProps.SetPropInt(bot_anim, "m_fEffects", 0); bot_anim.SetAbsOrigin(self.GetOrigin());
			bot_anim.AcceptInput("SetParent", "!activator", self, null);	
			bot_anim.ResetSequence(bot_anim.LookupSequence("taunt_headbutt_success"))
			EntFireByHandle(barricade,"runscriptcode",Barricades.UpdateBarricadeHealth(self,barricade),0, null, null)
			EntFireByHandle(bot_anim, "KillHierarchy", "", 4, null, null)
			EntFireByHandle(self, "runscriptcode", "Barricades.CheckBarricade(self)", 4, null, null)
		}
		if (scope.zombie_type > 3 && scope.zombie_type <= 5 || scope.zombie_type == 10)
		{
			self.PressFireButton(0.5)
			EntFireByHandle(barricade,"runscriptcode",Barricades.UpdateBarricadeHealth(self,barricade),0, null, null)
			EntFireByHandle(self, "runscriptcode", "Barricades.CheckBarricade(self)", 1.2, null, null)
		}
		if (scope.zombie_type == 7)
		{
			self.PressFireButton(0.5)
			EntFireByHandle(barricade,"runscriptcode",Barricades.UpdateBarricadeHealth(self,barricade),0, null, null)
			EntFireByHandle(self, "runscriptcode", "Barricades.CheckBarricade(self)", 1, null, null)
		}
		if (scope.zombie_type > 7 && scope.zombie_type <= 9 && scope.zombie_type != 11)
		{
			self.PressFireButton(0.5)
			EntFireByHandle(barricade,"runscriptcode",Barricades.UpdateBarricadeHealth(self,barricade),0, null, null)
			EntFireByHandle(self, "runscriptcode", "Barricades.CheckBarricade(self)", 1.2, null, null)
		}
		if (scope.zombie_type == 11)
		{
			self.PressFireButton(1.2)
			EntFireByHandle(barricade,"runscriptcode",Barricades.UpdateBarricadeHealth(self,barricade),0, null, null)
			EntFireByHandle(self, "runscriptcode", "Barricades.CheckBarricade(self)", 0.4, null, null)
		}
	}
	function UpdateBarricadeHealth(self,barricade)
	{
			local scope = self.GetScriptScope().Preserved
			local health = barricade.GetHealth()
			health = health - 1
			if (health < 1)
			{
				health = 1
			}
			local planks = SpawnEntityFromTable("func_breakable",
			{
			targetname = "planks"
		//	propdata = 4
			material = 1
			spawnflags = 1
			explosion = 0
		//	gibdir = barricade.GetAngles()
			origin = barricade.GetOrigin()
			})
			if (scope.zombie_type <= 3)
			{
				EntFireByHandle(barricade,"SetHealth",health.tostring(),0.2,null,null)
				EntFireByHandle(barricade, "SetModel", BarricadeModel[health], 1.9, null, null)
				EntFireByHandle(planks, "Break","", 1.9, null, null)
			}
			else
			{
				planks.AcceptInput("Break","",null,null)
				barricade.AcceptInput("SetHealth",health.tostring(),null,null)
				barricade.AcceptInput("SetModel",BarricadeModel[health],null,null)
			}
	}
	function RepairBarricade(self,barricade)
	{
		local health = barricade.GetHealth()
		local currency = GetPropInt(FindByClassname(null, "tf_mann_vs_machine_stats"),"m_currentWaveStats.nCreditsAcquired")
		if (health == 7) return
		health = health + 1
		if (health > 7)
		{
			health = 7
		}
		EntFireByHandle(barricade,"SetHealth",health.tostring(), 1, null, null)
		EntFireByHandle(barricade, "runscriptcode", "EmitSoundEx({ sound_name = `Breakable.MatWood`, origin = self.GetCenter(), filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT});",1, null, null)
		EntFireByHandle(barricade, "SetModel", BarricadeModel[health],1, null, null)
		if (self.GetScriptScope().Preserved.timesrepaired <= 5)
		{
			PopExtUtil.PlaySoundOnClient(self,"mvm/mvm_bought_upgrade.wav",0.7,100)
			self.RemoveCurrency(-10 * self.GetScriptScope().Preserved.multiplier)
			currency = currency + (10 * self.GetScriptScope().Preserved.multiplier)
			SetPropInt(FindByClassname(null, "tf_player_manager"),"m_iCurrencyCollected",currency)
			SetPropInt(FindByClassname(null, "tf_mann_vs_machine_stats"),"m_currentWaveStats.nCreditsAcquired",currency)
			SetPropInt(FindByClassname(null, "tf_mann_vs_machine_stats"),"m_currentWaveStats.nCreditsDropped",currency)
			self.GetScriptScope().Preserved.timesrepaired = self.GetScriptScope().Preserved.timesrepaired + (BREAK_RADIUS - 119)
		}
	}
	function ClearLevelCheck(self)
	{
		local scope = self.GetScriptScope().Preserved
		scope.isenteringlevel = 0
	}
}