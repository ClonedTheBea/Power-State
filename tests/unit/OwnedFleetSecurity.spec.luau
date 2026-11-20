--!strict
return function(fixtures:any)
 local S=game.ServerScriptService.Server;local Country=require(S.Domain.FleetCountry)
 local Controls=require(S.Services.FleetControls);local C=require(S.Domain.ProfileCodec)
 local state=Country.restore(fixtures.built,fixtures.world,"fleet-security-epoch")
 local checks=0;local function check(v:boolean,m:string)assert(v,m);checks+=1 end
 local function command():any return {version=1,kind="SetFleetGenerator",epoch=state.epoch,sequence=1,
  revision=state.controlRevision,assetId=state.fleet.windReceipt.generatorId,online=false,capKW=2000}end
 local malformed:{any}={false,{},string.rep("x",1024),-1,math.huge,0/0}
 for _,field in {"version","kind","epoch","sequence","revision","assetId","online","capKW","bankMinor","owner"}do
  for _,value in malformed do
   local p=command();p[field]=value
   -- false is an intentionally valid requested On/Off value.
   if not(field=="online"and value==false)then
    local result,outcome=Controls.handle(state,fixtures.world,state.owner,p,100000,true)
    check(result==state and outcome~="Accepted","Malformed field cannot change state: "..field)
   end
  end
 end
 local p=command();local rejected,outcome=Controls.handle(state,fixtures.world,state.owner+1,p,100000,true)
 check(rejected==state and outcome=="Unauthorized","Authenticated owner required")
 local changed,accepted=Controls.handle(state,fixtures.world,state.owner,p,100000,true)
 check(accepted=="Accepted"and not changed.fleet.windState.on,"Valid owned control")
 local replay,why=Controls.handle(changed,fixtures.world,state.owner,p,100000,true)
 check(replay==changed and why=="Rejected","Command replay rejected")
 local sampled=state
 for i=1,5 do
  p=command();p.sequence=i;p.online=true
  sampled,why=Controls.handle(sampled,fixtures.world,state.owner,p,100000,true)
  check(why==(if i<=4 then "NoChange"else "RateLimited"),"Bounded admission bucket")
 end
 local H=game:GetService("HttpService");local scalar=function(v:any):string return H:JSONEncode(v)end
 check(C.encode(Country.capture(fixtures.world,sampled),scalar)==C.encode(Country.capture(fixtures.world,state),scalar),"No-op traffic never advances money/energy")
 p=command();local suspended,reason=Controls.handle(state,fixtures.world,state.owner,p,100000,false)
 check(reason=="Suspended"and suspended.step==state.step and suspended.fleet.windState.on==state.fleet.windState.on,"Critical save prevents control")
 print("[Owned fleet security] PASS",checks)
 return checks
end
