--!strict
return function(gui:PlayerGui,fixtures:{any})
 local Run=game:GetService("RunService")
 local App=require(script.Parent.Parent.Parent.Client.Controllers.AppController)
 local Controller=require(script.Parent.IllustratedController)
 local Ground=require(script.Parent.ContinuousGround)
 local count=0
 local function check(v:boolean,m:string)assert(v,m);count+=1 end
 local Ocean=require(script.Parent.OceanBoundary)
 for p=0,1024 do
  for _,xy in {{0,p},{1024,p},{p,0},{p,1024}} do
   local r,g,b=Ocean.colour(xy[1],xy[2],1,8)
   check(r==24 and g==53 and b==70,"All finite boundary colours exactly match background")
  end
 end
 for d=0,64 do
  local w=Ocean.weight(d,512)
  check(w>=0 and w<=1,"Bounded offshore colour shoulder")
  if d>0 then check(w>=Ocean.weight(d-1,512),"Continuous monotone shoulder")end
 end
 local r,g,b=Ocean.colour(512,512,1,2)
 check(r==33 and g==80 and b==92,"Interior ocean unchanged")
 local function textureMemory():any
  local ok,value=pcall(function()return game:GetService("Stats"):GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.GraphicsTexture)end)
  return if ok then value else "unavailable"
 end
 local function settle()for _=1,4 do Run.RenderStepped:Wait()end end
 local function mount(f:any,groundLoader:any?)
  local old=gui:FindFirstChild("PowerStateShell");if old then old:Destroy()end
  local app=App.mount(gui,f);settle();return app,Controller.attach(app,f,groundLoader)
 end
 for fi,f in fixtures do
  local before=game.HttpService:JSONEncode(f)
  local app,proof=mount(f);local map=app.view.map
  local id=f.nodes[1].id;app.selectAsset(id);settle()
  local camera={map.root:GetAttribute("CameraX"),map.root:GetAttribute("CameraY"),map.root:GetAttribute("CameraZoom")}
  proof.setLandscapeMode("Ocean")
  local deadline=os.clock()+20
  repeat Run.RenderStepped:Wait() until proof.ground().state()~="Loading" or os.clock()>deadline
  check(proof.ground().state()=="Ready","Real ground readiness")
  check(proof.ground().allocationCount()==4,"Exactly four retained chunks; source EditableImage released")
  local n=#map.root:GetDescendants();check(n<=600,"Map budget")
  for _,mode in {"Native","Illustrated","Ground","Ocean","Native","Ocean"} do
   proof.setLandscapeMode(mode);settle()
   check(#map.root:GetDescendants()==n,"Switches reuse instances")
   check(app.state.selectedId==id,"Mode preserves selected asset and inspector identity")
   check(map.markers[id].AbsoluteSize.X>=44 and map.markers[id].AbsoluteSize.Y>=44,"Accessible marker target")
   check(camera[1]==map.root:GetAttribute("CameraX") and camera[2]==map.root:GetAttribute("CameraY") and camera[3]==map.root:GetAttribute("CameraZoom"),"Mode preserves camera")
  end
  -- Real texture readiness cannot be asserted for GUI deliberately placed outside
  -- the physical Studio render target. Widths still exercise every breakpoint.
  for _,size in {Vector2.new(1366,560),Vector2.new(820,560),Vector2.new(360,560),Vector2.new(740,320)} do
   app.view.root.Size=UDim2.fromOffset(size.X,size.Y);settle()
   for _,z in {.55,.72,1,1.2,1.8,.937} do
    map.render(-127.83,-63.19,z);settle()
    local readyDeadline=os.clock()+6
    while map.root:GetAttribute("ContinuousGroundActive")~=true and os.clock()<readyDeadline do Run.RenderStepped:Wait()end
    check(map.root:GetAttribute("ContinuousGroundActive")==true,"Ground resumes after atlas readiness without camera movement")
    local cells=proof.ground().cells
    for i,im in cells do
     local x,y=(i-1)%16,math.floor((i-1)/16)
     if x<15 then check(im.AbsolutePosition.X+im.AbsoluteSize.X==cells[i+1].AbsolutePosition.X,"Integrated horizontal shared edge")end
     if y<15 then
      if im.AbsolutePosition.Y+im.AbsoluteSize.Y~=cells[i+16].AbsolutePosition.Y then
       warn("IW12C_EDGE_FAILURE",fi,size,z,i,im.AbsolutePosition,im.AbsoluteSize,cells[i+16].AbsolutePosition,im.Parent,proof.ground().state(),map.root:GetAttribute("ContinuousGroundActive"))
      end
      check(im.AbsolutePosition.Y+im.AbsoluteSize.Y==cells[i+16].AbsolutePosition.Y,"Integrated vertical shared edge")
     end
     check(im.ImageRectSize==Vector2.new(64,64),"Original cell crop")
    end
    check(#map.root:GetDescendants()==n,"Movement/resize stable instances")
   end
  end
  check(game.HttpService:JSONEncode(f)==before,"Original geography/infrastructure descriptor unchanged")
  local resources=proof.ground();app.destroy();settle()
  check(resources.allocationCount()==0,"Destroyed map releases its owned images")
  -- Synthetic denied loader, no unapproved IDs.
  local deniedApp,deniedProof=mount(f,{loadSource=function()return nil end})
  deniedProof.setLandscapeMode("Ground");settle()
  local denied=deniedProof.ground()
  check(denied.state()=="Failed" and deniedApp.view.map.root:GetAttribute("ContinuousGroundActive")==false,"Synthetic allocation denial retains Native")
  check(deniedApp.view.map.root:GetAttribute("IllustratedActive")==false,"Source failure disables illustrated decorations as well as ground")
  deniedProof.setLandscapeMode("Ocean");settle()
  check(deniedApp.view.map.root:GetAttribute("IllustratedActive")==false,"Failed cache cannot re-enable partial artwork by switching mode")
  deniedApp.destroy();settle()
  local chunkApp=mount(f);local sourceReleased=0
  local chunkDenied=Ground.attach(chunkApp.view.map,f.world,{loadSource=function()
   return {Size=Vector2.new(1024,1024),ReadPixelsBuffer=function()return buffer.create(1024*1024*4)end,Destroy=function()sourceReleased+=1 end}
  end,createChunk=function()return nil end})
  chunkDenied.setMode("Ground");local chunkDeadline=os.clock()+20
  repeat Run.Heartbeat:Wait()until chunkDenied.state()~="Loading" or os.clock()>chunkDeadline
  check(chunkDenied.state()=="Failed" and sourceReleased==1 and chunkDenied.allocationCount()==0,"Synthetic nil chunk allocation: source released, Native retained")
  chunkApp.destroy();settle()
  local lateApp=mount(f);local released=0
  local late=Ground.attach(lateApp.view.map,f.world,{loadSource=function()
   for _=1,6 do Run.Heartbeat:Wait()end
   return {Destroy=function()released+=1 end}
  end})
  late.setMode("Ground");late.destroy()
  check(not late.isPreparing(),"Cancellation immediately disconnects preparation telemetry before source returns")
  for _=1,10 do Run.Heartbeat:Wait()end
  check(released==1,"Synthetic late resource destroyed once after cancellation")
  check(lateApp.view.map.root:GetAttribute("ContinuousGroundActive")==false,"Cancelled resource cannot reactivate")
  lateApp.destroy();settle()
  if fi==1 then
   local timeoutApp=mount(f);local lateDisposed=0
   local timed=Ground.attach(timeoutApp.view.map,f.world,{loadSource=function()
    local finish=os.clock()+21;repeat Run.Heartbeat:Wait()until os.clock()>=finish
    return {Destroy=function()lateDisposed+=1 end}
   end})
   timed.setMode("Ground");local timeoutDeadline=os.clock()+23
   repeat Run.Heartbeat:Wait()until lateDisposed==1 or os.clock()>timeoutDeadline
   check(timed.state()=="TimedOut" and timed.allocationCount()==0 and lateDisposed==1,"Real twenty-second deadline; synthetic late callback disposed without reactivation")
   timeoutApp.destroy();settle()
  end
  print("IW12C_FIXTURE_PASS",fi,count,n)
 end
 print("IW12C_ENGINE_PASS",count)
 local benchApp,benchProof=mount(fixtures[1]);local benchMap=benchApp.view.map
 benchApp.view.root.Size=UDim2.fromOffset(1366,560);settle()
 for _,mode in {"Native","Illustrated","Ground","Ocean"} do
  benchProof.setLandscapeMode(mode);settle()
  if mode=="Ground" then
   local benchDeadline=os.clock()+20
   repeat Run.RenderStepped:Wait()until benchProof.ground().state()~="Loading" or os.clock()>benchDeadline
   check(benchProof.ground().state()=="Ready","Benchmark readiness")
  end
  local cpu,frames={},{}
  for i=1,180 do
   local z=.55+(i%30)*.003;local x=benchMap.viewport.AbsoluteSize.X/2-512*z+(i%13)-6.37
   local y=benchMap.viewport.AbsoluteSize.Y/2-512*z+(i%17)-8.19
   local start=os.clock();benchMap.render(x,y,z);cpu[i]=(os.clock()-start)*1000
   frames[i]=Run.RenderStepped:Wait()*1000
  end
  table.sort(cpu);table.sort(frames)
  print("IW12C_BENCH",game.HttpService:JSONEncode({mode=mode,samples=180,cpuP50=cpu[90],cpuP95=cpu[171],cpuWorst=cpu[180],frameP50=frames[90],frameP95=frames[171],frameWorst=frames[180],mapDescendants=#benchMap.root:GetDescendants(),textureMemoryMb=textureMemory(),totalMemoryMb=game:GetService("Stats"):GetTotalMemoryUsageMb()}))
 end
 benchApp.destroy();settle()
 if game.ReplicatedStorage:GetAttribute("RunContinuousGroundSoak")==true then
  local app,proof=mount(fixtures[1]);local map=app.view.map
  proof.setLandscapeMode("Ocean");local deadline=os.clock()+20
  repeat Run.Heartbeat:Wait() until proof.ground().state()~="Loading" or os.clock()>deadline
  check(proof.ground().state()=="Ready","Soak readiness")
  local n=#map.root:GetDescendants();local start=os.clock();local cycles=0;local dtSamples:{number}={}
  local memoryStart=game:GetService("Stats"):GetTotalMemoryUsageMb()
  local investigation=require(script.Parent.FrameInvestigation).start(map)
  local connection=Run.RenderStepped:Connect(function(dt:number)if #dtSamples<36000 then table.insert(dtSamples,dt*1000)end end)
  while os.clock()-start<600 do
   cycles+=1
   investigation.phase("mode/camera transition")
   local workStart=os.clock()
   proof.setLandscapeMode(({"Native","Illustrated","Ground","Ocean"})[(cycles-1)%4+1])
   map.render(-70.37+(cycles%31),-55.19,({.55,.72,1,1.2,1.8})[(cycles-1)%5+1])
   investigation.work((os.clock()-workStart)*1000);investigation.phase("steady after transition")
   check(#map.root:GetDescendants()==n and n<=600,"Endurance fixed map pool")
   local nextCycle=os.clock()+1;repeat Run.Heartbeat:Wait()until os.clock()>=nextCycle
  end
  connection:Disconnect();table.sort(dtSamples)
  print("IW13_FRAME_INVESTIGATION",game.HttpService:JSONEncode(investigation.finish()))
  print("IW12C_SOAK_PASS",game.HttpService:JSONEncode({seconds=os.clock()-start,cycles=cycles,descendants=n,p50=dtSamples[math.ceil(#dtSamples*.5)],p95=dtSamples[math.ceil(#dtSamples*.95)],worst=dtSamples[#dtSamples],memoryStartMb=memoryStart,memoryEndMb=game:GetService("Stats"):GetTotalMemoryUsageMb()}))
  app.destroy();settle()
 end
end
