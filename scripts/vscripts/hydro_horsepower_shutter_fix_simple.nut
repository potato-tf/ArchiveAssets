function execute()
{
/*
 *  Is the script being executed?
 */
printl("*** HHPWR -- Execute script: hydro_horsepower_shutter_fix_simple.nut");



/*
 *  Find relevant entities.
 *  Terminate script if relevant entities can not be found.
 */

local ent_tankpath_pre = Entities.FindByName(null, "tank_path_a_71")
if (!ent_tankpath_pre)
{
    printl("*** HHPWR -- Failed to find entity: tank_path_a_71.")
    return
}


local ent_tankpath_post = Entities.FindByName(null, "tank_path_a_72")
if (!ent_tankpath_post)
{
    printl("*** HHPWR -- Failed to find entity: tank_path_a_72.")
    return
}


local ent_shutter_trigger = Entities.FindByName(null, "shutter_trigger")
if (!ent_shutter_trigger)
{
    printl("*** HHPWR -- Failed to find entity: shutter_trigger.")
    return
}


local ent_trackdoor = Entities.FindByName(null, "door_any_trackdoor_1")
if (!ent_trackdoor)
{
    printl("*** HHPWR -- Failed to find entity: door_any_trackdoor_1.")
    return
}


local ent_trackdoor_prop = Entities.FindByName(null, "door_any_trackdoor_1_prop")
if (!ent_trackdoor_prop)
{
    printl("*** HHPWR -- Failed to find entity: door_any_trackdoor_1_prop.")
    return
}



/*
 *  Construct new shutter trigger.
 *  Terminate script if the required entities can not be created.
 */

local ent_filter0 = SpawnEntityFromTable("filter_activator_class", {
    targetname		=	"hhpwr_filter_shutter_player"
    origin			=	Vector(0, 0, 0)
    filterclass		=	"player"
    Negated			=	false
})
if (!ent_filter0)
{
    printl("*** HHPWR -- Failed to create filter_activator_class: hhpwr_filter_shutter_player.")
    return
}


local ent_filter1 = SpawnEntityFromTable("filter_activator_class", {
    targetname		=	"hhpwr_filter_shutter_tank"
    origin			=	Vector(0, 0, 0)
    filterclass		=	"tank_boss"
    Negated			=	false
})
if (!ent_filter1)
{
    printl("*** HHPWR -- Failed to create filter_activator_class: hhpwr_filter_shutter_tank.")
    return
}


local ent_filter2 = SpawnEntityFromTable("filter_multi", {
    targetname		=	"hhpwr_filter_shutter_multi_OR"
    origin			=	Vector(0, 0, 0)
    FilterType		=	1
    Filter01		=	"hhpwr_filter_shutter_player"
    Filter02		=	"hhpwr_filter_shutter_tank"
})
if (!ent_filter2)
{
    printl("*** HHPWR -- Failed to create filter_multi: hhpwr_filter_shutter_multi_OR.")
    return
}


local ent_trigger = SpawnEntityFromTable("trigger_multiple", {
    targetname		=	"hhpwr_trigger_shutter"
    origin			=	Vector(-1664, 404, 232)
    angles			=	QAngle(0, 0, 0)
    filtername		=	"hhpwr_filter_shutter_multi_OR"
    spawnflags		=	64
})
if (!ent_trigger)
{
    printl("*** HHPWR -- Failed to create trigger_multiple: hhpwr_trigger_shutter.")
    return
}

ent_trigger.SetSize(Vector(0, 0, 0), Vector(512, 408, 240))
ent_trigger.SetSolid(2)

ent_trigger.ValidateScriptScope()
local ent_trigger_script = ent_trigger.GetScriptScope()



/*
 *  Setup new shutter logic.
 */

ent_trigger_script.hhpwr_shutter_open <- function()
{
    printl("*** HHPWR -- Shutter trigger touch start: " + activator)
    EntFire(ent_trackdoor.GetName(), "Open", "")
    EntFire(ent_trackdoor_prop.GetName(), "SetAnimation", "open")
}
ent_trigger.ConnectOutput("OnStartTouchAll", "hhpwr_shutter_open")


ent_trigger_script.hhpwr_shutter_close <- function()
{
    printl("*** HHPWR -- Shutter trigger touch end: " + activator)
    EntFire(ent_trackdoor.GetName(), "Open", "")
    EntFire(ent_trackdoor_prop.GetName(), "SetAnimation", "close")
}
ent_trigger.ConnectOutput("OnEndTouchAll", "hhpwr_shutter_close")



/*
 *  Disconnect old shutter logic.
 */

EntityOutputs.RemoveOutput(ent_tankpath_pre, "OnPass", "shutter_trigger", "Disable", "")
EntityOutputs.RemoveOutput(ent_tankpath_pre, "OnPass", "door_any_trackdoor_1", "Open", "")
EntityOutputs.RemoveOutput(ent_tankpath_pre, "OnPass", "door_any_trackdoor_1_prop", "SetAnimation", "open")
EntityOutputs.RemoveOutput(ent_tankpath_post, "OnPass", "shutter_trigger", "Enable", "")
EntityOutputs.RemoveOutput(ent_shutter_trigger, "OnStartTouchAll", "door_any_trackdoor_1", "Open", "")
EntityOutputs.RemoveOutput(ent_shutter_trigger, "OnStartTouchAll", "door_any_trackdoor_1_prop", "SetAnimation", "open")
EntityOutputs.RemoveOutput(ent_shutter_trigger, "OnEndTouchAll", "door_any_trackdoor_1", "Close", "")
EntityOutputs.RemoveOutput(ent_shutter_trigger, "OnEndTouchAll", "door_any_trackdoor_1_prop", "SetAnimation", "close")
}

execute();