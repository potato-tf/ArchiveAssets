timer.Create(1, function()

	
	
	ents.AddCreateCallback('math_remap', function(ent) 
		timer.Create(0.1, function() 
			--print(ent.m_vecOrigin)
			local initialvecorigin = ent.m_vecOrigin
			local initialentityname = ent:GetName()
			local anglestouse = Vector(0,0,0)
			if(initialentityname == "alternativefiremathtarget_0") then
				anglestouse = Vector(0,0,0)
			elseif(initialentityname == "alternativefiremathtarget_45") then
				anglestouse = Vector(0,45,0)
			elseif(initialentityname == "alternativefiremathtarget_90") then
				anglestouse = Vector(0,90,0)
			elseif(initialentityname == "alternativefiremathtarget_135") then
				anglestouse = Vector(0,135,0)
			elseif(initialentityname == "alternativefiremathtarget_180") then
				anglestouse = Vector(0,180,0)
			elseif(initialentityname == "alternativefiremathtarget_225") then
				anglestouse = Vector(0,225,0)
			elseif(initialentityname == "alternativefiremathtarget_270") then
				anglestouse = Vector(0,270,0)
			elseif(initialentityname == "alternativefiremathtarget_315") then
				anglestouse = Vector(0,315,0)
			end
			local TraceStraight = {
				start = initialvecorigin, -- Start position vector. Can also be set to entity, in this case the trace will start from entity eyes position
				endpos = nil, -- End position vector. If nil, the trace will be fired in `angles` direction with `distance` length
				distance = 150, -- Used if endpos is nil
				angles = anglestouse, -- Used if endpos is nil
				mask = MASK_SOLID, -- Solid type mask, see MASK_* globals
				collisiongroup = COLLISION_GROUP_DEBRIS, -- Pretend the trace to be fired by an entity belonging to this group. See COLLISION_GROUP_* globals
				mins = Vector(0,0,0), -- Extends the size of the trace in negative direction
				maxs = Vector(0,0,0), -- Extends the size of the trace in positive direction
				filter = nil -- Entity to ignore. Can be a single entity, table of entities, or a function with a single entity parameter
			}
			local TraceDownwards = {
				start = initialvecorigin, -- Start position vector. Can also be set to entity, in this case the trace will start from entity eyes position
				endpos = nil, -- End position vector. If nil, the trace will be fired in `angles` direction with `distance` length
				distance = 8192, -- Used if endpos is nil
				angles = Vector(90,0,0), -- Used if endpos is nil
				mask = MASK_SOLID, -- Solid type mask, see MASK_* globals
				collisiongroup = COLLISION_GROUP_DEBRIS, -- Pretend the trace to be fired by an entity belonging to this group. See COLLISION_GROUP_* globals
				mins = Vector(0,0,0), -- Extends the size of the trace in negative direction
				maxs = Vector(0,0,0), -- Extends the size of the trace in positive direction
				filter = nil -- Entity to ignore. Can be a single entity, table of entities, or a function with a single entity parameter
			}
			local straightTraceTable = util.Trace(TraceStraight)
			local downTraceTable = util.Trace(TraceDownwards)
			
			local creationtarget = Entity("math_colorblend", true)
			local entitymaker = ents.FindByName("individualfiremaker_900dps")
			creationtarget:SetName("putfirehere"..creationtarget:GetHandleIndex())
			--print(creationtarget:GetHandleIndex())
			if(downTraceTable["HitSky"] == false and downTraceTable["Hit"] == true) then
				creationtarget:SetAbsOrigin(downTraceTable["HitPos"])
			end
			timer.Create(0.1, function()
				--print("found math remap")
				if(downTraceTable["HitSky"] == false and downTraceTable["Hit"] == true) then
					entitymaker:AcceptInput("ForceSpawnAtEntityOrigin", creationtarget:GetName())
				end
				if(straightTraceTable["Hit"] == false) then
					local remaptoloop = Entity("math_remap", true)
					remaptoloop:SetName(initialentityname)
					remaptoloop:SetAbsOrigin(straightTraceTable["HitPos"])
				end
				--ent:SetAbsOrigin(downTraceTable["HitPos"])
				creationtarget:Remove()
				ent:Remove()
			end, 1)
		end, 1)
	end)
	
	--glboaasdfj = 0
	
	ents.AddCreateCallback('tf_projectile_pipe_remote', function(stickyent) 
		
		
		timer.Create(0.015, function() 
		
		--print(stickyent.isbosssticky)
			if(stickyent.isbosssticky == 1) then --only the boss fires stickies in this mission
				loopingtimer = timer.Create(0.015, function() 

					if IsValid(stickyent) == false then
						timer.Stop(loopingtimer)
						return
					end
					local entstosearch = ents.FindInSphere(stickyent.m_vecOrigin, 196)
					for entitytocheck, entitytocheck2 in pairs(entstosearch) do
						if(entitytocheck2.m_iClassname == 'tf_projectile_mechanicalarmorb') then
							--print("found smth")
							
							
							local scdeniedrelay = ents.FindByName("nukestickies_scdeniedrelay")
							scdeniedrelay:AcceptInput("Trigger")
							entitytocheck2:Remove()
						end
					end
				end, 600)
			end
		
		end, 1)
		
	end)
	
end, 1)