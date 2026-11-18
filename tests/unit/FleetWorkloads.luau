--!strict
local F={}
local function node(id:string,kind:string,cap:number):any return {id=id,kind=kind,capacityKW=cap}end
local function line(id:string,a:string,b:string,cap:number):any return {id=id,from=a,to=b,capacityKW=cap,connected=true}end
local function source(id:string,cap:number,cost:number):any return {id=id,nodeId=id,availableKW=cap,costMinorPerMWh=cost}end
local function sink(id:string,kw:number):any return {id=id,nodeId=id,requestedKW=kw}end
function F.small():any return {version=1,nodes={node("gas","Generator",5000),node("wind","Generator",2000),node("peak","Generator",2000),node("sub","Substation",10000),node("a","Demand",10000),node("b","Demand",10000)},
 lines={line("gs","gas","sub",5000),line("ws","wind","sub",2000),line("ps","peak","sub",2000),line("sa","sub","a",10000),line("sb","sub","b",10000)},
 sources={source("gas",5000,8000),source("wind",200,0),source("peak",0,11000)},sinks={sink("a",4000),sink("b",2000)}}end
function F.maximum():any
 local n:any={version=1,nodes={},lines={},sources={},sinks={}}
 for i=1,4 do local id="g"..i;table.insert(n.nodes,node(id,"Generator",25000));table.insert(n.sources,source(id,20000,i*1000))end
 for i=1,8 do local id="d"..i;table.insert(n.nodes,node(id,"Demand",12500));table.insert(n.sinks,sink(id,12500))end
 for i=1,20 do table.insert(n.nodes,node("j"..i,"Substation",100000))end
 for i=1,4 do table.insert(n.lines,line("gline"..i,"g"..i,"j1",25000))end
 for i=1,19 do table.insert(n.lines,line("trunk"..i,"j"..i,"j"..(i+1),if i==10 then 60000 else 100000))end
 for i=1,8 do table.insert(n.lines,line("dline"..i,"j20","d"..i,12500))end
 for i=1,17 do table.insert(n.lines,line("parallel"..i,"j"..i,"j"..(i+1),1000))end
 return n
end
function F.islands():any
 local n=F.maximum()
 for _,l in n.lines do if l.id=="trunk10" or l.id=="parallel10"then l.connected=false end end
 n.lines[1].to="j20";n.lines[2].to="j20"
 n.sinks[8].nodeId="j8";n.nodes[20].kind="Demand" -- j8, detached demand on the other powered island
 n.nodes[12].kind="Junction"
 return n
end
function F.adversarial():any
 local adversarial=F.maximum()
 for i,s in adversarial.sinks do s.requestedKW=2500+i*1100 end
 for _,l in adversarial.lines do
  local d=tonumber(string.match(l.id,"^dline(%d)$"))
  if d then l.capacityKW=if d%2==0 then 3000+d*97 else 12000 end
  -- Reverse physical endpoint orientation without changing capacities.
  if string.match(l.id,"^parallel")then l.from,l.to=l.to,l.from end
 end
 return adversarial
end
function F.independent():any
 local n=F.maximum()
 for _,l in n.lines do local i=tonumber(string.match(l.id,"^dline(%d)$"));if i then l.capacityKW=1000+i*500 end end
 return n
end
function F.equalCost():any local n=F.maximum();for _,v in n.sources do v.costMinorPerMWh=1000 end;return n end
function F.intermediate():any
 local n=F.maximum()
 for i=8,5,-1 do table.remove(n.sinks,i);table.remove(n.nodes,4+i)end
 for i=#n.lines,1,-1 do if string.match(n.lines[i].id,"^dline[5-8]$")then table.remove(n.lines,i)end end
 return n
end
return table.freeze(F)
