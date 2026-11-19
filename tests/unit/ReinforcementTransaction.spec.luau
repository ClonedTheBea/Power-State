--!strict
return function()
	local O = game.ServerScriptService.Server.Operations
	local Country = require(O.OperationsCountry); local Scenario = require(O.OperationsScenario)
	local Store = require(O.OperationsStore); local Coordinator = require(O.ReinforcementCoordinator)
	local Fake = require(O.Parent.Adapters.FakeDataStoreAdapter); local Codec = require(O.Parent.Domain.ProfileCodec)
	local Batch = require(O.OperationsBatch)
	local Commands = require(O.OperationsCommands)
	local count = 0; local serial = 0
	local function check(v: boolean, message: string) assert(v, message); count += 1 end
	local function fixture(balance: number): (any, any, any, any)
		local s = Codec.copy(Scenario.new(1, 1)); s.ledger.openingMinor = balance; s.ledger.balanceMinor = balance
		local fake = Fake.create({["training:1"]={version=1, ownerId=1, epoch=1, revision=1, active=false, receipt="fixture", state=s}})
		local time = {now=0}
		local store = Store.new({adapter=fake, reinforcement=true, clock=function() return time.now end})
		local record = store.acquire(1)
		local actor: any = {state=Country.convert(record.state), record=record, ownerId=1, epoch=record.epoch, active=true, status="Accepted"}
		local api = Coordinator.new(store, function() return time.now end, function() serial += 1; return "test:" .. serial end)
		return actor, store, api, time
	end
	for _, balance in {74999,75000,75001} do
		local a, store, api = fixture(balance)
		local outcome = api.quote(a)
		if balance < 75000 then
			check(outcome == "InsufficientFunds" and a.state.ledger.balanceMinor == balance, "Exact below-buffer boundary")
		else
			check(outcome == "Quoted", "Boundary quote")
			check(api.confirm(a,a.quote.id) == "Confirmed", "Boundary purchase")
			check(a.state.ledger.balanceMinor == balance-50000 and a.state.ledger.capitalExpenseMinor == 50000, "Single debit/buffer")
			check(a.state.investments.serial == 1 and a.state.network.lines[5].capacityKW == 4000, "Atomic infrastructure")
			check(api.quote(a) == "AlreadyReinforced" and api.confirm(a,"old") == "AlreadyReinforced", "Permanent replay guard")
			local ok, saved = store.save(a.record,a.state,false); check(ok, "Later receipt superseded")
			local released, r = store.save(saved,a.state,true); check(released and not r.active, "Release")
			local restored = store.acquire(1)
			check(restored.state.ledger.balanceMinor == balance-50000 and restored.state.investments.serial == 1, "Reconnect exact investment")
			check(restored.state.step == 0 and restored.state.ledger.salesMinor == 0, "No offline or historical billing")
		end
	end
	for _, fault in {"BeforeWrite","AfterWrite","CallbackReplay"} do
		local a, store, api = fixture(100000)
		api.quote(a); store.faults.inject(fault)
		check(api.confirm(a,a.quote.id) == "Confirmed", "Reconcile " .. fault)
		check(a.state.ledger.balanceMinor == 50000 and a.state.investments.serial == 1, "One atomic purchase under fault")
	end
	do
		local a, _, api = fixture(75000)
		local expensive=Codec.copy(a.state)
		for _, control in expensive.controls do control.on=true; control.fixedMinorPerHour=1000000 end
		a.state=Country.convert(expensive)
		check(api.quote(a)=="InsufficientFunds","Gross reservation can exceed protected buffer in adversarial fixture")
	end
	do
		local a, store, api = fixture(100000)
		api.quote(a); local id=a.quote.id
		a.active=false
		check(api.confirm(a,id)=="Unauthorized","Departed owner cannot start purchase")
		a.active=true; a.quote.topologyRevision=2
		check(api.confirm(a,id)=="StaleQuote" and store.faults.stats().writes==1,"Changed topology quote no write")
		a.nextSequence=1
		local payload={version=1,kind="QuoteReinforcement",epoch=a.epoch,revision=a.state.countryRevision,sequence=1}
		check(Commands.apply(a,2,payload)=="Unauthorized","Cross-player quote rejected")
		payload.epoch+=1
		check(Commands.apply(a,1,payload)=="StaleSession","Stale investment session")
		for _, extra in {"priceMinor","ownerId","capacityKW","bankMinor","countryId"} do
			local malicious:any=table.clone(payload); malicious[extra]=1
			check(not Commands.admit({},malicious,0),"Client cannot supply investment authority")
		end
	end
	do
		local a, store, api, time = fixture(100000)
		api.quote(a); local id = a.quote.id; time.now=30
		check(api.confirm(a,id) == "QuoteExpired" and store.faults.stats().writes == 1, "Expiry no write")
		check(api.quote(a) == "Quoted" and a.quote.id ~= id, "Refresh replaces quote")
		time.now=151
		check(api.confirm(a,a.quote.id) == "LeaseUnsafe", "Lease margin not weakened")
	end
	do
		local a, store, api = fixture(100000)
		api.quote(a); local quote = a.quote.id
		store.faults.inject("Unavailable")
		check(api.confirm(a,quote) == "Uncertain" and a.investing and a.saveBlocked, "Unknown stays suspended")
		check(a.state.ledger.balanceMinor == 100000 and a.state.investments.serial == 0, "No early installation")
		check(api.confirm(a,quote) == "Saving", "No duplicate pending purchase")
		local saved = store.save(a.record,a.state,false); check(not saved, "Concurrent save blocked")
		store.faults.inject(nil)
		check(api.finish(a) == "Confirmed" and a.state.ledger.balanceMinor == 50000, "Same prepared candidate recovery")
	end
	do
		local a, store, api = fixture(100000)
		api.quote(a)
		store.faults.setHook(function(kind:string) if kind=="Update" then store.faults.inject("BeforeWrite") end end)
		check(api.confirm(a,a.quote.id)=="Unavailable","Repeated proven precommit failure")
		check(not a.investing and a.state.investments.serial==0 and a.state.ledger.balanceMinor==100000,"Known failure leaves whole original state")
		store.faults.setHook(nil)
		check(api.quote(a)=="Quoted" and api.confirm(a,a.quote.id)=="Confirmed","New quote only after positively unchanged head")
	end
	do
		local a, store, api, time = fixture(100000)
		api.quote(a)
		local update=store.faults.update
		store.faults.update=function(key:any, transform:any):any local result=update(key,transform); time.now=181; return result end
		check(api.confirm(a,a.quote.id)=="Confirmed" and a.state.investments.serial==1,"Late committed response establishes durable result")
		check(a.saveBlocked and a.status=="Suspended" and a.state.step==0,"Expired return cannot resume financial gameplay")
	end
	do
		local a, store = fixture(100000)
		store.faults.inject("Unavailable")
		check(not store.save(a.record,a.state,false),"Ordinary unknown checkpoint suspended")
		store.faults.inject(nil)
		local ok,result=store.save(a.record,a.state,true)
		check(ok and result.active,"Exit first reconciles original checkpoint, not a replacement release")
		local released,r=store.save(result,a.state,true)
		check(released and not r.active and r.state.ledger.balanceMinor==100000,"Release only after original checkpoint resolved")
	end
	do
		local a, store, api = fixture(100000)
		api.quote(a)
		store.faults.setHook(function(kind:string) if kind=="Update" then a.active=false end end)
		check(api.confirm(a,a.quote.id)=="Confirmed" and not a.active,"Departure after dispatch does not cancel committed purchase")
		store.faults.setHook(nil)
		check(store.save(a.record,a.state,true),"Departed purchased country releases as one state")
		check(store.acquire(1).state.investments.serial==1,"Departure/rejoin preserves purchase")
	end
	do
		local a, store, api = fixture(100000)
		api.quote(a)
		local seen = false
		store.faults.setHook(function(kind: string)
			if kind == "Update" then
				seen = true
				check(a.investing and a.state.step == 0 and a.state.ledger.balanceMinor == 100000, "Barrier before external yield")
				check(api.confirm(a,"repeat") == "Saving", "Double click while saving")
				task.wait(.05)
				check(a.state.step == 0 and a.state.investments.serial == 0, "No simulation/debit before confirmation")
			end
		end)
		check(api.confirm(a,a.quote.id) == "Confirmed" and seen, "Delayed atomic commit")
	end
	do
		local a, store, api = fixture(100000)
		a.state = Scenario.prepare(a.state)
		local batch = Batch.new({a})
		api.quote(a)
		check(api.confirm(a,a.quote.id) == "Confirmed", "Purchase invalidates captured solve")
		batch.step(); batch.close()
		check(a.state.step == 0 and a.state.investments.serial == 1, "Obsolete job cannot settle")
		local staleOk = pcall(store.save, a.record, Country.convert(Scenario.new(1,1)), false)
		check(not staleOk, "Stale session cannot save")
	end
	print("[Reinforcement Stage B] PASS " .. count .. " fake transaction assertions")
end
