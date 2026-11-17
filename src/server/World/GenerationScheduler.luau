--!strict
-- Cooperative scheduling only: jobs retain their approved 128-sample / 2 ms yield contract.
local Scheduler={}
export type Job={thread:thread,started:number,firstResume:number?,lastYield:number?,queueMs:number,
 waitMs:number,resumeMs:number,resumes:number,wallMs:number,status:string,problem:string?}
function Scheduler.create(clock:(()->number)?)
 local now=clock or os.clock
 local jobs:{Job}={};local cursor=1
 local function cancel(job:Job)
  if job.status=="pending" then job.status="cancelled";coroutine.close(job.thread) end
  local i=table.find(jobs,job)
  if i then table.remove(jobs,i);if i<cursor then cursor-=1 end end
  if cursor>#jobs then cursor=1 end
 end
 return {
  add=function(work:()->()):Job
   assert(#jobs<8,"Generation queue ceiling")
   local job:Job={thread=coroutine.create(work),started=now(),firstResume=nil,lastYield=nil,
    queueMs=0,waitMs=0,resumeMs=0,resumes=0,wallMs=0,status="pending",problem=nil}
   table.insert(jobs,job);return job
  end,
  cancel=cancel,
  count=function():number return #jobs end,
  step=function()
   local began=now();local resumes=0
   -- Several round-robin slices may fit in one Heartbeat. Total slice work is bounded;
   -- the final cooperative slice can overrun this 2 ms scheduling target by <= its own work.
   while #jobs>0 and resumes<64 and now()-began<.002 do
    if cursor>#jobs then cursor=1 end
    local job=jobs[cursor];local start=now()
    if start-job.started>=2 then
     job.status="timeout";job.problem="Generation wall watchdog";job.wallMs=(start-job.started)*1000
     coroutine.close(job.thread)
    else
     if not job.firstResume then job.firstResume=start;job.queueMs=(start-job.started)*1000 end
     if job.lastYield then job.waitMs+=(start-job.lastYield)*1000 end
     job.resumes+=1;resumes+=1
     local ok,problem=coroutine.resume(job.thread)
     local ended=now();job.resumeMs+=(ended-start)*1000;job.wallMs=(ended-job.started)*1000
     job.lastYield=ended
     if not ok then job.status="failed";job.problem=tostring(problem)
     elseif ended-job.started>=2 then
      job.status="timeout";job.problem="Generation wall watchdog";coroutine.close(job.thread)
     elseif coroutine.status(job.thread)=="dead" then job.status="complete" end
    end
    if job.status~="pending" then table.remove(jobs,cursor) else cursor+=1 end
   end
   return resumes
  end,
 }
end
return table.freeze(Scheduler)
