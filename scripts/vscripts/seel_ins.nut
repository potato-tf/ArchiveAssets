//Seelpit's Icon maNipulator Script (SINS)

//Functions:
//ChangeIconByIndex(index,name)	Changes the icon at the specified index to the icon with the specified name.

//ChangeIconByName(oldName,newName)	Changes the icon with the specified name to the icon with the specified name.

//FindIndexOfIcon(name)			Finds the index of the icon with the specified name. Mostly used internally, but may be useful for other scripts.

//ChangeClassIcon(player,name)	Changes the classicon, but not the wavebar icon, of the specified player (handle) to the icon with the specified name. Typically for bosses with healthbars.

//ChangeIconFlags(name,flags)	Changes the icon with the specified name's flags.

//ToggleIconFlags(name,flagsString)	Simpler caller of ChangeIconFlags. Toggles whether an icon is a giant or common; crit or not; support or mainwave; and mission support IF support.
//									Format with strings, f.e.: ToggleIconFlags("soldier","crit|support") ; ToggleIconFlags("soldier","giant|support")

//Namespace base by ficool
foreach(k,v in NetProps.getclass())
	if (k != "IsValid")
		getroottable()[k] <- NetProps[k].bindenv(NetProps);

printl("Seelpit's Icon maNipulator Script loaded and ready for use.")

local iMaxEnemyCount = 0
local iCurrentEnemyCount = 0
local flWaveProgress = 1
local hTFOR = Entities.FindByClassname(null,"tf_objective_resource")
	
