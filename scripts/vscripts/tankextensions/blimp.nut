local BLIMP_VALUES_TABLE = {
	BLIMP_MODEL = "models/bots/boss_bot/boss_blimp_pure.mdl"
	BLIMP_SKIN_RED = 0
	BLIMP_SKIN_BLUE = 1
}
foreach(k,v in BLIMP_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(BLIMP_MODEL)

TankExt.NewTankScript("blimp", {
	Model = BLIMP_MODEL
	DisableChildModels = 1
	OnSpawn = function(hTank, sName, hPath)
	{
		hTank.SetAbsAngles(QAngle(0, hTank.GetAbsAngles().y, 0))
		hTank.SetSkin(hTank.GetTeam() == 3 ? BLIMP_SKIN_BLUE : BLIMP_SKIN_RED)

		local hTank_scope = hTank.GetScriptScope()
		local flSpeed = GetPropFloat(hTank, "m_speed")
		hTank_scope.hTrackTrain <- SpawnEntityFromTable("func_tracktrain", {
			origin = hTank.GetOrigin()
			speed = flSpeed
			startspeed = flSpeed
			target = hPath.GetName()
		})
		hTank_scope.flLastSpeed <- flSpeed
		hTank_scope.BlimpThink <- function()
		{
			local vecTrackTrain = hTrackTrain.GetOrigin()
			self.SetAbsOrigin(vecTrackTrain)
			self.GetLocomotionInterface().Reset()

			local flSpeed = GetPropFloat(self, "m_speed")
			if(flSpeed == 0) flSpeed = 0.0001
			if(flSpeed != flLastSpeed)
			{
				flLastSpeed = flSpeed
				SetPropFloat(hTrackTrain, "m_flSpeed", flSpeed)
			}
			return -1
		}
		TankExt.AddThinkToEnt(hTank, "BlimpThink")
	}
	OnDeath = function()
	{
		if(hTrackTrain && hTrackTrain.IsValid()) hTrackTrain.Destroy()
		local hDestruction = FindByClassnameNearest("tank_destruction", self.GetOrigin(), 16)
		if(hDestruction && hDestruction.IsValid()) hDestruction.Destroy()
	}
})

local BlimpRedTable = clone TankExt.TankScripts.blimp
BlimpRedTable.TeamNum <- 2
TankExt.NewTankScript("blimp_red", BlimpRedTable)