--!strict
if not game.ReplicatedStorage:GetAttribute("OperationsV13") or game.ReplicatedStorage:GetAttribute("OperationsV13")=="Server" then return end
assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Test only")
local R=game:GetService("RunService"); local G=game:GetService("GuiService")
local Client=script.Parent.Parent.Client.Simulation
local First=require(Client.ConstructionClient);local Operations=require(Client.OperationsClient)
local function waitFor(f:()->boolean,seconds:number)
 local t=os.clock();repeat if f() then return end;R.Heartbeat:Wait() until os.clock()-t>seconds;error("V13 readiness deadline")
end
if game.ReplicatedStorage:GetAttribute("OperationsV13")=="All" then
 waitFor(function()return game.ReplicatedStorage:GetAttribute("OperationsV13ServerReady")==true end,120)
 require(script.Parent["Operations.spec"])() elseif game.ReplicatedStorage:GetAttribute("OperationsV13")=="Capture" or game.ReplicatedStorage:GetAttribute("OperationsV13")=="Foundation" then
 require(script.Parent["Operations.spec"])() else
 waitFor(function()return First.active()~=nil end,60)
 local first=First.active();first.app.actions[first.app.view.navigation.buttons.Infrastructure](); first.app.actions[first.directory.training]()
 waitFor(function()return Operations.active()~=nil and Operations.active().app~=nil end,15)
end
local live=Operations.active();local app=live.app;local ui=live.ui
waitFor(function()return live.current().step>=2 end,8)
if game.ReplicatedStorage:GetAttribute("OperationsV13")=="Capture" then
 live=Operations.active();app=live.app;ui=live.ui
 app.back();app.navigate("Infrastructure")
 for _,entry in {{name="desktop",size=Vector2.new(1280,580)},{name="tablet",size=Vector2.new(1024,580)},{name="portrait",size=Vector2.new(390,580)},{name="landscape",size=Vector2.new(844,390)}}do
  local size=entry.size
  app.view.root.Size=UDim2.fromOffset(size.X,size.Y);app.refresh();ui.panel.CanvasPosition=Vector2.zero
  R.RenderStepped:Wait();R.RenderStepped:Wait()
  print("[Operations V13 capture] "..entry.name)
  task.wait(15)
 end
 app.view.root.Size=UDim2.fromScale(1,1);app.refresh()
 print("[Operations V13 capture] COMPLETE")
 return
