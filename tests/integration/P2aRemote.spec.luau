--!strict
-- Manual supplementary client suite: real RemoteEvent traffic, no invented owner authority.
return function(profile:string?)
 assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Test only")
 local folder=game:GetService("ReplicatedStorage"):WaitForChild(if profile=="P3b" then "P3bSimulation" elseif profile=="P3a" then "P3aSimulation" elseif profile=="P2b" then "P2bSimulation" else "P2aSimulation")
 local intent=folder.Intent :: RemoteEvent;local remote=folder.Snapshot :: RemoteEvent
 local latest:any=nil;local results:{any}={};local count=0
 local connection=remote.OnClientEvent:Connect(function(s:any)
  latest=s;if s.outcome~="Snapshot" then table.insert(results,s);if #results>32 then table.remove(results,1) end end
 end)
 local function check(ok:boolean,label:string)assert(ok,label);count+=1 end
 local function send(payload:any,expected:string):any
  task.wait(.6);table.clear(results);intent:FireServer(payload)
  local start=os.clock()
  while #results==0 and os.clock()-start<4 do task.wait(.02) end
  check(#results>0,"Response deadline")
  local result=results[#results];check(result.outcome==expected,"Real rejection/acceptance: "..expected)
  return result
 end
 local function command(online:boolean):any
  return {version=1,kind="SetGenerator",epoch=latest.epoch,sequence=latest.nextSequence,revision=latest.controlRevision,assetId=latest.generatorId or "station",online=online}
 end
 local ok,problem=xpcall(function()
  send({version=1,kind="Sync"},"Synced")
  if not latest.online then send(command(true),"Accepted") end
  local revision=latest.controlRevision
  send({version=1,kind="Sync",owner=999},"Malformed")
  send({version=1,kind="SetGenerator",online={value=false}},"Malformed")
  local bad=command(false);bad.outputMW=500;send(bad,"Malformed")
  bad=command(false);bad.assetId="capital";send(bad,"UnauthorizedAsset")
  bad=command(false);bad.epoch="old-session";send(bad,"StaleSession")
  bad=command(false);bad.sequence+=1;send(bad,"OutOfOrder")
  check(latest.online and latest.controlRevision==revision,"Rejected traffic cannot mutate operation")
  local off=command(false);send(off,"Accepted")
  check(latest.report.deliveredMW==0 and latest.report.unmetMW==latest.report.demandMW,"Real Off")
  revision=latest.controlRevision;send(off,"Duplicate")
  check(latest.controlRevision==revision,"Duplicate cannot mutate twice")
  send(command(false),"NoChange")
  bad=command(true);bad.revision=0;send(bad,"StaleRevision")
  send(command(true),"Accepted");check(latest.report.deliveredMW==latest.report.demandMW,"Real recovery")
  task.wait(2.1);table.clear(results)
  for _=1,20 do intent:FireServer({version=1,kind="Sync",unexpected=true}) end
  task.wait(.3);check(#results<=4,"Real burst response amplification bounded")
  check(latest.online,"Flood cannot switch state")
  task.wait(2.1);send({version=1,kind="Sync"},"Synced")
 end,function(err:unknown):string return debug.traceback(tostring(err)) end)
 intent:FireServer({version=1,kind="Unsubscribe"})
 connection:Disconnect();assert(ok,tostring(problem))
 print(string.format("[Power State %s remotes] PASS: %d actual transport assertions",profile or "P2a",count))
 return count
end
