--!strict
return function(playerGui:PlayerGui)
 local Client=require(script.Parent.Parent.Client.Simulation.ConstructionClient)
 local live=Client.active() or Client.mount(playerGui)
 local s=live.current();local remote=game.ReplicatedStorage.P3cConstruction.Intent :: RemoteEvent
 local snapshot=game.ReplicatedStorage.P3cConstruction.Snapshot :: RemoteEvent
 local checks=0;local function check(v:boolean,why:string)assert(v,why);checks+=1 end
 local function request():any return {version=1,kind="SetGenerator",epoch=s.epoch,sequence=s.nextSequence,revision=s.controlRevision,assetId=s.generatorId,online=not s.online}end
 for _,kind in {"epoch","asset","owner","price","nan","infinity","nested","oversize"}do
  local p=request()
  if kind=="epoch"then p.epoch="stale"elseif kind=="asset"then p.assetId="another-country-generator"elseif kind=="owner"then p.owner=149564437
  elseif kind=="price"then p.bankMinor=100000000 elseif kind=="nan"then p.sequence=0/0 elseif kind=="infinity"then p.revision=math.huge
  elseif kind=="nested"then p.online={}else p.assetId=string.rep("x",1024)end
  remote:FireServer(p);task.wait(.6)
  check(live.current().controlRevision==s.controlRevision and live.current().online==s.online,"Actual transport rejects "..kind)
 end
 local received=0;local listener=snapshot.OnClientEvent:Connect(function()received+=1 end)
 for _=1,100 do remote:FireServer({version=1,kind="SetGenerator",epoch="old"})end
 task.wait(.6);listener:Disconnect()
 check(received<=4,"Invalid flood does not amplify snapshots")
 check(live.current().controlRevision==s.controlRevision,"Flood cannot mutate control")
 task.wait(2.1)
 local before=live.current().online;live.requestToggle()
 local deadline=os.clock()+3;repeat task.wait(.05)until live.current().online~=before or os.clock()>deadline
 check(live.current().online~=before,"Valid command works after rejected traffic")
 task.wait(.6);live.requestToggle()
 deadline=os.clock()+3;repeat task.wait(.05)until live.current().online==before or os.clock()>deadline
 check(live.current().online==before,"Restore valid generator state")
 print(string.format("[First Playable remotes] PASS: %d actual transport assertions; invalid flood snapshots %d",checks,received))
end
