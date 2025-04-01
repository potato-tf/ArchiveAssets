///////////////////////////////////////////////////////////SETUP
/////////////////////////////////////////////////////////////////

//yes this popfile is a gigantic mess
//yes navigating the pop is a complete nightmare 
//yes this is neccesary dont ask why
// all by stardustspy with some help
PrecacheModel("models/props_mvm/robot_spawnpoint_warning.mdl")
PrecacheModel("models/empty.mdl")
PrecacheModel("models/bots/engineer/bot_engineer.mdl")
PrecacheModel("models/bots/merasmus/merasmus.mdl")
PrecacheModel("models/bots/spy/bot_spy.mdl")
PrecacheSound("weapons/pipe_bomb1.wav")
PrecacheSound("weapons/jar_explode.wav")
PrecacheSound("weapons/gas_can_explode.wav")
PrecacheSound("ui/halloween_boss_summoned_monoculus.wav")
PrecacheSound("misc/halloween/spell_lightning_ball_impact.wav")
PrecacheSound("vo/halloween_merasmus/sf12_magic_backfire06.mp3")
PrecacheSound("vo/halloween_merasmus/sf12_defeated01.mp3")
PrecacheSound("misc/halloween/merasmus_appear.wav")
PrecacheSound("vo/halloween_merasmus/sf12_found01.mp3")
PrecacheSound("vo/halloween_boss/knight_alert.mp3")
PrecacheSound("ui/halloween_boss_summoned_fx.wav")
PrecacheSound("vo/halloween_merasmus/sf12_appears09.mp3")
PopExtUtil.PrecacheParticle("utaunt_arcane_purple_parent")
PrecacheSound("vo/mvm/norm/spy_mvm_paincrticialdeath01.mp3")
PrecacheSound("vo/mvm/norm/spy_mvm_paincrticialdeath02.mp3")
PrecacheSound("vo/mvm/norm/spy_mvm_paincrticialdeath03.mp3")

