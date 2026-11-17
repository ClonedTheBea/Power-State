--!strict
return function()
 local Queue=require(game.ServerScriptService.Server.World.GenerationScheduler)
 local Generator=require(game.ServerScriptService.Server.World.WorldGenerator)
 local Http=game:GetService("HttpService")
 local checks=0
 local function check(ok:boolean,label:string)assert(ok,label);checks+=1 end
 local clock=0;local q=Queue.create(function()return clock end)
 local jobs={};local visits={}
 for i=1,8 do jobs[i]=q.add(function()for _=1,3 do table.insert(visits,i);clock+=.0001;coroutine.yield()end end)end
 check(not pcall(q.add,function()end),"Eight-job cap")
 q.step();check(#visits>=8 and #visits<=21,"Bounded multiple slices per frame")
 for i=1,8 do check(visits[i]==i,"Round-robin fairness")end
 while q.count()>0 do q.step()end
 for _,job in jobs do check(job.status=="complete" and job.resumes==4,"All jobs complete")end
 q=Queue.create(function()return clock end)
 local cancelled=q.add(function()error("Cancelled job ran")end);q.cancel(cancelled)
 check(q.count()==0 and cancelled.status=="cancelled","Leave releases queued job")
 -- Cross the slice budget decisively; binary subtraction at exactly .002 can round below it.
 local suspended=q.add(function()clock+=.003;coroutine.yield();error("Cancelled suspended job resumed")end)
 q.step();check(suspended.status=="pending" and suspended.resumes==1,"Job suspended at slice boundary")
 q.cancel(suspended);q.step();check(q.count()==0 and suspended.status=="cancelled","Leave closes suspended coroutine")
 clock=0 -- Empty queue: make the exact two-second deadline representable in this fixture.
 local late=q.add(function()error("Expired job ran")end);clock=2;q.step()
 check(late.status=="timeout" and late.resumes==0,"Queue wait counts toward deadline")
 local over=q.add(function()clock+=2.1 end);q.step()
 check(over.status=="timeout","Final slice cannot evade deadline")
 local failed=q.add(function()error("Injected job failure")end);q.step()
 check(failed.status=="failed" and q.count()==0,"Errors release job capacity")
 local bounded=Queue.create(function()return 0 end)
 local spinning=bounded.add(function()while true do coroutine.yield()end end)
 check(bounded.step()==64,"Hard per-frame resume bound even with frozen clock");bounded.cancel(spinning)
 local seed="df307a52185f423288df5749229f0808"
 local reference=Generator.create(seed,"scheduler-parity",1)
 q=Queue.create();local results:{any}={};jobs={}
 for i=1,8 do jobs[i]=q.add(function()results[i]=Generator.create(seed,"scheduler-parity",1,coroutine.yield)end)end
 local began=os.clock();local frames=0
 while q.count()>0 do game:GetService("RunService").Heartbeat:Wait();q.step();frames+=1 end
 for i,job in jobs do
  check(job.status=="complete","Eight scheduled real generators finish inside unchanged watchdog")
  check(Http:JSONEncode(results[i].chunks)==Http:JSONEncode(reference.chunks),"All chunk samples unchanged by scheduling")
  check(results[i].candidate==reference.candidate,"Candidate unchanged")
 end
 print(string.format("[P2b.1 scheduler] PASS %d assertions; eight synthetic jobs %.3fms / %d Heartbeats",checks,(os.clock()-began)*1000,frames))
end
