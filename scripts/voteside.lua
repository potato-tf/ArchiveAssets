RedVoters = ''
BluVoters = ''
RandomVoters = ''
VoteTimerDuration = 1980 --1980 ticks divided by 66 ticks per second = 30 seconds
PlayerCount = 0
RedVotes = 0
BluVotes = 0
RandomVotes = 0
UnanimousVote = false
VoteTimerDurationUnanimous = 1980
VoteTimerActive = false
VoteList = {}
VotePassed = false
VoteActive = false
WaveActive = false
RandomActive = false
CurrentWave = 0
WavesPlayed = {[1] = 'n', [2] = 'n', [3] = 'n', [4] = 'n', [5] = 'n', [6] = 'n'}
AiFirstSpawn = false
SpyDisabled = false
MirrorMode = false
MirrorVote = false
MirrorAlreadyVoted = false
MirrorUnanimousVote = false
MirrorVoteTimerActive = false
MirrorVoteTimerDuration = 660
MirrorVoteTimerDurationUnanimous = 660
YesVoters = ''
NoVoters = ''
YesVotes = 0
NoVotes = 0
KaizoVote = false
KaizoMode = false
ExtraVoteTitle = 'Enable Mirror Mode?\n \nWaves will swap position\nbetween RED and BLU Side!\n \n'
spawnbot_front_left = ents.FindByName('spawnbot_front_left'):GetAbsOrigin()
spawnbot_front_right = ents.FindByName('spawnbot_front_right'):GetAbsOrigin()
spawnbot_left = ents.FindByName('spawnbot_left'):GetAbsOrigin()
spawnbot_right = ents.FindByName('spawnbot_right'):GetAbsOrigin()
Wavebar = {
	['r'] = {
		[1] = {
			[1] = {class = 'soldier_giant', count = 2, flag = 8},
			[2] = {class = 'demoknight_giant', count = 3, flag = 8},
			[3] = {class = 'pyro_giant', count = 4, flag = 8},
			[4] = {class = 'scout_bat', count = 33, flag = 1},
			[5] = {class = 'medic', count = 9, flag = 1},
			[6] = {class = 'heavy_gru', count = 12, flag = 1},
			[7] = {class = 'heavy_champ', count = 0, flag = 2}
		},
		[2] = {
			[1] = {class = 'demo_spammer', count = 3, flag = 8},
			[2] = {class = 'tank', count = 1, flag = 8},
			[3] = {class = 'heavy_shotgun', count = 3, flag = 8},
			[4] = {class = 'soldier_crit', count = 2, flag = 24},
			[5] = {class = 'soldier_directhit_lite', count = 2, flag = 8},
			[6] = {class = 'pyro', count = 16, flag = 1},
			[7] = {class = 'heavy_steelfist', count = 9, flag = 1},
			[8] = {class = 'soldier', count = 16, flag = 1},
			[9] = {class = 'demo', count = 16, flag = 1},
			[10] = {class = 'pyro_detonator_lite', count = 12, flag = 1},
			[11] = {class = 'scout', count = 0, flag = 2},
			[12] = {class = 'spy', count = 0, flag = 2}
		},
		[3] = {
			[1] = {class = 'demo_burst_giant', count = 6, flag = 8},
			[2] = {class = 'medic_crossbow', count = 3, flag = 8},
			[3] = {class = 'heavy_giant', count = 2, flag = 8},
			[4] = {class = 'soldier_spammer', count = 2, flag = 8},
			[5] = {class = 'heavy', count = 24, flag = 1},
			[6] = {class = 'pyro', count = 10, flag = 1},
			[7] = {class = 'medic_blast', count = 10, flag = 1},
			[8] = {class = 'demoknight', count = 32, flag = 1},
			[9] = {class = 'sniper_smg', count = 12, flag = 1},
			[10] = {class = 'scout_shortstop', count = 9, flag = 1},
			[11] = {class = 'demoknight_persian_nys', count = 0, flag = 2}
		},
		[4] = {
			[1] = {class = 'heavy_steelfist', count = 4, flag = 8},
			[2] = {class = 'demoknight_giant', count = 3, flag = 8},
			[3] = {class = 'medic_giant', count = 3, flag = 8},
			[4] = {class = 'pyro_dragonfury_giant', count = 6, flag = 8},
			[5] = {class = 'soldier_burstfire', count = 4, flag = 8},
			[6] = {class = 'medic_uber', count = 8, flag = 1},
			[7] = {class = 'demo', count = 24, flag = 1},
			[8] = {class = 'scout', count = 16, flag = 1},
			[9] = {class = 'sniper_antiheal', count = 16, flag = 1},
			[10] = {class = 'soldier_bison', count = 15, flag = 1},
			[11] = {class = 'soldier_directhit_lite', count = 0, flag = 2},
			[12] = {class = 'sniper', count = 0, flag = 2}
		},
		[5] = {
			[1] = {class = 'heavy_heater_giant', count = 2, flag = 8},
			[2] = {class = 'soldier_barrage', count = 2, flag = 8},
			[3] = {class = 'tank', count = 1, flag = 8},
			[4] = {class = 'scout_bonk_giant', count = 3, flag = 8},
			[5] = {class = 'heavy_shotgun_giant', count = 3, flag = 8},
			[6] = {class = 'soldier_blackbox_giant', count = 3, flag = 8},
			[7] = {class = 'soldier_buff', count = 20, flag = 1},
			[8] = {class = 'sniper_bow_multi', count = 12, flag = 1},
			[9] = {class = 'demo_loch', count = 18, flag = 1},
			[10] = {class = 'heavy_shotgun', count = 27, flag = 1},
			[11] = {class = 'heavy_champ', count = 28, flag = 1},
			[12] = {class = 'soldier_mangler', count = 24, flag = 1},
			[13] = {class = 'demo_burst', count = 0, flag = 2}
		},
		[6] = {
			[1] = {class = 'heavy_giant', count = 2, flag = 8},
			[2] = {class = 'medic_giant', count = 2, flag = 8},
			[3] = {class = 'demo_burst_giant', count = 3, flag = 8},
			[4] = {class = 'soldier_burstfire', count = 3, flag = 24},
			[5] = {class = 'pyro_phlog', count = 20, flag = 1},
			[6] = {class = 'demoknight_samurai', count = 9, flag = 1},
			[7] = {class = 'medic_uber', count = 9, flag = 1},
			[8] = {class = 'scout_cleaver', count = 12, flag = 1},
			[9] = {class = 'scout_pistol', count = 12, flag = 1},
			[10] = {class = 'heavy_steelfist', count = 20, flag = 17},
			[11] = {class = 'sniper_antiheal', count = 0, flag = 2}
		}
	},
	['b'] = {
		[1] = {
			[1] = {class = 'tank', count = 1, flag = 8},
			[2] = {class = 'soldier_giant', count = 2, flag = 8},
			[3] = {class = 'demo_giant', count = 2, flag = 8},
			[4] = {class = 'pyro_fireaxe_lite', count = 27, flag = 1},
			[5] = {class = 'demoknight_samurai', count = 4, flag = 1},
			[6] = {class = 'heavy_champ', count = 8, flag = 1},
			[7] = {class = 'pyro_detonator_lite', count = 12, flag = 1},
			[8] = {class = 'soldier_shovel', count = 0, flag = 2}
		},
		[2] = {
			[1] = {class = 'pyro_giant', count = 3, flag = 8},
			[2] = {class = 'heavy_giant', count = 1, flag = 8},
			[3] = {class = 'scout_fan_giant', count = 3, flag = 8},
			[4] = {class = 'soldier_blackbox_giant', count = 3, flag = 8},
			[5] = {class = 'medic_kritz', count = 6, flag = 1},
			[6] = {class = 'soldier', count = 15, flag = 1},
			[7] = {class = 'medic', count = 1, flag = 1},
			[8] = {class = 'scout', count = 12, flag = 1},
			[9] = {class = 'sniper_bow_multi', count = 6, flag = 1},
			[10] = {class = 'heavy_mittens', count = 40, flag = 17},
			[11] = {class = 'demo', count = 0, flag = 2},
			[12] = {class = 'sniper', count = 0, flag = 2}
		},
		[3] = {
			[1] = {class = 'heavy_champ_giant', count = 6, flag = 8},
			[2] = {class = 'engineer_widowmaker_nys', count = 2, flag = 8},
			[3] = {class = 'medic_bullet', count = 2, flag = 8},
			[4] = {class = 'demo_spammer', count = 3, flag = 8},
			[5] = {class = 'soldier_directhit_lite', count = 2, flag = 8},
			[6] = {class = 'pyro_dragonfury', count = 24, flag = 1},
			[7] = {class = 'heavy_gru', count = 20, flag = 1},
			[8] = {class = 'heavy_shotgun', count = 18, flag = 1},
			[9] = {class = 'demo', count = 12, flag = 1},
			[10] = {class = 'demo_sticky_daan', count = 12, flag = 1},
			[11] = {class = 'heavy', count = 0, flag = 2}
		},
		[4] = {
			[1] = {class = 'heavy_shotgun', count = 4, flag = 8},
			[2] = {class = 'demo_burst_giant', count = 6, flag = 8},
			[3] = {class = 'tank', count = 1, flag = 8},
			[4] = {class = 'pyro_phlog', count = 6, flag = 8},
			[5] = {class = 'heavy_healonkill', count = 3, flag = 8},
			[6] = {class = 'scout_bat', count = 40, flag = 1},
			[7] = {class = 'soldier_blackbox', count = 20, flag = 1},
			[8] = {class = 'sniper_ammodrain', count = 16, flag = 1},
			[9] = {class = 'sniper_smg', count = 8, flag = 1},
			[10] = {class = 'demo_loch', count = 0, flag = 2},
			[11] = {class = 'spy', count = 0, flag = 2}
		},
		[5] = {
			[1] = {class = 'soldier_conch_giant', count = 2, flag = 8},
			[2] = {class = 'medic_giant', count = 2, flag = 8},
			[3] = {class = 'demoknight_giant', count = 6, flag = 8},
			[4] = {class = 'heavy_shotgun_giant', count = 3, flag = 8},
			[5] = {class = 'heavy', count = 12, flag = 1},
			[6] = {class = 'scout_pistol', count = 24, flag = 1},
			[7] = {class = 'scout_shortstop', count = 8, flag = 1},
			[8] = {class = 'heavy_steelfist', count = 21, flag = 1},
			[9] = {class = 'scout', count = 25, flag = 1},
			[10] = {class = 'pyro', count = 25, flag = 1},
			[11] = {class = 'soldier_conch', count = 20, flag = 1},
			[12] = {class = 'medic_uber', count = 18, flag = 1},
			[13] = {class = 'sniper_bow', count = 30, flag = 1},
			[14] = {class = 'soldier_blackbox', count = 0, flag = 2}
		},
		[6] = {
			[1] = {class = 'demo_sticky_daan', count = 1, flag = 8},
			[2] = {class = 'medic_shield', count = 1, flag = 8},
			[3] = {class = 'scout_stun_giant_armored', count = 8, flag = 8},
			[4] = {class = 'heavy_giant', count = 2, flag = 8},
			[5] = {class = 'medic_giant', count = 2, flag = 8},
			[6] = {class = 'demo_ibomber', count = 5, flag = 24},
			[7] = {class = 'pyro_dragonfury_giant', count = 5, flag = 8},
			[8] = {class = 'heavy_champ', count = 64, flag = 1},
			[9] = {class = 'soldier', count = 16, flag = 1},
			[10] = {class = 'demo', count = 16, flag = 1},
			[11] = {class = 'sniper_ammodrain', count = 0, flag = 2}
		}
	},
	['k'] = {
		[1] = {
			[1] = {class = 'soldier_giant', count = 4, flag = 8},
			[2] = {class = 'demoknight_giant', count = 3, flag = 8},
			[3] = {class = 'pyro_giant', count = 4, flag = 8},
			[4] = {class = 'tank', count = 1, flag = 8},
			[5] = {class = 'demo_giant', count = 2, flag = 8},
			[6] = {class = 'scout_bat', count = 33, flag = 1},
			[7] = {class = 'medic', count = 9, flag = 1},
			[8] = {class = 'heavy_gru', count = 12, flag = 1},
			[9] = {class = 'pyro_fireaxe_lite', count = 27, flag = 1},
			[10] = {class = 'demoknight_samurai', count = 4, flag = 1},
			[11] = {class = 'heavy_champ', count = 8, flag = 1},
			[12] = {class = 'pyro_detonator_lite', count = 12, flag = 1},
			[13] = {class = 'heavy_champ', count = 0, flag = 2},
			[14] = {class = 'soldier_shovel', count = 0, flag = 2}
		},
		[2] = {
			[1] = {class = 'demo_spammer', count = 3, flag = 8},
			[2] = {class = 'tank', count = 1, flag = 8},
			[3] = {class = 'heavy_shotgun', count = 3, flag = 8},
			[4] = {class = 'soldier_crit', count = 2, flag = 24},
			[5] = {class = 'soldier_directhit_lite', count = 2, flag = 8},
			[6] = {class = 'pyro_giant', count = 3, flag = 8},
			[7] = {class = 'heavy_giant', count = 1, flag = 8},
			[8] = {class = 'scout_fan_giant', count = 3, flag = 8},
			[9] = {class = 'soldier_blackbox_giant', count = 3, flag = 8},
			[10] = {class = 'pyro', count = 16, flag = 1},
			[11] = {class = 'heavy_steelfist', count = 9, flag = 1},
			[12] = {class = 'soldier', count = 31, flag = 1},
			[13] = {class = 'demo', count = 16, flag = 1},
			[14] = {class = 'pyro_detonator_lite', count = 12, flag = 1},
			[15] = {class = 'medic_kritz', count = 6, flag = 1},
			[16] = {class = 'medic', count = 1, flag = 1},
			[17] = {class = 'scout', count = 12, flag = 1},
			[18] = {class = 'sniper_bow_multi', count = 6, flag = 1},
			[19] = {class = 'heavy_mittens', count = 40, flag = 17},
			[20] = {class = 'scout', count = 0, flag = 2},
			[21] = {class = 'demo', count = 0, flag = 2},
			[22] = {class = 'spy', count = 0, flag = 2},
			[23] = {class = 'sniper', count = 0, flag = 2}
		},
		[3] = {
			[1] = {class = 'demo_burst_giant', count = 6, flag = 8},
			[2] = {class = 'medic_crossbow', count = 3, flag = 8},
			[3] = {class = 'heavy_giant', count = 2, flag = 8},
			[4] = {class = 'soldier_spammer', count = 2, flag = 8},
			[5] = {class = 'heavy_champ_giant', count = 6, flag = 8},
			[6] = {class = 'engineer_widowmaker_nys', count = 2, flag = 8},
			[7] = {class = 'medic_bullet', count = 2, flag = 8},
			[8] = {class = 'demo_spammer', count = 3, flag = 8},
			[9] = {class = 'soldier_directhit_lite', count = 2, flag = 8},
			[10] = {class = 'heavy', count = 24, flag = 1},
			[11] = {class = 'pyro', count = 10, flag = 1},
			[12] = {class = 'medic_blast', count = 10, flag = 1},
			[13] = {class = 'demoknight', count = 32, flag = 1},
			[14] = {class = 'sniper_smg', count = 12, flag = 1},
			[15] = {class = 'scout_shortstop', count = 9, flag = 1},
			[16] = {class = 'pyro_dragonfury', count = 24, flag = 1},
			[17] = {class = 'heavy_gru', count = 20, flag = 1},
			[18] = {class = 'heavy_shotgun', count = 18, flag = 1},
			[19] = {class = 'demo', count = 12, flag = 1},
			[20] = {class = 'demo_sticky_daan', count = 12, flag = 1},
			[21] = {class = 'demoknight_persian_nys', count = 0, flag = 2},
			[22] = {class = 'heavy', count = 0, flag = 2}
		},
		[4] = {
			[1] = {class = 'heavy_steelfist', count = 4, flag = 8},
			[2] = {class = 'demoknight_giant', count = 3, flag = 8},
			[3] = {class = 'medic_giant', count = 3, flag = 8},
			[4] = {class = 'pyro_dragonfury_giant', count = 6, flag = 8},
			[5] = {class = 'soldier_burstfire', count = 4, flag = 8},
			[6] = {class = 'heavy_shotgun', count = 4, flag = 8},
			[7] = {class = 'demo_burst_giant', count = 6, flag = 8},
			[8] = {class = 'tank', count = 1, flag = 8},
			[9] = {class = 'pyro_phlog', count = 6, flag = 8},
			[10] = {class = 'heavy_healonkill', count = 3, flag = 8},
			[11] = {class = 'medic_uber', count = 8, flag = 1},
			[12] = {class = 'demo', count = 24, flag = 1},
			[13] = {class = 'scout', count = 16, flag = 1},
			[14] = {class = 'sniper_antiheal', count = 16, flag = 1},
			[15] = {class = 'soldier_bison', count = 15, flag = 1},
			[16] = {class = 'scout_bat', count = 40, flag = 1},
			[17] = {class = 'soldier_blackbox', count = 20, flag = 1},
			[18] = {class = 'sniper_ammodrain', count = 16, flag = 1},
			[19] = {class = 'sniper_smg', count = 8, flag = 1},
			[20] = {class = 'soldier_directhit_lite', count = 0, flag = 2},
			[21] = {class = 'demo_loch', count = 0, flag = 2},
			[22] = {class = 'sniper', count = 0, flag = 2},
			[23] = {class = 'spy', count = 0, flag = 2}
		},
		[5] = {
			[1] = {class = 'heavy_heater_giant', count = 2, flag = 8},
			[2] = {class = 'soldier_barrage', count = 2, flag = 8},
			[3] = {class = 'tank', count = 1, flag = 8},
			[4] = {class = 'scout_bonk_giant', count = 3, flag = 8},
			[5] = {class = 'heavy_shotgun_giant', count = 6, flag = 8},
			[6] = {class = 'soldier_blackbox_giant', count = 3, flag = 8},
			[7] = {class = 'soldier_conch_giant', count = 2, flag = 8},
			[8] = {class = 'medic_giant', count = 2, flag = 8},
			[9] = {class = 'demoknight_giant', count = 6, flag = 8},
			[10] = {class = 'soldier_buff', count = 20, flag = 1},
			[11] = {class = 'sniper_bow_multi', count = 12, flag = 1},
			[12] = {class = 'demo_loch', count = 18, flag = 1},
			[13] = {class = 'heavy_shotgun', count = 27, flag = 1},
			[14] = {class = 'heavy_champ', count = 28, flag = 1},
			[15] = {class = 'soldier_mangler', count = 24, flag = 1},
			[16] = {class = 'heavy', count = 12, flag = 1},
			[17] = {class = 'scout_pistol', count = 24, flag = 1},
			[18] = {class = 'scout_shortstop', count = 8, flag = 1},
			[19] = {class = 'heavy_steelfist', count = 21, flag = 1},
			[20] = {class = 'scout', count = 25, flag = 1},
			[21] = {class = 'pyro', count = 25, flag = 1},
			[22] = {class = 'soldier_conch', count = 20, flag = 1},
			[23] = {class = 'medic_uber', count = 18, flag = 1},
			[24] = {class = 'sniper_bow', count = 30, flag = 1}
		},
		[6] = {
			[1] = {class = 'heavy_giant', count = 4, flag = 8},
			[2] = {class = 'medic_giant', count = 4, flag = 8},
			[3] = {class = 'demo_burst_giant', count = 3, flag = 8},
			[4] = {class = 'soldier_burstfire', count = 3, flag = 24},
			[5] = {class = 'demo_sticky_daan', count = 1, flag = 8},
			[6] = {class = 'medic_shield', count = 1, flag = 8},
			[7] = {class = 'scout_stun_giant_armored', count = 8, flag = 8},
			[8] = {class = 'demo_ibomber', count = 5, flag = 24},
			[9] = {class = 'pyro_dragonfury_giant', count = 5, flag = 8},
			[10] = {class = 'pyro_phlog', count = 20, flag = 1},
			[11] = {class = 'demoknight_samurai', count = 9, flag = 1},
			[12] = {class = 'medic_uber', count = 9, flag = 1},
			[13] = {class = 'scout_cleaver', count = 12, flag = 1},
			[14] = {class = 'scout_pistol', count = 12, flag = 1},
			[15] = {class = 'heavy_steelfist', count = 20, flag = 17},
			[16] = {class = 'heavy_champ', count = 64, flag = 1},
			[17] = {class = 'soldier', count = 16, flag = 1},
			[18] = {class = 'demo', count = 16, flag = 1},
			[19] = {class = 'sniper_antiheal', count = 0, flag = 2},
			[20] = {class = 'sniper_ammodrain', count = 0, flag = 2}
		}
	}
}
WavebarCount = 0

