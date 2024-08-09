function OnGameEvent_player_say(params) { 
    if (params.text.tolower() == "enablemirror" || params.text.tolower() == "/enablemirror" || params.text.tolower() == "!enablemirror" || params.text.tolower() == "mirror" || params.text.tolower() == "/mirror" || params.text.tolower() == "!mirror" || params.text.tolower() == "em" || params.text.tolower() == "/em" || params.text.tolower() == "!em") 
    {
        local steamid = NetProps.GetPropString(GetPlayerFromUserID(params.userid), "m_szNetworkIDString")
        local filename = "unlockedmirrormode"
        local unlocked = false
        local i = 1

        // search every file for steamid
        do {
            if (FileToString(filename+(i)).find(steamid) != null) unlocked = true
            i++
        } while (FileToString(filename+(i)) != null)

        if (unlocked == false)
        {
            ClientPrint((GetPlayerFromUserID(params.userid)), 3, "\x0700FF00To unlock Mirror Mode, complete all waves by selecting Random.")
        }
        else
        {
            EntFire("popscript", "$EnableMirrorMode")
        }
    }
    if (params.text.tolower() == "enablekaizo" || params.text.tolower() == "/enablekaizo" || params.text.tolower() == "!enablekaizo" || params.text.tolower() == "kaizo" || params.text.tolower() == "/kaizo" || params.text.tolower() == "!kaizo" || params.text.tolower() == "ek" || params.text.tolower() == "/ek" || params.text.tolower() == "!ek") 
    {
        local steamid = NetProps.GetPropString(GetPlayerFromUserID(params.userid), "m_szNetworkIDString")
        local filename = "unlockedmirrormode"
        local unlocked = false
        local i = 1

        // search every file for steamid
        do {
            if (FileToString(filename+(i)).find(steamid) != null) unlocked = true
            i++
        } while (FileToString(filename+(i)) != null)

        if (unlocked == false)
        {
            ClientPrint((GetPlayerFromUserID(params.userid)), 3, "\x07FFFF00To unlock Kaizo Mode, complete all waves by selecting Random.")
        }
        else
        {
            EntFire("popscript", "$EnableKaizoMode")
        }
    }
}

__CollectGameEventCallbacks(this)
