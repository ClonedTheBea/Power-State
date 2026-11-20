--!strict
-- Explicit diagnostic helper; never runs automatically. Accelerates only genuine
-- legacy solver/billing intervals in the existing in-memory fake Test country.
return function(player:Player)
 local Run=game:GetService("RunService")
 assert(Run:IsStudio()and Run:IsServer()and game.GameId==10776833313 and game.CreatorId==149564436,"Fake Test only")
 local S=game.ServerScriptService.Server;local host=require(S.Services.ConstructionTestService).start()
 assert(host.fleet and host.storage.mode=="Fake","No real adapter permitted")
 local a=host.inspect(player);assert(a and a.state and a.state.construction.receipt and not a.state.fleet.windReceipt,"Normal purchased district required")
 assert(player:GetAttribute("OperationsTraining")~=true,"Do not interrupt an active Training session")
 local Country=host.country;local Demand=require(S.World.DemandModel)
 local start=a.state.step;local balance=a.state.bank.balanceMinor;local at=os.clock();local count=0
 player:SetAttribute("OperationsTraining",true)
 local ok,why=pcall(function()
  while a.state.bank.balanceMinor<425000 and count<3000 do
   assert(host.inspect(player)==a and host.profiles.canMutate(a.entry),"Current fake owner and safe lease")
   local nextState=Country.advanceLegacy(a.state,a.world,Demand.atStep(a.state.step,1700,1000).demandMW)
   host.profiles.stage(a.entry,Country.capture(a.world,nextState),nextState.revision)
   a.state=nextState;count+=1
   if count%64==0 then host.profiles.checkpoint(a.entry)end
   if count%8==0 then Run.Heartbeat:Wait()end
  end
  assert(a.state.bank.balanceMinor>=425000,"Bounded genuine funding threshold")
  local revision=a.state.revision;local untilAt=os.clock()+15
  repeat host.profiles.checkpoint(a.entry);Run.Heartbeat:Wait()
  until host.profiles.profile(a.entry).countryRevision>=revision or os.clock()>untilAt
  assert(host.profiles.profile(a.entry).countryRevision>=revision,"Funding checkpoint confirmed")
 end)
 a.elapsed=0;player:SetAttribute("OperationsTraining",false)
 assert(ok,tostring(why))
 print("[Owned fleet genuine funding] intervals",count,"steps",start,a.state.step,"Bank minor",balance,a.state.bank.balanceMinor,"wall ms",(os.clock()-at)*1000,"accelerated fake test only; no grant or price change")
end
