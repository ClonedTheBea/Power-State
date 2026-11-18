--!strict
-- Manual server Command Bar entry only. Each fresh Play session can attempt one phase.
local Proof={};local attempted=false
function Proof.run(player:Player,phase:number,previousSHA:string?):any
 local run=game:GetService("RunService")
 assert(run:IsStudio() and run:IsServer() and run:IsRunning() and game.GameId==10776833313,"Running Test server only")
 assert(not attempted,"This session already attempted the bounded proof")
 assert(player.Parent==game:GetService("Players") and player.UserId==149564436,"Authenticated approved account only")
 assert(not game.ReplicatedStorage:FindFirstChild("P3bSimulation") and not game.ReplicatedStorage:FindFirstChild("P3aSimulation"),"Ordinary persistence proof must not be running")
 attempted=true
 local H=game:GetService("HttpService");local C=require(script.Parent.Parent.Domain.ProfileCodec)
 local function scalar(v:any):string return H:JSONEncode(v)end
 local prepared=require(script.Parent.Parent.Adapters.Schema2GameplayAdapter).createBounded(player,phase,previousSHA)
 local adapter,plan=prepared.adapter,prepared.plan
 local function record(kind:string,p:any)
  local c=p.country;local e=c.economy;local s=c.simulation
  print("[P3b5 "..kind.."] "..scalar({phase=phase,profileRevision=p.profileRevision,countryRevision=p.countryRevision,epoch=p.sessionEpoch,leaseAbsent=p.lease==nil,step=s.step,online=s.online,bank=c.bank.balanceMinor,sales=e.baseSalesMinor,variable=e.variableExpenseMinor,fixed=e.fixedExpenseMinor,cursor=e.lastSettledStep,activation=e.activationStep,carry={e.baseSalesRemainder,e.variableExpenseRemainder,e.fixedExpenseRemainder},meters={e.deliveredKwMinutes,e.generatedKwMinutes,e.onlineSteps}}))
  print("[P3b5 history] "..scalar({requestedMWh=s.requestedMWh,deliveredMWh=s.deliveredMWh,historyCount=#s.history,historyIndex=s.historyIndex,windowRequested=s.windowRequested,windowDelivered=s.windowDelivered}))
 end
 record("Starting",adapter.preflight)
 local result=require(script.Parent.BoundedEconomyRunner).run({adapter=adapter,scalar=scalar,utcMs=function():number return DateTime.now().UnixTimestampMillis end,
  mono=os.clock,id=function():string return H:GenerateGUID(false)end,spawn=task.spawn,wait=function()task.wait(.05)end,random=math.random,
  jobId=if game.JobId=="" then "StudioP3b5" else game.JobId,placeId=game.PlaceId,present=function():boolean return player.Parent==game.Players end,record=record},plan)
 local canonical=C.encode(result.profile,scalar)
 local raw=game:GetService("EncodingService"):ComputeStringHash(canonical,Enum.HashAlgorithm.Sha256)
 local sha=(string.gsub(raw,".",function(c:string):string return string.format("%02x",string.byte(c))end))
 print("[P3b5 complete] "..scalar({phase=phase,completedIntervals=result.completedIntervals,calls=result.stats.calls,bytes=#canonical,sha256=sha,countryId=result.profile.country.recipe.countryId,seed=result.profile.country.recipe.seed,name=result.profile.country.settlement.name}))
 return {sha256=sha,phase=phase,completedIntervals=result.completedIntervals}
end
return table.freeze(Proof)
