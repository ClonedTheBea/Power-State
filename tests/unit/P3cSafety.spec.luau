--!strict
return function()
 local S=game.ServerScriptService.Server;local H=game:GetService("HttpService")
 local Codec=require(S.Domain.ProfileCodec);local Migration=require(S.Domain.ProfileMigrations3)
 local Schema=require(S.Domain.ProfileSchema3);local Lease=require(S.Domain.ProfileLease3)
 local Country=require(S.Domain.ConstructionCountry);local Demand=require(S.World.DemandModel)
 local Fake=require(S.Adapters.FakeDataStoreAdapter);local Profiles=require(S.Services.ProfileService)
 local Quotes=require(S.Services.ConstructionQuotes)
 local function id():string return H:GenerateGUID(false)end
 local function scalar(v:any):string return H:JSONEncode(v)end
 local count=0;local function check(v:boolean,m:string)assert(v,m);count+=1 end
 local fixture=require(script.Parent["P3b4Fixture"])();local world=fixture.world
 local seed=Migration.read(fixture.profile,149564436,scalar);local s=Country.restore(seed,world,id())
 for _=1,150 do s=Country.advance(s,world,Demand.atStep(s.step,1700,1000).demandMW)end
 seed.country=Country.capture(world,s);seed.countryRevision=s.revision;seed.lastCommit.countryRevision=s.revision
 local now=1000;local epochs=id();local builds=0
 local quote=Quotes.create({owner=1,epoch=epochs,now=function()return now end,id=id,country=function()return seed.country end,
  build=function()builds+=1;return false,"DrainingSave"end})
 local function request(seq:number,command:string,qid:string?,owner:number?):any
  return quote.handle(owner or 1,{version=1,epoch=epochs,sequence=seq,command=command,quoteId=qid})
 end
 local q=request(1,"Quote")
 check(request(2,"Confirm",q.quoteId,2).state=="Rejected","Cross-player confirmation")
 now+=30;check(request(2,"Confirm",q.quoteId).state=="QuoteExpired" and builds==0,"Exact expiry before dispatch")
 now+=1;local fresh=request(3,"Quote");now+=1
 check(request(4,"Confirm",q.quoteId).state=="QuoteExpired","Superseded quote")
 check(request(5,"Confirm",fresh.quoteId).state=="DrainingSave" and builds==1,"Save drain has no acceptance")
 check(quote.handle(1,{version=1,epoch=epochs,sequence=6,command="Confirm",quoteId=fresh.quoteId,price=0}).state=="Rejected","Forged price")
 check(quote.handle(1,{version=1,epoch="wrong",sequence=6,command="Quote"}).state=="Rejected","Old command epoch")
 local values={};for owner=1,8 do local p=Codec.copy(seed);p.ownerUserId=owner;values["u:"..owner]=p end
 local memory=gcinfo();local fake=Fake.create(values);local tasks:{()->()}={}
 local service=Profiles.create({adapter=fake,schema=Schema,lease=Lease,scalar=scalar,id=id,jobId="EightFake",placeId=1,
  utcMs=function()return math.floor(now*1000)end,mono=function()return now end,random=function()return 0 end,
  spawn=function(fn)table.insert(tasks,fn)end})
 local entries={}
 for owner=1,8 do local e=service.reserve(owner);table.insert(entries,e);service.prepared(e,seed.country)end
 check(service.reserve(9)==nil,"Eight-profile admission bound")
 service.tick();check(service.stats().inFlight==4 and #tasks==4,"Four-call dispatch bound")
 local function drain()
  local pending=tasks;tasks={};for _,fn in pending do fn()end
  service.tick()
 end
 drain();drain()
 for _,e in entries do service.activate(e)end
 local started=os.clock()
 for _,e in entries do check(service.build(e,id()),"Eight fake purchases admitted")end
 service.tick();check(service.stats().inFlight==4,"Builds reuse global call limit")
 drain();drain()
 local maxBytes=0
 for _,e in entries do
  local p=service.profile(e);check(p.country.construction.receipt~=nil and service.canMutate(e),"Eight independent durable candidates")
  maxBytes=math.max(maxBytes,#Codec.encode(p,scalar))
 end
 print(string.format("[P3c eight fake] commits CPU %.3fms; max profile %d bytes; heap delta %.1fKiB; peak calls %d",(os.clock()-started)*1000,maxBytes,gcinfo()-memory,service.stats().peakInFlight))
 -- Lost committed response plus failed reconciliation: close must never save the pre-debit prefix.
 local store=Fake.create({["u:149564436"]=seed});local queued:{()->()}={}
 local svc=Profiles.create({adapter=store,schema=Schema,lease=Lease,scalar=scalar,id=id,jobId="Uncertain",placeId=1,
  utcMs=function()return math.floor(now*1000)end,mono=function()return now end,random=function()return 0 end,
  spawn=function(fn)table.insert(queued,fn)end})
 local e=svc.reserve(149564436);svc.prepared(e,seed.country);svc.tick();(table.remove(queued,1) :: ()->())();svc.tick();svc.activate(e)
 local op=id();check(svc.build(e,op),"Critical operation accepted")
 store.inject("AfterWrite");svc.tick();(table.remove(queued,1) :: ()->())();store.inject("ReadFailure");svc.tick()
 now+=31;svc.tick();check(not svc.canMutate(e),"Deadline keeps country suspended")
 svc.close(e);now+=21;svc.tick()
 local saved=store.inspect("u:149564436")
 check(saved.country.construction.receipt.operationId==op and saved.country.bank.balanceMinor==seed.country.bank.balanceMinor-100000,"Ambiguous commit retained atomically")
 check(saved.lease~=nil,"No unsafe release/force unlock")
 check(store.stats().writes==2,"No old checkpoint overwrote unknown purchase")
 for _,fn in queued do pcall(fn)end
 svc.tick()
 check(store.inspect("u:149564436").country.construction.receipt.operationId==op,"Late callback cannot erase construction")
 print(string.format("[Power State P3c safety] PASS: %d assertions",count))
end
