--!strict
-- Isolated training ledger, not a persistent profile schema or a migration.
local Model = require(script.Parent.FleetNetworkModel)
local Codec = require(script.Parent.Parent.Domain.ProfileCodec)
local Ledger = { VERSION = 1, DENOMINATOR = 60000, SALE = 12000, LIMIT = 1000000000000000 }
local function amount(meter: number, rate: number): (number, number)
	local part = (meter % 60000) * rate
	return math.floor(meter / 60000) * rate + math.floor(part / 60000), part % 60000
end
function Ledger.open(openingMinor: number, network: any): any
	Model.integer(openingMinor, 0, Ledger.LIMIT)
	local units = {}
	for _, source in network.sources do
		units[source.id] = { generatedKwMinutes = 0, onlineSteps = 0, variableMinor = 0, variableCarry = 0, fixedMinor = 0, fixedCarry = 0 }
	end
	return { version = 1, openingMinor = openingMinor, balanceMinor = openingMinor, cursor = 0,
		deliveredKwMinutes = 0, salesMinor = 0, salesCarry = 0, expensesMinor = 0, units = units }
end
function Ledger.validate(ledger: any, network: any, controls: any, step: number)
	assert((ledger.version == 1 or ledger.version == 2) and ledger.cursor == step, "Training ledger version/cursor")
	Model.integer(step, 0, 1000000000)
	Model.integer(ledger.openingMinor, 0, Ledger.LIMIT)
	Model.integer(ledger.balanceMinor, 0, Ledger.LIMIT)
	Model.integer(ledger.deliveredKwMinutes, 0, step * 100000)
	local sales, carry = amount(ledger.deliveredKwMinutes, Ledger.SALE)
	assert(ledger.salesMinor == sales and ledger.salesCarry == carry, "Sales meter/carry")
	local generated, expenses, count = 0, 0, 0
	for _ in ledger.units do count += 1 end
	assert(count == #network.sources, "Unit ledger membership")
	for _, source in network.sources do
		local unit, control = ledger.units[source.id], controls[source.id]
		assert(unit and control and control.costVersion == 1, "Pinned unit cost record")
		Model.integer(unit.onlineSteps, 0, step)
		Model.integer(unit.generatedKwMinutes, 0, unit.onlineSteps * 100000)
		local variable, variableCarry = amount(unit.generatedKwMinutes, source.costMinorPerMWh)
		local fixed, fixedCarry = amount(unit.onlineSteps * 1000, control.fixedMinorPerHour)
		assert(unit.variableMinor == variable and unit.variableCarry == variableCarry, "Unit variable meter/carry")
		assert(unit.fixedMinor == fixed and unit.fixedCarry == fixedCarry, "Unit fixed meter/carry")
		generated += unit.generatedKwMinutes
		expenses += variable + fixed
	end
	assert(generated == ledger.deliveredKwMinutes, "Lossless energy and paid meters")
	assert(ledger.expensesMinor == expenses and expenses <= Ledger.LIMIT and sales <= Ledger.LIMIT, "Expense sum/bounds")
	local capital = if ledger.version == 2 then ledger.capitalExpenseMinor else 0
	Model.integer(capital, 0, Ledger.LIMIT)
	assert(ledger.version ~= 1 or ledger.capitalExpenseMinor == nil, "Legacy ledger has no capital")
	assert(ledger.balanceMinor == ledger.openingMinor + sales - expenses - capital, "Bank conservation")
end
function Ledger.reservation(ledger: any, network: any, controls: any): number
	local total = 0
	for _, source in network.sources do
		local control, unit = controls[source.id], ledger.units[source.id]
		if control.on then
			local available = math.min(source.availableKW, control.capKW)
			total += math.floor((unit.variableCarry + available * source.costMinorPerMWh) / 60000)
			total += math.floor((unit.fixedCarry + control.fixedMinorPerHour * 1000) / 60000)
		end
	end
	return total
end
function Ledger.settle(ledger: any, network: any, controls: any, report: any, step: number): any
	Ledger.validate(ledger, network, controls, step)
	assert(ledger.balanceMinor >= Ledger.reservation(ledger, network, controls), "Operating funds unavailable")
	local nextLedger = Codec.copy(ledger)
	local generated = 0
	for _, source in network.sources do
		local control, unit = controls[source.id], nextLedger.units[source.id]
		local output = report.sources[source.id]
		Model.integer(output, 0, if control.on then math.min(source.availableKW, control.capKW) else 0)
		unit.generatedKwMinutes += output
		unit.onlineSteps += if control.on then 1 else 0
		unit.variableMinor, unit.variableCarry = amount(unit.generatedKwMinutes, source.costMinorPerMWh)
		unit.fixedMinor, unit.fixedCarry = amount(unit.onlineSteps * 1000, control.fixedMinorPerHour)
		generated += output
	end
	assert(generated == report.generatedKW and generated == report.deliveredKW, "Settled physical conservation")
	nextLedger.cursor += 1
	nextLedger.deliveredKwMinutes += generated
	nextLedger.salesMinor, nextLedger.salesCarry = amount(nextLedger.deliveredKwMinutes, Ledger.SALE)
	nextLedger.expensesMinor = 0
	for _, unit in nextLedger.units do nextLedger.expensesMinor += unit.variableMinor + unit.fixedMinor end
	nextLedger.balanceMinor = nextLedger.openingMinor + nextLedger.salesMinor - nextLedger.expensesMinor - (nextLedger.capitalExpenseMinor or 0)
	Ledger.validate(nextLedger, network, controls, step + 1)
	return nextLedger
end
return table.freeze(Ledger)