VoteMenu = {
	timeout = 0,
	title = 'Choose a wave\n ',
    flags = MENUFLAG_NO_SOUND,
	onSelect = function (voter, index)
		if index == 1 and voter.VoteChoice ~= 2 then
			voter.VoteChoice = 2
			voter:PlaySoundToSelf('ui/hint.wav')
		elseif index == 2 and voter.VoteChoice ~= 3 then
			voter.VoteChoice = 3
			voter:PlaySoundToSelf('ui/hint.wav')
		elseif index == 3 and voter.VoteChoice ~= 1 then
			voter.VoteChoice = 1
			voter:PlaySoundToSelf('ui/hint.wav')
		else
			voter.VoteChoice = 0
		end
		UpdateMenu()
	end
}

MirrorVoteMenu = {
	timeout = 0,
	title = ExtraVoteTitle,
    flags = MENUFLAG_NO_SOUND,
	onSelect = function (voter, index)
		if index == 1 and voter.MirrorVoteChoice ~= 1 then
			voter.MirrorVoteChoice = 1
			voter:PlaySoundToSelf('ui/vote_yes.wav')
		elseif index == 2 and voter.MirrorVoteChoice ~= 2 then
			voter.MirrorVoteChoice = 2
			voter:PlaySoundToSelf('ui/vote_no.wav')
		else
			voter.MirrorVoteChoice = 0
		end
		UpdateMenu()
	end
}

