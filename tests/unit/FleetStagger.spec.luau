--!strict
return function()
 assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Test only")
 local S=game.ServerScriptService.Server;local Solver=require(script.Parent.FleetStage1C.FleetSolver);local Snap=require(S.Operations.FleetJobSnapshot)
 local W=require(script.Parent.FleetWorkloads);local H=game:GetService("HttpService");local R=game:GetService("RunService")
 local Codec=require(S.Domain.ProfileCodec)
 local function encode(v:any):string return Codec.encode(v,function(x)return H:JSONEncode(x)end)end
 local failures=0
 for _,cadence in {0,30,15}do for round=1,3 do for _,name in {"small","intermediate","maximum","adversarial","independent","islands","equalCost"}do
  local jobs={};for i=1,8 do local n=W[name]();table.insert(jobs,{input=n,step=i,expected=encode(Solver.solve(n,i))})end
  local started=os.clock()
  for i,j in jobs do j.input=Snap.copy({countryId="c"..i,epoch=1,step=j.step,countryRevision=1,topologyRevision=1,network=j.input}).network end
  local admission=(os.clock()-started)*1000;local total,peak=admission,admission;local latencies={};local slices={}
  -- Exactly one complete immutable-input solve per Heartbeat; no gameplay install.
  for offset=1,8 do
   local waited=0;repeat waited+=R.Heartbeat:Wait()until cadence==0 or waited>=1/cadence
   local i=(offset+round-2)%8+1;local j=jobs[i]
   local at=os.clock();local result=Solver.solve(j.input,j.step);local cpu=(os.clock()-at)*1000
   total+=cpu;peak=math.max(peak,cpu);table.insert(slices,cpu);latencies[i]=(os.clock()-started)*1000
   assert(encode(result)==j.expected,"Staggered exact equivalence")
  end
  local elapsed=(os.clock()-started)*1000
  if peak>4 or total>80 or elapsed>750 then failures+=1 end
  print("[Fleet 1D whole] "..H:JSONEncode({cadenceHz=cadence,round=round,workload=name,admissionMs=admission,cpuMs=total,peakMs=peak,overshootMs=math.max(0,peak-4),elapsedMs=elapsed,latenciesMs=latencies,slicesMs=slices,maxQueue=8}))
 end end end
 print("[Fleet 1D whole complete] failed intervals",failures)
end
