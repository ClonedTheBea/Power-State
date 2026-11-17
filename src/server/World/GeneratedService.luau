--!strict
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local Http=game:GetService("HttpService")
local Generator=require(script.Parent.WorldGenerator)
local Demand=require(script.Parent.DemandModel)
local Scheduler=require(script.Parent.GenerationScheduler)
local Country=require(script.Parent.Parent.Simulation.Country)
local Handler=require(script.Parent.Parent.Simulation.IntentHandler)
local Service={}
local inspect: (() -> any)? = nil
function Service.inspect()
 assert(Run:IsStudio() and game.GameId==10776833313 and Run:IsServer(),"Test server diagnostics only")
 assert(inspect,"Generated service not started")
 return inspect()
end
function Service.start()
 assert(Run:IsStudio() and game.GameId==10776833313,"P2b isolated Test only")
 local folder=Instance.new("Folder");folder.Name="P2bSimulation"
 local intent=Instance.new("RemoteEvent");intent.Name="Intent";intent.Parent=folder
 local remote=Instance.new("RemoteEvent");remote.Name="Snapshot";remote.Parent=folder
 type Entry={state:Country.State?,world:any,job:Scheduler.Job?,subscribed:boolean,climate:any,yields:number,timing:any}
 local entries:{[Player]:Entry}={};local order:{Player}={}
 local scheduler=Scheduler.create()
 local function add(player:Player)
  if entries[player] or #order>=8 then return end
  local seed=string.lower((string.gsub(Http:GenerateGUID(false),"%-","")))
  local id=Http:GenerateGUID(false)
  local entry:Entry={state=nil,world=nil,job=nil,subscribed=false,climate=nil,yields=0,timing=nil}
  entry.job=scheduler.add(function()
   entry.world=Generator.create(seed,id,1,function()entry.yields+=1;coroutine.yield()end)
  end)
  entries[player]=entry;table.insert(order,player)
 end
 inspect=function()
  local rows={}
  for _,player in order do
   local entry=entries[player]
   table.insert(rows,{userId=player.UserId,ready=entry.state~=nil,pending=entry.job~=nil,
    subscribed=entry.subscribed,world=if entry.state then Generator.snapshot(entry.world) else nil,
    snapshot=if entry.state then Country.snapshot(entry.state) else nil,
    owner=if entry.state then entry.state.owner else nil,timing=entry.timing})
  end
  -- Copy through serialization so diagnostics cannot mutate private service state.
  return Http:JSONDecode(Http:JSONEncode(rows))
 end
 local function send(player:Player,entry:Entry,full:boolean,outcome:string?)
  local state=entry.state;if not state or not entry.subscribed then return end
  local value:any=Country.snapshot(state,outcome)
  value.profile="P2b";value.climate=entry.climate;value.minute=(720+state.step)%1440
  value.generatorId=state.network.generatorId;value.demandId=state.network.demandId
  if full then value.world=Generator.snapshot(entry.world) end
  assert(#Http:JSONEncode(value)<=(if full then 262144 else 8192),"P2b snapshot budget")
  remote:FireClient(player,value)
 end
 Players.PlayerAdded:Connect(add)
 Players.PlayerRemoving:Connect(function(player)
  local entry=entries[player];if entry and entry.job then scheduler.cancel(entry.job) end
  entries[player]=nil;local i=table.find(order,player);if i then table.remove(order,i)end
 end)
 for _,player in Players:GetPlayers()do add(player)end
 intent.OnServerEvent:Connect(function(player,payload,...)
  local entry=entries[player];if not entry or not entry.state then return end
  local ok,result=pcall(Handler.handle,entry.state,player.UserId,if select("#",...)==0 then payload else nil,os.clock())
  if not ok then entry.state.suspended=true;warn("[P2b] Intent suspended");return end
  if result=="Unsubscribed" then entry.subscribed=false;return end
  if result=="Synced" then entry.subscribed=true end
  if result~="RateLimited" then send(player,entry,result=="Synced",result)end
 end)
 local elapsed=0
 Run.Heartbeat:Connect(function(dt)
  scheduler.step()
  for _,player in order do
   local entry=entries[player];local job=entry.job
   if job and job.status~="pending" then
    entry.timing={cpuMs=if entry.world then entry.world.cpuMs else 0,wallMs=job.wallMs,
     queueMs=job.queueMs,waitMs=job.waitMs,resumeMs=job.resumeMs,yields=entry.yields,resumes=job.resumes,status=job.status}
    entry.job=nil
    if job.status=="complete" then
     local ok,problem=pcall(function()
      local d=Demand.atStep(0,entry.world.meanTemperatureCentiC,entry.world.network.population)
      entry.world.network.demandMW=d.demandMW
      entry.climate=d;entry.state=Country.new(player.UserId,entry.world.countryId,entry.world.network)
     end)
     if not ok then entry.state=nil;entry.world=nil;warn("[P2b] Initialization unavailable: "..tostring(problem)) end
    else entry.world=nil;warn("[P2b] Generation unavailable: "..tostring(job.problem)) end
    print("[P2b.1 timing] "..Http:JSONEncode({userId=player.UserId,timing=entry.timing,ready=entry.state~=nil}))
   end
  end
  elapsed+=dt;if elapsed<1 then return end
  local count=math.min(2,math.floor(elapsed));local delayed=elapsed>=3
  elapsed=if delayed then 0 else elapsed-count
  for _,player in order do
   local entry=entries[player];local state=entry.state
   if state then
    state.delayed=delayed
    if not state.suspended then
     for _=1,count do
      local ok,problem=pcall(function()
       local d=Demand.atStep(state.step,entry.world.meanTemperatureCentiC,state.network.population)
       Country.advance(state,d.demandMW);entry.climate=d
      end)
      if not ok then state.suspended=true;warn("[P2b] Step suspended: "..tostring(problem));break end
     end
    end
    send(player,entry,false)
   end
  end
 end)
 folder.Parent=game:GetService("ReplicatedStorage")
 print("[P2b] Test service: GUID seed, version 1; session only; Native presentation")
end
return table.freeze(Service)
