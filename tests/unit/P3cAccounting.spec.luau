--!strict
return function()
 local S=game.ServerScriptService.Server;local H=game:GetService("HttpService")
 local Codec=require(S.Domain.ProfileCodec);local Schema=require(S.Domain.ProfileSchema3)
 local Migration=require(S.Domain.ProfileMigrations3);local Country=require(S.Domain.ConstructionCountry)
 local Project=require(S.Domain.ConstructionProject);local Demand=require(S.World.DemandModel)
 local function id():string return H:GenerateGUID(false)end
 local function scalar(v:any):string return H:JSONEncode(v)end
 local fixture=require(script.Parent["P3b4Fixture"])();local world=fixture.world
 local p=Migration.read(fixture.profile,149564436,scalar);local state=Country.restore(p,world,id())
 for _=1,150 do state=Country.advance(state,world,Demand.atStep(state.step,1700,1000).demandMW)end
 local before=Country.capture(world,state)
 p.country=Project.build(before,id(),state.revision+1,p.profileRevision+1)
 p.countryRevision=state.revision+1;p.profileRevision+=1
 p.lastCommit.countryRevision=p.countryRevision;p.lastCommit.baseProfileRevision=p.profileRevision-1;p.lastCommit.committedProfileRevision=p.profileRevision
 Schema.validate(p,149564436,scalar)
 state=Country.restore(p,world,id());local baseline=Codec.copy(state);local started=os.clock();local maxBytes=0
 for step=1,1440 do
  state=Country.advance(state,world,Demand.atStep(state.step,1700,1000).demandMW)
  if step%120==0 then
   local c=Country.capture(world,state);p.country=c;p.countryRevision=state.revision;p.lastCommit.countryRevision=p.countryRevision
   Schema.validate(p,149564436,scalar)
   local restored=Country.restore(p,world,id())
   assert(Codec.encode(Country.capture(world,restored),scalar)==Codec.encode(c,scalar),"Exact financial/energy restore partition")
   state=restored;maxBytes=math.max(maxBytes,#Codec.encode(p,scalar));task.wait()
  end
 end
 local e=state.economy;local b=baseline.economy
 assert(e.deliveredKwMinutes-b.deliveredKwMinutes==5659536,"Full-day delivered meter")
 assert(e.generatedKwMinutes-b.generatedKwMinutes==5659536 and e.onlineSteps-b.onlineSteps==1440,"Full-day operating meters")
 assert(state.bank.constructionSpentMinor==100000 and state.bank.openingGrantMinor==100000,"One capital debit/one grant")
 assert(state.bank.balanceMinor-baseline.bank.balanceMinor==(e.baseSalesMinor-b.baseSalesMinor)-(e.variableExpenseMinor-b.variableExpenseMinor)-(e.fixedExpenseMinor-b.fixedExpenseMinor),"No duplicate purchase/revenue")
 assert(#state.history==1440 and #e.statements<=25,"Bounded history/statements")
 assert(maxBytes<=262144,"Full profile size")
 local suspended=Codec.copy(state);suspended.suspended=true
 assert(not pcall(Country.advance,suspended,world,3.12),"Suspension forbids billing")
 print(string.format("[P3c accounting] PASS: 1440 billed intervals / 12 exact restores; net %d minor; full-ring profile %d bytes; elapsed %.3fs",state.bank.balanceMinor-baseline.bank.balanceMinor,maxBytes,os.clock()-started))
end
