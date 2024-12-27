if ("powerkiller" in getroottable() && powerkiller && powerkiller.IsValid()) //"powerkiller" reference already exists, kill it and make a new one
  powerkiller.Kill()

::powerkiller <- Entities.CreateByClassname("move_rope") //create a new ent and give it a "powerkiller" reference
powerkiller.DispatchSpawn() //spawn it

powerkiller.ValidateScriptScope() //set up script scope

powerkiller.GetScriptScope().KillPowerups <- function() { //add powerup killing function to script scope

    for (local rune; rune = Entities.FindByClassname(rune, "item_powerup_rune");)
        EntFireByHandle(rune, "Kill", "", -1, null, null)

  return -1 //run every game tick
}

//make it a think function (run in a loop every X seconds, X being the return value (-1 for every game tick))
AddThinkToEnt(powerkiller, "KillPowerups")