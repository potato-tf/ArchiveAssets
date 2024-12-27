// by ficool2

if ("TraceFilter_trace" in getroottable())
	return;

::World <- ::Entities.FindByClassname(null, "worldspawn");

::TraceFilter_trace <- null;
::TraceFilter_function <- null;
::TraceFilter_entities <- [];
::TraceFilter_entity_mins <- [];
::TraceFilter_entity_maxs <- [];

// do not change
::TRACE_STOP <- 0;
::TRACE_OK_STOP <- 1;
::TRACE_CONTINUE <- 2;
::TRACE_OK_CONTINUE <- 3;

::TraceFilterRecurse <- function(trace)
{
	local entity = trace.enthit;
	TraceFilter_entities.append(entity);
	TraceFilter_entity_mins.append(entity.GetBoundingMins());
	TraceFilter_entity_maxs.append(entity.GetBoundingMaxs());
	entity.SetSize(Vector(), Vector());
	
	delete trace.enthit;
	TraceFilter_function(trace);
	
	if ("enthit" in trace)
	{
		local new_entity = trace.enthit;
		if (new_entity == World) // currently, world always blocks
			return;
		if (new_entity == entity) // this should not happen
			return;
		if (trace.filter(new_entity) == TRACE_STOP)
			return;
		TraceFilterRecurse(trace);
	}
}

::TraceGatherRecurse <- function(trace)
{
	local entity = trace.enthit;
	
	delete trace.enthit;
	TraceFilter_function(trace);
	
	if ("enthit" in trace)
	{
		local new_entity = trace.enthit;
		if (new_entity == World) // currently, world always blocks
			return;
		if (new_entity == entity) // this should not happen
			return;	
		local result = trace.filter(new_entity);
		if (result & 1) // accepted result?
		{
			local hit = clone(trace);
			hit.pos = trace.pos + Vector();
			hit.startpos = trace.startpos + Vector();
			hit.endpos = trace.endpos + Vector();
			hit.plane_normal = trace.plane_normal + Vector();
			TraceFilter_trace.hits.append(hit);
		}
		if (result < 2) // stop?
			return;
			
		TraceFilter_entities.append(new_entity);
		TraceFilter_entity_mins.append(new_entity.GetBoundingMins());
		TraceFilter_entity_maxs.append(new_entity.GetBoundingMaxs());
		new_entity.SetSize(Vector(), Vector());
			
		TraceGatherRecurse(trace);
	}
}

::TraceFilter <- function(trace)
{
	TraceFilter_function(trace);
	
	if ("enthit" in trace)
	{
		// early out
		if (trace.filter(trace.enthit) == TRACE_STOP)
			return trace;
		
		TraceFilter_entities.clear();
		TraceFilter_entity_mins.clear();
		TraceFilter_entity_maxs.clear();
		
		TraceFilterRecurse(trace);
		
		foreach (i, entity in TraceFilter_entities)
			entity.SetSize(TraceFilter_entity_mins[i], TraceFilter_entity_maxs[i]);
	}
}

::TraceGather <- function(trace)
{
	TraceFilter_entities.clear();
	TraceFilter_entity_mins.clear();
	TraceFilter_entity_maxs.clear();
	TraceFilter_trace = trace;
	
	trace.enthit <- null;
	trace.hits <- [];
	TraceGatherRecurse(trace);

	foreach (i, entity in TraceFilter_entities)
		entity.SetSize(TraceFilter_entity_mins[i], TraceFilter_entity_maxs[i]);
}

::TraceLineFilter <- function(trace)
{
	TraceFilter_function = TraceLineEx;
	TraceFilter(trace);
}

::TraceHullFilter <- function(trace)
{
	TraceFilter_function = TraceHull;
	TraceFilter(trace);
}

::TraceLineGather <- function(trace)
{
	TraceFilter_function = TraceLineEx;
	TraceGather(trace);
}

::TraceHullGather <- function(trace)
{
	TraceFilter_function = TraceHull;
	TraceGather(trace);
}


