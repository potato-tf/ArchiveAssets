// mvm_hideout_b3.bsp
const EFL_NO_THINK_FUNCTION = 4194304

Events <- {
    //fix the fish crashing the server
    function OnGameEvent_recalculate_holidays(_) {
        for (local fishpool; fishpool = Entities.FindByClassname(fishpool, "func_fish_pool");)
            EntFireByHandle(fishpool, "Kill", "", -1, null, null)

        for (local fish; fish = Entities.FindByClassname(fish, "fish");)
            EntFireByHandle(fish, "Kill", "", -1, null, null)
    }
}