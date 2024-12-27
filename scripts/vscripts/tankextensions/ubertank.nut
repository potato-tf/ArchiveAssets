local UBERTANK_VALUES_TABLE = {
	UBERTANK_MODEL = "models/bots/boss_bot/boss_tank_ubered.mdl"
	UBERTANK_SND_UBER = "player/invulnerable_on.wav"
	UBERTANK_SND_UBER_OFF = "player/invulnerable_off.wav"
	UBERTANK_SKIN_UBER = 2
}
foreach(k,v in UBERTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(UBERTANK_MODEL)
TankExt.PrecacheSound(UBERTANK_SND_UBER)
TankExt.PrecacheSound(UBERTANK_SND_UBER_OFF)

TankExt.NewTankScript("ubertank*", {
	OnSpawn = function(hTank, sName, hPath)
	{
		local sParams = split(sName, "|")
		if(sParams.len() == 1) sParams.append(0)
		if(sParams.len() == 2) sParams.append(30)

		local flTimeStart = sParams[1].tofloat()
		if(flTimeStart >= 0) EntFireByHandle(hTank, "CallScriptFunction", "ToggleUber", flTimeStart, null, null)

		local hTank_scope = hTank.GetScriptScope()
		hTank_scope.sModelLast <- null
		hTank_scope.flDuration <- sParams[2].tofloat()
		hTank_scope.iSkinLast <- hTank.GetSkin()
		hTank_scope.bUbered <- false
		hTank_scope.ToggleUber <- function()
		{
			if(!bUbered)
			{
				if(flDuration >= 0) EntFireByHandle(hTank, "CallScriptFunction", "ToggleUber", flDuration, null, null)
				bUbered = true
				sModelLast = self.GetModelName()
				TankExt.SetEntityColor(self, 127, 127, 127, 255)
				SetPropInt(hTank, "m_takedamage", 0)
				TankExt.SetTankModel(self, UBERTANK_MODEL)
				hTank.SetSkin(UBERTANK_SKIN_UBER)
				EmitSoundEx({
					sound_name = UBERTANK_SND_UBER
					filter_type = RECIPIENT_FILTER_GLOBAL
				})
			}
			else
			{
				EntFireByHandle(hTank, "RunScriptCode", "bUbered = false", 1, null, null)
				EntFireByHandle(hTank, "RunScriptCode", "TankExt.SetEntityColor(self, 255, 255, 255, 255)", 1, null, null)
				EntFireByHandle(hTank, "RunScriptCode", "SetPropInt(self, `m_takedamage`, 2)", 1, null, null)
				EntFireByHandle(hTank, "RunScriptCode", "TankExt.SetTankModel(self, sModelLast)", 1, null, null)
				EntFireByHandle(hTank, "RunScriptCode", "self.SetSkin(iSkinLast)", 1, null, null)
				EmitSoundEx({
					sound_name = UBERTANK_SND_UBER_OFF
					filter_type = RECIPIENT_FILTER_GLOBAL
				})
			}
		}
		hTank_scope.UberThink <- function()
		{
			if(bUbered)
			{
				local sModel = self.GetModelName()
				if(sModel != UBERTANK_MODEL)
				{
					sModelLast = sModel
					TankExt.SetTankModel(self, UBERTANK_MODEL)
				}
			}
			return -1
		}
		TankExt.AddThinkToEnt(hTank, "UberThink")
	}
})