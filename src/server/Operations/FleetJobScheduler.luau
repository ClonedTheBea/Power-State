--!strict
-- One isolated eight-country interval; no automatic retries, installs or billing.
local Solver=require(script.Parent.FleetSolver)
local Snapshot=require(script.Parent.FleetJobSnapshot)
local Scheduler={}
function Scheduler.new(options:any):any
 assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Isolated Test scheduler only")
 assert(type(options.isCurrent)=="function","Server ownership/version predicate required")
 local clock=options.clock or os.clock;local frameBudget=options.frameBudget or .004
 local sliceBudget=options.sliceBudget or .0004;local deadline=options.deadline or .750;local cpuLimit=options.cpuLimit or .080
 local quantum=options.quantum or 128
 assert(frameBudget>0 and frameBudget<=.004 and sliceBudget>=0 and sliceBudget<=frameBudget,"Slice bounds")
 assert(deadline>0 and deadline<=.750 and cpuLimit>0 and cpuLimit<=.080,"Interval bounds")
 assert(quantum%1==0 and quantum>=1 and quantum<=128,"Checkpoint bound")
 local jobs:{[any]:any}={};local queue:{any}={};local countries={};local cursor=1;local admitted=0;local stepping=false;local closed=false
 local started:number?=nil;local cpu=0;local admissionCpu=0;local peak=0;local maxDepth=0;local frameEnd=0;local sliceEnd=0
 local function current(j:any):boolean local ok,value=pcall(options.isCurrent,j.input);return ok and value==true end
 local function drop(j:any,state:string)
  j.state=state;j.result=nil;j.input=nil
  if started then j.latency=clock()-(started::number)end
  if j.thread and coroutine.status(j.thread)~="running"then coroutine.close(j.thread);j.thread=nil end
 end
 local function expired():boolean return started~=nil and clock()-(started::number)>=deadline end
 local function sweep()
  for _,j in jobs do if j.state=="pending" or j.state=="ready"then
   if expired()then drop(j,"deadline")elseif cpu>=cpuLimit then drop(j,"cpu-limit")elseif not current(j)then drop(j,"stale")end
  end end
  for i=#queue,1,-1 do if queue[i].state~="pending"then table.remove(queue,i);if i<cursor then cursor-=1 end end end
  if cursor>#queue or cursor<1 then cursor=1 end
 end
 local api={}
 function api.admit(input:any):any
  assert(not stepping and not closed and admitted<8,"Admission bound or closed interval")
  assert(not countries[input.countryId],"No overlapping/replayed country interval")
  local at=clock();local snapshot=Snapshot.copy(input);assert(options.isCurrent(snapshot)==true,"Unsafe ownership/version")
  if not started then started=at end
  assert(not expired() and cpu<cpuLimit,"Expired interval")
  admitted+=1;local handle=table.freeze({serial=admitted});local j:any={state="pending",input=snapshot,result=nil,thread=nil,resumes=0,cpu=0,latency=0,lastBoundary="admitted"}
  countries[snapshot.countryId]=handle;jobs[handle]=j
  j.thread=coroutine.create(function()
   local control={quantum=quantum}
   control.checkpoint=function(boundary:string)
    j.lastBoundary=boundary
    if options.observe then options.observe(boundary)end -- bounded test observer, never replicated
    if not current(j)then j.failure="stale";error("Stale job")end
    if expired()then j.failure="deadline";error("Job deadline")end
    if clock()>=math.min(frameEnd,sliceEnd)then coroutine.yield(boundary)end
    -- Recheck on every resume before touching preserved residual state.
    if not current(j)then j.failure="stale";error("Stale resumed job")end
   end
   return Solver.solve(snapshot.network,snapshot.step,options.operationLimit,nil,control)
  end)
  table.insert(queue,j);maxDepth=math.max(maxDepth,#queue)
  local used=clock()-at;cpu+=used;admissionCpu+=used
  return handle
 end
 function api.step():any
  assert(not stepping and not closed,"Non-reentrant interval")
  stepping=true;local at=clock();frameEnd=at+frameBudget-math.min(.00025,frameBudget/8);local resumes=0
  sweep()
  while #queue>0 and clock()<frameEnd and cpu+(clock()-at)<cpuLimit and resumes<64 do
   if cursor>#queue then cursor=1 end
   local j=queue[cursor];local began=clock();sliceEnd=math.min(frameEnd,began+sliceBudget)
   j.resumes+=1;resumes+=1
   local ok,value=coroutine.resume(j.thread);local ended=clock();j.cpu+=ended-began;j.latency=ended-(started::number)
   if not ok then j.problem=tostring(value);drop(j,j.failure or "failed")
   elseif expired()then drop(j,"deadline")
   elseif cpu+(ended-at)>=cpuLimit then drop(j,"cpu-limit")
   elseif not current(j)then drop(j,"stale")
   elseif coroutine.status(j.thread)=="dead"then j.result=value;j.state="ready";j.thread=nil end
   if j.state=="pending"then cursor+=1 else table.remove(queue,cursor)end
  end
  sweep()
  local used=clock()-at;cpu+=used;peak=math.max(peak,used);stepping=false
  return {cpuMs=used*1000,overshootMs=math.max(0,used-frameBudget)*1000,resumes=resumes,pending=#queue}
 end
 function api.cancel(handle:any)
  assert(not stepping,"Cancel only between slices")
  local j=jobs[handle];if j and (j.state=="pending" or j.state=="ready")then drop(j,"cancelled")end;sweep()
 end
 function api.take(handle:any):any
  assert(not stepping and not closed,"No concurrent install")
  sweep();local j=jobs[handle]
  if not j or j.state~="ready"then return nil end
  -- Single-use handoff only. Caller would need a separate atomic gameplay commit.
  local result=j.result;j.result=nil;j.input=nil;j.state="consumed";return result
 end
 function api.status(handle:any):any
  local j=jobs[handle];if not j then return nil end
  return {state=j.state,resumes=j.resumes,cpuMs=j.cpu*1000,latencyMs=j.latency*1000,lastBoundary=j.lastBoundary,problem=j.problem}
 end
 function api.stats():any
  local retained=0;for _,j in jobs do if j.input or j.thread or j.result then retained+=1 end end
  return {admitted=admitted,pending=#queue,retained=retained,maxQueue=maxDepth,cpuMs=cpu*1000,admissionMs=admissionCpu*1000,peakMs=peak*1000}
 end
 function api.close()
  assert(not stepping,"Close only between slices")
  for _,j in jobs do drop(j,"closed")end;table.clear(queue);table.clear(jobs);table.clear(countries);closed=true
 end
 return table.freeze(api)
end
return table.freeze(Scheduler)