ResultMenu = {
	timeout = 3,
	title = '✓ Vote Passed...',
	flags = MENUFLAG_NO_SOUND,
	[1] = {text=''},
}

--[[ function OnPlayerConnected(player)
	player:AddCallback(ON_DEATH, function()
	if WaveActive == true then
		local remaining = 0
		for k = 1, 12 do
			if ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags[k] ~= 4 then
				remaining = remaining + ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[k]
			end
		end
		for k = 1, 2 do
			if ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags2[k] ~= 4 then
				remaining = remaining + ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[k]
			end
		end
 		for k = 1, 12 do
			print(k, ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[k], ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames[k])
		end
		for k = 1, 12 do
			print(k+12, ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[k], ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames2[k])
		end 
		if remaining == 0 then
			EndWave()
		end
	end end)
end ]]

function UpdateMenu()
	RedVoters = ''
	BluVoters = ''
	RandomVoters = ''
	VoteMenu[1] = {text = 'Unlock RED Side'}
	VoteMenu[2] = {text = 'Unlock BLU Side'}
	VoteMenu[3] = {text = 'Random'}
	PlayerCount = 0
	RedVotes = 0
	BluVotes = 0
	RandomVotes = 0
	for _, player in pairs(ents.GetAllPlayers()) do
		if player:IsRealPlayer() and player.m_iTeamNum == 2 then
			PlayerCount = PlayerCount + 1
			if player.VoteChoice == 1 then
				RandomVoters = RandomVoters .. '\n✓ ' .. player.m_szNetname
				VoteMenu[3].text = 'Random' .. RandomVoters
				RandomVotes = RandomVotes + 1
			elseif player.VoteChoice == 2 then
				RedVoters = RedVoters .. '\n✓ ' .. player.m_szNetname
				VoteMenu[1].text = 'Unlock RED Side' .. RedVoters
				RedVotes = RedVotes + 1
			elseif player.VoteChoice == 3 then
				BluVoters = BluVoters .. '\n✓ ' .. player.m_szNetname
				VoteMenu[2].text = 'Unlock BLU Side' .. BluVoters
				BluVotes = BluVotes + 1
			end
		end
	end

	if RedVotes == 0 and BluVotes == 0 and RandomVotes == 0 then
		VoteTimerActive = false
		VoteTimerDuration = 1980
		VoteMenu.title = 'Choose a wave\n '
	else
		VoteTimerActive = true
	end

	if (RedVotes == PlayerCount or BluVotes == PlayerCount or RandomVotes == PlayerCount) and VoteTimerDuration >= 198 and UnanimousVote == false then
		UnanimousVote = true
		VoteTimerDurationUnanimous = VoteTimerDuration
		VoteTimerDuration = 198
	end

	if (RedVotes ~= PlayerCount and BluVotes ~= PlayerCount and RandomVotes ~= PlayerCount) and UnanimousVote == true then
		UnanimousVote = false
		VoteTimerDuration = VoteTimerDurationUnanimous
	end

	for _, player in pairs(ents.GetAllPlayers()) do
		if player:IsRealPlayer() and player.m_iTeamNum == 2 then
			player:DisplayMenu(VoteMenu)
			player.Overlay = 'wavebar'
			if KaizoMode == false then
				if MirrorMode == true then
					player:AcceptInput('SetScriptOverlayMaterial', 'yiresahud/wavebar'..CurrentWave..'m')
				else
					player:AcceptInput('SetScriptOverlayMaterial', 'yiresahud/wavebar'..CurrentWave)
				end
			else
				player:AcceptInput('SetScriptOverlayMaterial', '')
			end
		end
	end

	if MirrorVote == true then
		YesVoters = ''
		NoVoters = ''

		MirrorVoteMenu[1] = {text = 'Yes'}
		MirrorVoteMenu[2] = {text = 'No'}
		YesVotes = 0
		NoVotes = 0

		for _, player in pairs(ents.GetAllPlayers()) do
			if player:IsRealPlayer() and player.m_iTeamNum == 2 then
				PlayerCount = PlayerCount + 1
				if player.MirrorVoteChoice == 1 then
					YesVoters = YesVoters .. '\n✓ ' .. player.m_szNetname
					MirrorVoteMenu[1].text = 'Yes' .. YesVoters
					YesVotes = YesVotes + 1
				elseif player.MirrorVoteChoice == 2 then
					NoVoters = NoVoters .. '\n✓ ' .. player.m_szNetname
					MirrorVoteMenu[2].text = 'No' .. NoVoters
					NoVotes = NoVotes + 1
				end
			end
		end

		for _, player in pairs(ents.GetAllPlayers()) do
			if player:IsRealPlayer() and player.m_iTeamNum == 2 then
				player:DisplayMenu(MirrorVoteMenu)
				player:AcceptInput('SetScriptOverlayMaterial', 'yiresahud/wavebar'..CurrentWave)
			end
		end
	end

	if (YesVotes == PlayerCount or NoVotes == PlayerCount) and MirrorVoteTimerDuration >= 198 and MirrorUnanimousVote == false then
		MirrorUnanimousVote = true
		MirrorVoteTimerDurationUnanimous = MirrorVoteTimerDuration
		MirrorVoteTimerDuration = 198
	end

	if (YesVotes ~= PlayerCount and NoVotes ~= PlayerCount) and MirrorUnanimousVote == true then
		MirrorUnanimousVote = false
		MirrorVoteTimerDuration = MirrorVoteTimerDurationUnanimous
	end
