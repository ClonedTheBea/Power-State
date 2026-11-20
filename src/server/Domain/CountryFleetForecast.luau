--!strict
-- Capacity outlook only, never a dispatch solve or payable electricity interval.
local Wind=require(script.Parent.Parent.Operations.OperationsWind)
local Demand=require(script.Parent.Parent.World.DemandModel)
local Forecast={}
function Forecast.create(s:any):any
 local result={};local gas=s.fleet.units[s.network.generatorId]
 local wind=if s.fleet.windReceipt then s.fleet.units[s.fleet.windReceipt.generatorId]else nil
 for _,offset in {0,15,30,45,60}do
  local town=math.floor(Demand.atStep(s.step+offset,1700,1000).demandMW*1000+.5)
  local demand=town+(if s.construction.receipt then math.floor((town+2)/4)else 0)
  local potential=Wind.potential(s.fleet.windSeed,s.fleet.windRegion,s.step+offset)
  local windAvailable=if wind and wind.on then math.min(wind.capKW,potential)else 0
  local available=(if gas.on then gas.capKW else 0)+windAvailable
  table.insert(result,{offsetMinutes=offset,demandKW=demand,windPotentialKW=potential,windAvailableKW=windAvailable,
   availableKW=available,capacityMarginKW=available-demand})
 end
 return result
end
return table.freeze(Forecast)
