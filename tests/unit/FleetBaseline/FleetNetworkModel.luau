--!strict
-- Operations v1 uses integer kW and bounded, explicitly typed transport records.
local Model={VERSION=1,MAX_OPERATIONS=2000000}
local function integer(v:any,lo:number,hi:number)
 assert(type(v)=="number" and v==v and v%1==0 and v>=lo and v<=hi,"Invalid bounded integer")
end
local function fields(t:any,list:string)
 assert(type(t)=="table","Record required")
 local allowed={};for k in list:gmatch("%S+")do allowed[k]=true;assert(t[k]~=nil,"Missing "..k)end
 for k in t do assert(allowed[k],"Unsupported field")end
end
local function array(t:any,lo:number,hi:number)
 assert(type(t)=="table" and #t>=lo and #t<=hi,"Array bound")
 local count=0;for k in t do integer(k,1,#t);count+=1 end;assert(count==#t,"Sparse array")
end
local function id(v:any)assert(type(v)=="string" and #v>0 and #v<=64,"Invalid ID")end
function Model.validate(n:any)
 fields(n,"version nodes lines sources sinks");assert(n.version==1,"Unsupported fleet version")
 array(n.nodes,1,32);array(n.lines,0,48);array(n.sources,1,4);array(n.sinks,1,8)
 local nodes={};local ids={};local terminals={}
 for _,v in n.nodes do
  fields(v,"id kind capacityKW");id(v.id);assert(not ids[v.id],"Duplicate ID");ids[v.id]=true;nodes[v.id]=v
  assert(table.find({"Generator","Substation","Demand","Junction"},v.kind),"Unsupported node role");integer(v.capacityKW,0,100000)
 end
 for _,v in n.lines do
  fields(v,"id from to capacityKW connected");id(v.id);assert(not ids[v.id],"Duplicate ID");ids[v.id]=true
  assert(nodes[v.from] and nodes[v.to] and v.from~=v.to,"Invalid endpoints");integer(v.capacityKW,0,100000);assert(type(v.connected)=="boolean","Invalid switch")
 end
 local supply,demand=0,0
 for _,v in n.sources do
  fields(v,"id nodeId availableKW costMinorPerMWh");id(v.id);assert(not terminals[v.id] and nodes[v.nodeId] and nodes[v.nodeId].kind=="Generator","Invalid source")
  assert(not terminals[v.nodeId..":terminal"],"Duplicate terminal");terminals[v.id]=true;terminals[v.nodeId..":terminal"]=true
  integer(v.availableKW,0,nodes[v.nodeId].capacityKW);integer(v.costMinorPerMWh,0,1000000);supply+=v.availableKW
 end
 for _,v in n.sinks do
  fields(v,"id nodeId requestedKW");id(v.id);assert(not terminals[v.id] and nodes[v.nodeId] and nodes[v.nodeId].kind=="Demand","Invalid sink")
  assert(not terminals[v.nodeId..":terminal"],"Duplicate terminal");terminals[v.id]=true;terminals[v.nodeId..":terminal"]=true
  integer(v.requestedKW,0,100000);demand+=v.requestedKW
 end
 assert(supply<=100000 and demand<=100000,"Aggregate power bound")
end
Model.integer=integer
return table.freeze(Model)
