--!strict
if game.ReplicatedStorage:GetAttribute("OperationsMultiplayer") ~= true then return end
assert(game:GetService("RunService"):IsStudio() and game.GameId == 10776833313)
local host = require(game.ServerScriptService.Server.Operations.OperationsService).start()
local Country = require(game.ServerScriptService.Server.Operations.OperationsCountry)
local expected = game.ReplicatedStorage:GetAttribute("OperationsExpectedClients") or 8
assert(type(expected) == "number" and expected >= 2 and expected <= 8)
local start = os.clock(); local players = game.Players
repeat task.wait(.2) until #players:GetPlayers() == expected or os.clock() - start > 180
assert(#players:GetPlayers() == expected, "Actual connected Studio client count")
repeat
	local ready = 0
	for _, p in players:GetPlayers() do local a = host.inspect(p); if a and a.epoch >= 2 and a.state.step >= 5 then ready += 1 end end
	if ready == expected then break end
	task.wait(.2)
until os.clock() - start > 240
local seen = {}; local states = {}; local ledger = {}
for _, p in players:GetPlayers() do
	local a = host.inspect(p); assert(a and a.epoch >= 2 and a.state.step >= 5, "Completed own reconnect")
	Country.validate(a.state)
	assert(a.ownerId == p.UserId and a.state.ownerId == p.UserId and a.state.countryId == "operations-training-" .. p.UserId)
	assert(not seen[a.state.countryId] and not states[a.state] and not ledger[a.state.ledger], "Distinct identities and state")
	seen[a.state.countryId] = true; states[a.state] = true; ledger[a.state.ledger] = true
	assert(a.state.controls.gas.capKW == 5000 - math.abs(p.UserId) * 100, "No cross-player controls")
	print("[Operations V11 actual owner] PASS " .. game:GetService("HttpService"):JSONEncode({userId = p.UserId, countryId = a.state.countryId,
		step = a.state.step, epoch = a.epoch, bankMinor = a.state.ledger.balanceMinor, requested = a.state.requestedKwMinutes, delivered = a.state.deliveredKwMinutes}))
end
print("[Operations V11 actual server] PASS " .. expected .. " connected clients; " .. game:GetService("HttpService"):JSONEncode(host.metrics))
players.PlayerRemoving:Connect(function(p)
	task.spawn(function()
		local at = os.clock(); repeat task.wait(.1) until host.inspect(p) == nil or os.clock() - at > 10
		assert(host.inspect(p) == nil, "Departure actor cleanup")
		local record = host.storage.faults.inspect("training:" .. p.UserId)
		assert(record and not record.active, "Departure releases fake owner")
		print("[Operations V11 actual departure] PASS " .. p.UserId)
	end)
end)
