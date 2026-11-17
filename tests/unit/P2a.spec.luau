--!strict
return function()
 local modules=game:GetService("ServerScriptService").Server.Simulation
 local Model=require(modules.NetworkModel);local Solver=require(modules.GridSolver)
 local Country=require(modules.Country);local Handler=require(modules.IntentHandler)
 local count=0
 local function check(ok:boolean,label:string)assert(ok,label);count+=1 end
 local function near(a:number,b:number)check(math.abs(a-b)<1e-8,"Numeric equality")end
 local n=Model.starter();local r=Solver.solve(n,true)
 near(r.availableMW,5);near(r.outputMW,3);near(r.deliveredMW,3);near(r.unmetMW,0);near(r.headroomMW,2)
 check(r.status=="Served","Starter served")
 r=Solver.solve(n,false);near(r.outputMW,0);near(r.unmetMW,3);check(r.status=="Generator offline","Offline status")
 n.nodes[2].capacity=2;r=Solver.solve(n,true);near(r.deliveredMW,2);check(r.status=="Network bottleneck","Substation gate")
 n.nodes[2].capacity=10;n.lines[2].connected=false;r=Solver.solve(n,true);near(r.deliveredMW,0);check(r.status=="Disconnected","Disconnected")
 n.lines[2].connected=true;n.lines[1].capacity=1;r=Solver.solve(n,true);near(r.deliveredMW,1)
 n.lines[1].capacity=10;n.nodes[1].capacity=2;r=Solver.solve(n,true);near(r.deliveredMW,2);check(r.status=="Generation shortfall","Limited source")
 n.nodes[1].capacity=10;n.demandMW=7;n.lines[1].capacity=4;near(Solver.solve(n,true).deliveredMW,4)
 n.demandMW=0;near(Solver.solve(n,true).outputMW,0);near(Solver.solve(n,true).serviceRatio,-1)
 for _,bad in {0/0,math.huge,-1,.0001} do check(not pcall(Model.units,bad),"Invalid power") end
 n=Model.starter();n.lines[1].to="missing";check(not pcall(Solver.solve,n,true),"Unknown endpoint")
 n=Model.starter();n.nodes[2].id="station";check(not pcall(Solver.solve,n,true),"Duplicate node")
 -- A residual reroute is needed after choosing s-a-c-t; parallel/cyclic links share physical ratings.
 local graph:Model.Network={nodes={},lines={},generatorId="s",demandId="t",demandMW=2,population=1000}
 for _,id in {"s","a","b","c","d","t"} do table.insert(graph.nodes,{id=id,name=id,kind="Substation",capacity=2,x=0,y=0}) end
 for i,pair in {{"s","a"},{"s","b"},{"a","c"},{"a","d"},{"b","c"},{"c","t"},{"d","t"}} do
  table.insert(graph.lines,{id=tostring(i),from=pair[1],to=pair[2],capacity=1,connected=true})
 end
 r=Solver.solve(graph,true);near(r.deliveredMW,2)
 for _,flow in r.flows do check(math.abs(flow)<=1,"Shared rating") end
 table.insert(graph.lines,{id="parallel",from="s",to="a",capacity=1,connected=true})
 near(Solver.solve(graph,true).deliveredMW,2)
 table.sort(graph.nodes,function(a,b)return a.id>b.id end);table.sort(graph.lines,function(a,b)return a.id>b.id end)
 near(Solver.solve(graph,true).deliveredMW,2)
 local a,b=Country.new(1,"epoch"),Country.new(1,"epoch")
 for i=1,180 do
  if i==61 then a.online=false;b.online=false elseif i==121 then a.online=true;b.online=true end
  Country.advance(a);Country.advance(b)
  near(a.deliveredMWh,b.deliveredMWh);near(a.requestedMWh,b.requestedMWh)
 end
 near(a.deliveredMWh,6);near(a.requestedMWh,9);near(Country.snapshot(a).reliability,2/3)
 local window=Country.new(1,"e")
 for i=1,1500 do window.online=i>60;Country.advance(window) end
 check(#window.history==1440,"Bounded reliability ring");near(Country.snapshot(window).reliability,1)
 check(Country.snapshot(Country.new(1,"e")).reliability==-1,"No invented history")
 local state=Country.new(1,"e");local now=0
 local function request(online:boolean):any return {version=1,kind="SetGenerator",epoch="e",sequence=state.lastSequence+1,revision=state.controlRevision,assetId="station",online=online} end
 local function send(payload:any,actor:number?):string now+=1;return Handler.handle(state,actor or 1,payload,now) end
 local command=request(false)
 check(send(command)=="Accepted","Off accepted");near(state.report.deliveredMW,0);near(state.deliveredMWh,0)
 check(send(command)=="Duplicate","Repeated ID");check(state.controlRevision==1,"No double mutation")
 check(send(request(false))=="NoChange","Invalid same-state transition")
 check(send(request(true))=="Accepted","Restore");near(state.report.deliveredMW,3)
 Country.advance(state);near(state.deliveredMWh,.05)
 check(send(request(false),2)=="Unauthorized","Other player")
 local malformedPayloads:{any}={false,123,"bad",{}, {version=1,kind="Sync",extra=1},{version=1,kind="Sync",bad={}}}
 for _,payload in malformedPayloads do check(send(payload)=="Malformed","Malformed intent") end
 local bad=request(false);bad.online=5;check(send(bad)=="Malformed","Numeric dispatch forbidden")
 bad=request(false);bad.outputMW=99;check(send(bad)=="Malformed","Unexpected authoritative value")
 bad=request(false);bad.epoch="other";check(send(bad)=="StaleSession","Epoch")
 bad=request(false);bad.assetId="capital";check(send(bad)=="UnauthorizedAsset","Non-generator target")
 bad=request(false);bad.sequence+=1;check(send(bad)=="OutOfOrder","Sequence gap")
 bad=request(false);bad.sequence=0/0;check(send(bad)=="Malformed","Nonfinite sequence")
 bad=request(false);bad.revision=0;check(send(bad)=="StaleRevision","Stale control revision")
 check(send({version=1,kind="Sync"})=="Synced","Resync")
 state.suspended=true;check(send(request(false))=="Suspended","Suspended country")
 state.suspended=false;state.tokens=4;state.rateAt=now
 for _=1,4 do check(Handler.handle(state,1,{version=1,kind="Sync"},now)=="Synced","Burst bound") end
 check(Handler.handle(state,1,request(false),now)=="RateLimited","Rate limited")
 local other=Country.new(2,"other");check(other.online and other.step==0,"Separate country state")
 local start=os.clock();for _=1,1000 do Solver.solve(Model.starter(),true) end
 print(string.format("[Power State P2a unit] PASS: %d assertions; 1000 starter solves %.2f ms",count,(os.clock()-start)*1000))
 return count
end
