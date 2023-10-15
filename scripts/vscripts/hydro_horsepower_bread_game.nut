/*
 *  Initialize scope
 */
::HHPWR_BreadGame <- {}



/*
 *  Module data
 */
::HHPWR_BreadGame.bread_item_table <- {}
::HHPWR_BreadGame.bread_item_creation_count <- 0



/*
 *  Constants
 */
::HHPWR_BreadGame.bread_model_array <- [
    "models/weapons/c_models/c_bread/c_bread_baguette.mdl",
    "models/weapons/c_models/c_bread/c_bread_burnt.mdl",
    "models/weapons/c_models/c_bread/c_bread_cinnamon.mdl",
    "models/weapons/c_models/c_bread/c_bread_cornbread.mdl",
    "models/weapons/c_models/c_bread/c_bread_crumpet.mdl",
    "models/weapons/c_models/c_bread/c_bread_plainloaf.mdl",
    "models/weapons/c_models/c_bread/c_bread_pretzel.mdl",
    "models/weapons/c_models/c_bread/c_bread_ration.mdl",
    "models/weapons/c_models/c_bread/c_bread_russianblack.mdl"
]



/*
 *  Create a new bread item and add it to the item table.
 */
function HHPWR_BreadGame::create_bread_item(origin)
{
    ::HHPWR_BreadGame.bread_item_creation_count++


    local bread_item_data = {
        index       = ::HHPWR_BreadGame.bread_item_creation_count
        entities    = {
            root            =   null
            func_rotating   =   null
            prop            =   null
            trigger         =   null
        }
    }


    //  root
    bread_item_data.entities.root = SpawnEntityFromTable("info_target", {
        targetname	=	"hhpwr_breadgame_root_" + ::HHPWR_BreadGame.bread_item_creation_count
        origin		=	origin
        angles 		=	QAngle(0, 0, 0)
    })

    //  func_rotating
    bread_item_data.entities.func_rotating = SpawnEntityFromTable("func_rotating", {
        targetname	=	"hhpwr_breadgame_func_rotating_" + ::HHPWR_BreadGame.bread_item_creation_count
        origin		=	origin
        angles 		=	QAngle(0, 0, 0)
        maxspeed	=	30
        spawnflags	= 	1
    })
    EntFire(bread_item_data.entities.func_rotating.GetName(), "SetParent", bread_item_data.entities.root.GetName())
    bread_item_data.entities.func_rotating.SetSize(Vector(-16, -16, -16), Vector(16, 16, 16))

    //  trigger
    bread_item_data.entities.trigger = SpawnEntityFromTable("trigger_multiple", {
        targetname	=	"hhpwr_breadgame_trigger_" + ::HHPWR_BreadGame.bread_item_creation_count
        origin		=	origin
        angles 		=	QAngle(0, 0, 0)
        spawnflags	= 	1
    })
    EntFire("hhpwr_breadgame_trigger_" + ::HHPWR_BreadGame.bread_item_creation_count, "SetParent", "hhpwr_breadgame_root_" + ::HHPWR_BreadGame.bread_item_creation_count)
    bread_item_data.entities.trigger.SetSize(Vector(-16, -16, -16), Vector(16, 16, 16))
    bread_item_data.entities.trigger.SetSolid(2)

    // prop
    bread_item_data.entities.prop = SpawnEntityFromTable("prop_dynamic", {
        targetname	=	"hhpwr_breadgame_prop_" + ::HHPWR_BreadGame.bread_item_creation_count
        origin		=	origin
        angles 		=	QAngle(0, 0, 0)
    })
    EntFire("hhpwr_breadgame_prop_" + ::HHPWR_BreadGame.bread_item_creation_count, "SetParent", "hhpwr_breadgame_func_rotating_" + ::HHPWR_BreadGame.bread_item_creation_count)
    local random_bread_model = ::HHPWR_BreadGame.bread_model_array[RandomInt(0, ::HHPWR_BreadGame.bread_model_array.len() -1)]
    bread_item_data.entities.prop.SetModel(random_bread_model)


    //  Bread logic
    bread_item_data.entities.trigger.ValidateScriptScope()
    local trigger_script = bread_item_data.entities.trigger.GetScriptScope()

    trigger_script.hhpw_breadgame_on_trigger <- function()
    {
        printl("*** HHPWR_BreadGame -- Trigger activated by " + activator + ".")
        ::HHPWR_BreadGame.collect_bread_item(bread_item_data, activator)
    }

    bread_item_data.entities.trigger.ConnectOutput("OnStartTouch", "hhpw_breadgame_on_trigger")


    //  Add to data table
    ::HHPWR_BreadGame.bread_item_table[::HHPWR_BreadGame.bread_item_creation_count] <- bread_item_data
    return bread_item_data
}



/*
 *  Destroy a bread item and all of its associated entities. Remove it from the item table.
 */
function HHPWR_BreadGame::destroy_bread_item(bread_item)
{
    foreach(k, ent in bread_item.entities)
    {
        ent.Kill()
    }
    ::HHPWR_BreadGame.bread_item_table.remove(bread_item.index)
}



/*
 *  The specified collector picks up the specified bread item
 */
function HHPWR_BreadGame::collect_bread_item(bread_item, collector)
{
    //  Validate collector
    if (collector == null)
        return

}