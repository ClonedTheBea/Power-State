--!strict
-- Manual entry only; adapter gate remains closed during P3c.3.
local Adapter=require(script.Parent.Parent.Adapters.Schema3ConstructionAdapter)
local Execution={}
function Execution.run(phase:string,reviewedCanonical:string):any
 -- create() rejects before any service access while the execution gate is closed.
 local prepared=Adapter.create(phase,reviewedCanonical)
 local h=game:GetService("HttpService")
 local result=require(script.Parent.ConstructionProofRunner).run({adapter=prepared.adapter,
  scalar=function(v:any):string return h:JSONEncode(v)end,id=function():string return h:GenerateGUID(false)end,
  utcMs=function():number return DateTime.now().UnixTimestampMillis end,mono=os.clock,wait=task.wait,spawn=task.spawn,
  random=math.random,placeId=game.PlaceId,present=function():boolean
   return game:GetService("RunService"):IsStudio() and not game:GetService("RunService"):IsRunning()
    and game.GameId==10776833313 and game:GetService("StudioService"):GetUserId()==149564436
  end},prepared.plan)
 result.records=prepared.records();return result
end
return table.freeze(Execution)
