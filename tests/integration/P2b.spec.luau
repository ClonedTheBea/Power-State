--!strict
return function(playerGui:PlayerGui)
 local Client=require(script.Parent.Parent.Client.Simulation.SimulationClient)
 local RunService=game:GetService("RunService")
 local count=0;local function check(ok:boolean,label:string)assert(ok,label);count+=1 end
 local existing=playerGui:FindFirstChild("PowerStateShell");if existing then existing:Destroy() end
 local live=Client.mount(playerGui,"P2b");local app=live.app;local generatorId=live.current().generatorId
 local function settle()for _=1,4 do RunService.RenderStepped:Wait() end end
 local function waitState(online:boolean)
  local start=os.clock();repeat RunService.Heartbeat:Wait() until live.current().online==online or os.clock()-start>5
  check(live.current().online==online,"Real remote confirmation");settle()
 end
 local ok,problem=xpcall(function()
  settle();if not live.current().online then live.requestToggle();waitState(true) end
  check(live.current().report.deliveredMW==live.current().report.demandMW,"Real server supply")
  check(#live.current().nodes==3 and #live.current().lines==2,"Only starter graph")
  check(not game:GetService("ReplicatedStorage"):FindFirstChild("GridSolver",true),"Solver not replicated")
  local pool=#app.view.map.root:GetDescendants()
  check(pool<=600,"Map budget")
  for _,size in {{1366,704},{360,580},{640,300},{768,960}} do
   app.view.root.Size=UDim2.fromOffset(size[1],size[2]);settle();app.selectAsset(generatorId);settle()
   check(live.toggle.Visible and live.toggle.Size.Y.Offset>=44,"Accessible inspector action")
   check(app.actions[live.toggle]~=nil,"Keyboard/gamepad action registered")
   app.mapController.pan(30,10);app.mapController.changeZoom(.1)
   local x,y,z=app.view.map.root:GetAttribute("CameraX"),app.view.map.root:GetAttribute("CameraY"),app.view.map.root:GetAttribute("CameraZoom")
   app.actions[live.toggle]();waitState(false)
   check(live.current().report.deliveredMW==0 and live.current().report.unmetMW==live.current().report.demandMW,"Complete supply loss")
   check(app.state.selectedId==generatorId and app.state.inspectorStage~="closed","Inspector preserved")
   check(app.view.map.root:GetAttribute("CameraX")==x and app.view.map.root:GetAttribute("CameraY")==y and app.view.map.root:GetAttribute("CameraZoom")==z,"Snapshot preserves camera")
   check(app.view.root:GetAttribute("LiveDeliveredMW")==0,"Responsive live KPI")
   task.wait(.6);app.actions[live.toggle]();waitState(true)
   check(live.current().report.deliveredMW==live.current().report.demandMW and live.current().report.unmetMW==0,"Supply restored")
   check(string.find(app.view.kpis.cards[1].label.Text,"PREVIEW")~=nil,"Bank explicitly placeholder")
   check(string.find(app.view.kpis.cards[4].label.Text,"FIXED")~=nil,"Population not growth")
   app.navigate("Government");app.navigate("Map");check(app.state.selectedId==generatorId,"Navigation selection")
   app.actions[app.view.inspector.locate]();settle();app.mapController.recenter()
   check(#app.view.map.root:GetDescendants()==pool,"No snapshot/resize instance growth")
  end
  check(app.view.map.root:GetAttribute("WorldWidth")==1024 and app.view.map.root:GetAttribute("WorldHeight")==1024,"Independent generated bounds")
  for _,node in live.current().nodes do
   for _,zoom in {.55,.8,1,1.4,1.8}do
    local currentZoom=app.view.map.root:GetAttribute("CameraZoom") :: number
    app.mapController.changeZoom(zoom-currentZoom);app.mapController.locate(node.x,node.y)
    local marker=app.view.map.markers[node.id]
    local x=app.view.map.root:GetAttribute("CameraX") :: number
    local y=app.view.map.root:GetAttribute("CameraY") :: number
    check(math.abs(marker.Position.X.Offset-(x+node.x*zoom))<=1 and math.abs(marker.Position.Y.Offset-(y+node.y*zoom))<=1,"World marker alignment")
    check(marker.Size.X.Offset>=44 and marker.Size.Y.Offset>=44,"44px targets at every zoom")
   end
  end
  for _,size in {{1366,704},{360,580},{768,960}}do
   app.view.root.Size=UDim2.fromOffset(size[1],size[2]);settle();app.mapController.recenter()
   local cpu,frames={},{}
   for frame=1,120 do
    local started=os.clock();app.mapController.pan(if frame%2==0 then 8 else -8,0)
    table.insert(cpu,(os.clock()-started)*1000)
    table.insert(frames,RunService.RenderStepped:Wait()*1000)
   end
   table.sort(cpu);table.sort(frames)
   print(string.format("[P2b rendering] %dx%d CPU p50/p95 %.4f/%.4fms frame %.2f/%.2fms map %d",size[1],size[2],cpu[60],cpu[114],frames[60],frames[114],pool))
  end
  local before=live.current().deliveredMWh;task.wait(2.2)
  check(live.current().deliveredMWh>before,"Actual server energy advances")
  print(string.format("[Power State P2b GUI] PASS: %d assertions; map %d descendants",count,pool))
 end,function(err:unknown):string return debug.traceback(tostring(err)) end)
 live.destroy();check(not playerGui:FindFirstChild("PowerStateShell"),"Cleanup")
 if not ok then error(tostring(problem)) end
 local remount=Client.mount(playerGui,"P2b");check(remount.current().online,"Remount sync preserves server state");remount.destroy()
 require(script.Parent.Parent.Client.Controllers.AppController).mount(playerGui)
 return count
end
