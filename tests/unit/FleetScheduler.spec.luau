--!strict
return function()
 local S=game.ServerScriptService.Server;local Scheduler=require(S.Operations.FleetJobScheduler);local Snap=require(S.Operations.FleetJobSnapshot)
 local Sync=require(script.Parent.FleetStage1C.FleetSolver);local W=require(script.Parent.FleetWorkloads)
 local H=game:GetService("HttpService");local Codec=require(S.Domain.ProfileCodec);local count=0
 local function check(v:boolean,m:string)assert(v,m);count+=1 end
 local function encode(v:any):string return Codec.encode(v,function(x)return H:JSONEncode(x)end)end
 local function envelope(id:string,epoch:number?):any return {countryId=id,epoch=epoch or 1,step=7,countryRevision=20,topologyRevision=3,network=W.independent()}end
 local function drain(s:any)
  for _=1,1000 do if s.stats().pending==0 then return end;s.step()end;error("Drain bound")
 end
 local current:any={};local function valid(v:any):boolean return v and Snap.sameStamp(v,current[v.countryId])end
 local s=Scheduler.new({isCurrent=valid,sliceBudget=0});local inputs={};local handles={};local expected={}
 for i=1,8 do local e=envelope("c"..i);current[e.countryId]=e;inputs[i]=e;expected[i]=encode(Sync.solve(e.network,e.step));handles[i]=s.admit(e)end
 check(not pcall(s.admit,envelope("ninth")),"Eight-job admission limit")
 check(not pcall(s.admit,inputs[1]),"No overlapping country/step")
 -- Input mutation cannot affect the private frozen snapshot; valid commands must invalidate revision.
 inputs[1].network.sources[1].availableKW=0
 s.step();s.step()
 local lo,hi=math.huge,0
 for _,h in handles do local v=s.status(h);lo=math.min(lo,v.resumes);hi=math.max(hi,v.resumes)end
 check(lo>0 and hi-lo<=1,"Round-robin progress independent of country ID")
 current.c2.network.sources[1].availableKW=0;current.c2.countryRevision+=1;s.step();check(s.status(handles[2]).state=="stale","Command invalidates active country revision")
 current.c3.epoch+=1;s.step();check(s.status(handles[3]).state=="stale","Session/ownership change invalidates")
 s.cancel(handles[4]);check(s.take(handles[4])==nil,"Cancelled work cannot install")
 drain(s)
 for i,h in handles do
  if i==2 or i==3 or i==4 then check(s.take(h)==nil,"No stale/cancelled handoff")
  else local r=s.take(h);check(r~=nil and encode(r)==expected[i],"Private immutable exact result");check(s.take(h)==nil,"Single-use result")end
 end
 check(s.stats().retained==0 and s.stats().pending==0,"No residual or snapshot retained")
 check(not pcall(s.admit,inputs[1]),"No replay/catch-up admission")
 s.close();check(s.status(handles[1])==nil,"Closed interval releases metadata")
 -- A leave/rejoin needs a fresh explicit interval and a current epoch; old handles stay inert.
 current.c4=envelope("c4",2);local rejoin=Scheduler.new({isCurrent=valid});local h=rejoin.admit(current.c4);drain(rejoin)
 check(rejoin.take(handles[4])==nil and rejoin.take(h)~=nil,"Rejoin cannot consume old handle");rejoin.close()
 -- Fake non-yielding installation advances the owner's stamp, not money/history.
 -- A fresh scheduler must not accept the already-consumed interval afterward.
 local old=Snap.copy(envelope("replay"));current.replay=table.clone(old)
 local install=Scheduler.new({isCurrent=valid});local token=install.admit(old);drain(install)
 check(install.take(token)~=nil,"Fake owner accepts current interval once")
 current.replay.step+=1;current.replay.countryRevision+=1;install.close()
 local repeatInterval=Scheduler.new({isCurrent=valid})
 check(not pcall(repeatInterval.admit,old),"Owner cursor rejects replay across interval objects");repeatInterval.close()
 -- Cancellation at every supported named checkpoint, including completion before handoff.
 local boundaries={"start","validated","compiled","round","cut-test","feasibility","edge","prefix","freeze","allocated","routed","complete"}
 for _,target in boundaries do
  local alive=true;local seen=false
  local q=Scheduler.new({isCurrent=function()return alive end,observe=function(name:string)if name==target then seen=true;alive=false end end})
  local token=q.admit(envelope("boundary"));drain(q)
  check(seen and q.status(token).state=="stale" and q.take(token)==nil,"Cancel boundary "..target)
  check(q.stats().retained==0,"Boundary cleanup");q.close()
 end
 -- Ready results are revalidated, not just running coroutines.
 local alive=true;local q=Scheduler.new({isCurrent=function()return alive end});h=q.admit(envelope("ready"));drain(q);alive=false
 check(q.take(h)==nil and q.status(h).state=="stale","Late stale completion rejected");q.close()
 local now=0;q=Scheduler.new({isCurrent=function()return true end,clock=function()return now end});h=q.admit(envelope("late"));now=.751;q.step()
 check(q.status(h).state=="deadline" and q.take(h)==nil and q.stats().retained==0,"Deadline discards incomplete state");q.close()
 now=0;q=Scheduler.new({isCurrent=function()return true end,clock=function()return now end,observe=function(name:string)if name=="edge"then now+=.081 end end})
 h=q.admit(envelope("cpu"));q.step();check(q.status(h).state=="cpu-limit" and q.take(h)==nil,"CPU ceiling fails closed");q.close()
 q=Scheduler.new({isCurrent=function()return true end,operationLimit=1});h=q.admit(envelope("ops"));drain(q)
 check(q.status(h).state=="failed" and q.take(h)==nil and q.stats().retained==0,"Operation exhaustion is atomic");q.close()
 q=Scheduler.new({isCurrent=function()return true end});local bad=envelope("bad");bad.network.sources[1].availableKW=0/0
 check(not pcall(q.admit,bad) and q.stats().admitted==0,"Invalid admission has no queued mutation");q.close()
 -- Revision, topology and ownership failures before handoff are equally fatal.
 for _,key in {"step","topologyRevision","countryRevision","epoch"}do
  local e=envelope("revision");local live:any=table.clone(e)
  local r=Scheduler.new({isCurrent=function(v:any)return Snap.sameStamp(v,live)end,sliceBudget=0})
  local token=r.admit(e);r.step();live[key]+=1;r.step()
  check(r.take(token)==nil and r.stats().retained==0,"Stale "..key.." cleanup");r.close()
 end
 local mem=gcinfo()
 for cycle=1,32 do
  local r=Scheduler.new({isCurrent=function()return true end,sliceBudget=0});local tokens={}
  for i=1,8 do tokens[i]=r.admit(envelope("cycle"..i))end
  r.step();for _,token in tokens do r.cancel(token)end
  check(r.stats().pending==0 and r.stats().retained==0,"Cancelled interval releases all eight states");r.close()
 end
 print("[Fleet 1D cleanup memory] 32 cancelled eight-job intervals; heap delta KiB",gcinfo()-mem)
 -- Audit every actual checkpoint occurrence on the independent-branch solve,
 -- not just one representative of each named boundary type.
 local occurrences=0
 local audit=Scheduler.new({isCurrent=function()return true end,observe=function()occurrences+=1 end})
 local auditHandle=audit.admit(envelope("audit"));drain(audit);check(audit.take(auditHandle)~=nil,"Checkpoint census completes");audit.close()
 for stopAt=1,occurrences do
  local alive=true;local visited=0
  local r=Scheduler.new({isCurrent=function()return alive end,observe=function()visited+=1;if visited==stopAt then alive=false end end})
  local token=r.admit(envelope("audit"));drain(r)
  check(visited==stopAt and r.status(token).state=="stale" and r.take(token)==nil and r.stats().retained==0,"Every checkpoint cancellation")
  r.close();if stopAt%16==0 then task.wait()end
 end
 print("[Fleet 1D cancellation census] occurrences",occurrences)
 print(string.format("[Fleet 1D safety] PASS: %d assertions; all 12 cancellation boundaries",count))
end
