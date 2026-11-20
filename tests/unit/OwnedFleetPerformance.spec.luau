--!strict
return function(fixtures:any)
 local S=game.ServerScriptService.Server;local H=game:GetService("HttpService")
 local heapBefore=gcinfo()
 local Country=require(S.Domain.FleetCountry);local Batch=require(S.Services.CountryFleetBatch)
 local Profiles=require(S.Services.ProfileService);local Fake=require(S.Adapters.FakeDataStoreAdapter)
 local store=Fake.create();local profiles=Profiles.create({adapter=store,schema=require(S.Domain.ProfileSchema4),lease=require(S.Domain.ProfileLease4),
  id=function()return H:GenerateGUID(false)end,scalar=function(v:any)return H:JSONEncode(v)end,jobId="EightFleetFake",placeId=1,
  utcMs=function()return DateTime.now().UnixTimestampMillis end,mono=os.clock,random=function()return 0 end,spawn=function(fn)fn()end})
 local records={};local sourceId=fixtures.built.country.recipe.countryId
 local pattern=sourceId:gsub("%W","%%%0")
 local function rekey(v:any,newId:string):any
  if type(v)=="string"then return (v:gsub(pattern,newId))end
  if type(v)~="table"then return v end
  local n={};for k,x in v do n[rekey(k,newId)]=rekey(x,newId)end;return n
 end
 for i=1,8 do
  local identity=H:GenerateGUID(false);local p=rekey(fixtures.built,identity);p.ownerUserId=-i
  local world=rekey(fixtures.world,identity)
  store.update("fake:"..(-i),function()return p end)
  local e=profiles.reserve(-i);profiles.prepared(e,p.country)
  profiles.tick();profiles.tick();assert(e.acquired,"Fake profile acquisition");profiles.activate(e)
  local actor:any={world=world,state=Country.restore(profiles.profile(e),world,e.commandEpoch)}
  table.insert(records,{actor=actor,entry=e})
 end
 for _,hz in {60,30}do
  local installed=0;local failure=nil;local at=os.clock()
  local batch=Batch.new(records,{current=function()return true end,
   install=function(b:any,state:any)
    profiles.stage(b.entry,Country.capture(b.actor.world,state),state.revision)
    b.actor.state=state;installed+=1
   end,
   failed=function(_b:any,why:string)failure=why end})
  local admission=(os.clock()-at)*1000;local peak=0;local installPeak=0;local callbacks=0
  repeat
   local began=os.clock();local m=batch.step();local cpu=(os.clock()-began)*1000;callbacks+=cpu;peak=math.max(peak,cpu);installPeak=math.max(installPeak,m.installMs)
   if not batch.done()then task.wait(1/hz)end
  until batch.done()or os.clock()-at>2
  local stats=batch.stats();batch.close()
  print("OWNED_FLEET_PERFORMANCE",H:JSONEncode({requestedCadence=hz,installed=installed,failure=failure,admissionMs=admission,
   peakCallbackMs=peak,peakInstallMs=installPeak,totalCpuMs=callbacks+admission,totalWallMs=(os.clock()-at)*1000,solver=stats,coordinator=profiles.stats(),
   note=if game:GetService("RunService"):IsRunning()then "Studio Play; includes fake-coordinator staging, not hosted/device acceptance"else "Studio edit mode; includes fake-coordinator staging, not client frame/device acceptance"}))
  assert(installed==8 and failure==nil,"All owned-country jobs must settle")
  assert(stats.peakMs<=4 and stats.cpuMs<=80,"Unchanged solver budgets")
  assert((os.clock()-at)<.750,"Eight-country native/30 Hz completion deadline")
  for _,b in records do assert(b.actor.fleetJob==nil,"No retained country job")end
 end
 profiles.shutdown()
 for _=1,32 do profiles.tick();if profiles.stats().profiles==0 then break end end
 assert(profiles.stats().profiles==0 and profiles.stats().inFlight==0,"Eight fake owners released and coordinator drained")
 print("[Owned fleet resource cleanup] profiles=0 jobs=0 heapDeltaKiB",gcinfo()-heapBefore,"shared Luau heap includes GC, not a peak memory bound")
end
