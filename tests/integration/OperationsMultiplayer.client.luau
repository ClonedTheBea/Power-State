--!strict
if game.ReplicatedStorage:GetAttribute("OperationsMultiplayer") ~= true then return end
assert(game:GetService("RunService"):IsStudio() and game.GameId == 10776833313)
local client = script.Parent.Parent:WaitForChild("Client", 30); assert(client, "Client replication deadline")
local C = client:WaitForChild("Simulation", 30); assert(C)
local First = require(C.ConstructionClient); local Ops = require(C.OperationsClient)
local R = game:GetService("RunService"); local player = game.Players.LocalPlayer
local function waitFor(f: () -> boolean, limit: number)
	local at = os.clock(); repeat if f() then return end; R.Heartbeat:Wait() until os.clock() - at > limit
	error("Actual-client condition deadline")
end
waitFor(function() return First.active() ~= nil end, 90)
local first = First.active(); first.app.actions[first.app.view.navigation.buttons.Infrastructure](); first.app.actions[first.directory.training]()
waitFor(function() return Ops.active() ~= nil and Ops.active().app ~= nil end, 30)
-- Full fixed-window flood suite runs separately in Play Solo. Here retain the
-- actual sending-player attack under concurrent load without counting unsolicited packets.
local remote = game.ReplicatedStorage.OperationsTraining.Intent :: RemoteEvent
local probe = Ops.active(); local initial = probe.current()
remote:FireServer({version = 1, kind = "Control", epoch = initial.epoch, revision = initial.revision,
	sequence = initial.nextSequence, sourceId = "gas", on = false, capKW = 5000, ownerId = player.UserId - 1})
task.wait(1)
for _, unit in probe.current().fleet do if unit.id == "gas" then assert(unit.on and unit.capKW == 5000, "Forged ownership rejected") end end
local live = Ops.active(); local cap = 5000 - math.abs(player.UserId) * 100
assert(cap >= 4000 and cap <= 4900, "Local Studio client fixture")
local function gas(): any for _, unit in live.current().fleet do if unit.id == "gas" then return unit end end; error("Missing gas") end
local commandAt = os.clock()
repeat
	live.send("Control", "gas", true, cap); task.wait(.4)
until gas().capKW == cap or os.clock() - commandAt > 10
assert(gas().capKW == cap, "Own unique dispatch accepted")
local latency = (os.clock() - commandAt) * 1000
local initial = live.current(); local frames = {}
for _ = 1, 300 do table.insert(frames, R.RenderStepped:Wait() * 1000) end
assert(gas().capKW == cap, "Peer controls never replaced own cap")
assert(live.current().step > initial.step and live.current().bankMinor ~= initial.bankMinor, "Independent authoritative progression")
assert(#live.app.view.map.root:GetDescendants() <= 600, "Map bound")
live.app.actions[live.ui.leave]()
waitFor(function() return Ops.active() == nil and First.active() ~= nil end, 15)
local release = Ops.lastRelease(); task.wait(1)
first = First.active(); first.app.actions[first.app.view.navigation.buttons.Infrastructure](); first.app.actions[first.directory.training]()
waitFor(function() return Ops.active() ~= nil and Ops.active().app ~= nil end, 15)
live = Ops.active()
assert(live.entry.step == release.step and live.entry.bankMinor == release.bankMinor, "Exact same-player fake re-entry, no offline settlement")
assert(gas().capKW == cap, "Saved own cap restored")
table.sort(frames)
print("[Operations V11 actual client] PASS " .. game:GetService("HttpService"):JSONEncode({userId = player.UserId,
	capKW = cap, commandObservedMs = latency, frameP50Ms = frames[150], frameP95Ms = frames[285], frameWorstMs = frames[300],
	restoredStep = live.entry.step, bankMinor = live.entry.bankMinor, mapDescendants = #live.app.view.map.root:GetDescendants()}))
