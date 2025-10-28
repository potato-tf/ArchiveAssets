local TankExtLegacy = {
	TankScriptsLegacy = {}
	TankScriptsWildLegacy = {}
	function StartingPathNames(PathArray)
	{
	}
	function NewTankScript(sName, Table)
	{
		sName = sName.tolower()
		local bWild = sName[sName.len() - 1] == '*'
		if(bWild)
		{
			sName = sName.slice(0, sName.len() - 1)
			TankExt.TankScriptsWildLegacy[sName] <- Table
		}
		else
			TankExt.TankScriptsLegacy[sName] <- Table
	}
	function RunTankScript(hTank)
	{
		if(hTank.GetEFlags() & EFL_NO_MEGAPHYSCANNON_RAGDOLL || hTank.GetClassname() != "tank_boss") return
		local hPath = caller
		local sTankName = hTank.GetName().tolower()
		hTank.ValidateScriptScope()
		hTank.SetEFlags(EFL_NO_MEGAPHYSCANNON_RAGDOLL)
		SetPropBool(hTank, "m_bForcePurgeFixedupStrings", true)

		local TankTable

		if(sTankName in TankExt.TankScriptsLegacy)
			TankTable = TankExt.TankScriptsLegacy[sTankName]
		else
			foreach(sName, Table in TankExt.TankScriptsWildLegacy)
				if(startswith(sTankName, sName))
					{
						TankTable = Table
						hTank.KeyValueFromString("targetname", sName)
						break
					}

		if(TankTable)
		{
			local hTank_scope = hTank.GetScriptScope()
			if("Model" in TankTable)
			{
				if(typeof TankTable.Model == "string")
					TankTable.Model = { Default = TankTable.Model }
				TankExt.SetTankModel(hTank, {
					Tank = TankTable.Model.Default
					LeftTrack = "LeftTrack" in TankTable.Model ? TankTable.Model.LeftTrack : null
					RightTrack = "RightTrack" in TankTable.Model ? TankTable.Model.RightTrack : null
					Bomb = "Bomb" in TankTable.Model ? TankTable.Model.Bomb : null
				})

				if(!("Damage1" in TankTable.Model))
					TankTable.Model.Damage1 <- TankTable.Model.Default
				if(!("Damage2" in TankTable.Model))
					TankTable.Model.Damage2 <- TankTable.Model.Damage1
				if(!("Damage3" in TankTable.Model))
					TankTable.Model.Damage3 <- TankTable.Model.Damage2

				hTank_scope.sModelLast <- hTank.GetModelName()
				hTank_scope.CustomModelThink <- function()
				{
					local sModel = self.GetModelName()
					if(sModel != sModelLast)
					{
						local sNewModel = sModel

						if(sModel.find("damage1"))
							sNewModel = TankTable.Model.Damage1
						else if(sModel.find("damage2"))
							sNewModel = TankTable.Model.Damage2
						else if(sModel.find("damage3"))
							sNewModel = TankTable.Model.Damage3
						else
							sNewModel = TankTable.Model.Default

						TankExt.SetTankModel(hTank, { Tank = sNewModel })
						sModel = sNewModel
					}
					sModelLast = sModel
				}
				TankExt.AddThinkToEnt(hTank, "CustomModelThink")
			}

			local DisableModels = function(iFlags)
			{
				for(local hChild = hTank.FirstMoveChild(); hChild != null; hChild = hChild.NextMovePeer())
				{
					local sChildModel = hChild.GetModelName().tolower()
					if((sChildModel.find("track_") && iFlags & 1) || (sChildModel.find("bomb_mechanism") && iFlags & 2))
						hChild.DisableDraw()
				}
			}

			if("DisableChildModels" in TankTable && TankTable.DisableChildModels == 1)
				DisableModels(3)

			if("DisableTracks" in TankTable && TankTable.DisableTracks == 1)
				DisableModels(1)

			if("DisableBomb" in TankTable && TankTable.DisableBomb == 1)
				DisableModels(2)

			if("Color" in TankTable)
				hTank.AcceptInput("Color", TankTable.Color, null, null)

			if("TeamNum" in TankTable)
			{
				hTank.SetTeam(TankTable.TeamNum)
				EntFireByHandle(hTank, "RunScriptCode", "SetPropBool(self, `m_bGlowEnabled`, true)", 0.066, null, null)
			}

			if("DisableOutline" in TankTable && TankTable.DisableOutline == 1)
			{
				SetPropBool(hTank, "m_bGlowEnabled", false)
				EntFireByHandle(hTank, "RunScriptCode", "SetPropBool(self, `m_bGlowEnabled`, false)", 0.066, null, null)
			}

			if("DisableSmokestack" in TankTable && TankTable.DisableSmokestack == 1)
			{
				hTank_scope.DisableSmokestack <- function()	{ hTank.AcceptInput("DispatchEffect", "ParticleEffectStop", null, null)	}
				TankExt.AddThinkToEnt(hTank, "DisableSmokestack")
			}

			if("OnSpawn" in TankTable)
				TankTable.OnSpawn(hTank, sTankName, hPath)

			if("OnDeath" in TankTable)
				TankExt.SetDestroyCallback(hTank, TankTable.OnDeath)
		}
	}
}
foreach(k,v in TankExtLegacy)
	if(!(k in TankExt))
		TankExt[k] <- v