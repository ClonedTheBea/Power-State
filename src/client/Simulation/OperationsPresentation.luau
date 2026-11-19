--!strict
local Theme=require(script.Parent.Parent.Theme)
local P={}
local names={gas="Central Gas",wind="Coastal Wind",peak="Reserve Peaker",sub="National Substation",a="North Customers",b="East Customers"}
local technology={gas="Gas",wind="Wind",peak="Peaker"}
local function put(object:any,key:string,value:any)if object[key]~=value then object[key]=value end end
function P.update(app:any,ui:any,s:any,healthy:boolean,pending:boolean,leaving:boolean)
 local v=app.view
 put(v.header.identity,"Text",if v.header.brand.Visible then "Operations Training" else "POWER STATE · Operations Training")
 local status=if s.status=="Suspended" then "Paused · action needed" elseif s.status=="Invalidated" then "Inputs changed" elseif s.status=="SavingInvestment" then "Saving reinforcement" else "Operating"
 put(v.header.status,"Text",if not healthy then "Connection unavailable" else status.." · minute "..s.step)
 for i,value in {string.format("%.2f Credits",s.bankMinor/100),string.format("%.3f / %.3f MW",s.deliveredKW/1000,s.demandKW/1000),string.format("%.3f MW",s.unmetKW/1000),string.format("%.3f MW",s.headroomKW/1000)}do put(v.kpis.cards[i].value,"Text",value)end
 local controls=app.state.route=="Infrastructure"
 put(ui.panel,"Visible",controls)
 for _,obj in {v.pageTitle,v.pageTag,v.pageBody,v.pageBack}do put(obj,"Visible",not controls)end
 local width,height=v.page.Parent.AbsoluteSize.X,v.page.Parent.AbsoluteSize.Y
 put(v.page,"Position",UDim2.fromOffset(0,0))
 put(v.page,"Size",if controls then UDim2.fromOffset(width,height) else UDim2.fromScale(1,1))
 local acknowledgment=if pending then "Command sent · awaiting server" elseif s.outcome=="Accepted" then "Control confirmed by server" elseif s.outcome=="StaleRevision" then "State changed · try the control again" else "Live server readings"
 put(ui.status,"Text",if leaving then "Saving and leaving…" elseif not healthy then "Connection delayed · controls unavailable" elseif s.saveBlocked then "Save uncertain · simulation suspended" else acknowledgment.."\n"..(if s.saving then "Saving checkpoint" elseif s.status=="Pending" then "Calculating next interval" else "Checkpoint confirmed"))
 put(ui.totals,"Text",if v.kpis.root.Visible then string.format("Generation %.2f MW · Available %.2f MW",s.generatedKW/1000,s.availableKW/1000)
  else string.format("Delivered %.2f / %.2f MW · Unserved %.2f MW",s.deliveredKW/1000,s.demandKW/1000,s.unmetKW/1000))
 local condition="Customers supplied\nKeep headroom available; review the forecast."
 if s.saveBlocked or s.status=="Suspended" or s.status=="Invalidated" then condition="Operation paused\nNo energy or Credits settle. Resolve the issue, then Retry."
 elseif s.unmetKW>0 and s.demandKW>s.availableKW then condition="Generation shortage · customers unserved\nReview enabled gas/peaker capacity and output caps."
 elseif s.unmetKW>0 then condition="Transmission constraint · customers unserved\nSelect East; review feeder reinforcement."
 elseif s.investment.built then condition="East reinforced · 4 MW confirmed\nCustomers supplied; keep checking available generation."
 else
  for _,sample in s.forecast.samples do if sample.capacityShortfallKW>0 then condition="Future capacity shortage\nDemand exceeds forecast supply; review gas and peaker.";break end end
 end
 if s.bankMinor<75000 and not s.saveBlocked then condition..="\nLow investment funds · retain the operating buffer." end
 put(ui.alerts,"Text",condition)
 for _,source in s.fleet do
  local row=ui.fleet[source.id]
  local state=if not source.on then "Off" elseif source.availableKW==0 then "Unavailable" elseif source.outputKW==0 then "Ready" else "Online"
  put(row.name,"Text",source.name.." · "..technology[source.id])
  put(row.output,"Text",string.format("%.2f MW",source.outputKW/1000));put(row.state,"Text",state)
  put(row.state,"TextColor3",if source.on then Theme.healthy else Theme.muted)
  local ratio=if source.availableKW>0 then math.clamp(source.outputKW/source.availableKW,0,1) else 0
  put(row.fill,"Size",UDim2.fromScale(ratio,1))
  row.track:SetAttribute("OutputKW",source.outputKW);row.track:SetAttribute("AvailableKW",source.availableKW)
  put(row.text,"Text",string.format("Ready %.2f MW · Cap %.2f MW\n%.0f Credits/MWh + %.0f/h On",source.availableKW/1000,source.capKW/1000,source.variableMinorPerMWh/100,source.fixedMinorPerHour/100))
  put(row.toggle,"Text",if source.on then "Switch Off" else "Switch On")
  for _,button in {row.toggle,row.minus,row.plus}do put(button,"Active",healthy and not pending and not leaving and not s.saving and not s.saveBlocked)end
 end
 local first,last=s.forecast.samples[1],s.forecast.samples[#s.forecast.samples]
 put(ui.forecast,"Text",string.format("Next 60 min · demand %.2f → %.2f MW\nWind %.2f → %.2f MW · issued %d",first.demandKW/1000,last.demandKW/1000,first.windKW/1000,last.windKW/1000,s.forecast.step))
 put(ui.retry,"Visible",s.status=="Suspended" or s.status=="Invalidated" or s.saveBlocked)
 put(ui.retry,"Active",healthy and not pending and not leaving and not s.saving)
 local selected=app.state.selectedId
 local line=v.map.linkFrames[5]
 if line:GetAttribute("CapacityKW")~=s.eastCapacityKW then line:SetAttribute("CapacityKW",s.eastCapacityKW)end
 put(line,"BackgroundColor3",if selected=="b" or selected=="sub" then Theme.warning else Theme.accent)
 if names[selected] then
  put(v.inspector.title,"Text",names[selected]);put(v.inspector.tag,"Text","OPERATIONS · TRAINING")
  local body=""
  for _,source in s.fleet do if source.id==selected then body=string.format("%s · Output %.3f MW\nReady %.3f MW · Cap %.2f MW\nControl room offers controls and detailed costs.",if source.on then "On" else "Off",source.outputKW/1000,source.availableKW/1000,source.capKW/1000)end end
  local sink=s.sinks[selected]
  if sink then body=string.format("Requested %.3f MW\nDelivered %.3f MW\nUnserved %.3f MW\nFeeder limit %.0f MW",sink.requestedKW/1000,sink.deliveredKW/1000,sink.unmetKW/1000,if selected=="b" then s.eastCapacityKW/1000 else 6)end
  if selected=="sub" then
   local lines={"National substation · 10 MW"}
   for _,item in {{id="gs",label="Gas",capacity=5},{id="ws",label="Wind",capacity=2},{id="ps",label="Peaker",capacity=2},{id="sa",label="North",capacity=6},{id="sb",label="East",capacity=s.eastCapacityKW/1000}}do
    table.insert(lines,string.format("%s: %.3f / %.0f MW",item.label,math.abs(s.flowsKW[item.id] or 0)/1000,item.capacity))
   end
   body=table.concat(lines,"\n")
  end
  put(v.inspector.body,"Text",body);put(v.inspector.note,"Text","Completed server interval · temporary Training country")
 end
end
return table.freeze(P)
