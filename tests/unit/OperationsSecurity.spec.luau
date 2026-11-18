--!strict
return function()
	local O = game.ServerScriptService.Server.Operations
	local Commands = require(O.OperationsCommands); local Scenario = require(O.OperationsScenario)
	local Projection = require(O.OperationsProjection)
	local count = 0
	local function check(v: boolean, message: string) assert(v, message); count += 1 end
	local function command(): any return {version = 1, kind = "Control", epoch = 1, revision = 0, sequence = 1, sourceId = "gas", on = true, capKW = 4900} end
	for _, key in {"version", "kind", "epoch", "revision", "sequence", "sourceId", "on", "capKW"} do
		local c = command(); c[key] = nil; check(not Commands.admit({}, c, 0), "Missing command field")
	end
	for _, value in {-1, 0/0, math.huge, 100.5, 1e20} do
		local c = command(); c.capKW = value; check(not Commands.admit({}, c, 0), "Malformed bounded number")
	end
	local malformed: {any} = {false, "bad", {}, {version = 1, kind = "Control", ownerId = 2}, {version = 1, kind = "Enter", bank = 1000000}}
	for _, value in malformed do
		check(not Commands.admit({}, value, 0), "Malformed or unauthorized fields")
	end
	local bucket = {}; local admitted = 0
	for _ = 1, 10000 do if Commands.admit(bucket, command(), 0) then admitted += 1 end end
	check(admitted == 6, "Bounded six-command burst against spam")
	check(Commands.admit(bucket, command(), 1), "Rate recovery")
	local state = Scenario.new(1, 1)
	local actor: any = {active = true, ownerId = 1, epoch = 1, nextSequence = 1, state = state, record = {state = state}, status = "Accepted", controlsRevision = 0}
	check(Commands.apply(actor, 2, command()) == "Unauthorized" and actor.state == state, "No cross-player control")
	local stale = command(); stale.epoch = 2
	check(Commands.apply(actor, 1, stale) == "StaleSession" and actor.state == state, "No cross-session control")
	local unknown = command(); unknown.sourceId = "foreign"
	check(Commands.apply(actor, 1, unknown) == "InvalidControl" and actor.state == state, "Unknown source rejected")
	local valid = command(); valid.sequence = actor.nextSequence
	check(Commands.apply(actor, 1, valid) == "Accepted" and actor.state.controls.gas.capKW == 4900, "Validated server cap")
	local changed = actor.state
	check(Commands.apply(actor, 1, valid) == "ReplayRejected" and actor.state == changed, "Command replay rejected")
	local c = command(); c.sequence = actor.nextSequence
	check(Commands.apply(actor, 1, c) == "StaleRevision", "Stale revision rejected")
	c.sequence = actor.nextSequence; c.revision = actor.state.countryRevision; actor.saving = true
	check(Commands.apply(actor, 1, c) == "CheckpointUnavailable" and actor.state == changed, "No conflicting checkpoint mutation")
	actor.saving = false; actor.saveBlocked = true; c.sequence = actor.nextSequence
	check(Commands.apply(actor, 1, c) == "CheckpointUnavailable", "No mutation during unresolved save")
	actor.saveBlocked = false
	for _, cap in {1, 5100} do c.sequence = actor.nextSequence; c.capKW = cap; check(Commands.apply(actor, 1, c) == "InvalidControl", "Cap step and installed rating") end
	for _ = 1, 100 do
		local view = Projection.create(actor)
		check(#view.alerts <= 8 and #view.forecast.samples == 5 and #view.fleet == 3, "Bounded projection")
		check(view.ownerId == nil and view.ledger == nil and view.receipt == nil and view.seed == nil, "No private country/storage fields")
	end
	check(actor.state.step == 0 and actor.state.ledger.balanceMinor == 100000, "Controls/forecasts never bill")
	print("[Operations Security] PASS: " .. count .. " assertions")
end
