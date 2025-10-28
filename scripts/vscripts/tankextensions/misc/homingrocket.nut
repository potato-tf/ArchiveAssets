local Params = {
	Target                = null
	RocketSpeed           = 1
	TurnPower             = 0.1
	MaxAimError           = 105
	AimTime               = -1
	AimTimeStart          = 0
	Acceleration          = 0
	AccelerationTime      = -1
	AccelerationTimeStart = 0
}
if("HomingParams" in this)
	foreach(Key, Value in HomingParams)
		Params[Key] <- Value
foreach(k,v in Params)
	if(!(k in this))
		this[k] <- v

local vecVelocity = self.GetAbsVelocity() * RocketSpeed
self.SetAbsVelocity(vecVelocity)
MaxAimError = (MaxAimError > 0 ? cos(MaxAimError * 0.5 * DEG2RAD) : -1)
local iDeflected                   = 0
local flSpeed                      = vecVelocity.Length()
local InitialAimTime               = AimTime
local InitialAimTimeStart          = AimTimeStart
local InitialAccelerationTime      = AccelerationTime
local InitialAccelerationTimeStart = AccelerationTimeStart
local vecOrigin                    = self.GetOrigin()

local IsEntityInAim = function(hEnt)
{
    local vecDelta = hEnt.GetCenter() - vecOrigin
    vecDelta.Norm()
    return self.GetForwardVector().Dot(vecDelta) >= MaxAimError
}

local FindTarget = function()
{
	Target = null
	local iTeamNum = self.GetTeam()
	local flDist = 8192
	foreach(sClassname in [ "player", "obj_sentrygun", "obj_dispenser", "obj_teleporter", "tank_boss", "merasmus", "headless_hatman", "eyeball_boss", "tf_zombie" ])
		for(local hEnt; hEnt = FindByClassnameWithin(hEnt, sClassname, vecOrigin, flDist);)
		{
			local vecCenter    = hEnt.GetCenter()
			local bCenterTrace = TraceLine(vecCenter, vecOrigin, self) == 1
			if
			(
				bCenterTrace &&
				hEnt.IsAlive() &&
				hEnt.GetTeam() != iTeamNum &&
				!(hEnt.GetFlags() & FL_NOTARGET) &&
				!TankExt.IsPlayerStealthedOrDisguised(hEnt) &&
				(MaxAimError == -1 ? true : IsEntityInAim(hEnt))
			)
			{
				Target = hEnt
				flDist = (vecCenter - vecOrigin).Length()
			}
		}
}
local InitializeHoming = function()
{
	local flTime = Time()
	AimTime               = InitialAimTime >= 0 ? flTime + InitialAimTime : -1
	AimTimeStart          = flTime + InitialAimTimeStart
	AccelerationTime      = AccelerationTime >= 0 ? flTime + AccelerationTime : -1
	AccelerationTimeStart = flTime + InitialAccelerationTimeStart
	if(!Target) FindTarget()
}
InitializeHoming()

function HomingThink()
{
	if(!self.IsValid()) return
	vecOrigin = self.GetOrigin()
	local flTime            = Time()
	local iCurrentDeflected = GetPropInt(self, "m_iDeflected")
	if(iDeflected != iCurrentDeflected)
	{
		iDeflected = iCurrentDeflected
		Target     = null
		InitializeHoming()
	}

	if(!Target || !Target.IsValid() || !Target.IsAlive() || Target.GetTeam() == self.GetTeam() || TankExt.IsPlayerStealthedOrDisguised(Target) || (MaxAimError == -1 ? false : !IsEntityInAim(Target))) FindTarget()
	else if(flTime >= AimTimeStart && (AimTime == -1 || flTime < AimTime))
	{
		local vecTarget = Target.GetCenter() - vecOrigin
		vecTarget.Norm()
		local vecForward = self.GetForwardVector()
		local vecGoal = vecForward + (vecTarget - vecForward) * TurnPower
		vecGoal.Norm()
		self.SetAbsVelocity(vecGoal * flSpeed)
		self.SetForwardVector(vecGoal)

		if(flTime >= AccelerationTimeStart && (AccelerationTime == -1 || flTime < AccelerationTime)) flSpeed += Acceleration * FrameTime()
	}
	return -1
}
TankExt.AddThinkToEnt(self, "HomingThink")