--!strict
local V2=require(script.Parent.ProfileSchema2)
local Codec=require(script.Parent.ProfileCodec)
local Project=require(script.Parent.ConstructionProject)
local Economy=require(script.Parent.Economy)
local Schema={MAX_INTEGER=V2.MAX_INTEGER,integer=V2.integer}
local function fields(t:any,names:string,optional:string?)
 assert(type(t)=="table","Construction record required")
 local allowed={}
 for k in string.gmatch(names,"%S+")do allowed[k]=true;assert(t[k]~=nil,"Missing "..k)end
 for k in string.gmatch(optional or "","%S+")do allowed[k]=true end
 for k in t do assert(allowed[k],"Unknown construction field")end
end
local function equal(a:any,b:any,scalar:(any)->string)
 assert(Codec.encode(a,scalar)==Codec.encode(b,scalar),"Construction contract mismatch")
end
-- Validation-only projection: capital debit is removed together with its delta.
function Schema.previousCountry(c:any):any
 local n=Codec.copy(c);n.construction=nil
 local capital=n.bank.constructionSpentMinor
 Schema.integer(capital,0,Project.PRICE)
 n.bank.constructionSpentMinor=nil;n.bank.ledgerVersion=2
 n.bank.spentMinor-=capital;n.bank.balanceMinor+=capital
 n.deltas.builtNodes={};n.deltas.builtLines={};n.deltas.nextBuiltAssetSerial=1
 return n
end
function Schema.previous(p:any):any
 local n=Codec.copy(p);n.schemaVersion=2;n.country=Schema.previousCountry(p.country)
 if n.lastCommit.kind=="Build" then n.lastCommit.kind="Checkpoint"end
 return n
end
function Schema.country(c:any,scalar:((any)->string)?)
 local encode=scalar or function(v:any):string return game:GetService("HttpService"):JSONEncode(v)end
 assert(c.bank.ledgerVersion==3,"Ledger 3 required")
 V2.country(Schema.previousCountry(c))
 Schema.integer(c.bank.balanceMinor,0,Economy.CAP);Schema.integer(c.bank.spentMinor,0,Economy.CAP)
 local x=c.construction
 fields(x,"constructionVersion constructionDemandVersion compositionVersion topologyRevision","receipt")
 assert(x.constructionVersion==1 and x.constructionDemandVersion==1 and x.compositionVersion==2,"Construction version")
 if not x.receipt then
  assert(x.topologyRevision==0 and c.bank.constructionSpentMinor==0 and c.deltas.nextBuiltAssetSerial==1,"Empty construction invariant")
  equal(c.deltas.builtNodes,{},encode);equal(c.deltas.builtLines,{},encode)
 else
  local r=x.receipt
  fields(r,"projectId definitionVersion operationId priceMinor terminalId lineId step beforeBankMinor afterBankMinor countryRevision profileRevision")
  assert(r.projectId==Project.ID and r.definitionVersion==1 and r.priceMinor==Project.PRICE,"Project receipt")
  assert(type(r.operationId)=="string" and #r.operationId==36 and string.match(r.operationId,"^[%x]+%-[%x]+%-[%x]+%-[%x]+%-[%x]+$"),"Operation GUID")
  assert(x.topologyRevision==1 and c.bank.constructionSpentMinor==Project.PRICE and c.deltas.nextBuiltAssetSerial==3,"Built invariant")
  Schema.integer(r.step,0,c.simulation.step);Schema.integer(r.countryRevision,1,Schema.MAX_INTEGER);Schema.integer(r.profileRevision,1,Schema.MAX_INTEGER)
  Schema.integer(r.beforeBankMinor,125000,Economy.CAP);Schema.integer(r.afterBankMinor,25000,Economy.CAP)
  assert(r.beforeBankMinor-r.afterBankMinor==Project.PRICE,"Receipt debit")
  local node,line=Project.assets(c)
  assert(r.terminalId==node.id and r.lineId==line.id,"Receipt assets")
  equal(c.deltas.builtNodes,{node},encode);equal(c.deltas.builtLines,{line},encode)
 end
 assert(#Codec.encode(x,encode)<=4096,"Construction size")
end
function Schema.validate(p:any,owner:number,scalar:(any)->string):(number,boolean)
 local encoded=Codec.encode(p,scalar)
 assert(p.schemaVersion==3,"Schema 3 required")
 V2.validate(Schema.previous(p),owner,scalar);Schema.country(p.country,scalar)
 local r=p.country.construction.receipt
 if r then assert(r.profileRevision<=p.profileRevision and r.countryRevision<=p.countryRevision,"Future construction receipt")end
 assert(#Codec.encode({bank=p.country.bank,economy=p.country.economy},scalar)<=16384,"Finance size")
 return #encoded,#encoded>196608
end
function Schema.transition(a:any,b:any,scalar:(any)->string)
 Schema.country(b,scalar)
 equal(a.construction,b.construction,scalar);equal(a.deltas,b.deltas,scalar)
 assert(a.bank.constructionSpentMinor==b.bank.constructionSpentMinor,"Capital mutation requires Build")
 Economy.transition(Schema.previousCountry(a),Schema.previousCountry(b),scalar)
end
return table.freeze(Schema)
