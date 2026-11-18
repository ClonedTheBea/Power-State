--!strict
-- Independently gated manual phases. No startup/remote caller can open either gate.
local REAL_CONSTRUCTION_PROOF_APPROVED=false
local REAL_BUILD_PROOF_APPROVED=false
local C=require(script.Parent.Parent.Domain.ProfileCodec)
local V=require(script.Parent.Parent.Domain.ProfileSchema3)
local Plan=require(script.Parent.Parent.Domain.ConstructionProofPlan)
local Adapter={}
local approved:any=setmetatable({}, {__mode="k"})
local attempted=false
function Adapter.isApproved(value:any):boolean return approved[value]==true end
function Adapter.create(phase:string,reviewedCanonical:string):any
 if phase=="Fund" then
  assert(REAL_CONSTRUCTION_PROOF_APPROVED and not REAL_BUILD_PROOF_APPROVED,"Stage A gate closed")
 elseif phase=="Build" then
  assert(REAL_BUILD_PROOF_APPROVED and not REAL_CONSTRUCTION_PROOF_APPROVED,"Stage B gate closed")
 else error("Unknown phase")end
 local run=game:GetService("RunService")
 assert(run:IsStudio() and not run:IsRunning() and game.GameId==10776833313,"Stopped Test Studio only")
 assert(game.CreatorType==Enum.CreatorType.User and game.CreatorId==149564436,"Personal creator only")
 local function authenticate()assert(game:GetService("StudioService"):GetUserId()==149564436,"Approved authenticated Studio account only")end
 authenticate();assert(not attempted,"One phase per manual adapter lifetime")
 assert(phase=="Fund" or phase=="Build","Unknown phase")
 local h=game:GetService("HttpService");local function scalar(v:any):string return h:JSONEncode(v)end
 local reviewed=h:JSONDecode(reviewedCanonical);V.validate(reviewed,Plan.OWNER,scalar)
 assert(C.encode(reviewed,scalar)==reviewedCanonical and not reviewed.lease,"Canonical released review required")
 local expectedSha=if phase=="Fund" then "d846d13a398113d1442ff1e0a3feeccbf2397fdf286cad88583f635524c75a65"
  else "802d28f694d61242376bd9746f2724a2b85591ab9563199e50d9efed1ef2c548"
 do
  local raw=game:GetService("EncodingService"):ComputeStringHash(reviewedCanonical,Enum.HashAlgorithm.Sha256)
  local sha=(raw:gsub(".",function(c:string):string return string.format("%02x",string.byte(c))end))
  assert(sha==expectedSha,"Exact phase-specific reviewed record required")
 end
 local plan=Plan.create(reviewed,phase,scalar)
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
  assert(#records<65,"Total request ceiling including preflight")
  local start=os.clock();local ok,value=pcall(fn)
  table.insert(records,{kind=kind,ok=ok,ms=(os.clock()-start)*1000,
   readBudget=service:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync),
   writeBudget=service:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.SetIncrementAsync),
   transition=if ok and value and value.lastCommit then value.lastCommit.kind else nil,
   profileRevision=if ok and value then value.profileRevision else nil,
   step=if ok and value and value.country then value.country.simulation.step else nil})
  if not ok then error("Construction proof transport failed; reconcile or stop")end;return value
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
 assert(C.encode(initial,scalar)==reviewedCanonical,"Fresh profile differs from review; stop")
 local initialPlatform=C.copy(latestPlatform)
 if phase=="Build" then
  assert(initialPlatform.version=="08DF44E1F51DCFA5.0000000021.08DF456CA2E2E5D0.01"
   and initialPlatform.createdTime==1794944138060 and initialPlatform.updatedTime==1795003700146
   and next(initialPlatform.metadata)==nil,"Funded platform head differs; stop for renewed approval")
 end
 authenticate()
 local transport={mode="Real",read=read,
  budget=function():boolean return service:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync)>0 and service:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.SetIncrementAsync)>0 end,
  update=function(key:string,transform:(any)->any):any
   assert(preimageRetained,"Protected fresh preimage must be retained before mutation")
   assert(key==Plan.KEY,"Exact approved key only");authenticate()
   return measured("Update",function()return store:UpdateAsync(key,function(current:any,info:any)
    metadata(info)
    local nextValue=transform(current);if not nextValue then return nil end
    return nextValue,info:GetUserIds(),info:GetMetadata()
   end)end)
  end}
 local adapter=Plan.guard(transport,plan,scalar);approved[adapter]=true
 return {adapter=table.freeze(adapter),plan=plan,records=function()return C.copy(records)end,
  -- Manual operator calls this only after exporting and hashing the fresh capture.
  confirmPreimageRetained=function(sha256:string)
   assert(sha256==expectedSha,"Exact retained preimage checksum required")
   preimageRetained=true
  end,
  capture=function()return {initial=C.copy(initial),initialPlatform=C.copy(initialPlatform),
   latest=C.copy(latestProfile),latestPlatform=C.copy(latestPlatform),records=C.copy(records)}end}
end

return table.freeze(Adapter)
