--!strict
local Codec=require(script.Parent.ProfileCodec)
local Schema=require(script.Parent.ProfileSchema2)
local Legacy=require(script.Parent.ProfileCountry)
local Economy=require(script.Parent.Economy)
local Country=require(script.Parent.Parent.Simulation.Country)
local Handler=require(script.Parent.Parent.Simulation.IntentHandler)
local Economic={}
function Economic.capture(world:any,state:any):any
 local c=Legacy.capture(world,state);c.bank=Codec.copy(state.bank);c.economy=Codec.copy(state.economy)
 Schema.country(c);return c
end
function Economic.restore(p:any,world:any,epoch:string):any
 Schema.country(p.country)
 local s:any=Legacy.restore(Schema.legacy(p),world,epoch)
 s.countryId=p.country.recipe.countryId
 s.bank=Codec.copy(p.country.bank);s.economy=Codec.copy(p.country.economy);return s
end
function Economic.advance(state:any,demand:number?):any
 assert(not state.suspended,"Suspended countries cannot bill")
 local n=Codec.copy(state)
 if n.online and n.bank.balanceMinor<Economy.reservation(n.economy,5000)then
  n.online=false;n.controlRevision+=1
  n.economy.fundingReason="InsufficientOperatingFunds";n.economy.fundingStep=n.step
 end
 Country.advance(n,demand)
 n.bank,n.economy=Economy.settle(n.bank,n.economy,state.step,n.report,n.online)
 Economy.validate(n.bank,n.economy,n,n.countryId)
 return n
end
function Economic.handle(state:any,actor:number,payload:any,now:number):string
 local prior={online=state.online,report=state.report,revision=state.revision,controlRevision=state.controlRevision}
 local result=Handler.handle(state,actor,payload,now)
 if result=="Accepted" and state.online then
  if state.bank.balanceMinor<Economy.reservation(state.economy,5000)then
   for key,v in prior do state[key]=v end
   return "InsufficientOperatingFunds"
  end
  state.economy.fundingReason=nil;state.economy.fundingStep=nil
 end
 return result
end
return table.freeze(Economic)
