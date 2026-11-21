--!strict
-- Counterfactual cost analysis only. Never changes a catalogue, profile or save.
-- Payback uses actual exact-solver output and original integer billing carries.
return function()
 local S=game.ServerScriptService.Server;local H=game:GetService("HttpService")
 local C=require(S.Domain.ProfileCodec);local R=require(S.Domain.FleetRecord)
 local Project=require(S.Domain.WindProject);local Network=require(S.Domain.CountryFleetNetwork)
 local Solver=require(S.Operations.FleetSolver);local Demand=require(S.World.DemandModel)
 local Wind=require(S.Operations.OperationsWind);local studies={};local checks=0
 local function candidate(country:any,world:any,price:number,districtStep:number)
  local c=C.copy(country);local start=country.simulation.step;local node,line=Project.assets(c)
  -- An unsaved analytical network only: no forged purchase receipt is validated
  -- or sent to ProfileService. Electrical topology is the approved fixed asset.
  table.insert(c.deltas.builtNodes,node);table.insert(c.deltas.builtLines,line)
  c.fleet.windReceipt={generatorId=node.id,lineId=line.id}
  c.fleet.units[node.id]={on=true,capKW=2000}
  local gasId=c.network.generatorId;local initialGas=country.fleet.units[gasId]
  local gasWith=initialGas.generatedKwMinutes;local gasWithout=gasWith
  local beforeGasExpense=initialGas.variableExpenseMinor;local windOutput=0;local benefit=0
  local dayBenefit=0;local dayWind=0;local calm=0;local minWind=2000;local maxWind=0
  local payback=0;local dayMinBank=country.bank.balanceMinor-price;local bank=dayMinBank
  local salesMeter=country.economy.deliveredKwMinutes;local oldSales=country.economy.baseSalesMinor
  local oldGasFixed=initialGas.fixedExpenseMinor;local oldWindFixed=0;local oldGasVariable=beforeGasExpense
  for i=1,10080 do
   c.simulation.step=start+i-1
   local kw=math.floor(Demand.atStep(c.simulation.step,world.meanTemperatureCentiC,1000).demandMW*1000+.5)
   local n=Network.create(c,kw);local actual=Solver.solve(n,c.simulation.step)
   local noWind=C.copy(n);for _,source in noWind.sources do if source.id==node.id then source.availableKW=0 end end
   local reference=Solver.solve(noWind,c.simulation.step)
   assert(actual.deliveredKW==reference.deliveredKW and actual.unmetKW==0,"Gas backup preserves delivery");checks+=1
   gasWith+=actual.sources[gasId];gasWithout+=reference.sources[gasId];windOutput+=actual.sources[node.id]
   local variable=R.amount(gasWith,8000);local baselineVariable=R.amount(gasWithout,8000)
   local windFixed=R.amount(i*1000,600);benefit=baselineVariable-variable-windFixed
   local gasFixed=R.amount((initialGas.onlineSteps+i)*1000,1000)
   salesMeter+=actual.deliveredKW;local sales=R.amount(salesMeter,12000)
   bank+=sales-oldSales-(variable-oldGasVariable)-(gasFixed-oldGasFixed)-(windFixed-oldWindFixed)
   oldSales=sales;oldGasVariable=variable;oldGasFixed=gasFixed;oldWindFixed=windFixed
   if i<=1440 then
    dayMinBank=math.min(dayMinBank,bank)
    local potential=Wind.potential(c.fleet.windSeed,c.fleet.windRegion,c.simulation.step)
    minWind=math.min(minWind,potential);maxWind=math.max(maxWind,potential);if potential<75 then calm+=1 end
   end
   if i==1440 then dayBenefit=benefit;dayWind=windOutput end
   if payback==0 and benefit>=price then payback=i end
   if i>=1440 and payback>0 then break end
   if i%120==0 then task.wait()end
  end
  assert(dayMinBank>=25000 and payback>0,"Candidate buffer and bounded observed payback")
  local row={seed=country.recipe.seed,priceCredits=price/100,affordableStep=start,afterDistrictIntervals=start-districtStep,
   bankBeforeMinor=country.bank.balanceMinor,bankAfterMinor=country.bank.balanceMinor-price,
   minimumFirstDayBankMinor=dayMinBank,firstDaySavingsMinor=dayBenefit,firstDayWindKwMinutes=dayWind,
   paybackIntervals=payback,potentialMinKW=minWind,potentialMaxKW=maxWind,below75KWIntervals=calm}
  table.insert(studies,row);print("FLEET11_PRICE",H:JSONEncode(row))
 end
 require(script.Parent["OwnedFleetProgression.spec"])(candidate)
 assert(Project.PRICE==400000,"Study never changes approved price")
 print("[Fleet11 price study] PASS",checks,#studies,"counterfactual analysis; production price remains 4000")
 return studies
end
