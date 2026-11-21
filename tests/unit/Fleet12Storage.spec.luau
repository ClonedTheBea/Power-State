--!strict
return function(f:any)
 local D=game.ServerScriptService.Server.Domain;local H=game:GetService("HttpService")
 local C=require(D.ProfileCodec);local F=require(D.FleetStorageFormat);local V=require(D.ProfileSchema4)
 local scalar=function(v:any):string return H:JSONEncode(v)end
 local checks=0;local function check(v:boolean,m:string)assert(v,m);checks+=1 end
 local empty=require(script.Parent.Fleet12Fixture)(f.world)
 local packedEmpty=F.pack(empty,149564436,scalar)
 check(C.encode(F.read(H:JSONDecode(H:JSONEncode(packedEmpty)),149564436,scalar),scalar)==C.encode(empty,scalar),"Exact empty histories through JSON")
 check(empty.country.bank.balanceMinor==100000 and #empty.country.simulation.history==0,"Empty fixture uses original grant only")
 local partial=require(script.Parent.P3b4Fixture)().profile
 partial=require(D.ProfileMigrations3).read(partial,149564436,scalar)
 partial=require(D.ProfileMigrations4).read(partial,149564436,H:GenerateGUID(false),scalar)
 for _,p in {partial,f.funded,f.built,f.post,f.high}do
  local before=C.encode(p,scalar);local packed=F.pack(p,149564436,scalar)
  local round=F.read(H:JSONDecode(H:JSONEncode(packed)),149564436,scalar)
  check(C.encode(round,scalar)==before,"Exact canonical complete profile round trip")
  check(C.encode(F.read(p,149564436,scalar),scalar)==before,"Existing format readable")
  check(C.encode(p,scalar)==before,"Conversion does not mutate caller")
  check(table.isfrozen(round.country.fleet.baseline)and table.isfrozen(round.country.fleet.baseline.legacySimulation.history),"Decoded legacy evidence stays immutable")
  local cached=F.read(packed,149564436,scalar);cached.country.bank.balanceMinor+=1
  check(C.encode(F.read(packed,149564436,scalar),scalar)==before,"Cached proof never aliases mutable returned country")
  local bytes=#C.encode(packed,scalar)
  local rows=#p.country.simulation.history+#p.country.fleet.baseline.legacySimulation.history
  print("FLEET12_STORAGE_SIZE",H:JSONEncode({legacy=#before,compact=bytes,rows=rows,overhead=bytes-#before+rows*24}))
  for _,mutate in {
   function(n:any)n.storageVersion=2 end,
   function(n:any)n.storageFormat="unknown"end,
   function(n:any)n.profile.schemaVersion=3 end,
   function(n:any)n.extra=true end,
   function(n:any)n.profile.country.simulation.history[1]={1}end,
   function(n:any)n.profile.country.simulation.history[1]={0,0,0}end,
   function(n:any)n.profile.country.simulation.history[1]=({"0",0}::{any})end,
   function(n:any)n.profile.country.simulation.history[1]={[1]=0,[3]=0}end,
   function(n:any)n.profile.country.simulation.history[1]=nil end,
   function(n:any)n.profile.country.fleet.baseline.legacySimulation.history={}end,
   function(n:any)n.profile.country.bank.balanceMinor+=1 end,
   function(n:any)n.profile.country.simulation.history[1]={0/0,0}end,
   function(n:any)n.profile.country.simulation.history[1]={math.huge,0}end,
   function(n:any)n.profile.country.simulation.history[1]={0,1}end,
  }do local bad=C.copy(packed);mutate(bad);check(not pcall(F.read,bad,149564436,scalar),"Malformed storage rejected")end
  check(not pcall(F.read,packed,149564437,scalar),"Owner cannot change through conversion")
 end
 V.validate(f.post,149564436,scalar)
 local original=F.pack(f.built,149564436,scalar)
 F.read(original,149564436,scalar)
 for _=1,20 do F.read(F.pack(f.built,149564436,scalar),149564436,scalar);task.wait()end
 check(C.encode(F.read(original,149564436,scalar),scalar)==C.encode(f.built,scalar),"Eviction preserves full validation and exact output")
 local alternate=function(v:any):string return H:JSONEncode(v)end
 check(C.encode(F.read(original,149564436,alternate),scalar)==C.encode(f.built,scalar),"Different encoder revalidates")
 local mutable=C.copy(original);F.read(mutable,149564436,scalar);mutable.profile.country.bank.balanceMinor+=1
 check(not pcall(F.read,mutable,149564436,scalar),"Mutable input cannot retain proof")
 local high=F.pack(f.high,149564436,scalar)
 local bound=#C.encode(high,function(v:any):string
  if type(v)=="number"then assert(#scalar(v)<=24);return string.rep("9",24)end
  return scalar(v)
 end)+1024
 check(bound<262144,"Complete compact conservative envelope")
 print("FLEET12_STORAGE_ENVELOPE",bound,"headroom",262144-bound,"canonical limit also retained",f.upperBytes)
 print("FLEET12_STORAGE_PURE_PASS",checks,"no coordinator integration")
end
