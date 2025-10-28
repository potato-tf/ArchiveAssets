local BLIMP_VALUES_TABLE = {
	BLIMP_MODEL         = "models/bots/boss_blimp/boss_blimp.mdl"
	BLIMP_MODEL_DAMAGE1 = "models/bots/boss_blimp/boss_blimp_damage1.mdl"
	BLIMP_MODEL_DAMAGE2 = "models/bots/boss_blimp/boss_blimp_damage2.mdl"
	BLIMP_MODEL_DAMAGE3 = "models/bots/boss_blimp/boss_blimp_damage3.mdl"
	BLIMP_SOUND_ENGINE  = ")ambient/turbine3.wav"
}
foreach(k,v in BLIMP_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(BLIMP_MODEL)
PrecacheModel(BLIMP_MODEL_DAMAGE1)
PrecacheModel(BLIMP_MODEL_DAMAGE2)
PrecacheModel(BLIMP_MODEL_DAMAGE3)
TankExt.PrecacheSound(BLIMP_SOUND_ENGINE)

PrecacheSound("weapons/dumpster_rocket_reload.wav")

TankExt.NewTankType("blimp*", {
	Model = {
		Default = BLIMP_MODEL
		Damage1 = BLIMP_MODEL_DAMAGE1
		Damage2 = BLIMP_MODEL_DAMAGE2
		Damage3 = BLIMP_MODEL_DAMAGE3
	}
	DisableChildModels = 1
	NoScreenShake      = 1
	EngineLoopSound    = BLIMP_SOUND_ENGINE
	NoDestructionModel = 1
	NoGravity          = 1
	DisableSmokestack  = 1
	function OnSpawn()
	{
		local sParams = split(sTankName, "|")
		local iParamsLength = sParams.len()

		if(sParams[0].find("_red")) self.SetTeam(TF_TEAM_RED)

		local bParticles = false
		local hParticle1, hParticle2, hParticle3, hParticle4
		if(sParams[0].find("_customparticles"))
		{
			bParticles = true
			hParticle1 = SpawnEntityFromTableSafe("info_particle_system", { angles = QAngle(10, 106, -10), effect_name = "mvm_blimp_smoke", start_active = 1 })
			hParticle2 = SpawnEntityFromTableSafe("info_particle_system", { angles = QAngle(10, 106, -10), effect_name = "mvm_blimp_smoke_exhaust" })
			TankExt.SetParentArray([hParticle1, hParticle2], self, "smoke_attachment")
			hParticle3 = SpawnEntityFromTableSafe("info_particle_system", { angles = QAngle(90, 0, -90), effect_name = "mvm_blimp_propeller_wind", start_active = 1 })
			TankExt.SetParentArray([hParticle3], self, "propeller_l")
			hParticle4 = SpawnEntityFromTableSafe("info_particle_system", { angles = QAngle(90, 0, -90), effect_name = "mvm_blimp_propeller_wind", start_active = 1 })
			TankExt.SetParentArray([hParticle4], self, "propeller_r")
		}

		if(iParamsLength >= 2)
		{
			SetPropInt(self, "m_iTextureFrameIndex", 2)
			self.AcceptInput("Color", sParams[1], null, null)
		}

		local flSpeedLast         = 75.0
		local flHealthPercentLast = 1.0

		local iBombAttachment  = self.LookupAttachment("bomb_pos")
		local iPropAttachmentL = self.LookupAttachment("propeller_l")
		local iPropAttachmentR = self.LookupAttachment("propeller_r")
		local iPropPoseL       = self.LookupPoseParameter("prop_spin_l")
		local iPropPoseR       = self.LookupPoseParameter("prop_spin_r")

		local vecBombLast  = Vector()
		local vecPropLastL = self.GetAttachmentOrigin(iPropAttachmentL)
		local vecPropLastR = self.GetAttachmentOrigin(iPropAttachmentR)
		local flPropDegL   = 0.0
		local flPropDegR   = 0.0
		local flPropSpeed  = 20.0
		local bFoundWorld  = false
		function Think()
		{
			if(bParticles)
			{
				local flSpeed = GetPropFloat(self, "m_speed")
				if(flSpeed == 0.0 && flSpeedLast != 0.0)
				{
					hParticle3.AcceptInput("Stop", null, null, null)
					hParticle4.AcceptInput("Stop", null, null, null)
				}
				else if(flSpeed != 0.0 && flSpeedLast == 0.0)
				{
					hParticle3.AcceptInput("Start", null, null, null)
					hParticle4.AcceptInput("Start", null, null, null)
				}
				flSpeedLast = flSpeed

				local flHealthPercent = iHealth / iMaxHealth.tofloat()
				if(flHealthPercent <= 0.5 && flHealthPercentLast > 0.5)
				{
					hParticle1.AcceptInput("Stop", null, null, null)
					hParticle2.AcceptInput("Start", null, null, null)
				}
				else if(flHealthPercent > 0.5 && flHealthPercentLast <= 0.5)
				{
					hParticle1.AcceptInput("Start", null, null, null)
					hParticle2.AcceptInput("Stop", null, null, null)
				}
				flHealthPercentLast = flHealthPercent
			}
			if(!bDeploying)
			{
				local vecPropL = self.GetAttachmentOrigin(iPropAttachmentL)
				local vecPropR = self.GetAttachmentOrigin(iPropAttachmentR)
				local flMath   = flPropSpeed / FrameTime() / 80
				if((flPropDegL += (vecPropL - vecPropLastL).Length2D() * flMath) > 360) flPropDegL -= 360
				if((flPropDegR += (vecPropR - vecPropLastR).Length2D() * flMath) > 360) flPropDegR -= 360
				self.SetPoseParameter(iPropPoseL, flPropDegL)
				self.SetPoseParameter(iPropPoseR, flPropDegR)
				vecPropLastL = vecPropL
				vecPropLastR = vecPropR
			}
			else if(!bFoundWorld)
			{
				local vecBomb = self.GetAttachmentOrigin(iBombAttachment)
				local Trace = {
					start = vecBombLast
					end   = vecBomb
					mask  = CONTENTS_SOLID | CONTENTS_WINDOW | CONTENTS_MOVEABLE
				}
				TraceLineEx(Trace)
				if(Trace.hit)
				{
					bFoundWorld = true
					self.EmitSound("weapons/dumpster_rocket_reload.wav")
					TankExt.DelayFunction(self, this, 0.35, function()
					{
						self.SetCycle(1.0) // ends deploy sequence
					})
				}
				vecBombLast = vecBomb
			}
		}
		function OnStartDeploy()
		{
			vecBombLast = self.GetAttachmentOrigin(iBombAttachment)
			TankExt.DelayFunction(self, this, 7.5, function() // prevents the sound that plays when the bomb fits through the hole
			{
				self.StopSound("MVM.TankDeploy")
			})
			if(bParticles)
			{
				hParticle3.AcceptInput("Stop", null, null, null)
				hParticle4.AcceptInput("Stop", null, null, null)
			}
		}
	}
})