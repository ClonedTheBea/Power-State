--!strict
-- Separately gated manual capability. No normal startup or client caller.
local REAL_POSTBUILD_PROOF_APPROVED=false
local C=require(script.Parent.Parent.Domain.ProfileCodec)
local V=require(script.Parent.Parent.Domain.ProfileSchema3)
local Plan=require(script.Parent.Parent.Domain.PostBuildProofPlan)
local Adapter={}
local approved:any=setmetatable({}, {__mode="k"})
local attempted=false
function Adapter.isApproved(value:any):boolean return approved[value]==true end
function Adapter.create(phase:string,originCanonical:string,reviewedCanonical:string,reviewedPlatform:any):any
 assert(REAL_POSTBUILD_PROOF_APPROVED,"PostBuild gate closed")
 local run=game:GetService("RunService")
 local function authenticate()
  assert(run:IsStudio() and not run:IsRunning() and game.GameId==10776833313,"Stopped Test Studio only")
  assert(game.CreatorType==Enum.CreatorType.User and game.CreatorId==149564436,"Personal creator only")
  assert(game:GetService("StudioService"):GetUserId()==149564436,"Authenticated approved Studio account only")
 end
 authenticate();assert(not attempted,"One session per fresh context")
 local h=game:GetService("HttpService");local function scalar(v:any):string return h:JSONEncode(v)end
 local function hash(raw:string):string
  return (game:GetService("EncodingService"):ComputeStringHash(raw,Enum.HashAlgorithm.Sha256):gsub(".",function(c:string):string return string.format("%02x",string.byte(c))end))
 end
 assert(hash(originCanonical)=="72299d6608dda5275d48e0a35c78dca8c48254fd11d2783a40b67bc86d01cd85","Frozen built origin")
 local origin=h:JSONDecode(originCanonical);local reviewed=h:JSONDecode(reviewedCanonical)
 V.validate(reviewed,Plan.OWNER,scalar);assert(C.encode(reviewed,scalar)==reviewedCanonical,"Canonical review")
 local plan=Plan.create(origin,reviewed,phase,scalar);local expectedSha=hash(reviewedCanonical)
 assert(reviewedPlatform.createdTime==1794944138060 and #reviewedPlatform.userIds==1 and reviewedPlatform.userIds[1]==149564436 and next(reviewedPlatform.metadata)==nil,"Reviewed platform identity")
 if phase=="A" then
  assert(reviewedPlatform.version=="08DF44E1F51DCFA5.0000000025.08DF45716BF4E852.01" and reviewedPlatform.updatedTime==1795005755473,"Pinned initial platform")
 else assert(type(reviewedPlatform.version)=="string" and reviewedPlatform.updatedTime>1795005755473,"Retained Session A platform required")end
 attempted=true
 local service=game:GetService("DataStoreService")
 local store=service:GetDataStore("PowerStateProfilesP3aTest") -- Default/global; never caller-selected.
 local records={};local originalMetadata:any=nil;local originalUsers:any=nil
 local latestPlatform:any=nil;local latestProfile:any=nil;local preimageRetained=false
 local function metadata(info:any)
  assert(info~=nil,"Missing platform metadata")
  local users=info:GetUserIds();assert(#users==1 and users[1]==149564436,"Unexpected user association")
  if originalMetadata then
   assert(C.encode(info:GetMetadata(),scalar)==C.encode(originalMetadata,scalar) and C.encode(users,scalar)==C.encode(originalUsers,scalar),"Changed metadata")
  else originalMetadata=info:GetMetadata();originalUsers=users end
 end
 local function measured(kind:string,fn:()->any):any
  assert(#records<12,"Per-session application ceiling")
  local start=os.clock();local ok,value=pcall(fn)
  table.insert(records,{kind=kind,ok=ok,ms=(os.clock()-start)*1000,
   readBudget=service:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync),
   writeBudget=service:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.SetIncrementAsync),
   transition=if ok and value and value.lastCommit then value.lastCommit.kind else nil,
   profileRevision=if ok and value then value.profileRevision else nil,
   step=if ok and value and value.country then value.country.simulation.step else nil})
  if not ok then error("PostBuild transport failed; reconcile or stop")end;assert(os.clock()-start<30,"Application operation deadline");return value
 end
 local function read(key:string):any
  assert(key==Plan.KEY,"Exact approved key only");authenticate()
  return measured("Read",function()
   local options=Instance.new("DataStoreGetOptions");options.UseCache=false
   local ok,value,info=pcall(function()return store:GetAsync(key,options)end);options:Destroy()
   assert(ok,"Uncached read failed");metadata(info)
   latestPlatform={version=info.Version,createdTime=info.CreatedTime,updatedTime=info.UpdatedTime,
    userIds=info:GetUserIds(),metadata=info:GetMetadata()}
   latestProfile=C.copy(value);return value
  end)
 end
 local initial=read(Plan.KEY)
 assert(C.encode(initial,scalar)==reviewedCanonical,"Fresh complete profile mismatch")
 assert(C.encode(latestPlatform,scalar)==C.encode(reviewedPlatform,scalar),"Fresh complete platform mismatch")
 local initialPlatform=C.copy(latestPlatform)
 local transport={mode="Real",read=read,
  budget=function():boolean return service:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync)>0 and service:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.SetIncrementAsync)>0 end,
  update=function(key:string,transform:(any)->any):any
   assert(preimageRetained,"Protected preimage retention required")
   assert(key==Plan.KEY,"Exact approved key only");authenticate()
   return measured("Update",function()return store:UpdateAsync(key,function(current:any,info:any)
    metadata(info);local value=transform(current);if not value then return nil end
    return value,info:GetUserIds(),info:GetMetadata()
   end)end)
  end}
 local adapter=Plan.guard(transport,plan,scalar);approved[adapter]=true
 return {adapter=table.freeze(adapter),plan=plan,records=function()return C.copy(records)end,
  confirmPreimageRetained=function(sha:string)assert(sha==expectedSha,"Independent exact preimage hash required");preimageRetained=true end,
  capture=function()return {initial=C.copy(initial),initialPlatform=C.copy(initialPlatform),latest=C.copy(latestProfile),latestPlatform=C.copy(latestPlatform),records=C.copy(records)}end}
end
return table.freeze(Adapter)
