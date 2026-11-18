--!strict
return function()
	local O = game.ServerScriptService.Server.Operations
	local Country = require(O.OperationsCountry); local Batch = require(O.OperationsBatch)
	local Solver = require(script.Parent.FleetStage1C.FleetSolver); local W = require(script.Parent.FleetWorkloads)
	local Codec = require(O.Parent.Domain.ProfileCodec); local H = game:GetService("HttpService")
	local R = game:GetService("RunService")
	local function encode(v: any): string return Codec.encode(v, function(x) return H:JSONEncode(x) end) end
	local failures = 0; local safeFailures = 0
	for _, cadence in {0, 30, 15} do for round = 1, 3 do
		for _, name in {"small", "intermediate", "maximum", "adversarial", "independent", "islands", "equalCost"} do
			local actors: {any} = {}; local expected, originals = {}, {}
			for i = 1, 8 do
				local n = W[name](); local controls = {}
				for _, source in n.sources do
					local cap = 0; for _, node in n.nodes do if node.id == source.nodeId then cap = node.capacityKW end end
					controls[source.id] = {on = true, capKW = cap, costVersion = 1, fixedMinorPerHour = 1000}
				end
				local state = Country.new("schedule" .. i, i, 1, n, controls, 100000)
				originals[i] = state
				expected[i] = encode(Country.advance(state, Solver.solve(Country.envelope(state).network, state.step)))
				actors[i] = {state = state, active = true, ownerId = i, epoch = 1}
			end
			local order = {}; for offset = 1, 8 do table.insert(order, actors[(offset + round - 2) % 8 + 1]) end
			local memory = gcinfo(); local began = os.clock(); local batch = Batch.new(order)
			local elapsedCadence, peak, installPeak, overshoot = 0, 0, 0, 0
			while not batch.done() and os.clock() - began < 2 do
				elapsedCadence += R.Heartbeat:Wait()
				if cadence == 0 or elapsedCadence >= 1 / cadence then
					elapsedCadence = 0; local m = batch.step()
					peak = math.max(peak, m.cpuMs); installPeak = math.max(installPeak, m.installMs)
					overshoot = math.max(overshoot, m.overshootMs)
				end
			end
			local elapsed = (os.clock() - began) * 1000; local stats = batch.stats(); local completed = 0
			for i, actor in actors do
				if actor.status == "Completed" then
					assert(encode(actor.state) == expected[i], "Exact scheduled physical/financial installation")
					completed += 1
				else assert(actor.state == originals[i] and actor.reason ~= nil, "Failure changes no physics, reliability, cursor or Bank"); safeFailures += 1 end
			end
			assert(batch.done() and stats.retained == 0 and stats.pending == 0, "Bounded terminal cleanup")
			if cadence ~= 15 and (completed ~= 8 or elapsed > 750 or stats.cpuMs > 80) then failures += 1 end
			print("[Operations Schedule] " .. H:JSONEncode({cadenceHz = cadence, round = round, workload = name,
				cpuMs = stats.cpuMs, peakMs = peak, installPeakMs = installPeak, elapsedMs = elapsed, overshootMs = overshoot,
				completed = completed, retained = stats.retained, maxQueue = stats.maxQueue, heapDeltaKiB = gcinfo() - memory}))
			batch.close(); for _, actor in actors do assert(actor.job == nil, "Owner token released") end
		end
	end end
	assert(failures == 0, "Native/30 Hz provisional scheduling acceptance failed: " .. failures .. " intervals")
	print("[Operations Schedule] PASS: 63 eight-country intervals; safely suspended countries=" .. safeFailures)
end
