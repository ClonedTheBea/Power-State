--!strict
local C=require(script.Parent.Parent.Domain.ProfileCodec)
local Economy=require(script.Parent.Parent.Domain.FleetEconomy)
local Country=require(script.Parent.Parent.Domain.FleetCountry)
local R=require(script.Parent.Parent.Domain.FleetRecord)
local Controls={}
function Controls.handle(s:any,world:any,owner:number,p:any,now:number,canMutate:boolean):(any,string)
 if owner~=s.owner or type(p)~="table"then return s,"Unauthorized"end
 local count=0
 for key in p do count+=1;if count>8 or not table.find({"version","kind","epoch","sequence","revision","assetId","online","capKW"},key)then return s,"Rejected"end end
 if p.version~=1 or not table.find({"SetGenerator","SetFleetGenerator"},p.kind)then return s,"Rejected"end
 if p.epoch~=s.epoch then return s,"StaleSession"end
 if type(p.sequence)~="number"or p.sequence%1~=0 or p.sequence<=s.lastSequence or p.sequence>1000000000 then return s,"Rejected"end
 if type(p.revision)~="number"or p.revision%1~=0 or p.revision<0 or p.revision>1000000000 then return s,"Rejected"end
 if type(p.assetId)~="string"or #p.assetId>64 or not s.fleet.units[p.assetId]then return s,"Rejected"end
 if type(p.online)~="boolean"then return s,"Rejected"end
 local capacity=if p.assetId==s.network.generatorId then 5000 else 2000
 if p.capKW~=nil and (type(p.capKW)~="number"or p.capKW%100~=0 or p.capKW<0 or p.capKW>capacity)then return s,"Rejected"end
 if not s.fleet.windReceipt and p.capKW~=nil and p.capKW~=5000 then return s,"Rejected"end
 local tokens=math.min(4,s.tokens+math.max(0,now-s.rateAt)*2)
 if tokens<1 then return s,"RateLimited"end
 local n=C.copy(s);n.tokens=tokens-1;n.rateAt=now;n.lastSequence=p.sequence
 if not canMutate then return R.freeze(n),"Suspended"end
 if p.revision~=s.controlRevision then return R.freeze(n),"StaleRevision"end
 local u=n.fleet.units[p.assetId];local cap=p.capKW or u.capKW
 if u.on==p.online and u.capKW==cap then return R.freeze(n),"NoChange"end
 u.on=p.online;u.capKW=cap;n.online=n.fleet.units[n.network.generatorId].on
 if n.fleet.windReceipt then
  local wind=n.fleet.units[n.fleet.windReceipt.generatorId];n.fleet.windState={on=wind.on,capKW=wind.capKW}
 end
 local c=Country.capture(world,R.freeze(C.copy(n)))
 if Economy.reservation(c)>n.bank.balanceMinor then
  -- A valid but unaffordable intent still consumes its bounded admission token.
  -- Retain all gameplay fields; repeated rejection must not bypass rate limits.
  local rejected=table.clone(s);rejected.tokens=n.tokens;rejected.rateAt=now;rejected.lastSequence=p.sequence
  return R.freeze(rejected),"InsufficientOperatingFunds"
 end
 n.economy.fundingReason=nil;n.economy.fundingStep=nil;n.controlRevision+=1;n.revision+=1
 n.dispatchPending=n.fleet.windReceipt~=nil
 if not n.fleet.windReceipt then n.report=require(script.Parent.Parent.Simulation.DistrictSolver).solve(c,n.network.demandMW,n.online)end
 return R.freeze(n),"Accepted"
end
return table.freeze(Controls)