::SpawnHHH <- function()
{
    ::HHHThink <- function() 
    {
        local origin = self.GetOrigin()

        if (self.InCond(51)) return

        function ScareEffect()
        {
            local sound_range = (40 + (20 * log10(13650 / 36.0))).tointeger();

            for (local player; player = FindByClassnameWithin(player, "player", self.GetOrigin(), 500);)
            {
                for (local wearable = player.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
                {
                    //if hale mask or hhh head, grants immunity
                    if (NetProps.GetPropInt(wearable, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 277 || NetProps.GetPropInt(wearable, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 278)
                    player.AddCondEx(65, 2, null)
                    continue
                }

                if (player == null) continue

                if (player.GetTeam() != self.GetTeam())
                {
                    player.SetRageMeter(0)
                    player.SetScoutHypeMeter(0)
                    player.RemoveCondEx(26, true)
                    player.RemoveCondEx(16, true)
                    player.RemoveCondEx(29, true)
                    player.RemoveCondEx(44, true)
                    player.RemoveCondEx(46, true)
                }

                if (player.InCond(65)) continue

                if (player.GetTeam() != self.GetTeam())
                {
                    local enemy_origin = player.GetOrigin()
                    PopExtUtil.StunPlayer(player, 5, 2, 0, 0.5)
                    DispatchParticleEffect("yikes_text", enemy_origin, Vector(0, 0, 0))
                    player.SetRageMeter(0)
                }
            }
            for (local shield; shield = FindByClassnameWithin(shield, "entity_medigun_shield", self.GetOrigin(), 500);)
            {
                if (shield.GetTeam() != self.GetTeam())
                {
                    shield.Kill()
                }
            }
            EmitSoundEx
            ({
                sound_name = "vo/halloween_boss/knight_alert.mp3",
                origin = self.GetOrigin(),
                sound_level = sound_range 
            });
            EmitSoundEx
            ({
                sound_name = "vo/halloween_boss/knight_alert.mp3",
                origin = self.GetOrigin(),
                sound_level = sound_range 
            });
            DispatchParticleEffect("powerup_supernova_explode_blue", self.GetOrigin(), Vector(0, 0, 0))
            EntFireByHandle(particle, "Stop", "", -1, null, null)
        }

        if (particle == null)
        {
            particle = SpawnEntityFromTable("info_particle_system", 
            {
                effect_name = "utaunt_arcane_purple_parent", 
                targetname = "hhh_particle"
                origin = origin
                start_active = 0
                angles = Vector(0, 0, 0)
            })
            EntFireByHandle(particle, "SetParent", "!activator", 0, self, null)
        }

        if (!self.IsTaunting())
        {
            taunt_time++
        }

        if (taunt_time == 1000)
        {
            particle.AcceptInput("Start", "", self, self)
        }
        if (taunt_time == 1200)
        {
            self.Taunt(0, 1)
            taunt_time = 0
        }

        if (self.IsTaunting())
        {
            scare_time++
        }
        else 
        {
            scare_time = 0
        }

        if (scare_time == 155)
        {
            ScareEffect()
        }
    }

    self.ValidateScriptScope()
    local classname = PopExtUtil.Classes[self.GetPlayerClass()]
    local tagscope = self.GetScriptScope()

    self.SetCustomModelWithClassAnimations(format("models/player/%s.mdl", classname))
    PopExtUtil.CreatePlayerWearable(self, format("models/player/items/%s/%s_zombie.mdl", classname, classname))
    SetPropBool(self, "m_bForcedSkin", true)
    SetPropInt(self, "m_nForcedSkin", self.GetSkin() + 4)

    tagscope.particle <- null
    tagscope.taunt_time <- 999
    tagscope.scare_time <- 0
    
    PopExtUtil.AddThinkToEnt(self, "HHHThink")

}


///////////////////////////////////////////////////////////SETUP HOOKS
/////////////////////////////////////////////////////////////////

/////////////MISC

function UseHumanAnims(bot, args)
{
    local class_string = PopExtUtil.Classes[bot.GetPlayerClass()]
    EntFireByHandle(bot, "SetCustomModelWithClassAnimations", format("models/player/%s.mdl", class_string), 0.1, null, null)
    EntFireByHandle(bot, "RunScriptCode", format("PopExtUtil.PlayerRobotModel(self, `models/bots/%s/bot_%s.mdl`)", class_string, class_string), 5, null, null)
}

function WarningAllPlayers() 
{
    SendGlobalGameEvent("show_annotation", {
        text = "Watch the tombs! Something might arise from them..."
        lifetime = 5
        worldPosX = 1686
        worldPosY = 2351
        worldPosZ = 896
        id = 4
        play_sound = "misc/null.wav"
        show_distance = false
        show_effect = false
        follow_entindex = 0
    })
}

function WarningBombNoReset() 
{
    local bomb = FindByName(null, "intel_ironman")
    local bomb_origin = bomb.GetOrigin()

    SendGlobalGameEvent("show_annotation", 
    {
        text = "The bomb has stopped resetting for now..."
        lifetime = 5
        worldPosX = bomb_origin.x
        worldPosY = bomb_origin.y
        worldPosZ = bomb_origin.z
        id = 4
        play_sound = "misc/null.wav"
        show_distance = false
        show_effect = false
        follow_entindex = 0
    })
}

::CreepsideConjuringNamespace <- 
{
    Cleanup = function()
    {
        // cleanup any persistent changes here
        
        // keep this at the end
        delete ::CreepsideConjuringNamespace
        delete ::SpawnHHH  
        delete ::UseHumanAnims   
        delete ::WarningAllPlayers    
    }
    
    // mandatory events
    OnGameEvent_recalculate_holidays = function(_) { if (GetRoundState() == 3) Cleanup() }
    OnGameEvent_mvm_wave_complete = function(_) { Cleanup() }
    
    // add stored variables or your own events here
    //
    // e.g.
    // myvar = 123
    //
    // OnGameEvent_player_death = function(params)
    // { ... }

    MiscSetup = function() 
    {
        PopExt.AddRobotTag("bot_revolver_spy", 
        {
            OnSpawn = function(bot, tag) {
                local gun = PopExtUtil.GiveWeapon(bot, "tf_weapon_revolver", 210)
                bot.SetCustomModelWithClassAnimations("models/bots/spy/bot_spy.mdl")
            }
            OnDeath = function(bot, tag) 
            {
                local sound_range = (40 + (20 * log10(1500 / 36.0))).tointeger();
                local vo_death = RandomInt(1, 3)

                if (vo_death == 1)
                {
                    EmitSoundEx({
                        sound_name = "vo/mvm/norm/spy_mvm_paincrticialdeath01.mp3",
                        origin = bot.GetOrigin(),
                        sound_level = sound_range 
                    });
                }
                else if (vo_death == 2)
                {
                    EmitSoundEx({
                        sound_name = "vo/mvm/norm/spy_mvm_paincrticialdeath02.mp3",
                        origin = bot.GetOrigin(),
                        sound_level = sound_range 
                    });
                }
                else if (vo_death == 3)
                {
                    EmitSoundEx({
                        sound_name = "vo/mvm/norm/spy_mvm_paincrticialdeath03.mp3",
                        origin = bot.GetOrigin(),
                        sound_level = sound_range 
                    });
                }
            }
        })

        PopExt.AddRobotTag("bot_zombie", 
        {
            OnSpawn = function(bot, tag)
            {
                local classname = PopExtUtil.Classes[bot.GetPlayerClass()]
                local gun = PopExtUtil.GiveWeapon(bot, "tf_weapon_fists", 195)

                bot.SetCustomModelWithClassAnimations(format("models/player/%s.mdl", classname))
                PopExtUtil.CreatePlayerWearable(bot, format("models/player/items/%s/%s_zombie.mdl", classname, classname))
                SetPropBool(bot, "m_bForcedSkin", true)
                SetPropInt(bot, "m_nForcedSkin", bot.GetSkin() + 4)
            }
        })
        PopExt.AddRobotTag("bot_dummy", 
        {
            OnSpawn = function(bot, tag)
            {
                local classname = PopExtUtil.Classes[bot.GetPlayerClass()]
                local gun = PopExtUtil.GiveWeapon(bot, "tf_weapon_fists", 195)

                bot.SetSolid(0)
            }
        })
        PopExt.AddRobotTag("bot_horseman", 
        {
            OnSpawn = function(bot, tag) 
            {
                bot.ValidateScriptScope()
                local classname = PopExtUtil.Classes[bot.GetPlayerClass()]
                local tagscope = bot.GetScriptScope()

                EntFireByHandle(bot, "CallScriptFunction", "SpawnHHH", 0.1, bot, bot)
            }
            OnDeath = function(bot, tag) 
            {
                bot.ValidateScriptScope()
                local classname = PopExtUtil.Classes[bot.GetPlayerClass()]
                local tagscope = bot.GetScriptScope()
                
                tagscope.particle.Kill()
            }
        })
    }

    function OnScriptHook_OnTakeDamage(params) 
    {
        local victim = params.const_entity;
        local weapon = params.weapon;
        local attacker = params.attacker;
        local entity = params.inflictor;
        local damage = params.damage;

        local health = victim.GetMaxHealth()
        
        //have to check if bot type before checking tag
        if (attacker.GetClassname() == "player" && attacker.IsBotOfType(TF_BOT_TYPE))
        {
            if (attacker.HasBotTag("bot_horseman"))
            {
                params.damage = health * 0.9
            }   
        }
        
        if (victim.GetClassname() == "player" && victim.IsBotOfType(TF_BOT_TYPE))
        {
            if (victim.HasBotTag("bot_horseman"))
            {
                if (weapon != null && weapon.GetClassname() == "tf_weapon_minigun")
                {
                    damage *= 0.6
                }
                
                if (entity != null && entity.GetClassname() == "obj_sentrygun")
                {
                    damage *= 0.5
                }
            }
        }
    }
};


__CollectGameEventCallbacks(CreepsideConjuringNamespace)
CreepsideConjuringNamespace.MiscSetup()