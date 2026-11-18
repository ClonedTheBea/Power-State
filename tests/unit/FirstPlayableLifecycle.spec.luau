--!strict
-- Exercises the normal host's exact departure/arrival handlers; no real storage.
return function(player:Player)
 local S=game.ServerScriptService.Server;local Codec=require(S.Domain.ProfileCodec)
 local Country=require(S.Domain.ConstructionCountry);local H=game:GetService("HttpService")
 local function scalar(v:any):string return H:JSONEncode(v)end
 local host=require(S.Services.ConstructionTestService).start()
 local checks=0;local function check(v:boolean,why:string)assert(v,why);checks+=1 end
 local function waitFor(fn:()->boolean)
  local deadline=os.clock()+15;repeat task.wait(.05)until fn() or os.clock()>deadline;check(fn(),"Lifecycle deadline")
 end
 local a=host.inspect(player);assert(a and a.state and a.state.construction.receipt,"Complete normal GUI build first")
 for _,fault in {"AfterWrite","BeforeWrite"}do
  a=host.inspect(player)
  local before=Country.capture(a.world,a.state);local epoch=a.state.epoch
  host.storage.inject(fault);host.disconnect(player)
  waitFor(function()return host.profiles.stats().profiles==0 end)
  local saved=host.storage.inspect(a.entry.key)
  check(saved.lease==nil,"Departure releases lease after fake fault")
  check(Codec.encode(saved.country,scalar)==Codec.encode(before,scalar),"Exact financial/history/infrastructure departure save")
  task.wait(1)
  host.connect(player)
  waitFor(function()local nextActor=host.inspect(player);return nextActor and nextActor.state~=nil end)
  local nextActor=host.inspect(player)
  check(nextActor.state.epoch~=epoch,"Reconnect issues fresh command epoch")
  check(Codec.encode(Country.capture(nextActor.world,nextActor.state),scalar)==Codec.encode(saved.country,scalar),"Reconnect restores exact state without offline progression")
  local n,outcome=require(S.Services.ConstructionControls).handle(nextActor.state,nextActor.world,player.UserId,
   {version=1,kind="SetGenerator",epoch=epoch,sequence=1,revision=nextActor.state.controlRevision,assetId=nextActor.state.network.generatorId,online=false},os.clock(),true)
  check(outcome=="StaleSession" and n.online==nextActor.state.online,"Old player command cannot control new session")
  local status=nextActor.quotes.handle(player.UserId,{version=1,epoch=nextActor.state.epoch,sequence=1,command="Quote"})
  check(status.state=="AlreadyBuilt","Permanent receipt prevents another purchase after reconnect")
  check(host.profiles.stats().profiles==1 and host.profiles.stats().inFlight<=1,"One owned profile after reconnect")
 end
 print(string.format("[First Playable lifecycle] PASS: %d assertions; fake host handlers, not hosted network reconnect; stats %s",checks,H:JSONEncode(host.storage.stats())))
end
