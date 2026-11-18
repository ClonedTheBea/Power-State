--!strict
-- P3b.5 bounded proof completed. Both execution gates are closed after verification.
local Adapter={}
local REAL_ECONOMY_EXECUTION_APPROVED=false
local BOUNDED_P3B5_EXECUTION_APPROVED=false
local Policy=require(script.Parent.Parent.Domain.ExistingEconomyStore)
local Codec=require(script.Parent.Parent.Domain.ProfileCodec)
local approved:any = setmetatable({}, {__mode="k"})
function Adapter.isApproved(value:any):boolean return approved[value]==true end
function Adapter.create(player:Player):any
 assert(REAL_ECONOMY_EXECUTION_APPROVED,"P3b.4 preparation only; real execution requires separate approval")
 error("Ordinary real economy startup remains disabled")
end
function Adapter.createBounded(player:Player,phase:number,previousSHA:string?):any
 assert(BOUNDED_P3B5_EXECUTION_APPROVED,"P3b.5 bounded execution gate is closed")
 assert(phase==1 or phase==2,"Unknown bounded phase")
 if phase==2 then assert(type(previousSHA)=="string" and #previousSHA==64 and previousSHA:match("^[a-f0-9]+$"),"Verified prior release checksum required")end
 local run=game:GetService("RunService")
 assert(run:IsStudio() and run:IsServer() and game.GameId==10776833313,"Test universe only")
 assert(game.CreatorType==Enum.CreatorType.User and game.CreatorId==149564436,"Approved creator only")
 local function authenticate()
  assert(typeof(player)=="Instance" and player:IsA("Player") and player.Parent==game:GetService("Players") and player.UserId==149564436,"Approved authenticated Player required")
 end
 authenticate()
 local service=game:GetService("DataStoreService")
 local store=service:GetDataStore("PowerStateProfilesP3aTest") -- Default/global scope only.
 local http=game:GetService("HttpService")
 local records={};local calls=0
 local function measured(kind:string,call:()->any):any
  local began=os.clock();local ok,value=pcall(call);calls+=1
  if #records==64 then table.remove(records,1)end
  table.insert(records,{kind=kind,ms=(os.clock()-began)*1000,ok=ok,
   readBudget=service:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync),
   writeBudget=service:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.SetIncrementAsync)})
  print("[P3b5 request] "..http:JSONEncode(records[#records]))
  if not ok then error(value)end;return value
 end
 local transport={
  mode="Real",
  stats=function():any return {calls=calls,records=Codec.copy(records)}end,
  budget=function():boolean return service:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync)>0 and service:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.SetIncrementAsync)>0 end,
  read=function(key:string):any
   assert(key==Policy.KEY,"Exact key only")
   local options=Instance.new("DataStoreGetOptions");options.UseCache=false
   local ok,value=pcall(function()return measured("Read",function()return store:GetAsync(key,options)end)end)
   options:Destroy();if not ok then error(value)end;return value
  end,
  update=function(key:string,transform:(any)->any):any
   assert(key==Policy.KEY,"Exact key only")
   return measured("Update",function()return store:UpdateAsync(key,function(value:any,info:any)
    assert(info~=nil,"Existing profile metadata required")
    local nextValue=transform(value);if nextValue==nil then return nil end
    return nextValue,info:GetUserIds(),info:GetMetadata()
   end)end)
  end,
 }
 local scalar=function(v:any):string return http:JSONEncode(v)end
 local adapter=Policy.create(transport,scalar,function():number return DateTime.now().UnixTimestampMillis end)
 authenticate() -- A disconnect during preflight cannot start gameplay.
 local initial=adapter.preflight
 print("[P3b5 preflight] "..http:JSONEncode({phase=phase,universe=game.GameId,creator=game.CreatorId,player=player.UserId,schema=initial.schemaVersion,profileRevision=initial.profileRevision,countryRevision=initial.countryRevision,epoch=initial.sessionEpoch,leaseAbsent=initial.lease==nil,bank=initial.country.bank.balanceMinor,step=initial.country.simulation.step,online=initial.country.simulation.online}))
 local e=initial.country.economy
 print("[P3b5 preflight finance] "..http:JSONEncode({activation=e.activationStep,cursor=e.lastSettledStep,carry={e.baseSalesRemainder,e.bonusSalesRemainder,e.variableExpenseRemainder,e.fixedExpenseRemainder},sales=e.baseSalesMinor,variable=e.variableExpenseMinor,fixed=e.fixedExpenseMinor,grant=initial.country.bank.openingGrantMinor}))
 assert(initial.country.recipe.seed=="1441a4d819354af7b306ef8797931e15" and initial.country.settlement.name=="Rowanbridge","Unexpected saved identity/seed; stop")
 if phase==2 then
  local raw=game:GetService("EncodingService"):ComputeStringHash(Codec.encode(initial,scalar),Enum.HashAlgorithm.Sha256)
  local sha=(string.gsub(raw,".",function(c:string):string return string.format("%02x",string.byte(c))end))
  assert(sha==previousSHA,"Profile changed since verified release; stop")
 end
 local Plan=require(script.Parent.Parent.Domain.BoundedEconomyPlan)
 local plan=Plan.create(initial,phase,scalar)
 adapter=Plan.guard(adapter,plan,scalar)
 approved[adapter]=true
 return {adapter=table.freeze(adapter),plan=plan}
end
return table.freeze(Adapter)
