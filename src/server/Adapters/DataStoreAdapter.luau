--!strict
-- Owner-approved single-account Studio proof. Never selected by normal bootstrap.
local Adapter={}
local LIVE_ACCESS_APPROVED=true
local Codec=require(script.Parent.Parent.Domain.ProfileCodec)
local Schema=require(script.Parent.Parent.Domain.ProfileSchema)
function Adapter.create(player:Player,expectedCountryId:string?)
 assert(LIVE_ACCESS_APPROVED,"P3a real DataStore access requires separate owner approval")
 local run=game:GetService("RunService")
 assert(run:IsStudio() and run:IsServer() and game.GameId==10776833313,"Test universe only")
 assert(game.CreatorType==Enum.CreatorType.User and game.CreatorId==149564436,"Approved creator only")
 assert(typeof(player)=="Instance" and player:IsA("Player") and player.Parent==game:GetService("Players") and player.UserId==149564436,"Approved authenticated Player required")
 local service=game:GetService("DataStoreService")
 local store=service:GetDataStore("PowerStateProfilesP3aTest")
 local http=game:GetService("HttpService")
 local function scalar(v:any):string return http:JSONEncode(v)end
 local records={};local calls=0
 local function measured(kind:string,call:()->any):any
  local began=os.clock();local ok,value=pcall(call);calls+=1
  if #records==64 then table.remove(records,1)end
  table.insert(records,{kind=kind,ms=(os.clock()-began)*1000,ok=ok,
   readBudget=service:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync),
   writeBudget=service:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.SetIncrementAsync)})
  if not ok then error(value)end;return value
 end
 local function ownerOf(key:string):number
  assert(key=="u:149564436","Only the approved exact key is authorized")
  return 149564436
 end
 local function read(key:string):any
  ownerOf(key);local options=Instance.new("DataStoreGetOptions");options.UseCache=false
  local ok,value=pcall(function()return measured("Read",function()return store:GetAsync(key,options)end)end)
  options:Destroy();if not ok then error(value)end;return value
 end
 -- Read-only preflight must succeed before the first update. Existing profiles require
 -- the exact country identity recorded by this proof; never infer permission to reset.
 local initial=read("u:149564436")
 if initial~=nil then
  Schema.validate(initial,149564436,scalar)
  assert(expectedCountryId and initial.country.recipe.countryId==expectedCountryId,"Unexpected existing country; stop")
 else assert(expectedCountryId==nil,"Expected saved country missing; stop")end
 local baseline=if initial then Codec.encode(initial,scalar) else "nil"
 local first=true;local firstOperation:string?=nil
 return {
  mode="Real",
  preflight=Codec.copy(initial),
  stats=function():any return {calls=calls,records=Codec.copy(records)}end,
  budget=function():boolean
   return service:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync)>0
    and service:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.SetIncrementAsync)>0
  end,
  read=read,
  update=function(key:string,transform:(any)->any):any
   local owner=ownerOf(key)
   local result=measured("Update",function()return store:UpdateAsync(key,function(value:any,info:any)
    if first then
     local duplicate=value and firstOperation and value.lastCommit and value.lastCommit.operationId==firstOperation
     assert(duplicate or (if value then Codec.encode(value,scalar) else "nil")==baseline,"Profile changed since preflight; stop")
    end
    local updated=transform(value);if updated==nil then return nil end
    Schema.validate(updated,owner,scalar) -- This authorization is v1 only; never write economic migrations.
    if first then firstOperation=updated.lastCommit.operationId end
    local users=if info then info:GetUserIds() else {owner}
    if not table.find(users,owner) then table.insert(users,owner)end
    return updated,users,if info then info:GetMetadata() else {}
   end)end)
   if result~=nil then first=false end
   return result
  end,
 }
end
return table.freeze(Adapter)
