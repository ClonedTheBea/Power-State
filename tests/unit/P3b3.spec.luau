--!strict
return function()
 local S=game.ServerScriptService.Server
 local C=require(S.Domain.ProfileCodec);local L1=require(S.Domain.ProfileLease)
 local V2=require(S.Domain.ProfileSchema2);local Guard=require(S.Domain.ReviewedMigration)
 local Runner=require(S.Services.MigrationRunner);local Fake=require(S.Adapters.FakeDataStoreAdapter)
 local H=game:GetService("HttpService");local checks=0
 local function scalar(v:any):string return H:JSONEncode(v)end
 local function id():string return H:GenerateGUID(false)end
 local function check(v:boolean,message:string)assert(v,message);checks+=1 end
 local function equal(a:any,b:any):boolean return C.encode(a,scalar)==C.encode(b,scalar)end
 local world=require(S.World.WorldGenerator).create("df307a52185f423288df5749229f0808",id(),1)
 local Country=require(S.Simulation.Country);local state=Country.new(149564436,id(),world.network)
 local country=require(S.Domain.ProfileCountry).capture(world,state)
 local first={kind="Acquire",owner=149564436,id=id(),sessionId=id(),jobId="Fake",placeId=1,candidate=country}
 local acquired=L1.apply(nil,first,1000000,scalar)
 local base=L1.apply(acquired,{kind="Release",owner=149564436,id=id(),sessionId=first.sessionId,fence=1,baseRevision=1},1000001,scalar)
 for _=1,113 do Country.advance(state,3)end
 base.country=require(S.Domain.ProfileCountry).capture(world,state);base.countryRevision=state.revision;base.lastCommit.countryRevision=state.revision
 local function identity():any return {migrationId=id(),sessionId=id(),releaseId=id(),jobId="FakeMigration",placeId=1}end
 local ident=identity();local g=Guard.create(base,ident,scalar);local target=g.prepare(1000010)
 check(target.country.economy.activationStep==113 and target.country.economy.lastSettledStep==113,"Cutover cursor")
 check(target.country.bank.balanceMinor==100000 and target.country.bank.earnedMinor==0 and target.country.bank.spentMinor==0,"Exactly one grant; no backbilling")
 check(equal(target.country.simulation,base.country.simulation) and equal(target.country.network,base.country.network)
  and equal(target.country.recipe,base.country.recipe) and equal(target.country.settlement,base.country.settlement),"Exact history/infrastructure/identity preservation")
 check(equal(g.acquire(base,1000011),target) and equal(g.acquire(target,1000012),target),"Same callback and committed replay idempotent")
 for _,field in {"deliveredKwMinutes","generatedKwMinutes","onlineSteps","baseSalesMinor","bonusSalesMinor","variableExpenseMinor","fixedExpenseMinor","baseSalesRemainder","bonusSalesRemainder","variableExpenseRemainder","fixedExpenseRemainder"} do
  check(target.country.economy[field]==0,"Zero activation field "..field)
 end
 local changed=C.copy(base);changed.country.simulation.online=false
 check(not pcall(g.acquire,changed,1000011),"Valid but changed preimage denied")
 check(not pcall(g.acquire,nil,1000011),"Missing profile never initialized")
 changed=C.copy(base);changed.schemaVersion=99
 check(not pcall(g.acquire,changed,1000011),"Unsupported schema denied")
 changed=C.copy(target);changed.lease.ownerSessionId=id()
 check(not pcall(g.acquire,changed,1000011),"Conflicting owner denied")
 local release=g.prepareRelease(target,1000012)
 check(release.lease==nil and equal(release.country,target.country),"Fenced release preserves full financial/physical country")
 check(equal(g.release(target,1000013),release) and equal(g.release(release,1000014),release),"Release callback replay")
 changed=C.copy(target);changed.sessionEpoch+=1;changed.lease.fence+=1;changed.lastCommit.fence+=1
 check(not pcall(g.release,changed,1000013),"Stale fence denied")
 check(not pcall(g.release,target,target.lease.expiresAtUtcMs),"Expired lease never force released")
 local function runFault(fault:string?,phase:string?):(boolean,any,any)
  local f=Fake.create({["u:149564436"]=base});local now=1000020
  local success,result=pcall(Runner.run,{review=base,identity=identity(),scalar=scalar,
   utcMs=function()return now end,mono=function()return now/1000 end,wait=function(s:number)now+=s*1000 end,
   validateCandidate=function(p:any)V2.validate(p,149564436,scalar)end,
   read=function()return f.read("u:149564436")end,
   update=function(kind:string,transform:(any)->any):any
    if kind==phase then f.inject(fault)end
    return f.update("u:149564436",transform)
   end})
  return success,result,f
 end
 for _,phase in {"MigrateAcquire","Release"}do
  for _,fault in {"CallbackReplay","AfterWrite"}do
   local ok,result,f=runFault(fault,phase)
   check(ok,"Runner fault "..phase.." "..fault)
   check(result.profile.lease==nil and result.profile.country.bank.balanceMinor==100000,"Reconciled once-only grant")
   check(f.stats().writes==2 and f.stats().calls==4,"One migration/release, no blind retries")
   check(equal(result.profile.country.simulation,base.country.simulation),"No simulated income during proof")
  end
 end
 local ok,_,f=runFault("BeforeWrite","MigrateAcquire")
 check(not ok and f.stats().writes==0 and equal(f.inspect("u:149564436"),base),"Uncommitted failure stops without retry or release")
 ok,_,f=runFault("BeforeWrite","Release")
 check(not ok and f.stats().writes==1 and f.inspect("u:149564436").lease~=nil,"Failed release retains lease for expiry")
 local reads=0;local writes=0;local now=1000030
 ok=pcall(Runner.run,{review=base,identity=identity(),scalar=scalar,utcMs=function()return now end,
  mono=function()return now/1000 end,wait=function(s:number)now+=s*1000 end,validateCandidate=function()end,
  update=function()writes+=1;error("lost")end,read=function()reads+=1;error("unavailable")end})
 check(not ok and reads==3 and writes==1,"Unresolved ambiguous result bounded; no further action")
 local digest=game:GetService("EncodingService"):ComputeStringHash("abc",Enum.HashAlgorithm.Sha256)
 local hex=(digest:gsub(".",function(c:string):string return string.format("%02x",string.byte(c))end))
 check(hex=="ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad","Native SHA256 known vector")
 check(not pcall(require(S.Adapters.Schema2MigrationAdapter).run,{}),"Missing private package refused before real access")
 print(string.format("[P3b.3 fake] PASS: %d assertions; no real DataStore access",checks))
end
