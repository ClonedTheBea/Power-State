--!strict
-- Operator supplies a peer's identifiers as adversarial knowledge, never through gameplay replication.
return function(peerEpoch:string,peerGenerator:string)
 assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Test only")
 local Replicated=game:GetService("ReplicatedStorage")
 local folder=Replicated.P2bSimulation
 local latest:any=nil;local replies:{any}={};local violation:string?=nil;local epoch:string?=nil;local packets=0
 local connection=folder.Snapshot.OnClientEvent:Connect(function(s:any)
  packets+=1
  if epoch and s.epoch~=epoch then violation="Foreign snapshot epoch" end
  local encoded=game:GetService("HttpService"):JSONEncode(s)
  if string.find(encoded,peerEpoch,1,true) or string.find(encoded,peerGenerator,1,true) then violation="Peer data in gameplay snapshot"end
  latest=s;if s.outcome~="Snapshot"then table.insert(replies,s);if #replies>16 then table.remove(replies,1)end end
 end)
 local checks=0
 local function check(ok:boolean,label:string)assert(ok,label);checks+=1 end
 local function send(payload:any,expected:string)
  task.wait(.6);table.clear(replies);folder.Intent:FireServer(payload)
  local began=os.clock();repeat task.wait(.02)until #replies>0 or os.clock()-began>4
  check(#replies>0 and replies[#replies].outcome==expected,"Actual transport "..expected)
  return replies[#replies]
 end
 local function command():any
  return {version=1,kind="SetGenerator",epoch=latest.epoch,assetId=latest.generatorId,
   sequence=latest.nextSequence,revision=latest.controlRevision,online=not latest.online}
 end
 local ok,problem=pcall(function()
  local initial=send({version=1,kind="Sync"},"Synced");epoch=initial.epoch
  check(epoch~=peerEpoch and initial.world.countryId==epoch,"Own initial world")
  check(game:GetService("ServerScriptService"):FindFirstChild("Server")==nil,"Server modules not replicated")
  check(Replicated:FindFirstChild("World")==nil,"No shared private world folder")
  local bad=command();bad.epoch=peerEpoch;bad.assetId=peerGenerator;send(bad,"StaleSession")
  bad=command();bad.assetId=peerGenerator;send(bad,"UnauthorizedAsset")
  send({version=1,kind="Sync",owner=123},"Malformed")
  check(latest.online,"Attacks left own state unchanged")
  send(command(),"Accepted");local delivered=latest.deliveredMWh;local requested=latest.requestedMWh
  task.wait(3.1)
  check(latest.deliveredMWh==delivered and latest.requestedMWh>requested,"Own outage accounting")
  check(latest.report.deliveredMW==0,"Own generator Off")
  send(command(),"Accepted");check(latest.report.deliveredMW==latest.report.demandMW,"Own recovery")
  task.wait(1.1);check(violation==nil,"No cross-player snapshot/information leakage")
 end)
 connection:Disconnect();assert(ok,tostring(problem))
 print(string.format("[P2b.1 client] PASS %d assertions / %d own packets / user %d",checks,packets,game:GetService("Players").LocalPlayer.UserId))
end
