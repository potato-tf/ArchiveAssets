local TANKDOZER_VALUES_TABLE = {
	TANKDOZER_SND_SENTRY_SAPPED     = "Building_Sentry.Damage"
	TANKDOZER_SND_BREAKABLE_HURT    = "Breakable.Metal"
	TANKDOZER_SENTRY_SCALE          = 1.6
	TANKDOZER_SENTRY_HEALTH         = 9000
	TANKDOZER_SENTRY_DEFAULTUPGRADE = 1.6
	TANKDOZER_MODEL_BREAKABLE2      = "models/props_mvm/tankdozer_breakable2.mdl"
	TANKDOZER_MODEL_BREAKABLE1      = "models/props_mvm/tankdozer_breakable1.mdl"
	TANKDOZER_MODEL                 = "models/props_mvm/tankdozer.mdl"
	TANKDOZER_BREAKABLE_HEALTH      = 2000
}
foreach(k,v in TANKDOZER_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(TANKDOZER_MODEL)
PrecacheModel(TANKDOZER_MODEL_BREAKABLE1)
PrecacheModel(TANKDOZER_MODEL_BREAKABLE2)
TankExt.PrecacheSound(TANKDOZER_SND_BREAKABLE_HURT)
TankExt.PrecacheSound(TANKDOZER_SND_SENTRY_SAPPED)

TankExt.NewTankScript("tankdozer", {
	OnSpawn = function(hTank, sName, hPath)
	{
		local arrayModels = []
		local SpawnBreakable = @(vecOrigin, sModel) SpawnEntityFromTable("prop_dynamic", { origin = vecOrigin, model = sModel, solid = 6, "OnTakeDamage" : "!selfRunScriptCodeEmitSoundOn(TANKDOZER_SND_BREAKABLE_HURT,self)-1-1" })

		arrayModels.append(SpawnBreakable(Vector(8, 85, 121), TANKDOZER_MODEL_BREAKABLE1))
		arrayModels.append(SpawnBreakable(Vector(8, -85, 121), TANKDOZER_MODEL_BREAKABLE1))
		arrayModels.append(SpawnBreakable(Vector(58, 85, 62), TANKDOZER_MODEL_BREAKABLE2))
		arrayModels.append(SpawnBreakable(Vector(58, -85, 62), TANKDOZER_MODEL_BREAKABLE2))
		foreach(hBreakable in arrayModels)
			SetPropInt(hBreakable, "m_takedamage", 2), hBreakable.SetHealth(TANKDOZER_BREAKABLE_HEALTH)

		arrayModels.append(SpawnEntityFromTable("prop_dynamic", { model = TANKDOZER_MODEL, solid = 6 }))
		local hSentry = SpawnEntityFromTable("obj_sentrygun", { origin = "-37 0 176", angles = hTank.GetAbsAngles(), defaultupgrade = TANKDOZER_SENTRY_DEFAULTUPGRADE, modelscale = TANKDOZER_SENTRY_SCALE, spawnflags = 8, teamnum = hTank.GetTeam() })
		hSentry.SetLocalAngles(QAngle())
		hSentry.AcceptInput("SetHealth", TANKDOZER_SENTRY_HEALTH.tostring(), null, null)
		arrayModels.append(hSentry)
		
		TankExt.SetParentArray(arrayModels, hTank)

		// prevents sapper/rtr cheese
		hSentry.ValidateScriptScope()
		local hSentry_scope = hSentry.GetScriptScope()
		hSentry_scope.hSapperBuilder <- null
		hSentry_scope.bHasSapperLast <- false
		hSentry_scope.iHealthLast <- 0
		hSentry_scope.flNextDamage <- 0
		hSentry_scope.SentryThink <- function()
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
			iHealthLast = self.GetHealth()
			bHasSapperLast = bHasSapper
			return -1
		}
		TankExt.AddThinkToEnt(hSentry, "SentryThink")
	}
})