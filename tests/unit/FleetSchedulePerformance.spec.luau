--!strict
return function()
 local S=game.ServerScriptService.Server;local Scheduler=require(S.Operations.FleetJobScheduler);local Snap=require(S.Operations.FleetJobSnapshot)
 local Sync=require(script.Parent.FleetStage1C.FleetSolver);local W=require(script.Parent.FleetWorkloads)
 local H=game:GetService("HttpService");local R=game:GetService("RunService");local Codec=require(S.Domain.ProfileCodec)
 local function encode(v:any):string return Codec.encode(v,function(x)return H:JSONEncode(x)end)end
 for _,cadence in {0,30,15}do for round=1,3 do
  for _,name in {"small","intermediate","maximum","adversarial","independent","islands","equalCost"}do
   local current={};local input={};local expected={}
   for i=1,8 do local e={countryId="c"..i,epoch=1,step=i,countryRevision=1,topologyRevision=1,network=W[name]()};input[i]=e;current[e.countryId]=e;expected[i]=encode(Sync.solve(e.network,e.step))end
   local memory=gcinfo();local s=Scheduler.new({isCurrent=function(v:any)return Snap.sameStamp(v,current[v.countryId])end});local handles={};local started=os.clock()
   for offset=1,8 do local i=(offset+round-2)%8+1;handles[i]=s.admit(input[i])end
   local slices={};local overshoot=0;local elapsedCadence=0;local frames=0
   while s.stats().pending>0 and os.clock()-started<2 do
    local dt=R.Heartbeat:Wait();frames+=1;elapsedCadence+=dt
    if cadence==0 or elapsedCadence>=1/cadence then
     elapsedCadence=0;local frame=s.step();table.insert(slices,frame.cpuMs);overshoot=math.max(overshoot,frame.overshootMs)
    end
   end
   local elapsed=(os.clock()-started)*1000;local stats=s.stats();local latency={};local states={};local completed=0;local operations=0
   for i,h in handles do
    local status=s.status(h);latency[i]=status.latencyMs;states[i]=status.state
    local result=s.take(h)
    if result then assert(encode(result)==expected[i],"Scheduled exact allocation/cost/full report");completed+=1;operations=math.max(operations,result.operations)end
   end
   local clean=s.stats();assert(clean.retained==0 and clean.pending==0,"Completed/failed interval releases state")
   print("[Fleet 1D resumed] "..H:JSONEncode({cadenceHz=cadence,round=round,workload=name,cpuMs=stats.cpuMs,admissionMs=stats.admissionMs,peakMs=math.max(stats.peakMs,stats.admissionMs),overshootMs=overshoot,elapsedMs=elapsed,latenciesMs=latency,states=states,completed=completed,frames=frames,slicesMs=slices,maxQueue=stats.maxQueue,retained=clean.retained,operations=operations,heapDeltaKiB=gcinfo()-memory}))
   s.close()
  end
 end end
 print("[Fleet 1D resumed complete] all workload/cadence rounds recorded")
end
