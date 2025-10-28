local UBERTANK_VALUES_TABLE = {
	UBERTANK_MODEL          = "models/bots/boss_bot/ubertank/boss_tank_uber.mdl"
	UBERTANK_MODEL_TRACK_L  = "models/bots/boss_bot/ubertank/tank_uber_track_l.mdl"
	UBERTANK_MODEL_TRACK_R  = "models/bots/boss_bot/ubertank/tank_uber_track_r.mdl"
	UBERTANK_MODEL_BOMB     = "models/bots/boss_bot/ubertank/bomb_mechanism_uber.mdl"
	UBERTANK_SND_UBER       = "player/invulnerable_on.wav"
	UBERTANK_SND_UBER_OFF   = "player/invulnerable_off.wav"
	UBERTANK_SKIN_UBER_RED  = 0
	UBERTANK_SKIN_UBER_BLUE = 1
}
foreach(k,v in UBERTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(UBERTANK_MODEL)
PrecacheModel(UBERTANK_MODEL_TRACK_L)
PrecacheModel(UBERTANK_MODEL_TRACK_R)
PrecacheModel(UBERTANK_MODEL_BOMB)
TankExt.PrecacheSound(UBERTANK_SND_UBER)
TankExt.PrecacheSound(UBERTANK_SND_UBER_OFF)

::UberTankEvents <- {
	OnGameEvent_recalculate_holidays = function(_) { if(GetRoundState() == 3) delete ::UberTankEvents }
	OnScriptHook_OnTakeDamage = function(params)
	{
		local hAttacker = params.attacker
		local hVictim   = params.const_entity
		if(hAttacker && hVictim && hVictim.GetClassname() == "tank_boss" && hAttacker.GetTeam() != hVictim.GetTeam())
		{
			local UberScope = TankExt.GetMultiScopeTable(hVictim.GetScriptScope(), "ubertank")
			if(UberScope && UberScope.bUbered)
			{
				params.damage = 0
				EmitSoundOn("FX_RicochetSound.Ricochet", hVictim)
			}
		}
	}
}
__CollectGameEventCallbacks(UberTankEvents)

TankExt.NewTankType("ubertank*", {
	function OnSpawn()
	{
		local sParams = split(sTankName, "|")
		if(sParams.len() == 1) sParams.append(0)
		if(sParams.len() == 2) sParams.append(30)

		local ModelInfo = { Tank = { entity = self, modelname = null, skin = 0, color = 0 } }
		for(local hChild = self.FirstMoveChild(); hChild; hChild = hChild.NextMovePeer())
		{
			local sChildModel = hChild.GetModelName().tolower()
			local Table       = { entity = hChild, modelname = null, skin = 0, color = 0 }

			if(sChildModel.find("track_l"))
				ModelInfo.LeftTrack <- Table
			else if(sChildModel.find("track_r"))
				ModelInfo.RightTrack <- Table
			else if(sChildModel.find("bomb_mechanism"))
				ModelInfo.Bomb <- Table
		}

		local flTimeStart = sParams[1].tofloat()
		if(flTimeStart >= 0) TankExt.DelayFunction(self, this, flTimeStart, @() ToggleUber())

		local flDuration  = sParams[2].tofloat()
		local bUberFizzle = false
		bUbered <- false
		function ToggleUber()
		{
			if(!bUberFizzle)
				if(!bUbered)
				{
					if(flDuration >= 0) TankExt.DelayFunction(self, this, flDuration, @() ToggleUber())
					bUbered    = true
					EmitSoundEx({
						sound_name  = UBERTANK_SND_UBER
						filter_type = RECIPIENT_FILTER_GLOBAL
					})

					local bBlueTeam = self.GetTeam() == TF_TEAM_BLUE
					foreach(sName, Table in ModelInfo)
					{
						Table.modelname = Table.entity.GetModelName()
						Table.skin      = Table.entity.GetSkin()
						Table.color     = GetPropInt(Table.entity, "m_clrRender")
						Table.entity.SetSkin(bBlueTeam ? UBERTANK_SKIN_UBER_BLUE : UBERTANK_SKIN_UBER_RED)
						SetPropInt(Table.entity, "m_clrRender", 0xFFFFFFFF)
					}
					TankExt.SetTankModel(self, {
						Tank       = UBERTANK_MODEL
						LeftTrack  = UBERTANK_MODEL_TRACK_L
						RightTrack = UBERTANK_MODEL_TRACK_R
						Bomb       = UBERTANK_MODEL_BOMB
					})
				}
				else
				{
					bUberFizzle = true
					EmitSoundEx({
						sound_name  = UBERTANK_SND_UBER_OFF
						filter_type = RECIPIENT_FILTER_GLOBAL
					})
					TankExt.DelayFunction(self, this, 1, function()
					{
						bUbered     = false
						bUberFizzle = false
						TankExt.SetTankModel(self, {
							Tank       = ModelInfo.Tank.modelname
							LeftTrack  = ModelInfo.LeftTrack.modelname
							RightTrack = ModelInfo.RightTrack.modelname
							Bomb       = ModelInfo.Bomb.modelname
						})
						foreach(sName, Table in ModelInfo)
						{
							Table.entity.SetSkin(Table.skin)
							SetPropInt(Table.entity, "m_clrRender", Table.color)
						}
					})
				}
		}
		local UberScope = this
		self.GetScriptScope().ToggleUber <- @() UberScope.ToggleUber()

		function Think()
		{
			if(bUbered)
			{
				local sModel = self.GetModelName()
				if(sModel != UBERTANK_MODEL)
				{
					ModelInfo.Tank.modelname = sModel
					TankExt.SetTankModel(self, UBERTANK_MODEL)
				}
			}
			if(bUberFizzle)
			{
				local flColor = 127.5 - sin(flTime * 20.95) * 127.5 // 20.95 == PI / 0.3 * 0.5
				foreach(sName, Table in ModelInfo)
					Table.entity.AcceptInput("Color", format("%i %i %i", flColor, flColor, flColor), null, null)
			}
		}
	}
})