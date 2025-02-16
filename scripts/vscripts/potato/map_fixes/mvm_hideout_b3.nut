// mvm_hideout_b3.bsp
::__potato.MapFixes.RunOnce <- function() {

    for (local fishpool; fishpool = Entities.FindByClassname(fishpool, "func_fish_pool");)
    EntFireByHandle(fishpool, "Kill", "", -1, null, null)

    for (local fish; fish = Entities.FindByClassname(fish, "fish");)
        EntFireByHandle(fish, "Kill", "", -1, null, null)

}
