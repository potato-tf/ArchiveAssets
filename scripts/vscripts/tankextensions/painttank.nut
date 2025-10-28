local PAINTTANK_VALUES_TABLE = {
	PAINTTANK_MODEL_COLOR         = "models/bots/boss_bot/paintable_tank_v2/boss_tank.mdl"
	PAINTTANK_MODEL_COLOR_DAMAGE1 = "models/bots/boss_bot/paintable_tank_v2/boss_tank_damage1.mdl"
	PAINTTANK_MODEL_COLOR_DAMAGE2 = "models/bots/boss_bot/paintable_tank_v2/boss_tank_damage2.mdl"
	PAINTTANK_MODEL_COLOR_DAMAGE3 = "models/bots/boss_bot/paintable_tank_v2/boss_tank_damage3.mdl"
	PAINTTANK_MODEL_COLOR_TRACK_L = "models/bots/boss_bot/paintable_tank_v2/tank_track_l.mdl"
	PAINTTANK_MODEL_COLOR_TRACK_R = "models/bots/boss_bot/paintable_tank_v2/tank_track_r.mdl"
	PAINTTANK_MODEL_COLOR_BOMB    = "models/bots/boss_bot/paintable_tank_v2/bomb_mechanism.mdl"
}
foreach(k,v in PAINTTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(PAINTTANK_MODEL_COLOR)
PrecacheModel(PAINTTANK_MODEL_COLOR_DAMAGE1)
PrecacheModel(PAINTTANK_MODEL_COLOR_DAMAGE2)
PrecacheModel(PAINTTANK_MODEL_COLOR_DAMAGE3)
PrecacheModel(PAINTTANK_MODEL_COLOR_TRACK_L)
PrecacheModel(PAINTTANK_MODEL_COLOR_TRACK_R)
PrecacheModel(PAINTTANK_MODEL_COLOR_BOMB)

TankExt.NewTankType("painttank*", {
	Model = {
		Default    = PAINTTANK_MODEL_COLOR
		Damage1    = PAINTTANK_MODEL_COLOR_DAMAGE1
		Damage2    = PAINTTANK_MODEL_COLOR_DAMAGE2
		Damage3    = PAINTTANK_MODEL_COLOR_DAMAGE3
		LeftTrack  = PAINTTANK_MODEL_COLOR_TRACK_L
		RightTrack = PAINTTANK_MODEL_COLOR_TRACK_R
		Bomb       = PAINTTANK_MODEL_COLOR_BOMB
	}
	function OnSpawn()
	{
		local sParams = split(sTankName, "|")
		if(sParams.len() == 1) sParams.append("255 255 255")
        TankExt.SetTankColor(self, sParams[1])
	}
})