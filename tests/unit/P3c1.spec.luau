--!strict
-- Pure readiness checks. Caller supplies a captured profile; this module has no storage API.
return function(profile:any)
 local D=game.ServerScriptService.Server.Domain
 local Codec=require(D.ProfileCodec)
 local V2=require(D.ProfileSchema2)
 local V3=require(D.ProfileSchema3)
 local M=require(D.ProfileMigrations3)
 local H=game:GetService("HttpService")
 local function scalar(v:any):string return H:JSONEncode(v)end
 local function encode(v:any):string return Codec.encode(v,scalar)end
 local count=0
 local function check(v:boolean,message:string)assert(v,message);count+=1 end
 V2.validate(profile,149564436,scalar)
 local original=encode(profile)
 local preview=M.read(profile,149564436,scalar)
 local bytes,soft=V3.validate(preview,149564436,scalar)
 check(encode(profile)==original,"Input preserved")
 check(encode(V3.previous(preview))==original,"Complete v2 projection preserved")
 check(encode(M.read(preview,149564436,scalar))==encode(preview),"Idempotent v3 reload")
 for _,key in {"recipe","settlement","network","ownedSectors","simulation","economy","deltas"}do
  check(encode(preview.country[key])==encode(profile.country[key]),"Exact country subtree preservation: "..key)
 end
 local bank=Codec.copy(preview.country.bank);bank.ledgerVersion=2;bank.constructionSpentMinor=nil
 check(encode(bank)==encode(profile.country.bank),"Every original Bank/grant field preserved")
 check(preview.country.bank.constructionSpentMinor==0,"No construction debit")
 check(preview.country.construction.receipt==nil and preview.country.construction.topologyRevision==0,"No purchase or topology")
 check(preview.profileRevision==profile.profileRevision and preview.countryRevision==profile.countryRevision and preview.sessionEpoch==profile.sessionEpoch,"Pure preview changes no revision or fence")
 check(preview.lease==nil and profile.lease==nil,"No lease created")
 check(bytes<196608 and not soft,"Preview below soft and hard caps")
 check(not pcall(V3.validate,profile,149564436,scalar),"V3 validator rejects old schema")
 check(not pcall(V2.validate,preview,149564436,scalar),"V2 validator rejects v3")
 for _,version in {1,4}do
  local bad=Codec.copy(profile);bad.schemaVersion=version
  check(not pcall(M.read,bad,149564436,scalar),"Unsupported migration source rejected")
 end
 local bad=Codec.copy(preview);bad.country.bank.balanceMinor-=1
 check(not pcall(V3.validate,bad,149564436,scalar),"Unmatched Bank debit rejected")
 bad=Codec.copy(preview);bad.country.bank.openingGrantMinor+=100000
 check(not pcall(V3.validate,bad,149564436,scalar),"Duplicate grant rejected")
 bad=Codec.copy(preview);bad.country.bank.constructionSpentMinor=100000
 check(not pcall(V3.validate,bad,149564436,scalar),"Capital without purchase rejected")
 bad=Codec.copy(preview);bad.country.economy.lastSettledStep+=1
 check(not pcall(V3.validate,bad,149564436,scalar),"Cursor ahead of simulation rejected")
 bad=Codec.copy(preview);bad.country.construction.compositionVersion=3
 check(not pcall(V3.validate,bad,149564436,scalar),"Unknown composition rejected")
 check(not pcall(Codec.encode,{oversized=string.rep("x",262145)},scalar),"Oversized profile rejected")
 print(string.format("[P3c1 pure readiness] PASS: %d assertions; v3 %d bytes; no service calls",count,bytes))
 return count
end
