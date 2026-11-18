--!strict
local RunService=game:GetService("RunService")
local App=require(script.Parent.Parent.Controllers.AppController)
local ViewModel=require(script.Parent.LiveViewModel)
local C=require(script.Parent.Parent.Views.Components)
local Theme=require(script.Parent.Parent.Theme)
local Bank=require(script.Parent.BankPresentation)
local Trace=require(game.ReplicatedStorage.Shared.Util.SnapshotTrace)
local Client={}
function Client.mount(playerGui:PlayerGui,profile:string?)
 local economic=profile=="P3b"
 local persistent=profile=="P3a" or economic
 local generated=profile=="P2b" or persistent
 local profileName=if economic then "P3b" elseif persistent then "P3a" elseif generated then "P2b" else "P2a"
 assert(RunService:IsStudio() and game.GameId==10776833313,profileName.." Test only")
 local folder=game:GetService("ReplicatedStorage"):WaitForChild(if economic then "P3bSimulation" elseif persistent then "P3aSimulation" elseif generated then "P2bSimulation" else "P2aSimulation",5)
 assert(folder,profileName.." server unavailable")
 local intent=folder:WaitForChild("Intent") :: RemoteEvent
 local remote=folder:WaitForChild("Snapshot") :: RemoteEvent
 local current:any=nil;local lastReceived=0;local app:any=nil;local destroyed=false
 local pending:number?=nil;local pendingAt=0;local nextSequence=1;local message=""
 local loading:ScreenGui?=nil;local loadingLabel:TextLabel?=nil
 if persistent then
  local loadingGui=Instance.new("ScreenGui");loadingGui.Name="P3aLoading";loadingGui.ResetOnSpawn=false
  loading=loadingGui
  local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1)
  loadingLabel=label
  label.BackgroundColor3=Theme.background;label.TextColor3=Theme.text
  label.TextWrapped=true;label.TextSize=18;label.Text="Loading country · Isolated persistence proof"
  label.Parent=loadingGui;loadingGui.Parent=playerGui
 end
 local update:(()->())?=nil
 local connection=remote.OnClientEvent:Connect(function(snapshot:any)
  if destroyed or type(snapshot)~="table" or snapshot.version~=1 then return end
  if snapshot.loadState then
   if loadingLabel then loadingLabel.Text="Country "..snapshot.loadState.state.." · "..tostring(snapshot.loadState.storage).." storage proof"end
   return
  end
  Trace.record("received",snapshot)
  if generated and not current and not snapshot.world then Trace.record("drop:missingWorld",snapshot);return end
  if current and (snapshot.epoch~=current.epoch or snapshot.revision<current.revision) then Trace.record("drop:ordering",snapshot);return end
  if generated and not snapshot.world and current then snapshot.world=current.world end
  Trace.record("accepted",snapshot)
  current=snapshot;lastReceived=os.clock();nextSequence=snapshot.nextSequence
  if pending and snapshot.ackSequence>=pending then
   pending=nil;message=if snapshot.outcome=="Accepted" then (if persistent then "Applied live; awaiting checkpoint" else "Confirmed by server") else "Server: "..snapshot.outcome
  end
  if update then update() end
 end)
 Trace.record("subscribe")
 intent:FireServer({version=1,kind="Sync"})
 local start=os.clock()
 while not current and os.clock()-start<(if persistent then 60 else 6) do task.wait(.5);intent:FireServer({version=1,kind="Sync"}) end
 if loading then loading:Destroy()end
 if not current then connection:Disconnect();error(profileName.." snapshot unavailable; no live values shown") end
 app=App.mount(playerGui,ViewModel.create(current))
 Trace.record("viewModel:mounted",current)
 local view=app.view
 local generatorId=if generated then current.generatorId else "station"
 local townId=if generated then current.demandId else "capital"
 local subId="junction";local townName="Westhaven"
 for _,node in current.nodes do if node.kind=="Substation" then subId=node.id elseif node.kind=="Settlement" then townName=node.name end end
 view.gui:SetAttribute("P3aFake",persistent and not economic and current.save.storage=="Fake")
 view.gui:SetAttribute("P3bFake",economic)
 view.gui:SetAttribute("P3aReal",persistent and current.save.storage=="Real")
 view.gui:SetAttribute("P2bLive",generated and not persistent)
 view.gui:SetAttribute("P2aLive",not generated)
 view.map.terrain.setReplacements({["art1:0:0:southbank"]=true,["art1:0:0:eastmere"]=true})
 for _,n in current.nodes do view.map.markers[n.id]:SetAttribute("AccessibleLabel",n.name.." · "..n.kind.." · live Test") end
 for _,line in view.map.linkFrames do line.Name="LiveConnection";line:SetAttribute("Illustrative",false) end
 view.drawer.buttons.Links.Text="Connections · on"
 local toggle=C.button(view.inspector.note.Parent,"Waiting for server")
 toggle.Name="GeneratorToggle";toggle.Size=UDim2.new(1,-8,0,44);toggle.LayoutOrder=3;toggle.ZIndex=11
 view.inspector.note.LayoutOrder=4;view.inspector.locate.LayoutOrder=5
 local function available():boolean return not current.suspended and os.clock()-lastReceived<3 end
 local function details():string
  local r=current.report
  if not available() then return "Simulation unavailable. Last confirmed data is stale or suspended. No client estimate replaces it." end
  return string.format("Generator: %s\nAvailable capacity: %.3g MW\nActual output: %.3g MW\nDemand: %.3g MW\nDelivered: %.3g MW\nUnserved: %.3g MW\nGeneration headroom: %.3g MW\nStatus: %s\nDelivered energy: %.4f MWh\nSimulated elapsed: %d min",if current.online then "Online" else "Offline",r.availableMW,r.outputMW,r.demandMW,r.deliveredMW,r.unmetMW,r.headroomMW,r.status,current.deliveredMWh,current.step)
 end
 local function present()
  local r=current.report;local live=available()
  view.header.identity.Text=if view.kpis.root.Visible then "POWER STATE" else (if live then string.format("%.3g / %.3g MW",r.deliveredMW,r.demandMW) else "Data unavailable")
  view.header.status.Text=if not live then "Simulation unavailable" elseif current.delayed then "Live Test · Simulation delayed" else "Live Test · "..r.status
  view.kpis.cards[2].value.Text=if live then string.format("%.3g / %.3g MW",r.deliveredMW,r.demandMW) else "Unavailable"
  view.kpis.cards[3].value.Text=if live and current.reliability>=0 then string.format("%.1f%% · %d min",current.reliability*100,current.historyMinutes) else "Unknown"
  view.kpis.cards[4].value.Text=tostring(current.population).." (fixed)"
  view.root:SetAttribute("LiveStatus",if live then r.status else "Unavailable")
  view.root:SetAttribute("LiveDeliveredMW",if live then r.deliveredMW else nil)
  toggle.Visible=app.state.selectedId==generatorId;toggle.Active=live and pending==nil;toggle.Selectable=toggle.Active
  toggle.Text=if not live then "Control unavailable" elseif pending then "Awaiting server…" elseif current.online then "Switch generator Off" else "Switch generator On"
  toggle:SetAttribute("AccessibleLabel",toggle.Text)
  local id=app.state.selectedId
  view.inspector.title.Text=if id==generatorId then "Starter Generator" elseif id==subId then "Central Substation" elseif id==townId then townName else "Live grid overview"
  view.inspector.tag.Text=profileName.." · Server-authoritative Test"
  view.inspector.body.Text=details()..(if id==subId then "\nSubstation rating: 10 MW" elseif id==townId then "\nPopulation: 1,000 fixed fixture residents" else "")
  view.inspector.note.Text=message.."\nSession only. Bank is a placeholder; no finance, growth or saving. Terrain is cosmetic. Headroom is generation capacity, not guaranteed network reserve."
  if persistent then
   local save=current.save
   view.inspector.note.Text=message.."\n"..save.storage.." storage · "..save.state.." · last confirmed revision "..tostring(save.savedRevision or "none").."\nBank: 0 Credits. No income or spending. "..(if save.storage=="Fake" then "Stop Play loses fake saves." else "Only confirmed checkpoints are saved.")
   view.root:SetAttribute("SaveStatus",save.state)
  end
  if economic then
   view.kpis.cards[1].value.Text=Bank.compact(current)
   view.kpis.buttons[1]:SetAttribute("AccessibleLabel","Live Bank: "..Bank.exact(current))
   view.inspector.note.Text=message.."\nFake storage · "..current.save.state.." · Live Bank "..Bank.exact(current).."\n"..(current.finance.economy.fundingReason or "Only confirmed financial checkpoints survive reconnect within this Play session.")
   if view.feedback.root.Visible and view.feedback.root:GetAttribute("BankOverview") then view.feedback.updateText(Bank.text(current));Trace.record("bank:rendered",current)end
  end
  if generated then
   view.header.status.Text=townName.." · "..(if not live then "Unavailable" elseif current.delayed then "Simulation delayed" else r.status)
   if persistent then view.header.status.Text..=" · "..current.save.storage.." save "..current.save.state end
   view.inspector.body.Text..=string.format("\nServer clock: %02d:%02d · %.2f°C\nClimate-driven demand · seed %s",math.floor(current.minute/60),current.minute%60,current.climate.temperatureC,string.sub(current.world.seed,1,8))
  end
  for _,demo in view.inspector.demos do demo.Visible=false end
  for i,line in view.map.linkFrames do
   local flow=r.flows[current.lines[i].id]
   line.BackgroundColor3=if live and math.abs(flow)>0 then Theme.accent else Theme.muted
   line:SetAttribute("FlowMW",if live then flow else nil)
  end
 end
 local function requestToggle()
  if not available() or pending then return end
  local sequence=nextSequence;nextSequence+=1;pending=sequence;pendingAt=os.clock();message="Awaiting confirmation"
  intent:FireServer({version=1,kind="SetGenerator",epoch=current.epoch,sequence=sequence,revision=current.controlRevision,assetId=generatorId,online=not current.online})
  present()
 end
 app.bind(toggle,requestToggle)
 local function overview(button:TextButton)
  if economic then app.showFeedback("Bank · Isolated economy proof",Bank.text(current),button);view.feedback.root:SetAttribute("BankOverview",true);Trace.record("bank:opened",current);return end
  app.showFeedback(townName.." · Live Test",details()..(if persistent then "\n\nBank: 0 Credits. "..current.save.storage.." storage; "..current.save.state..". No income or spending." else "\n\nBank: 100,000 Credits (placeholder only). Population: 1,000 fixed; no growth. No bills or saving."),button)
 end
 for _,button in {view.header.overview,view.drawer.buttons.Overview} do app.actions[button]=function()overview(button)end end
 for _,button in view.kpis.buttons do app.actions[button]=function()overview(button)end end
 for _,button in {view.header.buttons.Alerts,view.drawer.buttons.Alerts} do app.actions[button]=function()overview(button)end end
 for _,button in {view.header.buttons.Help,view.drawer.buttons.Help} do app.actions[button]=function()
  app.showFeedback(profileName.." controls","Select Starter Generator in Assets, then switch On/Off in its inspector. Server confirmation changes output. Drag to pan, +/- to zoom, Recenter to frame. Keyboard/gamepad Map focus and 44px targets remain available. "..(if economic then "Bank opens the live and confirmed financial overview. Fake saves last only within this Play session." else "Bank, terrain and future routes do not simulate finance or development."),button)
 end end
 app.actions[view.drawer.buttons.Links]=function()
  local enabled=view.map.root:GetAttribute("LinksVisible")~=true
  view.map.setOptions(view.map.root:GetAttribute("LabelsVisible")==true,enabled)
  view.drawer.buttons.Links.Text="Connections · "..(if enabled then "on" else "off")
 end
 app.setPresenter(present);update=function()app.refresh()end
 local beat=RunService.Heartbeat:Connect(function()
  if pending and os.clock()-pendingAt>3 then pending=nil;message="Confirmation delayed; refreshing server state";intent:FireServer({version=1,kind="Sync"}) end
  if os.clock()-lastReceived>=3 then present() end
 end)
 local function cleanup()
  if destroyed then return end
  intent:FireServer({version=1,kind="Unsubscribe"})
  destroyed=true;connection:Disconnect();beat:Disconnect();update=nil
 end
 view.gui.Destroying:Once(cleanup)
 return {app=app,toggle=toggle,current=function()return current end,requestToggle=requestToggle,
 destroy=function()cleanup();app.destroy()end}
end
return table.freeze(Client)
