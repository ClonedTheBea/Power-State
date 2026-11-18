--!strict
return function()
	local Client = script.Parent.Parent.Client.Simulation
	local Operations = require(Client.OperationsClient); local First = require(Client.ConstructionClient)
	local R = game:GetService("RunService"); local count = 0
	local function check(v: boolean, message: string) assert(v, message); count += 1 end
	local function waitFor(predicate: () -> boolean, seconds: number, message: string)
		local at = os.clock()
		repeat if predicate() then return end; R.Heartbeat:Wait() until os.clock() - at >= seconds
		error("Journey deadline: " .. message)
	end
	local live = Operations.active(); assert(live and live.app, "Run Operations.spec first")
	local function s(): any return live.current() end
	local function source(id: string): any for _, v in s().fleet do if v.id == id then return v end end; return nil end
	waitFor(function() return s().step >= 61 end, 90, "real-time peak")
	check(s().unmetKW > 0 and s().reliability < 1, "No-action shortage lowers reliability")
	check(not source("peak").on, "No forced operator action")
	local oldExpense = s().expensesMinor
	waitFor(function() return not s().saving and s().status ~= "Pending" end, 3, "peaker command window")
	live.app.actions[live.ui.fleet.peak.toggle]()
	waitFor(function() return source("peak").on and s().unmetKW == 0 and source("peak").outputKW > 0 end, 5, "peaker restores service")
	check(s().expensesMinor > oldExpense, "Peak service increases expenses")
	waitFor(function() return s().step >= 91 end, 40, "constrained branch")
	check(s().unmetKW == 500 and s().availableKW > s().demandKW, "Route bottleneck despite spare generation")
	waitFor(function() return s().status == "Suspended" end, 15, "server harness delay")
	check(s().step == game.ReplicatedStorage:GetAttribute("OperationsDelayStep") and s().bankMinor == game.ReplicatedStorage:GetAttribute("OperationsDelayBank"), "Delayed interval changes no energy or finance")
	local suspendedStep = s().step
	local suspendedBank = s().bankMinor
	task.wait(4.1) -- Deliberately exceed the client's three-second connection-health window.
	check(s().status == "Suspended" and s().step == suspendedStep and s().bankMinor == suspendedBank, "Idle suspension advances no physics or finance")
	check(live.ui.retry.Active, "Healthy suspended connection keeps Retry available after idle")
	live.app.actions[live.ui.retry]()
	waitFor(function() return s().step > suspendedStep end, 5, "normal Retry recovery")
	check(s().step == suspendedStep + 1, "Recovery advances one interval, no catch-up")
	waitFor(function() return not s().saving and s().status ~= "Pending" end, 3, "leave checkpoint")
	live.app.actions[live.ui.leave]()
	waitFor(function() return First.active() ~= nil and Operations.lastRelease() ~= nil end, 10, "normal return and release")
	local saved = Operations.lastRelease()
	task.wait(2)
	local first = First.active(); first.app.actions[first.app.view.navigation.buttons.Infrastructure]()
	waitFor(function() return Operations.active() ~= nil and Operations.active().app ~= nil end, 15, "normal training reconnect")
	live = Operations.active()
	check(live.entry.step == saved.step and live.entry.bankMinor == saved.bankMinor and live.entry.salesMinor == saved.salesMinor and live.entry.expensesMinor == saved.expensesMinor, "Exact reconnect/no offline billing")
	check(live.entry.epoch > saved.epoch and source("peak").on, "Fresh owner epoch and preserved operator controls")
	check(#live.app.view.map.root:GetDescendants() <= 600, "Remount bounded")
	print("[Operations Journey] PASS: " .. count .. " assertions; released minute=" .. saved.step .. "; Bank=" .. saved.bankMinor .. "; restored without offline revenue")
end
