::__tagarray <-  [
	"popext_forceromevision"
	"popext_usehumananims"
    "popext_spawntemplate"
    "popext_spawntemplate|Dispensomat_boss"
    "popext_spawntemplate|Grimmemorial_Boss"
]

// custom tags, code taken from popextensions+'s tags.nut

    PopExt.AddRobotTag("bot_heavycommon", {
        OnSpawn = function(bot, tag) {
            local class_string = PopExtUtil.Classes[bot.GetPlayerClass()]
           	EntFireByHandle(bot, "SetCustomModelWithClassAnimations", format("models/player/%s.mdl", class_string), SINGLE_TICK, null, null)
		    EntFireByHandle(bot, "RunScriptCode", format("PopExtUtil.PlayerRobotModel(self, `models/bots/heavy/bot_heavy.mdl`)", class_string, class_string), SINGLE_TICK, null, null)
        },
        OnDeath = function(bot, params) {
            EntFireByHandle(bot, "SetCustomModelWithClassAnimations", "models/bots/heavy/bot_heavy.mdl", -1, null, null)
        }
    })

    PopExt.AddRobotTag("bot_heavygiant", {
        OnSpawn = function(bot, tag) {
            local class_string = PopExtUtil.Classes[bot.GetPlayerClass()]
           	EntFireByHandle(bot, "SetCustomModelWithClassAnimations", format("models/player/%s.mdl", class_string), SINGLE_TICK, null, null)
		    EntFireByHandle(bot, "RunScriptCode", format("PopExtUtil.PlayerRobotModel(self, `models/bots/heavy_boss/bot_heavy_boss.mdl`)", class_string, class_string), SINGLE_TICK, null, null)
        },
        OnDeath = function(bot, params) {
            EntFireByHandle(bot, "SetCustomModelWithClassAnimations", "models/bots/heavy_boss/bot_heavy_boss.mdl", -1, null, null)
        }
    })