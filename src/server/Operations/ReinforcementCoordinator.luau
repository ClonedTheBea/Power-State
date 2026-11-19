--!strict
-- Fake transactional coordinator. A pending candidate survives ambiguous responses unchanged.
local Country = require(script.Parent.OperationsCountry)
local Model = require(script.Parent.ReinforcementModel)
local Ledger = require(script.Parent.OperationsLedger)
local Coordinator = {}
function Coordinator.new(store: any, clock: () -> number, newId: () -> string): any
	local api = {}
	local function eligible(actor: any): string?
		if not actor.active or actor.ownerId ~= actor.state.ownerId or actor.epoch ~= actor.state.epoch then return "Unauthorized" end
		if actor.state.version ~= 2 then return "Unsupported" end
		if actor.state.investments.serial == 1 then return "AlreadyReinforced" end
		if actor.saving or actor.saveBlocked or actor.investing then return "Unavailable" end
		if actor.record.leaseUntil - clock() <= 30 then return "LeaseUnsafe" end
		local required = Model.PRICE + math.max(Model.BUFFER, Ledger.reservation(actor.state.ledger, actor.state.network, actor.state.controls))
		if actor.state.ledger.balanceMinor < required then return "InsufficientFunds" end
		return nil
	end
	function api.quote(actor: any): string
		local problem = eligible(actor)
		if problem then actor.quote = nil; return problem end
		Country.validate(actor.state)
		actor.quote = {id = newId(), operationId = newId(), expires = clock() + 30,
			ownerId = actor.ownerId, countryId = actor.state.countryId, epoch = actor.epoch,
			topologyRevision = actor.state.topologyRevision, priceMinor = Model.PRICE}
		return "Quoted"
	end
	function api.finish(actor: any): string
		local prepared = actor.investmentPending
		if not prepared then return "Unavailable" end
		if actor.investmentRunning then return "Saving" end
		actor.investmentRunning = true
		local ok, result = store.commit(prepared)
		actor.investmentRunning = false
		if ok then
			-- Full result equality is checked by storage; freeze the returned state before exposing it.
			Country.validate(result.state)
			assert(result.state.ownerId == actor.ownerId and result.epoch == actor.epoch, "Committed owner")
			actor.record = result; actor.state = Country.convert(result.state)
			actor.investmentPending = nil; actor.investing = false; actor.saveBlocked = false
			actor.forecast = nil; actor.status = "Accepted"; actor.reason = nil
			if result.leaseUntil - clock() <= 30 then
				actor.saveBlocked = true; actor.status = "Suspended"
				actor.reason = "Purchase confirmed, but session lease is unsafe; gameplay remains suspended."
			end
			return "Confirmed"
		elseif result == "Unavailable" then
			actor.investmentPending = nil; actor.investing = false
			actor.status = "Accepted"; return "Unavailable"
		end
		actor.status = "Suspended"; actor.reason = "Investment outcome unresolved; no simulation or further purchase."
		actor.saveBlocked = true
		return "Uncertain"
	end
	function api.confirm(actor: any, quoteId: string): string
		if actor.investmentPending then return "Saving" end
		local problem = eligible(actor); if problem then return problem end
		local quote = actor.quote
		if not quote or quote.id ~= quoteId then return "InvalidQuote" end
		if clock() >= quote.expires then actor.quote = nil; return "QuoteExpired" end
		if quote.ownerId ~= actor.ownerId or quote.countryId ~= actor.state.countryId or quote.epoch ~= actor.epoch
			or quote.topologyRevision ~= actor.state.topologyRevision or quote.priceMinor ~= Model.PRICE then return "StaleQuote" end
		local candidate = Country.invest(actor.state, quote.operationId)
		local prepared = store.prepare(actor.record, candidate, false, quote.operationId)
		-- No yield between capture and barrier. Scheduler revalidates this barrier before installation.
		actor.quote = nil; actor.investing = true; actor.investmentPending = prepared; actor.status = "SavingInvestment"
		return api.finish(actor)
	end
	return table.freeze(api)
end
return table.freeze(Coordinator)
