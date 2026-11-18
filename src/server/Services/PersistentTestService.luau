--!strict
-- Explicit opt-in proof. Normal start remains fake; real start requires the approved Player.
local Run=game:GetService("RunService")
local Players=game:GetService("Players")
local Http=game:GetService("HttpService")
local Profiles=require(script.Parent.ProfileService)
local Fake=require(script.Parent.Parent.Adapters.FakeDataStoreAdapter)
local Queue=require(script.Parent.Parent.World.GenerationScheduler)
local Generator=require(script.Parent.Parent.World.WorldGenerator)
local Demand=require(script.Parent.Parent.World.DemandModel)
local ProfileCountry=require(script.Parent.Parent.Domain.ProfileCountry)
local Codec=require(script.Parent.Parent.Domain.ProfileCodec)
local Country=require(script.Parent.Parent.Simulation.Country)
local Handler=require(script.Parent.Parent.Simulation.IntentHandler)
local Trace=require(game.ReplicatedStorage.Shared.Util.SnapshotTrace)
local Service={};local started=false;local inspect:(()->any)?=nil
local function start(store:any,economic:boolean?,existing:boolean?)
 local approvedEconomy=require(script.Parent.Parent.Adapters.Schema2GameplayAdapter).isApproved(store)
 assert(not economic or tostring(store.mode)=="Fake" or (existing and approvedEconomy),"P3b real execution is not authorized")
 local Economics=if economic then require(script.Parent.Parent.Domain.EconomicCountry) else nil
 local capture:(any,any)->any=if Economics then Economics.capture else ProfileCountry.capture
 local restore:(any,any,string)->any=if Economics then Economics.restore else ProfileCountry.restore
 local handle:(any,number,any,number)->string=if Economics then Economics.handle else Handler.handle
 assert(Run:IsStudio() and Run:IsServer() and game.GameId==10776833313,"P3a isolated Test only")
 if started then return end;started=true
 local random=Random.new()
 local profiles=Profiles.create({adapter=store,
  schema=if economic then require(script.Parent.Parent.Domain.ProfileSchema2) else nil,
  lease=if existing then require(script.Parent.Parent.Domain.ExistingEconomyLease) elseif economic then require(script.Parent.Parent.Domain.ProfileLease2) else nil,
  prepareCountry=if existing then require(script.Parent.Parent.Domain.ProfileSchema2).country else require(script.Parent.Parent.Domain.ProfileSchema).country,utcMs=function()return DateTime.now().UnixTimestampMillis end,mono=os.clock,
  id=function()return Http:GenerateGUID(false)end,scalar=function(v:any)return Http:JSONEncode(v)end,
  spawn=task.spawn,random=function()return random:NextNumber()end,jobId=if game.JobId=="" then "Studio" else game.JobId,placeId=game.PlaceId})
 local jobs=Queue.create();local actors:{[Player]:any}={}
 local folder=Instance.new("Folder");folder.Name=if economic then "P3bSimulation" else "P3aSimulation"
 local intent=Instance.new("RemoteEvent");intent.Name="Intent";intent.Parent=folder
 local remote=Instance.new("RemoteEvent");remote.Name="Snapshot";remote.Parent=folder
 local function add(player:Player)
  if (store.mode=="Real" or existing) and player.UserId~=149564436 then return end
  local handle=profiles.reserve(player.UserId);if not handle then return end
  local actor:any={handle=handle,state=nil,world=nil,job=nil,subscribed=false,elapsed=0,tokens=4,rateAt=os.clock(),lastSend=0}
  actors[player]=actor
  if existing then
   -- The candidate is validation-only; ExistingEconomyLease cannot initialize it.
   profiles.prepared(handle,store.preflight.country);actor.phase="Acquire";return
  end
  local seed=string.lower((string.gsub(Http:GenerateGUID(false),"%-","")));local id=Http:GenerateGUID(false)
  actor.job=jobs.add(function()actor.world=Generator.create(seed,id,1,coroutine.yield)end)
  actor.phase="Prepare"
 end
 local function send(player:Player,a:any,full:boolean,outcome:string?)
  if not a.subscribed then return end
  local save=profiles.status(a.handle)
  if not a.state then remote:FireClient(player,{version=1,loadState=save});return end
  local value:any=Country.snapshot(a.state,outcome)
  value.suspended=not profiles.canMutate(a.handle) or a.state.suspended
  value.profile=if economic then "P3b" else "P3a";value.save=save;value.bankMinor=if economic then a.state.bank.balanceMinor else 0
  if economic then value.finance={bank=Codec.copy(a.state.bank),economy=Codec.copy(a.state.economy)};value.finance.economy.activationOperationId=nil end
  value.climate=Demand.atStep(math.max(0,a.state.step-1),a.world.meanTemperatureCentiC,1000)
  value.minute=(720+a.state.step)%1440;value.generatorId=a.state.network.generatorId;value.demandId=a.state.network.demandId
  if full then value.world=Generator.snapshot(a.world)end
  assert(#Http:JSONEncode(value)<=(if full then 262144 elseif economic then 24576 else 8192),"P3a snapshot bound")
  Trace.record("publish:"..(outcome or "periodic"),value,a.elapsed)
  remote:FireClient(player,value)
 end
 Players.PlayerAdded:Connect(add)
 Players.PlayerRemoving:Connect(function(player)
  local a=actors[player];if not a then return end
  if a.job then jobs.cancel(a.job)end
  profiles.close(a.handle);actors[player]=nil
 end)
 for _,player in Players:GetPlayers()do add(player)end
 intent.OnServerEvent:Connect(function(player,payload,...)
  local a=actors[player];if not a then return end
  if not a.state then
   local now=os.clock();a.tokens=math.min(4,a.tokens+math.max(0,now-a.rateAt)*2);a.rateAt=now
   if a.tokens<1 then return end;a.tokens-=1
   if select("#",...)~=0 or type(payload)~="table" then return end
   local count=0;for key in payload do count+=1;if key~="version" and key~="kind" then return end end
   if count~=2 or payload.version~=1 then return end
   if payload.kind=="Sync" then a.subscribed=true;send(player,a,false)elseif payload.kind=="Unsubscribe" then a.subscribed=false end
   return
  end
  local candidate=Codec.copy(a.state)
  candidate.suspended=not profiles.canMutate(a.handle) or a.state.suspended
  local ok,result=pcall(handle,candidate,player.UserId,if select("#",...)==0 then payload else nil,os.clock())
  if not ok then profiles.unavailable(a.handle,"CommandFailure");return end
  if result=="Accepted" then
   local staged=pcall(profiles.stage,a.handle,capture(a.world,candidate),candidate.revision)
   if not staged then profiles.unavailable(a.handle,"InvalidCheckpoint");return end
  end
  a.state=candidate
  Trace.record("intent:"..result,candidate,a.elapsed)
  if result=="Unsubscribed" then a.subscribed=false;return end
  if result=="Synced" then a.subscribed=true end
  if result~="RateLimited" then send(player,a,result=="Synced",result)end
 end)
 Run.Heartbeat:Connect(function(dt)
  jobs.step();profiles.tick()
  for player,a in actors do
   local ok=pcall(function()
    if a.job and a.job.status~="pending" then
     assert(a.job.status=="complete","Generation unavailable");a.job=nil
     if a.phase=="Prepare" then
      profiles.prepared(a.handle,ProfileCountry.capture(a.world,Country.new(player.UserId,"initial",a.world.network)))
      a.phase="Acquire"
     elseif a.phase=="Restore" then
      a.state=restore(profiles.profile(a.handle),a.world,a.handle.commandEpoch)
      profiles.activate(a.handle);a.phase="Live";a.elapsed=0;send(player,a,true,"Synced")
     end
    end
    if a.phase=="Acquire" and a.handle.acquired and not a.handle.closing and not a.handle.terminal then
     local p=profiles.profile(a.handle)
     a.phase="Restore"
     a.job=jobs.add(function()a.world=Generator.create(p.country.recipe.seed,p.country.recipe.countryId,p.country.recipe.generationVersion,coroutine.yield)end)
    end
    if a.state and profiles.canMutate(a.handle) and not a.state.suspended then
     a.elapsed+=dt
     if a.elapsed>=1 then
      local steps=math.min(2,math.floor(a.elapsed));local delayed=a.elapsed>=3
      a.elapsed=if delayed then 0 else a.elapsed-steps
      local candidate=Codec.copy(a.state);candidate.delayed=delayed
      for _=1,steps do local d=Demand.atStep(candidate.step,a.world.meanTemperatureCentiC,1000);if Economics then candidate=Economics.advance(candidate,d.demandMW)else Country.advance(candidate,d.demandMW)end end
      profiles.stage(a.handle,capture(a.world,candidate),candidate.revision);a.state=candidate
      Trace.record("settled",candidate,a.elapsed)
     end
    else a.elapsed=0 end
    if os.clock()-a.lastSend>=1 then a.lastSend=os.clock();send(player,a,false)end
   end)
   if not ok then
    if a.job then jobs.cancel(a.job);a.job=nil end
    profiles.unavailable(a.handle,"RestoreOrSimulationUnavailable")
   end
  end
 end)
 game:BindToClose(function()
  for _,a in actors do if a.job then jobs.cancel(a.job)end end
  profiles.shutdown();local began=os.clock()
  while profiles.stats().profiles>0 and os.clock()-began<20 do profiles.tick();task.wait(.05)end
 end)
 inspect=function()
  local saved={}
  for player,a in actors do saved[tostring(player.UserId)]={status=profiles.status(a.handle),profile=profiles.profile(a.handle),state=Codec.copy(a.state)}end
  return {profiles=profiles.stats(),store=store.stats(),mode=store.mode,actors=saved}
 end
 folder.Parent=game:GetService("ReplicatedStorage")
 print("[P3a] Explicit isolated proof storage: "..store.mode)
end
function Service.start()start(Fake.create())end
function Service.startEconomy()start(Fake.create(),true)end
function Service.startExistingEconomyFake(store:any)
 assert(store.mode=="Fake","Fake validation only")
 local policy=require(script.Parent.Parent.Domain.ExistingEconomyStore).create(store,function(v:any):string return Http:JSONEncode(v)end,function():number return DateTime.now().UnixTimestampMillis end)
 start(policy,true,true)
end
function Service.startRealEconomy(player:Player)
 assert(not started,"Proof already started")
 local real=require(script.Parent.Parent.Adapters.Schema2GameplayAdapter).create(player)
 start(real,true,true)
end
function Service.startReal(player:Player,expectedCountryId:string?)
 assert(not started,"Proof already started")
 local real=require(script.Parent.Parent.Adapters.DataStoreAdapter).create(player,expectedCountryId)
 start(real)
end
function Service.inspect():any
 assert(Run:IsStudio() and Run:IsServer() and game.GameId==10776833313 and inspect,"P3a Test diagnostics only")
 return inspect()
end
return table.freeze(Service)
