--!strict
return function(useBaseline:boolean,useStage1B:boolean?,workloads:{string}?)
 assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Test-only profiler")
 local solver:any=if useStage1B then require(script.Parent.FleetStage1B.FleetSolver)elseif useBaseline then require(script.Parent.FleetBaseline.FleetSolver)else require(game.ServerScriptService.Server.Operations.FleetSolver)
 local fixtures=require(script.Parent.FleetWorkloads);local H=game:GetService("HttpService")
 local names:{string}=workloads or {"small","maximum","adversarial","islands","independent","equalCost"}
 for _,name in names do
  local n=fixtures[name]();local aggregate:any={};local samples={};local maxOps=0;local resetTables,resetSlots=0,0
  local memoryBefore=gcinfo()
  for i=1,10 do
   local current="";local at=os.clock();local observer={}
   observer.phase=function(nextPhase:string)local now=os.clock();if current~=""then aggregate[current]=(aggregate[current] or 0)+(now-at)*1000 end;current=nextPhase;at=now end
   observer.finish=function(ops:number)observer.phase("");maxOps=math.max(maxOps,ops)end
   observer.reset=function(seconds:number,slots:number)aggregate.residualReset=(aggregate.residualReset or 0)+seconds*1000;resetTables+=1;resetSlots+=slots end
   local start=os.clock();solver.solve(n,i,nil,observer);table.insert(samples,(os.clock()-start)*1000);task.wait()
  end
  for k,v in aggregate do aggregate[k]=v/10 end
  table.sort(samples)
  print("[Fleet phase profile] "..H:JSONEncode({implementation=if useStage1B then "Stage1B"elseif useBaseline then "original"else "Stage1C",baseline=useBaseline,workload=name,samples=10,phaseMeanMs=aggregate,p50=samples[5],p95=samples[10],max=samples[10],operations=maxOps,residualTables=resetTables,residualSlots=resetSlots,heapDeltaKiB=gcinfo()-memoryBefore}))
 end
end