end

function OnWaveInit(wave)
	CurrentWave = wave
	SpyDisabled = false
	WaveActive = false
	RandomActive = false
	AiFirstSpawn = false
	timer.Simple(1, function()
		for _, player in pairs(ents.GetAllPlayers()) do
			if player:IsRealPlayer() then
				player.VoteChoice = 0
				player.MirrorVoteChoice = 0
				player:PlaySoundToSelf('ui/vote_started.wav')
				VoteActive = true
			end
		end
		VoteActive = true
		UpdateMenu()
	end)

	for k = 1, 12 do
		ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags[k] = 0
		ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags2[k] = 0
	end

	if KaizoMode == false then
		for k = 1, ents.FindByClass('tf_objective_resource').m_nMannVsMachineMaxWaveCount do
			if k < wave then
				ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[k] = k
				ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags[k] = 1
				if string.sub((WavesPlayed[k]), 1, 1) == 'r' then
					ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames[k] = 'pathred'
				elseif string.sub((WavesPlayed[k]), 1, 1) == 'b' then
					ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames[k] = 'pathblu'
				elseif string.sub((WavesPlayed[k]), 1, 1) == 'd' then
					ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames[k] = 'pathrandom'
				else
					ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames[k] = 'random_lite'
				end
			else
				ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[k] = 0
				ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags[k] = 0
			end
		end

		WavebarCount = 0

		for k = 1, wave do
			WavebarCount = WavebarCount + k
		end

		ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveEnemyCount = WavebarCount
		ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[wave] = wave
		ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[wave + 1] = 0
		ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[wave + 2] = 0
		ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[wave + 3] = 0
		ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames[wave] = 'random_lite'
		ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames[wave + 1] = 'pathred'
		ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames[wave + 2] = 'pathblu'
		ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames[wave + 3] = 'pathrandom'
		ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags[wave] = 1
		ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags[wave + 1] = 2
		ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags[wave + 2] = 2
		ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags[wave + 3] = 2
	else
		InitializeWavebar(wave, 'k')
	end

	if wave == 1 then
		ents.FindByClass('tf_gamerules'):RunScriptFile('enablemirror')
	end
end