::SINS <- 
{
	Cleanup = function()
	{
		// cleanup any persistent changes here
		
		AddThinkToEnt(hTFOR, null)
		// keep this at the end
		if (SINS)
			delete ::SINS;
	}
	
	// mandatory events
	OnGameEvent_recalculate_holidays = function(_) { if (GetRoundState() == 3) Cleanup() }
	OnGameEvent_mvm_wave_complete = function(_) { Cleanup() }
	
	
	DEBUG = false
	EngageDebugMode = function()
	{
		printl("SINS - Debug mode manually engaged!")
	}
	
	
	MaxPlayers = MaxClients().tointeger()
	
	IconsToChangeTable = {}
	HiddenIcons = {}

	GetIconByHandle = function(handle)
	{
		if (!handle.IsValid())
		{
			printl("SINS ERROR: Invalid player for GetIconByHandle!")
		}
		return GetPropString(handle, "m_PlayerClass.m_iszClassIcon")
	}
	//Finds the index of the given icon on the wavebar. Intended for internal use, but global for accessibility.
	//@string name	: name of the icon.
	FindIndexOfIcon = function(name)
	{
		local i = 0 //Check: do I start at 0 or at 1?
		local two = ""
		local i2 = 0
		for(i; i < 24; i+=1) //Check: and thus, do I end at 24, or 23?
		{
			if (i >= 12) two = "2.",i2 = 12;
			
			local curIconName = GetPropStringArray(hTFOR, "m_iszMannVsMachineWaveClassNames"+two, i-i2)
			if (curIconName == name)
				return i;
		}
		printf("Icon name '%s' not found!\n",name)
		return null;
	}
	//Finds the enemy count of the given icon on the wavebar. Intended for internal use, but global for accessibility.
	//@string name	: name of the icon.
	FindCountOfIcon = function(name)
	{
		local iIconIndex = FindIndexOfIcon(name)
		
		if (iIconIndex == null) return 0;
		
		local two = ""
		local i2 = 0
		if (iIconIndex >= 12) two = "2.",i2 = 12;
		local iIconCount = GetPropIntArray(hTFOR, "m_nMannVsMachineWaveClassCounts"+two, iIconIndex-i2);
		return iIconCount
	}

	
	//Returns the flags of the icon with the specified name.
	//@string iconName : name of the icon to get the flags of.
	//If the icon is not on the wavebar, returns NULL.
	GetIconFlags = function(iconName)
	{
		local iconIndex = FindIndexOfIcon(iconName)
		if (iconIndex == null) return null;
		
		local two = ""
		local i2 = 0
		if (iconIndex >= 12) two = "2.",i2 = 12; //Was this dot ever fixed? Getting fixed? Hopefully.
		local flags = GetPropIntArray(hTFOR, "m_nMannVsMachineWaveClassFlags"+two, iconIndex)
		return flags
	}
	
	
	//Changes icon of specified index on the wavebar to icon with the specified name. Uses parts of lite's hideicons script.
	//@integer	index	: index of the given icon. Can be determined by counting unique icons in WaveSpawn order.
	//@string	name	: name of the new icon.
	ChangeIconByIndex = function(index, name)
	{
		local two = ""
		local i2 = 0
		if (index >= 12) two = "2.",i2 = 12; //Was this dot ever fixed? Getting fixed? Hopefully.
		SetPropStringArray(hTFOR, "m_iszMannVsMachineWaveClassNames"+two, name, index-i2)
	}
	
	
	//Changes only the wavebar icon with the specified name to the icon with the specified new name.
	//@string	oldName	: name of the icon to change.
	//@string	newName	: name of the new icon.
	ChangeIconByName = function(oldName, newName)
	{
		local iconIndex = FindIndexOfIcon(oldName)
		if (iconIndex == null) return;
		
		printf("%s found at %d! Changing to %s...\n",oldName,iconIndex,newName)
		ChangeIconByIndex(iconIndex,newName)
	}
	
	
	//Wrapper that changes the given player's class icon. More convenient than writing it all out.
	//Does NOT change the wavebar icon.
	ChangeClassIcon = function(player, name)
	{
		SetPropString(player, "m_PlayerClass.m_iszClassIcon", name)
	}

	//Changes both the class icon and the wavebar icon. Assumes wavebar icon is the same as player's classicon!
	//@handle player : A player (bot) to change the icon of.
	//@string name	 : name of the icon to change to.
	ChangeClassIconAndWavebar = function(player, name)
	{
		if (!(player)) return;
		
		local iconNameOld = GetIconByHandle(player)
		local iconIndex = FindIndexOfIcon(oldName)
		
		if (iconIndex == null) return;
		
		printf("%s found at %d! Changing to %s...\n",iconNameOld,iconIndex,name)
		ChangeClassIcon(player, name)
		ChangeIconByIndex(iconIndex,name)
	}
	
	//Changes icons of all bots that match the provided tag.
	//@string	tag				: tag of the bots whose icon should be changed.
	//@string	iconName		: name of the icon to change to.
	//@bool		updateClassIcon	: whether to also change the classicon. Default: true.
	ChangeIconByTag = function(tag,iconName,updateWavebarIcon = true,updateClassIcon = true)
	{
		for (local i = 1; i <= MaxPlayers ; i++)
		{
			local player = PlayerInstanceFromIndex(i)
			if (player == null) continue
			if (!player.IsBotOfType(TF_BOT_TYPE)) continue
			if (!player.HasBotTag(tag)) continue
			
			local oldIcon = GetIconByHandle(player)
			
			if (updateWavebarIcon)
				ChangeIconByIndex(FindIndexOfIcon(oldIcon),iconName)
			
			if (updateClassIcon)
				ChangeClassIcon(player,iconName)
		}
	}
	
	//Changes "flags" of the given icon.
	//@string	iconName	: name of the icon whose flags to change.
	//@int		flags		: flags to set on the icon. Valid values below.
	//POSITION FLAGS: 0 = not on wavebar;	1 = mainwave;	2 = Support;	4 = Mission Support, is put right of other Support. Also causes Engineer, Spy, and Sentry Buster icons to flash.
	//VISUAL FLAGS:   8 = red background, for giants and tanks;		16 = blue flashing outline, for crits
	ChangeIconFlags = function(iconName,flags)
	{
		local iconIndex = FindIndexOfIcon(iconName)
		
		if (iconIndex == null) return;
		
		local oldFlags = GetIconFlags(iconName)
		printf("%s found at %d! Changing its flags from %d to %d...\n",iconName,iconIndex,oldFlags,flags)
		
		local two = ""
		local i2 = 0
		if (iconIndex >= 12) two = "2.",i2 = 12; //Was this dot ever fixed? Getting fixed? Hopefully.
		
		SetPropIntArray(hTFOR, "m_nMannVsMachineWaveClassFlags"+two, flags, iconIndex-i2)
	}
	
	//TODO: finish finding a neat way to do this
	ToggleIconFlags = function(name,flagsString)
	{
		local flags = split(flagsString,"|")
		local validFlags = {
			mainwave = 1,
			support = 2,
			mission = 4,
			giant = 8,
			crit = 16,
		}
		foreach(flag in flags)
		{
			if (!(validFlags[flag] & existingFlags))
			{
				if (validFlags[flag] & validFlags[mainwave] || validFlags[flag] & validFlags[support] || validFlags[flag] & validFlags[mission])
					existingFlags = existingFlags & validFlags[mainwave]
				existingFlags = existingFlags & validFlags[flag];
				print("New flags: "+existingFlags.tostring() + "\n");
			}
		}
	}
	
	HideIcon = function(name)
	{
		local iIconIndex 				= FindIndexOfIcon(name)
		local iIconEnemyCount			= FindCountOfIcon(name)
		local iIconFlags 				= GetIconFlags(name)
		local iMaxEnemyCountAfterHide 	= iMaxEnemyCount - iIconEnemyCount
		
		HiddenIcons[name] <- { flags = iIconFlags, count = iIconEnemyCount }
		
		ChangeIconFlags(name,0)
		SetPropInt(hTFOR,"m_nMannVsMachineWaveEnemyCount",iMaxEnemyCountAfterHide)
	}
	UnhideIcon = function(name)
	{
		local iIconFlags = GetIconFlags(name)
		if (!name in HiddenIcons || iIconFlags != 0)
		{
			printl("You can't un-hide an icon that's not hidden, dummy.")
			return;
		}
		iIconFlags 						= HiddenIcons[name].flags
		local iIconCount 				= HiddenIcons[name].count
		local iMaxEnemyCountAfterUnhide = iMaxEnemyCount + iIconCount
		
		ChangeIconFlags(name, HiddenIcons[name].flags)
		SetPropInt(hTFOR,"m_nMannVsMachineWaveEnemyCount",iMaxEnemyCountAfterUnhide)
	}
}
__CollectGameEventCallbacks(SINS)

