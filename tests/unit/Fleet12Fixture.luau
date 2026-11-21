--!strict
-- Brand-new empty-history country using the original grant/migrations, no invented funds.
return function(world:any):any
 local D=game.ServerScriptService.Server.Domain;local H=game:GetService("HttpService")
 local id=function():string return H:GenerateGUID(false)end
 local scalar=function(v:any):string return H:JSONEncode(v)end
 local state=require(D.Parent.Simulation.Country).new(149564436,id(),world.network)
 local country=require(D.ProfileCountry).capture(world,state)
 local function op(kind:string,p:any?):any
  return {id=id(),kind=kind,owner=149564436,sessionId=if p and p.lease then p.lease.ownerSessionId else id(),
   jobId="Fleet12EmptyFake",placeId=1,candidate=country,fence=if p then p.sessionEpoch else nil,
   baseRevision=if p then p.profileRevision else nil}
 end
 local L1=require(D.ProfileLease);local L2=require(D.ProfileLease2)
 local p=L1.apply(nil,op("Acquire"),1000000,scalar);p=L1.apply(p,op("Release",p),1000001,scalar)
 p=L2.apply(p,op("Acquire",p),1000002,scalar);p=L2.apply(p,op("Release",p),1000003,scalar)
 p=require(D.ProfileMigrations3).read(p,149564436,scalar)
 return require(D.ProfileMigrations4).read(p,149564436,id(),scalar)
end
