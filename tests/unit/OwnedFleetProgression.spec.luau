--!strict
-- Exact fresh-country progression, with no waiting, grants or Training imports.
-- Accelerated pure replay measures simulated intervals, not human playtest time.
return function()
 local S=game.ServerScriptService.Server;local H=game:GetService("HttpService")
 local L1=require(S.Domain.ProfileLease);local L2=require(S.Domain.ProfileLease2)
 local C=require(S.Domain.FleetCountry);local PC=require(S.Domain.ProfileCountry)
 local Base=require(S.Simulation.Country);local Demand=require(S.World.DemandModel)
 local District=require(S.Domain.ConstructionProject);local Wind=require(S.Domain.WindProject)
 local V=require(S.Domain.ProfileSchema4);local rows={}
 local function id():string return H:GenerateGUID(false)end
 local function scalar(v:any):string return H:JSONEncode(v)end
 for _,seed in {"df307a52185f423288df5749229f0808",string.rep("0",32),string.rep("f",32)}do
  local world=require(S.World.WorldGenerator).create(seed,id(),1)
  local initial=Base.new(149564436,id(),world.network)
  local function op(kind:string,p:any?):any
   return {id=id(),kind=kind,owner=149564436,sessionId=if p and p.lease then p.lease.ownerSessionId else id(),jobId="FleetProgressionFake",placeId=1,
    candidate=PC.capture(world,initial),fence=if p then p.sessionEpoch else nil,baseRevision=if p then p.profileRevision else nil}
  end
  local p=L1.apply(nil,op("Acquire"),1000000,scalar);p=L1.apply(p,op("Release",p),1000001,scalar)
  p=L2.apply(p,op("Acquire",p),1000002,scalar);p=L2.apply(p,op("Release",p),1000003,scalar)
  p=require(S.Domain.ProfileMigrations3).read(p,149564436,scalar)
  p=require(S.Domain.ProfileMigrations4).read(p,149564436,id(),scalar)
  local epoch=id();local state=C.restore(p,world,epoch);local districtStep=0;local windStep=0;local windBank=0
  local function install(country:any)
   p.country=country;p.countryRevision=state.revision+1;p.lastCommit.countryRevision=p.countryRevision
   V.validate(p,149564436,scalar);state=C.restore(p,world,epoch,state)
  end
  for i=1,3000 do
   state=C.advanceLegacy(state,world,Demand.atStep(state.step,world.meanTemperatureCentiC,1000).demandMW)
   if not state.construction.receipt and state.bank.balanceMinor>=125000 then
    districtStep=state.step;install(District.build(C.capture(world,state),id(),p.countryRevision+1,p.profileRevision))
   elseif state.construction.receipt and state.bank.balanceMinor>=425000 then
    windStep=state.step;windBank=state.bank.balanceMinor
    install(Wind.build(C.capture(world,state),id(),p.countryRevision+1,p.profileRevision));break
   end
   if i%30==0 then task.wait()end
  end
  assert(districtStep>0 and windStep>districtStep,"Bounded genuine progression reaches both projects")
  assert(state.bank.balanceMinor==windBank-400000 and state.bank.balanceMinor>=25000,"Exact wind debit retains buffer")
  assert(state.bank.openingGrantMinor==100000 and state.bank.constructionSpentMinor+state.bank.windConstructionSpentMinor==500000,"One original grant and two approved capital debits")
  table.insert(rows,{seed=seed,districtStep=districtStep,windStep=windStep,afterDistrictIntervals=windStep-districtStep,
   windBankMinor=windBank,postWindBankMinor=state.bank.balanceMinor,temperature=world.meanTemperatureCentiC})
 end
 print("[Owned fleet progression] PASS",H:JSONEncode(rows),"accelerated exact replay; not wall-clock or player acceptance")
 return rows
end
