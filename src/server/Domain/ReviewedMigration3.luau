--!strict
-- A single reviewed preimage, one acquisition and one release. No gameplay mutations.
local Codec=require(script.Parent.ProfileCodec)
local V1=require(script.Parent.ProfileSchema2)
local V2=require(script.Parent.ProfileSchema3)
local Lease=require(script.Parent.ProfileLease3)
local Migration=require(script.Parent.ProfileMigrations3)
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
  local pure=Migration.read(before,149564436,scalar)
  assert(Codec.encode(V2.previous(pure),scalar)==encoded,"Pure migration preservation")
  local value,reason=Lease.apply(pure,op,now,scalar);assert(value and not reason,"Migration rejected")
  value.countryRevision+=1;value.lastCommit.countryRevision=value.countryRevision;value.lastCommit.kind="MigrateAcquire"
  V2.validate(value,149564436,scalar);acquired=value
  return Codec.copy(value)
 end
 function api.acquire(current:any,now:number):any
  assert(acquired and now<acquired.lease.expiresAtUtcMs-Lease.SAFETY_MS,"Migration deadline")
  if current and current.schemaVersion==3 then
   V2.validate(current,149564436,scalar)
   assert(Codec.encode(current,scalar)==Codec.encode(acquired,scalar),"Unexpected v3 head")
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
function Guard.metadata(info:any,expected:any,original:boolean,scalar:(any)->string)
 assert(info~=nil,"Missing key metadata")
 assert(Codec.encode(info:GetMetadata(),scalar)==Codec.encode(expected.metadata,scalar),"Changed custom metadata")
 assert(Codec.encode(info:GetUserIds(),scalar)==Codec.encode(expected.userIds,scalar),"Changed associated UserIds")
 assert(info.CreatedTime==expected.createdTime,"Changed creation time")
 if original then assert(info.Version==expected.version and info.UpdatedTime==expected.updatedTime,"Reviewed platform version changed")end
end
return table.freeze(Guard)
