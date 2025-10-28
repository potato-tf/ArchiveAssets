//Seelpit's Icon maNipulator Script (SINS)

//////////////////////////////////////////////////////////
//						Functions						//
//////////////////////////////////////////////////////////

//ChangeIconByIndex(index,name)	Changes the icon at the specified index to the icon with the specified name.

//ChangeIconByName(oldName,newName)	Changes the icon with the specified name to the icon with the specified name.

//FindIndexOfIcon(name)			Finds the index of the icon with the specified name. Mostly used internally, but may be useful for other scripts.

//ChangeClassIcon(player,name)	Changes the classicon, but not the wavebar icon, of the specified player (handle) to the icon with the specified name. Typically for bosses with healthbars.

//ChangeClassIconAndWavebar(player,name)	Changes both the class icon and the wavebar icon. Assumes wavebar icon is the same as player's classicon!

//ChangeIconFlags(name,flags)	Changes the icon with the specified name's flags.

//ToggleIconFlags(name,flagsString)	Simpler caller of ChangeIconFlags. Toggles whether an icon is a giant or common; crit or not; support or mainwave; and mission support IF support.
//									Format with strings, f.e.: ToggleIconFlags("soldier","crit|support") ; ToggleIconFlags("soldier","giant|support")

//PrintAllIconNames()	Prints all the icon names per index of the wave. May be useful for debugging in what order they're in.

//////////////////////////////////////////////////////////

//Namespace base by ficool
foreach(k,v in NetProps.getclass())
	if (k != "IsValid")
		getroottable()[k] <- NetProps[k].bindenv(NetProps);

printl("Seelpit's Icon maNipulator Script loaded and ready for use.")

local iMaxEnemyCount = 0
local iCurrentEnemyCount = 0
local flWaveProgress = 1
::hTFOR <- Entities.FindByClassname(null,"tf_objective_resource")
if (!("TF_BOT_TYPE" in this))
	::TF_BOT_TYPE <- 1337
	
