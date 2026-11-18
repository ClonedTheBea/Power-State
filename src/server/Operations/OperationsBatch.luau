--!strict
-- One global bounded batch. Host may explicitly retry a failed interval, never catch up.
local Scheduler = require(script.Parent.FleetJobScheduler)
local Country = require(script.Parent.OperationsCountry)
local Batch = {}
function Batch.new(actors: {any}, options: any?): any
	assert(game:GetService("RunService"):IsServer() and game:GetService("RunService"):IsStudio() and game.GameId == 10776833313, "Test server only")
	assert(#actors >= 1 and #actors <= 8, "Eight-country batch bound")
	local config = table.clone(options or {})
	local clock = config.clock or os.clock
	local bindings, records = {}, {}
	local token = table.freeze({})
	local ids = {}; local count = 0
	-- Validate the entire admission list before claiming ANY actor or allocating coroutines.
	for index, actor in actors do
		assert(type(index) == "number" and index % 1 == 0 and index >= 1 and index <= #actors, "Dense actor list")
		count += 1
		assert(actor.job == nil, "No overlapping country job")
		Country.validate(actor.state)
		assert(table.isfrozen(actor.state) and actor.active and actor.ownerId == actor.state.ownerId and actor.epoch == actor.state.epoch, "Active immutable owner required")
		assert(not ids[actor.state.countryId], "Duplicate country"); ids[actor.state.countryId] = true
	end
	assert(count == #actors, "Dense actor count")
	local started = clock()
	config.isCurrent = function(input: any): boolean
		local binding = bindings[input.countryId]
		-- Deep-frozen object identity binds ALL input fields, including owner, costs, cursor and controls.
		return binding ~= nil and binding.actor.active == true and binding.actor.state == binding.base
			and binding.actor.ownerId == binding.base.ownerId and binding.actor.epoch == binding.base.epoch
	end
	local scheduler = Scheduler.new(config)
	for _, actor in actors do
		local base = actor.state
		assert(not bindings[base.countryId], "Duplicate country")
		assert(table.isfrozen(base), "Only immutable country inputs")
		local binding = { actor = actor, base = base }
		bindings[base.countryId] = binding
		actor.job = token
		local ok, result = pcall(function() return scheduler.admit(Country.envelope(base)) end)
		local record: any = { binding = binding, done = not ok }
		if ok then record.handle = result; actor.status = "Pending"
		else actor.status = "Suspended"; actor.reason = tostring(result) end
		table.insert(records, record)
	end
	local api = {}
	local closed = false
	function api.step(): any
		assert(not closed, "Closed batch")
		local metrics = scheduler.step()
		local began = clock()
		for _, record in records do if not record.done then
			local binding, handle = record.binding, record.handle
			local actor, base = binding.actor, binding.base
			local status = scheduler.status(handle)
			if status.state == "ready" then
				local report = scheduler.take(handle)
				local ok, candidate = pcall(function() return Country.advance(base, report) end)
				-- No yield or external call between this final full-state comparison and the ONE pointer swap.
				if ok and config.isCurrent(base) and clock() - started < (config.deadline or .750) then
					actor.state = candidate
					actor.status = "Completed"; actor.reason = nil
				else
					actor.status = "Suspended"
					actor.reason = if not ok then tostring(candidate) else "Calculation expired or inputs changed; retry safely"
				end
				record.done = true
			elseif status.state ~= "pending" then
				actor.status = if status.state == "stale" then "Invalidated" else "Suspended"
				actor.reason = status.state .. ": no interval settled; retry safely"
				record.done = true
			end
		end end
		metrics.installMs = (clock() - began) * 1000
		return metrics
	end
	function api.stats(): any return scheduler.stats() end
	function api.done(): boolean
		for _, record in records do if not record.done then return false end end
		return true
	end
	function api.close()
		if closed then return end
		for _, record in records do
			local actor = record.binding.actor
			if not record.done then actor.status = "Suspended"; actor.reason = "Cancelled; no interval settled" end
			if actor.job == token then actor.job = nil end
		end
		scheduler.close(); table.clear(records); table.clear(bindings); closed = true
	end
	return table.freeze(api)
end
return table.freeze(Batch)
