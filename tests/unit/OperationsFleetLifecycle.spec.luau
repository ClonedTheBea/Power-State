--!strict
return function()
	local O = game.ServerScriptService.Server.Operations
	local Scenario = require(O.OperationsScenario); local Country = require(O.OperationsCountry)
	local Batch = require(O.OperationsBatch); local Store = require(O.OperationsStore)
	local Projection = require(O.OperationsProjection)
	local H = game:GetService("HttpService"); local R = game:GetService("RunService")
	local store = Store.new(); local actors: {any} = {}; local count = 0
	local memory = gcinfo(); local prepPeak, cpuPeak, installPeak, savePeak, maxBytes = 0, 0, 0, 0, 0
	local maxSnapshotBytes = 0
	local function check(v: boolean, message: string) assert(v, message); count += 1 end
	for i = 1, 8 do
		local record = store.acquire(1000 + i)
		actors[i] = {ownerId = record.ownerId, epoch = record.epoch, active = true, record = record, nextSequence = 1, controlsRevision = 0,
			state = Country.restore(record.state, record.ownerId, record.epoch)}
	end
	for step = 1, 120 do
		local began = os.clock()
		for _, actor in actors do actor.state = Scenario.prepare(actor.state) end
		local batch = Batch.new(actors)
		prepPeak = math.max(prepPeak, (os.clock() - began) * 1000)
		while not batch.done() do
			R.Heartbeat:Wait(); local m = batch.step()
			cpuPeak = math.max(cpuPeak, m.cpuMs); installPeak = math.max(installPeak, m.installMs)
		end
		for _, actor in actors do
			if actor.status ~= "Completed" or actor.state.step ~= step then
				warn("[Operations lifecycle diagnostic] " .. H:JSONEncode({expectedStep=step,observedStep=actor.state.step,status=actor.status,reason=actor.reason,elapsedMs=(os.clock()-began)*1000,batch=batch.stats()}))
			end
			check(actor.status == "Completed" and actor.state.step == step and actor.state.ledger.cursor == step, "Independent exact fleet progression")
			began = os.clock(); local ok, result = store.save(actor.record, actor.state, false)
			savePeak = math.max(savePeak, (os.clock() - began) * 1000)
			check(ok, "Confirmed whole training checkpoint"); actor.record = result
			maxBytes = math.max(maxBytes, #H:JSONEncode(result))
			maxSnapshotBytes = math.max(maxSnapshotBytes, #H:JSONEncode(Projection.create(actor)))
		end
		check(batch.stats().retained == 0, "No accumulated job state"); batch.close()
	end
	for _, actor in actors do
		local state = actor.state
		local ok = store.save(actor.record, state, true); check(ok, "Release every owner")
		local record = store.acquire(actor.ownerId)
		check(record.state.step == state.step and record.state.ledger.balanceMinor == state.ledger.balanceMinor, "Eight independent reconnects")
	end
	-- Delayed concurrent callback: a later confirmed checkpoint fences the suspended writer.
	local concurrent = Store.new(); local old = concurrent.acquire(99); local firstState = Scenario.prepare(old.state)
	local laterState = Country.control(firstState, 99, old.epoch, firstState.countryRevision, "gas", false, 5000)
	local held = false; local firstOk: any = nil
	concurrent.faults.setHook(function(kind: string)
		if kind == "Update" and not held then held = true; coroutine.yield() end
	end)
	local thread = coroutine.create(function() firstOk = concurrent.save(old, firstState, false) end)
	check(coroutine.resume(thread) and coroutine.status(thread) == "suspended", "Delayed fake callback held")
	local secondOk, confirmed = concurrent.save(old, laterState, false)
	check(secondOk, "Concurrent valid checkpoint wins once")
	check(coroutine.resume(thread) and coroutine.status(thread) == "dead" and firstOk == false, "Stale delayed callback rejected")
	check(concurrent.faults.inspect("training:99").receipt == confirmed.receipt, "No stale overwrite")
	check(maxBytes <= 262144 and store.faults.stats().profiles == 8, "Bounded profiles/size")
	check(maxSnapshotBytes <= 65536, "Bounded public snapshots over complete fleet run")
	print("[Operations Fleet Lifecycle] PASS: " .. count .. " assertions; " .. H:JSONEncode({
		countries = 8, intervals = 120, prepPeakMs = prepPeak, solverPeakMs = cpuPeak, installPeakMs = installPeak,
		fakeSavePeakMs = savePeak, profileBytes = maxBytes, snapshotBytes = maxSnapshotBytes,
		heapDeltaKiB = gcinfo() - memory, storage = store.faults.stats()}))
end
