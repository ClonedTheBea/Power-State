--!strict
-- Reuse the existing intent/security contract; install physics only after the
-- complete two-sink report succeeds. Control never settles energy or money.
local Codec=require(script.Parent.Parent.Domain.ProfileCodec)
local Intent=require(script.Parent.Parent.Simulation.IntentHandler)
local Solver=require(script.Parent.Parent.Simulation.DistrictSolver)
local Country=require(script.Parent.Parent.Domain.ConstructionCountry)
local Controls={}
function Controls.handle(state:any,world:any,actor:number,payload:any,now:number,canMutate:boolean):(any,string)
 -- Cheap admission precedes the history clone/physics work. The retained gate
 -- consumes admitted requests and remains the authority for shape and ordering.
 if actor~=state.owner then return state,"Unauthorized" end
 if math.min(4,state.tokens+math.max(0,now-state.rateAt)*2)<1 then return state,"RateLimited" end
 local candidate=Codec.copy(state)
 candidate.suspended=not canMutate
 local outcome=Intent.handle(candidate,actor,payload,now)
 candidate.suspended=false
 if outcome=="Accepted" then
  candidate.report=Solver.solve(Country.capture(world,candidate),candidate.network.demandMW,candidate.online)
 end
 return candidate,outcome
end
return table.freeze(Controls)
