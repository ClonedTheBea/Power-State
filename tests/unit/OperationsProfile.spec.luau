--!strict
-- Bounded lifecycle timings; os.clock includes GC/host scheduling, not an OS CPU counter.
return function(label: string?)
	local O = game.ServerScriptService.Server.Operations
	local Country = require(O.OperationsCountry); local Scenario = require(O.OperationsScenario)
	local Batch = require(O.OperationsBatch); local Store = require(O.OperationsStore)
	local Projection = require(O.OperationsProjection)
	local Codec = require(game.ServerScriptService.Server.Domain.ProfileCodec)
	local H = game:GetService("HttpService"); local R = game:GetService("RunService")
	local samples: {[string]: {number}} = {}; local heap = {}; local totals = {}; local assertions = 0
	local function add(name: string, value: number)
		if not samples[name] then samples[name] = {} end
		table.insert(samples[name], value)
	end
	local function timed(name: string, callback: () -> any): any
		local at = os.clock(); local value = callback(); add(name, (os.clock() - at) * 1000); return value
	end
	for round = 1, 3 do
		local store = Store.new(); local actors: {any} = {}; local start = os.clock(); local memory = gcinfo()
		for i = 1, 8 do
			local record = store.acquire(2000 + i)
			actors[i] = {ownerId = record.ownerId, epoch = record.epoch, active = true, record = record,
				nextSequence = 1, controlsRevision = 0, state = Country.restore(record.state, record.ownerId, record.epoch)}
		end
		for step = 1, 120 do
			local interval = os.clock(); local active = 0; local at = os.clock()
			timed("prepare8", function() for _, a in actors do a.state = Scenario.prepare(a.state) end; return nil end)
			local batch = timed("admit8", function() return Batch.new(actors) end)
			active += os.clock() - at
			while not batch.done() do
				R.Heartbeat:Wait(); at = os.clock(); local m = batch.step(); active += os.clock() - at
				add("solverSlice", m.cpuMs); add("install8", m.installMs)
			end
			at = os.clock()
			timed("checkpoint8", function()
				for _, a in actors do
					assert(a.status == "Completed" and a.state.step == step and a.state.ledger.cursor == step); assertions += 1
					local ok, record = store.save(a.record, a.state, false); assert(ok); assertions += 1; a.record = record
				end
				return nil
			end)
			timed("projectionEncode8", function() for _, a in actors do assert(#H:JSONEncode(Projection.create(a)) <= 65536) end; return nil end)
			timed("cleanup8", function() assert(batch.stats().retained == 0); batch.close(); return nil end)
			active += os.clock() - at
			add("activeLifecycle8", active * 1000); add("elapsedLifecycle8", (os.clock() - interval) * 1000)
			-- Separate instrumentation, deliberately excluded from lifecycle timing.
			timed("validate8", function() for _, a in actors do Country.validate(a.state) end; return nil end)
			timed("copy8", function() for _, a in actors do Codec.copy(a.state) end; return nil end)
			timed("canonicalEncode8", function() for _, a in actors do Codec.encode(a.record, function(v) return H:JSONEncode(v) end) end; return nil end)
			if step % 15 == 0 then table.insert(heap, gcinfo()) end
		end
		for _, a in actors do local ok = store.save(a.record, a.state, true); assert(ok) end
		table.insert(totals, {elapsedMs = (os.clock() - start) * 1000, heapDeltaKiB = gcinfo() - memory, storage = store.faults.stats()})
	end
	local summary = {}
	for name, values in samples do
		table.sort(values); local sum = 0; for _, v in values do sum += v end
		summary[name] = {n = #values, p50 = values[math.ceil(#values * .5)], p95 = values[math.ceil(#values * .95)], worst = values[#values], totalMs = sum}
	end
	local result = {label = label or "unspecified", phases = summary, rounds = totals, heapKiB = heap, assertions = assertions}
	for name, values in summary do print("[Operations V11 phase] " .. H:JSONEncode({label = label or "unspecified", phase = name, values = values})) end
	print("[Operations V11 lifecycle] " .. H:JSONEncode({label = label or "unspecified", rounds = totals, heapKiB = heap, assertions = assertions})); return result
end
