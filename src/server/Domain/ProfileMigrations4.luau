--!strict
-- Pure owner-approved W5 cutover; never opens a store or advances simulation.
local V3=require(script.Parent.ProfileSchema3)
local V4=require(script.Parent.ProfileSchema4)
local Codec=require(script.Parent.ProfileCodec)
local Seed=require(script.Parent.CountryFleetSeed)
local Record=require(script.Parent.FleetRecord)
local Migration={}
function Migration.read(profile:any,owner:number,operationId:string,scalar:(any)->string):any
 if profile.schemaVersion==4 then V4.validate(profile,owner,scalar);return Codec.copy(profile)end
 V3.validate(profile,owner,scalar);Record.guid(operationId)
 local n=Codec.copy(profile);local c=n.country;local e=c.economy
 local baseline={legacyBank=Codec.copy(c.bank),legacyEconomy=Codec.copy(e),legacyConstruction=Codec.copy(c.construction),
  legacySimulation=Codec.copy(c.simulation),migrationOperationId=operationId}
 c.fleet={version=1,compositionVersion=1,cutoverStep=c.simulation.step,windVersion=1,
  windSeed=Seed.fromCountry(c.recipe.seed),windRegion=Seed.REGION,investmentSerial=0,baseline=baseline,
  units={[c.network.generatorId]={costVersion=1,on=c.simulation.online,capKW=5000,
   generatedKwMinutes=e.generatedKwMinutes,onlineSteps=e.onlineSteps,variableExpenseMinor=e.variableExpenseMinor,
   fixedExpenseMinor=e.fixedExpenseMinor,variableExpenseRemainder=e.variableExpenseRemainder,fixedExpenseRemainder=e.fixedExpenseRemainder}}}
 n.schemaVersion=4;c.bank.ledgerVersion=4;c.bank.windConstructionSpentMinor=0;e.economyVersion=2
 V4.validate(n,owner,scalar)
 Record.equal(V4.baselineCountry(c),profile.country,scalar)
 return n
end
return table.freeze(Migration)
