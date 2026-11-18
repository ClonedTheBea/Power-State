--!strict
return function()
	assert(game:GetService("RunService"):IsStudio() and game.GameId == 10776833313, "Isolated Test transport only")
	local Client = require(script.Parent.Parent.Client.Simulation.OperationsClient)
	local live = Client.active(); assert(live and live.app, "Training entered through normal navigation")
	local folder = game.ReplicatedStorage.OperationsTraining
	local remote = folder.Intent :: RemoteEvent
	local snapshots = folder.Snapshot :: RemoteEvent
	local initial = live.current(); local count, messages = 0, 0
	local function check(v: boolean, message: string) assert(v, message); count += 1 end
	local function sameControls(s: any): boolean
		for i, source in s.fleet do local old = initial.fleet[i]; if source.id ~= old.id or source.on ~= old.on or source.capKW ~= old.capKW then return false end end
		return true
	end
	local connection = snapshots.OnClientEvent:Connect(function(s: any)
		messages += 1
		check(s.ownerId == nil and s.ledger == nil and s.receipt == nil and s.seed == nil, "No private fields on actual transport")
	end)
	for _, kind in {"owner", "id", "epoch", "revision", "negative", "fraction", "nan", "infinity", "cap", "nested", "large"} do
		local p: any = {version = 1, kind = "Control", epoch = initial.epoch, revision = initial.revision,
			sequence = initial.nextSequence, sourceId = "gas", on = false, capKW = 5000}
		if kind == "owner" then p.ownerId = 1 elseif kind == "id" then p.sourceId = "foreign-generator"
		elseif kind == "epoch" then p.epoch += 100 elseif kind == "revision" then p.revision = 1000000000
		elseif kind == "negative" then p.capKW = -100 elseif kind == "fraction" then p.capKW = 100.5
		elseif kind == "nan" then p.capKW = 0/0 elseif kind == "infinity" then p.capKW = math.huge
		elseif kind == "cap" then p.capKW = 5100 elseif kind == "nested" then p.on = {} elseif kind == "large" then p.sourceId = string.rep("x", 1024) end
		remote:FireServer(p); task.wait(.4)
		check(sameControls(live.current()), "Rejected actual invalid command: " .. kind)
	end
	local before = messages
	for _ = 1, 100 do remote:FireServer({version = 1, kind = "Sync"}) end
	task.wait(.5)
	check(messages - before <= 9, "Actual transport flood response bounded")
	check(sameControls(live.current()), "Flood cannot alter control state")
	connection:Disconnect()
	print("[Operations Remote] PASS: " .. count .. " assertions; flood response count=" .. (messages - before))
end
