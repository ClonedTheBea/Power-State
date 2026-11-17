--!strict
-- Two complete days through the real country accounting and intent modules.
return function()
 local Server=game:GetService("ServerScriptService").Server
 local Generator=require(Server.World.WorldGenerator)
 local Demand=require(Server.World.DemandModel)
 local Country=require(Server.Simulation.Country)
 local Handler=require(Server.Simulation.IntentHandler)
 local Http=game:GetService("HttpService")
 local world=Generator.create("df307a52185f423288df5749229f0808","replay",1)
 local a=Country.new(1,"same-replay",world.network)
 local b=Country.new(1,"same-replay",world.network)
 local requested,delivered=0,0;local n=0
 local function check(ok:boolean,label:string)assert(ok,label);n+=1 end
 for step=0,2879 do
  if step==180 or step==240 or step==1440 or step==1600 then
   for _,state in {a,b}do
    local before=state.deliveredMWh
    local outcome=Handler.handle(state,1,{version=1,kind="SetGenerator",epoch=state.epoch,
     sequence=state.lastSequence+1,revision=state.controlRevision,assetId=state.network.generatorId,online=not state.online},step)
    check(outcome=="Accepted" and state.deliveredMWh==before,"Control does not integrate energy")
   end
  end
  local d=Demand.atStep(step,world.meanTemperatureCentiC,1000)
  Country.advance(a,d.demandMW);Country.advance(b,d.demandMW)
  requested+=d.demandMW/60;delivered+=if a.online then d.demandMW/60 else 0
  check(math.abs(a.requestedMWh-requested)<1e-8 and math.abs(a.deliveredMWh-delivered)<1e-8,"Climate demand accounting conservation")
  if step%60==0 then check(Http:JSONEncode(Country.snapshot(a))==Http:JSONEncode(Country.snapshot(b)),"Deterministic country replay")end
 end
 check(#a.history==1440 and a.historyIndex==1440,"Bounded rolling day history")
 local before=Http:JSONEncode(Country.snapshot(a))
 check(not pcall(Country.advance,a,0/0),"Invalid demand rejected")
 check(Http:JSONEncode(Country.snapshot(a))==before,"Rejected step is atomic")
 local windowRequested,windowDelivered=0,0
 for step=1440,2879 do
  local d=Demand.atStep(step,1700,1000).demandMW/60
  windowRequested+=d;if step>=1600 then windowDelivered+=d end
 end
 check(math.abs(a.windowRequested-windowRequested)<1e-8 and math.abs(a.windowDelivered-windowDelivered)<1e-8,"History evicts previous day exactly")
 check(a.network~=b.network,"Separate state network updates")
 print(string.format("[P2b accounting] PASS %d assertions; two-day requested %.6f / delivered %.6f MWh",n,requested,delivered))
end