function OnWaveStart(wave)
 	WavesPlayed[wave] = string.sub((VoteListSorted)[3], 2, 3)
	WaveActive = true
	if MirrorMode == false then
		InitializeWavebar(wave, string.sub((WavesPlayed[wave]), 1, 1))
	else
		if string.sub((WavesPlayed[wave]), 1, 1) == 'r' then
			InitializeWavebar(wave, 'b')
		else
			InitializeWavebar(wave, 'r')
		end
	end
	if KaizoMode == false then
		if wave == 2 then
			ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags[12] = 0
			if string.sub((WavesPlayed[wave]), 1, 1) == 'r' then
				ents.FindByName('spawnbot_mission_sniper'):AcceptInput("Disable")
				ents.FindByName('spawnbot_mission_sniper_left'):AcceptInput("Disable")
				ents.FindByName('spawnbot_mission_sniper_right'):AcceptInput("Disable")
			elseif string.sub((WavesPlayed[wave]), 1, 1) == 'b' then
				ents.FindByName('spawnbot_mission_spy'):AcceptInput("Disable")
				SpyDisabled = true
			end
			if MirrorMode == false then
				if string.sub((WavesPlayed[wave]), 1, 1) == 'r' then
					ents.FindByName('spawnbot_mission_spy'):AcceptInput("Disable")
					SpyDisabled = true
				elseif string.sub((WavesPlayed[wave]), 1, 1) == 'b' then
					ents.FindByName('spawnbot_mission_sniper'):AcceptInput("Disable")
					ents.FindByName('spawnbot_mission_sniper_left'):AcceptInput("Disable")
					ents.FindByName('spawnbot_mission_sniper_right'):AcceptInput("Disable")
				end
			end
		end
		if wave == 4 then
			if string.sub((WavesPlayed[wave]), 1, 1) == 'b' then
				ents.FindByName('spawnbot_mission_sniper'):AcceptInput("Disable")
				ents.FindByName('spawnbot_mission_sniper_left'):AcceptInput("Disable")
				ents.FindByName('spawnbot_mission_sniper_right'):AcceptInput("Disable")
				ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags[11] = 0
			elseif string.sub((WavesPlayed[wave]), 1, 1) == 'r' then
				ents.FindByName('spawnbot_mission_spy'):AcceptInput("Disable")
				ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags[12] = 0
				SpyDisabled = true
			end
			if MirrorMode == false then
				if string.sub((WavesPlayed[wave]), 1, 1) == 'r' then
					ents.FindByName('spawnbot_mission_spy'):AcceptInput("Disable")
					ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags[12] = 0
					SpyDisabled = true
				elseif string.sub((WavesPlayed[wave]), 1, 1) == 'b' then
					ents.FindByName('spawnbot_mission_sniper'):AcceptInput("Disable")
					ents.FindByName('spawnbot_mission_sniper_left'):AcceptInput("Disable")
					ents.FindByName('spawnbot_mission_sniper_right'):AcceptInput("Disable")
					ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags[11] = 0
				end
			end
		end
	else
		InitializeWavebar(wave, 'k')
		if wave == 2 or wave == 4 then
			ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags2[11] = 0
			ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags2[10] = 0
		end
	end
	if string.sub((WavesPlayed[wave]), 2, 2) == 'd' then
		RandomActive = true
	end
end

function OnWaveSuccess(wave)
--[[ 	if RandomActive == true then
		timer.Simple(1, function()
			if wave - 1 ~= 6 then
				util.PrintToChatAll("\x076cc94d$100 bonus for randoming has been awarded!")
				for _, player in pairs(ents.GetAllPlayers()) do
					if player:IsRealPlayer() and player.m_iTeamNum == 2 then
						player:AddCurrency(100)
					end
				end
			end
		end)
	end ]]
	if wave - 1 == 1 then
		if string.sub((WavesPlayed[wave - 1]), 1, 1) == 'r' then
			util.PrintToChatAll("\x07ff3d3dAI-dol\x07fbeccb has been upgraded with: \x07FFD700Equip Rocket Launcher")
		else
			util.PrintToChatAll("\x07ff3d3dAI-dol\x07fbeccb has been upgraded with: \x07FFD700Equip Flamethrower")
		end
	elseif wave - 1 == 2 then
		if string.sub((WavesPlayed[wave - 1]), 1, 1) == 'r' then
			util.PrintToChatAll("\x07ff3d3dAI-dol\x07fbeccb has been upgraded with: \x07FFD700Rapid Reload Module")
		else
			util.PrintToChatAll("\x07ff3d3dAI-dol\x07fbeccb has been upgraded with: \x07FFD700Heal On Hit Module")
		end
	elseif wave - 1 == 3 then
		if string.sub((WavesPlayed[wave - 1]), 1, 1) == 'r' then
			util.PrintToChatAll("\x07ff3d3dAI-dol\x07fbeccb has been upgraded with: \x07FFD700Blast Resist Aura")
		else
			util.PrintToChatAll("\x07ff3d3dAI-dol\x07fbeccb has been upgraded with: \x07FFD700Bullet Resist Aura")
		end
	elseif wave - 1 == 4 then
		if string.sub((WavesPlayed[wave - 1]), 1, 1) == 'r' then
			util.PrintToChatAll("\x07ff3d3dAI-dol\x07fbeccb has been upgraded with: \x07FFD700Anti-Heal Attacks")
		else
			util.PrintToChatAll("\x07ff3d3dAI-dol\x07fbeccb has been upgraded with: \x07FFD700Ammo Drain Attacks")
		end
	elseif wave - 1 == 5 then
		if string.sub((WavesPlayed[wave - 1]), 1, 1) == 'r' then
			util.PrintToChatAll("\x07ff3d3dAI-dol\x07fbeccb has been upgraded with: \x07FFD700Equip Buff Banner")
		else
			util.PrintToChatAll("\x07ff3d3dAI-dol\x07fbeccb has been upgraded with: \x07FFD700Equip Concheror")
		end
	elseif wave - 1 == 6 then
		local clearstring = ""
		clearstring = clearstring .. "\x07FFD700>>>  "
		for k = 1, 6 do
			if string.sub((WavesPlayed[k]), 1, 1) == 'r' then
				clearstring = clearstring .. "\x07ff3d3d 【R"
				if string.sub((WavesPlayed[k]), 2, 2) == 'd' then
					clearstring = clearstring .. "\x07FFD700◆\x07ff3d3d】 "
				else
					clearstring = clearstring .. "\x07ff3d3d】 "
				end
			else
				clearstring = clearstring .. "\x0799CCFF 【B"
				if string.sub((WavesPlayed[k]), 2, 2) == 'd' then
					clearstring = clearstring .. "\x07FFD700◆\x0799CCFF】 "
				else
					clearstring = clearstring .. "\x0799CCFF】 "
				end
			end
		end
		clearstring = clearstring .. "\x07FFD700  <<<"
		util.PrintToChatAll(clearstring)
		if MirrorMode == true then util.PrintToChatAll("\x0700FF00>>>>>>>> MIRROR MODE CLEAR <<<<<<<<") end
		if KaizoMode == true then util.PrintToChatAll("\x07FFFF00>>>>>>>> KAIZO MODE CLEAR <<<<<<<<") end
		local k = 0
		for i = 1, 6, 1 do
			if string.sub((WavesPlayed[i]), 2, 2) == 'd' then
				k = k + 1
			end
			if k == 6 then
				util.PrintToChatAll("\x0700FF00Mirror Mode unlocked! Type \x07FFFFFFenablemirror \x0700FF00in chat during Wave 1 voting time to enable Mirror Mode")
				util.PrintToChatAll("\x07FFFF00Kaizo Mode unlocked! Type \x07FFFFFFenablekaizo \x07FFFF00in chat during Wave 1 voting time to enable Kaizo Mode.")
				for _, player in pairs(ents.GetAllPlayers()) do
					if player:IsRealPlayer() and player.m_iTeamNum == 2 then
						player:RunScriptFile('unlockmirror')
					end
				end
			end
		end
	end
end

--[[ function OnWaveReset(wave)
	for k = 1, wave do
		if WavesPlayed[k] ~= nil then
			if string.sub((WavesPlayed[k]), 2, 2) == 'd' then
				timer.Simple(1, function()
					for _, player in pairs(ents.GetAllPlayers()) do
						if player:IsRealPlayer() and player.m_iTeamNum == 2 then
							player:AddCurrency(100)
						end
					end
				end)
			end
		end
	end
end ]]

