--!strict
-- Existing aggregate statement shape is retained. Gas's 8000/60000 tariff
-- leaves at most eight possible kW-minute meter values per posted minor unit.
-- Check feasible per-unit decomposition without inventing per-row source data.
local R=require(script.Parent.FleetRecord)
local Statements={}
function Statements.validate(c:any)
 local e=c.economy;local gas=c.fleet.units[c.network.generatorId]
 local delivered,online,variable=0,0,0
 for _,row in e.statements do delivered+=row.deliveredKwMinutes;online+=row.onlineSteps;variable+=row.variableExpenseMinor end
 local before=e.deliveredKwMinutes-delivered;local gasOnline=e.onlineSteps-online
 local posted=gas.variableExpenseMinor-variable
 R.integer(before,0,e.deliveredKwMinutes);R.integer(gasOnline,0,e.onlineSteps);R.integer(posted,0,gas.variableExpenseMinor)
 local possible={}
 for meter=math.ceil(posted*7.5),math.ceil((posted+1)*7.5)-1 do
  if meter<=before then possible[meter]=true end
 end
 local windOnline=0
 for _,row in e.statements do
  local a=R.amount(before,12000);before+=row.deliveredKwMinutes;local b=R.amount(before,12000)
  assert(row.baseSalesMinor==b-a,"Fleet statement sales carry")
  local fixedA=R.amount(gasOnline*1000,1000);gasOnline+=row.onlineSteps;local fixedB=R.amount(gasOnline*1000,1000)
  local windMinutes=(row.fixedExpenseMinor-(fixedB-fixedA))/10
  local eligible=if c.fleet.windReceipt then math.max(0,row.endStep-math.max(row.startStep,c.fleet.windReceipt.step))else 0
  R.integer(windMinutes,0,eligible);windOnline+=windMinutes
  posted+=row.variableExpenseMinor
  local nextPossible={}
  for meter=math.ceil(posted*7.5),math.ceil((posted+1)*7.5)-1 do
   for prior in possible do
    local gasOutput=meter-prior;local windOutput=row.generatedKwMinutes-gasOutput
    if gasOutput>=0 and gasOutput<=row.onlineSteps*5000 and windOutput>=0 and windOutput<=windMinutes*1600 then
     nextPossible[meter]=true;break
    end
   end
  end
  assert(next(nextPossible)~=nil,"Impossible per-source statement costs/energy")
  possible=nextPossible
 end
 assert(possible[gas.generatedKwMinutes],"Statement gas meter reconciliation")
 if c.fleet.windReceipt then
  local unit=c.fleet.units[c.fleet.windReceipt.generatorId]
  local start=if #e.statements>0 then e.statements[1].startStep else c.simulation.step
  R.integer(unit.onlineSteps-windOnline,0,math.max(0,start-c.fleet.windReceipt.step))
 else assert(windOnline==0,"No historic wind expense")end
end
return table.freeze(Statements)
