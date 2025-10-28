::POPEXT_VERSION <- "06.26.2025.1"

local ROOT = getroottable()

function Include( path ) {
	// try IncludeScript( format( "popextensions/%s", path ), ROOT ) catch( e ) error( e )
	IncludeScript( format( "popextensions/%s", path ), ROOT )
}

Include( "constants" ) // constants must include first
Include( "event_wrapper" ) // must include second

// these get defined here so we can use them
local objres = Entities.FindByClassname( null, "tf_objective_resource" )

//save popfile name in global scope when we first initialize
//if the popfile name changed, a new pop has loaded, clean everything up.
::__popname <- NetProps.GetPropString( objres, "m_iszMvMPopfileName" )

// ::commentaryNode <- SpawnEntityFromTable( "point_commentary_node", {targetname = "  IGNORE THIS ERROR \r"} )

// overwrite AddThinkToEnt
// certain entity types use think tables, meaning any external scripts will conflict with this and break everything
// don't want to confuse new scripters by allowing adding multiple thinks with AddThinkToEnt in our library and our library only
// spew a big fat warning below so they know what's going on

local banned_think_classnames = {
	player 			= "PlayerThinkTable"
	tank_boss 		= "TankThinkTable"
	tf_projectile_ 	= "ProjectileThinkTable"
	tf_weapon_ 		= "ItemThinkTable"
	tf_wearable 	= "ItemThinkTable"
}

if ( !( "_AddThinkToEnt" in ROOT ) ) {

	//rename so we can still use it elsewhere
	//this also allows people to override the think restriction by using _AddThinkToEnt( ent, "FuncNameHere" ) instead
	//I'm not including this in the warning, only the people that know what they're doing already and can find it here should know about it.
	::_AddThinkToEnt <- AddThinkToEnt

	::AddThinkToEnt <- function( ent, func ) {

		//mission unloaded, revert back to vanilla AddThinkToEnt
		if ( !( "__popname" in ROOT ) ) {

			_AddThinkToEnt( ent, func )
			AddThinkToEnt <- _AddThinkToEnt
			return
		}

		foreach ( k, v in banned_think_classnames )
			if ( startswith( ent.GetClassname(), k ) ) {

				error( format( "ERROR: **POPEXTENSIONS WARNING: AddThinkToEnt on '%s' entity overwritten!**\n", k ) )
				// ClientPrint( null, HUD_PRINTTALK, format( "\x08FFB4B4FF**WARNING: AddThinkToEnt on '%s' entities is forbidden!**\n\n Use PopExtUtil.AddThinkToEnt instead.\n\nExample: AddThinkToEnt( ent, \"%s\" ) -> PopExtUtil.AddThinkToEnt( ent, \"%s\" )", k, func, func ) )

				//we use printl instead of printf because it's redirected to player console on potato servers
				printl( format( "\n\n**POPEXTENSIONS WARNING: AddThinkToEnt on '%s' overwritten!**\n\nAddThinkToEnt( ent, \"%s\" ) -> PopExtUtil.AddThinkToEnt( ent, \"%s\" )\n\n", ent.tostring(), func, func ) )
				PopExtUtil.AddThinkToEnt( ent, func )
				return
			}

		_AddThinkToEnt( ent, func )
	}
}

