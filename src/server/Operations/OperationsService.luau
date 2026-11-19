--!strict
local Run = game:GetService("RunService")
local Players = game:GetService("Players")
local Http = game:GetService("HttpService")
local Country = require(script.Parent.OperationsCountry)
local Scenario = require(script.Parent.OperationsScenario)
local Batch = require(script.Parent.OperationsBatch)
local Commands = require(script.Parent.OperationsCommands)
local Projection = require(script.Parent.OperationsProjection)
local Store = require(script.Parent.OperationsStore)
local Investment = require(script.Parent.ReinforcementCoordinator)
local Service = {}
local host: any = nil
function Service.start(): any
	assert(Run:IsServer() and Run:IsStudio() and game.GameId == 10776833313, "Operations is isolated fake Test only")
	if host then return host end
	local store = Store.new({reinforcement=true})
	local investment = Investment.new(store, os.clock, function() return Http:GenerateGUID(false) end)
	local actors: {[Player]: any} = {}; local buckets: {[Player]: any} = {}
	local retained: {[number]: boolean} = {}; local retainedCount = 0
	local folder = Instance.new("Folder"); folder.Name = "OperationsTraining"
	local intent = Instance.new("RemoteEvent"); intent.Name = "Intent"; intent.Parent = folder
	local snapshot = Instance.new("RemoteEvent"); snapshot.Name = "Snapshot"; snapshot.Parent = folder
	local batch: any = nil; local nextAt = 0; local delayUntil = 0
	local metrics: any = {intervals = 0, peakSolverMs = 0, peakInstallMs = 0, maxSnapshotBytes = 0, suspended = 0}
	local function send(player: Player, actor: any)
		if player.Parent ~= Players then return end
		local value = Projection.create(actor)
		local size = #Http:JSONEncode(value); assert(size <= 65536, "Training snapshot bound")
		metrics.maxSnapshotBytes = math.max(metrics.maxSnapshotBytes, size)
		snapshot:FireClient(player, value)
	end
	local function checkpoint(player: Player, actor: any, release: boolean)
		if actor.saving or actor.investing then return end
		actor.saving = true
		local captured = actor.state
		task.spawn(function()
			local callOk, ok, result = pcall(store.save, actor.record, captured, release)
			actor.saving = false
			if callOk and ok then
				actor.record = result; actor.saveBlocked = false
				if release and not result.active then
					actors[player] = nil
					if player.Parent == Players then
						player:SetAttribute("OperationsTraining", false)
						snapshot:FireClient(player, {version = 1, mode = "FirstPlayable", outcome = "Released", last = Projection.create(actor)})
					end
				else
					if release then actor.releaseRequested = true end
					send(player, actor)
				end
			else
				actor.saveBlocked = true; actor.status = "Suspended"
				actor.reason = if callOk then tostring(result) else "Training checkpoint failed; no further simulation"
				send(player, actor)
			end
		end)
	end
	local function exit(player: Player)
		local actor = actors[player]
		if not actor then return end
		actor.active = false
		if actor.saving or actor.investing then actor.releaseRequested = true else checkpoint(player, actor, true) end
	end
	local function enter(player: Player)
		local existing = actors[player]
		if existing then send(player, existing); return end
		if not retained[player.UserId] and retainedCount >= 8 then
			snapshot:FireClient(player, {version = 1, mode = "Unavailable", reason = "This Test server retains at most eight training countries."}); return
		end
		local ok, record = pcall(store.acquire, player.UserId)
		if not ok then snapshot:FireClient(player, {version = 1, mode = "Unavailable", reason = "Training ownership unavailable; no country reset."}); return end
		if not retained[player.UserId] then retained[player.UserId] = true; retainedCount += 1 end
		local actor = {state = Country.restore(record.state, player.UserId, record.epoch), record = record, ownerId = player.UserId,
			epoch = record.epoch, active = true, nextSequence = 1, controlsRevision = 0, status = "Accepted"}
		actors[player] = actor; player:SetAttribute("OperationsTraining", true); send(player, actor)
	end
	intent.OnServerEvent:Connect(function(player: Player, payload: any)
		local bucket = buckets[player] or {}; buckets[player] = bucket
		if not Commands.admit(bucket, payload, os.clock()) then return end
		if payload.kind == "Enter" then enter(player); return end
		local actor = actors[player]; if not actor then return end
		if payload.kind == "Exit" then exit(player); return end
		if payload.kind == "Sync" then send(player, actor); return end
		if payload.kind == "Retry" and actor.saveBlocked then
			-- Retry only the captured full checkpoint; never a fresh financial interval.
			if payload.epoch == actor.epoch and payload.revision == actor.state.countryRevision and payload.sequence == actor.nextSequence then
				actor.nextSequence += 1
				if actor.investmentPending then
					task.spawn(function() actor.investmentOutcome = investment.finish(actor); send(player, actor) end)
				else checkpoint(player, actor, not actor.active) end
			end
			return
		end
		local outcome = Commands.apply(actor, player.UserId, payload); actor.outcome = outcome
		if outcome == "Accepted" and payload.kind == "QuoteReinforcement" then
			actor.investmentOutcome = investment.quote(actor)
		elseif outcome == "Accepted" and payload.kind == "ConfirmReinforcement" then
			actor.investmentOutcome = "Saving"
			task.spawn(function()
				local ok, result = pcall(investment.confirm, actor, payload.quoteId)
				actor.investmentOutcome = if ok then result else "Uncertain"
				if not ok then actor.saveBlocked = true; actor.status = "Suspended"; actor.reason = "Investment unavailable; no further mutation" end
				send(player, actor)
			end)
		elseif outcome == "Accepted" then
			actor.controlsRevision += 1
			if payload.kind == "Control" then checkpoint(player, actor, false) end
		end
		send(player, actor)
	end)
	Players.PlayerRemoving:Connect(function(player) exit(player); buckets[player] = nil end)
	Run.Heartbeat:Connect(function()
		local now = os.clock()
		for player, actor in actors do
			if actor.releaseRequested and not actor.saving and not actor.investing then actor.releaseRequested = false; checkpoint(player, actor, true) end
		end
		if batch then
			if now < delayUntil then return end
			local ok, result = pcall(batch.step)
			if not ok then
				batch.close(); batch = nil
				for player, actor in actors do actor.status = "Suspended"; actor.reason = "Calculation unavailable; retry safely"; send(player, actor) end
				return
			end
			metrics.peakSolverMs = math.max(metrics.peakSolverMs, result.cpuMs)
			metrics.peakInstallMs = math.max(metrics.peakInstallMs, result.installMs)
			if batch.done() then
				batch.close(); batch = nil
				for player, actor in actors do
					if actor.status == "Completed" and actor.active and not actor.investing then checkpoint(player, actor, false)
					elseif actor.status == "Suspended" then metrics.suspended += 1 end
					send(player, actor)
				end
			end
		elseif now >= nextAt then
			nextAt = now + 1 -- Never accumulate missed time or run a catch-up burst.
			local ready = {}
			for player, actor in actors do
				if actor.record.version == 2 and actor.record.leaseUntil - now <= 30 then
					actor.saveBlocked = true; actor.status = "Suspended"; actor.reason = "Training lease safety expired; no further simulation"
				end
				if actor.active and not actor.saving and not actor.investing and not actor.saveBlocked and actor.status ~= "Suspended" then
					local ok, value = pcall(Scenario.prepare, actor.state)
					if ok then actor.state = value; table.insert(ready, actor)
					else actor.status = "Suspended"; actor.reason = "Scenario inputs unavailable"; send(player, actor) end
				end
			end
			if #ready > 0 then
				table.sort(ready, function(a, b) return a.ownerId < b.ownerId end)
				local ok, value = pcall(Batch.new, ready)
				if ok then batch = value; metrics.intervals += 1
				else for _, actor in ready do actor.status = "Suspended"; actor.reason = "Admission unavailable; retry safely" end end
				for player, actor in actors do if actor.active then send(player, actor) end end
			else
				-- A suspended simulation is still a healthy connection. Keep Retry reachable
				-- without advancing physics, finance or storage; at most one status per second.
				for player, actor in actors do send(player, actor) end
			end
		end
	end)
	folder.Parent = game.ReplicatedStorage
	host = {inspect = function(player: Player) return actors[player] end, storage = store, metrics = metrics,
		delay = function(seconds: number) assert(seconds >= 0 and seconds <= 2); delayUntil = os.clock() + seconds end,
		connect = enter, disconnect = exit}
	return host
end
return table.freeze(Service)