if (SINS.DEBUG)
	printl("SINS - Debug mode engaged!")

//This think is on the tf_objective_resource.
::IconCountThink <- function()
{
	local iCurrentEnemyCount = 0
	
	local i = 0
	local two = ""
	local i2 = 0
	for(i; i < 24; i+=1)
	{
		if (i >= 12) two = "2.",i2 = 12;
		
		local iFlags = GetPropIntArray(hTFOR, "m_nMannVsMachineWaveClassFlags"+two, i-i2)
		if (!(iFlags & 1)) continue; //Support is not counted, nor are any that are invisible.
		
		local iIconCount = GetPropIntArray(hTFOR, "m_nMannVsMachineWaveClassCounts"+two, i-i2)
		iCurrentEnemyCount = iCurrentEnemyCount + iIconCount
	}
	
	iMaxEnemyCount = GetPropInt(hTFOR, "m_nMannVsMachineWaveEnemyCount")
	
	if(SINS.DEBUG)
	{
		ClientPrint(null,4,format("Current enemy count / max enemy count:\n%i / %i",iCurrentEnemyCount,iMaxEnemyCount))
	}
	
	flWaveProgress = iCurrentEnemyCount.tofloat() / iMaxEnemyCount.tofloat()
	return -1
}

AddThinkToEnt(hTFOR, "IconCountThink")