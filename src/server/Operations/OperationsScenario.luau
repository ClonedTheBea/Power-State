--!strict
local Investment = require(script.Parent.ReinforcementModel)
local Country = require(script.Parent.OperationsCountry)
local Wind = require(script.Parent.OperationsWind)
local Model = require(script.Parent.FleetNetworkModel)
local Scenario = {VERSION = 1, SEED = 20, REGION = "coastal-training"}
function Scenario.demand(step: number): (number, number)
	Model.integer(step, 0, 1000000060)
	local phase = step % 240
	local total = if phase <= 60 then 3000 + phase * 50 elseif phase <= 120 then 6000
		elseif phase <= 180 then 6000 - (phase - 120) * 50 else 3000
	-- Late peak moves demand behind a fixed 3 MW branch, demonstrating stranded generation.
	local b = if phase >= 90 and phase <= 120 then 3500 else math.floor(total / 2)
	return total - b, b
end
function Scenario.network(step: number): any
	local a, b = Scenario.demand(step)
	local nodes = {
		{id = "gas", kind = "Generator", capacityKW = 5000}, {id = "wind", kind = "Generator", capacityKW = 2000},
		{id = "peak", kind = "Generator", capacityKW = 2000}, {id = "sub", kind = "Substation", capacityKW = 10000},
		{id = "a", kind = "Demand", capacityKW = 6000}, {id = "b", kind = "Demand", capacityKW = 6000},
	}
	local lines = {
		{id = "gs", from = "gas", to = "sub", capacityKW = 5000, connected = true},
		{id = "ws", from = "wind", to = "sub", capacityKW = 2000, connected = true},
		{id = "ps", from = "peak", to = "sub", capacityKW = 2000, connected = true},
		{id = "sa", from = "sub", to = "a", capacityKW = 6000, connected = true},
		{id = "sb", from = "sub", to = "b", capacityKW = 3000, connected = true},
	}
	return {version = 1, nodes = nodes, lines = lines,
		sources = {{id = "gas", nodeId = "gas", availableKW = 5000, costMinorPerMWh = 8000},
			{id = "wind", nodeId = "wind", availableKW = Wind.potential(Scenario.SEED, Scenario.REGION, step), costMinorPerMWh = 0},
			{id = "peak", nodeId = "peak", availableKW = 2000, costMinorPerMWh = 11000}},
		sinks = {{id = "a", nodeId = "a", requestedKW = a}, {id = "b", nodeId = "b", requestedKW = b}}}
end
function Scenario.new(ownerId: number, epoch: number): any
	return Country.new("operations-training-" .. ownerId, ownerId, epoch, Scenario.network(0), {
		gas = {on = true, capKW = 5000, fixedMinorPerHour = 1000, costVersion = 1},
		wind = {on = true, capKW = 2000, fixedMinorPerHour = 600, costVersion = 1},
		peak = {on = false, capKW = 2000, fixedMinorPerHour = 200, costVersion = 1},
	}, 100000)
end
function Scenario.prepare(state: any): any
	return Country.inputs(state, Investment.compose(state, Scenario.network(state.step)), {scenarioVersion = 1, windVersion = 1, seed = Scenario.SEED, region = Scenario.REGION})
end
function Scenario.forecast(state: any): any
	local samples = {}
	for _, offset in {0, 15, 30, 45, 60} do
		local step = state.step + offset; local n = Scenario.network(step)
		local available = 0
		for _, source in n.sources do local c = state.controls[source.id]; if c.on then available += math.min(c.capKW, source.availableKW) end end
		local demand = n.sinks[1].requestedKW + n.sinks[2].requestedKW
		table.insert(samples, {offset = offset, demandKW = demand, windKW = n.sources[2].availableKW,
			availableKW = available, capacityShortfallKW = math.max(0, demand - available), branchLimited = n.sinks[2].requestedKW > (if state.version == 2 and state.investments.serial == 1 then 4000 else 3000)})
	end
	return {step = state.step, conditional = true, approximateRouting = true, samples = samples}
end
return table.freeze(Scenario)
