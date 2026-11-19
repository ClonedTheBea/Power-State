--!strict
-- Presentation only: reads the bounded public snapshot, never private ledger or future physics.
local Details={}
local roles={gas="Flexible main supply. Auto dispatch uses cheaper available generation first.",wind="Weather changes with simulated time. Unused potential is curtailed and earns nothing.",peak="Backup for shortages. On pays standby cost even at zero output."}
function Details.create(app:any,current:()->any,elapsed:()->number):any
 local feedback=app.view.feedback
 local function refresh()
  local kind=feedback.root:GetAttribute("OperationsDetail")
  if not feedback.root.Visible or type(kind)~="string" then return end
  local s=current();local rows={}
  if kind=="Bank" then
   rows={"BALANCE",string.format("Live Bank  %.2f Credits\nConfirmed checkpoint  %.2f Credits\nOperating buffer  250.00 Credits",s.bankMinor/100,s.savedBankMinor/100),"",
    "OPERATING TOTALS",string.format("Electricity sales  %.2f Credits\nGenerator expenses  %.2f Credits\nNet operating earnings  %.2f Credits",s.salesMinor/100,s.expensesMinor/100,(s.salesMinor-s.expensesMinor)/100),"",
    "INVESTMENT",string.format("Capital construction  %.2f Credits",s.capitalExpenseMinor/100),"",
    "SERVICE HISTORY",string.format("Lifetime energy served  %.1f%%\nDelivered / requested  %.3f / %.3f MW\nDispatchable headroom  %.3f MW",s.reliability*100,s.deliveredKW/1000,s.demandKW/1000,s.headroomKW/1000),"",
    "Capital is separate from operating earnings. Headroom excludes wind and does not guarantee delivery through a constrained feeder. Exact financial carries remain server-owned. Stop Play discards temporary fake saves."}
  elseif kind=="Alerts" then
   rows={"OPERATIONAL ALERTS", "Last command: "..s.outcome,""}
   for _,alert in s.alerts do table.insert(rows,alert)end
   if #s.alerts==0 then table.insert(rows,"No active operational alerts.")end
   if s.reason then table.insert(rows,s.reason)end
   table.insert(rows,"\nRetry only after resolving the cause. Suspended intervals earn no energy or Credits; no missed-time catch-up occurs.")
  elseif kind=="Forecast" then
   rows={"CONDITIONAL · issued minute "..s.forecast.step,"Unchanged controls · capacity estimate, not a routed solve","","OFFSET   DEMAND / WIND / AVAILABLE (MW)"}
   for _,v in s.forecast.samples do
    table.insert(rows,string.format("+%d min   %.2f / %.2f / %.2f%s%s",v.offset,v.demandKW/1000,v.windKW/1000,v.availableKW/1000,if v.capacityShortfallKW>0 then " · supply short" else "",if v.branchLimited then " · East constrained" else ""))
   end
   table.insert(rows,"\nFalling wind may require gas or peaker headroom. More generation cannot widen a constrained feeder. Caps limit auto dispatch; forecasts are not delivery guarantees.")
  else
   for _,v in s.fleet do if v.id==kind then
    rows={v.name,string.format("%s\nLast output  %.3f MW\nReady capacity  %.3f MW\nOutput cap  %.3f MW\nInstalled  %.3f MW",if v.on then "On" else "Off",v.outputKW/1000,v.availableKW/1000,v.capKW/1000,v.installedKW/1000),"",
     string.format("OPERATING COST\n%.0f Credits/MWh + %.0f Credits/hour On\nVariable total  %.2f Credits\nFixed total  %.2f Credits",v.variableMinorPerMWh/100,v.fixedMinorPerHour/100,v.variableExpenseMinor/100,v.fixedExpenseMinor/100),"",roles[v.id]}
    if v.id=="wind" then table.insert(rows,string.format("Potential %.3f MW · curtailed %.3f MW",v.potentialKW/1000,v.curtailedKW/1000))end
    table.insert(rows,"Controls affect the next dispatch. Output belongs to the last completed interval. No offline generation.")
   end end
  end
  table.insert(rows,"\n"..(if elapsed()>=3 then "CONNECTION DELAYED · last received values" else "Live server values").." · completed minute "..s.step)
  feedback.updateDetails(table.concat(rows,"\n"))
 end
 local function open(kind:string,source:GuiButton)
  app.showFeedback(if kind=="Bank" then "Bank · Operations Training" elseif kind=="Forecast" then "Demand & wind forecast" elseif kind=="Alerts" then "Operational alerts" else "Generator details","",source)
  feedback.root:SetAttribute("OperationsDetail",kind);refresh()
 end
 return {open=open,refresh=refresh}
end
return table.freeze(Details)
