// mvm_hideout_b3.bsp
const EFL_NO_THINK_FUNCTION = 4194304

Events <- {
    //fix the fish crashing the server
    function OnGameEvent_recalculate_holidays(_) {
        for (local fish; fish = Entities.FindByClassname(fish, "fish");)
        {
            fish.SetAbsVelocity(Vector())
            fish.AddEFlags(EFL_NO_THINK_FUNCTION)
        }
    }
}