end
local counts:any={snapshots=0,layouts=0,textChanges=0,canvasChanges=0,added=0,removed=0,focusChanges=0,scrollChanges=0,refreshes=0,cpuMs=0,peakMs=0}
local connections={}
local function watch(signal:any,f:any)table.insert(connections,signal:Connect(f))end
local oldPresent=app.present
local oldRefresh=app.refresh
app.refresh=function()local t=os.clock();oldRefresh();local ms=(os.clock()-t)*1000;counts.refreshes+=1;counts.cpuMs+=ms;counts.peakMs=math.max(counts.peakMs,ms) end
if oldPresent then app.present=function()local t=os.clock();oldPresent();local ms=(os.clock()-t)*1000;counts.refreshes+=1;counts.cpuMs+=ms;counts.peakMs=math.max(counts.peakMs,ms) end end
local oldLayout=app.view.applyLayout
app.view.applyLayout=function(...)counts.layouts+=1;return oldLayout(...)end
watch(game.ReplicatedStorage.OperationsTraining.Snapshot.OnClientEvent,function()counts.snapshots+=1 end)
watch(app.view.gui.DescendantAdded,function()counts.added+=1 end)
watch(app.view.gui.DescendantRemoving,function()counts.removed+=1 end)
watch(G:GetPropertyChangedSignal("SelectedObject"),function()counts.focusChanges+=1 end)
for _,row in ui.fleet do watch(row.text:GetPropertyChangedSignal("Text"),function()counts.textChanges+=1 end)end
watch(ui.panel:GetPropertyChangedSignal("AbsoluteCanvasSize"),function()counts.canvasChanges+=1 end)
watch(ui.panel:GetPropertyChangedSignal("CanvasPosition"),function()counts.scrollChanges+=1 end)
local function sample(label:string,open:()->())
 open();R.RenderStepped:Wait();R.RenderStepped:Wait();R.RenderStepped:Wait()
 local scroll=if app.view.feedback.root.Visible then app.view.feedback.root.Message else ui.panel
 scroll.CanvasPosition=Vector2.new(0,math.min(120,math.max(0,scroll.AbsoluteCanvasSize.Y-scroll.AbsoluteSize.Y)))
 local focus=if app.view.feedback.root.Visible then app.view.feedback.close else ui.fleet.gas.toggle
 app.keyboard.focus(focus);R.RenderStepped:Wait();R.RenderStepped:Wait()
 local startScroll=scroll.CanvasPosition;local startFocus=G.SelectedObject;local initialStep=live.current().step
 counts.peakMs=0;local before=table.clone(counts);local measure=ui.metrics.textMeasurements+app.view.feedback.metrics.textMeasurements
 local t=os.clock();local maxDrift=0;local focusLost=false
 while os.clock()-t<12 do R.RenderStepped:Wait();maxDrift=math.max(maxDrift,(scroll.CanvasPosition-startScroll).Magnitude);focusLost=focusLost or G.SelectedObject~=startFocus end
 local report:any={panel=label,seconds=os.clock()-t,scrollDrift=maxDrift,focusLost=focusLost,steps=live.current().step-initialStep,measurements=ui.metrics.textMeasurements+app.view.feedback.metrics.textMeasurements-measure}
 for k,v in counts do report[k]=v-before[k]end
 print("[Operations V13 stability] "..game:GetService("HttpService"):JSONEncode(report))
 if game.ReplicatedStorage:GetAttribute("OperationsV13")~="Baseline" then
  assert(report.added==0 and report.removed==0,"Stable component tree")
  assert(maxDrift<1 and not focusLost,"Live updates retain scroll and focus")
  assert(report.steps>0 and report.snapshots>0,"Authoritative progression remains live")
  assert(report.layouts==0,"Snapshots do not perform shell layout")
 end
end
sample("fleet",function() app.navigate("Infrastructure")end)
sample("generator details",function()app.actions[ui.fleet.wind.details]()end)
app.back()
sample("forecast",function()app.actions[ui.forecastButton]()end)
app.back()
sample("Bank",function()app.actions[app.view.header.overview]()end)
app.back()
sample("reinforcement",function()app.actions[live.investment.review]()end)
app.back()
for _,c in connections do c:Disconnect()end
app.refresh=oldRefresh;app.present=oldPresent;app.view.applyLayout=oldLayout
print("[Operations V13 stability] COMPLETE "..tostring(game.ReplicatedStorage:GetAttribute("OperationsV13")))

if game.ReplicatedStorage:GetAttribute("OperationsV13")=="All" then
 require(script.Parent["OperationsInteraction.spec"])()
 require(script.Parent["OperationsRemote.spec"])()
 require(script.Parent["ReinforcementJourney.spec"])()
 live=Operations.active();app=live.app;ui=live.ui
 app.back();app.navigate("Infrastructure")
 for _,entry in {{name="desktop",size=Vector2.new(1280,580)},{name="tablet",size=Vector2.new(1024,580)},{name="portrait",size=Vector2.new(390,580)},{name="landscape",size=Vector2.new(844,390)}}do
  local size=entry.size
  app.view.root.Size=UDim2.fromOffset(size.X,size.Y);app.refresh();ui.panel.CanvasPosition=Vector2.zero
  R.RenderStepped:Wait();R.RenderStepped:Wait()
  print("[Operations V13 capture] "..entry.name)
  task.wait(15)
 end
 app.view.root.Size=UDim2.fromScale(1,1);app.refresh()
 print("[Operations V13 final] COMPLETE; normal fake journey and captures")
end
