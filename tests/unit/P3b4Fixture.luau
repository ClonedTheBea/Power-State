--!strict
-- Synthetic already-migrated country; not a copy of the private Rowanbridge profile.
return function():any
 local S=game.ServerScriptService.Server
 local H=game:GetService("HttpService")
 local L1=require(S.Domain.ProfileLease);local L2=require(S.Domain.ProfileLease2)
 local PC=require(S.Domain.ProfileCountry);local Country=require(S.Simulation.Country)
 local Demand=require(S.World.DemandModel)
 local world=require(S.World.WorldGenerator).create("df307a52185f423288df5749229f0808",require(S.Domain.ExistingEconomyStore).COUNTRY_ID,1)
 local function id():string return H:GenerateGUID(false)end
 local function scalar(v:any):string return H:JSONEncode(v)end
 local state=Country.new(149564436,id(),world.network)
 local function op(kind:string,p:any?):any
  return {id=id(),kind=kind,owner=149564436,sessionId=if p and p.lease then p.lease.ownerSessionId else id(),jobId="P3b4Fake",placeId=1,
   candidate=PC.capture(world,state),fence=if p then p.sessionEpoch else nil,baseRevision=if p then p.profileRevision else nil}
 end
 local p=L1.apply(nil,op("Acquire"),1000000,scalar)
 for _=1,113 do Country.advance(state,Demand.atStep(state.step,world.meanTemperatureCentiC,1000).demandMW)end
 local save=op("Checkpoint",p);save.snapshot=PC.capture(world,state);save.countryRevision=state.revision
 p=L1.apply(p,save,1000010,scalar);p=L1.apply(p,op("Release",p),1000020,scalar)
 p=L2.apply(p,op("Acquire"),1000030,scalar);p=L2.apply(p,op("Release",p),1000040,scalar)
 return {world=world,profile=p}
end
