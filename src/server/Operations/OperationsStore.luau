--!strict
-- Memory-only training checkpoints. No real adapter injection or profile schema migration.
local Fake = require(script.Parent.Parent.Adapters.FakeDataStoreAdapter)
local Country = require(script.Parent.OperationsCountry)
local Scenario = require(script.Parent.OperationsScenario)
local Encoding = require(script.Parent.OperationsEncoding)
local Store = {}
function Store.new(): any
	assert(game:GetService("RunService"):IsStudio() and game.GameId == 10776833313, "Training Test only")
	local adapter = Fake.create()
	local H = game:GetService("HttpService")
	local api = {faults = adapter}
	function api.acquire(ownerId: number): any
		local key = "training:" .. ownerId
		local record = adapter.update(key, function(old: any): any
			if old then
				assert(old.version == 1 and old.ownerId == ownerId and not old.active, "Conflicting training owner")
				Country.validate(old.state)
				assert(old.state.countryId == "operations-training-" .. ownerId, "Training country identity")
			end
			local epoch = if old then old.epoch + 1 else 1
			return {version = 1, ownerId = ownerId, epoch = epoch, revision = if old then old.revision + 1 else 1,
				active = true, receipt = "acquire:" .. epoch,
				state = if old then Country.restore(old.state, ownerId, epoch) else Scenario.new(ownerId, epoch)}
		end)
		return record
	end
	function api.save(record: any, state: any, release: boolean): (boolean, any)
		local encode = Encoding.new(function(value) return H:JSONEncode(value) end)
		Country.validate(state)
		assert(record.ownerId == state.ownerId and record.epoch == state.epoch, "Checkpoint ownership")
		local candidate = {version = 1, ownerId = record.ownerId, epoch = record.epoch, revision = record.revision + 1,
			active = not release, receipt = H:GenerateGUID(false), state = state}
		local expected = encode(record); local exact = encode(candidate); local key = "training:" .. record.ownerId
		-- At most two updates and two reconciliation reads. Retry never recomputes simulation or finance.
		for _ = 1, 2 do
			local ok, result = pcall(adapter.update, key, function(old: any): any
				if old and old.receipt == candidate.receipt then assert(encode(old) == exact, "Receipt collision"); return old end
				assert(old and old.active and encode(old) == expected, "Stale checkpoint/fence")
				return candidate
			end)
			if ok and result and encode(result) == exact then return true, result end
			local readOk, observed = pcall(adapter.read, key)
			if not readOk then return false, "Uncertain training checkpoint; simulation suspended" end
			if observed and encode(observed) == exact then return true, observed end
			if not observed or encode(observed) ~= expected then return false, "Training ownership changed; simulation suspended" end
		end
		return false, "Training checkpoint unavailable; retry safely"
	end
	return table.freeze(api)
end
return table.freeze(Store)
