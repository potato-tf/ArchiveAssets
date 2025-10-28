local COMBATTANK_VALUES_TABLE = {
	COMBATTANK_RAILGUN_SND_CHARGE           = ")misc/doomsday_cap_close_quick.wav"
	COMBATTANK_RAILGUN_SND_FIRE1            = ")weapons/shooting_star_shoot_charged.wav"
	COMBATTANK_RAILGUN_SND_FIRE2            = ")weapons/sniper_railgun_charged_shot_crit_01.wav"
	COMBATTANK_RAILGUN_SND_COOL_START       = ")misc/doomsday_cap_close_start.wav"
	COMBATTANK_RAILGUN_SND_COOL_END         = ")misc/doomsday_cap_spin_start.wav"
	COMBATTANK_RAILGUN_MODEL                = "models/bots/boss_bot/combat_tank_mk2/mk2_railgun.mdl"
	COMBATTANK_RAILGUN_MODEL_CASING         = "models/bots/boss_bot/combat_tank/railgun_case.mdl"
	COMBATTANK_RAILGUN_PARTICLE_TRACER_RED  = "dxhr_sniper_rail_red"
	COMBATTANK_RAILGUN_PARTICLE_TRACER_BLUE = "dxhr_sniper_rail_blue"
	COMBATTANK_RAILGUN_COOLDOWN_TIME        = 8
	COMBATTANK_RAILGUN_BULLET_DAMAGE        = 300
	COMBATTANK_RAILGUN_CLIP_SIZE            = 3
}
foreach(k,v in COMBATTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(COMBATTANK_RAILGUN_MODEL)
PrecacheModel(COMBATTANK_RAILGUN_MODEL_CASING)
TankExt.PrecacheSound(COMBATTANK_RAILGUN_SND_CHARGE)
TankExt.PrecacheSound(COMBATTANK_RAILGUN_SND_FIRE1)
TankExt.PrecacheSound(COMBATTANK_RAILGUN_SND_FIRE2)
TankExt.PrecacheSound(COMBATTANK_RAILGUN_SND_COOL_START)
TankExt.PrecacheSound(COMBATTANK_RAILGUN_SND_COOL_END)

TankExt.CombatTankWeapons["railgun"] <- {
	function SpawnModel()
	{
		local hRailgun = CreateByClassnameSafe("funCBaseFlex")
		hRailgun.SetModel(COMBATTANK_RAILGUN_MODEL)
		hRailgun.SetPlaybackRate(1.0)
		hRailgun.DispatchSpawn()
		hRailgun.SetSequence(hRailgun.LookupSequence("idle"))
		hRailgun.SetAbsAngles(QAngle(0, 90, 0))
		return hRailgun
	}
	function OnSpawn()
	{
		local flNextAttack  = 0.0
		local flCoolPercent = 0.0
		local iClip         = COMBATTANK_RAILGUN_CLIP_SIZE
		local bCharging     = false

		local hCasingShooter = SpawnEntityFromTableSafe("env_shooter", {
			origin           = Vector(-188, 5, 0)
			angles           = QAngle(0, 90, 0)
			shootmodel       = COMBATTANK_RAILGUN_MODEL_CASING
			m_flGibLife      = 5
			m_flVariance     = 0.15
			m_flVelocity     = 200
			m_iGibs          = 1
			nogibshadows     = 1
			shootsounds      = -1
			spawnflags       = 5
			gibanglevelocity = 10
		})
		TankExt.SetParentArray([hCasingShooter], self, "barrel")

		local iLaserColor = hTank_scope.hBeam.IsValid() ? GetPropInt(hTank_scope.hBeam, "m_clrRender") : 0
		function SetLaserColor(sColor)
		{
			if(hTank_scope.hBeam.IsValid())
				sColor ? hTank_scope.hBeam.AcceptInput("Color", sColor, null, null) : SetPropInt(hTank_scope.hBeam, "m_clrRender", iLaserColor)
			if(hTank_scope.hBeamEnd.IsValid())
				sColor ? hTank_scope.hBeamEnd.AcceptInput("Color", sColor, null, null) : SetPropInt(hTank_scope.hBeamEnd, "m_clrRender", iLaserColor)
		}
		function Shoot()
		{
			iClip--
			flNextAttack = Time() + (iClip == 0 ? COMBATTANK_RAILGUN_COOLDOWN_TIME : 0.7)
			SetLaserColor(null)
			bCharging = false
			hTank_scope.AddToSoundQueue({
				sound_name  = COMBATTANK_RAILGUN_SND_FIRE1
				pitch       = 65
				sound_level = 100
				entity      = hTank
				filter_type = RECIPIENT_FILTER_GLOBAL
			})
			hTank_scope.AddToSoundQueue({
				sound_name  = COMBATTANK_RAILGUN_SND_FIRE2
				pitch       = 90
				sound_level = 100
				entity      = hTank
				filter_type = RECIPIENT_FILTER_GLOBAL
			})

			local iTeamNum = hTank.GetTeam()
			local LaserTrace = hTank_scope.LaserTrace
			if("enthit" in LaserTrace)
			{
				local hHit = LaserTrace.enthit
				if("GetTeam" in hHit && hHit.GetTeam() != iTeamNum)
				{
					local sClassname = hHit.GetClassname()
					if(sClassname == "player")
						if(!hHit.InCond(TF_COND_DISGUISED))
							hHit.EmitSound("Flesh.BulletImpact")
					if(startswith(sClassname, "obj_"))
						hHit.EmitSound("SolidMetal.BulletImpact")
					hHit.TakeDamageCustom(hTank, hTank, null, Vector(), Vector(), COMBATTANK_RAILGUN_BULLET_DAMAGE, DMG_BULLET | DMG_ACID, TF_DMG_CUSTOM_HEADSHOT)
				}
			}

			local vecTracer = hTank_scope.LaserTrace.endpos
			local vecBarrel = self.GetAttachmentOrigin(self.LookupAttachment("barrel"))
			local bBlueTeam = iTeamNum == TF_TEAM_BLUE

			local hParticle = SpawnEntityFromTableSafe("info_particle_system", {
				origin       = vecBarrel
				effect_name  = (bBlueTeam ? COMBATTANK_RAILGUN_PARTICLE_TRACER_BLUE : COMBATTANK_RAILGUN_PARTICLE_TRACER_RED)
				start_active = 1
			})

			local hBeamShock = SpawnEntityFromTableSafe("env_beam", {
				lightningstart = "bignet"
				lightningend   = "bignet"
				texture        = "effects/electro_beam.vmt"
				rendercolor    = (bBlueTeam ? "180 180 255" : "255 180 180")
				spawnflags     = 256
				TextureScroll  = 32
			})
			SetPropEntityArray(hBeamShock, "m_hAttachEntity", hBeamShock, 0)
			SetPropEntityArray(hBeamShock, "m_hAttachEntity", hParticle, 1)
			hBeamShock.SetAbsOrigin(vecTracer)

			local hBeamShot = SpawnEntityFromTableSafe("env_beam", {
				lightningstart = "bignet"
				lightningend   = "bignet"
				texture        = "sprites/laserbeam.vmt"
				rendercolor    = (bBlueTeam ? "60 60 90" : "90 60 60")
				spawnflags     = 256
				TextureScroll  = 32
			})
			SetPropEntityArray(hBeamShot, "m_hAttachEntity", hBeamShot, 0)
			SetPropEntityArray(hBeamShot, "m_hAttachEntity", hParticle, 1)
			hBeamShot.SetAbsOrigin(vecTracer)

			SetPropEntityArray(hParticle, "m_hControlPointEnts", hBeamShot, 0)

			hBeamShock.ValidateScriptScope()
			local flWidth = 16
			local iAlpha  = 255
			hBeamShock.GetScriptScope().Think <- function()
			{
				if(iAlpha <= 0)
				{
					hBeamShot.Kill()
					self.Kill()
					if(hParticle.IsValid())
						hParticle.Kill()
					return
				}

				local sAlpha = format("%i", iAlpha)
				self.AcceptInput("Alpha", sAlpha, null, null)
				hBeamShot.AcceptInput("Alpha", sAlpha, null, null)
				self.AcceptInput("Width", format("%f", (4 + flWidth) * 4), null, null)
				hBeamShot.AcceptInput("Width", format("%f", 4 + flWidth), null, null)

				iAlpha -= 2.5
				flWidth *= 0.95
				return -1
			}
			AddThinkToEnt(hBeamShock, "Think")
			SetPropVector(hCasingShooter, "m_angGibRotation", TankExt.VectorAngles(hCasingShooter.GetRightVector()) + Vector())
			EntFireByHandle(hCasingShooter, "Shoot", null, 0.1, null, null)
		}
		function Think()
		{
			if(!(self && self.IsValid())) return
			self.StudioFrameAdvance()

			local LaserTrace = hTank_scope.LaserTrace
			local bInLaser   = "enthit" in LaserTrace && LaserTrace.enthit == hTank_scope.hTarget
			local flTime     = Time()
			local bCanAttack = flTime >= flNextAttack

			if(!bCharging && bInLaser && bCanAttack && flCoolPercent <= 0)
			{
				SetLaserColor("150 90 0")
				bCharging = true
				hTank_scope.AddToSoundQueue({
					sound_name  = COMBATTANK_RAILGUN_SND_CHARGE
					sound_level = 100
					entity      = hTank
					filter_type = RECIPIENT_FILTER_GLOBAL
				})
				self.ResetSequence(self.LookupSequence("fire"))
				if(iClip == 0) iClip = COMBATTANK_RAILGUN_CLIP_SIZE
				EntFireByHandle(self, "CallScriptFunction", "Shoot", 1.7, null, null)
			}

			local flCoolPercentLast = flCoolPercent

			if(bCanAttack) flCoolPercent -= 0.015
			else if(iClip == 0) flCoolPercent += 0.015

			if(flCoolPercentLast == 0 && flCoolPercent > 0)
				hTank_scope.AddToSoundQueue({
					sound_name  = COMBATTANK_RAILGUN_SND_COOL_START
					sound_level = 85
					pitch       = 115
					entity      = hTank
					filter_type = RECIPIENT_FILTER_GLOBAL
				})

			if(flCoolPercentLast == 1 && flCoolPercent < 1)
				hTank_scope.AddToSoundQueue({
					sound_name  = COMBATTANK_RAILGUN_SND_COOL_END
					sound_level = 85
					pitch       = 115
					entity      = hTank
					filter_type = RECIPIENT_FILTER_GLOBAL
				})

			flCoolPercent = TankExt.Clamp(flCoolPercent, 0, 1)

			self.SetPoseParameter(0, flCoolPercent)

			return -1
		}
		TankExt.AddThinkToEnt(self, "Think")
	}
}