function OnGameTick()
	if (VoteTimerDuration == 0 and VoteTimerActive == true) or (math.abs(ents.FindByClass('tf_gamerules').m_flRestartRoundTime - CurTime()) < 10 and VoteActive == true) then
		VoteTimerActive = false
		VoteActive = false
		for _, player in pairs(ents.GetAllPlayers()) do
			if player:IsRealPlayer() then
				if player.Overlay == 'wavebar' then
					player:AcceptInput('SetScriptOverlayMaterial', '')
					player.Overlay = 'none'
				end
			end
		end
		VoteResult()
		if MirrorVote == true then
			MirrorVoteTimerActive = false
			MirrorVote = false
		end
	end

	if VoteTimerActive == true then
		VoteTimerDuration = VoteTimerDuration - 1
		if math.ceil(VoteTimerDuration/66) == 1 then VoteMenu.title = 'Choose a wave\n' .. math.ceil(VoteTimerDuration/66) .. ' second remaining\n ' else VoteMenu.title = 'Choose a wave\n' .. math.ceil(VoteTimerDuration/66) .. ' seconds remaining\n ' end
	end

	if UnanimousVote == true then
		VoteTimerDurationUnanimous = VoteTimerDurationUnanimous - 1
	end

	if VoteActive == true then
		UpdateMenu()
	end

	if VoteActive == false then
		for _, player in pairs(ents.GetAllPlayers()) do
			if (player:InCond(65) == true and player:InCond(12) == true) and not (player:InCond(5) == true or player:InCond(52) == true) then
				if player.Overlay ~= 'combined' then
					player.Overlay = 'combined'
					player:SetScriptOverlayMaterial("yiresahud/combined")
					player:Print(2, "Healing Disabled!\nAmmo Drained!")
					player:AcceptInput("AddOutput", "rendercolor 228 75 128")
					player:PlaySoundToSelf('ana_biotic_grenade_no_healing_sound.mp3')
				end
			else
				if (player:InCond(12) == true and player:IsAlive() == true and not (player:InCond(5) == true or player:InCond(52) == true)) then
					if player.Overlay ~= 'antiheal' then
						player.Overlay = 'antiheal'
						player:SetScriptOverlayMaterial("yiresahud/antiheal")
						player:Print(2, "Healing Disabled!")
						player:SetAttributeValue("healing received penalty", 0)
						if player:IsRealPlayer() then player:SetAttributeValue("mod weapon blocks healing", 1) end
						player:AcceptInput("AddOutput", "rendercolor 200 0 255")
						player:PlaySoundToSelf('ana_biotic_grenade_no_healing_sound.mp3')
						for i = 0, 6 do
							if player:GetPlayerItemBySlot(i) ~= nil then
								player:GetPlayerItemBySlot(i):SetAttributeValue("healing received penalty", 0)
								if player:IsRealPlayer() then player:GetPlayerItemBySlot(i):SetAttributeValue("mod weapon blocks healing", 1) end
							end
						end
					end
				end
				if (player:InCond(65) == true and player:IsAlive() == true and not (player:InCond(5) == true or player:InCond(52) == true)) then
					if player.Overlay ~= 'ammodrain' then
						player.Overlay = 'ammodrain'
						player:SetScriptOverlayMaterial("yiresahud/ammodrain")
						player:Print(2, "Ammo Drained!")
						player:AcceptInput("AddOutput", "rendercolor 255 150 0")
						player:PlaySoundToSelf('ana_biotic_grenade_no_healing_sound.mp3')
						if player.m_iTeamNum == 3 then
							for i = 0, 1 do
								if player:GetPlayerItemBySlot(i) ~= nil then
									player:GetPlayerItemBySlot(i):SetAttributeValue("fire rate penalty HIDDEN", 1.8)
									player:GetPlayerItemBySlot(i):SetAttributeValue("reload time increased hidden", 1.8)
								end
							end
						end
					end
				end
			end
			if (player:InCond(65) == false and player:InCond(12) == false) then
				if player.Overlay ~= 'none' then
					player.Overlay = 'none'
					player:SetScriptOverlayMaterial("")
					player:Print(2, "")
					player:SetAttributeValue("healing received penalty", nil)
					if player:IsRealPlayer() then player:SetAttributeValue("mod weapon blocks healing", nil) end
					player:AcceptInput("AddOutput", "rendercolor 255 255 255")
					for i = 0, 6 do
						if player:GetPlayerItemBySlot(i) ~= nil then
							player:GetPlayerItemBySlot(i):SetAttributeValue("healing received penalty", nil)
							if player:IsRealPlayer() then player:GetPlayerItemBySlot(i):SetAttributeValue("mod weapon blocks healing", nil) end
						end
					end
					for i = 0, 1 do
						if player:GetPlayerItemBySlot(i) ~= nil then
							player:GetPlayerItemBySlot(i):SetAttributeValue("fire rate penalty HIDDEN", nil)
							player:GetPlayerItemBySlot(i):SetAttributeValue("reload time increased hidden", nil)
						end
					end
				end
			end
		end
	end

	if WaveActive == true then
		local remaining = 0
		for k = 1, 12 do
			if (ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags2[k] ~= 4) and (ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags2[k] ~= 2) then
				remaining = remaining + ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[k]
			end
		end
		for k = 1, 12 do
			if (ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags2[k] ~= 4) and (ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags2[k] ~= 2)  then
				remaining = remaining + ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[k]
			end
		end
--[[  		for k = 1, 12 do
			print(k, ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[k], ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames[k])
		end
		for k = 1, 12 do
			print(k+12, ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[k], ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames2[k])
		end ]]
		if remaining == 0 then
			EndWave()
		end
	end

	if (MirrorVoteTimerDuration == 0 and MirrorVoteTimerActive == true) then
		MirrorVoteTimerActive = false
		MirrorVote = false
		MirrorVoteResult()
	end

	if MirrorVoteTimerActive == true then
		MirrorVoteTimerDuration = MirrorVoteTimerDuration - 1
		if math.ceil(MirrorVoteTimerDuration/66) == 1 then MirrorVoteMenu.title = ExtraVoteTitle .. math.ceil(MirrorVoteTimerDuration/66) .. ' second remaining\n ' else MirrorVoteMenu.title = ExtraVoteTitle .. math.ceil(MirrorVoteTimerDuration/66) .. ' seconds remaining\n ' end
	end

	if MirrorUnanimousVote == true then
		MirrorVoteTimerDurationUnanimous = MirrorVoteTimerDurationUnanimous - 1
	end

	if VoteActive == true then
		UpdateMenu()
	end
end

function VoteResult()
	VoteList = {RedVotes..'r', BluVotes..'b', RandomVotes..'d'}
	table.sort(VoteList)
	VoteListSorted = {}

	for k, v in ipairs(VoteList) do
		VoteListSorted[k] = v
	end

	if string.sub((VoteListSorted)[3], 1, 1) == string.sub((VoteListSorted)[2], 1, 1) then
		ResultMenu.title = '✗ Vote Failed\n '
		ResultMenu[1].text = 'Not enough players voted. Random wave selected.'
		ChooseRandom(ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveCount)
		VotePassed = false
	elseif string.sub((VoteListSorted)[3], -1, -1) == 'r' then
		ResultMenu.title = '✓ Vote Passed\n '
		ResultMenu[1].text = 'Unlocking RED side...'
		ChooseRed(ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveCount, 'r')
		VoteListSorted[3] = ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveCount..'rn'
		VotePassed = true
	elseif string.sub((VoteListSorted)[3], -1, -1) == 'b' then
		ResultMenu.title = '✓ Vote Passed\n '
		ResultMenu[1].text = 'Unlocking BLU side...'
		ChooseBlu(ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveCount, 'b')
		VoteListSorted[3] = ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveCount..'bn'
		VotePassed = true
	elseif string.sub((VoteListSorted)[3], -1, -1) == 'd' then
		ResultMenu.title = '✓ Vote Passed\n '
		ResultMenu[1].text = 'Random selected!'
		ChooseRandom(ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveCount)
		VotePassed = true
	end

	for _, player in pairs(ents.GetAllPlayers()) do
		if player:IsRealPlayer() then
			player:DisplayMenu(ResultMenu)
		end
		if VotePassed == true then
			player:PlaySoundToSelf('ui/vote_success.wav')
		else
			player:PlaySoundToSelf('ui/vote_failure.wav')
		end
	end
end

