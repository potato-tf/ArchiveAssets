////////////////////////////////////////////////////////////////////////////////////////////
// quick disclaimer that this script is not meant to be as simple or intuitive as
// PopExtensions when adding new tanks. most tank features youll have to write yourself.
// hopefully the current scripts that are provided help out on any possible confusion.
////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////
// Function List
////////////////////////////////////////////////////////////////////////////////////////////

// void TankExt.CreatePaths(table)   // uses a table with strings and arrays to create multiple paths
//                                   // can merge into existing paths if the endpoint overlaps with a map's path_track
//                                   // starting path entities will have "_1" appended to their name

// void TankExt.CreateLoopPaths(table)   // the same as CreatePaths except paths will loop into itself
//                                       // end path Vector must be the same as another within the path and the tank must spawn on the first node

// void TankExt.StartingPathNames(array)   // array of strings that include the targetnames of all starting paths, or any path node a tank can spawn on

// void TankExt.NewTankScript(string name, table)   // table of functions called either OnSpawn or OnDeath that will apply to a tank with a matching name, can use wildcards

// void TankExt.RunTankScript()   // paths from StartingPathNames will call this function and apply functions in TankScripts or TankScriptsWild onto a tank

//////////// Utilities ////////////

// void TankExt.PathMaker(player)   // tool for creating tank paths ingame and prints them to console

// void TankExt.SetTankModel(handle tank, table models)   // sets the tank's models including itself and its accessories

// void TankExt.SetTankColor(handle tank, string color)   // sets the tank's color including itself and its accessories

// void TankExt.SetPathConnection(handle path1, handle path2, handle pathalt = null)   // connects paths from one to another

// void TankExt.SetValueOverrides(table)   // overrides variables set inside tank script files, can be used before or after adding tank scripts

// void TankExt.SetDestroyCallback(handle entity, function)   // used for OnDeath, copied from script examples

// void TankExt.SetParentArray(array entities, handle parent, string attachment = null)   // parents one or multiple entities to another entity, and onto an attachment if specified

// QAngle TankExt.VectorToQAngle(vector)   // calculates the angle based on a vectors direction

// integer/float TankExt.SetEntityColor(handle entity, int r, int g, int b, int a)   // sets entity color similar to a Color input

// integer/float TankExt.Clamp(value, min, max)   // inputted value cannot go below min or above max

// void TankExt.AddThinkToEnt(handle entity, string function)   // wrapper for AddThinkToEnt to allow usage with PopExt+ and to attach a think table to tanks

// bool TankExt.HasPathOutput(handle path_track)   // returns true if inputted path already has the output to apply scripts to tanks

// void TankExt.PrecacheSound(string sound)   // precaches sounds but automatically detects if the inputted sound is a SoundScript or not

// bool TankExt.ExistsInScope(scope, string)   // checks if a string exists inside a script scope, if it finds an instance then it checks if its valid and not null

////////////////////////////////////////////////////////////////////////////////////////////

::ROOT <- getroottable()
::CONST <- getconsttable()
::MAX_CLIENTS <- MaxClients().tointeger()

if(!("ConstantNamingConvention" in ROOT))
	foreach(a, b in Constants)
		foreach(k, v in b)
		{
			CONST[k] <- v != null ? v : 0
			ROOT[k] <- v != null ? v : 0
		}

