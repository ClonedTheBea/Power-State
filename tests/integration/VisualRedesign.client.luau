--!strict
local mode=game.ReplicatedStorage:GetAttribute("VisualRedesignTests")
if not mode then return end
assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Visual Test only")
local R=game:GetService("RunService");local G=game:GetService("GuiService")
local Client=script.Parent.Parent.Client.Simulation
local First=require(Client.ConstructionClient);local Operations=require(Client.OperationsClient)
local function waitFor(f:()->boolean,n:number)local t=os.clock();repeat if f()then return end;R.Heartbeat:Wait()until os.clock()-t>n;error("Visual readiness deadline")end
waitFor(function()return First.active()~=nil end,60)
local first=First.active();local app=first.app;local count=0
local function check(v:boolean,m:string)assert(v,m);count+=1 end
local function layout()R.RenderStepped:Wait();R.RenderStepped:Wait();R.RenderStepped:Wait()end
local function capture(name:string)
 layout();print("[Visual capture] "..name.." safeRoot="..tostring(app.view.root.AbsoluteSize));task.wait(12)
end
for _,size in {Vector2.new(1600,840),Vector2.new(1366,704),Vector2.new(1024,720),Vector2.new(390,780),Vector2.new(844,390)}do
 app.view.root.Size=UDim2.fromOffset(size.X,size.Y);app.navigate("Infrastructure");layout()
 local d=first.directory
 check(d.root.Visible,"Real directory available")
 for _,row in d.rows do if row.button.Visible then check(row.button.AbsoluteSize.X>=44 and row.button.AbsoluteSize.Y>=44,"Directory target")end end
 app.actions[d.tabs.Generators]();check(d.rows[1].id==first.current().generatorId and not d.rows[2].button.Visible,"Actual generator filter")
 app.actions[d.rows[1].button]();app.actions[d.locate]();layout()
 check(app.state.route=="Map" and app.state.selectedId==first.current().generatorId,"Directory Locate keeps identity")
 check(#app.view.map.root:GetDescendants()<=600,"Native map budget")
 app.navigate("Infrastructure");app.actions[d.tabs.All]()
end
app.view.root.Size=UDim2.fromScale(1,1);app.navigate("Map");app.state.inspectorStage="closed";app.refresh();app.mapController.recenter()
if mode=="Screens" then
 capture("grid-desktop")
 app.selectAsset(first.current().generatorId);capture("grid-selected")
 app.actions[app.view.navigation.buttons.Build]();capture("build-review");app.back()
 app.navigate("Infrastructure");capture("infrastructure")
 app.actions[app.view.kpis.buttons[1]]();capture("bank-first-playable");app.back()
 for _,entry in {{name="grid-portrait",size=Vector2.new(390,540)},{name="grid-landscape",size=Vector2.new(844,390)},{name="grid-tablet",size=Vector2.new(1024,540)}}do
  app.view.root.Size=UDim2.fromOffset(entry.size.X,entry.size.Y);app.navigate("Map");app.state.inspectorStage="closed";app.refresh();app.mapController.recenter();capture(entry.name)
 end
 app.view.root.Size=UDim2.fromScale(1,1)
end
print("[Visual directory] PASS "..count.." assertions")
if mode=="All" then
 require(script.Parent["QuoteRefresh.spec"])(game.Players.LocalPlayer.PlayerGui);app.back()
end
-- Inspect the visible financial rows, not only their hidden canonical text.
app.actions[app.view.kpis.buttons[1]]()
for _,size in {Vector2.new(1366,704),Vector2.new(390,640),Vector2.new(844,390)}do
 app.view.root.Size=UDim2.fromOffset(size.X,size.Y);app.view.root:SetAttribute("TextScale",1.5);app.refresh();layout()
 local scroll=app.view.feedback.root.Message
 for _,row in scroll:GetChildren()do if row:IsA("Frame") and row.Visible then
  for _,label in row:GetChildren()do if label:IsA("TextLabel") and label.Visible then
   check(label.TextBounds.Y<=label.AbsoluteSize.Y+1,"Financial row text fits vertically")
   check(label.TextBounds.X<=label.AbsoluteSize.X+1,"Financial row text fits horizontally")
  end end
 end end
end
app.view.root:SetAttribute("TextScale",1);app.view.root.Size=UDim2.fromScale(1,1);app.refresh();layout()
local firstScroll=app.view.feedback.root.Message;firstScroll.CanvasPosition=Vector2.new(0,80);layout()
local bankY=firstScroll.CanvasPosition;local firstFocus=G.SelectedObject;local firstStep=first.current().step;local started=os.clock()
while os.clock()-started<12 do R.RenderStepped:Wait();check(firstScroll.CanvasPosition==bankY,"First Bank scroll retained");check(G.SelectedObject==firstFocus,"First Bank focus retained")end
check(first.current().step>firstStep,"First Bank authoritative progression");app.back()
require(script.Parent["Operations.spec"])()
local live=Operations.active();app=live.app
app.navigate("Map");app.actions[app.view.navigation.buttons.Infrastructure]();layout()
check(app.state.route=="Infrastructure" and not app.view.feedback.root.Visible,"Fleet navigation opens control room, not Alerts")
check(app.view.navigation.buttons.Build:GetAttribute("LabelOverride")=="Build","Available Build has no Later label")
require(script.Parent["OperationsInteraction.spec"])()
for _,size in {Vector2.new(1600,735),Vector2.new(1024,540),Vector2.new(390,580),Vector2.new(844,390)}do
 app.view.root.Size=UDim2.fromOffset(size.X,size.Y);app.navigate("Infrastructure");layout()
 for _,source in live.current().fleet do
  local row=live.ui.fleet[source.id]
  check(row.track:GetAttribute("OutputKW")==source.outputKW and row.track:GetAttribute("AvailableKW")==source.availableKW,"Bar uses current authoritative readings")
  local ratio=if source.availableKW>0 then math.clamp(source.outputKW/source.availableKW,0,1)else 0
  check(math.abs(row.fill.Size.X.Scale-ratio)<.00001,"Actual/available bar ratio")
  for _,b in {row.toggle,row.minus,row.plus,row.locate,row.details}do check(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44,"Fleet polish keeps targets")end
  check(row.details.Position.Y.Offset+row.details.AbsoluteSize.Y<=row.card.AbsoluteSize.Y,"Fleet controls contained")
 end
end
app.view.root.Size=UDim2.fromScale(1,1);app.refresh();layout()
if mode=="Screens" then
 app.navigate("Infrastructure");live.ui.panel.CanvasPosition=Vector2.zero;capture("operations")
 app.actions[live.ui.bank]();capture("bank-operations");app.back()
 app.actions[live.investment.review]();capture("reinforcement-review");app.back()
 app.view.root.Size=UDim2.fromOffset(390,580);app.navigate("Infrastructure");live.ui.panel.CanvasPosition=Vector2.zero;capture("operations-portrait")
 app.view.root.Size=UDim2.fromOffset(844,390);app.refresh();capture("operations-landscape")
 app.view.root.Size=UDim2.fromScale(1,1);app.refresh()
end
-- Same mounted instances across data updates; exercise the actual public snapshot stream.
for _,entry in {{name="fleet",open=function()app.navigate("Infrastructure")end},{name="Bank",open=function()app.actions[live.ui.bank]()end},{name="review",open=function()app.actions[live.investment.review]()end}}do
 entry.open();layout()
 local target=if app.view.feedback.root.Visible then app.view.feedback.close else live.ui.fleet.gas.toggle
 local scroll=if app.view.feedback.root.Visible then app.view.feedback.root.Message else live.ui.panel
 scroll.CanvasPosition=Vector2.new(0,math.min(80,math.max(0,scroll.AbsoluteCanvasSize.Y-scroll.AbsoluteWindowSize.Y)));layout()
 app.keyboard.focus(target);layout();check(G.SelectedObject==target,"Valid focus target")
 local before=scroll.CanvasPosition;local focused=G.SelectedObject;local added=0;local removed=0;local layouts=0;local calls=0;local cpu=0;local peak=0;local frames={}
 local a=app.view.gui.DescendantAdded:Connect(function()added+=1 end);local b=app.view.gui.DescendantRemoving:Connect(function()removed+=1 end)
 local old=app.present;local oldLayout=app.view.applyLayout
 app.view.applyLayout=function(...)layouts+=1;return oldLayout(...)end
 app.present=function()local t=os.clock();old();local ms=(os.clock()-t)*1000;cpu+=ms;peak=math.max(peak,ms);calls+=1 end
 local step=live.current().step;local start=os.clock()
 while os.clock()-start<12 do local dt=R.RenderStepped:Wait();table.insert(frames,dt*1000);check(G.SelectedObject==focused,"Focus retained");check((scroll.CanvasPosition-before).Magnitude<1,"Scroll retained")end
 app.present=old;app.view.applyLayout=oldLayout;a:Disconnect();b:Disconnect()
 check(added==0 and removed==0 and layouts==0,"Stable tree and data-only updates");check(live.current().step>step,"Authoritative progression")
 table.sort(frames)
 print("[Visual stability] "..game:GetService("HttpService"):JSONEncode({panel=entry.name,added=added,removed=removed,layouts=layouts,calls=calls,cpuMs=cpu,peakMs=peak,frameP95=frames[math.ceil(#frames*.95)],map=#app.view.map.root:GetDescendants(),shell=#app.view.gui:GetDescendants()}))
 app.back()
end
if mode=="All" then require(script.Parent["OperationsRemote.spec"])();require(script.Parent["ReinforcementJourney.spec"])()end
print("[Visual acceptance] COMPLETE "..mode.." checks="..count)
