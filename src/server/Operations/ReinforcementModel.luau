--!strict
-- Cosmetic presentation never supplies these ratings or purchase values.
local Codec = require(script.Parent.Parent.Domain.ProfileCodec)
local Model = {PROJECT = "east-feeder-reinforcement-v1", PRICE = 50000, BUFFER = 25000}
local function exactKeys(value: any, allowed: any)
	assert(type(value) == "table", "Investment table")
	for key in value do assert(allowed[key], "Unexpected investment field") end
	for key in allowed do assert(value[key] ~= nil, "Missing investment field") end
end
function Model.line(network: any): any
	local found = nil
	for _, line in network.lines do if line.id == "sb" then assert(not found, "Duplicate East line"); found = line end end
	assert(found and found.from == "sub" and found.to == "b" and found.connected == true, "Surveyed East route")
	return found
end
function Model.empty(): any
	return {version = 1, serial = 0, receipts = {}, overrides = {}}
end
function Model.validate(state: any)
	if state.version == 1 then
		assert(state.ledger.version == 1 and state.investments == nil and state.compositionVersion == nil, "Mixed legacy investment version")
		return
	end
	assert(state.version == 2 and state.compositionVersion == 2 and state.ledger.version == 2, "Investment versions")
	local investment = state.investments
	exactKeys(investment, {version=true, serial=true, receipts=true, overrides=true})
	assert(investment.version == 1, "Investment contract")
	local line = Model.line(state.network)
	if investment.serial == 0 then
		assert(next(investment.receipts) == nil and next(investment.overrides) == nil, "Empty investment state")
		assert(line.capacityKW == 3000 and state.ledger.capitalExpenseMinor == 0 and state.topologyRevision == 1, "Unbuilt topology/capital")
	else
		assert(investment.serial == 1 and state.topologyRevision == 2, "One reinforcement")
		exactKeys(investment.receipts, {[Model.PROJECT]=true})
		exactKeys(investment.overrides, {sb=true})
		local overlay, receipt = investment.overrides.sb, investment.receipts[Model.PROJECT]
		exactKeys(overlay, {project=true, version=true, baseKW=true, capacityKW=true})
		assert(overlay.project == Model.PROJECT and overlay.version == 1 and overlay.baseKW == 3000 and overlay.capacityKW == 4000, "Exact overlay")
		exactKeys(receipt, {project=true, version=true, countryId=true, operationId=true, priceMinor=true, lineId=true, baseTopology=true, topologyRevision=true, countryRevision=true, step=true})
		assert(receipt.project == Model.PROJECT and receipt.version == 1 and receipt.countryId == state.countryId and receipt.lineId == "sb", "Permanent purchase identity")
		assert(type(receipt.operationId) == "string" and #receipt.operationId > 0 and #receipt.operationId <= 64, "Purchase operation")
		assert(receipt.priceMinor == Model.PRICE and receipt.baseTopology == 1 and receipt.topologyRevision == 2, "Permanent capital receipt")
		assert(type(receipt.step) == "number" and receipt.step % 1 == 0 and receipt.step >= 0 and receipt.step <= state.step, "Purchase cursor")
		assert(type(receipt.countryRevision) == "number" and receipt.countryRevision % 1 == 0 and receipt.countryRevision >= 1 and receipt.countryRevision <= state.countryRevision, "Purchase revision")
		assert(line.capacityKW == 4000 and state.ledger.capitalExpenseMinor == Model.PRICE, "Atomic rating and capital")
	end
end
function Model.convert(state: any): any
	local candidate = Codec.copy(state)
	if state.version == 2 then Model.validate(candidate); return candidate end
	Model.validate(state)
	assert(Model.line(state.network).capacityKW == 3000 and state.topologyRevision == 1, "Eligible original training route")
	candidate.version = 2; candidate.compositionVersion = 2
	candidate.investments = Model.empty()
	candidate.ledger.version = 2; candidate.ledger.capitalExpenseMinor = 0
	Model.validate(candidate)
	return candidate
end
function Model.compose(state: any, base: any): any
	if state.version == 1 then return base end
	Model.validate(state)
	local network = Codec.copy(base)
	local line = Model.line(network)
	assert(line.capacityKW == 3000, "Immutable original topology required")
	if state.investments.serial == 1 then line.capacityKW = 4000 end
	return network
end
function Model.purchase(state: any, operationId: string, reservation: number): any
	Model.validate(state)
	assert(state.version == 2 and state.investments.serial == 0, "Already reinforced or unsupported")
	assert(state.ledger.balanceMinor >= Model.PRICE + math.max(Model.BUFFER, reservation), "Insufficient funds")
	local candidate = Codec.copy(state)
	candidate.countryRevision += 1; candidate.topologyRevision += 1
	candidate.ledger.balanceMinor -= Model.PRICE; candidate.ledger.capitalExpenseMinor = Model.PRICE
	candidate.investments.serial = 1
	candidate.investments.overrides.sb = {project=Model.PROJECT, version=1, baseKW=3000, capacityKW=4000}
	candidate.investments.receipts[Model.PROJECT] = {project=Model.PROJECT, version=1, countryId=state.countryId,
		operationId=operationId, priceMinor=Model.PRICE, lineId="sb", baseTopology=1, topologyRevision=2,
		countryRevision=candidate.countryRevision, step=state.step}
	Model.line(candidate.network).capacityKW = 4000
	Model.validate(candidate)
	return candidate
end
return table.freeze(Model)
