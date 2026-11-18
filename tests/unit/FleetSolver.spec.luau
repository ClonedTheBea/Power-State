--!strict
return function()
 local S=game.ServerScriptService.Server
 local Baseline=require(script.Parent.FleetBaseline.FleetSolver)
 local Solver=require(S.Operations.FleetSolver);local Codec=require(S.Domain.ProfileCodec);local H=game:GetService("HttpService")
 local checks=0
 local function check(v:boolean,m:string)assert(v,m);checks+=1 end
 local function node(id:string,kind:string,cap:number):any return {id=id,kind=kind,capacityKW=cap}end
 local function line(id:string,a:string,b:string,cap:number):any return {id=id,from=a,to=b,capacityKW=cap,connected=true}end
 local function source(id:string,cap:number,cost:number):any return {id=id,nodeId=id,availableKW=cap,costMinorPerMWh=cost}end
 local function sink(id:string,kw:number):any return {id=id,nodeId=id,requestedKW=kw}end
 local function fixture():any return {version=1,nodes={node("gas","Generator",5000),node("wind","Generator",2000),node("peak","Generator",2000),node("sub","Substation",10000),node("a","Demand",10000),node("b","Demand",10000)},
 lines={line("gs","gas","sub",5000),line("ws","wind","sub",2000),line("ps","peak","sub",2000),line("sa","sub","a",10000),line("sb","sub","b",10000)},
 sources={source("gas",5000,8000),source("wind",200,0),source("peak",0,11000)},sinks={sink("a",4000),sink("b",2000)}}end
 local n=fixture();local r=Solver.solve(n,0)
 check(r.deliveredKW==5200 and r.unmetKW==800,"Scarce fleet conservation")
 check(math.abs(r.sinks.a.deliveredKW/4000-r.sinks.b.deliveredKW/2000)<=.0015,"Proportional shortage")
 check(r.sources.wind==200 and r.sources.gas==5000,"Economic sources")
 n.sources[3].availableKW=2000;r=Solver.solve(n,0)
 check(r.deliveredKW==6000 and r.sources.peak==800,"Peaker intervention")
 check(r.costNumerator==48800000,"Actual variable cost numerator")
 n.lines[5].capacityKW=500;r=Solver.solve(n,0)
 check(r.sinks.b.deliveredKW==500 and r.sinks.a.deliveredKW==4000,"Freeze branch without starving other bus")
 n.lines[5].connected=false;r=Solver.solve(n,0)
 check(r.sinks.b.deliveredKW==0 and r.sinks.a.deliveredKW==4000,"Disconnected bus cannot suppress other island")
 n=fixture();n.nodes[4].capacityKW=3000;r=Solver.solve(n,0)
 check(r.deliveredKW==3000 and r.throughputKW.sub==3000,"Shared substation gate")
 check(r.sources.wind==200 and r.sources.gas==2800,"Congestion minimizes cost after delivery")
 -- Cross-connected residual rerouting: cheap source must be freed for its unique sink.
 n={version=1,nodes={node("x","Generator",2),node("y","Generator",2),node("a","Demand",2),node("b","Demand",2)},
 lines={line("xa","x","a",2),line("xb","x","b",2),line("ya","y","a",2)},sources={source("x",2,1),source("y",2,3)},sinks={sink("a",2),sink("b",2)}}
 r=Solver.solve(n,0);check(r.deliveredKW==4 and r.costNumerator==8,"Residual source/path reallocation")
 -- Independent exhaustive signed physical-flow oracle, including transit through
 -- generator/customer terminals and each node throughput gate.
 local cases=0
 for mask=0,80 do
  local caps={};local m=mask;for i=1,4 do caps[i]=m%3;m=math.floor(m/3)end
  for supply=1,3 do for demandA=1,3 do for demandB=1,3 do
   local q={version=1,nodes={node("x","Generator",supply),node("y","Generator",supply),node("a","Demand",demandA),node("b","Demand",demandB)},
    lines={line("xa","x","a",caps[1]),line("xb","x","b",caps[2]),line("ya","y","a",caps[3]),line("yb","y","b",caps[4])},
    sources={source("x",supply,1),source("y",supply,3)},sinks={sink("a",demandA),sink("b",demandB)}}
   local actual=Solver.solve(q,cases);local previous=Baseline.solve(q,cases)
   check(actual.sinks.a.deliveredKW==previous.sinks.a.deliveredKW and actual.sinks.b.deliveredKW==previous.sinks.b.deliveredKW and actual.costNumerator==previous.costNumerator,"Reference allocation/cost case "..cases)
   local bestTotal=0;local bestCost=math.huge;local bestMin=0
   for xa=-caps[1],caps[1]do for xb=-caps[2],caps[2]do for ya=-caps[3],caps[3]do for yb=-caps[4],caps[4]do
    local a,b,x,y=xa+ya,xb+yb,xa+xb,ya+yb
    if a>=0 and b>=0 and x>=0 and y>=0 and a<=demandA and b<=demandB and x<=supply and y<=supply
     and math.max(xa,0)+math.max(xb,0)<=supply and math.max(ya,0)+math.max(yb,0)<=supply
     and math.max(xa,0)+math.max(ya,0)<=demandA and math.max(xb,0)+math.max(yb,0)<=demandB then
     bestTotal=math.max(bestTotal,a+b);bestMin=math.max(bestMin,math.min(a/demandA,b/demandB))
     if a==actual.sinks.a.deliveredKW and b==actual.sinks.b.deliveredKW then bestCost=math.min(bestCost,x+3*y)end
    end
   end end end end
   check(actual.deliveredKW==bestTotal,"Oracle maximum delivery case "..cases)
   check(actual.costNumerator==bestCost,"Oracle minimum cost at fair targets case "..cases)
   check(math.min(actual.sinks.a.deliveredKW/demandA,actual.sinks.b.deliveredKW/demandB)+1/math.min(demandA,demandB)+.001>=bestMin,"Quantized fairness envelope")
   cases+=1
  end end end
  if mask%9==0 then task.wait()end
 end
 print(string.format("[Operations oracle] PASS: %d exhaustive topology/supply/demand cases",cases))
 -- Large-unit proportional reference avoids a trivial 1-kW tolerance on tiny graphs.
 for supply=0,9000,137 do
  n=fixture();n.sources[1].availableKW=math.min(5000,supply);n.sources[2].availableKW=math.min(2000,math.max(0,supply-5000));n.sources[3].availableKW=math.min(2000,math.max(0,supply-7000))
  r=Solver.solve(n,supply);local f=math.min(1,supply/6000)
  check(math.abs(r.sinks.a.deliveredKW-4000*f)<=5 and math.abs(r.sinks.b.deliveredKW-2000*f)<=3,"Large proportional reference")
 end
 n=fixture();n.sources[1].availableKW=1;n.sources[2].availableKW=0;n.sinks={sink("a",1),sink("b",1)}
 check(Solver.solve(n,0).sinks.a.deliveredKW==1 and Solver.solve(n,1).sinks.b.deliveredKW==1,"One-kW tie rotates with step")
 local function canonical(v:any):string return Codec.encode(v,function(x)return H:JSONEncode(x)end)end
 n=fixture();local before=canonical(n);r=Solver.solve(n,42)
 local perm=Codec.copy(n)
 for _,key in {"nodes","lines","sources","sinks"}do table.sort(perm[key],function(a,b)return a.id>b.id end)end
 check(canonical(r)==canonical(Solver.solve(perm,42)),"Reordered inputs deterministic")
 check(before==canonical(n),"Pure solve leaves input unchanged")
 for _,mutate in {
  function(q:any)q.version=2 end,function(q:any)q.sources[1].availableKW=0/0 end,function(q:any)q.sources[1].availableKW=math.huge end,
  function(q:any)q.sinks[1].requestedKW=.5 end,function(q:any)q.nodes[1].kind="Storage"end,function(q:any)q.lines[1].to="missing"end,
  function(q:any)q.lines[1].connected="true"end,function(q:any)table.insert(q.nodes,q.nodes[1])end,function(q:any)q.secret=true end,
  function(q:any)q.sources[1].costMinorPerMWh=-1 end,function(q:any)q.sources[1].availableKW=5001 end,
  function(q:any)q.sinks[1].requestedKW=100000;q.sinks[2].requestedKW=100000 end
 }do local bad=Codec.copy(n);mutate(bad);check(not pcall(Solver.solve,bad,0),"Reject malformed input")end
 check(not pcall(Solver.solve,n,0,1),"Operation exhaustion rejects entire solve")
 check(before==canonical(n),"Rejected solve cannot mutate input")
 -- Legacy APIs remain independent and retain their full suites outside this test.
 local old=require(S.Simulation.NetworkModel).starter();local expected=require(S.Simulation.GridSolver).solve(old,true)
 local converted={version=1,nodes={},lines={},sources={source("station",5000,8000)},sinks={sink("capital",3000)}}
 for _,v in old.nodes do table.insert(converted.nodes,node(v.id,if v.kind=="Settlement"then "Demand"else v.kind,v.capacity*1000))end
 for _,v in old.lines do table.insert(converted.lines,line(v.id,v.from,v.to,v.capacity*1000))end
 check(Solver.solve(converted,0).deliveredKW==expected.deliveredMW*1000,"Legacy single-sink agreement")
 local samples={};local maxOps=0;local maxMs=0
 for i=1,300 do
  n=fixture();n.sources[3].availableKW=if i%2==0 then 2000 else 0
  local start=os.clock();r=Solver.solve(n,i);local ms=(os.clock()-start)*1000
  table.insert(samples,ms);maxOps=math.max(maxOps,r.operations);maxMs=math.max(maxMs,ms)
  if i%30==0 then task.wait()end
 end
 table.sort(samples);local p95=samples[math.ceil(#samples*.95)]
 local start=os.clock();for i=1,8 do Solver.solve(fixture(),i)end;local batch=(os.clock()-start)*1000
 print(string.format("[Operations performance] p95 %.4fms; max %.4fms; eight-country %.4fms; max operations %d; checks %d",p95,maxMs,batch,maxOps,checks))
 check(p95<=2,"Required p95 <=2ms gate")
 check(batch<=16,"Required eight-country <=16ms gate")
 -- Maximum-size coupled graph: 4 sources, 8 sinks, 32 nodes, 48 links.
 local large:any={version=1,nodes={},lines={},sources={},sinks={}}
 for i=1,4 do local id="g"..i;table.insert(large.nodes,node(id,"Generator",25000));table.insert(large.sources,source(id,20000,i*1000))end
 for i=1,8 do local id="d"..i;table.insert(large.nodes,node(id,"Demand",12500));table.insert(large.sinks,sink(id,12500))end
 for i=1,20 do table.insert(large.nodes,node("j"..i,"Substation",100000))end
 for i=1,4 do table.insert(large.lines,line("gline"..i,"g"..i,"j1",25000))end
 for i=1,19 do table.insert(large.lines,line("trunk"..i,"j"..i,"j"..(i+1),if i==10 then 60000 else 100000))end
 for i=1,8 do table.insert(large.lines,line("dline"..i,"j20","d"..i,12500))end
 for i=1,17 do table.insert(large.lines,line("parallel"..i,"j"..i,"j"..(i+1),1000))end
 r=Solver.solve(large,0)
 check(r.deliveredKW==61000,"Maximum topology shared trunk")
 for _,v in r.sinks do check(v.deliveredKW==7625,"Eight-way proportional allocation")end
 local worst={};local worstOps=0;local worstMax=0
 for i=1,40 do local at=os.clock();local report=Solver.solve(large,i);local ms=(os.clock()-at)*1000;table.insert(worst,ms);worstOps=math.max(worstOps,report.operations);worstMax=math.max(worstMax,ms);if i%8==0 then task.wait()end end
 table.sort(worst);start=os.clock();for i=1,8 do Solver.solve(large,i)end;local worstBatch=(os.clock()-start)*1000
 print(string.format("[Operations maximum bounds] p95 %.4fms; max %.4fms; eight-country %.4fms; operations %d",worst[38],worstMax,worstBatch,worstOps))
 check(worstBatch<=16,"Required eight-country bounded-network <=16ms gate")
 print(string.format("[Operations Stage 1] PASS: %d assertions",checks))
end
