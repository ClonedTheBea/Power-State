--!strict
-- Explicit isolated fake-storage host. There is deliberately no real-adapter parameter.
local Run=game:GetService("RunService")
local Players=game:GetService("Players")
local Http=game:GetService("HttpService")
local Domain=script.Parent.Parent.Domain
local Profiles=require(script.Parent.ProfileService)
local Quotes=require(script.Parent.ConstructionQuotes)
local Schema=require(Domain.ProfileSchema3)
local Lease=require(Domain.ProfileLease3)
local Country=require(Domain.ConstructionCountry)
local Base=require(script.Parent.Parent.Simulation.Country)
local Generator=require(script.Parent.Parent.World.WorldGenerator)
local Demand=require(script.Parent.Parent.World.DemandModel)
local Codec=require(Domain.ProfileCodec)
local Service={};local started=false
function Service.start()
 assert(Run:IsStudio() and Run:IsServer() and game.GameId==10776833313,"Construction Test only")
 assert(not started,"Construction proof already started");started=true
 local store=require(script.Parent.Parent.Adapters.FakeDataStoreAdapter).create()
 local function id():string return Http:GenerateGUID(false)end
 local function scalar(v:any):string return Http:JSONEncode(v)end
 local profiles=Profiles.create({adapter=store,schema=Schema,lease=Lease,id=id,scalar=scalar,jobId="P3cFake",placeId=game.PlaceId,
  utcMs=function()return DateTime.now().UnixTimestampMillis end,mono=os.clock,random=function()return .5 end,spawn=task.spawn})
 local actors:{[Player]:any}={};local admitted=0
 local folder=Instance.new("Folder");folder.Name="P3cConstruction"
 local intent=Instance.new("RemoteEvent");intent.Name="Intent";intent.Parent=folder
 local remote=Instance.new("RemoteEvent");remote.Name="Snapshot";remote.Parent=folder
 local function send(player:Player,a:any)
  if not a.state or not a.subscribed then return end
  local value:any=Base.snapshot(a.state)
  value.world=Generator.snapshot(a.world);value.save=profiles.status(a.entry);value.profile="P3c"
  value.bankMinor=a.state.bank.balanceMinor;value.construction=a.quotes.status();value.built=a.state.construction.receipt~=nil
  value.finance={bank=Codec.copy(a.state.bank),economy=Codec.copy(a.state.economy)}
  value.finance.economy.activationOperationId=nil
  value.suspended=not profiles.canMutate(a.entry)
  local node,line=require(Domain.ConstructionProject).assets(Country.capture(a.world,a.state))
  value.proposedNode=node;value.proposedLine=line
  assert(#Http:JSONEncode(value)<=262144,"Construction snapshot bounds")
  remote:FireClient(player,value)
 end
 local function add(player:Player)
  if admitted>=8 or actors[player] then return end
  admitted+=1;local a:any={elapsed=0,lastSend=0,subscribed=false,syncTokens=2,syncAt=os.clock()};actors[player]=a
  task.spawn(function()
   local ok,err=pcall(function()
    local entry=profiles.reserve(player.UserId)
    local deadline=os.clock()+60
    while not entry and actors[player]==a and os.clock()<deadline do task.wait(.1);entry=profiles.reserve(player.UserId)end
    assert(entry,"Profile admission unavailable")
    a.entry=entry
    if actors[player]~=a then profiles.close(entry);return false end
    local existing=store.inspect(entry.key)
    if existing then
     Schema.validate(existing,player.UserId,scalar)
     local r=existing.country.recipe
     a.world=Generator.create(r.seed,r.countryId,r.generationVersion)
     profiles.prepared(entry,existing.country)
     return true
    end
    local world=Generator.create(string.gsub(id(),"%-",""),id(),1)
    if actors[player]~=a then profiles.close(entry);return false end
    a.world=world
    local state=Base.new(player.UserId,id(),world.network)
    local capture=require(Domain.ProfileCountry).capture
    local function operation(kind:string,p:any?):any
     return {id=id(),kind=kind,owner=player.UserId,sessionId=if p and p.lease then p.lease.ownerSessionId else id(),jobId="P3cFake",placeId=game.PlaceId,
      candidate=capture(world,state),fence=if p then p.sessionEpoch else nil,baseRevision=if p then p.profileRevision else nil}
    end
    local now=DateTime.now().UnixTimestampMillis
    local l1=require(Domain.ProfileLease);local l2=require(Domain.ProfileLease2)
    local p=l1.apply(nil,operation("Acquire"),now,scalar);p=l1.apply(p,operation("Release",p),now,scalar)
    p=l2.apply(p,operation("Acquire",p),now,scalar);p=l2.apply(p,operation("Release",p),now,scalar)
    p=require(Domain.ProfileMigrations3).read(p,player.UserId,scalar)
    store.update(entry.key,function(current)assert(current==nil,"Fake initialization raced");return p end)
    profiles.prepared(entry,p.country)
    return true
   end)
   if not ok then warn("[P3c Fake] Initialization unavailable: "..tostring(err));if a.entry then profiles.unavailable(a.entry,"InitializationFailure")end end
  end)
 end
 Players.PlayerAdded:Connect(add)
 Players.PlayerRemoving:Connect(function(p)
  local a=actors[p];if not a then return end
  if a.entry then profiles.close(a.entry)end;actors[p]=nil;admitted-=1
 end)
 for _,p in Players:GetPlayers()do add(p)end
 intent.OnServerEvent:Connect(function(player,payload,...)
  local a=actors[player];if not a or select("#",...)~=0 then return end
  if type(payload)=="table" and (payload.command=="Subscribe" or payload.command=="Unsubscribe")then
   local count=0;for key in payload do count+=1;if count>2 or (key~="version" and key~="command")then return end end
   if count~=2 or payload.version~=1 then return end
    -- Idempotent transport shutdown must survive a rapid mount/unmount burst.
    -- It emits nothing and never changes simulation or transaction state.
    if payload.command=="Unsubscribe" then a.subscribed=false;return end
   local now=os.clock();a.syncTokens=math.min(2,a.syncTokens+math.max(0,now-a.syncAt));a.syncAt=now
   if a.syncTokens<1 then return end;a.syncTokens-=1
   a.subscribed=payload.command=="Subscribe";if a.subscribed then send(player,a)end
   return
  end
  if not a.quotes then return end
  local ok,response=pcall(a.quotes.handle,player.UserId,payload)
  if not ok then profiles.unavailable(a.entry,"ConstructionCommandFailure");return end
  if response.state~="Rejected" then send(player,a)end
 end)
 Run.Heartbeat:Connect(function(dt)
  profiles.tick()
  for player,a in actors do
   local ok,err=pcall(function()
    local e=a.entry
    if e and e.acquired and not a.state and not e.terminal then
     a.state=Country.restore(profiles.profile(e),a.world,e.commandEpoch);profiles.activate(e)
     a.quotes=Quotes.create({owner=player.UserId,epoch=e.commandEpoch,id=id,now=os.clock,
      country=function()return Country.capture(a.world,a.state)end,
      build=function(op)profiles.stage(e,Country.capture(a.world,a.state),a.state.revision);return profiles.build(e,op)end,
      profile=function()return profiles.profile(e)end,saveStatus=function()return profiles.status(e)end,
      canResume=function()return profiles.canMutate(e)end,
      install=function(p)a.state=Country.restore(p,a.world,e.commandEpoch);a.elapsed=0 end})
    end
    if not a.state then return false end
    a.quotes.tick()
    if profiles.canMutate(e)then
     a.elapsed+=dt
     if a.elapsed>=1 then
      local steps=math.min(2,math.floor(a.elapsed));a.elapsed=if a.elapsed>=3 then 0 else a.elapsed-steps
      for _=1,steps do a.state=Country.advance(a.state,a.world,Demand.atStep(a.state.step,1700,1000).demandMW)end
      profiles.stage(e,Country.capture(a.world,a.state),a.state.revision)
     end
    else a.elapsed=0 end
    if os.clock()-a.lastSend>=1 then a.lastSend=os.clock();send(player,a)end
    return true
   end)
   if not ok then warn("[P3c Fake] Suspended: "..tostring(err));if a.entry then profiles.unavailable(a.entry,"SimulationFailure")end end
  end
 end)
 game:BindToClose(function()
  profiles.shutdown();local start=os.clock()
  while profiles.stats().profiles>0 and os.clock()-start<20 do profiles.tick();task.wait(.05)end
 end)
 folder.Parent=game.ReplicatedStorage
 print("[P3c Fake] Test-only construction host; no real storage adapter")
end
return table.freeze(Service)
