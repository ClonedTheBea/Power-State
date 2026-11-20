--!strict
-- Explicit isolated fake-storage host. There is deliberately no real-adapter parameter.
local Run=game:GetService("RunService")
local Players=game:GetService("Players")
local Http=game:GetService("HttpService")
local Domain=script.Parent.Parent.Domain
local Profiles=require(script.Parent.ProfileService)
local Quotes=require(script.Parent.ConstructionQuotes)
local Schema3=require(Domain.ProfileSchema3)
local Lease3=require(Domain.ProfileLease3)
local Country3=require(Domain.ConstructionCountry)
local Base=require(script.Parent.Parent.Simulation.Country)
local Generator=require(script.Parent.Parent.World.WorldGenerator)
local Demand=require(script.Parent.Parent.World.DemandModel)
local Codec=require(Domain.ProfileCodec)
local Service={};local started=false;local host:any=nil
function Service.start()
 assert(Run:IsStudio() and Run:IsServer() and game.GameId==10776833313,"Construction Test only")
 if started then return host end;started=true
 local fleet=game.ReplicatedStorage:GetAttribute("NationalFleetProof")==true
 local Schema:any=if fleet then require(Domain.ProfileSchema4)else Schema3
 local Lease:any=if fleet then require(Domain.ProfileLease4)else Lease3
 local Country:any=if fleet then require(Domain.FleetCountry)else Country3
 local batch:any=nil
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
  if not a.subscribed then return end
  if not a.state then
   remote:FireClient(player,{version=1,profile="P3c",subscriptionId=a.subscriptionId,loadState=if a.entry then profiles.status(a.entry).state else "Loading"})
   return
  end
  local value:any=Base.snapshot(a.state)
  value.subscriptionId=a.subscriptionId
  value.world=Generator.snapshot(a.world);value.save=profiles.status(a.entry);value.profile="P3c"
  value.generatorId=a.state.network.generatorId;value.demandId=a.state.network.demandId
  value.controlOutcome=a.controlOutcome
  value.bankMinor=a.state.bank.balanceMinor;value.construction=a.quotes.status();value.built=a.state.construction.receipt~=nil
  value.finance={bank=Codec.copy(a.state.bank),economy=Codec.copy(a.state.economy)}
  value.finance.economy.activationOperationId=nil
  value.suspended=not profiles.canMutate(a.entry)
  local node,line=require(Domain.ConstructionProject).assets(Country.capture(a.world,a.state))
  value.proposedNode=node;value.proposedLine=line
  if fleet then
   local record=Country.capture(a.world,a.state);local windNode,windLine,route=require(Domain.WindProject).assets(record)
   value.fleet={version=1,units=Codec.copy(a.state.fleet.units),built=a.state.fleet.windReceipt~=nil,
    project=a.windQuotes.status(),node=windNode,line=windLine,route=route,
    dispatch=a.state.fleetReport,pending=a.state.dispatchPending==true,forecast=require(Domain.CountryFleetForecast).create(a.state),
    potentialKW=require(script.Parent.Parent.Operations.OperationsWind).potential(a.state.fleet.windSeed,a.state.fleet.windRegion,a.state.step)}
  end
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
    if fleet then p=require(Domain.ProfileMigrations4).read(p,player.UserId,id(),scalar)end
    store.update(entry.key,function(current)assert(current==nil,"Fake initialization raced");return p end)
    profiles.prepared(entry,p.country)
    return true
   end)
   if not ok then warn("[P3c Fake] Initialization unavailable: "..tostring(err));if a.entry then profiles.unavailable(a.entry,"InitializationFailure")end end
  end)
 end
 Players.PlayerAdded:Connect(add)
 local function remove(p:Player)
  local a=actors[p];if not a then return end
  if a.entry then profiles.close(a.entry)end;actors[p]=nil;admitted-=1
 end
 Players.PlayerRemoving:Connect(remove)
 for _,p in Players:GetPlayers()do add(p)end
 intent.OnServerEvent:Connect(function(player,payload,...)
  local a=actors[player];if not a or select("#",...)~=0 then return end
  if type(payload)=="table" and (payload.command=="Subscribe" or payload.command=="Unsubscribe")then
   local count=0;for key in payload do count+=1;if count>3 or (key~="version" and key~="command"and key~="subscriptionId")then return end end
   if count~=3 or payload.version~=1 or type(payload.subscriptionId)~="string"or #payload.subscriptionId~=36
    or not payload.subscriptionId:match("^[%x]+%-[%x]+%-[%x]+%-[%x]+%-[%x]+$")then return end
    -- Idempotent transport shutdown must survive a rapid mount/unmount burst.
    -- It emits nothing and never changes simulation or transaction state.
    if payload.command=="Unsubscribe" then if payload.subscriptionId==a.subscriptionId then a.subscribed=false end;return end
   local now=os.clock();a.syncTokens=math.min(2,a.syncTokens+math.max(0,now-a.syncAt));a.syncAt=now
   if a.syncTokens<1 then return end;a.syncTokens-=1
   a.subscriptionId=payload.subscriptionId;a.subscribed=true;send(player,a)
   return
  end
  if not a.quotes then return end
  if type(payload)=="table" and (payload.kind=="SetGenerator" or (fleet and payload.kind=="SetFleetGenerator")) then
   local controls:any=if fleet then require(script.Parent.FleetControls)else require(script.Parent.ConstructionControls)
   local ok,candidate,outcome=pcall(controls.handle,a.state,a.world,player.UserId,payload,os.clock(),profiles.canMutate(a.entry))
   if not ok then profiles.unavailable(a.entry,"ControlFailure");return end
   a.state=candidate;a.controlOutcome=outcome
   if outcome=="Accepted" then profiles.stage(a.entry,Country.capture(a.world,a.state),a.state.revision)end
   if outcome=="Accepted" or outcome=="NoChange" or outcome=="StaleRevision" or outcome=="Suspended" then send(player,a)end;return
  end
  local target=a.quotes
  if type(payload)=="table" and payload.projectId~=nil then
   if not fleet or payload.projectId~=require(Domain.WindProject).ID then return end
   local count=0;for key in payload do count+=1;if count>6 or not table.find({"version","epoch","sequence","command","quoteId","projectId"},key)then return end end
   payload=table.clone(payload);payload.projectId=nil;target=a.windQuotes
  end
  local ok,response=pcall(target.handle,player.UserId,payload)
  if not ok then profiles.unavailable(a.entry,"ConstructionCommandFailure");return end
  if fleet and response.state~="Rejected" and payload.command=="Quote"then
   if target==a.windQuotes then a.quotes.invalidate()else a.windQuotes.invalidate()end
  end
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
      install=function(p)a.state=Country.restore(p,a.world,e.commandEpoch,if fleet then a.state else nil);a.elapsed=0 end})
     if fleet then
      a.windQuotes=Quotes.create({owner=player.UserId,epoch=e.commandEpoch,id=id,now=os.clock,project=require(Domain.WindProject),
       receipt=function(c)return c.fleet.windReceipt end,
       topology=function(c:any)return c.construction.topologyRevision+c.fleet.investmentSerial end,
       eligible=function(c)return c.construction.receipt~=nil end,
       country=function()return Country.capture(a.world,a.state)end,
       build=function(op)profiles.stage(e,Country.capture(a.world,a.state),a.state.revision);return profiles.buildWind(e,op)end,
       profile=function()return profiles.profile(e)end,saveStatus=function()return profiles.status(e)end,
       canResume=function()return profiles.canMutate(e)end,
       install=function(p)a.state=Country.restore(p,a.world,e.commandEpoch,a.state);a.elapsed=0 end})
     end
    end
    if not a.state then
     if os.clock()-a.lastSend>=1 then a.lastSend=os.clock();send(player,a)end
     return false
    end
    a.quotes.tick()
    if a.windQuotes then a.windQuotes.tick()end
    if profiles.canMutate(e) and player:GetAttribute("OperationsTraining")~=true then
     a.elapsed+=dt
     if a.elapsed>=1 then
      local steps=math.min(2,math.floor(a.elapsed));a.elapsed=if a.elapsed>=3 then 0 else a.elapsed-steps
      if fleet and a.state.fleet.windReceipt then
       a.elapsed=0
       if not a.fleetJob then a.fleetDue=true end
      else
       for _=1,steps do
        local advance=if fleet then Country.advanceLegacy else Country.advance
        a.state=advance(a.state,a.world,Demand.atStep(a.state.step,1700,1000).demandMW)
       end
       profiles.stage(e,Country.capture(a.world,a.state),a.state.revision)
      end
     end
    else a.elapsed=0 end
    if os.clock()-a.lastSend>=1 then a.lastSend=os.clock();send(player,a)end
    return true
   end)
   if not ok then warn("[P3c Fake] Suspended: "..tostring(err));if a.entry then profiles.unavailable(a.entry,"SimulationFailure")end end
  end
  if fleet then
   local ok,err=pcall(function()
    if batch then batch.step();if batch.done()then batch.close();batch=nil end end
    if not batch then
     local ready={}
     for player,a in actors do
      if a.fleetDue and a.state and profiles.canMutate(a.entry)and player:GetAttribute("OperationsTraining")~=true then
       a.fleetDue=false;a.state=Country.fundOrStop(a.state,a.world)
       table.insert(ready,{actor=a,player=player,entry=a.entry})
      end
     end
     if #ready>0 then batch=require(script.Parent.CountryFleetBatch).new(ready,{
      current=function(b)return actors[b.player]==b.actor and profiles.canMutate(b.entry)and b.player:GetAttribute("OperationsTraining")~=true end,
      install=function(b,candidate)
       profiles.stage(b.entry,Country.capture(b.actor.world,candidate),candidate.revision)
       b.actor.state=candidate
      end,
      failed=function(b,why)profiles.unavailable(b.entry,"FleetCalculation:"..why)end})end
    end
   end)
   if not ok then
    if batch then batch.close();batch=nil end
    warn("[Fleet Fake] Suspended: "..tostring(err))
    for _,a in actors do if a.state and a.state.fleet.windReceipt then profiles.unavailable(a.entry,"FleetBatchFailure")end end
   end
  end
 end)
 game:BindToClose(function()
  if batch then batch.close();batch=nil end
  profiles.shutdown();local start=os.clock()
  while profiles.stats().profiles>0 and os.clock()-start<20 do profiles.tick();task.wait(.05)end
 end)
 folder.Parent=game.ReplicatedStorage
 host={
  -- Server-only test surface. No transport exposes these capabilities.
  connect=add,disconnect=remove,inspect=function(player:Player)return actors[player]end,
  storage=store,profiles=profiles,
  country=Country,fleet=fleet,
 }
 print("[Power State Test] Fake saves last only while this server runs; Stop Play discards them")
 return host
end
return table.freeze(Service)
