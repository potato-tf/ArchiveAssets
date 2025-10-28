local EXAMPLETANK_VALUES_TABLE = {
	EXAMPLETANK_MODEL_COLOR         = "models/bots/boss_bot/paintable_tank_v2/boss_tank.mdl"
	EXAMPLETANK_MODEL_COLOR_DAMAGE1 = "models/bots/boss_bot/paintable_tank_v2/boss_tank_damage1.mdl"
	EXAMPLETANK_MODEL_COLOR_DAMAGE2 = "models/bots/boss_bot/paintable_tank_v2/boss_tank_damage2.mdl"
	EXAMPLETANK_MODEL_COLOR_DAMAGE3 = "models/bots/boss_bot/paintable_tank_v2/boss_tank_damage3.mdl"
	EXAMPLETANK_MODEL_COLOR_TRACK_L = "models/bots/boss_bot/paintable_tank_v2/tank_track_l.mdl"
	EXAMPLETANK_MODEL_COLOR_TRACK_R = "models/bots/boss_bot/paintable_tank_v2/tank_track_r.mdl"
	EXAMPLETANK_MODEL_COLOR_BOMB    = "models/bots/boss_bot/paintable_tank_v2/bomb_mechanism.mdl"
	EXAMPLETANK_SND_ENGINE          = ")music/mvm_class_menu_bg.wav"
	EXAMPLETANK_SND_PING            = ")music/mvm_class_select.wav"
}
foreach(k,v in EXAMPLETANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

TankExt.PrecacheSound(EXAMPLETANK_SND_ENGINE)
TankExt.PrecacheSound(EXAMPLETANK_SND_PING)
PrecacheModel(EXAMPLETANK_MODEL_COLOR)
PrecacheModel(EXAMPLETANK_MODEL_COLOR_DAMAGE1)
PrecacheModel(EXAMPLETANK_MODEL_COLOR_DAMAGE2)
PrecacheModel(EXAMPLETANK_MODEL_COLOR_DAMAGE3)
PrecacheModel(EXAMPLETANK_MODEL_COLOR_TRACK_L)
PrecacheModel(EXAMPLETANK_MODEL_COLOR_TRACK_R)
PrecacheModel(EXAMPLETANK_MODEL_COLOR_BOMB)

TankExt.NewTankType("exampletank", {
	Color              = "110 110 110"
	DisableBomb        = 0
	DisableChildModels = 0
	DisableOutline     = 0
	DisableSmokestack  = 0
	DisableTracks      = 0
	EngineLoopSound    = EXAMPLETANK_SND_ENGINE
	// Model           = EXAMPLETANK_MODEL_COLOR
	Model = {
		Default    = EXAMPLETANK_MODEL_COLOR
		Damage1    = EXAMPLETANK_MODEL_COLOR_DAMAGE1
		Damage2    = EXAMPLETANK_MODEL_COLOR_DAMAGE2
		Damage3    = EXAMPLETANK_MODEL_COLOR_DAMAGE3
		LeftTrack  = EXAMPLETANK_MODEL_COLOR_TRACK_L
		RightTrack = EXAMPLETANK_MODEL_COLOR_TRACK_R
		Bomb       = EXAMPLETANK_MODEL_COLOR_BOMB
	}
	NoDestructionModel = 1
	NoScreenShake      = 0
	PingSound          = EXAMPLETANK_SND_PING
	Scale              = 0.75
	TeamNum            = 1
	function OnSpawn()
	{
		// Available definitons: self, sTankName, hTankPath
		local bBlueTeam = self.GetTeam() == TF_TEAM_BLUE
		local hProp = SpawnEntityFromTableSafe("prop_dynamic", {
			origin      = "-35 0 88"
			model       = "models/player/heavy.mdl"
			defaultanim = "taunt_russian"
			skin        = bBlueTeam ? 1 : 0
		})
		TankExt.SetParentArray([hProp], self)
		local flSpeed = GetPropFloat(self, "m_speed")
		local flValue = 0
		function Think() // Adds a think function automatically
		{
			// Available definitons: self, vecOrigin, angRotation, flTime, iTeamNum, iHealth, iMaxHealth
			SetPropFloat(self, "m_speed", flSpeed + flValue)
			hProp.SetModelScale(1 + flValue * 0.01, -1)
			EmitSoundEx({
				sound_name  = "misc/null.wav"
				pitch       = 100 + flValue * 0.2
				entity      = self
				filter_type = RECIPIENT_FILTER_GLOBAL
				flags       = SND_CHANGE_PITCH | SND_IGNORE_NAME
			})
			flValue += 0.1
		}
	}
	function OnDeath()
	{
		// Available definitons: self
		local vecOrigin = self.GetOrigin()
		for(local i = 1; i <= MAX_CLIENTS; i++)
		{
			local hPlayer = PlayerInstanceFromIndex(i)
			if(hPlayer && hPlayer.IsAlive() && hPlayer.GetTeam() != self.GetTeam())
				hPlayer.SetAbsOrigin(vecOrigin)
		}
	}
})