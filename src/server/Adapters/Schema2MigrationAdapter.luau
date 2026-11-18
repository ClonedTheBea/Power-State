--!strict
-- P3b.3 approval: stopped authenticated Test Studio only; one migration and release.
-- No generic update/checkpoint API and no bootstrap, remote or gameplay caller.
local Codec=require(script.Parent.Parent.Domain.ProfileCodec)
local V1=require(script.Parent.Parent.Domain.ProfileSchema)
local V2=require(script.Parent.Parent.Domain.ProfileSchema2)
local Migration=require(script.Parent.Parent.Domain.ProfileMigrations2)
local Runner=require(script.Parent.Parent.Services.MigrationRunner)
local Adapter={}
local PREIMAGE_SHA="d812a9752fa685f9d6976e08ea0821510b4d82c405fa11df558c2903628655df"
local CANDIDATE_SHA="68cdcb0723bf19e742c37b869908f442e10e8c40e2570a85297ce58bdbc72f38"
local METADATA_SHA="62d1c010d67a8c57ed508376b3c26785aa8fbb23d18d9ea5bc6af98ea9e9e6b4"
local KEY="u:149564436"
local attempted=false -- One sequential invocation per module lifetime, including failures.
function Adapter.run(package:any):any
 local run=game:GetService("RunService")
 assert(run:IsStudio() and not run:IsRunning() and game.GameId==10776833313,"Stopped Test Studio only")
 assert(game.CreatorType==Enum.CreatorType.User and game.CreatorId==149564436,"Approved personal creator only")
 assert(game:GetService("StudioService"):GetUserId()==149564436,"Approved authenticated Studio account only")
 assert(not attempted,"Migration proof already attempted")
 local http=game:GetService("HttpService")
 local encoding=game:GetService("EncodingService")
 local function sha(value:string):string
  return (encoding:ComputeStringHash(value,Enum.HashAlgorithm.Sha256):gsub(".",function(c:string):string return string.format("%02x",string.byte(c))end))
 end
 local function scalar(value:any):string return http:JSONEncode(value)end
 assert(type(package)=="table","Private review package required")
 assert(type(package.preimage)=="string" and #package.preimage==6620 and sha(package.preimage)==PREIMAGE_SHA,"Reviewed preimage checksum")
 assert(type(package.candidate)=="string" and #package.candidate==7269 and sha(package.candidate)==CANDIDATE_SHA,"Reviewed candidate checksum")
 assert(type(package.metadata)=="string" and #package.metadata==351 and sha(package.metadata)==METADATA_SHA,"Reviewed metadata checksum")
 local review=http:JSONDecode(package.preimage);local candidate=http:JSONDecode(package.candidate);local metadata=http:JSONDecode(package.metadata)
 V1.validate(review,149564436,scalar);V2.validate(candidate,149564436,scalar)
 assert(Codec.encode(review,scalar)==package.preimage and Codec.encode(candidate,scalar)==package.candidate,"Canonical recovery package")
 assert(metadata.universe==10776833313 and metadata.creator==149564436 and metadata.authenticatedUser==149564436
  and metadata.store=="PowerStateProfilesP3aTest" and metadata.scope=="global" and metadata.key==KEY,"Reviewed destination")
 local migrationId=candidate.country.economy.activationOperationId
 assert(Codec.encode(Migration.read(review,149564436,migrationId,scalar),scalar)==package.candidate,"Approved transformation differs")
 local function checkMetadata(info:any,original:boolean)
  assert(info~=nil,"Missing key metadata")
  assert(Codec.encode(info:GetMetadata(),scalar)==Codec.encode(metadata.metadata,scalar),"Changed custom metadata")
  assert(Codec.encode(info:GetUserIds(),scalar)==Codec.encode(metadata.userIds,scalar),"Changed associated UserIds")
  if original then
   assert(info.Version==metadata.version and info.CreatedTime==metadata.createdTime and info.UpdatedTime==metadata.updatedTime,"Reviewed platform version changed")
  end
 end
 attempted=true
 local service=game:GetService("DataStoreService")
 local store=service:GetDataStore("PowerStateProfilesP3aTest") -- Default/global; no caller-controlled destination.
 local records={};local latestVersion="";local acquiredVersion=""
 local function measured(kind:string,call:()->any):any
  assert(#records<9,"Request ceiling")
  local start=os.clock();local ok,value=pcall(call)
  table.insert(records,{kind=kind,ms=(os.clock()-start)*1000,ok=ok,
   readBudget=service:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync),
   writeBudget=service:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.SetIncrementAsync)})
  print("[P3b.3 request] "..http:JSONEncode(records[#records]))
  if not ok then error("Migration service call failed; reconcile or stop")end
  return value
 end
 local preflight=true
 local function read():any
  assert(service:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync)>0,"Read budget unavailable")
  return measured("Read",function()
   local options=Instance.new("DataStoreGetOptions");options.UseCache=false
   local ok,value,info=pcall(function()return store:GetAsync(KEY,options)end)
   options:Destroy();assert(ok,"Uncached read failed")
   checkMetadata(info,preflight);latestVersion=info.Version
   if value and value.schemaVersion==2 and value.lease then acquiredVersion=info.Version end
   return value
  end)
 end
 local current=read()
 V1.validate(current,149564436,scalar)
 assert(current.lease==nil and Codec.encode(current,scalar)==package.preimage
  and sha(Codec.encode(current,scalar))==PREIMAGE_SHA,"Fresh complete preimage mismatch; stop")
 preflight=false
 print("[P3b.3 preflight] PASS: exact authenticated Test/global/key, reviewed version and SHA-256, schema1 revisions15/123 epoch4, absent lease")
 local function update(kind:string,transform:(any)->any):any
  assert(kind=="MigrateAcquire" or kind=="Release","No financial writes authorized")
  assert(service:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync)>0
   and service:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.SetIncrementAsync)>0,"Update budget unavailable")
  return measured(kind,function()
   return store:UpdateAsync(KEY,function(value:any,info:any)
    checkMetadata(info,value and value.schemaVersion==1)
    local nextValue=transform(value);V2.validate(nextValue,149564436,scalar)
    assert(Codec.encode(nextValue.country,scalar)==Codec.encode(candidate.country,scalar),"Migration-only country invariant")
    return nextValue,info:GetUserIds(),info:GetMetadata()
   end)
  end)
 end
 local outcome=Runner.run({review=review,scalar=scalar,identity={migrationId=migrationId,
  sessionId=http:GenerateGUID(false),releaseId=http:GenerateGUID(false),jobId="StudioP3b3MigrationOnly",placeId=game.PlaceId},
  utcMs=function():number return DateTime.now().UnixTimestampMillis end,mono=os.clock,wait=task.wait,read=read,update=update,
  validateCandidate=function(value:any)
   V2.validate(value,149564436,scalar)
   assert(value.profileRevision==16 and value.countryRevision==124 and value.sessionEpoch==5,"Approved counters")
   assert(Codec.encode(value.country,scalar)==Codec.encode(candidate.country,scalar),"Approved country candidate")
  end})
 local final=outcome.profile
 assert(final.profileRevision==17 and final.lease==nil and final.lastCommit.kind=="Release","Final fenced release")
 return {profile=final,operations=outcome.operations,records=records,version=latestVersion,migrationVersion=acquiredVersion,
  canonical=Codec.encode(final,scalar),sha256=sha(Codec.encode(final,scalar))}
end
return table.freeze(Adapter)
