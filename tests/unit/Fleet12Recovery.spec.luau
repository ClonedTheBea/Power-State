--!strict
return function(f:any)
 local S=game.ServerScriptService.Server;local H=game:GetService("HttpService")
 local scalar=function(v:any):string return H:JSONEncode(v)end
 local C=require(S.Domain.ProfileCodec);local F=require(S.Domain.FleetStorageFormat)
 local A=require(S.Adapters.FakeFleetStorageAdapter);local key="u:149564436"
 for _,version in {1,2}do
  require(script.Parent["FleetTransactions.spec"])(f,version,function(seed:any)return A.create(seed,scalar)end)
 end
 local checks=0;local function check(v:boolean,m:string)assert(v,m);checks+=1 end
 for _,source in {f.funded,F.pack(f.funded,149564436,scalar)}do
  local a=A.create({[key]=source},scalar);local original=C.encode(a.inspectStored(key),scalar)
  local before=C.encode(a.read(key),scalar)
  local ok=pcall(a.update,key,function(p:any)p.country.bank.balanceMinor+=1;return p end)
  check(not ok and C.encode(a.inspectStored(key),scalar)==original,"Failed conversion commits nothing")
  a.inject("BeforeWrite");check(not pcall(a.update,key,function(p)return p end),"Interrupted before write")
  check(C.encode(a.inspectStored(key),scalar)==original,"No partial format switch")
  a.inject("AfterWrite");check(not pcall(a.update,key,function(p)return p end),"Lost conversion response")
  check(a.inspectStored(key).storageVersion==1 and C.encode(a.read(key),scalar)==before,"Read reconciles entire converted profile exactly")
  a.inject("CallbackReplay");a.update(key,function(p)return p end)
  check(C.encode(a.read(key),scalar)==before,"Replay adds no grant, debit, income or simulation")
 end
 local packed=C.copy(F.pack(f.built,149564436,scalar));packed.storageVersion=99
 local a=A.create({[key]=packed},scalar)
 check(not pcall(a.read,key)and a.stats().writes==0,"Unknown stored version never overwritten")
 check(not pcall(a.update,key,function()return f.built end)and a.stats().writes==0,"Invalid old record prevents callback replacement")
 print("FLEET12_RECOVERY_GATE_PASS",checks,"plus 170 compact transaction assertions; fake only")
end
