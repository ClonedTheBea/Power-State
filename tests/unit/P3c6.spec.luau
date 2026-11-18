--!strict
-- Local protected capture supplied by the operator. Fake storage only, no real adapter.
return function(review:any)
 local S=game.ServerScriptService.Server;local H=game:GetService("HttpService")
 local C=require(S.Domain.ProfileCodec);local V=require(S.Domain.ProfileSchema3)
 local Lease=require(S.Domain.ProfileLease3);local Country=require(S.Domain.ConstructionCountry)
 local Demand=require(S.World.DemandModel);local World=require(S.World.WorldGenerator)
 local Solver=require(S.Simulation.DistrictSolver);local Economy=require(S.Domain.Economy)
 local Profiles=require(S.Services.ProfileService);local Fake=require(S.Adapters.FakeDataStoreAdapter)
 local function scalar(v:any):string return H:JSONEncode(v)end
 local function id():string return H:GenerateGUID(false)end
 local function equal(a:any,b:any):boolean return C.encode(a,scalar)==C.encode(b,scalar)end
 local n=0;local function check(ok:boolean,m:string)assert(ok,m);n+=1 end
 local function near(a:number,b:number):boolean return math.abs(a-b)<1e-9 end
 local raw=C.encode(review,scalar)
 V.validate(review,149564436,scalar)
 check(review.profileRevision==37 and review.countryRevision==257 and review.sessionEpoch==10 and not review.lease,"Released starting envelope")
 check(review.country.simulation.step==242 and review.country.bank.balanceMinor==25003,"Exact starting step/Bank")
 local world=World.create(review.country.recipe.seed,review.country.recipe.countryId,review.country.recipe.generationVersion)
 local initial=Country.restore(review,world,id());local state=initial;local rows={};local expected={}
 local receipt=C.copy(review.country.construction);local deltas=C.copy(review.country.deltas)
 local salesCarry=initial.economy.baseSalesRemainder;local variableCarry=initial.economy.variableExpenseRemainder
 local fixedCarry=initial.economy.fixedExpenseRemainder;local bank=initial.bank.balanceMinor;local totalKW=0
 for i=1,5 do
  local demand=Demand.atStep(state.step,world.meanTemperatureCentiC,1000).demandMW
  local townKW=math.floor(demand*1000+.5);local districtKW=math.floor((townKW+2)/4);local combined=townKW+districtKW
  check(townKW==({3370,3374,3378,3382,3386})[i],"Pinned five-interval demand reference")
  local before=state;state=Country.advance(state,world,demand);local report=state.report
  check(#report.sinks==2 and report.sinks[1].id==world.network.demandId and report.sinks[2].id==receipt.receipt.terminalId,"Independent sink identities")
  check(near(report.sinks[1].requestedMW,townKW/1000) and near(report.sinks[1].deliveredMW,townKW/1000),"Original town demand/service")
  check(near(report.sinks[2].requestedMW,districtKW/1000) and near(report.sinks[2].deliveredMW,districtKW/1000),"District demand/service")
  check(near(report.deliveredMW,combined/1000) and near(report.outputMW,report.deliveredMW),"Two-sink conservation")
  check(near(report.flows[receipt.receipt.lineId],districtKW/1000) and districtKW<=1000,"Feeder capacity")
  for _,line in world.network.lines do
   check(near(report.flows[line.id],combined/1000) and report.flows[line.id]<=line.capacity,"Shared upstream conservation")
  end
  local sales=math.floor((salesCarry+combined*12000)/60000);salesCarry=(salesCarry+combined*12000)%60000
  local variable=math.floor((variableCarry+combined*8000)/60000);variableCarry=(variableCarry+combined*8000)%60000
  local fixed=math.floor((fixedCarry+1000000)/60000);fixedCarry=(fixedCarry+1000000)%60000
  bank+=sales-variable-fixed;totalKW+=combined
  check(state.bank.balanceMinor==bank and state.economy.baseSalesMinor-before.economy.baseSalesMinor==sales
   and state.economy.variableExpenseMinor-before.economy.variableExpenseMinor==variable
   and state.economy.fixedExpenseMinor-before.economy.fixedExpenseMinor==fixed,"Independent integer billing oracle")
  check(state.economy.baseSalesRemainder==salesCarry and state.economy.variableExpenseRemainder==variableCarry and state.economy.fixedExpenseRemainder==fixedCarry,"Exact carries")
  check(near(state.deliveredMWh-before.deliveredMWh,combined/60000),"Physical MWh")
  expected[state.step]=Country.capture(world,state)
  check(equal(expected[state.step].construction,receipt) and equal(expected[state.step].deltas,deltas),"No capital or infrastructure mutation")
  table.insert(rows,{startStep=before.step,endStep=state.step,townKW=townKW,districtKW=districtKW,totalKW=combined,
   salesMinor=sales,variableMinor=variable,fixedMinor=fixed,bankMinor=bank,salesCarry=salesCarry,variableCarry=variableCarry,fixedCarry=fixedCarry})
 end
 local finalCountry=Country.capture(world,state)
 check(state.economy.deliveredKwMinutes-initial.economy.deliveredKwMinutes==totalKW,"Exact five-interval energy meter")
 for i,row in initial.history do check(equal(state.history[i],row),"Original reliability history preserved")end
 local function execute(fault:string?):any
  local store=Fake.create({["u:149564436"]=review});local time=2000000000;local first=true
  local function session(count:number)
   local svc=Profiles.create({adapter=store,schema=V,lease=Lease,prepareCountry=V.country,scalar=scalar,id=id,
    utcMs=function()return math.floor(time*1000)end,mono=function()return time end,random=function()return 0 end,
    spawn=function(fn)fn()end,jobId="P3c6FakeOnly",placeId=1})
   local e=svc.reserve(149564436);local head=store.read("u:149564436")
   local function idle()for _=1,200 do svc.tick();if e.terminal then error(e.reason)end;if not e.op and not e.inFlight and not e.result then return end;time+=.05 end;error("Fake deadline")end
   svc.prepared(e,head.country);idle();svc.activate(e)
   local current=Country.restore(svc.profile(e),world,e.commandEpoch)
   check(equal(Country.capture(world,current),head.country),"Reconnect has no offline progression")
   for _=1,count do
    time+=1;svc.tick();check(svc.canMutate(e),"Safe lease before explicit interval")
    current=Country.advance(current,world,Demand.atStep(current.step,world.meanTemperatureCentiC,1000).demandMW)
    check(equal(Country.capture(world,current),expected[current.step]),"Exact deterministic interval prefix")
    svc.stage(e,Country.capture(world,current),current.revision)
   end
   if first and fault then store.inject(fault)end;first=false
   svc.checkpoint(e);idle();check(equal(store.read("u:149564436"),svc.profile(e)),"Whole checkpoint confirmed")
   svc.close(e);idle();local released=store.read("u:149564436")
   check(not released.lease and svc.stats().profiles==0 and equal(released,svc.profile(e)),"Fenced released confirmation")
   return released
  end
  local mid=session(3);time+=86400;local finish=session(2)
  check(mid.country.simulation.step==245 and finish.country.simulation.step==247,"Exactly three plus two intervals")
  check(equal(finish.country,finalCountry),"Partition/retry-independent exact final country")
  check(finish.profileRevision==43 and finish.countryRevision==262 and finish.sessionEpoch==12,"Expected two-session revisions")
  check(finish.country.bank.openingGrantMinor==100000 and finish.country.bank.constructionSpentMinor==100000,"No new grant or capital debit")
  return {profileRevision=finish.profileRevision,countryRevision=finish.countryRevision,epoch=finish.sessionEpoch,stats=store.stats(),bytes=#C.encode(finish,scalar)}
 end
 local normal=execute(nil)
 for _,fault in {"BeforeWrite","AfterWrite","CallbackReplay"}do execute(fault)end
 local demand=Demand.atStep(242,world.meanTemperatureCentiC,1000).demandMW
 local off=C.copy(initial);off.online=false;local offNext=Country.advance(off,world,demand)
 check(offNext.report.deliveredMW==0 and offNext.report.sinks[1].unmetMW>0 and offNext.report.sinks[2].unmetMW>0,"Off preserves both unmet requests")
 check(offNext.bank.balanceMinor==initial.bank.balanceMinor and offNext.economy.onlineSteps==initial.economy.onlineSteps,"Off pays no sales or costs")
 local disconnected=Solver.solve(review.country,demand,true,false)
 check(disconnected.sinks[2].deliveredMW==0 and disconnected.sinks[2].unmetMW>0 and near(disconnected.sinks[1].deliveredMW,demand),"Disconnected district, town remains served")
 local projected=V.previousCountry(review.country)
 local disconnectedBank,disconnectedEconomy=Economy.settle(projected.bank,projected.economy,242,disconnected,true)
 check(disconnectedEconomy.deliveredKwMinutes-initial.economy.deliveredKwMinutes==math.floor(demand*1000+.5),"Disconnected demand is not paid")
 check(disconnectedBank.balanceMinor-projected.bank.balanceMinor<rows[1].bankMinor-initial.bank.balanceMinor,"District raises eligible net income")
 check(not pcall(Economy.settle,projected.bank,projected.economy,241,disconnected,true),"Duplicate cursor rejected")
 local corrupt=C.copy(review);corrupt.country.bank.balanceMinor+=1
 check(not pcall(V.validate,corrupt,149564436,scalar),"Malformed profile rejected")
 local op={id=id(),owner=149564436,sessionId=id(),jobId="Fake",placeId=1,kind="Acquire",baseRevision=37,candidate=review.country}
 local owned=Lease.apply(review,op,2000000000000,scalar)
 local bad={id=id(),owner=149564436,sessionId=id(),jobId="Fake",placeId=1,kind="Checkpoint",fence=owned.sessionEpoch,baseRevision=owned.profileRevision,snapshot=review.country,countryRevision=257}
 local rejected=Lease.apply(owned,bad,2000000000001,scalar)
 check(rejected==nil,"Stale/foreign owner rejected")
 check(C.encode(review,scalar)==raw,"Historical protected capture untouched")
 for _,row in rows do print("[P3c6 interval] "..H:JSONEncode(row))end
 print("[P3c6 forecast] "..H:JSONEncode({totalKwMinutes=totalKW,normal=normal,meanCentiC=world.meanTemperatureCentiC,
  finalBank=state.bank.balanceMinor,baseSales=state.economy.baseSalesMinor,variable=state.economy.variableExpenseMinor,fixed=state.economy.fixedExpenseMinor}))
 print(string.format("[P3c6 fake] PASS: %d assertions; five intervals, two sessions, no real access",n))
end
