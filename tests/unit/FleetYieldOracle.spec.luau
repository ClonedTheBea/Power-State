--!strict
return function()
 local S=game.ServerScriptService.Server;local Sync=require(script.Parent.FleetStage1C.FleetSolver)
 local Solver=require(S.Operations.FleetSolver);local Codec=require(S.Domain.ProfileCodec);local H=game:GetService("HttpService")
 local W=require(script.Parent.FleetWorkloads);local checks=0;local boundaries={}
 local function encode(v:any):string return Codec.encode(v,function(x)return H:JSONEncode(x)end)end
 local function scheduled(n:any,step:number,quantum:number):any
  local co=coroutine.create(function()return Solver.solve(n,step,nil,nil,{quantum=quantum,checkpoint=function(name:string)boundaries[name]=true;coroutine.yield()end})end)
  while true do local ok,result=coroutine.resume(co);assert(ok,result);if coroutine.status(co)=="dead"then return result end end
 end
 local function compare(n:any,step:number)
  local expected=encode(Sync.solve(n,step))
  for _,q in {1,16,128}do assert(encode(scheduled(n,step,q))==expected,"Yield-invariant exact report");checks+=1 end
  local perm=Codec.copy(n)
  for _,key in {"nodes","lines","sources","sinks"}do table.sort(perm[key],function(a,b)return a.id>b.id end)end
  assert(encode(scheduled(perm,step,16))==expected,"Permuted scheduled exact report");checks+=1
 end
 local function node(id:string,kind:string,cap:number):any return {id=id,kind=kind,capacityKW=cap}end
 local function line(id:string,a:string,b:string,cap:number):any return {id=id,from=a,to=b,capacityKW=cap,connected=true}end
 local cases=0
 for mask=0,80 do
  local caps={};local m=mask;for i=1,4 do caps[i]=m%3;m=math.floor(m/3)end
  for supply=1,3 do for a=1,3 do for b=1,3 do
   local n={version=1,nodes={node("x","Generator",supply),node("y","Generator",supply),node("a","Demand",a),node("b","Demand",b)},
    lines={line("xa","x","a",caps[1]),line("xb","x","b",caps[2]),line("ya","y","a",caps[3]),line("yb","y","b",caps[4])},
    sources={{id="x",nodeId="x",availableKW=supply,costMinorPerMWh=1},{id="y",nodeId="y",availableKW=supply,costMinorPerMWh=3}},
    sinks={{id="a",nodeId="a",requestedKW=a},{id="b",nodeId="b",requestedKW=b}}}
   compare(n,cases);cases+=1
  end end end
  if mask%3==0 then task.wait()end
 end
 for _,name in {"small","intermediate","maximum","adversarial","independent","islands","equalCost"}do
  for step=0,7 do compare(W[name](),step);task.wait()end
 end
 local dark=W.islands();dark.sources[3].availableKW=0;dark.sources[4].availableKW=0
 for step=0,7 do compare(dark,step);task.wait()end
 local changing=W.maximum()
 for step=1,24 do
  changing.sources[1].availableKW=(step*7919)%25001
  changing.sources[2].costMinorPerMWh=if step%2==0 then 1000 else 9000
  changing.sinks[step%8+1].requestedKW=step*431
  changing.lines[step%#changing.lines+1].connected=step%3~=0
  compare(changing,step);task.wait()
 end
 print("[Fleet 1D yield equivalence] "..H:JSONEncode({oracleCases=cases,checks=checks,quantums={1,16,128},boundaries=boundaries}))
end
