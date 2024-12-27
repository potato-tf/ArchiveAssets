::PLAYERLOG <-
{
	std =
	{
		[48] = 0,
		[49] = 1,
		[50] = 2
	}
	
	FetchCheck_Think = function()
	{
		if (thinkertick % 66 == 0)
		{
			foreach (player in GetAllPlayers(2, false, false))
			{
				local scope = player.GetScriptScope()
				
				if (scope.fetching) scope.CheckFetchStatus()
			}
		}
	}

	ProgressLog = function()
	{
		local scope = self.GetScriptScope()
		
		local basewavestatus = ""
		
		for (local i = 1; i <= wavecount; i++) basewavestatus += "0"
		
		local wavestatus
		local waveprogress = ""
		
		if (!(!lastfetchresults.wavedata)) wavestatus = lastfetchresults.wavedata

		else wavestatus = basewavestatus

		for (local g = 0; g <= wavestatus.len() - 1; g++)
		{
			if (Wave == secretwave && g == (secretwave - 1) && !secretwave_unlocked)
			{
				waveprogress += std[wavestatus[g]]
				continue
			}
			
			if ((Wave - 1) != g) waveprogress += std[wavestatus[g]]
			
			else
			{
				if (std[wavestatus[g]] == 2)
				{
					waveprogress += std[wavestatus[g]]
					continue
				}
				
				if (wavewon)
				{
					if (std[wavestatus[g]] >= 1) waveprogress += 2
					else						 waveprogress += 0
				}
				
				else waveprogress += 1
			}
		}
		
		lastfetchresults.wavedata = waveprogress

		VPI.AsyncCall(
		{
			func = "VPI_DB_UndeadDread_ReadWrite",
			kwargs =
			{
				query_mode = "write",
				network_id = lastfetchresults.steamid,
				wave_data = waveprogress
			}
		})
	}
	
	IsInLog = function()
	{
		local scope = self.GetScriptScope()
		
		if (!("fetching" in scope))
		{
			scope.fetching <- false
			scope.fetched <- false
			scope.retries <- 1
			
			scope.lastfetchresults <-
			{
				inlog = false
				steamid = false
				wavedata = false
				beatmission = false
				beatsecretwave = false
			}
			
			local id = NetProps.GetPropString(self, "m_szNetworkIDString")
			
			lastfetchresults.steamid = id.slice(5, id.find("]"))
		}
		
		if (!lastfetchresults.steamid) return
		
		if (!lastfetchresults.wavedata)
		{
			if (!fetching)
			{
				fetching = true
				
				VPI.AsyncCall(
				{
					func = "VPI_DB_UndeadDread_ReadWrite",
					
					kwargs = 
					{
						query_mode = "read",
						network_id = lastfetchresults.steamid
					},
					
					callback = function(response, error)
					{
						if (error)
						{
							scope.fetching = false
							
							scope.retries++

							if (scope.retries <= 5) return IsInLog.call(scope)
						}
						
						scope.fetched = true
						scope.retries = 1

						if (typeof(response) != "array" || !response.len()) return

						scope.lastfetchresults.inlog = true

						scope.lastfetchresults.wavedata = response[0][0]
					}
				})
			}
		}
		
		else FetchResult()
	}
	
	CheckFetchStatus = function()
	{
		if (fetched)
		{
			fetching = false
			fetched = false
			FetchResult()
		}
	}
	
	FetchResult = function()
	{
		local scope = self.GetScriptScope()
		
		if (!lastfetchresults.inlog)
		{
			local basewavestatus = ""
			
			for (local i = 1; i <= wavecount; i++) basewavestatus += "0"

			VPI.AsyncCall(
			{
				func = "VPI_DB_UndeadDread_ReadWrite",
				kwargs =
				{
					query_mode = "write",
					network_id = lastfetchresults.steamid
					wave_data = basewavestatus
				}
			})
			
			lastfetchresults.inlog = true
			lastfetchresults.wavedata = basewavestatus
		}
		
		if (lastfetchresults.wavedata[4] == 50) lastfetchresults.beatsecretwave = true
		
		for (local i = 0; i <= lastfetchresults.wavedata.len() - 1; i++)
		{
			if (i == 4) continue

			if (lastfetchresults.wavedata[i] < 50) break

			if (i == 5)
			{
				lastfetchresults.beatmission = true

				if (NetProps.GetPropBool(objective_resource_entity, "m_bMannVsMachineBetweenWaves"))
				{
					DisplayWeaponGallery()
					
					if (!("NewFeaturesTutorial" in scope))
					{
						scope.NewFeaturesTutorial <- function()
						{
							SendGlobalGameEvent("show_annotation", 
							{
								id = self.entindex()
								text = "Congratulations on beating\nthe mission! You now have\naccess to new weapon features!"
								worldPosX = 540
								worldPosY = 5000
								worldPosZ = 0
								visibilityBitfield = (1 << self.entindex())
								play_sound = "misc/null.wav"
								show_distance = false
								show_effect = false
								lifetime = 7.5
							})
							
							NewFeaturesTutorial = null
						}
						
						EntFireByHandle(self, "CallScriptFunction", "NewFeaturesTutorial", 0.1, null, null)
					}
				}
			}
		}
	}
}