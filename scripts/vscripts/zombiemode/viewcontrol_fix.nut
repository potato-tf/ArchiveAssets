if (!("SetInputHook" in getroottable()))
{
	::_PostInputScope <- null;
	::_PostInputFunc  <- null;

	::SetInputHook <- function(entity, input, pre_func, post_func)
	{
		entity.ValidateScriptScope();
		local scope = entity.GetScriptScope();
		if (post_func)
		{
			local wrapper_func = function() 
			{ 
				_PostInputScope = scope; 
				_PostInputFunc  = post_func;
				if (pre_func)
					return pre_func.call(scope);
				return true;
			};
			
			scope["Input" + input]           <- wrapper_func;
			scope["Input" + input.tolower()] <- wrapper_func;
		}
		else if (pre_func)
		{
			scope["Input" + input]           <- pre_func;
			scope["Input" + input.tolower()] <- pre_func;
		}
	}
	
	getroottable().setdelegate(
	{
		_delslot = function(k)
		{
			if (_PostInputScope && k == "activator" && "activator" in this)
			{
				_PostInputFunc.call(_PostInputScope);
				_PostInputFunc = null;
			}
			
			rawdelete(k);
		}
	});		
}

if (!("CameraFixer" in getroottable()))
{
	::_CameraFixLifestate <- 0;

	::CameraFixPre <- function()
	{
		if (activator)
		{
			_CameraFixLifestate = NetProps.GetPropInt(activator, "m_lifeState");
			NetProps.SetPropInt(activator, "m_lifeState", 0);
			NetProps.SetPropEntity(self, "m_hPlayer", activator);
		}
		
		return true;
	}

	::CameraFixPost <- function()
	{
		if (activator)
		{
			NetProps.SetPropInt(activator, "m_lifeState", _CameraFixLifestate);
			NetProps.SetPropInt(activator, "m_takedamage", 2);
		}
	}
	
	::CameraDisableAll <- function()
	{
		for (local player; player = Entities.FindByClassname(player, "player");)
			EntFireByHandle(CameraFixer, "Disable", "", -1, player, player);
		EntFireByHandle(CameraFixer, "Kill", "", 1, null, null);
	}
	
	::CameraFixer <- Entities.CreateByClassname("point_viewcontrol");
	::CameraFixer.KeyValueFromString("classname", "camera_fixer");
	::CameraFixer.AddEFlags(1);
	SetInputHook(CameraFixer, "Disable", CameraFixPre, CameraFixPost);	

	SpawnEntityFromTable("logic_eventlistener", 
	{ 
		classname	 = "move_rope",
		eventname    = "teamplay_round_start",
		IsEnabled    = true,
		OnEventFired = "worldspawn,CallScriptFunction,CameraDisableAll,-1,-1",
	});

	SpawnEntityFromTable("logic_eventlistener", 
	{ 
		classname	 = "move_rope",
		eventname    = "recalculate_holidays",
		IsEnabled    = true,
		OnEventFired = "worldspawn,RunScriptCode,if (GetRoundState() == 8) CameraDisableAll(),0.1,-1",
	});
}

function Precache()
{
	SetInputHook(self, "Disable", CameraFixPre, CameraFixPost);
}