foreach(k, v in ::NetProps.getclass())
	if(k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::NetProps[k].bindenv(::NetProps)

foreach(k, v in ::Entities.getclass())
	if(k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::Entities[k].bindenv(::Entities)

foreach(k, v in ::EntityOutputs.getclass())
	if(k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::EntityOutputs[k].bindenv(::EntityOutputs)

local UNOFFICIAL_CONSTANTS = {
	LIFE_ALIVE       = 0
	LIFE_DYING       = 1
	LIFE_DEAD        = 2
	LIFE_RESPAWNABLE = 3
	LIFE_DISCARDBODY = 4

	SND_NOFLAGS                              = 0
	SND_CHANGE_VOL                           = 1
	SND_CHANGE_PITCH                         = 2
	SND_STOP                                 = 4
	SND_SPAWNING                             = 8
	SND_DELAY                                = 16
	SND_STOP_LOOPING                         = 32
	SND_SPEAKER                              = 64
	SND_SHOULDPAUSE                          = 128
	SND_IGNORE_PHONEMES                      = 256
	SND_IGNORE_NAME                          = 512
	SND_DO_NOT_OVERWRITE_EXISTING_ON_CHANNEL = 1024

	CHAN_REPLACE    = -1
	CHAN_AUTO       = 0
	CHAN_WEAPON     = 1
	CHAN_VOICE      = 2
	CHAN_ITEM       = 3
	CHAN_BODY       = 4
	CHAN_STREAM     = 5
	CHAN_STATIC     = 6
	CHAN_VOICE2     = 7
	CHAN_VOICE_BASE = 8
	CHAN_USER_BASE  = 136

	MASK_ALL                   = -1
	MASK_SPLITAREAPORTAL       = 48
	MASK_SOLID_BRUSHONLY       = 16395
	MASK_WATER                 = 16432
	MASK_BLOCKLOS              = 16449
	MASK_OPAQUE                = 16513
	MASK_DEADSOLID             = 65547
	MASK_PLAYERSOLID_BRUSHONLY = 81931
	MASK_NPCWORLDSTATIC        = 131083
	MASK_NPCSOLID_BRUSHONLY    = 147467
	MASK_CURRENT               = 16515072
	MASK_SHOT_PORTAL           = 33570819
	MASK_SOLID                 = 33570827
	MASK_BLOCKLOS_AND_NPCS     = 33570881
	MASK_OPAQUE_AND_NPCS       = 33570945
	MASK_VISIBLE_AND_NPCS      = 33579137
	MASK_PLAYERSOLID           = 33636363
	MASK_NPCSOLID              = 33701899
	MASK_SHOT_HULL             = 100679691
	MASK_SHOT                  = 1174421507

	// damagefilter redefinitions
	DMG_USE_HITLOCATIONS                    = DMG_AIRBOAT
	DMG_HALF_FALLOFF                        = DMG_RADIATION
	DMG_CRITICAL                            = DMG_ACID
	DMG_RADIUS_MAX                          = DMG_ENERGYBEAM
	DMG_IGNITE                              = DMG_PLASMA
	DMG_USEDISTANCEMOD                      = DMG_SLOWBURN
	DMG_NOCLOSEDISTANCEMOD                  = DMG_POISON
	DMG_MELEE                               = DMG_BLAST_SURFACE
	DMG_DONT_COUNT_DAMAGE_TOWARDS_CRIT_RATE = DMG_DISSOLVE
}
foreach(k,v in UNOFFICIAL_CONSTANTS)
	if(!(k in ROOT))
	{
		CONST[k] <- v
		ROOT[k] <- v
	}

////////////////////////////////////////////////////////////////////////////////////////////

::TankExt <- {
	function OnGameEvent_recalculate_holidays(_) { if(GetRoundState() == 3) { delete ::TankExt } }
	function OnGameEvent_mvm_begin_wave(_)
	{
		for(local hPath; hPath = FindByClassname(hPath, "path_track");)
			if(!TankExt.HasPathOutput(hPath))
				AddOutput(hPath, "OnPass", "!activator", "RunScriptCode", "TankExt.RunTankScript.call(this)", -1, -1)
	}

	ValueOverrides = {}
	TankScripts = {}
	TankScriptsWild = {}
	function CreateLoopPaths(PathTable)
	{
		Convars.SetValue("sig_etc_path_track_is_server_entity", 0)
		foreach(sPathName, OriginArray in PathTable)
		{
			if(FindByName(null, format("%s_1", sPathName)))
				continue

			local iArrayLength = OriginArray.len() - 1
			local vecFinalOrigin = OriginArray.top()
			local iLoopStart
			foreach(i, vecOrigin in OriginArray)
				if(i != iArrayLength && vecOrigin.x == vecFinalOrigin.x && vecOrigin.y == vecFinalOrigin.y && vecOrigin.z == vecFinalOrigin.z)
					{ iLoopStart = i; break }
			
			if(iLoopStart == null)
				return ClientPrint(null, 3, format("\x07ffb2b2[ERROR] Looping path (%s) endpoint does not connect to itself", sPathName))

			local hPath1 = SpawnEntityFromTable("path_track", {
				origin     = OriginArray[0]
				targetname = format("%s_1", sPathName)
				"OnPass#1" : format("%s,CallScriptFunction,LoopInitialize,0,-1", format("%s_2", sPathName))
				"OnPass#2" : "!activator,RunScriptCode,TankExt.RunTankScript.call(this),0,-1"
			})
			local hPath2 = SpawnEntityFromTable("path_track", {
				origin     = OriginArray[1]
				targetname = format("%s_2", sPathName)
				vscripts   = "tankextensions/misc/loopingpath_think"
			})
			local hPath3 = SpawnEntityFromTable("path_track", {
				origin     = Vector(99999)
				targetname = format("%s_3", sPathName)
			})
			TankExt.SetPathConnection(hPath1, hPath2)
			TankExt.SetPathConnection(hPath2, hPath3)
			local hPath_scope = hPath2.GetScriptScope()
			hPath_scope.OriginArray <- OriginArray
			hPath_scope.sPathName <- sPathName
			hPath_scope.iArrayLength <- iArrayLength
			hPath_scope.iLoopStart <- iLoopStart
			SetPropBool(hPath2, "m_bForcePurgeFixedupStrings", true)
			TankExt.AddThinkToEnt(hPath2, "PathThink")
		}
	}
	function CreatePaths(PathTable)
	{
		foreach(sPathName, OriginArray in PathTable)
		{
			if(FindByName(null, format("%s_1", sPathName)))
				continue

			local PathGroup = {}
			local iArrayLength = OriginArray.len() - 1
			foreach(i, vecOrigin in OriginArray)
			{
				PathGroup[i] <- {}
				PathGroup[i].path_track <- {
					origin     = vecOrigin
					targetname = format("%s_%i", sPathName, i + 1)
					target     = i != iArrayLength ? format("%s_%i", sPathName, i + 2) : ""
					OnPass     = "!activator,RunScriptCode,TankExt.RunTankScript.call(this),0,-1"
				}
				if(i == iArrayLength - 1)
				{
					local vecOriginNext = OriginArray[i + 1]
					local hPath = FindByClassnameNearest("path_track", vecOriginNext, 1)
					if(hPath != null)
						{ PathGroup[i].path_track.target = hPath.GetName(); break }
				}
			}
			SpawnEntityGroupFromTable(PathGroup)
		}
	}
	function HasPathOutput(hPath)
	{
		local iTotalOutputs = GetNumElements(hPath, "OnPass")
		local bHasOutput = false
		for(local i = 0; i <= iTotalOutputs; i++)
		{
			local OutputTable = {}
			GetOutputTable(hPath, "OnPass", OutputTable, i)
			if("parameter" in OutputTable && OutputTable.parameter == "TankExt.RunTankScript.call(this)")
				{ bHasOutput = true; break }
		}
		return bHasOutput
	}
	function StartingPathNames(PathArray)
	{
		foreach(sName in PathArray)
		{
			local hPath = FindByName(null, sName)
			if(hPath)
			{
				if(!TankExt.HasPathOutput(hPath))
					AddOutput(hPath, "OnPass", "!activator", "RunScriptCode", "TankExt.RunTankScript.call(this)", -1, -1)
			}
			else
				ClientPrint(null, 3, format("\x07FFD700[WARNING] Invalid path name \"%s\"", sName))
		}
	}
	function NewTankScript(sName, Table)
	{
		sName = sName.tolower()
		local bWild = sName[sName.len() - 1] == '*'
		if(bWild)
		{
			sName = sName.slice(0, sName.len() - 1)
			TankExt.TankScriptsWild[sName] <- Table
		}
		else
			TankExt.TankScripts[sName] <- Table
	}
	function RunTankScript()
	{
		if(!("self" in this) || self.GetEFlags() & EFL_NO_MEGAPHYSCANNON_RAGDOLL || self.GetClassname() != "tank_boss") return
		local hPath = caller
		local hTank = self
		local sTankName = hTank.GetName().tolower()
		hTank.ValidateScriptScope()
		hTank.SetEFlags(EFL_NO_MEGAPHYSCANNON_RAGDOLL)
		SetPropBool(hTank, "m_bForcePurgeFixedupStrings", true)
		
		local TankTable

		if(sTankName in TankExt.TankScripts)
			TankTable = TankExt.TankScripts[sTankName]
		else
			foreach(sName, Table in TankExt.TankScriptsWild)
				if(startswith(sTankName, sName))
					{
						TankTable = Table
						self.KeyValueFromString("targetname", sName)
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
				SetPropBool(self, "m_bGlowEnabled", false)
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

	//////////////////////// Utilities ////////////////////////

	function SetTankModel(hTank, Model)
	{
		local ApplyModel = function(hEntity, sModel)
		{
			local iModelIndex = PrecacheModel(sModel)
			local sSequence = hEntity.GetSequenceName(hEntity.GetSequence())
			hEntity.SetModel(sModel)
			SetPropInt(hEntity, "m_nModelIndex", iModelIndex)
			SetPropIntArray(hEntity, "m_nModelIndexOverrides", iModelIndex, 0)
			SetPropIntArray(hEntity, "m_nModelIndexOverrides", iModelIndex, 3)
			hEntity.SetSequence(hEntity.LookupSequence(sSequence))
		}
		if(typeof Model == "string")
			{ ApplyModel(hTank, Model); return }

		if("Tank" in Model)
			ApplyModel(hTank, Model.Tank)
		for(local hChild = hTank.FirstMoveChild(); hChild != null; hChild = hChild.NextMovePeer())
		{
			local sChildModel = hChild.GetModelName().tolower()
			if(sChildModel.find("track_l") && "LeftTrack" in Model && Model.LeftTrack)
				ApplyModel(hChild, Model.LeftTrack)
			else if(sChildModel.find("track_r") && "RightTrack" in Model && Model.RightTrack)
				ApplyModel(hChild, Model.RightTrack)
			else if(sChildModel.find("bomb_mechanism") && "Bomb" in Model && Model.Bomb)
				ApplyModel(hChild, Model.Bomb)
		}
	}
	function SetTankColor(hTank, sColor)
	{
		hTank.AcceptInput("Color", sColor, null, null)
		for(local hChild = hTank.FirstMoveChild(); hChild != null; hChild = hChild.NextMovePeer())
		{
			local sChildModel = hChild.GetModelName().tolower()
			if(sChildModel.find("track_"))
				hChild.AcceptInput("Color", sColor, null, null)
			else if(sChildModel.find("bomb_mechanism"))
				hChild.AcceptInput("Color", sColor, null, null)
		}
	}
	function SetPathConnection(hPath1, hPath2, hPathAlt = null)
	{
		if(hPath2)
		{
			SetPropEntity(hPath1, "m_pnext", hPath2)
			SetPropEntity(hPath2, "m_pprevious", hPath1)
		}
		else
		{
			SetPropEntity(hPath1, "m_pnext", null)
			SetPropEntity(hPath1, "m_pprevious", null)
			SetPropEntity(hPath1, "m_paltpath", null)
			return
		}
		if(hPathAlt)
			SetPropEntity(hPath1, "m_paltpath", hPathAlt)
	}
	function SetValueOverrides(ValueTable)
	{
		ValueOverrides = ValueTable
		foreach(k,v in ValueTable)
			ROOT[k] <- v 
	}
	function SetDestroyCallback(entity, callback)
	{
		entity.ValidateScriptScope();
		local scope = entity.GetScriptScope();
		scope.setdelegate({}.setdelegate({
				parent   = scope.getdelegate()
				id       = entity.GetScriptId()
				index    = entity.entindex()
				callback = callback
				_get = function(k)
				{
					return parent[k];
				}
				_delslot = function(k)
				{
					if (k == id)
					{
						entity = EntIndexToHScript(index);
						local scope = entity.GetScriptScope();
						scope.self <- entity;
						callback.pcall(scope);
					}
					delete parent[k];
				}
			})
		);
	}
	function SetParentArray(hChildren, hParent, sAttachment = null)
	{
		local iAttachment
		if(sAttachment) iAttachment = hParent.LookupAttachment(sAttachment)
		foreach(hChild in hChildren)
		{
			SetPropEntity(hChild, "m_hMovePeer", hParent.FirstMoveChild())
			SetPropEntity(hParent, "m_hMoveChild", hChild)
			SetPropEntity(hChild, "m_pParent", hParent)
			SetPropEntity(hChild, "m_hMoveParent", hParent)
			SetPropEntity(hChild, "m_Network.m_hParent", hParent)
			SetPropEntity(hChild, "m_hLightingOrigin", hParent)
			if(sAttachment)
				SetPropInt(hChild, "m_iParentAttachment", iAttachment)
		}
	}
	function VectorToQAngle(Vector)
	{
		local yaw, pitch
		if ( Vector.y == 0.0 && Vector.x == 0.0 )
		{
			yaw = 0.0
			if (Vector.z > 0.0)
				pitch = 270.0
			else
				pitch = 90.0
		}
		else
		{
			yaw = (::atan2(Vector.y, Vector.x) * 57.2958)
			if (yaw < 0.0)
				yaw += 360.0
			pitch = (::atan2(-Vector.z, Vector.Length2D()) * 57.2958)
			if (pitch < 0.0)
				pitch += 360.0
		}
		return ::QAngle(pitch, yaw, 0.0)
	}
	function Clamp(value, low, high)
	{
		if (value < low)
			return low
		if (value > high)
			return high
		return value
	}
	function SetEntityColor(entity, r, g, b, a)
	{
		local color = (r) | (g << 8) | (b << 16) | (a << 24)
		NetProps.SetPropInt(entity, "m_clrRender", color)
	}
	function PathMaker(hPlayer)
	{
		Convars.SetValue("sig_etc_path_track_is_server_entity", 0)
		hPlayer.ValidateScriptScope()
		local hPlayer_scope = hPlayer.GetScriptScope()
		
		hPlayer_scope.flTimeNext <- 0
		hPlayer_scope.iGridSize <- 64
		hPlayer_scope.iButtonsLast <- 0
		hPlayer_scope.iPrintMode <- 0
		hPlayer_scope.sndPlace <- "buttons/blip1.wav"
		hPlayer_scope.sndRemove <- "buttons/button15.wav"
		hPlayer_scope.sndChange <- "buttons/button16.wav"
		hPlayer_scope.sndComplete1 <- "buttons/button18.wav"
		hPlayer_scope.sndComplete2 <- "buttons/button9.wav"
		PrecacheSound(hPlayer_scope.sndPlace)
		PrecacheSound(hPlayer_scope.sndRemove)
		PrecacheSound(hPlayer_scope.sndChange)
		PrecacheSound(hPlayer_scope.sndComplete1)
		PrecacheSound(hPlayer_scope.sndComplete2)
	
		if(TankExt.ExistsInScope(hPlayer_scope, "PathArray"))
			foreach(array in hPlayer_scope.PathArray)
				if(array[1].IsValid())
					array[1].Destroy()
		hPlayer_scope.PathArray <- []
	
		if(TankExt.ExistsInScope(hPlayer_scope, "hGlow")) hPlayer_scope.hGlow.Destroy()
		hPlayer_scope.hGlow <- null
	
		if(TankExt.ExistsInScope(hPlayer_scope, "hPathVisual")) hPlayer_scope.hPathVisual.Destroy()
		hPlayer_scope.hPathVisual <- null
	
		if(TankExt.ExistsInScope(hPlayer_scope, "hPathTrackVisual")) hPlayer_scope.hPathTrackVisual.Destroy()
		hPlayer_scope.hPathTrackVisual <- null
	
		if(TankExt.ExistsInScope(hPlayer_scope, "hPathHatchVisual")) hPlayer_scope.hPathHatchVisual.Destroy()
		hPlayer_scope.hPathHatchVisual <- null
	
		if(TankExt.ExistsInScope(hPlayer_scope, "hText")) hPlayer_scope.hText.Destroy()
		hPlayer_scope.hText <- null
		
	
		hPlayer_scope.PathMakerThink <- function()
		{
			local iButtons = GetPropInt(self, "m_nButtons")
			local iButtonsChanged = iButtonsLast ^ iButtons
			local iButtonsPressed = iButtonsChanged & iButtons
			local iButtonsReleased = iButtonsChanged & (~iButtons)
			iButtonsLast = iButtons
			local vecEye = self.EyePosition()
			local angEye = self.EyeAngles()
	
			local vecTarget = (vecEye + angEye.Forward() * 128) * (1.0 / iGridSize)
			local GridMath = @(value) floor(value + 0.5) * iGridSize
			vecTarget.x = GridMath(vecTarget.x)
			vecTarget.y = GridMath(vecTarget.y)
			vecTarget.z = GridMath(vecTarget.z)
	
			local hLastPath
			local PathArrayLength = PathArray.len()
			if(PathArrayLength > 0) hLastPath = PathArray.top()[1]
			local hNearestPathTrack = FindByClassnameNearest("path_track", vecTarget, 1024)
	
			self.AddCustomAttribute("no_attack", 1, 0.1)
	
			if(TankExt.ExistsInScope(this, "hText"))
			{
				local sPlaceText = format("Grid Size : %i\nReload : Cycle Grid Size\nMouse1 : Add Path\nMouse2 : Undo Path\nReload + Crouch : Print Path", iGridSize)
				local sPrintText = format("[Export Method]\nReload : Rafmod\nMouse1 : TankExt\nMouse2 : PopExt+\nCrouch : Cancel", iGridSize)
				hText.KeyValueFromString("message", iPrintMode > 0 ? sPrintText : sPlaceText)
				EntFireByHandle(hText, "Display", null, -1, self, null)
			}
			else
				hText = SpawnEntityFromTable("game_text", {
					targetname = "pathmakertext"
					message = "test"
					channel = 0
					color = "255 255 255"
					holdtime = 0.3
					x = -1
					y = 0.7
				})
	
			if(iPrintMode > 0)
			{
				if(iPrintMode > 1)
				{
					EmitSoundEx({
						sound_name = sndComplete2
						entity = self
						filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
					})
					ClientPrint(self, HUD_PRINTCENTER, "Path printed to console")
	
					switch(iPrintMode)
					{
						case 2:
							ClientPrint(self, HUD_PRINTCONSOLE, "tank_path = [")
							foreach(array in PathArray)
								ClientPrint(self, HUD_PRINTCONSOLE, format("\tVector(%i, %i, %i)", array[0].x, array[0].y, array[0].z))
							ClientPrint(self, HUD_PRINTCONSOLE, "]")
							break
						case 3:
							ClientPrint(self, HUD_PRINTCONSOLE, "\"ExtraTankPath\" : [\n\t[")
							foreach(array in PathArray)
								ClientPrint(self, HUD_PRINTCONSOLE, format("\t\t\"%i %i %i\"", array[0].x, array[0].y, array[0].z))
							ClientPrint(self, HUD_PRINTCONSOLE, "\t]\n]")
							break
						case 4:
							ClientPrint(self, HUD_PRINTCONSOLE, "ExtraTankPath\n{\n\tName \"tank_path\"")
							foreach(array in PathArray)
								ClientPrint(self, HUD_PRINTCONSOLE, format("\tNode \"%i %i %i\"", array[0].x, array[0].y, array[0].z))
							ClientPrint(self, HUD_PRINTCONSOLE, "}")
							break
					}
	
					if(TankExt.ExistsInScope(this, "hGlow")) hGlow.Destroy()
					if(TankExt.ExistsInScope(this, "hPathVisual")) hPathVisual.Destroy()
					if(TankExt.ExistsInScope(this, "hPathTrackVisual")) hPathTrackVisual.Destroy()
					if(TankExt.ExistsInScope(this, "hPathHatchVisual")) hPathHatchVisual.Destroy()
					if(TankExt.ExistsInScope(this, "hText")) hText.Destroy()
					if(TankExt.ExistsInScope(this, "PathArray"))
						foreach(array in hPlayer_scope.PathArray)
							if(array[1].IsValid())
								array[1].Destroy()
	
					delete hPlayer_scope.PathMakerThink
					Convars.SetValue("sig_etc_path_track_is_server_entity", 1)
				}
	
				if(iButtonsPressed & IN_ATTACK)
					iPrintMode = 2
				if(iButtonsPressed & IN_ATTACK2)
					iPrintMode = 3
				if(iButtonsPressed & IN_RELOAD)
					iPrintMode = 4
				if(iButtonsPressed & IN_DUCK)
					iPrintMode = 0
	
				return -1
			}
	
			if(iButtonsPressed & IN_RELOAD && iButtons & IN_DUCK)
			{
				EmitSoundEx({
					sound_name = sndComplete1
					entity = self
					filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
				})
				iPrintMode = 1
				return -1
			}
			if(iButtonsPressed & IN_ATTACK)
			{
				EmitSoundEx({
					sound_name = sndPlace
					entity = self
					filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
				})
				local hPath = SpawnEntityFromTable("prop_dynamic", {
					origin = vecTarget
					targetname = "pathmakerpath"
					model = "models/editor/axis_helper_thick.mdl"
					disableshadows = 1
				})
				PathArray.append([vecTarget, hPath])
			}
			if(iButtonsPressed & IN_ATTACK2 && PathArrayLength > 0)
			{
				EmitSoundEx({
					sound_name = sndRemove
					entity = self
					filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
				})
				local PathArrayEnd = PathArray.pop()
				PathArrayEnd[1].Destroy()
			}
			if(iButtonsPressed & IN_RELOAD)
			{
				EmitSoundEx({
					sound_name = sndChange
					entity = self
					filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
				})
				switch(iGridSize)
				{
					case 8:
						iGridSize = 16
						break
					case 16:
						iGridSize = 32
						break
					case 32:
						iGridSize = 64
						break
					case 64:
						iGridSize = 128
						break
					case 128:
						iGridSize = 8
				}
			}
	
			if(TankExt.ExistsInScope(this, "hPathVisual"))
				hPathVisual.SetAbsOrigin(vecTarget)
			else
				hPathVisual = SpawnEntityFromTable("prop_dynamic", {
					model = "models/editor/axis_helper_thick.mdl"
					disableshadows = 1
					rendermode = 1
					renderfx = 4
					renderamt = 127
				})
				
			if(TankExt.ExistsInScope(this, "hPathHatchVisual"))
			{
				if(PathArray.len() > 0)
				{
					local vecLastPath = PathArray.top()[0]
					local vecHatch = FindByClassname(null, "func_capturezone").GetCenter()
					local vecLastPathXY = Vector(vecLastPath.x, vecLastPath.y, 0)
					local vecHatchXY = Vector(vecHatch.x, vecHatch.y, 0)
					local vecDirection = vecLastPathXY - vecHatchXY
					vecDirection.Norm()
					hPathHatchVisual.SetAbsOrigin(Vector(vecHatch.x, vecHatch.y, vecTarget.z) + vecDirection * 176)
					hPathHatchVisual.SetForwardVector(vecDirection * -1)
				}
			}
			else
				hPathHatchVisual = SpawnEntityFromTable("prop_dynamic", {
					model = "models/editor/cone_helper.mdl"
					rendercolor = "255 0 255"
					disableshadows = 1
				})
	
			if(TankExt.ExistsInScope(this, "hPathTrackVisual"))
			{
				if(hNearestPathTrack)
				{
					local vecPathTrack = hNearestPathTrack.GetOrigin()
					local vecPathTrackNext = GetPropEntity(hNearestPathTrack, "m_pnext")
					local vecDirection = vecPathTrackNext ? GetPropEntity(hNearestPathTrack, "m_pnext").GetOrigin() - vecPathTrack : Vector(0, 0, -1)
					vecDirection.Norm()
					hPathTrackVisual.SetAbsOrigin(vecPathTrack)
					hPathTrackVisual.SetForwardVector(vecDirection)
					EntFireByHandle(hPathTrackVisual.FirstMoveChild(), "SetText", hNearestPathTrack.GetName(), -1, null, null)
				}
			}
			else
			{
				hPathTrackVisual = SpawnEntityFromTable("prop_dynamic", {
					model = "models/editor/cone_helper.mdl"
					disableshadows = 1
				})
				local hWorldText = SpawnEntityFromTable("point_worldtext", {
					origin = Vector(0, 0, 12)
					color = "0 255 255 255"
					font = 3
					orientation = 2
					textsize = 6
				})
				TankExt.SetParentArray([hWorldText], hPathTrackVisual)
			}
				
			if(TankExt.ExistsInScope(this, "hGlow"))
				SetPropEntity(hGlow, "m_hTarget", hLastPath)
			else
				hGlow = SpawnEntityFromTable("tf_glow", {
					targetname = "pathmakerglow"
					glowcolor = "255 255 0 255"
					target = "pathmakerglow"
				})
	
			local flTime = Time()
			if(flTime >= flTimeNext)
			{
				flTimeNext = flTime + 0.5
				local PathArrayMax = PathArray.len() - 1
				foreach(i, array in PathArray)
				{
					if(i == PathArrayMax) break
					local hPathNext = PathArray[i + 1][1]
					local vecDirection = hPathNext.GetOrigin() - array[0]
					vecDirection.Norm()
					local hParticle = SpawnEntityFromTable("info_particle_system", {
						origin = array[0]
						effect_name = "spell_lightningball_hit_zap_blue"
						start_active = 1
					})
					hParticle.SetForwardVector(vecDirection)
					SetPropEntityArray(hParticle, "m_hControlPointEnts", hPathNext, 0)
					EntFireByHandle(hParticle, "Kill", null, 0.066, null, null)
				}
			}
	
			return -1
		}
		TankExt.AddThinkToEnt(hPlayer, "PathMakerThink")
	}
	function AddThinkToEnt(hEntity, sFunction) 
	{
		local AddThink = @(ent, func) "_AddThinkToEnt" in ROOT ? ROOT._AddThinkToEnt(ent, func) : ROOT.AddThinkToEnt(ent, func)
		if(hEntity.GetClassname() == "tank_boss")
		{
			local hTank = hEntity
			hTank.ValidateScriptScope()
			local hTank_scope = hTank.GetScriptScope()
			if(!("MultiThink" in hTank_scope))
			{
				hTank_scope.ThinkTable <- {}
				hTank_scope.MultiThink <- function()
				{
					foreach(sName, sFunction in ThinkTable)
						sFunction.call(this)
					return -1
				}
				AddThink(hTank, "MultiThink")
			}
	
			if(sFunction == null)
				{ hTank_scope.ThinkTable.clear(); return }
			
			local Function
			if(sFunction in hTank_scope)
				Function = hTank_scope[sFunction]
			else if(sFunction in ROOT)
				Function = ROOT[sFunction]
	
			hTank_scope.ThinkTable[sFunction] <- Function
		}
		else
			AddThink(hEntity, sFunction)
	}
	function PrecacheSound(sSound)
	{
		if(endswith(sSound, ".wav") || endswith(sSound, ".mp3"))
			ROOT.PrecacheSound(sSound)
		else
			ROOT.PrecacheScriptSound(sSound)
	}
	ExistsInScope = @(scope, string) string in scope && (typeof(scope[string]) == "instance" || typeof(scope[string]) == "null" ? (scope[string] != null && scope[string].IsValid()) : true)
}
__CollectGameEventCallbacks(TankExt)