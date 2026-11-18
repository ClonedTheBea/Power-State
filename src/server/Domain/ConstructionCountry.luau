--!strict
local Codec=require(script.Parent.ProfileCodec)
local Schema=require(script.Parent.ProfileSchema3)
local Legacy=require(script.Parent.EconomicCountry)
local Economy=require(script.Parent.Economy)
local Solver=require(script.Parent.Parent.Simulation.DistrictSolver)
local Construction={}
function Construction.capture(world:any,state:any):any
 local projected=Codec.copy(state)
 projected.bank.ledgerVersion=2;projected.bank.constructionSpentMinor=nil
 projected.bank.balanceMinor+=state.bank.constructionSpentMinor;projected.bank.spentMinor-=state.bank.constructionSpentMinor
 local c=Legacy.capture(world,projected)
 c.bank=Codec.copy(state.bank);c.deltas=Codec.copy(state.deltas);c.construction=Codec.copy(state.construction)
 Schema.country(c);return c
end
function Construction.restore(profile:any,world:any,epoch:string):any
 Schema.country(profile.country)
 local s=Legacy.restore(Schema.previous(profile),world,epoch)
 s.bank=Codec.copy(profile.country.bank);s.construction=Codec.copy(profile.country.construction);s.deltas=Codec.copy(profile.country.deltas)
 s.report=Solver.solve(profile.country,s.network.demandMW,s.online)
 return s
end
function Construction.advance(state:any,world:any,demandMW:number):any
 assert(not state.suspended,"Construction/save suspension")
 local n=Codec.copy(state)
 if n.online and n.bank.balanceMinor<Economy.reservation(n.economy,5000)then
  n.online=false;n.controlRevision+=1;n.economy.fundingReason="InsufficientOperatingFunds";n.economy.fundingStep=n.step
 end
 -- Physics consumes the pinned base and cosmetic-independent built flag. Avoid
 -- encoding/validating a full history-ring checkpoint just to solve one step.
 local country={recipe={seed=world.seed,countryId=world.countryId,candidate=world.candidate},
  network=world.network,settlement={name=world.layout.name},construction=n.construction}
 local report=Solver.solve(country,demandMW,n.online)
 local requested,delivered=report.demandMW/60,report.deliveredMW/60
 local index=n.historyIndex%1440+1;local old=n.history[index]
 n.windowRequested+=requested-(if old then old.requested else 0)
 n.windowDelivered+=delivered-(if old then old.delivered else 0)
 n.history[index]={requested=requested,delivered=delivered};n.historyIndex=index
 n.requestedMWh+=requested;n.deliveredMWh+=delivered;n.step+=1;n.revision+=1;n.report=report;n.network.demandMW=demandMW
 -- Reuse exact v2 billing, then retain the separately validated capital debit.
 local capital=n.bank.constructionSpentMinor
 local projected=Codec.copy(n.bank)
 projected.ledgerVersion=2;projected.constructionSpentMinor=nil
 projected.balanceMinor+=capital;projected.spentMinor-=capital
 n.bank,n.economy=Economy.settle(projected,n.economy,state.step,report,n.online)
 Economy.validate(n.bank,n.economy,n,n.countryId)
 n.bank.ledgerVersion=3;n.bank.constructionSpentMinor=capital;n.bank.spentMinor+=capital;n.bank.balanceMinor-=capital
 Schema.integer(n.bank.balanceMinor,0,Economy.CAP);Schema.integer(n.bank.spentMinor,0,Economy.CAP)
 return n
end
return table.freeze(Construction)
