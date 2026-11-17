--!strict
return function(playerGui:PlayerGui)
 local Client=require(script.Parent.Parent.Client.Simulation.SimulationClient)
 local old=playerGui:FindFirstChild("PowerStateShell");if old then old:Destroy()end
 local live=Client.mount(playerGui,"P2b");local app=live.app
 local baseline=#app.view.gui:GetDescendants();local mapCount=#app.view.map.root:GetDescendants()
 local first=live.current();local seed=first.world.seed;local started=os.clock();local cycles=0
 local requested=first.requestedMWh;local delivered=first.deliveredMWh;local steps=first.step
 local sizes={{1366,704},{360,580},{640,300},{768,960}}
 local ok,problem=xpcall(function()
  while os.clock()-started<600 do
   cycles+=1;local size=sizes[(cycles-1)%#sizes+1]
   app.view.root.Size=UDim2.fromOffset(size[1],size[2]);app.selectAsset(first.generatorId)
   app.mapController.pan(if cycles%2==0 then 40 else -40,15)
   app.mapController.changeZoom(if cycles%2==0 then .15 else -.15)
   task.wait(1)
   local s=live.current()
   assert(not s.suspended and s.world.seed==seed,"Live generated state stayed valid")
   assert(s.report.demandMW<=4.10 and s.report.headroomMW>=.9,"Live demand envelope")
   assert(s.report.unmetMW==0 and s.report.deliveredMW==s.report.demandMW,"Live service conservation")
   assert(s.step>=steps and s.requestedMWh>=requested and s.deliveredMWh>=delivered,"Monotonic accounting")
   requested,delivered,steps=s.requestedMWh,s.deliveredMWh,s.step
   assert(#app.view.gui:GetDescendants()==baseline and #app.view.map.root:GetDescendants()==mapCount,"Stable pool")
   assert(app.state.selectedId==first.generatorId,"Selection preserved")
   if cycles%60==0 then print("[P2b soak] "..cycles.." cycles; stable "..mapCount.." map descendants")end
  end
 end,function(err:unknown):string return debug.traceback(tostring(err))end)
 live.destroy();assert(ok,tostring(problem))
 print(string.format("[P2b soak] PASS %.1fs / %d cycles / %d map descendants",os.clock()-started,cycles,mapCount))
end
