////////////////////////////////////////////////////////////////////////////////////////////
// example tank name : "combattank|rocketpod|minigun"
// add _red to combattank for a red teamed tank
// second argument, rocketpod, places it on the tank's left side
// third argument, minigun, places it on the tank's right side
// intended to be put onto a LOOPING path
////////////////////////////////////////////////////////////////////////////////////////////
// look at scripts inside of the combattank_weapons folder for weapon names
////////////////////////////////////////////////////////////////////////////////////////////
// popfile example can be found at https://testing.potato.tf/tf/scripts/population/mvm_slick_v4_combattank.pop
////////////////////////////////////////////////////////////////////////////////////////////

local COMBATTANK_VALUES_TABLE = {
	COMBATTANK_SND_ROTATE           = ")plats/tram_move.wav"
	COMBATTANK_ROTATE_SPEED_DEFAULT = 0.8
	COMBATTANK_POSE_YAW             = 2
	COMBATTANK_POSE_PITCH           = 1
	COMBATTANK_MODEL                = "models/bots/boss_bot/combat_tank/combat_tank.mdl"
	COMBATTANK_TRACK_L_BLUE         = "models/bots/boss_bot/tank_track_l.mdl"
	COMBATTANK_TRACK_R_BLUE         = "models/bots/boss_bot/tank_track_r.mdl"
	COMBATTANK_TRACK_L_RED          = "models/bots/boss_bot/tankred_track_l.mdl"
	COMBATTANK_TRACK_R_RED          = "models/bots/boss_bot/tankred_track_r.mdl"
	COMBATTANK_MAX_RANGE            = 1400
}
foreach(k,v in COMBATTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(COMBATTANK_MODEL)
PrecacheModel(COMBATTANK_TRACK_L_BLUE)
PrecacheModel(COMBATTANK_TRACK_R_BLUE)
PrecacheModel(COMBATTANK_TRACK_L_RED)
PrecacheModel(COMBATTANK_TRACK_R_RED)
TankExt.PrecacheSound(COMBATTANK_SND_ROTATE)

::CombatTankWeapons <- {}

function TankExt::IsPlayerStealthedOrDisguised(player)
{
	return (player.IsStealthed() || player.InCond(TF_COND_DISGUISED)) &&
		!player.InCond(TF_COND_BURNING) &&
		!player.InCond(TF_COND_URINE) &&
		!player.InCond(TF_COND_STEALTHED_BLINK) &&
		!player.InCond(TF_COND_BLEEDING)
}
function TankExt::CombatTankRefreshSkin(hTank)
{
	local hTank_scope = hTank.GetScriptScope()
	if(hTank_scope == null) return
	local bBlueTeam = hTank.GetTeam() == 3

	local iSkin = bBlueTeam ? hTank_scope.bUbered ? 5 : 2 + hTank_scope.iSkinLast : hTank_scope.bUbered ? 4 : hTank_scope.iSkinLast
	local iSkinWeapon = bBlueTeam ? hTank_scope.bUbered ? 3 : 1 : hTank_scope.bUbered ? 2 : 0

	TankExt.SetTankModel(hTank, {
		LeftTrack = bBlueTeam ? COMBATTANK_TRACK_L_BLUE : COMBATTANK_TRACK_L_RED
		RightTrack = bBlueTeam ? COMBATTANK_TRACK_R_BLUE : COMBATTANK_TRACK_R_RED
	})

	hTank.SetSkin(iSkin)
	for(local hChild = hTank.FirstMoveChild(); hChild != null; hChild = hChild.NextMovePeer())
		if(HasProp(hChild, "m_nSkin")) hChild.SetSkin(iSkinWeapon)
	
	if(TankExt.ExistsInScope(hTank_scope, "hBeam"))
		TankExt.SetEntityColor(hTank_scope.hBeam, bBlueTeam ? 0 : 255, 0, bBlueTeam ? 255 : 0, 255)
	if(TankExt.ExistsInScope(hTank_scope, "hBeamEnd"))
		TankExt.SetEntityColor(hTank_scope.hBeamEnd, bBlueTeam ? 0 : 255, 0, bBlueTeam ? 255 : 0, 255)
}
function TankExt::CombatTankPlaySound(SoundTable, bLooping = false)
{
	local hTank_scope = SoundTable.entity.GetScriptScope()
	local SoundPlaying = hTank_scope.SoundPlaying
	local sSoundName = SoundTable.sound_name

	if(bLooping)
	{
		sSoundName += "_LOOPING"
		if(sSoundName in SoundPlaying)
			return
	}
	
	hTank_scope.SoundQueue[sSoundName] <- SoundTable
}
function TankExt::CombatTankStopSound(SoundTable)
{
	local hTank_scope = SoundTable.entity.GetScriptScope()
	local SoundPlaying = hTank_scope.SoundPlaying
	local sSoundName = SoundTable.sound_name

	if(sSoundName in SoundPlaying)
		delete SoundPlaying[sSoundName]
	if(sSoundName + "_LOOPING" in SoundPlaying)
		delete SoundPlaying[sSoundName + "_LOOPING"]
	
	EmitSoundEx(SoundTable)
}

TankExt.NewTankScript("combattank*", {
	Model = {
		Default = COMBATTANK_MODEL
	}
	DisableBomb = 1
	OnSpawn = function(hTank, sName, hPath)
	{
		local hTank_scope = hTank.GetScriptScope()

		hTank_scope.SoundPlaying <- {}
		hTank_scope.SoundQueue <- {}

		hTank_scope.LaserTrace <- {}
	
		hTank_scope.angCurrent <- QAngle()
		hTank_scope.angGoalIdle <- QAngle()
		hTank_scope.angGoal <- QAngle()

		hTank_scope.hEnemy <- null
		hTank_scope.hEnemyLast <- null
		hTank_scope.vecEnemyTarget <- null
		hTank_scope.vecMount <- null
		hTank_scope.flRotateSpeed <- COMBATTANK_ROTATE_SPEED_DEFAULT
		hTank_scope.flAngleDist <- 360.0
		hTank_scope.iDirIdle <- 1
		hTank_scope.iTeamNumLast <- hTank.GetTeam()
		hTank_scope.bMovingLast <- false

		hTank_scope.bUbered <- false

		TankExt.CombatTankPlaySound({
			sound_name = COMBATTANK_SND_ROTATE
			sound_level = 85
			entity = hTank
			filter_type = RECIPIENT_FILTER_GLOBAL
			pitch = 90
		}, true)

		local sParams = split(sName, "|")
		if(sParams.len() == 3)
		{
			if(sParams[0].find("_red"))
				hTank.SetTeam(2)
			
			if(sParams[0].find("_nolaser") == null)
			{
				local iTankIndex = hTank.entindex()
				local sLaserStart = "laserstart_" + iTankIndex
				local sLaserEnd = "laserend_" + iTankIndex
				local hBeamEnd = SpawnEntityFromTable("env_sprite", { targetname = sLaserEnd, model = "sprites/glow1.vmt", spawnflags = 1, rendermode = 5 })
				SetPropBool(hBeamEnd, "m_bForcePurgeFixedupStrings", true)
				local hBeam = SpawnEntityFromTable("env_beam", { targetname = sLaserStart, lightningstart = sLaserStart, lightningend = sLaserEnd, boltwidth = 0.75, spawnflags = 1, texture = "sprites/laserbeam.vmt" })
				SetPropBool(hBeam, "m_bForcePurgeFixedupStrings", true)
				hTank_scope.hBeam <- hBeam
				hTank_scope.hBeamEnd <- hBeamEnd
			}

			for(local i = 1; i <= 2; i++)
				if(sParams[i] in CombatTankWeapons)
				{
					local WeaponTable = CombatTankWeapons[sParams[i]]
					local hWeapon
					if("Spawn" in WeaponTable)
					{
						hWeapon = WeaponTable.Spawn(hTank)
						TankExt.SetParentArray([hWeapon], hTank, i == 1 ? "weapon_r" : "weapon_l")
					}
					if("OnDeath" in WeaponTable)
						TankExt.SetDestroyCallback(hWeapon, WeaponTable.OnDeath)
				}
		}
		else
		{
			ClientPrint(null, 3, format("\x07ffb2b2[ERROR] Wrong number of CombatTank parameters (%i passed, 3 required)", sParams.len()))
			return
		}
		
		hTank_scope.iSkinLast <- hTank.GetSkin() & 1
		TankExt.CombatTankRefreshSkin(hTank)

		hTank_scope.ToggleUber <- function()
		{
			if(!bUbered)
			{
				bUbered = true
				local sndUber = {
					sound_name = "player/invulnerable_on.wav"
					filter_type = RECIPIENT_FILTER_GLOBAL
				}
				TankExt.PrecacheSound(sndUber.sound_name)
				EmitSoundEx(sndUber)
				SetPropInt(self, "m_takedamage", 1)
				TankExt.CombatTankRefreshSkin(self)
			}
			else
			{
				bUbered = false
				local sndUberOff = {
					sound_name = "player/invulnerable_off.wav"
					filter_type = RECIPIENT_FILTER_GLOBAL
				}
				TankExt.PrecacheSound(sndUberOff.sound_name)
				EmitSoundEx(sndUberOff)
				EntFireByHandle(self, "RunScriptCode", "SetPropInt(self, `m_takedamage`, 2)", 1, null, null)
				EntFireByHandle(self, "RunScriptCode", "TankExt.CombatTankRefreshSkin(self)", 1, null, null)
			}
		}

		hTank_scope.CombatThink <- function()
		{
			local iTeamNum = self.GetTeam()
			if(iTeamNum != iTeamNumLast)
			{
				iTeamNumLast = iTeamNum
				TankExt.CombatTankRefreshSkin(self)
			}
			
			if(!GetPropBool(self, "m_bGlowEnabled")) // this entfire is here because sometimes the glow doesnt realize its team has been changed
			{
				EntFireByHandle(self, "RunScriptCode", "SetPropBool(self, `m_bGlowEnabled`, true)", 0.066, null, null)
				EntFireByHandle(self, "RunScriptCode", "SetPropBool(self, `m_bGlowEnabled`, true)", 0.1, null, null)
			}
					
			local vecOrigin = self.GetOrigin()
			local angRotation = self.GetAbsAngles()
			vecMount = self.GetAttachmentOrigin(self.LookupAttachment("weapon_l"))

			foreach(sName, SoundTable in SoundQueue)
			{
				delete SoundQueue[sName]
				if(sName.find("_LOOPING") != null)
				{
					if(!(sName in SoundPlaying))
					{
						SoundPlaying[sName] <- SoundTable.sound_name
						EmitSoundEx(SoundTable)
					}
				}
				else
					EmitSoundEx(SoundTable)
			}
		
			hEnemy = null
			vecEnemyTarget = null
			local FindValidTarget = function(sClassname)
			{
				local flTargetDist = COMBATTANK_MAX_RANGE
				for(local hEnt; hEnt = FindByClassnameWithin(hEnt, sClassname, vecOrigin, COMBATTANK_MAX_RANGE);)
				{
					local vecEntCenter = hEnt.GetCenter()
					local vecEntEye = "EyePosition" in hEnt ? hEnt.EyePosition() : vecEntCenter
					local flEntDist = (vecEntCenter - vecMount).Length()
					local bCenterTrace = TraceLine(vecEntCenter, vecMount, self) == 1
					local bEyeTrace = TraceLine(vecEntEye, vecMount, self) == 1
					if(
						hEnt.GetTeam() != iTeamNum &&
						hEnt.IsAlive() &&
						bEyeTrace &&
						flTargetDist > flEntDist &&
						(sClassname == "player" ? !TankExt.IsPlayerStealthedOrDisguised(hEnt) : true) &&
						!(hEnt.GetFlags() & FL_NOTARGET)
					)
					{
						hEnemy = hEnt
						vecEnemyTarget = bCenterTrace ? vecEntCenter : vecEntEye
						flTargetDist = flEntDist
					}
				}
			}
			local EntityPriority = [
				"player"
				"obj_sentrygun"
				"obj_dispenser"
				"obj_teleporter"
				"tank_boss"
				"merasmus"
				"headless_hatman"
				"eyeball_boss"
				"tf_zombie"
			]
			foreach(sClassname in EntityPriority)
			{
				FindValidTarget(sClassname)
				if(hEnemy) break
			}
					
			if(hEnemy != hEnemyLast)
			{
				hEnemyLast = hEnemy
				if(hEnemy)
				{
					EmitSoundEx({
						sound_name = "weapons/sentry_spot.wav"
						entity = self
						filter_type = RECIPIENT_FILTER_GLOBAL
						flags = SND_STOP
					})
					EmitSoundEx({
						sound_name = "weapons/sentry_spot_client.wav"
						entity = hEnemy
						filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
						flags = SND_STOP
					})
					EmitSoundEx({
						sound_name = "weapons/sentry_spot.wav"
						sound_level = 80
						entity = self
						filter_type = RECIPIENT_FILTER_GLOBAL
						pitch = 95
					})
					EmitSoundEx({
						sound_name = "weapons/sentry_spot_client.wav"
						entity = hEnemy
						filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
						pitch = 95
					})
				}
			}

			local iLaser = self.LookupAttachment("laser_origin")
			local vecLaser = self.GetAttachmentOrigin(iLaser)
			local angLaser = self.GetAttachmentAngles(iLaser)
			LaserTrace = {
				start = vecLaser
				end = vecLaser + angLaser.Forward() * 8192
				ignore = hTank
				mask = MASK_SHOT_HULL
			}
			TraceLineEx(LaserTrace)

			if(hEnemy)
			{
				if("enthit" in LaserTrace && LaserTrace.enthit == hEnemy)
					LaserTrace.endpos = vecEnemyTarget

				flRotateSpeed = COMBATTANK_ROTATE_SPEED_DEFAULT
				local vecDirToEnemy = vecEnemyTarget - vecMount
				vecDirToEnemy = RotatePosition(Vector(), angRotation * -1, vecDirToEnemy)
				local angToTarget = TankExt.VectorToQAngle(vecDirToEnemy)
		
				angToTarget.y = 360.0 - angToTarget.y
				angToTarget.x = -TankExt.Clamp(angToTarget.x - (angToTarget.x > 180 ? 360 : 0), -14, 14)
				angGoal = angToTarget
			}
			else if(!bMovingLast)
			{
				flRotateSpeed = COMBATTANK_ROTATE_SPEED_DEFAULT * 0.5
				iDirIdle = 0 - iDirIdle
				angGoal = QAngle(RandomFloat(-10, 10), 50 * iDirIdle + (iDirIdle == -1 ? 360 : 0), 0)
			}
			
			if("hBeam" in this)
			{
				hBeam.SetAbsOrigin(vecLaser)
				hBeamEnd.SetAbsOrigin(LaserTrace.endpos)
			}
			
			////////// RotateMount //////////
		
			local bMoving = false
		
			if(fabs(angCurrent.x - angGoal.x) > 0.001) // the wonders of floating point imprecision
			{
				local iDir = angGoal.x > angCurrent.x ? 1 : -1
				angCurrent.x += flRotateSpeed * 0.5 * iDir
		
				if(iDir == 1 ? angCurrent.x > angGoal.x : angCurrent.x < angGoal.x)
					angCurrent.x = angGoal.x
				bMoving = true
			}
			self.SetPoseParameter(COMBATTANK_POSE_PITCH, angCurrent.x)
		
			if(angCurrent.y != angGoal.y)
			{
				local iDir = angGoal.y > angCurrent.y ? 1 : -1
				local flDist = fabs(angGoal.y - angCurrent.y)
				local bReversed = false
				if(flDist > 180)
				{
					flDist = 360 - flDist
					iDir = -iDir
					bReversed = true
				}
		
				angCurrent.y += flRotateSpeed * iDir
		
				if(iDir == -1 ? bReversed ? angGoal.y < angCurrent.y : angGoal.y > angCurrent.y : bReversed ? angGoal.y > angCurrent.y : angGoal.y < angCurrent.y)
					angCurrent.y = angGoal.y
		
				if(angCurrent.y < 0)
					angCurrent.y += 360
				else if(angCurrent.y >= 360)
					angCurrent.y -= 360
		
				bMoving = true
			}
			self.SetPoseParameter(COMBATTANK_POSE_YAW, angCurrent.y)
			
			// this isnt the exact angle length between the two but its close
			flAngleDist = hEnemy ? ((angCurrent.Forward() - angGoal.Forward()) * 64).Length() : null
		
			bMovingLast = bMoving
			return -1
		}
		TankExt.AddThinkToEnt(hTank, "CombatThink")
	}
	OnDeath = function()
	{
		foreach(sName, sSoundName in SoundPlaying)
			EmitSoundEx({
				sound_name = sSoundName
				entity = self
				filter_type = RECIPIENT_FILTER_GLOBAL
				flags = SND_STOP
			})
		if(TankExt.ExistsInScope(this, "hBeam")) hBeam.Destroy()
		if(TankExt.ExistsInScope(this, "hBeamEnd")) hBeamEnd.Destroy()
	}
})