::PopExtMain <- {

	DebugText = false

	DebugFiles = {
		"missionattributes" : null,
		// "util" 				: null,
		"tags" 				: null,
	}

	// manual cleanup flag, set to true for missions that are created for a specific map.
	// automated unloading is meant for multiple missions on one map, purpose-built map/mission combos ( like mvm_redridge ) don't need this.
	// this should also be used if you change the popfile name mid-mission.
	ManualCleanup = false


	// ignore these variables when cleaning up
	// "Preserved" is a special table that will persist through the cleanup process
	// any player scoped variables you want to use across multiple waves should be added here
	IgnoreTable = {
		"self"         		   : null
		"__vname"      		   : null
		"__vrefs"      		   : null
		"Preserved"    		   : null
		"ExtraLoadout" 		   : null
		"templates_to_kill"    : null
		"wearables_to_kill"    : null
	}

	function PlayerCleanup( player ) {

		NetProps.SetPropInt( player, "m_nRenderMode", kRenderNormal )
		NetProps.SetPropInt( player, "m_clrRender", 0xFFFFFF )

		local scope = player.GetScriptScope()

		if ( scope.len() > IgnoreTable.len() )
			foreach ( k, v in scope )
				if ( !( k in IgnoreTable ) )
					delete scope[k]
	}

	Error = {

		RaisedParseError = false

		function DebugLog( LogMsg ) {
			if ( !PopExtMain.DebugText || !( getstackinfos(2).src.slice(0, -4) in PopExtMain.DebugFiles ) ) return
			ClientPrint( null, HUD_PRINTCONSOLE, format( "%s %s.", "POPEXT DEBUG", LogMsg ) )
		}
		// warnings
		GenericWarning = @( msg ) ClientPrint( null, HUD_PRINTCONSOLE, format( "%s %s.", "POPEXT WARNING", msg ) )
		DeprecationWarning = @( old, new ) ClientPrint( null, HUD_PRINTCONSOLE, format( "%s %s is DEPRECATED. Use %s instead.", "POPEXT WARNING", old, new ) )

		// errors
		RaiseIndexError = @( key, max = [0, 1] ) ParseError( format( "Index out of range for '%s', value range: %d - %d", key, max[0], max[1] ) )
		RaiseTypeError = @( key, type ) ParseError( format( "Bad type for '%s' ( should be %s )", key, type ) )
		RaiseValueError = @( key, value, extra = "" ) ParseError( format( "Bad value '%s' passed to %s. %s", value.tostring(), key, extra ) )

		// generic template parsing error
		function ParseError( ErrorMsg ) {

			if ( !RaisedParseError ) {

				RaisedParseError = true
				ClientPrint( null, HUD_PRINTTALK, "\x08FFB4B4FFIt is possible that a parsing error has occured. Check console for details." )
			}
			ClientPrint( null, HUD_PRINTCONSOLE, format( "%s %s.\n", "POPEXT ERROR", ErrorMsg ) )

			printf( "%s %s.\n", "POPEXT ERROR", ErrorMsg )
		}

		// generic exception
		RaiseException = @( ExceptionMsg ) Assert( false, format( "%s: %s.", "POPEXT ERROR", ExceptionMsg ) )
	}

	GlobalThinks = {

		// add think table to all projectiles
		function AddProjectileThink() {

			for ( local projectile; projectile = Entities.FindByClassname( projectile, "tf_projectile*" ); ) {

				if ( projectile.GetEFlags() & 1048576 ) continue

				projectile.ValidateScriptScope()
				local scope = projectile.GetScriptScope()
				local owner = projectile.GetOwner()

				if ( owner && owner.IsValid() ) {

					local owner_scope = owner.GetScriptScope()
					if ( !owner_scope ) {

						owner.ValidateScriptScope()
						owner_scope = owner.GetScriptScope()
					}

					// this should not be a thing.  Preserved gets added in player_spawn but we still get does not exist errors
					if ( !( "Preserved" in owner_scope ) )
						owner_scope.Preserved <- {}

					if ( !( "ActiveProjectiles" in owner_scope.Preserved ) )
						owner_scope.Preserved.ActiveProjectiles <- {}

					owner_scope.Preserved.ActiveProjectiles[projectile.entindex()] <- [projectile, Time()]

					PopExtUtil.SetDestroyCallback( projectile, function() {
						if ( "ActiveProjectiles" in owner_scope.Preserved && self.entindex() in owner_scope.Preserved.ActiveProjectiles )
							delete owner_scope.Preserved.ActiveProjectiles[self.entindex()]
					})
				}

				if ( !( "ProjectileThinkTable" in scope ) )
					scope.ProjectileThinkTable <- {}

				scope.ProjectileThink <- function () {

					foreach ( name, func in scope.ProjectileThinkTable )
						func.call( scope )

					return -1
				}

				_AddThinkToEnt( projectile, "ProjectileThink" )

				projectile.AddEFlags( 1048576 )
			}
		}
	}
}

// overwrite EntFireByHandle to get invalid/null entities
if ( PopExtMain.DebugText && !( "_EntFireByHandle" in ROOT ) ) {

	::_EntFireByHandle <- EntFireByHandle

	::EntFireByHandle <- function( target, action, param, delay, activator, caller ) {

		if ( !target || !target.IsValid() )
			PopExtMain.Error.RaiseException( "Invalid target passed to EntFireByHandle" )

		_EntFireByHandle( target, action, param, delay, activator, caller )
	}
}

local global_think_entity = Entities.FindByName( null, "__popext_global_think" )
if ( global_think_entity == null ) global_think_entity = SpawnEntityFromTable( "info_teleport_destination", { targetname = "__popext_global_think" } )

global_think_entity.ValidateScriptScope()

global_think_entity.GetScriptScope().GlobalThink <- function() {
	foreach( func in PopExtMain.GlobalThinks ) func()
	return -1
}

AddThinkToEnt( global_think_entity, "GlobalThink" )

PopExtEvents.AddRemoveEventHook( "player_spawn", "MainPlayerSpawn", function( params ) {

	local player = GetPlayerFromUserID( params.userid )
	local scope = player.GetScriptScope()

	if ( !scope ) {

		player.ValidateScriptScope()
		scope = player.GetScriptScope()
	}

	if ( !( "Preserved" in scope ) )
		scope.Preserved <- {}

}, 0)

