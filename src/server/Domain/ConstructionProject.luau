--!strict
local Starter=require(script.Parent.Parent.World.StarterValidator)
local Climate=require(script.Parent.Parent.World.ClimateModel)
local Field=require(script.Parent.Parent.World.IntegerField)
local Codec=require(script.Parent.ProfileCodec)
local Project={ID="district-feeder-v1",PRICE=100000,BUFFER=25000,VERSION=1}
function Project.layout(country:any):any
 local r=country.recipe
 return Starter.layout(r.seed,r.countryId,r.candidate)
end
function Project.assets(country:any):(any,any)
 local layout=Project.layout(country)
 local x,y=Starter.rotate(704,704,layout.rotation)
 local prefix=country.recipe.countryId..":b:"
 return {id=prefix.."1",kind="Settlement",name=country.settlement.name.." district",capacity=1,x=x,y=y},
  {id=prefix.."2",from=country.network.demandId,to=prefix.."1",capacity=1,connected=true}
end
function Project.validateSite(country:any)
 local layout=Project.layout(country)
 local climate=Climate.create(country.recipe.seed)
 local function probe(x:number,y:number)
  x,y=Starter.rotate(x,y,layout.rotation)
  assert(x>=0 and x<1024 and y>=0 and y<1024,"Project outside owned sector")
  local raw=climate.sample(x,y)
  local elevation=Field.lerp(raw.elevationM,40,Starter.weight(layout,x,y))
  assert(elevation==40,"Reserved project terrain changed")
 end
 for y=512,704,32 do probe(704,y)end
 for _,dx in {-48,0,48}do for _,dy in {-48,0,48}do probe(704+dx,704+dy)end end
end
function Project.empty():any
 return {constructionVersion=1,constructionDemandVersion=1,compositionVersion=2,topologyRevision=0}
end
function Project.build(country:any,operationId:string,countryRevision:number,profileRevision:number):any
 assert(not country.construction.receipt,"AlreadyBuilt")
 assert(country.bank.balanceMinor>=Project.PRICE+Project.BUFFER,"InsufficientCredits")
 Project.validateSite(country)
 local n=Codec.copy(country);local node,line=Project.assets(n)
 n.bank.balanceMinor-=Project.PRICE;n.bank.spentMinor+=Project.PRICE;n.bank.constructionSpentMinor=Project.PRICE
 n.deltas.builtNodes={node};n.deltas.builtLines={line};n.deltas.nextBuiltAssetSerial=3
 n.construction.topologyRevision=1
 n.construction.receipt={projectId=Project.ID,definitionVersion=1,operationId=operationId,priceMinor=Project.PRICE,
  terminalId=node.id,lineId=line.id,step=n.simulation.step,beforeBankMinor=country.bank.balanceMinor,
  afterBankMinor=n.bank.balanceMinor,countryRevision=countryRevision,profileRevision=profileRevision}
 return n
end
return table.freeze(Project)
