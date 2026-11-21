--!strict
-- Isolated, non-writing component measurements. Timings overlap and must not be summed.
return function(fixtures:any,label:string,adapterFactory:any?)
 local S=game.ServerScriptService.Server;local H=game:GetService("HttpService")
 local C=require(S.Domain.ProfileCodec);local R=require(S.Domain.FleetRecord)
 local V=require(S.Domain.ProfileSchema4);local Country=require(S.Domain.FleetCountry)
 local Ledger=require(S.Domain.FleetEconomy);local Network=require(S.Domain.CountryFleetNetwork)
 local Solver=require(S.Operations.FleetSolver);local Demand=require(S.World.DemandModel)
 local scalar=function(v:any):string return H:JSONEncode(v)end
 local p=C.copy(fixtures.built);R.freeze(p.country)
 local state=Country.restore(p,fixtures.world,H:GenerateGUID(false))
 local network=Network.create(p.country,math.floor(Demand.atStep(state.step,1700,1000).demandMW*1000+.5))
 local report=Solver.solve(network,state.step);local rows={};local before=gcinfo();local wall=os.clock()
 local function measure(name:string,fn:()->(),prepare:(()->())?,finish:(()->())?)
  local times={};for i=1,30 do if prepare then prepare()end;local t=os.clock();fn();table.insert(times,(os.clock()-t)*1000);if finish then finish()end;if i%5==0 then task.wait()end end
  table.sort(times);rows[name]={p50=times[15],p95=times[29],peak=times[30]}
  print("FLEET11_PHASE",label,name,H:JSONEncode(rows[name]))
 end
 measure("fullCountryCopy",function()C.copy(p.country)end)
 measure("liveCopy",function()R.copyLive(p.country,p.country.fleet.baseline)end)
 measure("historyCopy",function()C.copy(p.country.simulation.history)end)
 measure("accountingCopy",function()C.copy(p.country.economy)end)
 measure("countryValidation",function()V.country(p.country,scalar)end)
 measure("fullProfileValidation",function()V.validate(p,p.ownerUserId,scalar)end)
 measure("fullProfileEncoding",function()C.encode(p,scalar)end)
 measure("capture",function()Country.capture(fixtures.world,state)end)
 measure("settlement",function()Ledger.settle(p.country,report)end)
 measure("complete",function()Country.complete(state,fixtures.world,report,network)end)
 local store=(adapterFactory or require(S.Adapters.FakeDataStoreAdapter).create)({["u:"..p.ownerUserId]=p})
 local profiles=require(S.Services.ProfileService).create({adapter=store,schema=V,lease=require(S.Domain.ProfileLease4),
  id=function()return H:GenerateGUID(false)end,scalar=scalar,jobId="Fleet11ComponentFake",placeId=1,
  utcMs=function()return DateTime.now().UnixTimestampMillis end,mono=os.clock,random=function()return 0 end,spawn=function(fn)fn()end})
 local entry=profiles.reserve(p.ownerUserId);profiles.prepared(entry,p.country);profiles.tick();profiles.tick();profiles.activate(entry)
 local snapshot=Country.capture(fixtures.world,state)
 local function stage()profiles.stage(entry,snapshot,state.revision)end
 local function finish()profiles.tick();profiles.tick();assert(not entry.op and not entry.terminal,"Confirmed fake checkpoint")end
 measure("coordinatorStage",stage)
 measure("checkpointPreparation",function()profiles.checkpoint(entry)end,stage,finish)
 measure("checkpointExecuteAndConfirm",finish,function()stage();profiles.checkpoint(entry)end)
 profiles.shutdown();for _=1,10 do profiles.tick()end
 assert(profiles.stats().profiles==0,"Component coordinator cleanup")
 local components={};for _,key in {"simulation","fleet","economy","deltas","construction","bank"}do components[key]=#C.encode(p.country[key],scalar)end
 components.frozenBaseline=#C.encode(p.country.fleet.baseline,scalar)
 components.liveHistory=#C.encode(p.country.simulation.history,scalar)
 components.frozenHistory=#C.encode(p.country.fleet.baseline.legacySimulation.history,scalar)
 print("FLEET11_SIZE_BREAKDOWN",label,H:JSONEncode(components))
 print("FLEET11_COMPONENTS",H:JSONEncode({label=label,timingsMs=rows,bytes=components,profileBytes=#C.encode(p,scalar),
  wallMs=(os.clock()-wall)*1000,heapDeltaKiB=gcinfo()-before,note="shared heap; no forced GC or isolated allocation attribution; timings overlap"}))
 return rows
end
