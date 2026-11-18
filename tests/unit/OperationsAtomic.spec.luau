--!strict
return function()
	local S = game.ServerScriptService.Server
	local Country = require(S.Operations.OperationsCountry)
	local Ledger = require(S.Operations.OperationsLedger)
	local Batch = require(S.Operations.OperationsBatch)
	local Solver = require(S.Operations.FleetSolver)
	local W = require(script.Parent.FleetWorkloads)
	local Codec = require(S.Domain.ProfileCodec)
	local H = game:GetService("HttpService")
	local count = 0
	local function check(value: boolean, message: string) assert(value, message); count += 1 end
	local function encode(value: any): string return Codec.encode(value, function(v) return H:JSONEncode(v) end) end
	local function actor(id: number?, network: any?, money: number?): any
		local n = network or W.small(); local controls = {}
		for _, source in n.sources do
			local capacity = 0; for _, node in n.nodes do if node.id == source.nodeId then capacity = node.capacityKW end end
			controls[source.id] = { on = true, capKW = capacity, costVersion = 1,
				fixedMinorPerHour = if source.id == "gas" then 1000 elseif source.id == "wind" then 600 else 200 }
		end
		return { active = true, ownerId = id or 1, epoch = 1, state = Country.new("c" .. (id or 1), id or 1, 1, n, controls, money or 100000) }
	end
	local function drain(batch: any)
		for _ = 1, 1000 do if batch.done() then return end; batch.step() end
		error("Bounded batch drain")
	end
	local a = actor(); local before = a.state; local beforeJson = encode(before)
	check(not pcall(Batch.new, {a, a}) and a.job == nil, "Malformed batch acquires no partial ownership")
	local expected = Country.advance(before, Solver.solve(Country.envelope(before).network, before.step))
	local b = Batch.new({a}); check(not pcall(Batch.new, {a}), "Overlapping batch rejected")
	drain(b)
	check(a.status == "Completed" and encode(a.state) == encode(expected), "Atomic scheduled equals synchronous full physical/financial candidate")
	check(encode(before) == beforeJson, "Captured input never mutated")
	local committed = a.state
	b.step(); check(a.state == committed and committed.step == 1 and committed.ledger.cursor == 1, "No duplicate settlement")
	check(b.stats().retained == 0, "Consumed solver resources released"); b.close(); check(a.job == nil, "Batch ownership released")
	check(committed.report.generatedKW == 5200 and committed.report.unmetKW == 800, "Approved shortage case")
	check(committed.shortfallSteps == 1 and committed.deliveredKwMinutes == 5200, "Reliability and meter committed together")
	check(committed.ledger.balanceMinor == 100345 and committed.ledger.units.gas.variableCarry == 40000 and committed.ledger.units.gas.fixedCarry == 40000 and committed.ledger.units.peak.fixedCarry == 20000, "Independent first-minute fractional reference")
	local off = Country.control(committed, 1, 1, committed.countryRevision, "gas", false, 5000)
	local afterOff = Country.advance(off, Solver.solve(Country.envelope(off).network, off.step))
	check(afterOff.ledger.units.gas.variableCarry == 40000 and afterOff.ledger.units.gas.fixedCarry == 40000 and afterOff.ledger.units.gas.onlineSteps == 1, "Off interval preserves exact carried liabilities without new gas cost")
	-- Full frozen-object binding, not merely the five scheduler envelope stamps.
	for _, change in {"ownerId", "epoch", "step", "countryRevision", "topologyRevision", "cursor", "cost", "cap", "demand", "availability", "bank", "leave"} do
		local target = actor(nil, W.independent()); local original = target.state; local originalJson = encode(original)
		local batch = Batch.new({target}, {sliceBudget = 0}); batch.step()
		check(target.state == original and not batch.done(), "Invalidation fixture is genuinely pending")
		if change == "leave" then target.active = false
		elseif change == "ownerId" then target.ownerId = 2
		elseif change == "epoch" then target.epoch = 2
		else
			local altered = Codec.copy(original)
			if change == "cursor" then altered.ledger.cursor += 1
			elseif change == "cost" then altered.controls.g1.costVersion += 1
			elseif change == "cap" then altered.controls.g1.capKW = 100
			elseif change == "demand" then altered.network.sinks[1].requestedKW += 1
			elseif change == "availability" then altered.network.sources[1].availableKW -= 1
			elseif change == "bank" then altered.ledger.balanceMinor += 1
			else altered[change] += 1 end
			target.state = table.freeze(altered)
		end
		local retained = target.state; drain(batch)
		check(target.state == retained and target.status == "Invalidated", "Stale full identity rejected: " .. change)
		check(encode(original) == originalJson, "Invalidation settles no original state: " .. change)
		batch.close()
	end
	a = actor(); before = a.state; b = Batch.new({a}, {sliceBudget = 0})
	a.state = Country.control(a.state, 1, 1, 0, "gas", false, 5000)
	drain(b); check(a.state.step == 0 and a.state.countryRevision == 1 and a.status == "Invalidated", "Accepted command cancels interval without finance")
	b.close(); b = Batch.new({a}); drain(b); check(a.state.step == 1 and a.state.report.sources.gas == 0, "Explicit retry settles latest controls once"); b.close()
	for _, cap in {-100, 100.5, 0/0, math.huge, 5100} do
		check(not pcall(Country.control, a.state, 1, 1, a.state.countryRevision, "gas", true, cap), "Invalid cap rejected")
	end
	check(not pcall(Country.control, a.state, 2, 1, a.state.countryRevision, "gas", true, 5000), "Foreign owner rejected")
	check(not pcall(Country.control, a.state, 1, 1, 0, "gas", true, 5000), "Stale command replay rejected")
	for _, failure in {"deadline", "cpu", "work", "cancel"} do
		local time = 0; local target = actor(); local original = target.state
		local options: any = { clock = function() return time end, sliceBudget = 0 }
		if failure == "work" then options.operationLimit = 1 end
		local batch = Batch.new({target}, options)
		if failure == "cancel" then batch.close()
		else
			if failure == "deadline" then time = 1 end
			if failure == "cpu" then options = nil; batch.close(); batch = Batch.new({target}, {cpuLimit = 0.000000001}) end
			drain(batch); check(batch.stats().retained == 0, "Failure releases solver: " .. failure); batch.close()
		end
		check(target.state == original and target.status == "Suspended" and target.reason ~= nil, "Failure preserves all state: " .. failure)
	end
	local poor = actor(nil, nil, 0); local empty = poor.state
	b = Batch.new({poor}); drain(b); check(poor.state == empty and poor.status == "Suspended", "No credit against expected revenue"); b.close()
	for _, source in poor.state.network.sources do poor.state = Country.control(poor.state, 1, 1, poor.state.countryRevision, source.id, false, 0) end
	b = Batch.new({poor}); drain(b); check(poor.status == "Completed" and poor.state.ledger.balanceMinor == 0, "Unfunded configuration can recover without grant"); b.close()
	-- Independently calculated one-hour meters: 5 MW gas, .2 MW wind, ready peaker.
	a = actor()
	for _ = 1, 60 do b = Batch.new({a}); drain(b); b.close() end
	local ledger = a.state.ledger
	check(ledger.salesMinor == 62400 and ledger.units.gas.variableMinor == 40000, "One-hour exact sales and gas")
	check(ledger.units.gas.fixedMinor == 1000 and ledger.units.wind.fixedMinor == 600 and ledger.units.peak.fixedMinor == 200, "Each On fixed cost once")
	check(ledger.expensesMinor == 41800 and ledger.balanceMinor == 120600, "No fleet expense double rounding")
	check(ledger.salesCarry == 0 and ledger.units.gas.variableCarry == 0 and ledger.units.peak.fixedCarry == 0, "Exact carried hour accounting")
	check(#a.state.history == 60 and #encode(a.state) < 262144, "History and record byte bounds")
	Ledger.validate(ledger, a.state.network, a.state.controls, a.state.step)
	for cycle = 1, 32 do
		local actors = {}; for i = 1, 8 do actors[i] = actor(i, W.independent()) end
		b = Batch.new(actors, {sliceBudget = 0}); b.step(); b.close()
		for _, target in actors do check(target.state.step == 0 and target.job == nil, "Eight-country cancellation releases ownership") end
	end
	print("[Operations Atomic] PASS: " .. count .. " assertions; one-hour Bank " .. ledger.balanceMinor .. " minor; state " .. #encode(a.state) .. " bytes")
end