::SINS <- 
{
	Cleanup = function()
	{
		// cleanup any persistent changes here
		
		AddThinkToEnt(hTFOR, null)
		
		for (local i = 1; i <= MaxPlayers ; i++)
		{
			local hPlayer = PlayerInstanceFromIndex(i)
			if (hPlayer == null) continue
			local hScope = hPlayer.GetScriptScope()
			if ( "iszClassIconOld" in hScope )
				delete hScope.iszClassIconOld
		}
		
		
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
		DEBUG = true
	}
	
	
	MaxPlayers = MaxClients().tointeger()
	
	IconsToChangeTable = {}
	HiddenIcons = {}
	arIconMemory = {}
	arStartWave = []
	
	OnGameEvent_mvm_begin_wave = function(_)
	{
		foreach(func in arStartWave)
			func()
	}
	OnGameEvent_player_death = function(params)
	{
		local hDied = GetPlayerFromUserID(params.userid)
		
		if ( !(hDied.IsBotOfType(TF_BOT_TYPE)) ) return;
		
		local hScope = hDied.GetScriptScope()
		
		local iszClassIcon = GetIconByHandle(hDied)
		if ( "iszClassIconOld" in hScope )
		{
			// CASE: the bot's ClassIcon was changed, and its original icon is on the wavebar.
			// Result: decrement from original icon and delete scope variable.
			if ( iszClassIcon != hScope.iszClassIconOld && GetIndexOfIcon(hScope.iszClassIconOld) )
				DecrementIconCount(hScope.iszClassIconOld)
			
			// CASE: the bot's ClassIcon was changed, but its current or original icon are NOT on the wavebar.
			// Result: check memory for newly matching icon. 
			else if ( iszClassIcon in arIconMemory )
					DecrementIconCount(arIconMemory[iszClassIcon])
				
			// CASE: the bot's ClassIcon was changed, but its current or original icon are NOT on the wavebar,
			// 		 AND its "new" icon is not in memory.
			// Result: check memory for old icon as final resort.
			else if ( hScope.iszClassIconOld in arIconMemory )
					DecrementIconCount(arIconMemory[hScope.iszClassIconOld])
			
			else
				printl(" [[MEMORY]] I don't know what you did, but you didn't fit in any of my cases. Incredible!")
			
			delete hScope.iszClassIconOld
		}
		
		// CASE: the bot's ClassIcon is unchanged, not on the wavebar, and inside memory.
		else if ( !(GetIndexOfIcon(iszClassIcon)) && iszClassIcon in arIconMemory )
		{
			printl("[[MEMORY]] Bot's icon was not changed ("+iszClassIcon+"), isn't on wavebar, but found in memory (tied to "+arIconMemory[iszClassIcon]+")")
			DecrementIconCount(arIconMemory[iszClassIcon])
		}
	}

	GetIconByIndex = function(iIndex)
	{
		local i = 0 //Check: do I start at 0 or at 1?
		local two = ""
		local i2 = 0
		printf("Trying to find icon at index %i...",iIndex)
		if (i >= 12) two = "2.",i2 = 12;
		
		local sName = GetPropStringArray(hTFOR, "m_iszMannVsMachineWaveClassNames"+two, i-i2)
		if ( sName.len() == 0 )
		{
			printf("index %i is empty!\n",iIndex)
			return null
		}
		printf("found icon %s at index %i!\n",sName,iIndex)
		return sName
	}

	GetIconByHandle = function(hPlayer)
	{
		if (!hPlayer.IsValid())
		{
			printl("SINS ERROR: Invalid player for GetIconByHandle!")
			return null;
		}
		return GetPropString(hPlayer, "m_PlayerClass.m_iszClassIcon")
	}
	
	//@string sTag	: tag of the bot.
	GetIconByTag = function(sTag)
	{
		local iBotCount = 1
		for (local i = 1; i <= MaxPlayers ; i++)
		{
			local player = PlayerInstanceFromIndex(i)
			if (player == null) continue
			if (GetPropInt(player, "m_lifeState") != 0) continue
			if (!player.IsBotOfType(TF_BOT_TYPE)) continue
			if (!player.HasBotTag(tag)) continue
			
			local sName = GetIconByHandle(player)
			printf("Found icon %s on bot #%i",sName,iBotCount)
			iBotCount = iBotCount + 1
		}
		if (iBotCount == 1)
			printf("Couldn't find any bots with tag %s.\n",sTag)
	}
	
	//Finds the index of the given icon on the wavebar. Intended for internal use, but global for accessibility.
	//@string sName	: name of the icon.
	//@return int	: integer index of icon. If not found, returns NULL.
	FindIndexOfIcon = function(sName)
	{
		local i = 0 //Check: do I start at 0 or at 1?
		local two = ""
		local i2 = 0
		printf("Trying to find icon '%s'...",sName)
		for(i; i < 24; i+=1) //Check: and thus, do I end at 24, or 23?
		{
			if (i >= 12) two = "2.",i2 = 12;
			
			local _sName = GetPropStringArray(hTFOR, "m_iszMannVsMachineWaveClassNames"+two, i-i2)
			if (_sName == sName)
			{
				printf("found '%s' at index %i!\n",sName,i)
				return i
			}
		}
		printf("icon name '%s' not found!\n",sName)
		return null
	}
	//Finds the enemy count of the given icon on the wavebar. Intended for internal use, but global for accessibility.
	//@string sName	: name of the icon.
	//@return int	: count of icon. If not found, returns 0 (zero).
	FindCountOfIcon = function(sName)
	{
		local iIndex = FindIndexOfIcon(sName)
		
		if (iIndex == null) return 0;
		
		local two = ""
		local i2 = 0
		if (iIndex >= 12) two = "2.",i2 = 12;
		local iIconCount = GetPropIntArray(hTFOR, "m_nMannVsMachineWaveClassCounts"+two, iIndex-i2);
		return iIconCount
	}

	//Wrapper for FindIndexOfIcon so both can be used.
	//Finds the index of the given icon on the wavebar. Intended for internal use, but global for accessibility.
	//@string sName	: name of the icon.
	//@return int	: integer index of icon. If not found, returns NULL.
	GetIndexOfIcon = function(sName)
	{
		return FindIndexOfIcon(sName)
	}
	
	//Wrapper for FindCountOfIcon so both can be used.
	//Finds the enemy count of the given icon on the wavebar. Intended for internal use, but global for accessibility.
	//@string sName	: name of the icon.
	//@return int	: count of icon. If not found, returns 0 (zero).
	GetCountOfIcon = function(sName)
	{
		return FindCountOfIcon(sName)
	}
	
	//Returns the flags of the icon with the specified name.
	//@string sName : name of the icon to get the flags of.
	//If the icon is not on the wavebar, returns NULL.
	GetIconFlags = function(sName)
	{
		local iIndex = FindIndexOfIcon(sName)
		if (iIndex == null) return null;
		
		local two = ""
		local i2 = 0
		if (iIndex >= 12) two = "2.",i2 = 12; //Was this dot ever fixed? Getting fixed? Hopefully.
		local iFlags = GetPropIntArray(hTFOR, "m_nMannVsMachineWaveClassFlags"+two, iIndex)
		return iFlags
	}
	
	//Loops through and prints all icon names.
	PrintAllIconNames = function()
	{
		local i = 0
		local two = ""
		local i2 = 0
		for(i; i < 24; i+=1)
		{
			if (i >= 12) two = "2.",i2 = 12;
			
			local sName = GetPropStringArray(hTFOR, "m_iszMannVsMachineWaveClassNames"+two, i-i2)
			printf("Icon %i: %s\n",i,sName)
		}
	}
	
	
	// ### All functions that change wavebar icons are dependent on this function!!! ###
	
	//Changes icon of specified index on the wavebar to icon with the specified name. Uses parts of lite's hideicons script.
	//@integer	iIndex	: index of the given icon. Can be determined by counting unique icons in WaveSpawn order.
	//@string	sName	: name of the new icon.
	ChangeIconByIndex = function(iIndex, sName)
	{
		if (iIndex == null)
		{
			if (DEBUG) ClientPrint(null,2,"SINS ChangeIconByIndex ERROR: Index is null!");
			return;
		}
		
		if (GetRoundState() == 10)
			arStartWave.append(function() ChangeIconByIndex(iIndex,sName))
		
		local two = ""
		local i2 = 0
		if (iIndex >= 12) two = "2.",i2 = 12; //Was this dot ever fixed? Getting fixed? Hopefully.
		
		local sNameOld = GetPropStringArray(hTFOR, "m_iszMannVsMachineWaveClassNames"+two, iIndex-i2)
		
		if ( sNameOld == sName )
		{
			printl("Redundant operation! '"+sNameOld+"' **is** '"+sName+"'!")
			return
		}
		
		// CASE: icon was not changed on the wavebar before; is neither a key nor a value in memory.
		if ( !(sNameOld in arIconMemory) && arIconMemory.values().find(sNameOld) == null )
		{
			printl("[[MEMORY]] Storing '"+sNameOld+"' in memory. When a bot with that classicon dies, decrement '"+sName+"' on the wavebar!")
			arIconMemory[sNameOld] <- sName
		}
		// CASE: NEW icon exists in memory as a KEY - aka "bot with icon A should die means decrement B, B is on the wavebar, set icon to A".
		// This is done when restoring icons, so delete it from memory as we no longer need to remember it.
		else if ( sName in arIconMemory )
		{
			printl("[[MEMORY]] Resetting & forgetting icon '"+sName+"'!")
			delete arIconMemory[sName]
		}
		// CASE: OLD icon exists in memory as a VALUE - aka "bot with icon A should die means decrement B, B is on the wavebar, set icon to C".
		else if ( arIconMemory.values().find(sNameOld) != null )
		{
			local sNameOldOld = arIconMemory.keys()[arIconMemory.values().find(sNameOld)]
			arIconMemory[sNameOldOld] <- sName
			printl(" [[MEMORY]] Updating memory. When a bot with icon '"+sNameOldOld+"' dies, decrement '"+sName+"' on the wavebar!")
		}
		
			//printl("Redundant operation: icons are already tied - a bot with icon '"+sNameOld+"' dying means '"+sName+"' gets decremented!")
		
		SetPropStringArray(hTFOR, "m_iszMannVsMachineWaveClassNames"+two, sName, iIndex-i2)
	}
	//Changes only the wavebar icon with the specified name to the icon with the specified new name.
	//@string	sNameOld	: name of the icon to change.
	//@string	sNameNew	: name of the new icon.
	ChangeIconByName = function(sNameOld, sName)
	{
		local iIndex = FindIndexOfIcon(sNameOld)
		if ( iIndex == null )
		{
			if (DEBUG) ClientPrint(null,2,"SINS ChangeIconByIndex ERROR: Index is null!");
			return;
		}
		if ( sNameOld == sName )
		{
			printl("Redundant operation! '"+sNameOld+"' **is** '"+sName+"'!")
			return
		}
		
		printf("'%s' found at %i! Changing to '%s'...\n",sNameOld,iIndex,sName)
		ChangeIconByIndex(iIndex,sName)
	}
	
	
	//Wrapper that changes the given player's class icon. More convenient than writing it all out.
	//Does NOT change the wavebar icon, but can change the icon on a boss health bar.
	//@handle	hPlayer	: player to change the classicon of.
	//@string	sName	: name of the icon to change to.
	//@bool		bStore	: whether to store the icon to remove it from the wavebar later, if it is no longer the same (default: true)
	ChangeClassIcon = function(hPlayer, sName, bStore = true)
	{
		local hScope = hPlayer.GetScriptScope()
		if ( !("iszClassIconOld" in hScope) && bStore)
			hScope.iszClassIconOld <- GetPropString(hPlayer, "m_PlayerClass.m_iszClassIcon")
		
		SetPropString(hPlayer, "m_PlayerClass.m_iszClassIcon", sName)
	}

	//Changes both the class icon and the wavebar icon. Assumes wavebar icon is the same as player's classicon!
	//@handle hPlayer	: the player (bot) to change the icon of.
	//@string sName		: name of the icon to change to.
	ChangeClassIconAndWavebar = function(hPlayer, sName)
	{
		if (!(hPlayer)) return;
		
		local sNameOld = GetIconByHandle(hPlayer)
		local iIndex = FindIndexOfIcon(sNameOld)
		
		if (iIndex == null) return;
		if ( sNameOld == sName )
		{
			printl("Redundant operation! '"+sNameOld+"' **is** '"+sName+"'!")
			return
		}
		
		printf("%s found at %d! Changing to %s...\n",sNameOld,iIndex,sName)
		ChangeClassIcon(hPlayer, sName, false)
		ChangeIconByIndex(iIndex, sName)
	}
	
	//Changes icons of all bots that match the provided tag and are currently alive.
	//@string	tag				: tag of the bots whose icon should be changed.
	//@string	iconName		: name of the icon to change to.
	//@bool		updateClassIcon	: whether to also change the classicon. Default: true.
	ChangeIconByTag = function(tag,iconName,updateWavebarIcon = true,updateClassIcon = true)
	{
		for (local i = 1; i <= MaxPlayers ; i++)
		{
			local player = PlayerInstanceFromIndex(i)
			if (player == null) continue
			if (GetPropInt(player, "m_lifeState") != 0) continue
			if (!player.IsBotOfType(TF_BOT_TYPE)) continue
			if (!player.HasBotTag(tag)) continue
			
			local oldIcon = GetIconByHandle(player)
			if (updateWavebarIcon && oldIcon != iconName)
			{
				local iconIndex = FindIndexOfIcon(oldIcon)
				
				if (iconIndex == null && DEBUG)
					ClientPrint(null,2,"SINS ChangeIconByTag ERROR: Index is null!");
				else 
					ChangeIconByIndex(iconIndex,iconName);
			}
			
			// Should the bot's icon (healthbar) be changed?
			// Don't store it if we're changing both!
			if (updateClassIcon)
				ChangeClassIcon(player,iconName,!(updateWavebarIcon && updateClassIcon) )
		}
	}
	
	//Changes "flags" of the given icon.
	//@string	sName	: name of the icon whose flags to change.
	//@int		iFlags	: flags to set on the icon. Valid values below.
	//POSITION FLAGS: 0 = not on wavebar;	1 = mainwave;	2 = Support;	4 = Mission Support, is put right of other Support. Also causes Engineer, Spy, and Sentry Buster icons to flash.
	//VISUAL FLAGS:   8 = red background, for giants and tanks;		16 = blue flashing outline, for crits
	ChangeIconFlags = function(sName,iFlags)
	{
		local iIndex = FindIndexOfIcon(sName)
		
		if (iIndex == null) return;
		
		local iFlagsOld = GetIconFlags(sName)
		printf("%s found at %d! Changing its flags from %d to %d...\n",sName,iIndex,iFlagsOld,iFlags)
		
		local two = ""
		local i2 = 0
		if (iIndex >= 12) two = "2.",i2 = 12; //Was this dot ever fixed? Getting fixed? Hopefully.
		
		if (GetRoundState() == 10)
			arStartWave.append(function() SetPropIntArray(hTFOR, "m_nMannVsMachineWaveClassFlags"+two, iFlags, iIndex-i2))
		
		SetPropIntArray(hTFOR, "m_nMannVsMachineWaveClassFlags"+two, iFlags, iIndex-i2)
	}
	
	//TODO: finish finding a neat way to do this
	ToggleIconFlags = function(sName,flagsString)
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
	
	//Increments the given icon's count by the given count.
	//@string	sName	: icon name to increment.
	//@int		iCount	: amount to increment by (default: 1).
	IncrementIconCount = function(sName,iCount = 1)
	{
		local iIndex = FindIndexOfIcon(sName)
		if (iIndex == null) return false;
		
		local two = ""
		local i2 = 0
		if (iIndex >= 12) two = "2.",i2 = 12;
		local iIconCount = GetPropIntArray(hTFOR, "m_nMannVsMachineWaveClassCounts"+two, iIndex-i2);
		SetPropIntArray(hTFOR, "m_nMannVsMachineWaveClassCounts"+two, iIconCount+iCount, iIndex-i2)
	}
	
	//Decrements the given icon's count by the given count.
	//@string	sName	: icon name to decrement.
	//@int		iCount	: amount to decrement by (default: 1).
	DecrementIconCount = function(sName,iCount = 1)
	{
		local iIndex = FindIndexOfIcon(sName)
		if (iIndex == null) return false;
		
		local two = ""
		local i2 = 0
		if (iIndex >= 12) two = "2.",i2 = 12;
		local iIconCount = GetPropIntArray(hTFOR, "m_nMannVsMachineWaveClassCounts"+two, iIndex-i2);
		SetPropIntArray(hTFOR, "m_nMannVsMachineWaveClassCounts"+two, iIconCount-iCount, iIndex-i2)
	}
	
	HideIcon = function(name)
	{
		local iIndex 					= FindIndexOfIcon(name)
		local iEnemyCount				= FindCountOfIcon(name)
		local iFlags 					= GetIconFlags(name)
		local iMaxEnemyCountAfterHide 	= iMaxEnemyCount - iIconEnemyCount
		
		HiddenIcons[name] <- { flags = iFlags, count = iEnemyCount }
		
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