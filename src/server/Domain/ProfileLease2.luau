--!strict
local V1=require(script.Parent.ProfileSchema)
local Schema=require(script.Parent.ProfileSchema2)
local Legacy=require(script.Parent.ProfileLease)
local Codec=require(script.Parent.ProfileCodec)
local Migration=require(script.Parent.ProfileMigrations2)
local Economy=require(script.Parent.Economy)
local Lease={DURATION_MS=Legacy.DURATION_MS,SAFETY_MS=Legacy.SAFETY_MS}
function Lease.apply(current:any,op:any,now:number,scalar:(any)->string):(any,string?)
 local isV2=current and current.schemaVersion==2
 if current then
  if isV2 then Schema.validate(current,op.owner,scalar)else V1.validate(current,op.owner,scalar)end
  if current.lastCommit.operationId==op.id then return Codec.copy(current),nil end
 end
 if not isV2 then
  assert(op.kind=="Acquire","V1 requires explicit migration acquisition")
  local p,why=Legacy.apply(current,op,now,scalar)
  if not p then return nil,why end
  local n=Migration.read(p,op.owner,op.id,scalar)
  n.countryRevision+=1;n.lastCommit.countryRevision=n.countryRevision
  if current then n.lastCommit.kind="MigrateAcquire"end
  Schema.validate(n,op.owner,scalar);return n,nil
 end
 local projected=Codec.copy(op)
 if op.snapshot then
  Schema.country(op.snapshot)
  Economy.transition(current.country,op.snapshot,scalar)
  projected.snapshot=Schema.legacyCountry(op.snapshot)
 end
 local p,why=Legacy.apply(Schema.legacy(current),projected,now,scalar)
 if not p then return nil,why end
 p.schemaVersion=2
 local source=op.snapshot or current.country
 p.country.bank=Codec.copy(source.bank);p.country.economy=Codec.copy(source.economy)
 Schema.validate(p,op.owner,scalar);return p,nil
end
return table.freeze(Lease)
