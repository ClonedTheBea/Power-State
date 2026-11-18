--!strict
-- A single reviewed preimage, one acquisition and one release. No gameplay mutations.
local Codec=require(script.Parent.ProfileCodec)
local V1=require(script.Parent.ProfileSchema)
local V2=require(script.Parent.ProfileSchema2)
local Lease=require(script.Parent.ProfileLease2)
local Guard={}
function Guard.create(review:any,identity:any,scalar:(any)->string)
 local before=Codec.copy(review)
 V1.validate(before,149564436,scalar)
 assert(before.lease==nil,"Reviewed lease must be absent")
 local encoded=Codec.encode(before,scalar)
 local op={kind="Acquire",owner=149564436,id=identity.migrationId,sessionId=identity.sessionId,
  jobId=identity.jobId,placeId=identity.placeId}
 assert(identity.releaseId~=identity.migrationId,"Distinct release receipt required")
 local acquired:any=nil;local released:any=nil
 local api={}
 function api.prepare(now:number):any
  assert(not acquired,"Already prepared")
  local value,reason=Lease.apply(before,op,now,scalar);assert(value and not reason,"Migration rejected")
  V2.validate(value,149564436,scalar);acquired=value
  return Codec.copy(value)
 end
 function api.acquire(current:any,now:number):any
  assert(acquired and now<acquired.lease.expiresAtUtcMs-Lease.SAFETY_MS,"Migration deadline")
  if current and current.schemaVersion==2 then
   V2.validate(current,149564436,scalar)
   assert(Codec.encode(current,scalar)==Codec.encode(acquired,scalar),"Unexpected v2 head")
   return Codec.copy(current)
  end
  V1.validate(current,149564436,scalar)
  assert(Codec.encode(current,scalar)==encoded,"Reviewed preimage changed")
  return Codec.copy(acquired)
 end
 function api.verifyAcquired(value:any)
  V2.validate(value,149564436,scalar)
  assert(acquired and Codec.encode(value,scalar)==Codec.encode(acquired,scalar),"Unconfirmed migration")
 end
 function api.prepareRelease(value:any,now:number):any
  api.verifyAcquired(value)
  assert(not released,"Release already prepared")
  local release={kind="Release",owner=149564436,id=identity.releaseId,sessionId=identity.sessionId,
   fence=value.sessionEpoch,baseRevision=value.profileRevision}
  local nextValue,reason=Lease.apply(value,release,now,scalar)
  assert(nextValue and not reason,"Cannot safely release lease")
  V2.validate(nextValue,149564436,scalar);released=nextValue
  assert(Codec.encode(released.country,scalar)==Codec.encode(acquired.country,scalar),"Release changed country")
  return Codec.copy(nextValue)
 end
 function api.release(current:any,now:number):any
  assert(released,"Release not prepared")
  V2.validate(current,149564436,scalar)
  if Codec.encode(current,scalar)==Codec.encode(released,scalar) then return Codec.copy(current)end
  api.verifyAcquired(current)
  assert(now<current.lease.expiresAtUtcMs,"Lease expired; do not force unlock")
  return Codec.copy(released)
 end
 function api.verifyReleased(value:any)
  V2.validate(value,149564436,scalar)
  assert(released and Codec.encode(value,scalar)==Codec.encode(released,scalar),"Unconfirmed release")
 end
 return api
end
return table.freeze(Guard)
