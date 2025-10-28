local REDTANK_VALUES_TABLE = {
	REDTANK_MODEL             = "models/bots/boss_bot/boss_tankred.mdl"
	REDTANK_MODEL_DAMAGE1     = "models/bots/boss_bot/boss_tankred_damage1.mdl"
	REDTANK_MODEL_DAMAGE2     = "models/bots/boss_bot/boss_tankred_damage2.mdl"
	REDTANK_MODEL_DAMAGE3     = "models/bots/boss_bot/boss_tankred_damage3.mdl"
	REDTANK_MODEL_TRACK_L     = "models/bots/boss_bot/tankred_track_l.mdl"
	REDTANK_MODEL_TRACK_R     = "models/bots/boss_bot/tankred_track_r.mdl"
	REDTANK_MODEL_BOMB        = "models/bots/boss_bot/bomb_mechanism.mdl"
}
foreach(k,v in REDTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(REDTANK_MODEL)
PrecacheModel(REDTANK_MODEL_DAMAGE1)
PrecacheModel(REDTANK_MODEL_DAMAGE2)
PrecacheModel(REDTANK_MODEL_DAMAGE3)
PrecacheModel(REDTANK_MODEL_TRACK_L)
PrecacheModel(REDTANK_MODEL_TRACK_R)
PrecacheModel(REDTANK_MODEL_BOMB)

TankExt.NewTankType("redtank", {
	Model = {
		Default     = REDTANK_MODEL
		Damage1     = REDTANK_MODEL_DAMAGE1
		Damage2     = REDTANK_MODEL_DAMAGE2
		Damage3     = REDTANK_MODEL_DAMAGE3
		LeftTrack   = REDTANK_MODEL_TRACK_L
		RightTrack  = REDTANK_MODEL_TRACK_R
		Bomb        = REDTANK_MODEL_BOMB
	}
	TeamNum = TF_TEAM_RED
})