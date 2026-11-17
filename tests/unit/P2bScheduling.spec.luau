--!strict
-- Engine Heartbeat scheduler with eight synthetic jobs, not eight real players.
return function()
 local Generator=require(game:GetService("ServerScriptService").Server.World.WorldGenerator)
 local Run=game:GetService("RunService")
 local Http=game:GetService("HttpService")
 local seed="df307a52185f423288df5749229f0808"
 local reference=Generator.create(seed,"scheduled",1)
 local jobs:{thread}={};local results:{any}={};local yields={0,0,0,0,0,0,0,0}
 for i=1,8 do
  jobs[i]=coroutine.create(function()
   results[i]=Generator.create(seed,"scheduled",1,function()yields[i]+=1;coroutine.yield()end)
  end)
 end
 local started=os.clock();local rounds=0
 while true do
  Run.Heartbeat:Wait();rounds+=1
  local done=0
  for _,job in jobs do
   if coroutine.status(job)~="dead" then local ok,err=coroutine.resume(job);assert(ok,tostring(err))end
   if coroutine.status(job)=="dead" then done+=1 end
  end
  if done==8 then break end
  assert(os.clock()-started<=2,"Eight-job wall watchdog gate")
 end
 local wall=(os.clock()-started)*1000
 assert(wall<=2000,"Eight-job wall watchdog gate")
 for i,result in results do
  assert(yields[i]>=20,"Bounded generation yielded")
  assert(Http:JSONEncode(result.chunks)==Http:JSONEncode(reference.chunks),"Yield timing cannot change generated country")
 end
 print(string.format("[P2b scheduler] PASS eight synthetic jobs, %.3fms wall / %d rounds; identical descriptors",wall,rounds))
end
