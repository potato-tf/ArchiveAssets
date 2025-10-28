local TARGETANK_VALUES_TABLE = {
	TARGETANK_MODEL_COLOR         = "models/bots/boss_bot/paintable_tank_v2/boss_tank.mdl"
	TARGETANK_MODEL_COLOR_DAMAGE1 = "models/bots/boss_bot/paintable_tank_v2/boss_tank_damage1.mdl"
	TARGETANK_MODEL_COLOR_DAMAGE2 = "models/bots/boss_bot/paintable_tank_v2/boss_tank_damage2.mdl"
	TARGETANK_MODEL_COLOR_DAMAGE3 = "models/bots/boss_bot/paintable_tank_v2/boss_tank_damage3.mdl"
	TARGETANK_MODEL_COLOR_TRACK_L = "models/bots/boss_bot/paintable_tank_v2/tank_track_l.mdl"
	TARGETANK_MODEL_COLOR_TRACK_R = "models/bots/boss_bot/paintable_tank_v2/tank_track_r.mdl"
	TARGETANK_MODEL_COLOR_BOMB    = "models/bots/boss_bot/paintable_tank_v2/bomb_mechanism.mdl"
	TARGETANK_MODEL_TARGE         = "models/weapons/c_models/c_targe/c_targe.mdl"
	TARGETANK_IMPACT_DAMAGE       = 75
	TARGETANK_RECHARGE_DURATION   = 10
	TARGETANK_CHARGE_DURATION     = 3
	TARGETANK_CHARGE_SPEED        = 300
	TARGETANK_SND_WARNING         = ")ambient/alarms/klaxon1.wav"
	TARGETANK_SND_CHARGE          = "DemoCharge.Charging"
	TARGETANK_SND_IMPACT          = ")weapons/demo_charge_hit_flesh2.wav"
	TARGETANK_COLOR1              = "255 0 0"
	TARGETANK_COLOR2              = "255 127 0"
}
foreach(k,v in TARGETANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(TARGETANK_MODEL_COLOR)
PrecacheModel(TARGETANK_MODEL_COLOR_DAMAGE1)
PrecacheModel(TARGETANK_MODEL_COLOR_DAMAGE2)
PrecacheModel(TARGETANK_MODEL_COLOR_DAMAGE3)
PrecacheModel(TARGETANK_MODEL_COLOR_TRACK_L)
PrecacheModel(TARGETANK_MODEL_COLOR_TRACK_R)
PrecacheModel(TARGETANK_MODEL_COLOR_BOMB)
PrecacheModel(TARGETANK_MODEL_TARGE)
TankExt.PrecacheSound(TARGETANK_SND_WARNING)
TankExt.PrecacheSound(TARGETANK_SND_IMPACT)
TankExt.PrecacheSound(TARGETANK_SND_CHARGE)

TankExt.NewTankType("targetank", {
	function OnSpawn()
	{
		local hTargeModel = SpawnEntityFromTableSafe("prop_dynamic", {
			model      = TARGETANK_MODEL_TARGE
			origin     = "90 28 84"
			angles     = "-29.3 194.9 76.8"
			modelscale = 2.5
			skin       = 1
		})
		local hTrail = SpawnEntityFromTableSafe("env_spritetrail", {
			origin     = "-72 0 96"
			spritename = self.GetTeam() == TF_TEAM_BLUE ? "effects/beam001_blu.vmt" : "effects/beam001_red.vmt"
			startwidth = 128
			endwidth   = 1
			lifetime   = 1
		})
		hTrail.AcceptInput("HideSprite", null, null, null)
		TankExt.SetParentArray([hTargeModel, hTrail], self)

		local hTracks = []
		for(local hChild = self.FirstMoveChild(); hChild != null; hChild = hChild.NextMovePeer())
			if(hChild.GetModelName().find("track_"))
				hTracks.append(hChild)

		bPaintable <- false
		local PlayersLast = []
		local flTimeNext  = Time() + TARGETANK_RECHARGE_DURATION
		local flTimeLast  = Time()
		local flSpeedLast = 0.0
		local iState      = 0
		function Think()
		{
			local bCanDoAction = flTime >= flTimeNext
			if(iState == 0 && bCanDoAction)
			{
				flTimeNext = flTime + 2
				iState = 1
				flSpeedLast = GetPropFloat(self, "m_speed")
				self.AcceptInput("SetSpeed", "15", null, null)
				local sSound = @() EmitSoundEx({
					sound_name  = TARGETANK_SND_WARNING
					sound_level = 85
					filter_type = RECIPIENT_FILTER_GLOBAL
					entity      = self
				})

				sSound()
				sSound()
				TankExt.DelayFunction(self, this, 1, sSound)
				TankExt.DelayFunction(self, this, 1, sSound)
			}
			else if(iState == 1 && bCanDoAction)
			{
				flTimeNext = flTime + TARGETANK_CHARGE_DURATION
				flTimeLast = flTime
				iState = 2
				EmitSoundEx({
					sound_name  = TARGETANK_SND_CHARGE
					sound_level = 80
					filter_type = RECIPIENT_FILTER_GLOBAL
					entity      = self
				})
				self.AcceptInput("SetSpeed", TARGETANK_CHARGE_SPEED.tostring(), null, null)
				hTrail.AcceptInput("ShowSprite", null, null, null)
				PlayersLast.clear()
			}
			else if(iState == 2 && bCanDoAction)
			{
				flTimeNext = flTime + TARGETANK_RECHARGE_DURATION
				flTimeLast = flTime
				iState = 0
				self.AcceptInput("SetSpeed", flSpeedLast.tostring(), null, null)
				EntFireByHandle(hTrail, "HideSprite", "HideSprite", 1, null, null)
			}

			local flTimePercentage = (flTime - flTimeLast) / (flTimeNext - flTimeLast)
			local Color = function(bool)
			{
				local vecColorCombined = Colors[0] * (bool ? 1 - flTimePercentage : flTimePercentage) + Colors[1] * (bool ? flTimePercentage : 1 - flTimePercentage)
				TankExt.SetTankColor(self, format("%i %i %i", vecColorCombined.x, vecColorCombined.y, vecColorCombined.z))
			}

			if(iState == 0)
			{
				if(bPaintable) Color(true)
			}
			else if(iState == 2)
			{
				if(bPaintable) Color(false)

				local flTankSpeed = self.GetAbsVelocity().Length()

				foreach(hTrack in hTracks)
					hTrack.SetPlaybackRate(flTankSpeed / 80.0)

				local angRotation = self.GetAbsAngles()
				local Players = []
				if(flTankSpeed > TARGETANK_CHARGE_SPEED * 0.75)
					for(local hPlayer; hPlayer = FindByClassnameWithin(hPlayer, "player", self.GetOrigin() + RotatePosition(Vector(), angRotation, Vector(130, 0, 32)), 80);)
					{
						if(hPlayer.IsAlive() && hPlayer.GetTeam() != self.GetTeam())
						{
							Players.append(hPlayer)
							if(PlayersLast.find(hPlayer) == null)
							{
								EmitSoundEx({
									sound_name  = TARGETANK_SND_IMPACT
									sound_level = 76
									filter_type = RECIPIENT_FILTER_GLOBAL
									entity      = self
								})
								local vecLaunch = QAngle(-25, angRotation.y, 0).Forward()
								hPlayer.SetAbsVelocity(vecLaunch * 1200)
								hPlayer.TakeDamageCustom(self, self, null, Vector(), Vector(), TARGETANK_IMPACT_DAMAGE, DMG_CLUB, TF_DMG_CUSTOM_CHARGE_IMPACT)
							}
						}
					}
				PlayersLast = Players
			}
		}
	}
})

TankExt.NewTankType("targetank_color", {
	Model = {
		Default    = TARGETANK_MODEL_COLOR
		Damage1    = TARGETANK_MODEL_COLOR_DAMAGE1
		Damage2    = TARGETANK_MODEL_COLOR_DAMAGE2
		Damage3    = TARGETANK_MODEL_COLOR_DAMAGE3
		LeftTrack  = TARGETANK_MODEL_COLOR_TRACK_L
		RightTrack = TARGETANK_MODEL_COLOR_TRACK_R
		Bomb       = TARGETANK_MODEL_COLOR_BOMB
	}
	function OnSpawn()
	{
		TankExt.TankScripts.targetank.OnSpawn.call(this)
		local Colors1 = split(TARGETANK_COLOR1, " ")
		local Colors2 = split(TARGETANK_COLOR2, " ")
		Colors1.apply(@(value) value.tointeger())
		Colors2.apply(@(value) value.tointeger())
		local vecColor1 = Vector(Colors1[0], Colors1[1], Colors1[2])
		local vecColor2 = Vector(Colors2[0], Colors2[1], Colors2[2])
		Colors <- [vecColor1, vecColor2]
		bPaintable = true
	}
})