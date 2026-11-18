--!strict
return function()
 local S=game.ServerScriptService.Server
 local fixture=require(script.Parent["P3b4Fixture"])()
 local Codec=require(S.Domain.ProfileCodec);local Country=require(S.Domain.ConstructionCountry)
 local Migration=require(S.Domain.ProfileMigrations3);local Controls=require(S.Services.ConstructionControls)
 local Demand=require(S.World.DemandModel);local Project=require(S.Domain.ConstructionProject)
 local H=game:GetService("HttpService");local function scalar(v:any):string return H:JSONEncode(v)end
 local p=Migration.read(fixture.profile,149564436,scalar)
 local s=Country.restore(p,fixture.world,"controls-session")
 local checks=0;local function check(v:boolean,why:string)assert(v,why);checks+=1 end
 local function payload(state:any,online:boolean):any
  return {version=1,kind="SetGenerator",epoch=state.epoch,sequence=state.lastSequence+1,revision=state.controlRevision,assetId=state.network.generatorId,online=online}
 end
 for _,built in {false,true}do
  if built then
   for _=1,150 do s=Country.advance(s,fixture.world,Demand.atStep(s.step,1700,1000).demandMW)end
   p.country=Project.build(Country.capture(fixture.world,s),H:GenerateGUID(false),s.revision+1,p.profileRevision+1)
   p.countryRevision=s.revision+1;p.lastCommit.countryRevision=p.countryRevision
   s=Country.restore(p,fixture.world,"built-controls")
  end
  local before=Codec.encode(Country.capture(fixture.world,s),scalar)
  for _,case in {"owner","epoch","asset","extra","nan","suspended","revision"}do
   local req=payload(s,false);local owner=s.owner
   if case=="owner"then owner+=1 elseif case=="epoch"then req.epoch="old"elseif case=="asset"then req.assetId="other"
   elseif case=="extra"then req.bank=1e9 elseif case=="nan"then req.sequence=0/0 elseif case=="revision"then req.revision+=1 end
   local n,outcome=Controls.handle(s,fixture.world,owner,req,100,case~="suspended")
   check(outcome~="Accepted" and n.online==s.online,"Reject "..case)
   check(Codec.encode(Country.capture(fixture.world,s),scalar)==before,"Input remains immutable")
  end
  local n,outcome=Controls.handle(s,fixture.world,s.owner,payload(s,false),100,true)
  check(outcome=="Accepted" and not n.online and n.report.deliveredMW==0,"Off changes actual delivery")
  check(#n.report.sinks==(if built then 2 else 1),"Correct sink report after control")
  check(n.step==s.step and n.bank.balanceMinor==s.bank.balanceMinor,"Control neither bills nor advances time")
  check(n.report.sinks[1].unmetMW>0 and (not built or n.report.sinks[2].unmetMW>0),"Off preserves all unmet demand")
  local repeated,why=Controls.handle(n,fixture.world,s.owner,payload(s,false),101,true)
  check(why=="Duplicate" and repeated.controlRevision==n.controlRevision,"Replay rejected")
  local restored,on=Controls.handle(n,fixture.world,s.owner,payload(n,true),102,true)
  check(on=="Accepted" and restored.report.unmetMW<1e-9,"On restores all customers")
  check(restored.bank.balanceMinor==s.bank.balanceMinor and restored.step==s.step,"On no bonus interval")
  s=restored
 end
 print(string.format("[First Playable controls] PASS: %d assertions",checks))
end
