--!strict
-- Pure schema4 transitions reuse the unchanged fenced envelope, never a store.
local V1=require(script.Parent.ProfileLease)
local Schema=require(script.Parent.ProfileSchema4)
local C=require(script.Parent.ProfileCodec)
local R=require(script.Parent.FleetRecord)
local Lease={DURATION_MS=180000,SAFETY_MS=30000}
local function structural(p:any):any
 local n=table.clone(p);n.lastCommit=table.clone(p.lastCommit);n.schemaVersion=1;n.country=Schema.structural(p.country)
 if table.find({"MigrateAcquire","Build","BuildWind"},n.lastCommit.kind)then n.lastCommit.kind="Checkpoint"end
 return n
end
function Lease.apply(current:any,op:any,now:number,scalar:(any)->string):(any,string?)
 assert(current~=nil,"Schema4 initialization is explicit")
 Schema.validate(current,op.owner,scalar)
 assert(table.find({"Acquire","Checkpoint","Renew","Release","Build","BuildWind"},op.kind),"Unsupported fleet operation")
 if op.kind=="Acquire"or op.kind=="Renew"then assert(op.snapshot==nil,"Ownership-only operation cannot advance gameplay")end
 if current.lastCommit.operationId==op.id then return C.copy(current),nil end
 -- The v1 transition reads its inputs and creates independent result copies.
 -- Avoid cloning large before/snapshot records that are immediately replaced.
 local projected=table.clone(op)
 if op.kind=="Build" or op.kind=="BuildWind"then
  local wind=op.kind=="BuildWind"
  local receipt=if wind then current.country.fleet.windReceipt else current.country.construction.receipt
  if receipt then return nil,"AlreadyBuilt"end
  assert(op.before and op.snapshot,"Immutable purchase prefix required")
  Schema.transition(current.country,op.before,scalar)
  assert(op.countryRevision==op.beforeRevision+1 and op.beforeRevision>=current.countryRevision,"Purchase revision")
  local project:any=if wind then require(script.Parent.WindProject)else require(script.Parent.ConstructionProject)
  if wind then project=project.catalog(if op.windDefinitionVersion==nil then 1 else op.windDefinitionVersion)end
  R.equal(project.build(op.before,op.id,op.countryRevision,current.profileRevision+1),op.snapshot,scalar)
  Schema.country(op.snapshot,scalar);projected.kind="Checkpoint"
 elseif op.snapshot then Schema.transition(current.country,op.snapshot,scalar)end
 if op.snapshot then projected.snapshot=Schema.structural(op.snapshot)end
 local result,why=V1.apply(structural(current),projected,now,scalar)
 if not result then return nil,why end
 result.schemaVersion=4;result.country=C.copy(op.snapshot or current.country)
 if op.kind=="Build" or op.kind=="BuildWind"then result.lastCommit.kind=op.kind end
 Schema.validate(result,op.owner,scalar)
 return result,nil
end
return table.freeze(Lease)
