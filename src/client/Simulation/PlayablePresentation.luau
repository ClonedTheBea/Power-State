--!strict
local C=require(script.Parent.Parent.Views.Components)
local Theme=require(script.Parent.Parent.Theme)
local Bank=require(script.Parent.BankPresentation)
local Presentation={}
function Presentation.attach(app:any,current:()->any,healthy:()->boolean,requestToggle:()->(),review:()->())
 local v=app.view
 local toggle=C.button(v.inspector.note.Parent,"Switch generator Off")
 toggle.Name="GeneratorToggle";toggle.Size=UDim2.new(1,-8,0,44);toggle.LayoutOrder=3;toggle.ZIndex=11
 app.bind(toggle,requestToggle)
 for _,demo in v.inspector.demos do demo.Visible=false end
 v.drawer.buttons.Links.Text="Connections · on"
 local function overview(source:TextButton)
  local s=current();local r=s.report
  local connections={"", "GRID CONNECTIONS"}
  local names={};for _,n in s.nodes do names[n.id]=n.name end;names[s.proposedNode.id]=s.proposedNode.name
  for _,line in s.lines do table.insert(connections,string.format("%s → %s: %.3f / %.0f MW",names[line.from],names[line.to],math.abs(r.flows[line.id] or 0),line.capacity))end
  if s.built then table.insert(connections,string.format("Town → district: %.3f / 1 MW",r.flows[s.proposedLine.id] or 0))end
  if s.fleet and s.fleet.built then
   table.insert(connections,string.format("Wind → substation: %.3f / 2 MW",math.abs(r.flows[s.fleet.line.id]or 0)))
   table.insert(connections,"\nFLEET OUTLOOK · current controls\nCapacity comparison, not guaranteed routed delivery or income.")
   for _,point in s.fleet.forecast or {}do
    table.insert(connections,string.format("+%d min: demand %.3f MW · wind available %.3f MW · capacity margin %+.3f MW",point.offsetMinutes,point.demandKW/1000,point.windAvailableKW/1000,point.capacityMarginKW/1000))
   end
  end
  app.showFeedback("Country overview",string.format("Delivered / demand: %.3f / %.3f MW\nUnserved: %.3f MW\nGenerator: %s\nBank: %s\n\nCustomers pay for electricity delivered. Running the generator incurs fuel and operating costs. Connect the surveyed district to serve more customers.\n\nFake saves last only while this Test server runs. Stop Play loses progress.",r.deliveredMW,r.demandMW,r.unmetMW,if s.online then "On" else "Off",Bank.exact(s))..table.concat(connections,"\n"),source)
  v.feedback.root:SetAttribute("ConstructionOverview",false);v.feedback.root:SetAttribute("ConstructionBank",false)
 end
 for _,b in {v.header.overview,v.drawer.buttons.Overview,v.kpis.buttons[2],v.kpis.buttons[3],v.kpis.buttons[4],v.header.buttons.Alerts,v.drawer.buttons.Alerts}do
  app.actions[b]=function()overview(b)end
 end
 for _,b in {v.header.buttons.Help,v.drawer.buttons.Help}do app.actions[b]=function()
  app.showFeedback("Your first connection","1. Select the generator to switch it On or Off.\n2. Watch delivered power and Bank. Customers pay for electricity; fuel and running costs are deducted.\n3. Select the surveyed district or Build. Earn a Bank of 1,250 Credits, then review the 1,000-Credit connection. Keep 250 Credits for operations.\n4. Confirm once. The district starts serving customers only after the save is confirmed.\n\nMenus keep the simulation running. Fake saves disappear when Play stops.\n\nDrag to pan; +/- to zoom; Locate or Recenter to frame. Tab / D-pad selects controls; Enter / A activates; Escape / B closes panels.",b)
  v.feedback.root:SetAttribute("ConstructionOverview",false);v.feedback.root:SetAttribute("ConstructionBank",false)
 end end
 for _,group in {v.navigation.buttons,v.navigation.bottom,v.drawer.buttons}do
  local b=group.Build
  if b then app.actions[b]=function()app.navigate("Map");app.selectAsset(current().proposedNode.id);review()end end
 end
 app.actions[v.drawer.buttons.Links]=function()
  local enabled=v.map.root:GetAttribute("LinksVisible")~=true
  v.map.setOptions(v.map.root:GetAttribute("LabelsVisible")==true,enabled)
  v.drawer.buttons.Links.Text="Connections · "..(if enabled then "on"else "off")
 end
 local function refresh()
  local s=current();local r=s.report;local selected=app.state.selectedId
  if v.kpis.root.Visible then
   local name="Your country";for _,n in s.nodes do if n.id==s.demandId then name=n.name end end
   v.header.identity.Text=(if v.header.brand.Visible then "" else "POWER STATE · ")..name
  end
  if selected==s.proposedNode.id and s.built and r.sinks[2] then
   local sink=r.sinks[2]
   v.inspector.body.Text=string.format("Connected · 250 resident-equivalent customers\nDemand: %.3f MW\nDelivered: %.3f MW\nUnserved: %.3f MW\nFeeder capacity: 1 MW",sink.requestedMW,sink.deliveredMW,sink.unmetMW)
  end
  v.gui:SetAttribute("FirstPlayableFake",true)
  v.root:SetAttribute("SaveStatus",s.save.state)
  v.header.status.Text=if not healthy()then "Updates unavailable"elseif s.suspended then "Saving · simulation suspended"else "Fake save · Stop Play loses progress"
  toggle.Visible=selected==s.generatorId
  toggle.Active=healthy() and not s.suspended;toggle.Selectable=toggle.Active
  toggle.Text=if not toggle.Active then "Control unavailable"elseif s.online then "Switch generator Off"else "Switch generator On"
  toggle:SetAttribute("AccessibleLabel",toggle.Text)
  if selected~=s.proposedNode.id then
   local node:any=nil;for _,n in s.nodes do if n.id==selected then node=n end end
   v.inspector.title.Text=if node then node.name else "Your electricity grid"
   v.inspector.tag.Text=if node then node.kind else "Country overview"
   if selected==s.generatorId then
    v.inspector.body.Text=string.format("Generator %s · 5 MW capacity\nOutput: %.3f MW\nSales: 120 Credits / MWh delivered\nFuel: 80 Credits / MWh generated\nRunning: 10 Credits / simulated hour",if s.online then "On"else "Off",r.outputMW)
   elseif node and node.kind=="Substation"then
    v.inspector.body.Text=string.format("Routes electricity to customers\nCapacity: 10 MW\nCurrent flow: %.3f MW",r.outputMW)
   else
    local sink=r.sinks[1]
    v.inspector.body.Text=string.format("1,000 residents · fixed population\nDemand: %.3f MW\nDelivered: %.3f MW\nUnserved: %.3f MW",sink.requestedMW,sink.deliveredMW,sink.unmetMW)
   end
   v.inspector.note.Text="Live Bank "..Bank.exact(s).." · "..s.save.state.."\nOnly confirmed checkpoints survive reconnect in this server. Stop Play discards fake saves."
  end
  for i,line in v.map.linkFrames do
   local id=if i<=#s.lines then s.lines[i].id else s.proposedLine.id
   local flow=r.flows[id] or 0
   line.BackgroundColor3=if healthy() and flow>0 then Theme.accent else Theme.muted
   line:SetAttribute("FlowMW",flow);line:SetAttribute("Illustrative",false)
  end
 end
 return {toggle=toggle,refresh=refresh}
end
return table.freeze(Presentation)
