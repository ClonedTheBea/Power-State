--!strict
-- Expanded Stage 1B differential cases and repeated, uncached CPU measurements.
return function(useStage1B:boolean?)
 assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Test only")
 local S=game.ServerScriptService.Server
 local Solver:any=if useStage1B then require(script.Parent.FleetStage1B.FleetSolver)else require(S.Operations.FleetSolver);local Old=require(script.Parent.FleetStage1B.FleetSolver)
 local W=require(script.Parent.FleetWorkloads);local Codec=require(S.Domain.ProfileCodec);local H=game:GetService("HttpService")
 local count=0
 local function check(v:boolean,m:string)assert(v,m);count+=1 end
 local function canonical(v:any):string return Codec.encode(v,function(x)return H:JSONEncode(x)end)end
 local function compare(n:any,step:number)
  local before=canonical(n);local a=Solver.solve(n,step);local b=Old.solve(n,step)
  check(a.deliveredKW==b.deliveredKW and a.costNumerator==b.costNumerator,"Baseline total/cost")
  check(canonical(a.sources)==canonical(b.sources),"Stable source dispatch including equal costs")
  for id,v in a.sinks do check(v.deliveredKW==b.sinks[id].deliveredKW,"Baseline sink "..id)end
  local p=Codec.copy(n)
  for _,key in {"nodes","lines","sources","sinks"}do table.sort(p[key],function(x,y)return x.id>y.id end)end
  check(canonical(a)==canonical(Solver.solve(p,step)),"Full report permutation")
  check(canonical(a)==canonical(Solver.solve(n,step)),"Full report replay")
  check(before==canonical(n),"Input purity")
 end
 local intermediate=W.maximum()
 -- Same long shared corridor; remove four customer buses and their routes only.
 for i=8,5,-1 do table.remove(intermediate.sinks,i);table.remove(intermediate.nodes,4+i)end
 for i=#intermediate.lines,1,-1 do local l=intermediate.lines[i];if string.match(l.id,"^dline[5-8]$")then table.remove(intermediate.lines,i)end end
 local equal=W.maximum();for _,s in equal.sources do s.costMinorPerMWh=1000 end
 local adversarial=W.adversarial()
 local islands=W.islands();local result=Solver.solve(islands,0)
 check(result.sinks.d8.deliveredKW==12500,"Independent left island fully served")
 local right=0;for i=1,7 do local kw=result.sinks["d"..i].deliveredKW;check(kw==5714 or kw==5715,"Right island fair remainder");right+=kw end
 check(right==40000 and result.deliveredKW==52500,"Independent island supplies conserved")
 local dark=Codec.copy(islands);dark.sources[3].availableKW=0;dark.sources[4].availableKW=0
 check(Solver.solve(dark,0).sinks.d8.deliveredKW==0,"Unpowered island unmet")
 local independent=W.independent();local independentResult=Solver.solve(independent,0)
 for i=1,8 do check(independentResult.sinks["d"..i].deliveredKW==1000+i*500,"Independent exact branch cap")end
 check(independentResult.deliveredKW==26000,"Independent eight-sink total")
 for _,n in {W.maximum(),intermediate,equal,adversarial,islands,dark,independent}do
  for step=0,7 do compare(n,step);task.wait()end
 end
 -- Mutation sequence exercises invalidation: no cross-call compiled or dispatch cache.
 local changing=W.maximum()
 for step=1,24 do
  changing.sources[1].availableKW=(step*7919)%25001
  changing.sources[2].costMinorPerMWh=if step%2==0 then 1000 else 9000
  changing.sinks[step%8+1].requestedKW=step*431
  changing.lines[step%#changing.lines+1].connected=step%3~=0
  compare(changing,step);task.wait()
 end
 local n=W.maximum();local before=canonical(n)
 for _,limit in {1,500,2000,4000,6000}do
  check(not pcall(Solver.solve,n,0,limit),"Atomic exhaustion at "..limit)
  check(canonical(n)==before,"No partial input mutation on exhaustion")
 end
 print(string.format("[Fleet 1B correctness] PASS: %d expanded assertions",count))
 local failures={}
 for round=1,3 do
  for _,case in {{"small",W.small()},{"intermediate",intermediate},{"maximum",W.maximum()},{"adversarial",adversarial},{"islands",islands},{"equalCost",equal},{"independent",independent}}do
   local name=case[1];local graph=case[2];local samples={};local batches={};local ops=0;local heap=gcinfo()
   for i=1,40 do
    local at=os.clock();local r=Solver.solve(graph,i);table.insert(samples,(os.clock()-at)*1000);ops=math.max(ops,r.operations)
    if i%8==0 then task.wait()end
   end
   for i=1,10 do
    local at=os.clock();for j=1,8 do Solver.solve(graph,i*8+j)end;table.insert(batches,(os.clock()-at)*1000);task.wait()
   end
   table.sort(samples);table.sort(batches)
   print("[Fleet 1B benchmark] "..H:JSONEncode({implementation=if useStage1B then "Stage1B"else "Stage1C",round=round,workload=name,samples=40,batches=10,p50=samples[20],p95=samples[38],max=samples[40],batchP50=batches[5],batchP95=batches[10],batchMax=batches[10],operations=ops,heapDeltaKiB=gcinfo()-heap}))
   if name=="small" and samples[38]>2 then table.insert(failures,"small p95")end
   if samples[40]>10 then table.insert(failures,name.." individual >10ms")end
   if name~="small" and name~="intermediate" and batches[10]>16 then table.insert(failures,name.." eight maximum-bound >16ms")end
  end
 end
 assert(#failures==0,"Fleet performance gate: "..table.concat(failures,", "))
 print("[Fleet 1B acceptance] PASS: three rounds, seven workloads, unchanged gates")
end
