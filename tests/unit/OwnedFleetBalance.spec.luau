--!strict
return function(fixtures:any)
 local S=game.ServerScriptService.Server;local C=require(S.Domain.ProfileCodec);local R=require(S.Domain.FleetRecord)
 local Network=require(S.Domain.CountryFleetNetwork);local Ledger=require(S.Domain.FleetEconomy)
 local Solver=require(S.Operations.FleetSolver);local Demand=require(S.World.DemandModel);local V=require(S.Domain.ProfileSchema4)
 local rows={};local checks=0
 for _,mode in {"WindOff","NormalWind","Capped500","DisconnectedWind"}do
  local country=C.copy(fixtures.built.country);local wind=country.fleet.units[country.fleet.windReceipt.generatorId]
  wind.on=mode~="WindOff";wind.capKW=if mode=="Capped500"then 500 else 2000
  country.fleet.windState={on=wind.on,capKW=wind.capKW};country=R.freeze(country)
  local start=country;local at=os.clock();local windId=country.fleet.windReceipt.generatorId
  local potentialMin=2000;local potentialMax=0;local curtailed=0;local calmIntervals=0
  for i=1,1440 do
   local kw=math.floor(Demand.atStep(country.simulation.step,1700,1000).demandMW*1000+.5)
   local network=Network.create(country,kw)
   if mode=="DisconnectedWind"then for _,line in network.lines do if line.id==country.fleet.windReceipt.lineId then line.connected=false end end end
   local report=Solver.solve(network,country.simulation.step)
   local potential=require(S.Operations.OperationsWind).potential(country.fleet.windSeed,country.fleet.windRegion,country.simulation.step)
   potentialMin=math.min(potentialMin,potential);potentialMax=math.max(potentialMax,potential)
   -- 6 Credits/hour divided by 80 Credits/MWh fuel displacement = 75 kW.
   if potential<75 then calmIntervals+=1 end
   if wind.on then curtailed+=math.max(0,potential-report.sources[windId])end
   assert(report.generatedKW==report.deliveredKW and report.requestedKW==report.deliveredKW,"Retained gas capacity serves full approved daily demand")
   checks+=1;country=R.freeze(Ledger.settle(country,report))
   if i%60==0 then task.wait()end
  end
  V.country(country)
  assert(country.simulation.step==start.simulation.step+1440 and country.bank.windConstructionSpentMinor==400000,"No extra capital/grant in day replay");checks+=1
  rows[mode]={netMinor=country.bank.balanceMinor-start.bank.balanceMinor,salesMinor=country.economy.baseSalesMinor-start.economy.baseSalesMinor,
   variableMinor=country.economy.variableExpenseMinor-start.economy.variableExpenseMinor,fixedMinor=country.economy.fixedExpenseMinor-start.economy.fixedExpenseMinor,
   windKwMinutes=country.fleet.units[country.fleet.windReceipt.generatorId].generatedKwMinutes-start.fleet.units[start.fleet.windReceipt.generatorId].generatedKwMinutes,
   elapsedMs=(os.clock()-at)*1000}
  print("[Owned fleet availability]",mode,game.HttpService:JSONEncode({potentialMinKW=potentialMin,potentialMaxKW=potentialMax,
   below75KWIntervals=calmIntervals,unusedPotentialKwMinutes=curtailed}))
 end
 assert(rows.NormalWind.netMinor>rows.WindOff.netMinor,"Reference wind improves operating net");checks+=1
 assert(rows.DisconnectedWind.netMinor==rows.WindOff.netMinor-14400,"Disconnected On wind still costs exactly 144 Credits/day");checks+=1
 print("[Owned fleet balance]",game:GetService("HttpService"):JSONEncode(rows))
 print("[Owned fleet full-day replay] PASS",checks,"reference seed/phase only, not guaranteed investment returns")
 return rows
end
