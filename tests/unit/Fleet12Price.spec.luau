--!strict
return function(f:any)
 local D=game.ServerScriptService.Server.Domain;local H=game:GetService("HttpService")
 local C=require(D.ProfileCodec);local V=require(D.ProfileSchema4);local W=require(D.WindProject)
 local scalar=function(v:any):string return H:JSONEncode(v)end
 local legacy=C.encode(f.built,scalar)
 local old=require(script.Parent["FleetTransactions.spec"])(f,1)
 local trial=require(script.Parent["FleetTransactions.spec"])(f,2)
 assert(old.country.fleet.windReceipt.priceMinor==400000 and old.country.bank.windConstructionSpentMinor==400000)
 assert(trial.country.fleet.windReceipt.priceMinor==200000 and trial.country.bank.windConstructionSpentMinor==200000)
 assert(C.encode(f.built,scalar)==legacy,"No repricing of caller or frozen legacy profile")
 V.validate(f.built,149564436,scalar);V.validate(trial,149564436,scalar)
 for _,p in {old,trial}do
  local bad=C.copy(p);bad.country.fleet.windReceipt.definitionVersion=3
  assert(not pcall(V.validate,bad,149564436,scalar),"Unknown price version")
  bad=C.copy(p);bad.country.fleet.windReceipt.definitionVersion=if p.country.fleet.windReceipt.definitionVersion==1 then 2 else 1
  assert(not pcall(V.validate,bad,149564436,scalar),"Cannot reinterpret historical capital")
  assert(not pcall(W.build,p.country,H:GenerateGUID(false),99999,99999,2),"Same entitlement across versions")
 end
 assert(W.PRICE==400000 and W.VERSION==1,"Legacy default preserved")
 print("FLEET12_PRICE_GATE_PASS 170 transaction assertions plus 10 version/history/default checks")
 return trial
end
