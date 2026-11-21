--!strict
-- Displays owner snapshots; controls and quotes only send intent to the server.
local C=require(script.Parent.Parent.Views.Components)
local Theme=require(script.Parent.Parent.Theme)
local Bank=require(script.Parent.BankPresentation)
local Currency=require(game:GetService("ReplicatedStorage").Shared.Util.CurrencyFormat)
local Presentation={}
function Presentation.create(app:any,current:()->any,healthy:()->boolean,age:()->number,quote:(string)->(),control:(string,boolean,number)->()):any
 local v=app.view
 local review=C.button(v.inspector.note.Parent,"Review wind investment")
 review.Size=UDim2.new(1,-8,0,44);review.LayoutOrder=4;review.ZIndex=11;review.Name="WindReview"
 local toggle=C.button(v.inspector.note.Parent,"Switch wind Off")
 toggle.Size=UDim2.new(1,-8,0,44);toggle.LayoutOrder=4;toggle.ZIndex=11;toggle.Name="OwnedFleetToggle"
 local caps=C.frame(v.inspector.note.Parent,"FleetCaps");caps.BackgroundTransparency=1
 caps.Size=UDim2.new(1,-8,0,44);caps.LayoutOrder=5;caps.ZIndex=11
 local down=C.button(caps,"−100 kW");down.Size=UDim2.new(.5,-2,1,0);down.ZIndex=12
 local up=C.button(caps,"+100 kW");up.Size=UDim2.new(.5,-2,1,0);up.Position=UDim2.new(.5,2,0,0);up.ZIndex=12
 local confirm=C.button(v.feedback.root,"Refresh Quote");confirm.Name="WindConfirm";confirm.ZIndex=32
 confirm.Position=UDim2.new(0,16,1,-60);confirm.Size=UDim2.new(1,-32,0,44)
 local function selected():any return current().fleet.units[app.state.selectedId]end
 local function action():string
  local s=current();local q=s.fleet.project
  if not healthy()or s.suspended or s.fleet.built or not s.built or q.state=="Saving"or q.state=="Unavailable"then return "Disabled"end
  if not q.quoteId or q.expiresIn<=age()or q.state=="QuoteExpired"or q.state=="DrainingSave"then return "Quote"end
  if s.bankMinor>=q.priceMinor+q.bufferMinor and q.state=="Available"then return "Confirm"end
  if s.bankMinor>=q.priceMinor+q.bufferMinor and q.state=="InsufficientCredits"then return "Quote"end
  return "Disabled"
 end
 local function details():string
  local s=current();local f=s.fleet
  return string.format("%s\n\nStarter Wind Farm · 2 MW nameplate\nSurveyed western pad and 2 MW connection\nPrice: %s\nBank: %s\nConfirmed: %.2f Credits\nKeep at least 250 Credits and the next gross operating cost.\n\n%s\n\nVariable production: 0–1.6 MW under wind model v1. Gas supplies the remainder when available.\nWind cost: 0 Credits/MWh + 6 Credits/simulated hour while On. Only delivered energy earns 120 Credits/MWh. Curtailed wind earns nothing. Savings depend on actual dispatch.\n\nOne purchase per country. Closing this review cannot cancel a submitted save. Fake Test saves only.",
   if f.built then "Built · saved once"else f.project.state,Currency.format(if f.built then s.finance.bank.windConstructionSpentMinor else f.project.priceMinor),Bank.exact(s),(s.save.savedBankMinor or 0)/100,
   if s.built then "District prerequisite complete."else "Connect the new district first.")
 end
 local function open()
  quote("Quote");v.feedback.root:SetAttribute("ConstructionOverview",false);v.feedback.root:SetAttribute("ConstructionBank",false)
  app.showFeedback("Starter Wind Farm",details(),review,"info");v.feedback.root:SetAttribute("FleetReview",true)
 end
 app.bind(review,open)
 app.bind(confirm,function()local a=action();if a~="Disabled"then quote(a);confirm.Active=false;confirm.Selectable=false end end)
 app.bind(toggle,function()local u=selected();if u and healthy()and not current().suspended then control(app.state.selectedId,not u.on,u.capKW)end end)
 for button,delta in {[down]=-100,[up]=100}do app.bind(button,function()
  local u=selected();if u and button.Active then control(app.state.selectedId,u.on,u.capKW+delta)end
 end)end
 local function refresh()
  local s=current();local f=s.fleet;local wind=app.state.selectedId==f.node.id
  local u=selected();local isUnit=u~=nil and f.built
  review.Visible=wind and not f.built;review.Active=healthy();review.Selectable=review.Active
  toggle.Visible=isUnit;caps.Visible=isUnit
  local allowed=healthy()and not s.suspended
  toggle.Active=allowed;toggle.Selectable=allowed
  toggle.Text=if u and u.on then "Switch generator Off"else "Switch generator On"
  local limit=if wind then 2000 else 5000
  down.Active=allowed and u~=nil and u.capKW>0;up.Active=allowed and u~=nil and u.capKW<limit
  down.Selectable=down.Active;up.Selectable=up.Active
  if wind or isUnit then
   v.inspector.title.Text=if wind then "Starter Wind Farm"else "Gas power station"
   v.inspector.tag.Text=if wind and not f.built then "Surveyed · not built"else "Owned generation · fake Test"
   local output=if f.dispatch then f.dispatch.sources[app.state.selectedId]else nil
   local supply=if f.dispatch and f.dispatch.availableKW then string.format("Last permitted %.3f MW · unused %.3f MW",f.dispatch.availableKW[app.state.selectedId]/1000,f.dispatch.curtailedKW[app.state.selectedId]/1000)else "Availability awaiting interval"
   v.inspector.body.Text=if u then string.format("%s · cap %.1f MW\nLast completed output: %s\n%s\n%s\nControl: %s",if u.on then "On"else "Off",u.capKW/1000,
    if output then string.format("%.3f MW",output/1000)else "awaiting interval",
    supply,
    if wind then string.format("Next weather potential: %.3f MW",f.potentialKW/1000)else "80 Credits/MWh + 10 Credits/hour On",
    s.controlOutcome or "Ready")else "2 MW wind investment\n"..Currency.format(f.project.priceMinor).." · district required\nNo electricity or costs before saved construction."
   v.inspector.note.Text=if u then string.format("Produced %.3f MWh\nVariable costs %.2f · running costs %.2f Credits\n%s%s",u.generatedKwMinutes/60000,u.variableExpenseMinor/100,u.fixedExpenseMinor/100,if f.pending then "Dispatch update pending"else "Server-confirmed interval accounting",
    if wind then "\nCap is a limit, not an output target. Weather, On/Off and network delivery limit production. Keep gas available for calm periods. Wind costs 6 Credits/hour while On."else "")else "Review a fresh server quote to build."
  end
  for i=4,#v.map.linkFrames do
   local line=v.map.linkFrames[i];local flow=if f.dispatch then math.abs(f.dispatch.flowsKW[f.line.id]or 0)/1000 else 0
   line.BackgroundTransparency=if f.built then .15 else .8;line.BackgroundColor3=if flow>0 then Theme.accent else Theme.muted
   line:SetAttribute("PreviewOnly",not f.built);line:SetAttribute("FlowMW",flow)
  end
  confirm.Visible=v.feedback.root.Visible and v.feedback.root:GetAttribute("FleetReview")==true
  if confirm.Visible then
   local a=action();confirm.Active=a~="Disabled";confirm.Selectable=confirm.Active
   confirm.Text=if f.built then "Built · saved in this Test server"elseif f.project.state=="Saving"then "Checking saved result…"elseif a=="Quote"then "Refresh Quote"elseif not s.built then "Connect the district first"elseif s.bankMinor<f.project.priceMinor+f.project.bufferMinor then "Need "..Currency.format(f.project.priceMinor+f.project.bufferMinor)else "Build for "..Currency.format(f.project.priceMinor)
   local scroll=v.feedback.root.Message :: ScrollingFrame
   scroll.Position=UDim2.fromOffset(16,60);scroll.Size=UDim2.new(1,-32,1,-136);v.feedback.updateDetails(details())
  end
 end
 v.feedback.root:GetPropertyChangedSignal("Visible"):Connect(function()if not v.feedback.root.Visible then v.feedback.root:SetAttribute("FleetReview",false)end end)
 return {open=open,refresh=refresh,confirm=confirm,review=review,toggle=toggle,down=down,up=up}
end
return table.freeze(Presentation)
