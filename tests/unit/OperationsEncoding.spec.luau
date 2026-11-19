--!strict
return function()
	local O = game.ServerScriptService.Server.Operations
	local Encoding = require(O.OperationsEncoding); local Scenario = require(O.OperationsScenario)
	local Codec = require(O.Parent.Domain.ProfileCodec); local H = game:GetService("HttpService")
	local count = 0; local calls = 0
	local function check(value: boolean) assert(value, "Exact bounded encoding"); count += 1 end
	local function scalar(value: any): string return H:JSONEncode(value) end
	local encode = Encoding.new(function(value) calls += 1; return scalar(value) end)
	local state = Scenario.new(1, 1)
	check(encode(state) == Codec.encode(state, scalar))
	local first = calls; check(encode(Codec.copy(state)) == Codec.encode(state, scalar) and calls == first)
	local changed = Codec.copy(state); changed.ledger.balanceMinor += 1
	check(encode(changed) ~= encode(state)); check(encode(changed) == Codec.encode(changed, scalar))
	local scalars: {any} = {"a\"b\\c\n", "é", true, false, 0, -1, 1.25}
	for _, value in scalars do check(encode(value) == Codec.encode(value, scalar)) end
	check(encode(-1 * 0) == Codec.encode(-1 * 0, scalar))
	local malformed: {any} = {{[2] = 1}, {a = 1, [1] = 2}, {x = 0/0}, {x = math.huge}, {x = string.rep("x", 257)}, {x = function() end}}
	local cycle: any = {}; cycle.self = cycle; table.insert(malformed, cycle)
	for _, value in malformed do check(not pcall(encode, value) and not pcall(Codec.encode, value, scalar)) end
	for i = 1, 5000 do check(encode(i) == scalar(i)) end
	check(encode(state) == Codec.encode(state, scalar))
	print("[Operations Encoding] PASS: " .. count .. " assertions; first scalar calls " .. first)
end
