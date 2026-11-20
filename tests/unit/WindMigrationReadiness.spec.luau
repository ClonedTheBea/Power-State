--!strict
-- Design-gate reproduction only. No schema4, persistence adapter or mutation path.
return function()
 local S=game.ServerScriptService.Server
 local Codec=require(S.Domain.ProfileCodec)
 local Schema=require(S.Domain.ProfileSchema3)
 local Migration=require(S.Domain.ProfileMigrations3)
 local Country=require(S.Domain.ConstructionCountry)
 local Demand=require(S.World.DemandModel)
 local fixture=require(script.Parent.P3b4Fixture)()
 local scalar=function(v:any):string return game.HttpService:JSONEncode(v)end
 local p=Migration.read(fixture.profile,149564436,scalar)
 Schema.validate(p,149564436,scalar)
 local original=Codec.encode(p,scalar)
 local baseline={legacyEconomy=Codec.copy(p.country.economy),legacyBank=Codec.copy(p.country.bank),
  legacyConstruction=Codec.copy(p.country.construction),migrationOperationId="preview-only"}
 local state=Country.restore(p,fixture.world,game.HttpService:GenerateGUID(false))
 state=Country.advance(state,fixture.world,Demand.atStep(state.step,1700,1000).demandMW)
 local current=Country.capture(fixture.world,state)
 local projected=Codec.copy(current)
 projected.bank=Codec.copy(baseline.legacyBank);projected.economy=Codec.copy(baseline.legacyEconomy)
 projected.construction=Codec.copy(baseline.legacyConstruction)
 local ok,why=pcall(function()Schema.country(projected,scalar);return true end)
 assert(not ok and string.find(tostring(why),"Settlement cursor",1,true),"Reproduce cutover/current simulation mismatch")
 -- Proposed extra baseline field, tested locally only; not added to any schema.
 projected.simulation=Codec.copy(p.country.simulation)
 Schema.country(projected,scalar)
 assert(Codec.encode(projected,scalar)==Codec.encode(p.country,scalar),"Exact cutover projection with proposed simulation copy")
 assert(Codec.encode(p,scalar)==original,"Fixture preserved")
 for i=1,1440 do
  state=Country.advance(state,fixture.world,Demand.atStep(state.step,1700,1000).demandMW)
  if i%50==0 then task.wait()end
 end
 local full=Country.capture(fixture.world,state)
 Schema.country(full,scalar)
 print("WIND_SCHEMA_GATE",game.HttpService:JSONEncode({cutoverStep=p.country.simulation.step,
  nextStep=current.simulation.step,rejection=tostring(why),profileBytes=#original,
  baselineBytes=#Codec.encode(baseline,scalar),proposedSimulationBytes=#Codec.encode(p.country.simulation,scalar),
  fullRingSimulationBytes=#Codec.encode(full.simulation,scalar),fullRingCountryBytes=#Codec.encode(full,scalar),
  fullRingEntries=#full.simulation.history,
  result="Approval required: baseline simulation absent from W5 exact fields"}))
end
