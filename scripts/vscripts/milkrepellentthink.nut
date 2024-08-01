//written by watermelon
local bots = []
local milkedBots = {}

function think() {
	foreach(index, bot in bots) {
		if(bot.InCond(27)) { //TF_COND_MAD_MILK
			milkedBots[bot] <- Time() + 2
			bots.remove(index)
		}
	}
	
	foreach(bot, time in milkedBots) {
		if(Time() >= time) {
			bot.RemoveCondEx(27, true)
			bots.append(bot)
			delete milkedBots[bot]
		}			
	}
}

function checkBot() {
	if(activator.HasBotTag("tag_cordelius")) {
		bots.append(activator)
	}
}