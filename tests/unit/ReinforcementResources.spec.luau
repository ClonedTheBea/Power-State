--!strict
return function()
	local O=game.ServerScriptService.Server.Operations
	local Store=require(O.OperationsStore); local Coordinator=require(O.ReinforcementCoordinator)
	local Country=require(O.OperationsCountry); local Scenario=require(O.OperationsScenario); local Batch=require(O.OperationsBatch)
	local Projection=require(O.OperationsProjection); local H=game:GetService("HttpService")
	local Codec=require(O.Parent.Domain.ProfileCodec)
	local function encode(v:any):string return Codec.encode(v,function(x) return H:JSONEncode(x) end) end
	local store=Store.new({reinforcement=true}); local api=Coordinator.new(store,os.clock,function() return H:GenerateGUID(false) end)
	local actors:{any}={}; local count=0; local memory=gcinfo()
	local peak={prepare=0,solver=0,install=0,checkpoint=0,transaction=0,profile=0,snapshot=0}
	local function check(v:boolean,message:string) assert(v,message);count+=1 end
	for i=1,8 do
		local r=store.acquire(2000+i)
		local a:any={ownerId=r.ownerId,epoch=r.epoch,active=true,record=r,state=Country.convert(r.state),nextSequence=1,controlsRevision=0}
		local began=os.clock(); check(api.quote(a)=="Quoted" and api.confirm(a,a.quote.id)=="Confirmed","Eight independent investments")
		peak.transaction=math.max(peak.transaction,(os.clock()-began)*1000)
		actors[i]=a
	end
	for step=1,120 do
		local began=os.clock()
		for _,a in actors do a.state=Scenario.prepare(a.state) end
		local batch=Batch.new(actors);peak.prepare=math.max(peak.prepare,(os.clock()-began)*1000)
		local wall=os.clock();local maxGap=0
		while not batch.done() do
			local gap=game:GetService("RunService").Heartbeat:Wait();maxGap=math.max(maxGap,gap);local m=batch.step()
			peak.solver=math.max(peak.solver,m.cpuMs);peak.install=math.max(peak.install,m.installMs)
		end
		for _,a in actors do
			check(a.state.step==step and a.state.investments.serial==1 and a.state.ledger.capitalExpenseMinor==50000,
				"Independent investment/cursor "..H:JSONEncode({expected=step, actual=a.state.step, status=a.status, reason=a.reason, serial=a.state.investments.serial, capital=a.state.ledger.capitalExpenseMinor,wallMs=(os.clock()-wall)*1000,maxHeartbeatGapMs=maxGap*1000,batch=batch.stats()}))
			began=os.clock();local ok,r=store.save(a.record,a.state,false)
			check(ok,"Confirmed reinforced checkpoint");a.record=r
			peak.checkpoint=math.max(peak.checkpoint,(os.clock()-began)*1000)
			peak.profile=math.max(peak.profile,#H:JSONEncode(r));peak.snapshot=math.max(peak.snapshot,#H:JSONEncode(Projection.create(a)))
		end
		check(batch.stats().retained==0,"Bounded solver cleanup");batch.close()
	end
	for _,a in actors do
		local ledger=encode(a.state.ledger);local receipt=encode(a.state.investments)
		local rawLedger=H:JSONEncode(a.state.ledger);local rawReceipt=H:JSONEncode(a.state.investments)
		check(store.save(a.record,a.state,true),"Release invested country")
		local r=store.acquire(a.ownerId)
		local exact=encode(r.state.ledger)==ledger and encode(r.state.investments)==receipt
		if exact and (H:JSONEncode(r.state.ledger)~=rawLedger or H:JSONEncode(r.state.investments)~=rawReceipt) then
			print("[Reinforcement diagnostic] JSON key order differs; canonical complete ledger/receipt equality holds")
		end
		check(exact,"Exact financial carries and permanent receipt on reconnect")
	end
	check(peak.profile<192*1024 and peak.snapshot<=65536 and store.faults.stats().profiles==8,"Bounded eight-country memory records")
	print("[Reinforcement resources] PASS "..count.." assertions; "..H:JSONEncode({peaks=peak,heapDeltaKiB=gcinfo()-memory,storage=store.faults.stats()}))
end
