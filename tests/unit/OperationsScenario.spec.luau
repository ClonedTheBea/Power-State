--!strict
return function()
	local O = game.ServerScriptService.Server.Operations
	local Scenario = require(O.OperationsScenario); local Country = require(O.OperationsCountry)
	local Solver = require(O.FleetSolver); local Wind = require(O.OperationsWind); local Store = require(O.OperationsStore)
	local Codec = require(O.Parent.Domain.ProfileCodec); local H = game:GetService("HttpService")
	local count = 0
	local function check(v: boolean, message: string) assert(v, message); count += 1 end
	local function encode(v: any): string return Codec.encode(v, function(x) return H:JSONEncode(x) end) end
	for hour, expected in {575, 32, 290, 548, 562} do check(Wind.knot(20, "coastal-training", hour - 1) == expected, "Pinned wind knot") end
	for step = 0, 3000 do
		local output = Wind.potential(20, "coastal-training", step)
		check(output >= 0 and output <= 1600 and output % 1 == 0 and output == Wind.potential(20, "coastal-training", step), "Deterministic bounded integer wind")
	end
	local state = Scenario.new(1, 1); local noAction: any = nil; local rescued: any = nil
	local function advance(s: any): any
		s = Scenario.prepare(s)
		local n = Country.envelope(s).network
		return Country.advance(s, Solver.solve(n, s.step))
	end
	for step = 0, 120 do
		local before = encode(state); local forecast = Scenario.forecast(state)
		check(encode(state) == before and #forecast.samples == 5, "Forecast pure/bounded")
		if step == 0 then check(forecast.samples[5].capacityShortfallKW > 0 and forecast.samples[5].windKW < forecast.samples[1].windKW, "Actionable falling-wind forecast") end
		if step == 60 then
			noAction = advance(state)
			local enabled = Country.control(state, 1, 1, state.countryRevision, "peak", true, 2000)
			rescued = advance(enabled)
			check(noAction.report.unmetKW == 936 and noAction.shortfallSteps > 0, "No-action shortage and reliability consequence")
			check(rescued.report.unmetKW == 0 and rescued.report.sources.peak == 936, "Peaker restores exact served demand")
			check(rescued.ledger.expensesMinor > noAction.ledger.expensesMinor, "Reliability has operating expense")
			state = enabled
		end
		state = advance(state)
		if step == 90 then check(state.report.unmetKW == 500 and state.report.deliveredKW == 5500, "Adequate generation cannot bypass branch constraint") end
	end
	local store = Store.new(); local record = store.acquire(1)
	local saved = Scenario.prepare(record.state)
	for _ = 1, 12 do saved = advance(saved) end
	for _, fault in {"CallbackReplay", "AfterWrite", "BeforeWrite"} do
		store.faults.inject(fault)
		local ok, result = store.save(record, saved, false)
		check(ok and encode(result.state) == encode(saved), "Exact checkpoint reconciliation: " .. fault); record = result
	end
	local ok, released = store.save(record, saved, true); check(ok and not released.active, "Controlled fake release")
	local restored = store.acquire(1)
	check(restored.state.step == saved.step and encode(restored.state.ledger) == encode(saved.ledger), "Reconnect exact finances/no offline time")
	check(encode(restored.state.history) == encode(saved.history) and encode(restored.state.controls) == encode(saved.controls), "Reconnect exact history and controls")
	check(restored.epoch == record.epoch + 1 and Wind.potential(20, Scenario.REGION, restored.state.step) == Wind.potential(20, Scenario.REGION, saved.step), "Fenced reconnect/no wind reroll")
	check(not store.save(record, saved, false), "Stale session cannot overwrite reconnected country")
	check(not pcall(store.acquire, 1), "Duplicate owner rejected")
	store.faults.inject("Unavailable")
	local unchanged = encode(store.faults.inspect("training:1"))
	check(not store.save(restored, restored.state, false), "Ambiguous unavailable checkpoint fails safely")
	check(encode(store.faults.inspect("training:1")) == unchanged, "Failure does not mutate confirmed state")
	check(#encode(state) < 262144 and #state.history == 60, "Bounded training record")
	print("[Operations Scenario] PASS: " .. count .. " assertions; shortage936 kW, peaker936 kW, constrained500 kW; record=" .. #encode(state))
end
