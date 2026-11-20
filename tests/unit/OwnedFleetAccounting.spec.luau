--!strict
return function(fixtures:any)
 local S=game.ServerScriptService.Server;local H=game:GetService("HttpService")
 local C=require(S.Domain.ProfileCodec);local V=require(S.Domain.ProfileSchema4);local R=require(S.Domain.FleetRecord)
 local Network=require(S.Domain.CountryFleetNetwork);local Ledger=require(S.Domain.FleetEconomy)
 local Solver=require(S.Operations.FleetSolver);local Wind=require(S.Operations.OperationsWind)
 local checks=0;local function check(ok:boolean,m:string)assert(ok,m);checks+=1 end
 local scalar=function(v:any):string return H:JSONEncode(v)end
 local function equal(a:any,b:any):boolean return C.encode(a,scalar)==C.encode(b,scalar)end
 for seed,expected in {[string.rep("0",32)]=138458787,[string.rep("f",32)]=2125758868,
  df307a52185f423288df5749229f0808=758429271,["0123456789abcdef0123456789abcdef"]=1256165764}do
  check(require(S.Domain.CountryFleetSeed).fromCountry(seed)==expected,"Independent byte-FNV seed vector")
 end
 local c=fixtures.built.country;local gasId=c.network.generatorId;local windId=c.fleet.windReceipt.generatorId
 for _,gasOn in {false,true}do for _,windOn in {false,true}do for _,cap in {0,500,2000}do
  local start=C.copy(c);start.simulation.online=gasOn;start.fleet.units[gasId].on=gasOn
  start.fleet.units[windId].on=windOn;start.fleet.units[windId].capKW=cap;start.fleet.windState={on=windOn,capKW=cap}
  V.country(start,scalar)
  local n=Network.create(start,3000);local report=Solver.solve(n,start.simulation.step)
  local after=Ledger.settle(start,report);V.country(after,scalar)
  check(equal(Ledger.settle(start,Solver.solve(n,start.simulation.step)),after),"Deterministic financial replay")
  check(report.generatedKW==report.deliveredKW and report.requestedKW==3750,"Two-sink conservation")
  local potential=math.min(cap,Wind.potential(start.fleet.windSeed,start.fleet.windRegion,start.simulation.step))
  check(report.sources[windId]==(if windOn then potential else 0),"Cheapest available wind used first")
  check(report.sources[gasId]==(if gasOn then 3750-report.sources[windId]else 0),"Gas backfills actual residual")
  check(after.fleet.units[windId].onlineSteps-start.fleet.units[windId].onlineSteps==(if windOn then 1 else 0),"Independent wind On cost")
  check(after.economy.baseSalesMinor-start.economy.baseSalesMinor==math.floor((start.economy.baseSalesRemainder+report.deliveredKW*12000)/60000),"Sales once on delivery")
  check(after.fleet.units[windId].variableExpenseMinor==0,"Zero variable wind cost")
  check(after.bank.openingGrantMinor==start.bank.openingGrantMinor and equal(after.fleet.baseline,start.fleet.baseline),"No grant or historical baseline mutation")
  if not gasOn then check(report.unmetKW>0 and report.sinks[start.construction.receipt.terminalId].unmetKW>0,"Shortfall remains visible to both sinks")end
 end end end
 local n=Network.create(c,3000)
 for _,line in n.lines do if line.id==c.fleet.windReceipt.lineId then line.connected=false end end
 local disconnected=Solver.solve(n,c.simulation.step)
 check(disconnected.sources[windId]==0 and disconnected.sources[gasId]==3750,"Disconnected wind cannot create a national energy pool")
 n=Network.create(c,3000)
 for _,source in n.sources do if source.id==gasId then source.availableKW=1000 else source.availableKW=1600 end end
 local curtailed=Solver.solve(n,c.simulation.step)
 check(curtailed.deliveredKW==2600 and curtailed.unmetKW==1150,"Capped supply shortfall conserves energy")
 local bad=C.copy(c);bad.bank.balanceMinor=0
 check(not pcall(Ledger.settle,bad,Solver.solve(Network.create(c,3000),c.simulation.step)),"No prospective revenue funds an interval")
 local unchanged=C.encode(bad,scalar);pcall(Ledger.settle,bad,curtailed)
 check(C.encode(bad,scalar)==unchanged,"Failed settlement leaves input unchanged")
 local frozen=R.freeze(C.copy(c));V.country(frozen,scalar);V.country(frozen,scalar)
 check(not pcall(function()frozen.fleet.baseline.legacySimulation.history[1].delivered=0 end),"Cached baseline is deeply immutable")
 local shallow=C.copy(c);table.freeze(shallow.fleet.baseline);V.country(shallow,scalar)
 shallow.fleet.baseline.legacySimulation.history[1].delivered=100
 check(not pcall(V.country,shallow,scalar),"Shallow freeze cannot bypass historical validation")
 local before=fixtures.funded.country;local advanced=fixtures.post.country
 check(not pcall(V.transition,before,advanced,scalar),"Checkpoint cannot smuggle a wind purchase")
 local p3=C.copy(fixtures.funded);p3.schemaVersion=3;p3.country.fleet=nil
 p3.country.bank.ledgerVersion=3;p3.country.bank.windConstructionSpentMinor=nil;p3.country.economy.economyVersion=1
 local Old=require(S.Domain.ConstructionCountry);local New=require(S.Domain.FleetCountry)
 local a=Old.restore(p3,fixtures.world,"legacy");local b=New.restore(fixtures.funded,fixtures.world,"fleet")
 for i=1,25 do
  a=Old.advance(a,fixtures.world,3);b=New.advanceLegacy(b,fixtures.world,3)
  local current=New.capture(fixtures.world,b);current.fleet=nil;current.bank=C.copy(current.bank)
  current.bank.ledgerVersion=3;current.bank.windConstructionSpentMinor=nil;current.economy=C.copy(current.economy);current.economy.economyVersion=1
  check(equal(current,Old.capture(fixtures.world,a)),"Unchanged no-wind two-sink historical path")
 end
 print("OWNED_FLEET_ACCOUNTING_PASS",checks)
end
