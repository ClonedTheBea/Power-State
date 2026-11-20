--!strict
-- Opt-in actual-client measurements; never runs on normal startup.
return function(gui:PlayerGui,fixture:any)
 assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Test only")
 local Run=game:GetService("RunService")
 local App=require(script.Parent.Parent.Parent.Client.Controllers.AppController)
 local Controller=require(script.Parent.IllustratedController)
 local old=gui:FindFirstChild("PowerStateShell");if old then old:Destroy()end
 local app=App.mount(gui,fixture);local proof=Controller.attach(app,fixture);local map=app.view.map
 app.view.root.Size=UDim2.fromOffset(1366,560)
 local function ready(mode:string)
  proof.setLandscapeMode(mode)
  if mode~="Native" then
   local deadline=os.clock()+20
   repeat Run.RenderStepped:Wait()until proof.ground().state()~="Loading" or os.clock()>deadline
   assert(proof.ground().state()=="Ready","Unchanged preparation deadline")
  end
  for _=1,6 do Run.RenderStepped:Wait()end
 end
 local function measure(mode:string,moving:boolean,duration:number)
  local probe=require(script.Parent.FrameInvestigation).start(map)
  probe.phase(mode..(if moving then " moving" else " idle"))
  local cpu:{number}={};local count=0;local began=os.clock();local initial=#map.root:GetDescendants()
  local memory=game:GetService("Stats"):GetTotalMemoryUsageMb()
  repeat
   count+=1
   if moving then
    local start=os.clock();debug.profilebegin("IW14 camera and presentation")
    local z=.55+(count%30)*.003
    map.render(map.viewport.AbsoluteSize.X/2-512*z+(count%13)-6.37,map.viewport.AbsoluteSize.Y/2-512*z+(count%17)-8.19,z)
    debug.profileend();local elapsed=(os.clock()-start)*1000
    if #cpu<36000 then table.insert(cpu,elapsed)end;probe.work(elapsed)
   end
   assert(#map.root:GetDescendants()==initial and initial<=600,"Fixed descendant budget")
   if mode=="Organic" then assert(proof.ground().allocationCount()==4 and map.root:GetAttribute("OrganicShoreActive")==true,"Organic resources remain active")end
   Run.RenderStepped:Wait()
  until os.clock()-began>=duration
  local result:any=probe.finish();result.events=nil -- events already individually printed, no log truncation
  table.sort(cpu)
  result.mode=mode;result.moving=moving;result.seconds=os.clock()-began;result.descendants=initial
  result.memoryStartMb=memory;result.memoryEndMb=game:GetService("Stats"):GetTotalMemoryUsageMb()
  if #cpu>0 then result.cpuP50=cpu[math.ceil(#cpu*.5)];result.cpuP95=cpu[math.ceil(#cpu*.95)];result.cpuWorst=cpu[#cpu]end
  print("IW14_MEASURE",game.HttpService:JSONEncode(result))
 end
 for _,mode in {"Native","Ocean","Organic"}do
  ready(mode);measure(mode,false,30);measure(mode,true,30)
 end
 measure("Organic",true,600)
 app.destroy();assert(proof.ground().allocationCount()==0,"Final resource release")
 print("IW14_SOAK_COMPLETE")
end