function MirrorVoteResult()
	MirrorVoteList = {YesVotes..'y', NoVotes..'n'}
	table.sort(MirrorVoteList)
	MirrorVoteListSorted = {}

	for k, v in ipairs(MirrorVoteList) do
		MirrorVoteListSorted[k] = v
	end

	if string.sub((MirrorVoteListSorted)[2], 1, 1) == string.sub((MirrorVoteListSorted)[1], 1, 1) then
		VotePassed = false
		util.PrintToChatAll("\x07FF0000Vote Failed")
	elseif string.sub((MirrorVoteListSorted)[2], -1, -1) == 'y' then
		VotePassed = true
		if KaizoVote == false then
			MirrorMode = true
			ents.FindByName('spawnbot_front_left'):Teleport(spawnbot_front_right)
			ents.FindByName('spawnbot_front_right'):Teleport(spawnbot_front_left)
			ents.FindByName('spawnbot_left'):Teleport(spawnbot_right)
			ents.FindByName('spawnbot_right'):Teleport(spawnbot_left)
			ents.FindByName('movespawns_left'):AddOutput('OnTrigger spawnbot_left:Disable:0:0.1:-1')
			ents.FindByName('movespawns_left'):AddOutput('OnTrigger spawnbot_right:Enable:0:0.1:-1')
			ents.FindByName('movespawns_right'):AddOutput('OnTrigger spawnbot_right:Disable:0:0.1:-1')
			ents.FindByName('movespawns_right'):AddOutput('OnTrigger spawnbot_left:Enable:0:0.1:-1')
			util.PrintToChatAll("\x0700FF00Mirror Mode has been enabled! RED and BLU waves have switched sides.")
		else
			KaizoMode = true
			InitializeWavebar(1, 'k')
			ents.FindByName('movespawns_left'):AddOutput('OnTrigger spawnbot_right:Enable:0:0.1:-1')
			ents.FindByName('movespawns_left'):AddOutput('OnTrigger popscript:$TeleportLeft:0:0.1:-1')
			ents.FindByName('movespawns_right'):AddOutput('OnTrigger popscript:$TeleportRight:0:0.1:-1')
			ents.FindByName('movespawns_right'):AddOutput('OnTrigger spawnbot_left:Enable:0:0.1:-1')
			util.PrintToChatAll("\x07FFFF00Kaizo Mode has been enabled! Both waves will spawn simultaneously. Good luck...")
		end
	elseif string.sub((MirrorVoteListSorted)[2], -1, -1) == 'n' then
		VotePassed = false
		util.PrintToChatAll("\x07FF0000Vote Failed")
	end

	for _, player in pairs(ents.GetAllPlayers()) do
		if player:IsRealPlayer() then
			player:DisplayMenu(ResultMenu)
		end
		if VotePassed == true then
			if KaizoVote == true then
				player:PlaySoundToSelf('ui/duel_challenge_accepted_with_restriction.wav')
			else
				player:PlaySoundToSelf('ui/duel_challenge_accepted.wav')
			end
		else
			if KaizoVote == true then
				player:PlaySoundToSelf('ui/duel_challenge_rejected_with_restriction.wav')
			else
				player:PlaySoundToSelf('ui/duel_challenge_rejected.wav')
			end
		end
	end
end

function ChooseRed(wave, team)
	ents.FindByName('wave_finished_nextwave_left'):AcceptInput("Trigger")
	if KaizoMode == false then timer.Simple(2, function() ents.FindByName('spawnbot_front_left'):AcceptInput("Disable") end) end
	if MirrorMode == true then
		timer.Simple(2.1, function() ents.FindByName('spawnbot_front_left'):AcceptInput("Enable") end)
		timer.Simple(2.1, function() ents.FindByName('spawnbot_front_right'):AcceptInput("Disable") end)
	end

	if KaizoMode == false then
		for k = 1, 12 do
			ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[k] = 0
			ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags[k] = 0
		end
		InitializeWavebar(wave, team)
		if MirrorMode == true then
			InitializeWavebar(wave, 'b')
		end
	end
end

function ChooseBlu(wave, team)
	ents.FindByName('wave_finished_nextwave_right'):AcceptInput("Trigger")
	if KaizoMode == false then timer.Simple(2, function() ents.FindByName('spawnbot_front_right'):AcceptInput("Disable") end) end
	if MirrorMode == true then
		timer.Simple(2.1, function() ents.FindByName('spawnbot_front_right'):AcceptInput("Enable") end)
		timer.Simple(2.1, function() ents.FindByName('spawnbot_front_left'):AcceptInput("Disable") end)
	end

	if KaizoMode == false then
		for k = 1, 12 do
			ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[k] = 0
			ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags[k] = 0
		end
		InitializeWavebar(wave, team)
		if MirrorMode == true then
			InitializeWavebar(wave, 'r')
		end
	end
end

function ChooseRandom(wave)
	local team = ''
	local number = math.random(2)
	if number == 1 then
		team = 'r'
		ChooseRed(wave, team)
	else
		team = 'b'
		ChooseBlu(wave, team)
	end
	VoteListSorted[3] = wave..team..'d'
end

function EndWave()
	for _, player in pairs(ents.GetAllPlayers()) do
		if player.m_iTeamNum == 3 then
			player:AcceptInput('$Suicide')
		end
	end
end

function InitializeWavebar(wave, team)
	WavebarCount = 0
	for k = 1, 12 do
		if Wavebar[team][wave][k] ~= nil then
			ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames[k] = Wavebar[team][wave][k].class
			ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[k] = Wavebar[team][wave][k].count
			ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags[k] = Wavebar[team][wave][k].flag
			WavebarCount = WavebarCount + Wavebar[team][wave][k].count
		else
			ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames[k] = ''
			ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[k] = 0
			ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags[k] = 0
		end

	end
	for k = 13, 24 do
		if Wavebar[team][wave][k] ~= nil then
			ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames2[k-12] = Wavebar[team][wave][k].class
			ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[k-12] = Wavebar[team][wave][k].count
			ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags2[k-12] = Wavebar[team][wave][k].flag
			WavebarCount = WavebarCount + Wavebar[team][wave][k].count
		else
			ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames2[k-12] = ''
			ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[k-12] = 0
			ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags2[k-12] = 0
		end
	end
	if KaizoMode == false then
		if team == 'r' then
			ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames2[12] = 'pathred'
			ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[12] = 0
			ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags2[12] = 2
			if MirrorMode == true then ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames2[12] = 'pathblu' end
		else
			ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames2[12] = 'pathblu'
			ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[12] = 0
			ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags2[12] = 2
			if MirrorMode == true then ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames2[12] = 'pathred' end
		end
	end
	ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveEnemyCount = WavebarCount
end

