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
	
::SINS <- 
{
	Cleanup = function()
	{
		// cleanup any persistent changes here
		
		// keep this at the end
		if (SINS)
			delete ::SINS;
	}
	
	// mandatory events
	OnGameEvent_recalculate_holidays = function(_) { if (GetRoundState() == 3) Cleanup() }
	OnGameEvent_mvm_wave_complete = function(_) { Cleanup() }

	tfor = Entities.FindByClassname(null,"tf_objective_resource")

	//Changes icon of specified index on the wavebar to icon with the specified name. Uses parts of lite's hideicons script.
	ChangeIconByIndex = function(index, name)
	{
		local two = ""
		local i2 = 0
		if (index >= 12) two = "2.",i2 = 12; //Was this dot ever fixed? Getting fixed? Hopefully.
		SetPropStringArray(tfor, "m_iszMannVsMachineWaveClassNames"+two, name, index-i2)
	}
	//Changes only the wavebar icon with the specified name to the icon with the specified new name.
	ChangeIconByName = function(oldName, newName)
	{
		local iconIndex = FindIndexOfIcon(oldName)
		if (iconIndex == null) return;
		
		printf("%s found at %d! Changing to %s...\n",oldName,iconIndex,newName)
		ChangeIconByIndex(iconIndex,newName)
	}
	//Finds the index of the given icon on the wavebar.
	//Global for ease of use.
	//@string name	: name of the icon.
	FindIndexOfIcon = function(name)
	{
		local i = 0 //Check: do I start at 0 or at 1?
		local two = ""
		local i2 = 0
		for(i; i < 24; i+=1) //Check: and thus, do I end at 24, or 23?
		{
			if (i >= 12) two = "2.",i2 = 12;
			
			local curIconName = GetPropStringArray(tfor, "m_iszMannVsMachineWaveClassNames"+two, i-i2)
			if (curIconName == name)
				return i;
		}
		printf("Icon name '%s' not found!\n",name)
		return null;
	}
	//Wrapper that changes the given player's class icon. More convenient than writing it all out.
	//Does NOT change the wavebar icon.
	ChangeClassIcon = function(player, name)
	{
		SetPropString(player, "m_PlayerClass.m_iszClassIcon", name)
	}

	//Changes both the class icon and the wavebar icon. Assumes wavebar icon is the same as player's classicon!
	//@handle player : A player (bot) to change the icon of.
	//@string name : name of the icon to change to.
	ChangeClassIconAndWavebar = function(player, name)
	{
		if (!(player)) return;
		local iconNameOld = GetPropString(player, "m_PlayerClass.m_iszClassIcon")
		local iconIndex = FindIndexOfIcon(oldName)
		if (iconIndex == null) return;
		
		printf("%s found at %d! Changing to %s...\n",iconNameOld,iconIndex,name)
		ChangeClassIcon(player, name)
		ChangeIconByIndex(iconIndex,name)
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
		local flags = GetPropIntArray(tfor, "m_nMannVsMachineWaveClassFlags"+two, iconIndex)
		return flags
	}
	ChangeIconFlags = function(iconName,flags)
	{
		local iconIndex = FindIndexOfIcon(iconName)
		if (iconIndex == null) return;
		
		local oldFlags = GetIconFlags(iconName)
		printf("%s found at %d! Changing its flags from %d to %d...\n",iconName,iconIndex,oldFlags,flags)
		
		local two = ""
		local i2 = 0
		if (iconIndex >= 12) two = "2.",i2 = 12; //Was this dot ever fixed? Getting fixed? Hopefully.
		SetPropIntArray(tfor, "m_nMannVsMachineWaveClassFlags"+two, flags, iconIndex-i2)
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
}
__CollectGameEventCallbacks(SINS)