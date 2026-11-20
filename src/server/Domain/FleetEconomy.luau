--!strict
-- Whole-country pure settlement. No persistence, wall clock, or client input.
local R=require(script.Parent.FleetRecord)
local Ledger={}
function Ledger.reservation(c:any):number
 local total=0
 for id,u in c.fleet.units do
  if u.on then
   local gas=id==c.network.generatorId
   total+=math.floor((u.variableExpenseRemainder+u.capKW*(if gas then 8000 else 0))/60000)
   total+=math.floor((u.fixedExpenseRemainder+(if gas then 1000000 else 600000))/60000)
  end
 end
 return total
end
function Ledger.settle(c:any,report:any):any
 local step=c.simulation.step
 assert(c.economy.lastSettledStep==step and step<1000000000,"Duplicate/gapped billing interval")
 assert(c.bank.balanceMinor>=Ledger.reservation(c),"Unfunded fleet interval")
 local n=R.copyLive(c,c.fleet.baseline);local e=n.economy;local generated,variable,fixed=0,0,0
 local count=0;for _ in report.sources do count+=1 end
 local expected=0
 for id,u in n.fleet.units do
  expected+=1;local gas=id==n.network.generatorId;local output=report.sources[id]
  R.integer(output,0,if u.on then u.capKW else 0)
  u.generatedKwMinutes+=output;u.onlineSteps+=if u.on then 1 else 0
  local a,b=R.amount(u.generatedKwMinutes,if gas then 8000 else 0)
  local x,y=R.amount(u.onlineSteps*1000,if gas then 1000 else 600)
  variable+=a-u.variableExpenseMinor;fixed+=x-u.fixedExpenseMinor
  u.variableExpenseMinor=a;u.variableExpenseRemainder=b;u.fixedExpenseMinor=x;u.fixedExpenseRemainder=y
  generated+=output
 end
 assert(count==expected and report.generatedKW==generated and report.deliveredKW==generated,"Exact source/delivery accounting")
 R.integer(report.requestedKW,generated,4764)
 e.lastSettledStep=step+1;e.deliveredKwMinutes+=generated;e.generatedKwMinutes+=generated
 local gas=n.fleet.units[n.network.generatorId];e.onlineSteps=gas.onlineSteps
 local sales,carry=R.amount(e.deliveredKwMinutes,12000);local postedSales=sales-e.baseSalesMinor
 e.baseSalesMinor=sales;e.baseSalesRemainder=carry;e.variableExpenseMinor+=variable;e.fixedExpenseMinor+=fixed
 e.variableExpenseRemainder=gas.variableExpenseRemainder;e.fixedExpenseRemainder=gas.fixedExpenseRemainder
 local row=e.statements[#e.statements]
 if not row or math.floor(row.startStep/60)~=math.floor(step/60)then
  row={startStep=step,endStep=step,deliveredKwMinutes=0,generatedKwMinutes=0,onlineSteps=0,baseSalesMinor=0,variableExpenseMinor=0,fixedExpenseMinor=0}
  table.insert(e.statements,row)
 end
 row.endStep=step+1;row.deliveredKwMinutes+=generated;row.generatedKwMinutes+=generated
 row.onlineSteps+=if gas.on then 1 else 0;row.baseSalesMinor+=postedSales;row.variableExpenseMinor+=variable;row.fixedExpenseMinor+=fixed
 while #e.statements>(if e.lastSettledStep%60==0 then 24 else 25)do table.remove(e.statements,1)end
 local b=n.bank;b.earnedMinor=e.baseSalesMinor;b.spentMinor=e.variableExpenseMinor+e.fixedExpenseMinor+b.constructionSpentMinor+b.windConstructionSpentMinor
 b.balanceMinor=b.openingGrantMinor+b.earnedMinor-b.spentMinor
 for _,key in {"balanceMinor","earnedMinor","spentMinor"}do R.integer(b[key],0,R.LIMIT)end
 local s=n.simulation;local requested,delivered=report.requestedKW/60000,generated/60000
 local index=s.historyIndex%1440+1;local old=s.history[index]
 s.windowRequested+=requested-(if old then old.requested else 0);s.windowDelivered+=delivered-(if old then old.delivered else 0)
 s.history[index]={requested=requested,delivered=delivered};s.historyIndex=index
 s.requestedMWh+=requested;s.deliveredMWh+=delivered;s.step+=1;s.online=gas.on
 return n
end
return table.freeze(Ledger)