--[[ ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// ]]

timer.Create(0.5, function ()
	for _, player in pairs(ents.GetAllPlayers()) do
		if (player:InCond(65) == true and player:IsAlive() == true and player:InCond(5) == false) then
			if player.m_iClass == 6 or player.m_iClass == 7 then
				if player:GetPlayerItemBySlot(0):GetClassname() == "tf_weapon_rocketlauncher_fireball" then
					player.m_iAmmo[2] = math.max(player.m_iAmmo[2] - 2, 0)
				else
					player.m_iAmmo[2] = math.max(player.m_iAmmo[2] - 10, 0)
				end
			elseif player.m_iClass == 5 then
				if player:GetPlayerItemBySlot(0):GetClassname() == "tf_weapon_crossbow" then
					player.m_iAmmo[2] = math.max(player.m_iAmmo[2] - 1, 0)
				else
					player.m_iAmmo[2] = math.max(player.m_iAmmo[2] - 10, 0)
				end
			else
				player.m_iAmmo[2] = math.max(player.m_iAmmo[2] - 1, 0)
			end
			player.m_iAmmo[3] = math.max(player.m_iAmmo[3] - 1, 0)
			if player.m_iClass == 9 then
				player.m_iAmmo[4] = math.max(player.m_iAmmo[4] - 10, 0)
			end
		end
	end
end, 0)


function OnWaveSpawnBot(bot, wave, tags)
	if tags[3] == "die" then
		timer.Simple(1, function() bot:Suicide() end)
	end
	if bot.m_iClass == 8 and tags[1] == nil then
		ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames2[11] = 'spy'
		--ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[11] = ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[11] + 1
		ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags2[11] = 4
		bot:AddCallback(ON_DEATH, function()
			--ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[11] = ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[11] - 1
			if ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[11] == 0 then
				ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags2[11] = 0
			end
			bot:RemoveAllCallbacks()
		end)
		if SpyDisabled == true then
			bot:AcceptInput('$Suicide')
		end
	end
	if bot.m_iClass == 2 and tags[1] == nil then
		ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames2[10] = 'sniper'
		--ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[10] = ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[10] + 1
		ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags2[10] = 4
		bot:AddCallback(ON_DEATH, function()
			--ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[10] = ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[10] - 1
			if ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[10] == 0 then
				ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags2[10] = 0
			end
			bot:RemoveAllCallbacks()
		end)
	end
	if bot:GetPlayerItemBySlot(2):GetClassname() == "tf_weapon_stickbomb" then
		if KaizoMode == false then
			ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames2[9] = 'sentry_buster'
			--ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[9] = ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[9] + 1
			ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags2[9] = 4
			bot:AddCallback(ON_DEATH, function()
				--ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[9] = ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[9] - 1
				if ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[9] == 0 then
					ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags2[9] = 0
				end
				bot:RemoveAllCallbacks()
			end)
		elseif KaizoMode == true and CurrentWave ~= 5 then
			ents.FindByClass('tf_objective_resource').m_iszMannVsMachineWaveClassNames2[12] = 'sentry_buster'
			ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags2[12] = 4
			bot:AddCallback(ON_DEATH, function()
				if ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts2[12] == 0 then
					ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassFlags2[12] = 0
				end
				bot:RemoveAllCallbacks()
			end)
		end
	end

	if tags[1] == 'ally' and bot.m_iTeamNum == 2 then
		if AiFirstSpawn == false then
			bot:Teleport(Vector(-675, 379, -1200))
			AiFirstSpawn = true
		else
			bot:Teleport(Vector(264, 512, 128))
			bot:SetAttributeValue('CARD: move speed bonus', 3)
			bot:AddCond(32)
			bot:AddCond(6, 18) --non functional
			bot:AddCond(5, 5)
			bot:AddCallback(ON_KEY_PRESSED, function(ent, key) if key == 1 then bot:SetAttributeValue('CARD: move speed bonus', nil) ent:RemoveCond(32) end end)
		end
		util.ParticleEffect("teleportedin_red", bot:GetAbsOrigin())
		util.ParticleEffect("teleported_red", bot:GetAbsOrigin())
		util.ParticleEffect("player_recent_teleport_red", bot:GetAbsOrigin(),_,bot)
		bot:PlaySound('weapons/teleporter_send.wav')
		ents.SpawnTemplate('RedBotParticle', {parent = bot})

		function Equip()
			local timer1 = 0
			local timer2 = 0
			local timer3 = 0
			local timer4 = 0
			bot:AddCallback(ON_DEATH, function()
				if timer1 ~= 0 then
					timer.Stop(timer1)
					timer1 = 0
				end
				if timer2 ~= 0 then
					timer.Stop(timer2)
					timer2 = 0
				end
				if timer3 ~= 0 then
					timer.Stop(timer3)
					timer3 = 0
				end
				if timer4 ~= 0 then
					timer.Stop(timer4)
					timer4 = 0
				end
			end)
			for k = 1, wave - 1 do
				if k == 1 then
					if string.sub((WavesPlayed[k]), 1, 1) == 'r' then
						bot:GiveItem('TF_WEAPON_ROCKETLAUNCHER')
					else
						bot:GiveItem('TF_WEAPON_FLAMETHROWER')
					end
				elseif k == 2 then
					if string.sub((WavesPlayed[k]), 1, 1) == 'r' then
						bot:SetAttributeValue('faster reload rate', 0.1)
					else
						bot:SetAttributeValue('heal on hit for rapidfire', 5)
					end
				elseif k == 3 then
					if string.sub((WavesPlayed[k]), 1, 1) == 'r' then
						timer1 = timer.Create(1, function()
							if bot.m_lifeState == 0 then
								for _, player in pairs(ents.FindInSphere(bot:GetAbsOrigin(), 450)) do
									if player:IsPlayer() and player.m_iTeamNum == 2 then
										player:AddCond(62, 2, bot)
									end
								end
							end
						end, 0)
					else
						timer2 = timer.Create(1, function()
							if bot.m_lifeState == 0 then
								for _, player in pairs(ents.FindInSphere(bot:GetAbsOrigin(), 450)) do
									if player:IsPlayer() and player.m_iTeamNum == 2 then
										player:AddCond(61, 2, bot)
									end
								end
							end
						end, 0)
					end
				elseif k == 4 then
					if string.sub((WavesPlayed[k]), 1, 1) == 'r' then
						bot:SetAttributeValue('add cond on hit', 12)
						bot:SetAttributeValue('add cond on hit duration', 10)
					else
						bot:SetAttributeValue('add cond on hit', 65)
						bot:SetAttributeValue('add cond on hit duration', 3)
					end
				elseif k == 5 then
					if string.sub((WavesPlayed[k]), 1, 1) == 'r' then
						timer3 = timer.Create(1, function()
							if bot.m_lifeState == 0 then
								for _, player in pairs(ents.FindInSphere(bot:GetAbsOrigin(), 450)) do
									if player:IsPlayer() and player.m_iTeamNum == 2 then
										player:AddCond(16, 2, bot)
									end
								end
							end
						end, 0)
					else
						timer4 = timer.Create(1, function()
							if bot.m_lifeState == 0 then
								for _, player in pairs(ents.FindInSphere(bot:GetAbsOrigin(), 450)) do
									if player:IsPlayer() and player.m_iTeamNum == 2 then
										player:AddCond(29, 2, bot)
									end
								end
							end
						end, 0)
					end
				end
			end
		end
		Equip()
	end
end

function OnWaveSpawnTank(tank, wave)
	tank:AddCallback(ON_REMOVE, function()
		local remaining = 0
		if KaizoMode == false then
			if wave == 1 then
				ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[1] = ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[1] - 1
			elseif wave == 2 then
				ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[2] = ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[2] - 1
			elseif wave == 4 or wave == 5 then
				ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[3] = ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[3] - 1
			end
		else
			if wave == 1 then
				ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[4] = ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[4] - 1
			elseif wave == 2 then
				ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[2] = ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[2] - 1
			elseif wave == 4 then
				ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[8] = ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[8] - 1
			elseif wave == 5 then
				ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[3] = ents.FindByClass('tf_objective_resource').m_nMannVsMachineWaveClassCounts[3] - 1
			end
		end
	end)
end

function EnableMirrorMode()
	if MirrorAlreadyVoted == false and VoteActive == true and CurrentWave == 1 then
		for _, player in pairs(ents.GetAllPlayers()) do
			if player:IsRealPlayer() then
				player.VoteChoice = 0
				player.MirrorVoteChoice = 0
				player:PlaySoundToSelf('ui/duel_challenge.wav')
			end
		end
		MirrorVote = true
		MirrorVoteTimerActive = true
		MirrorAlreadyVoted = true
	end
end

function EnableKaizoMode()
	if MirrorAlreadyVoted == false and VoteActive == true and CurrentWave == 1 then
		for _, player in pairs(ents.GetAllPlayers()) do
			if player:IsRealPlayer() then
				player.VoteChoice = 0
				player.KaizoVoteChoice = 0
				player:PlaySoundToSelf('ui/duel_challenge_with_restriction.wav')
			end
		end
		MirrorVote = true
		MirrorVoteTimerActive = true
		MirrorAlreadyVoted = true
		KaizoVote = true
		ExtraVoteTitle = 'Enable Kaizo Mode?\n \nBoth waves will be active at the same time!\nWARNING: This is a long and gruelling challenge\n \n'
	end
end

function TeleportLeft()
	ents.FindByName('spawnbot_left'):Teleport(spawnbot_left)
	ents.FindByName('spawnbot_right'):Teleport(spawnbot_left)
end

function TeleportRight()
	ents.FindByName('spawnbot_left'):Teleport(spawnbot_right)
	ents.FindByName('spawnbot_right'):Teleport(spawnbot_right)
end