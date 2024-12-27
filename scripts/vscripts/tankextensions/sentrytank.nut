// Sentry Flags
//
// Invulnerable = 2
// Upgradable = 4
// Infinite Ammo = 8
// Mini-sentry = 64 [$SIGSEGV]

local SENTRYTANK_VALUES_TABLE = {
	SENTRYTANK_SENTRY_HEALTH = 700
	SENTRYTANK_SENTRY_DEFAULTUPGRADE = 2
	SENTRYTANK_SENTRY_FLAGS = 10
}
foreach(k,v in SENTRYTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

TankExt.NewTankScript("sentrytank", {
	OnSpawn = function(hTank, sName, hPath)
	{
		local SpawnSentry = @(vecOrigin, angRotation, iLevel)
		{
			Entity = SpawnEntityFromTable("obj_sentrygun",
			{
				origin = vecOrigin
				angles = hTank.GetAbsAngles() + angRotation
				defaultupgrade = iLevel
				teamnum = hTank.GetTeam()
				spawnflags = SENTRYTANK_SENTRY_FLAGS
				vscripts = "tankextensions/misc/sentry_removesapper"
			})
			Angles = angRotation 
		}
		local Sentries = []
		Sentries.append(SpawnSentry(Vector(74, 0, 158), QAngle(), SENTRYTANK_SENTRY_DEFAULTUPGRADE))
		Sentries.append(SpawnSentry(Vector(-60, 0, 158), QAngle(0, 180, 0), SENTRYTANK_SENTRY_DEFAULTUPGRADE))
		foreach(i, SentryTable in Sentries)
		{
			Sentries[i] = SentryTable.Entity
			SentryTable.Entity.SetLocalAngles(SentryTable.Angles)
			SentryTable.Entity.AcceptInput("SetHealth", SENTRYTANK_SENTRY_HEALTH.tostring(), null, null)
		}
		TankExt.SetParentArray(Sentries, hTank)
	}
})