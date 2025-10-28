local SENTRY_FLAG_INVULN        = 2
local SENTRY_FLAG_UPGRADABLE    = 4
local SENTRY_FLAG_INFINITE_AMMO = 8
local SENTRY_FLAG_MINI_SIGSEGV  = 64

local TANKDOZER_VALUES_TABLE = {
	TANKDOZER_SND_SENTRY_SAPPED     = "Building_Sentry.Damage"
	TANKDOZER_SENTRY_HEALTH         = 6000
	TANKDOZER_SENTRY_DEFAULTUPGRADE = 1
	TANKDOZER_SENTRY_FLAGS          = SENTRY_FLAG_INFINITE_AMMO
	TANKDOZER_MODEL                 = "models/bots/boss_bot/killdozer/killdozer_base_armour.mdl"
	TANKDOZER_MODEL_L               = "models/bots/boss_bot/killdozer/killdozer_extra_armour_l.mdl"
	TANKDOZER_MODEL_R               = "models/bots/boss_bot/killdozer/killdozer_extra_armour_r.mdl"
	TANKDOZER_MODEL_SCOOP           = "models/bots/boss_bot/killdozer/killdozer_scoop.mdl"
}
foreach(k,v in TANKDOZER_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(TANKDOZER_MODEL)
PrecacheModel(TANKDOZER_MODEL_L)
PrecacheModel(TANKDOZER_MODEL_R)
PrecacheModel(TANKDOZER_MODEL_SCOOP)

local PROPCOLLISION_CRATE  = "models/props_mvm/barrel_crate.mdl"
local PROPCOLLISION_BARREL = "models/props_hydro/water_barrel_cluster.mdl"
PrecacheModel(PROPCOLLISION_CRATE)
PrecacheModel(PROPCOLLISION_BARREL)

::TankDozerEvents <- {
	OnGameEvent_recalculate_holidays = function(_) { if(GetRoundState() == 3) delete ::TankDozerEvents }
	OnScriptHook_OnTakeDamage = function(params)
	{
		local hVictim   = params.const_entity
		local hAttacker = params.attacker
		if(hVictim && hAttacker && hVictim.GetClassname() == "tank_boss")
		{
			local DozerScope = TankExt.GetMultiScopeTable(hVictim.GetScriptScope(), "tankdozer")
			if(DozerScope)
			{
				local CrateCollision = {}
				local CreateCrateCollisionProp = function(sModel, vecOrigin, angRotation)
				{
					local hProp = CreateByClassnameSafe("prop_dynamic")
					hProp.SetModel(sModel)
					hProp.AcceptInput("SetParent", "!activator", hVictim, null)
					hProp.SetLocalOrigin(vecOrigin)
					hProp.SetLocalAngles(angRotation)
					hProp.SetSolid(SOLID_VPHYSICS)
					hProp.DispatchSpawn()
					CrateCollision[hProp] <- null
				}
				CreateCrateCollisionProp(PROPCOLLISION_CRATE, Vector(-18, 0, 119), QAngle(90))
				CreateCrateCollisionProp(PROPCOLLISION_CRATE, Vector(30, 0, 119), QAngle(90, 180))
				CreateCrateCollisionProp(PROPCOLLISION_CRATE, Vector(-16, -42, 34), QAngle(82.5))
				CreateCrateCollisionProp(PROPCOLLISION_CRATE, Vector(-99, -42, 23), QAngle(82.5))
				CreateCrateCollisionProp(PROPCOLLISION_CRATE, Vector(-16, 42, 34), QAngle(82.5))
				CreateCrateCollisionProp(PROPCOLLISION_CRATE, Vector(-99, 42, 23), QAngle(82.5))
				CreateCrateCollisionProp(PROPCOLLISION_CRATE, Vector(-104, 0, 52), QAngle(90))
				CreateCrateCollisionProp(PROPCOLLISION_BARREL, Vector(-79, 56, 22), QAngle(0, 0, 90))
				CreateCrateCollisionProp(PROPCOLLISION_BARREL, Vector(79, 56, 46), QAngle(0, 0, 90))

				local vecShot   = params.damage_position
				local vecCenter = hVictim.GetCenter()
				local Trace = {
					mask   = MASK_SOLID
					ignore = hVictim
					end    = vecCenter
					start  = vecShot
				}

				local hInflictor = params.inflictor
				if(hInflictor)
				{
					if(hInflictor == hAttacker)
					{
						local vecTowards = vecShot - hAttacker.EyePosition()
						vecTowards.Norm()
						Trace.end = vecShot + vecTowards * 256
					}
					else if(startswith(hInflictor.GetClassname(), "tf_projectile"))
					{
						local vecTowards = hInflictor.GetAbsVelocity()
						if(vecTowards.LengthSqr() == 0) vecTowards = hInflictor.GetPhysVelocity()
						vecTowards.Norm()
						Trace.end = vecShot + vecTowards * 256
					}
					else if(hInflictor.GetClassname() == "tf_weapon_flamethrower")
					{
						Trace.start = GetPropEntity(hInflictor, "m_hFlameManager").GetOrigin()
					}
				}

				local flDamage = params.damage
				local Revert   = {}
				local TraceRecursive
				TraceRecursive = function()
				{
					TraceLineEx(Trace)
					if("enthit" in Trace)
					{
						local hEntHit = Trace.enthit
						delete Trace.enthit

						if(!(hEntHit in CrateCollision))
						{
							local sClassname = hEntHit.GetClassname()
							if(sClassname == "funCBaseFlex")
							{
								params.damage = 0
							}
							else if(sClassname == "worldspawn" && (Trace.end - vecCenter).LengthSqr() != 0)
							{
								Trace.end = vecCenter
								TraceRecursive()
							}
							else
							{
								Revert[hEntHit] <- [hEntHit.GetSolid(), hEntHit.GetBoundingMins(), hEntHit.GetBoundingMaxs()]
								hEntHit.SetSize(Vector(), Vector())
								hEntHit.SetSolid(SOLID_NONE)
								TraceRecursive()
							}
						}
					}
					else if((Trace.end - vecCenter).LengthSqr() != 0)
					{
						Trace.end = vecCenter
						TraceRecursive()
					}
				}
				TraceRecursive()

				foreach(hEnt, array in Revert)
				{
					hEnt.SetSolid(array[0])
					hEnt.SetSize(array[1], array[2])
				}
				foreach(hProp, _ in CrateCollision)
					hProp.Kill()
			}
		}
	}
}
__CollectGameEventCallbacks(TankDozerEvents)

TankExt.NewTankType("tankdozer*", {
	function OnSpawn()
	{
		local bBlueTeam = self.GetTeam() == TF_TEAM_BLUE
		local MakeCBaseFlex = function(sModel)
		{
			local hBaseFlex = CreateByClassnameSafe("funCBaseFlex")
			hBaseFlex.SetModel(sModel)
			hBaseFlex.SetPlaybackRate(1.0)
			hBaseFlex.SetSkin(bBlueTeam ? 1 : 0)
			hBaseFlex.SetSolid(SOLID_VPHYSICS)
			hBaseFlex.DispatchSpawn()
			hBaseFlex.AddEFlags(EFL_DONTBLOCKLOS)
			return hBaseFlex
		}
		local hArmorScoop = MakeCBaseFlex(TANKDOZER_MODEL_SCOOP)
		local hArmor      = MakeCBaseFlex(TANKDOZER_MODEL)
		local hArmorL     = MakeCBaseFlex(TANKDOZER_MODEL_L)
		local hArmorR     = MakeCBaseFlex(TANKDOZER_MODEL_R)
		local ModelArray  = [hArmor, hArmorL, hArmorR, hArmorScoop]
		TankExt.SetParentArray(ModelArray, self)

		if(sTankName.find("_nosentry") == null)
		{
			self.RemoveEFlags(EFL_DONTBLOCKLOS)
			local hSentry = SpawnEntityFromTableSafe("obj_sentrygun", {
				origin         = "-43 0 176"
				angles         = self.GetAbsAngles()
				defaultupgrade = TANKDOZER_SENTRY_DEFAULTUPGRADE
				spawnflags     = TANKDOZER_SENTRY_FLAGS
				teamnum        = self.GetTeam()
			})
			hSentry.SetLocalAngles(QAngle())
			hSentry.AcceptInput("SetHealth", TANKDOZER_SENTRY_HEALTH.tostring(), null, null)

			// prevents sapper/rtr cheese
			local hSapperBuilder = null
			local bHasSapperLast = false
			local iHealthLast    = 0
			local flNextDamage   = 0
			hSentry.ValidateScriptScope()
			hSentry.GetScriptScope().SentryThink <- function()
			{
				if(!self.IsValid()) return
				local bHasSapper = GetPropBool(self, "m_bHasSapper")
				if(bHasSapper)
				{
					local hSapper = self.FirstMoveChild()
					if(!bHasSapperLast)
					{
						EmitSoundOn(TANKDOZER_SND_SENTRY_SAPPED, self)
						hSapperBuilder = GetPropEntity(hSapper, "m_hBuilder")
						SetPropEntity(hSapper, "m_hBuilder", null)
						EntFireByHandle(self, "SetHealth", iHealthLast.tostring(), 0.1, null, null)
						EntFireByHandle(hSapper, "RemoveHealth", hSapper.GetHealth().tostring(), 10, null, null)
					}
					// to make sappers still useful
					local flTime = Time()
					if(flTime >= flNextDamage)
					{
						flNextDamage = flTime + 0.4
						self.TakeDamage(20, DMG_GENERIC, hSapperBuilder)
					}
				}
				iHealthLast    = self.GetHealth()
				bHasSapperLast = bHasSapper
				return -1
			}
			TankExt.AddThinkToEnt(hSentry, "SentryThink")
			TankExt.SetParentArray([hSentry], self)
		}

		local iSequenceLast = 0
		local iHealthLast   = 0
		function Think()
		{
			local iSequence = self.GetSequence()
			local flCycle   = self.GetCycle()
			foreach(hModel in ModelArray)
			{
				if(iSequence != iSequenceLast || iHealthLast != iHealth)
				{
					if(hModel == hArmor)
					{
						local iMainSequence   = iSequence
						local flHealthPercent = iHealth / iMaxHealth.tofloat()

						if(flHealthPercent <= 0.25)
							iMainSequence += 6
						else if(flHealthPercent <= 0.5)
							iMainSequence += 4
						else if(flHealthPercent <= 0.75)
							iMainSequence += 2

						hModel.ResetSequence(iMainSequence)
					}
					else
						hModel.ResetSequence(iSequence)
				}
				hModel.StudioFrameAdvance()
				hModel.SetCycle(flCycle)
			}
			iSequenceLast = iSequence
			iHealthLast   = iHealth
		}
		function OnStartDeploy()
		{
			hArmorScoop.SetSolid(SOLID_NONE)
		}
	}
})