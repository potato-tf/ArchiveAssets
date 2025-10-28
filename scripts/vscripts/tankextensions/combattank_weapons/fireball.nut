local COMBATTANK_VALUES_TABLE = {
	COMBATTANK_FIREBALL_BURN_DAMAGE_BONUS  = Convars.GetFloat("tf_fireball_burning_bonus") // 3
	COMBATTANK_FIREBALL_BURN_DURATION      = Convars.GetFloat("tf_fireball_burn_duration") // 2
	COMBATTANK_FIREBALL_CONE_RADIUS        = 15
	COMBATTANK_FIREBALL_DAMAGE             = Convars.GetFloat("tf_fireball_damage") // 25
	COMBATTANK_FIREBALL_MODEL              = "models/bots/boss_bot/combat_tank_mk2/mk2_fireball.mdl"
	COMBATTANK_FIREBALL_RECHARGE_TIME      = 0.8
	COMBATTANK_FIREBALL_SND_FIRE           = "Weapon_DragonsFury.Single"
}
foreach(k,v in COMBATTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(COMBATTANK_FIREBALL_MODEL)
TankExt.PrecacheSound(COMBATTANK_FIREBALL_SND_FIRE)
TankExt.PrecacheParticle("projectile_fireball")

::CombatTankFireballEvents <- {
	OnGameEvent_recalculate_holidays = function(_) { if(GetRoundState() == 3) delete ::CombatTankFireballEvents }
	OnScriptHook_OnTakeDamage = function(params)
	{
		local hAttacker = params.attacker
		local hVictim   = params.const_entity
		if(hAttacker && hVictim && hAttacker.GetClassname() == "combattank_fireball")
		{
			// this is horrible
			local vecVelocity = hVictim.GetAbsVelocity()
			if(vecVelocity.LengthSqr() > 1 && vecVelocity.z != Convars.GetFloat("sv_gravity") * -FrameTime())
				EntFire("bignet", "RunScriptCode", format("activator.SetAbsVelocity(Vector(%f, %f, %f)); SetPropInt(activator, `m_takedamage`, DAMAGE_NO); EntFireByHandle(self, `RunScriptCode`, `SetPropInt(activator, \\`m_takedamage\\`, DAMAGE_YES)`, FrameTime(), activator, null)", vecVelocity.x, vecVelocity.y, vecVelocity.z), -1, hVictim)

			params.damage = 0
			local hAttacker_scope = hAttacker.GetScriptScope()
			if(hAttacker.GetTeam() != hVictim.GetTeam() && !(hVictim in hAttacker_scope.HitEntities))
			{
				hAttacker_scope.HitEntities[hVictim] <- null
				local hOwner = hAttacker.GetOwner()

				params.attacker        = hOwner
				params.damage          = COMBATTANK_FIREBALL_DAMAGE
				params.damage_type     = DMG_IGNITE | DMG_USEDISTANCEMOD | DMG_NOCLOSEDISTANCEMOD
				params.damage_position = hAttacker.GetOrigin()

				local bBonusDamage = false

				if(hVictim.IsPlayer())
				{
					bBonusDamage = hVictim.InCond(TF_COND_BURNING)
					params.damage *= (bBonusDamage ? COMBATTANK_FIREBALL_BURN_DAMAGE_BONUS : 1.0)
					params.damage_stats = (bBonusDamage ? TF_DMG_CUSTOM_DRAGONS_FURY_BONUS_BURNING : TF_DMG_CUSTOM_DRAGONS_FURY_IGNITE)

					if(bBonusDamage) EmitSoundOnClient("Weapon_DragonsFury.BonusDamagePain", hVictim)

					if(hVictim.GetPlayerClass() == TF_CLASS_PYRO) hVictim.AddCondEx(TF_COND_BURNING_PYRO, COMBATTANK_FIREBALL_BURN_DURATION * 0.5, hOwner)
					local hIgniter = CreateByClassnameSafe("trigger_ignite")
					hIgniter.KeyValueFromInt("spawnflags", 1)
					hIgniter.KeyValueFromInt("burn_duration", COMBATTANK_FIREBALL_BURN_DURATION)
					hIgniter.DispatchSpawn()
					hIgniter.AcceptInput("StartTouch", null, null, hVictim)
					hIgniter.Kill()
				}
				else
				{
					bBonusDamage = true
					params.damage *= COMBATTANK_FIREBALL_BURN_DAMAGE_BONUS
					params.damage_stats = TF_DMG_CUSTOM_DRAGONS_FURY_BONUS_BURNING
				}

				if(!hAttacker_scope.bImpactSoundPlayed)
				{
					hAttacker_scope.bImpactSoundPlayed = true
					if(bBonusDamage)
					{
						EmitSoundOn("Weapon_DragonsFury.BonusDamage", hVictim)
						EmitSoundEx({
							sound_name  = "Weapon_DragonsFury.BonusDamage"
							channel     = CHAN_STATIC
							filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
							entity      = hVictim
							flags       = SND_STOP
						})
					}
				}
			}
		}
	}
}
__CollectGameEventCallbacks(CombatTankFireballEvents)

TankExt.CombatTankWeapons["fireball"] <- {
	function SpawnModel()
	{
		local hFireball = CreateByClassnameSafe("funCBaseFlex")
		hFireball.SetModel(COMBATTANK_FIREBALL_MODEL)
		hFireball.SetPlaybackRate(1.0)
		hFireball.DispatchSpawn()
		hFireball.SetSequence(hFireball.LookupSequence("idle"))
		hFireball.SetAbsAngles(QAngle(0, 90, 0))
		return hFireball
	}
	function OnSpawn()
	{
		local flUpperRechargeTime = 0.0
		local flLowerRechargeTime = 0.0
		local bUseUpper           = GetPropInt(self, "m_iParentAttachment") == hTank.LookupAttachment("weapon_r")

		local iPoseChargeUpper = self.LookupPoseParameter("charge_level_upper")
		local iPoseReloadUpper = self.LookupPoseParameter("reload_upper")
		local iPoseChargeLower = self.LookupPoseParameter("charge_level_lower")
		local iPoseReloadLower = self.LookupPoseParameter("reload_lower")

		local iAttachmentUpper = self.LookupAttachment("barrel_1")
		local iAttachmentLower = self.LookupAttachment("barrel_2")

		local BrushModel = First().GetModelName() // doesnt cause issues?

		function Think()
		{
			if(!(self && self.IsValid())) return

			self.StudioFrameAdvance()

			local flTime       = Time()
			local bEnemyInCone = hTank_scope.flAngleDot >= cos(COMBATTANK_FIREBALL_CONE_RADIUS * DEG2RAD)

			local GetEffectBarProgress = function(bUpper)
			{
				local flRechargeTime = bUpper ? flUpperRechargeTime : flLowerRechargeTime
				if(flTime < flRechargeTime)
					return (COMBATTANK_FIREBALL_RECHARGE_TIME - flRechargeTime + flTime) / COMBATTANK_FIREBALL_RECHARGE_TIME
				return 1.0
			}

			local flProgressUpper = GetEffectBarProgress(true)
			self.SetPoseParameter(iPoseChargeUpper, flProgressUpper)
			self.SetPoseParameter(iPoseReloadUpper, 1 - flProgressUpper)

			local flProgressLower = GetEffectBarProgress(false)
			self.SetPoseParameter(iPoseChargeLower, flProgressLower)
			self.SetPoseParameter(iPoseReloadLower, 1 - flProgressLower)

			local ShootAtTarget = function(vecOrigin)
			{
				local vecDirection = hTank_scope.vecTarget - vecOrigin
				vecDirection.Norm()

				local hProj = CreateByClassnameSafe("func_rotating")

				hProj.SetAbsOrigin(vecOrigin)
				hProj.SetAbsVelocity(vecDirection * Convars.GetFloat("tf_fireball_speed"))
				hProj.SetForwardVector(vecDirection)
				hProj.SetOwner(hTank)
				hProj.SetTeam(hTank.GetTeam())
				hProj.KeyValueFromInt("spawnflags", 32)
				hProj.KeyValueFromInt("rendermode", 1)
				hProj.KeyValueFromInt("renderamt", 0)
				hProj.SetModel(BrushModel)

				hProj.DispatchSpawn()
				SetPropString(hProj, "m_iClassname", "combattank_fireball")
				TankExt.DispatchParticleEffectOn(hProj, "projectile_fireball")

				hProj.SetSolid(SOLID_BBOX)
				hProj.SetMoveType(MOVETYPE_FLY, MOVECOLLIDE_FLY_CUSTOM)
				hProj.ClearSolidFlags()
				hProj.AddSolidFlags(FSOLID_TRIGGER | FSOLID_USE_TRIGGER_BOUNDS | FSOLID_NOT_SOLID)
				hProj.SetCollisionGroup(TFCOLLISION_GROUP_ROCKETS)
				hProj.SetSize(Vector(-1, -1, -1), Vector(1, 1, 1))
				SetPropInt(hProj, "m_Collision.m_triggerBloat", Convars.GetInt("tf_fireball_radius"))
				SetPropBool(hProj, "m_Collision.m_bUniformTriggerBloat", true)

				hProj.AddEFlags(EFL_NO_WATER_VELOCITY_CHANGE)
				SetPropInt(hProj, "m_fEffects", GetPropInt(hProj, "m_fEffects") | EF_NOSHADOW)
				SetPropInt(hProj, "m_takedamage", DAMAGE_NO)
				EmitSoundOn("Weapon_DragonsFury.Single", self)

				hProj.ValidateScriptScope()
				local hProj_scope = hProj.GetScriptScope()
				hProj_scope.HitEntities <- {}
				hProj_scope.bImpactSoundPlayed <- false

				EntFireByHandle(hProj, "Kill", null, Convars.GetFloat("tf_fireball_max_lifetime"), null, null)
			}

			if(bEnemyInCone && hTank_scope.flDist <= Convars.GetFloat("tf_fireball_distance") && (bUseUpper ? flProgressLower : flProgressUpper) >= 0.5 && (bUseUpper ? flProgressUpper : flProgressLower) >= 1.0)
			{
				local flDelta = flTime + COMBATTANK_FIREBALL_RECHARGE_TIME
				bUseUpper ? flUpperRechargeTime = flDelta : flLowerRechargeTime = flDelta
				ShootAtTarget(self.GetAttachmentOrigin(bUseUpper ? iAttachmentUpper : iAttachmentLower))
				bUseUpper = bUseUpper ? false : true
				hTank_scope.AddToSoundQueue({
					sound_name  = COMBATTANK_FIREBALL_SND_FIRE
					sound_level = 84
					entity      = hTank
					filter_type = RECIPIENT_FILTER_GLOBAL
				})
			}
			return -1
		}
		TankExt.AddThinkToEnt(self, "Think")
	}
}