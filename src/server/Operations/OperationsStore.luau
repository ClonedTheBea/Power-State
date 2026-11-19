--!strict
-- Memory-only training checkpoints. No real adapter injection or profile schema migration.
local Fake = require(script.Parent.Parent.Adapters.FakeDataStoreAdapter)
local Country = require(script.Parent.OperationsCountry)
local Scenario = require(script.Parent.OperationsScenario)
local Encoding = require(script.Parent.OperationsEncoding)
local Store = {}
local function validateRecord(record: any)
	assert(type(record) == "table" and (record.version == 1 or record.version == 2), "Training record version")
	Country.validate(record.state)
	assert(record.version == record.state.version and record.ownerId == record.state.ownerId and record.epoch == record.state.epoch, "Record/state ownership and version")
	assert(type(record.active) == "boolean" and type(record.receipt) == "string" and #record.receipt > 0 and #record.receipt <= 64, "Record receipt")
	assert(type(record.revision) == "number" and record.revision % 1 == 0 and record.revision >= 1 and record.revision < 1000000000, "Record revision")
	if record.version == 2 then
		assert(type(record.leaseUntil) == "number" and record.leaseUntil >= 0 and record.leaseUntil < math.huge, "Fake lease clock")
	else assert(record.leaseUntil == nil, "Legacy record lease version") end
end
function Store.new(options: any?): any
	assert(game:GetService("RunService"):IsStudio() and game.GameId == 10776833313, "Training Test only")
	local config = options or {}
	local adapter = config.adapter or Fake.create()
	assert(adapter.mode == "Fake", "Only memory fake storage permitted")
	local clock = config.clock or os.clock
	local pending: {[string]: any} = {}
	local running: {[string]: boolean} = {}
	local calls = 0
	local H = game:GetService("HttpService")
	local api = {faults = adapter}
	function api.acquire(ownerId: number): any
		local key = "training:" .. ownerId
		assert(not pending[key] and not running[key], "Unresolved transaction")
		local record = adapter.update(key, function(old: any): any
			if old then
				validateRecord(old)
				assert((old.version == 1 or old.version == 2) and old.ownerId == ownerId and not old.active, "Conflicting training owner")
				Country.validate(old.state)
				assert(old.state.countryId == "operations-training-" .. ownerId, "Training country identity")
			end
			local epoch = if old then old.epoch + 1 else 1
			local state = if old then Country.restore(old.state, ownerId, epoch) else Scenario.new(ownerId, epoch)
			if config.reinforcement then state = Country.convert(state) end
			return {version = state.version, ownerId = ownerId, epoch = epoch, revision = if old then old.revision + 1 else 1,
				leaseUntil = if state.version == 2 then clock() + 180 else nil,
				active = true, receipt = "acquire:" .. epoch,
				state = state}
		end)
		return record
	end
	function api.prepare(record: any, state: any, release: boolean, operationId: string): any
		validateRecord(record)
		Country.validate(record.state); Country.validate(state)
		assert(record.ownerId == state.ownerId and record.epoch == state.epoch and record.state.countryId == state.countryId, "Checkpoint ownership")
		assert(record.active and state.countryRevision >= record.state.countryRevision, "Active monotonic checkpoint")
		assert(record.version == state.version, "Conversion only during acquisition")
		assert(state.version ~= 2 or record.leaseUntil - clock() > 30, "Lease safety margin")
		local encode = Encoding.new(function(value) return H:JSONEncode(value) end)
		assert(state.step >= record.state.step, "No simulation rollback")
		if record.state.version == 2 and record.state.investments.serial == 1 then
			assert(encode(state.investments) == encode(record.state.investments), "Permanent investment cannot be removed or replaced")
		end
		local candidate = {version = state.version, ownerId = record.ownerId, epoch = record.epoch, revision = record.revision + 1,
			active = not release, receipt = operationId, state = state,
			leaseUntil = if state.version == 2 then (if release then 0 else clock() + 180) else nil}
		local expected, exact = encode(record), encode(candidate)
		assert(#exact <= 192 * 1024, "Training checkpoint soft size limit")
		return {key = "training:" .. record.ownerId, base = record, candidate = candidate,
			expected = expected, exact = exact, encode = encode, started = clock(), attempts = 0}
	end
	function api.commit(prepared: any): (boolean, any)
		local key = prepared.key
		local serialized = prepared.candidate.version == 2
		-- Retain the legacy v1 compare-and-swap race fixture; v2 adds the investment barrier.
		if calls >= 4 or (serialized and (running[key] or (pending[key] and pending[key] ~= prepared))) then return false, "Busy" end
		if serialized then pending[key] = prepared; running[key] = true end
		calls += 1
		local function execute(): (boolean, any)
			-- Bounded retries of the SAME immutable candidate. No arithmetic or effects in callback.
			for _ = 1, 2 do
				if prepared.attempts >= 5 then return false, "Uncertain" end
				prepared.attempts += 1
				local ok, result = pcall(adapter.update, key, function(old: any): any
					if old and old.receipt == prepared.candidate.receipt then
						assert(prepared.encode(old) == prepared.exact, "Receipt collision"); return old
					end
					assert(clock() - prepared.started <= 30, "Transaction observation limit")
					assert(old and old.active and prepared.encode(old) == prepared.expected, "Stale checkpoint/fence")
					assert(old.version ~= 2 or old.leaseUntil - clock() > 30, "Expired lease safety")
					return prepared.candidate
				end)
				if ok and result and prepared.encode(result) == prepared.exact then
					Country.validate(result.state); pending[key] = nil; return true, result
				end
				local readOk, observed = pcall(adapter.read, key)
				if not readOk then return false, "Uncertain" end
				if observed and prepared.encode(observed) == prepared.exact then
					Country.validate(observed.state); pending[key] = nil; return true, observed
				end
				if not observed or prepared.encode(observed) ~= prepared.expected then return false, "OwnershipChanged" end
				if clock() - prepared.started > 30 or (observed.version == 2 and observed.leaseUntil - clock() <= 30) then return false, "LeaseUnsafe" end
			end
			-- Positively observed unchanged head. No irreversible mutation occurred.
			pending[key] = nil; return false, "Unavailable"
		end
		local called, ok, result = pcall(execute)
		running[key] = nil; calls -= 1
		if not called then return false, "Uncertain" end
		return ok, result
	end
	function api.save(record: any, state: any, release: boolean): (boolean, any)
		local key = "training:" .. record.ownerId
		local existing = pending[key]
		if existing then
			if existing.isCheckpoint and existing.encode(record) == existing.expected
				and existing.encode(state) == existing.encode(existing.candidate.state) then
				return api.commit(existing)
			end
			return false, "Unresolved transaction; simulation suspended"
		end
		local prepared = api.prepare(record, state, release, H:GenerateGUID(false))
		prepared.isCheckpoint = true
		return api.commit(prepared)
	end

	return table.freeze(api)
end
return table.freeze(Store)
