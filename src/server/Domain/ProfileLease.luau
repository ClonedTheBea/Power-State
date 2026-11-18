--!strict
local Codec=require(script.Parent.ProfileCodec)
local Schema=require(script.Parent.ProfileSchema)
local Lease={DURATION_MS=180000,SAFETY_MS=30000}
function Lease.apply(current:any,op:any,nowMs:number,scalar:(any)->string):(any,string?)
 Schema.integer(nowMs,0,Schema.MAX_INTEGER-Lease.DURATION_MS)
 if current~=nil then
  Schema.validate(current,op.owner,scalar)
  if current.lastCommit.operationId==op.id then return Codec.copy(current),nil end
 end
 local p:any
 if op.kind=="Acquire" then
  if current and current.lease and current.lease.expiresAtUtcMs>nowMs then return nil,"InUse" end
  p=if current then Codec.copy(current) else {schemaVersion=1,ownerUserId=op.owner,createdAtUtc=math.floor(nowMs/1000),lastSavedAtUtc=math.floor(nowMs/1000),profileRevision=0,countryRevision=0,sessionEpoch=0,country=Codec.copy(op.candidate)}
  p.sessionEpoch+=1
  p.lease={ownerSessionId=op.sessionId,jobId=op.jobId,placeId=op.placeId,fence=p.sessionEpoch,expiresAtUtcMs=nowMs+Lease.DURATION_MS}
 else
  if not current then return nil,"Missing" end
  local lock=current.lease
  if not lock or lock.ownerSessionId~=op.sessionId or lock.fence~=op.fence or lock.expiresAtUtcMs<=nowMs then return nil,"OwnershipLost" end
  if current.profileRevision~=op.baseRevision then return nil,"RevisionConflict" end
  p=Codec.copy(current)
  if op.snapshot then
   assert(op.countryRevision>=p.countryRevision,"Country revision regression")
   for _,key in {"recipe","settlement","network","ownedSectors","bank","deltas"}do
    assert(Codec.encode(op.snapshot[key],scalar)==Codec.encode(p.country[key],scalar),"Immutable country mutation")
   end
   p.country=Codec.copy(op.snapshot);p.countryRevision=op.countryRevision;p.lastSavedAtUtc=math.floor(nowMs/1000)
  end
  if op.kind=="Release" then p.lease=nil
  else p.lease.expiresAtUtcMs=nowMs+Lease.DURATION_MS end
 end
 local base=p.profileRevision;p.profileRevision+=1
 p.lastCommit={operationId=op.id,kind=op.kind,fence=p.sessionEpoch,baseProfileRevision=base,committedProfileRevision=p.profileRevision,countryRevision=p.countryRevision}
 Schema.validate(p,op.owner,scalar)
 return p,nil
end
return table.freeze(Lease)