PopExtEvents.AddRemoveEventHook( "post_inventory_application", "MainPostInventoryApplication", function( params ) {

	if ( GetRoundState() == 3 ) return

	local player = GetPlayerFromUserID( params.userid )

	if ( player.IsEFlagSet( 1073741824 ) ) return

	PopExtMain.PlayerCleanup( player )

	local scope = player.GetScriptScope()

	if ( !scope ) {

		player.ValidateScriptScope()
		scope = player.GetScriptScope()
	}

	if ( !( "Preserved" in scope ) )
		scope.Preserved <- {}

	local scope = player.GetScriptScope()

	if ( !( "PlayerThinkTable" in scope ) ) 
		scope.PlayerThinkTable <- {}

	if ( player.IsBotOfType( 1337 ) ) {

		scope.aibot <- PopExtBotBehavior( player )

		scope.PlayerThinkTable.BotThink <- function() {

				aibot.OnUpdate()
		}
	}

	scope.PlayerThinks <- function() {

		foreach ( name, func in scope.PlayerThinkTable )
			func.call( scope )
		return -1
	}

	_AddThinkToEnt( player, "PlayerThinks" )

	if ( player.GetPlayerClass() > 7 && !( "BuiltObjectTable" in scope ) ) {

		scope.BuiltObjectTable <- {}
		scope.buildings <- []
	}

}, 0)

PopExtEvents.AddRemoveEventHook( "player_changeclass", "MainChangeClassCleanup", function( params ) {

	local player = GetPlayerFromUserID( params.userid )

	for ( local model; model = FindByName( model, "__popext_bonemerge_model" ); )
		if ( model.GetMoveParent() == player )
			EntFireByHandle( model, "Kill", "", -1, null, null )
}, 0)

//clean up bot scope on death
PopExtEvents.AddRemoveEventHook( "player_death", "MainDeathCleanup", function( params ) {

	local player = GetPlayerFromUserID( params.userid )

	if ( !player.IsBotOfType( 1337 ) ) return

	PopExtMain.PlayerCleanup( player )
}, 0)

// final cleanup step, must run last
PopExtEvents.AddRemoveEventHook( "teamplay_round_start", "MainRoundStartCleanup", function( _ ) {

	// clean up lingering wearables
	for ( local wearable; wearable = FindByClassname( wearable, "tf_wearable*" ); )
		if ( wearable.GetOwner() == null || wearable.GetOwner().IsBotOfType( 1337 ) )
			EntFireByHandle( wearable, "Kill", "", -1, null, null )

	//same pop or manual cleanup flag set, don't run
	if ( __popname == GetPropString( objres, "m_iszMvMPopfileName" ) || PopExtMain.ManualCleanup ) 
		return

	//clean up all players
	local maxclients = MaxClients().tointeger()

	for ( local i = 1; i <= maxclients; i++ ) {

		local player = PlayerInstanceFromIndex( i )

		if ( player == null ) continue

		PopExtMain.PlayerCleanup( player )
	}

	//clean up missionattributes
	MissionAttributes.Cleanup()

	//nuke it all
	local cleanup = [

		"MissionAttributes"
		"CustomAttributes"
		"SpawnTemplate"
		"SpawnTemplateWaveSchedule"
		"SpawnTemplates"
		"VCD_SOUNDSCRIPT_MAP"
		"PointTemplates"
		"CustomWeapons"
		"__popname"
		"ExtraItems"
		"Homing"
		"Include"
		"MAtr"
		"MAtrs"
		"MissionAttr"
		"MissionAttrs"
		"MissionAttrThink"

		"pop_ext_think_func_set"
		"POPEXT_VERSION"

		"ScriptLoadTable"
		"ScriptUnloadTable"
		"EntAdditions"
		"Explanation"
		"Info"

		"PopExt"
		"PopExtTags"
		"PopExtHooks"
		"PopExtPathPoint"
		"PopExtBotBehavior"
		"PopExtWeapons"
		"PopExtAttributes"
		"PopExtItems"
		"PopExtGlobalThink"
		"PopExtTutorial"

		// clear these last
		"PopExtMain"
		"PopExtEvents"
		"PopExtUtil"
	]

	foreach( c in cleanup ) if ( c in ROOT ) delete ROOT[c]

	EntFire( "__popext*", "Kill" )
	EntFire( "extratankpath*", "Kill" )
})

//HACK: forces post_inventory_application to fire on pop load
local maxclients = MaxClients().tointeger()
for ( local i = 1; i <= maxclients; i++ )
	if ( PlayerInstanceFromIndex( i ) != null )
		EntFireByHandle( PlayerInstanceFromIndex( i ), "RunScriptCode", "self.Regenerate( true )", 0.015, null, null )

Include( "itemdef_constants" ) //constants must include first
Include( "item_map" ) //must include second
Include( "attribute_map" ) //must include third ( after item_map )
Include( "util" ) //must include fourth

Include( "hooks" ) //must include before popextensions
Include( "popextensions" )

Include( "robotvoicelines" ) //must include before missionattributes
Include( "customattributes" ) //must include before missionattributes
Include( "missionattributes" )
Include( "customweapons" )

Include( "botbehavior" ) //must include before tags
Include( "tags" )

Include( "spawntemplate" )

// Include( "tutorialtools" )
// Include( "populator" )
