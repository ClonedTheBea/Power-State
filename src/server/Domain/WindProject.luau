--!strict
-- W1-W4 fixed surveyed investment. No placement, seed or price comes from a client.
local Starter=require(script.Parent.Parent.World.StarterValidator)
local Climate=require(script.Parent.Parent.World.ClimateModel)
local Field=require(script.Parent.Parent.World.IntegerField)
local Codec=require(script.Parent.ProfileCodec)
local Project={ID="starter-wind-v1",VERSION=1,PRICE=400000,BUFFER=25000,CAPACITY_KW=2000}
function Project.layout(country:any):any
 local r=country.recipe
 for _,key in {"generationVersion","climateVersion","demandVersion","startTemplateVersion","namePoolVersion","networkVersion"}do
  assert(r[key]==1,"Unsupported saved wind-site version")
 end
 assert(r.fallback==(r.candidate==8),"Saved fallback mismatch")
 return Starter.layout(r.seed,r.countryId,r.candidate)
end
function Project.assets(country:any):(any,any,any)
 local layout=Project.layout(country)
 local x,y=Starter.rotate(320,704,layout.rotation)
 local bx,by=Starter.rotate(320,512,layout.rotation)
 local prefix=country.recipe.countryId..":wind:starter:"
 return {id=prefix.."generator",kind="Generator",name="Starter Wind Farm",capacity=2,x=x,y=y},
  {id=prefix.."feed",from=prefix.."generator",to=country.recipe.countryId..":0,0:substation",capacity=2,connected=true},
  {{x=x,y=y},{x=bx,y=by},{x=512,y=512}}
end
function Project.validateSite(country:any)
 local layout=Project.layout(country)
 assert(#country.ownedSectors==1 and country.ownedSectors[1].x==0 and country.ownedSectors[1].y==0,"Wind site requires owned sector")
 local scalar=function(v:any):string return game:GetService("HttpService"):JSONEncode(v)end
 assert(Codec.encode(country.network,scalar)==Codec.encode(Starter.network(layout),scalar),"Pinned wind-site network")
 local climate=Climate.create(country.recipe.seed)
 local count=0
 local function probe(x:number,y:number)
  x,y=Starter.rotate(x,y,layout.rotation)
  assert(x>=0 and x<1024 and y>=0 and y<1024,"Wind route outside ownership")
  local raw=climate.sample(x,y)
  assert(Field.lerp(raw.elevationM,40,Starter.weight(layout,x,y))==40,"Reserved wind terrain changed")
  count+=1
 end
 for _,dx in {-48,0,48}do for _,dy in {-48,0,48}do probe(320+dx,704+dy)end end
 for y=512,704,32 do probe(320,y)end
 for x=320,512,32 do probe(x,512)end
 local node,_,route=Project.assets(country)
 for _,existing in country.network.nodes do
  assert(math.abs(existing.x-node.x)>=96 or math.abs(existing.y-node.y)>=96,"Wind pad overlaps starter asset")
 end
 -- District occupies the other reserved pad; the authored bend intentionally
 -- shares the gas corridor but does not create a junction at the gas generator.
 local dx,dy=Starter.rotate(704,704,layout.rotation)
 assert(math.abs(dx-node.x)>=96 or math.abs(dy-node.y)>=96,"Wind pad overlaps district")
 local length=0
 for i=1,2 do length+=math.abs(route[i].x-route[i+1].x)+math.abs(route[i].y-route[i+1].y)end
 assert(length==384,"Pinned wind route length")
 return count
end
function Project.price(version:number):number
 assert(version==1 or version==2,"Unsupported wind catalogue revision")
 return if version==1 then 400000 else 200000
end
function Project.build(country:any,operationId:string,countryRevision:number,profileRevision:number,definitionVersion:number?):any
 local version=if definitionVersion==nil then 1 else definitionVersion;local price=Project.price(version)
 assert(country.fleet and country.bank.ledgerVersion==4,"Fleet migration required")
 assert(not country.fleet.windReceipt,"AlreadyBuilt")
 assert(country.construction.receipt,"DistrictRequired")
 require(script.Parent.FleetRecord).guid(operationId)
 Project.validateSite(country)
 local n=Codec.copy(country);local node,line=Project.assets(n)
 n.fleet.units[node.id]={costVersion=1,on=true,capKW=2000,generatedKwMinutes=0,onlineSteps=0,
  variableExpenseMinor=0,fixedExpenseMinor=0,variableExpenseRemainder=0,fixedExpenseRemainder=0}
 local reserve=require(script.Parent.FleetEconomy).reservation(n)
 assert(country.bank.balanceMinor>=price+math.max(Project.BUFFER,reserve),"InsufficientCredits")
 n.bank.balanceMinor-=price;n.bank.spentMinor+=price;n.bank.windConstructionSpentMinor=price
 table.insert(n.deltas.builtNodes,node);table.insert(n.deltas.builtLines,line)
 n.fleet.investmentSerial=1;n.fleet.windState={on=true,capKW=2000}
 n.fleet.windReceipt={projectId=Project.ID,definitionVersion=version,operationId=operationId,priceMinor=price,
  generatorId=node.id,lineId=line.id,step=n.simulation.step,beforeBankMinor=country.bank.balanceMinor,
  afterBankMinor=n.bank.balanceMinor,countryRevision=countryRevision,profileRevision=profileRevision}
 return n
end
function Project.catalog(version:number):any
 local result=table.clone(Project);result.VERSION=version;result.PRICE=Project.price(version)
 result.build=function(c:any,id:string,cr:number,pr:number):any return Project.build(c,id,cr,pr,version)end
 return table.freeze(result)
end
return table.freeze(Project)
