--!strict
-- Immutable server-owned training state. Never accepted from a remote or real profile.
local Model = require(script.Parent.FleetNetworkModel)
local Snapshot = require(script.Parent.FleetJobSnapshot)
local Ledger = require(script.Parent.OperationsLedger)
local Codec = require(script.Parent.Parent.Domain.ProfileCodec)
local Country = {}
local function freeze(value: any): any
	if type(value) == "table" and not table.isfrozen(value) then
		for _, child in value do freeze(child) end
		table.freeze(value)
	end
	return value
end
function Country.validate(state: any)
	assert(state.version == 1 and state.inputVersion == 1, "Training state version")
	Model.integer(state.ownerId, -9007199254740991, 9007199254740991)
	assert(state.ownerId ~= 0, "Nonzero owner")
	if state.ownerId < 0 then
		assert(game:GetService("RunService"):IsStudio() and game.GameId == 10776833313, "Local Studio Test identities only")
	end
	Model.integer(state.epoch, 1, 1000000000)
	Model.integer(state.step, 0, 1000000000)
	Model.integer(state.countryRevision, state.step, 1000000000)
	Model.integer(state.topologyRevision, 1, 1000000000)
	assert(type(state.countryId) == "string" and #state.countryId > 0 and #state.countryId <= 64, "Country identity")
	Model.validate(state.network)
	local count = 0
	for _ in state.controls do count += 1 end
	assert(count == #state.network.sources, "Control membership")
	for _, source in state.network.sources do
		local control = state.controls[source.id]
		assert(control and type(control.on) == "boolean" and control.costVersion == 1, "Source controls")
		Model.integer(control.capKW, 0, 100000)
		local capacity = 0
		for _, node in state.network.nodes do if node.id == source.nodeId then capacity = node.capacityKW end end
		assert(control.capKW <= capacity and control.capKW % 100 == 0, "Installed cap bound/increments")
		Model.integer(control.fixedMinorPerHour, 0, 1000000)
	end
	Model.integer(state.requestedKwMinutes, 0, state.step * 100000)
	Model.integer(state.deliveredKwMinutes, 0, state.requestedKwMinutes)
	Model.integer(state.shortfallSteps, 0, state.step)
	assert(#state.history <= 60, "Bounded reliability history")
	Ledger.validate(state.ledger, state.network, state.controls, state.step)
	assert(state.deliveredKwMinutes == state.ledger.deliveredKwMinutes, "Physical and financial cursor/meter")
end
function Country.new(countryId: string, ownerId: number, epoch: number, network: any, controls: any, openingMinor: number): any
	local state = { version = 1, inputVersion = 1, countryId = countryId, ownerId = ownerId, epoch = epoch,
		step = 0, countryRevision = 0, topologyRevision = 1, network = Codec.copy(network), controls = Codec.copy(controls),
		requestedKwMinutes = 0, deliveredKwMinutes = 0, shortfallSteps = 0, history = {},
		ledger = Ledger.open(openingMinor, network) }
	Country.validate(state)
	return freeze(state)
end
function Country.envelope(state: any): any
	Country.validate(state)
	assert(state.ledger.balanceMinor >= Ledger.reservation(state.ledger, state.network, state.controls), "Operating funds unavailable")
	local network = Codec.copy(state.network)
	for _, source in network.sources do
		local control = state.controls[source.id]
		source.availableKW = if control.on then math.min(source.availableKW, control.capKW) else 0
	end
	return Snapshot.copy({ countryId = state.countryId, epoch = state.epoch, step = state.step,
		countryRevision = state.countryRevision, topologyRevision = state.topologyRevision, network = network })
end
function Country.inputs(state: any, network: any, recipe: any): any
	-- Trusted scenario preparation only. Topology and prices cannot be changed by this operation.
	Model.validate(network)
	local function equal(a: any, b: any): boolean
		for k, v in a do
			if type(v) == "table" then
				if type(b[k]) ~= "table" or not equal(v, b[k]) then return false end
			elseif b[k] ~= v then return false end
		end
		for k in b do if a[k] == nil then return false end end
		return true
	end
	assert(equal(state.network.nodes, network.nodes) and equal(state.network.lines, network.lines), "Scenario cannot change topology")
	assert(#network.sources == #state.network.sources and #network.sinks == #state.network.sinks, "Stable terminals")
	for i, source in network.sources do
		local old = state.network.sources[i]
		assert(source.id == old.id and source.nodeId == old.nodeId and source.costMinorPerMWh == old.costMinorPerMWh, "Stable source identity/cost")
	end
	for i, sink in network.sinks do assert(sink.id == state.network.sinks[i].id and sink.nodeId == state.network.sinks[i].nodeId, "Stable customer identity") end
	if state.recipe then assert(equal(state.recipe, recipe), "No recipe/seed reroll") end
	local nextState = Codec.copy(state)
	nextState.network = Codec.copy(network); nextState.recipe = Codec.copy(recipe)
	nextState.countryRevision += 1
	Country.validate(nextState)
	return freeze(nextState)
end
function Country.restore(state: any, ownerId: number, epoch: number): any
	Country.validate(state)
	assert(state.ownerId == ownerId, "Training owner mismatch")
	local nextState = Codec.copy(state); nextState.epoch = epoch; nextState.countryRevision += 1
	Country.validate(nextState)
	return freeze(nextState)
end
function Country.control(state: any, ownerId: number, epoch: number, revision: number, sourceId: string, on: boolean, capKW: number): any
	assert(ownerId == state.ownerId and epoch == state.epoch and revision == state.countryRevision, "Stale or unauthorized command")
	assert(type(on) == "boolean" and type(sourceId) == "string" and state.controls[sourceId], "Invalid source command")
	Model.integer(capKW, 0, 100000)
	assert(capKW % 100 == 0, "Caps use 100 kW increments")
	local capacity = 0
	for _, source in state.network.sources do if source.id == sourceId then
		for _, node in state.network.nodes do if node.id == source.nodeId then capacity = node.capacityKW end end
	end end
	assert(capKW <= capacity, "Cap exceeds installed capacity")
	local nextState = Codec.copy(state)
	nextState.controls[sourceId].on = on
	nextState.controls[sourceId].capKW = capKW
	nextState.countryRevision += 1
	Country.validate(nextState)
	return freeze(nextState)
end
function Country.advance(state: any, report: any): any
	-- Called only with a single-use server scheduler result. Preparing never mutates the live state.
	Country.validate(state)
	local requested, delivered = 0, 0
	for _, sink in state.network.sinks do
		local result = report.sinks[sink.id]
		assert(result and result.requestedKW == sink.requestedKW, "Bound demand identity")
		Model.integer(result.deliveredKW, 0, sink.requestedKW)
		assert(result.unmetKW == sink.requestedKW - result.deliveredKW, "Unmet demand")
		requested += sink.requestedKW
		delivered += result.deliveredKW
	end
	assert(report.requestedKW == requested and report.deliveredKW == delivered and report.unmetKW == requested - delivered, "Physical report totals")
	local nextState = Codec.copy(state)
	nextState.ledger = Ledger.settle(state.ledger, state.network, state.controls, report, state.step)
	nextState.step += 1
	nextState.countryRevision += 1
	nextState.requestedKwMinutes += requested
	nextState.deliveredKwMinutes += delivered
	nextState.shortfallSteps += if delivered < requested then 1 else 0
	nextState.report = Codec.copy(report)
	table.insert(nextState.history, { step = nextState.step, requestedKW = requested, deliveredKW = delivered })
	if #nextState.history > 60 then table.remove(nextState.history, 1) end
	Country.validate(nextState)
	return freeze(nextState)
end
return table.freeze(Country)
