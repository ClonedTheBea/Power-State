--!strict
local Codec=require(script.Parent.ProfileCodec)
local Starter=require(script.Parent.Parent.World.StarterValidator)
local Schema={SOFT_BYTES=196608,HARD_BYTES=262144,MAX_INTEGER=9007199254740991}
function Schema.integer(v:any,minimum:number,maximum:number)
 assert(type(v)=="number" and v==v and v%1==0 and v>=minimum and v<=maximum,"Invalid profile integer")
end
local function fields(t:any,names:string,optional:string?)
 assert(type(t)=="table","Expected profile record")
 local allowed={};for name in string.gmatch(names,"%S+")do allowed[name]=true;assert(t[name]~=nil,"Missing "..name)end
 for name in string.gmatch(optional or "","%S+")do allowed[name]=true end
 for key in t do assert(allowed[key],"Unknown profile field "..tostring(key))end
end
local function text(v:any,limit:number)
 assert(type(v)=="string" and #v>0 and #v<=limit and utf8.len(v)~=nil,"Invalid profile text")
end
local function guid(v:any)
 text(v,36);assert(#v==36 and string.match(v,"^[%x]+%-[%x]+%-[%x]+%-[%x]+%-[%x]+$")~=nil,"Invalid GUID")
end
local function array(t:any,size:number)
 assert(type(t)=="table" and #t==size,"Profile array size")
 local count=0;for k in t do Schema.integer(k,1,size);count+=1 end;assert(count==size,"Sparse array")
end
local function energy(v:any)
 assert(type(v)=="number" and v==v and v>=0 and v<math.huge,"Invalid energy")
end
local function near(a:number,b:number):boolean return math.abs(a-b)<=1e-6+1e-9*math.max(math.abs(a),math.abs(b))end
function Schema.country(c:any)
 fields(c,"recipe settlement network ownedSectors simulation bank deltas")
 local r=c.recipe
 fields(r,"countryId seed generationVersion climateVersion demandVersion startTemplateVersion namePoolVersion networkVersion candidate fallback")
 guid(r.countryId);text(r.seed,32);assert(#r.seed==32 and string.match(r.seed,"^[0-9a-f]+$"),"Invalid seed")
 for _,key in {"generationVersion","climateVersion","demandVersion","startTemplateVersion","namePoolVersion","networkVersion"}do assert(r[key]==1,"Unsupported "..key)end
 Schema.integer(r.candidate,0,8);assert(r.fallback==(r.candidate==8),"Fallback mismatch")
 local layout=Starter.layout(r.seed,r.countryId,r.candidate)
 local expected=Starter.network(layout)
 local settlement=c.settlement
 fields(settlement,"id nameId name population demandBusId x16 y16 sectorX sectorY")
 assert(settlement.id==expected.demandId and settlement.demandBusId==expected.demandId,"Settlement identity")
 assert(settlement.nameId==layout.nameId and settlement.name==layout.name,"Pinned settlement name")
 assert(settlement.population==1000 and settlement.x16==expected.nodes[3].x*16 and settlement.y16==expected.nodes[3].y*16,"Settlement anchors")
 assert(settlement.sectorX==0 and settlement.sectorY==0,"Settlement sector")
 local n=c.network;fields(n,"generatorId demandId demandMW population nodes lines")
 assert(n.generatorId==expected.generatorId and n.demandId==expected.demandId and n.demandMW==3 and n.population==1000,"Starter contract")
 array(n.nodes,3);array(n.lines,2)
 for i,node in n.nodes do
  fields(node,"id kind name capacity x y")
  for key,v in expected.nodes[i] do assert(node[key]==v,"Pinned node "..tostring(key))end
 end
 for i,line in n.lines do
  fields(line,"id from to capacity connected")
  for key,v in expected.lines[i]do assert(line[key]==v,"Pinned line "..tostring(key))end
 end
 array(c.ownedSectors,1);fields(c.ownedSectors[1],"x y");assert(c.ownedSectors[1].x==0 and c.ownedSectors[1].y==0,"Owned sector")
 local b=c.bank;fields(b,"currency minorUnitsPerCredit balanceMinor earnedMinor spentMinor ledgerVersion")
 assert(b.currency=="Credits" and b.minorUnitsPerCredit==100 and b.ledgerVersion==1,"Bank schema")
 assert(b.balanceMinor==0 and b.earnedMinor==0 and b.spentMinor==0,"Nonzero P3a Bank")
 local d=c.deltas;fields(d,"builtNodes builtLines generatedOverrides tombstones constructionOrders nextBuiltAssetSerial")
 for _,key in {"builtNodes","builtLines","generatedOverrides","tombstones","constructionOrders"}do array(d[key],0)end
 assert(d.nextBuiltAssetSerial==1,"No construction in P3a")
 local s=c.simulation;fields(s,"simulationVersion step online requestedMWh deliveredMWh history historyIndex windowRequested windowDelivered")
 assert(s.simulationVersion==1 and type(s.online)=="boolean","Simulation version/state")
 Schema.integer(s.step,0,1000000000);array(s.history,math.min(s.step,1440)) -- Existing DemandModel input ceiling.
 local expectedIndex=if s.step==0 then 0 else (s.step-1)%1440+1
 assert(s.historyIndex==expectedIndex,"History cursor")
 local requested=0;local delivered=0
 for _,pair in s.history do
  fields(pair,"requested delivered");energy(pair.requested);energy(pair.delivered)
  assert(pair.delivered<=pair.requested+1e-6,"History conservation")
  assert(pair.requested<=10/60+1e-6 and pair.delivered<=5/60+1e-6,"History exceeds pinned demand/generation bounds")
  requested+=pair.requested;delivered+=pair.delivered
 end
 for _,key in {"requestedMWh","deliveredMWh","windowRequested","windowDelivered"}do energy(s[key])end
 assert(near(requested,s.windowRequested) and near(delivered,s.windowDelivered),"History aggregate mismatch")
 assert(s.deliveredMWh<=s.requestedMWh+1e-6 and s.windowRequested<=s.requestedMWh+1e-6 and s.windowDelivered<=s.deliveredMWh+1e-6,"Energy conservation")
 assert(s.requestedMWh<=s.step*10/60+1e-6 and s.deliveredMWh<=s.step*5/60+1e-6,"Cumulative energy exceeds completed time")
 if s.step<=1440 then assert(near(s.requestedMWh,s.windowRequested) and near(s.deliveredMWh,s.windowDelivered),"Initial history totals")end
end
function Schema.validate(p:any,owner:number,scalar:(any)->string):(number,boolean)
 local encoded=Codec.encode(p,scalar) -- Bound traversal before semantic work.
 fields(p,"schemaVersion ownerUserId createdAtUtc lastSavedAtUtc profileRevision countryRevision sessionEpoch country lastCommit","lease")
 assert(p.schemaVersion==1,"Unsupported profile schema")
 Schema.integer(owner,-Schema.MAX_INTEGER,Schema.MAX_INTEGER);assert(owner~=0 and p.ownerUserId==owner,"Profile owner mismatch")
 for _,key in {"createdAtUtc","lastSavedAtUtc","profileRevision","countryRevision","sessionEpoch"}do Schema.integer(p[key],0,Schema.MAX_INTEGER)end
 assert(p.profileRevision>=1 and p.sessionEpoch>=1 and p.lastSavedAtUtc>=p.createdAtUtc,"Envelope counters")
 Schema.country(p.country);assert(p.countryRevision>=p.country.simulation.step,"Country revision")
 if p.lease then
  fields(p.lease,"ownerSessionId jobId placeId fence expiresAtUtcMs")
  guid(p.lease.ownerSessionId);text(p.lease.jobId,64);Schema.integer(p.lease.placeId,0,Schema.MAX_INTEGER)
  assert(p.lease.fence==p.sessionEpoch,"Lease fence")
  Schema.integer(p.lease.expiresAtUtcMs,1,Schema.MAX_INTEGER)
 end
 local receipt=p.lastCommit;fields(receipt,"operationId kind fence baseProfileRevision committedProfileRevision countryRevision")
 guid(receipt.operationId)
 assert(table.find({"Acquire","Checkpoint","Renew","Release"},receipt.kind),"Commit kind")
 for _,key in {"fence","baseProfileRevision","committedProfileRevision","countryRevision"}do Schema.integer(receipt[key],0,Schema.MAX_INTEGER)end
 assert(receipt.committedProfileRevision==p.profileRevision and receipt.baseProfileRevision+1==p.profileRevision and receipt.countryRevision==p.countryRevision and receipt.fence==p.sessionEpoch,"Commit revision")
 return #encoded,#encoded>Schema.SOFT_BYTES
end
return table.freeze(Schema)
