--!strict
-- Caller supplies the local reviewed capture; all mutations below use isolated fake storage.
return function(review:any)
 local S=game.ServerScriptService.Server;local H=game:GetService("HttpService")
 local C=require(S.Domain.ProfileCodec);local V=require(S.Domain.ProfileSchema3)
 local G=require(S.Domain.ReviewedMigration3);local R=require(S.Services.MigrationRunner3)
 local F=require(S.Adapters.FakeDataStoreAdapter);local M=require(S.Domain.ProfileMigrations3)
 local function scalar(v:any):string return H:JSONEncode(v)end
 local function equal(a:any,b:any):boolean return C.encode(a,scalar)==C.encode(b,scalar)end
 local function id():string return H:GenerateGUID(false)end
 local function identity():any return {migrationId=id(),releaseId=id(),sessionId=id(),jobId="FakeV3Migration",placeId=1}end
 local count=0;local function check(ok:boolean,message:string)assert(ok,message);count+=1 end
 local base=C.copy(review);local now=2000000000000
 local g=G.create(base,identity(),scalar);local target=g.prepare(now)
 local pure=M.read(base,149564436,scalar)
 check(equal(V.previous(pure),base),"Exactly reversible seven-field pure transformation")
 check(equal(target.country,pure.country),"Atomic acquisition changes no country data beyond pure migration")
 check(target.profileRevision==25 and target.countryRevision==132 and target.sessionEpoch==8,"Approved revision/fence transition")
 check(target.lease.expiresAtUtcMs==now+180000 and target.lastCommit.kind=="MigrateAcquire","180-second migration lease")
 check(equal(target.country.economy,base.country.economy) and equal(target.country.simulation,base.country.simulation),"Exact cursor/carries/energy/history")
 check(target.country.bank.balanceMinor==100766 and target.country.bank.openingGrantMinor==100000 and target.country.bank.constructionSpentMinor==0,"No grant/debit/revenue")
 check(not target.country.construction.receipt and #target.country.deltas.builtNodes==0 and #target.country.deltas.builtLines==0,"No construction or demand")
 check(equal(g.acquire(base,now+1),target) and equal(g.acquire(target,now+2),target),"Callback and committed operation replay")
 for _,field in {"profileRevision","countryRevision","sessionEpoch","schemaVersion"}do
  local bad=C.copy(base);bad[field]+=1
  check(not pcall(g.acquire,bad,now+3),"Changed/unsupported head rejected: "..field)
 end
 check(not pcall(g.acquire,nil,now+3),"Never initialize absent record")
 local bad=C.copy(base);bad.country.simulation.online=false
 check(not pcall(g.acquire,bad,now+3),"Changed valid original country rejected")
 bad=C.copy(base);bad.country.bank.balanceMinor-=1
 check(not pcall(g.acquire,bad,now+3),"Corrupt financial record rejected")
 bad=C.copy(target);bad.lease.ownerSessionId=id()
 check(not pcall(g.acquire,bad,now+3),"Competing owner rejected")
 local released=g.prepareRelease(target,now+4)
 check(released.profileRevision==26 and released.countryRevision==132 and released.sessionEpoch==8 and not released.lease,"Exact released revisions")
 check(equal(released.country,pure.country),"Release preserves complete country")
 check(equal(g.release(target,now+5),released) and equal(g.release(released,now+6),released),"Idempotent release")
 bad=C.copy(target);bad.sessionEpoch+=1;bad.lease.fence+=1;bad.lastCommit.fence+=1
 check(not pcall(g.release,bad,now+5),"Stale fence refused")
 check(not pcall(g.release,target,target.lease.expiresAtUtcMs),"No expired force release")
 local metadata={version="v24",createdTime=1,updatedTime=2,metadata={review="retained"},userIds={149564436}}
 local function info(m:any):any return {Version=m.version,CreatedTime=m.createdTime,UpdatedTime=m.updatedTime,
  GetMetadata=function()return m.metadata end,GetUserIds=function()return m.userIds end}end
 check(pcall(G.metadata,info(metadata),metadata,true,scalar),"Original platform metadata accepted")
 for _,field in {"version","createdTime","updatedTime","metadata","userIds"}do
  local changed=C.copy(metadata);changed[field]=if field=="version" then "other" elseif field=="metadata" then {} elseif field=="userIds" then {1} else 99
  check(not pcall(G.metadata,info(changed),metadata,true,scalar),"Metadata mismatch refused: "..field)
 end
 local changed=C.copy(metadata);changed.version="v25";changed.updatedTime=3
 check(pcall(G.metadata,info(changed),metadata,false,scalar),"New platform version retains associations")
 for _,phase in {"MigrateAcquire","Release"}do
  for _,fault in {"None","CallbackReplay","AfterWrite","BeforeWrite"}do
   local store=F.create({["u:149564436"]=base});local clock=now
   local ok,result=pcall(R.run,{review=base,identity=identity(),scalar=scalar,
    utcMs=function()return clock end,mono=function()return clock/1000 end,wait=function(s:number)clock+=s*1000 end,
    validateCandidate=function(p:any)V.validate(p,149564436,scalar);assert(equal(p.country,pure.country))end,
    read=function()return store.read("u:149564436")end,
    update=function(kind:string,fn:(any)->any):any if kind==phase and fault~="None" then store.inject(fault)end;return store.update("u:149564436",fn)end})
   if fault=="BeforeWrite" then
    check(not ok and store.stats().writes==(if phase=="MigrateAcquire" then 0 else 1),"Failed write stops without replacement")
    check(if phase=="MigrateAcquire" then equal(store.inspect("u:149564436"),base) else store.inspect("u:149564436").lease~=nil,"No rollback/forced unlock")
   else
    check(ok and not result.profile.lease and equal(result.profile.country,pure.country),"Safe result: "..phase.." "..fault)
    check(store.stats().writes==2 and store.stats().calls==4,"One migration/release with uncached confirmations")
   end
  end
 end
 local reads=0;local writes=0;local clock=now
 local ok=pcall(R.run,{review=base,identity=identity(),scalar=scalar,utcMs=function()return clock end,mono=function()return clock/1000 end,
  wait=function(s:number)clock+=s*1000 end,validateCandidate=function()end,update=function()writes+=1;error("lost")end,
  read=function()reads+=1;error("unavailable")end})
 check(not ok and writes==1 and reads==3,"Uncertain outcome bounded; no replacement write")
 check(not pcall(require(S.Adapters.Schema3MigrationAdapter).run,{}),"Missing private package denied before service access")
 print(string.format("[P3c2 fake] PASS: %d assertions; no real service calls",count))
end
