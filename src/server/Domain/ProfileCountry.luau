--!strict
local Codec=require(script.Parent.ProfileCodec)
local Schema=require(script.Parent.ProfileSchema)
local Country=require(script.Parent.Parent.Simulation.Country)
local Demand=require(script.Parent.Parent.World.DemandModel)
local Starter=require(script.Parent.Parent.World.StarterValidator)
local Solver=require(script.Parent.Parent.Simulation.GridSolver)
local ProfileCountry={}
function ProfileCountry.capture(world:any,state:any):any
 local n=Starter.network(world.layout)
 local simulation={simulationVersion=1}
 for _,key in {"step","online","requestedMWh","deliveredMWh","history","historyIndex","windowRequested","windowDelivered"}do simulation[key]=Codec.copy(state[key])end
 local result={recipe={countryId=world.countryId,seed=world.seed,generationVersion=1,climateVersion=1,demandVersion=1,startTemplateVersion=1,namePoolVersion=1,networkVersion=1,candidate=world.candidate,fallback=world.fallback},
  settlement={id=n.demandId,nameId=world.layout.nameId,name=world.layout.name,population=1000,demandBusId=n.demandId,x16=n.nodes[3].x*16,y16=n.nodes[3].y*16,sectorX=0,sectorY=0},
  network=n,ownedSectors={{x=0,y=0}},simulation=simulation,
  bank={currency="Credits",minorUnitsPerCredit=100,balanceMinor=0,earnedMinor=0,spentMinor=0,ledgerVersion=1},
  deltas={builtNodes={},builtLines={},generatedOverrides={},tombstones={},constructionOrders={},nextBuiltAssetSerial=1}}
 Schema.country(result);return result
end
function ProfileCountry.restore(p:any,world:any,commandEpoch:string):any
 Schema.country(p.country)
 local c=p.country;local r=c.recipe
 assert(world.countryId==r.countryId and world.seed==r.seed and world.candidate==r.candidate and world.fallback==r.fallback,"Regenerated country mismatch")
 local network=Codec.copy(c.network)
 local d=Demand.atStep(math.max(0,c.simulation.step-1),world.meanTemperatureCentiC,network.population)
 network.demandMW=d.demandMW
 local state=Country.new(p.ownerUserId,commandEpoch,network)
 for key,v in c.simulation do if key~="simulationVersion" then state[key]=Codec.copy(v)end end
 state.revision=p.countryRevision;state.report=Solver.solve(network,state.online)
 return state
end
return table.freeze(ProfileCountry)
