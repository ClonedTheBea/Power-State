--!strict
-- Repeated fresh memory stores plus staggered ownership/cancellation. No real services.
local mode=game.ReplicatedStorage:GetAttribute("OperationsV13")
if mode~="All" and mode~="Server" then return end
assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Test only")
local O=game.ServerScriptService.Server.Operations
local Store=require(O.OperationsStore);local Country=require(O.OperationsCountry);local Scenario=require(O.OperationsScenario)
local Batch=require(O.OperationsBatch);local Coordinator=require(O.ReinforcementCoordinator)
local H=game:GetService("HttpService");local R=game:GetService("RunService")
for round=1,4 do
 print("[Operations V13 startup] fresh resource round "..round)
 require(script.Parent["ReinforcementResources.spec"])()
 require(script.Parent["ReinforcementTransaction.spec"])()
end
local checks=0
local function check(v:boolean,m:string)assert(v,m);checks+=1 end
for round=1,3 do
 local store=Store.new({reinforcement=true});local actors:{any}={}
 local api=Coordinator.new(store,os.clock,function()return H:GenerateGUID(false)end)
 for i=1,8 do
  R.Heartbeat:Wait();local r=store.acquire(3000+i)
  actors[i]={ownerId=r.ownerId,epoch=r.epoch,active=true,record=r,state=Scenario.prepare(Country.convert(r.state))}
 end
 local batch=Batch.new(actors)
 local old=actors[1].state;actors[1].active=false
 check(api.quote(actors[2])=="Quoted","Staggered quote")
 check(api.confirm(actors[2],actors[2].quote.id)=="Confirmed","Pending solver purchase")
 while not batch.done() do R.Heartbeat:Wait();batch.step()end
 check(actors[1].state==old,"Departed pending job installs nothing")
 check(actors[2].state.step==0 and actors[2].state.investments.serial==1,"Purchase invalidates old solve without bill")
 batch.close();check(batch.stats().retained==0,"No retained jobs")
 for i,a in actors do
  check(a.job==nil,"Job ownership cleared")
  if i>=3 then check(a.state.step==1,"Unrelated countries complete")end
  local ok,r=store.save(a.record,a.state,true);check(ok and not r.active,"Controlled release")
  local nextRecord=store.acquire(a.ownerId)
  check(nextRecord.epoch==r.epoch+1 and nextRecord.state.step==a.state.step,"Fresh epoch exact reentry")
  check(not pcall(store.save,r,a.state,false),"Stale released owner rejected")
 end
end
print("[Operations V13 startup] PASS "..checks.." staggered assertions; four fresh eight-country resource runs")

-- Explicit missed-service opportunity: the unchanged deadline must suspend, then one requested retry settles once.
do
 local store=Store.new({reinforcement=true});local r=store.acquire(9001)
 local a:any={ownerId=r.ownerId,epoch=r.epoch,active=true,record=r,state=Scenario.prepare(Country.convert(r.state))}
 local original=a.state;local now=0
 local b=Batch.new({a},{clock=function()return now end});now=1;b.step();b.close()
 check(a.state==original and a.status=="Suspended","Missed cadence installs no step or accounting")
 a.status="Accepted";local retry=Batch.new({a})
 while not retry.done()do R.Heartbeat:Wait();retry.step()end;retry.close()
 check(a.state.step==original.step+1,"Explicit retry advances one interval, not catch-up")
end
print("[Operations V13 startup] recovery PASS; total staggered/recovery "..checks)
game.ReplicatedStorage:SetAttribute("OperationsV13ServerReady",true)

if mode=="Server" then require(script.Parent["ReinforcementEconomy.spec"])() end
