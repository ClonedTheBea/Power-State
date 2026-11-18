--!strict
local Scenario = require(script.Parent.OperationsScenario)
local Projection = {}
local names = {gas = "Central Gas", wind = "Coastal Wind", peak = "Reserve Peaker"}
function Projection.create(actor: any): any
	local state = actor.state; local report = state.report
	local fleet = {}; local available, headroom = 0, 0
	local alerts = {}
	for _, source in state.network.sources do
		local c = state.controls[source.id]; local output = if report then report.sources[source.id] else 0
		local ready = if c.on then math.min(c.capKW, source.availableKW) else 0
		available += ready
		if source.id ~= "wind" then headroom += math.max(0, ready - output) end
		local capacity = if source.id == "gas" then 5000 else 2000
		local expense = state.ledger.units[source.id]
		table.insert(fleet, {id = source.id, name = names[source.id], installedKW = capacity, availableKW = ready,
			potentialKW = source.availableKW, outputKW = output, capKW = c.capKW, on = c.on,
			variableMinorPerMWh = source.costMinorPerMWh, fixedMinorPerHour = c.fixedMinorPerHour,
			variableExpenseMinor = expense.variableMinor, fixedExpenseMinor = expense.fixedMinor,
			curtailedKW = if source.id == "wind" then math.max(0, source.availableKW - output) else 0})
		if c.on and ready == 0 then table.insert(alerts, names[source.id] .. ": no available output") end
	end
	local demand = if report then report.requestedKW else state.network.sinks[1].requestedKW + state.network.sinks[2].requestedKW
	local delivered = if report then report.deliveredKW else 0
	if report and report.unmetKW > 0 then table.insert(alerts, string.format("Unserved demand: %.3f MW", report.unmetKW / 1000)) end
	if report and state.network.sinks[2].requestedKW > 3000 then table.insert(alerts, "East feeder constrained: 3 MW route. More generators cannot widen this connection.") end
	if headroom < math.max(500, math.ceil(demand / 10)) then table.insert(alerts, "Low dispatchable headroom; review the forecast and peaker.") end
	if actor.status == "Suspended" or actor.status == "Invalidated" then table.insert(alerts, actor.reason or "Calculation unavailable; retry safely") end
	if actor.status == "Pending" then table.insert(alerts, "Calculation pending; previous completed electricity result shown") end
	assert(#alerts <= 8, "Bounded deduplicated alerts")
	if not actor.forecast or state.step - actor.forecast.step >= 15 or actor.forecastControls ~= actor.controlsRevision then
		actor.forecast = Scenario.forecast(state); actor.forecastControls = actor.controlsRevision
	end
	return {version = 1, mode = "Operations", epoch = actor.epoch, revision = state.countryRevision, nextSequence = actor.nextSequence,
		step = state.step, status = actor.status, reason = actor.reason, outcome = actor.outcome or "Ready", fleet = fleet,
		demandKW = demand, deliveredKW = delivered, generatedKW = if report then report.generatedKW else 0,
		unmetKW = if report then report.unmetKW else 0, installedKW = 9000, availableKW = available, headroomKW = headroom,
		reliability = if state.requestedKwMinutes > 0 then state.deliveredKwMinutes / state.requestedKwMinutes else 1,
		bankMinor = state.ledger.balanceMinor, savedBankMinor = actor.record.state.ledger.balanceMinor,
		salesMinor = state.ledger.salesMinor, expensesMinor = state.ledger.expensesMinor,
		forecast = actor.forecast, alerts = alerts, saving = actor.saving == true, saveBlocked = actor.saveBlocked == true,
		flowsKW = if report then report.flowsKW else {}, sinks = if report then report.sinks else {}}
end
return table.freeze(Projection)
