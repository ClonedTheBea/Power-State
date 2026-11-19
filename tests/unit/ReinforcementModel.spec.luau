--!strict
return function()
	local O = game.ServerScriptService.Server.Operations
	local C = require(O.OperationsCountry); local S = require(O.OperationsScenario)
	local I = require(O.ReinforcementModel); local Solver = require(O.FleetSolver)
	local Codec = require(O.Parent.Domain.ProfileCodec)
	local H = game:GetService("HttpService")
	local function encode(v: any): string return Codec.encode(v, function(x) return H:JSONEncode(x) end) end
	local count = 0
	local function check(ok: boolean, message: string) assert(ok, message); count += 1 end
	local state = S.new(1, 1)
	state = C.control(state, 1, 1, state.countryRevision, "peak", true, 2000)
	for _ = 1, 100 do
		state = S.prepare(state); state = C.advance(state, Solver.solve(C.envelope(state).network, state.step))
	end
	local original = encode(state); local converted = C.convert(state)
	local reverse = Codec.copy(converted)
	reverse.version = 1; reverse.compositionVersion = nil; reverse.investments = nil
	reverse.ledger.version = 1; reverse.ledger.capitalExpenseMinor = nil
	check(encode(reverse) == original, "Every historical field preserved")
	check(encode(state) == original and encode(C.convert(converted)) == encode(converted), "Pure idempotent conversion")
	check(converted.investments.serial == 0 and converted.ledger.capitalExpenseMinor == 0, "No free construction or debit")
	for _, field in {"version", "compositionVersion"} do
		local bad = Codec.copy(converted); bad[field] = 99
		check(not pcall(C.validate, bad), "Reject unsupported version")
	end
	local bad = Codec.copy(converted); table.insert(bad.network.lines, Codec.copy(bad.network.lines[5]))
	check(not pcall(C.validate, bad), "Unique topology references")
	local built = C.invest(converted, "pure-model-proof")
	check(built.ledger.balanceMinor == converted.ledger.balanceMinor - 50000, "Exact capital deduction")
	check(built.step == converted.step and encode(built.history) == encode(converted.history), "No historical electricity change")
	for _, field in {"salesMinor", "expensesMinor", "salesCarry", "cursor", "units"} do
		check(encode(built.ledger[field]) == encode(converted.ledger[field]), "Financial prefix preserved")
	end
	for step = 1, 240 do
		local a = S.prepare(converted); local b = S.prepare(built)
		check(I.line(a.network).capacityKW == 3000 and I.line(b.network).capacityKW == 4000, "Every preparation composes rating")
		local ra = Solver.solve(C.envelope(a).network, a.step)
		local rb = Solver.solve(C.envelope(b).network, b.step)
		check(rb.deliveredKW >= ra.deliveredKW and rb.generatedKW == rb.deliveredKW, "Compatible conserved delivery")
		converted = C.advance(a, ra); built = C.advance(b, rb)
		if step % 60 == 0 then task.wait() end
	end
	check(I.line(S.network(100)).capacityKW == 3000, "Base fixture unchanged")
	for _, mutate in {
		function(v: any) v.ledger.capitalExpenseMinor = 0 end,
		function(v: any) v.investments.receipts = {} end,
		function(v: any) I.line(v.network).capacityKW = 3000 end,
	} do
		local corrupt = Codec.copy(built); mutate(corrupt)
		check(not pcall(C.validate, corrupt), "Reject partial capital/topology/receipt")
	end
	print("[Reinforcement Stage A] PASS " .. count .. " assertions; pure model and actual FleetSolver")
	return count
end
