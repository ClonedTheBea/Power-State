--!strict
local Test={}
local function same(a:any,b:any):boolean
 if type(a)~=type(b)then return false end
 if type(a)~="table"then return a==b end
 for k,v in a do if not same(v,b[k])then return false end end
 for k in b do if a[k]==nil then return false end end
 return true
end
function Test.capture(expected:number)
 assert(game:GetService("RunService"):IsServer() and game.GameId==10776833313,"Test server only")
 local Server=game.ServerScriptService.Server
 local rows=require(Server.World.GeneratedService).inspect()
 assert(#rows==expected and #rows<=8,"Actual player count")
 local ids={};local seeds={};local summary={}
 for _,r in rows do
  assert(r.ready and not r.pending and r.owner==r.userId,"Ready independent server owner")
  assert(not ids[r.world.countryId] and not seeds[r.world.seed],"Distinct identity and seed")
  ids[r.world.countryId]=true;seeds[r.world.seed]=true
  local replay=require(Server.World.WorldGenerator).create(r.world.seed,r.world.countryId,1)
  assert(same(require(Server.World.WorldGenerator).snapshot(replay),r.world),"Actual player seed reproduces all owned terrain")
  assert(r.snapshot.epoch==r.world.countryId,"Snapshot belongs to own world")
  assert(not r.snapshot.suspended and r.snapshot.report.deliveredMW<=r.snapshot.report.demandMW,"Healthy authoritative delivery")
  assert(r.timing.wallMs<2000,"Unchanged wall deadline")
  table.insert(summary,{userId=r.userId,countryId=r.world.countryId,seed=r.world.seed,timing=r.timing,
   online=r.snapshot.online,step=r.snapshot.step,controlRevision=r.snapshot.controlRevision,
   requestedMWh=r.snapshot.requestedMWh,deliveredMWh=r.snapshot.deliveredMWh})
 end
 print("[P2b.1 actual players] "..game:GetService("HttpService"):JSONEncode(summary))
 return rows
end
function Test.checkPeers(before:any,actor:number)
 local after=require(game.ServerScriptService.Server.World.GeneratedService).inspect()
 assert(#after==#before,"No test-induced join/leave")
 for _,a in after do
  local b=nil;for _,r in before do if r.userId==a.userId then b=r end end;assert(b)
  assert(a.world.countryId==b.world.countryId and a.world.seed==b.world.seed,"Identity preserved")
  if a.userId~=actor then
   assert(a.snapshot.online==b.snapshot.online and a.snapshot.controlRevision==b.snapshot.controlRevision,"Other player never controlled")
   assert(math.abs((a.snapshot.requestedMWh-b.snapshot.requestedMWh)-(a.snapshot.deliveredMWh-b.snapshot.deliveredMWh))<1e-8,"Peer accounting served independently")
  else assert(a.snapshot.controlRevision==b.snapshot.controlRevision+2,"Only own Off/On committed")end
 end
 print("[P2b.1 peer isolation] PASS actor "..actor.." / "..#after.." real players")
end
function Test.runAll(expected:number)
 local rows=Test.capture(expected)
 local Service=require(game.ServerScriptService.Server.World.GeneratedService)
 local template=game.StarterPlayer.StarterPlayerScripts.DevelopmentTests.P2b1Probe
 for i,row in rows do
  local before=Service.inspect();local peer=rows[i%#rows+1]
  local player=game:GetService("Players"):GetPlayerByUserId(row.userId);assert(player)
  local probe=template:Clone()
  probe:SetAttribute("PeerEpoch",peer.world.countryId)
  probe:SetAttribute("PeerGenerator",peer.snapshot.nodes[1].id)
  probe.Parent=player:WaitForChild("PlayerGui")
  task.wait(15)
  Test.checkPeers(before,row.userId)
 end
 print("[P2b.1 all clients] PASS "..expected.." real-client control/isolation rounds")
end
return Test
