--!strict
local Field=require(script.Parent.IntegerField)
local Starter={}
Starter.NAMES=table.freeze({"Alderwick","Brackenford","Elmstead","Hazelbrook","Merefield","Oakcombe","Rowanbridge","Willowmere"})
export type Layout={rotation:number,candidate:number,nameId:number,name:string,countryId:string}
function Starter.rotate(x:number,y:number,r:number):(number,number)
 for _=1,r do x,y=1024-y,x end
 return x,y
end
function Starter.layout(seed:string,countryId:string,candidate:number):Layout
 assert(candidate%1==0 and candidate>=0 and candidate<=8,"Candidate bounds")
 assert(#countryId>0 and #countryId<=36 and not string.find(countryId,"[^%w%-]"),"Country identity")
 local rotation=if candidate==8 then 0 else math.floor(Field.sample(Field.prefix(seed,"start-layout",1),0,0,candidate)/1073741824)
 local nameId=math.floor(Field.sample(Field.prefix(seed,"town-name",1),0,0,0)/536870912)+1
 return {rotation=rotation,candidate=candidate,nameId=nameId,name=Starter.NAMES[nameId],countryId=countryId}
end
-- Union of the exit corridor and two orthogonal future-site routes. Chebyshev
-- distance gives an integer 64-unit feather; protected interiors remain exactly flat.
function Starter.weight(layout:Layout,x:number,y:number):number
 x,y=Starter.rotate(x,y,(4-layout.rotation)%4)
 local distance=math.huge
 for _,box in {{-128,448,1152,576},{256,448,384,768},{640,448,768,768}} do
  distance=math.min(distance,math.max(box[1]-x,0,x-box[3],box[2]-y,y-box[4]))
 end
 return 4096-Field.smooth(math.clamp(math.floor(distance*4096/64),0,4096))
end
function Starter.network(layout:Layout)
 local prefix=layout.countryId..":0,0:"
 local gen,sub,town=prefix.."generator",prefix.."substation",prefix.."settlement"
 local gx,gy=Starter.rotate(320,512,layout.rotation)
 local tx,ty=Starter.rotate(704,512,layout.rotation)
 return {generatorId=gen,demandId=town,demandMW=3,population=1000,nodes={
  {id=gen,kind="Generator",name="Starter Generator",capacity=5,x=gx,y=gy},
  {id=sub,kind="Substation",name="Central Substation",capacity=10,x=512,y=512},
  {id=town,kind="Settlement",name=layout.name,capacity=10,x=tx,y=ty}},
  lines={{id=prefix.."feed",from=gen,to=sub,capacity=10,connected=true},
   {id=prefix.."town",from=sub,to=town,capacity=10,connected=true}}}
end
function Starter.validate(layout:Layout,sample:(number,number)->{elevationM:number,temperatureCentiC:number,rainfallMm:number})
 local minimum=math.huge
 for _,pad in {{320,512},{512,512},{704,512},{320,704},{704,704}} do
  local elevation:number?=nil
  for _,dx in {-48,0,48} do for _,dy in {-48,0,48} do
   local x,y=Starter.rotate(pad[1]+dx,pad[2]+dy,layout.rotation);local p=sample(x,y)
   minimum=math.min(minimum,p.elevationM)
   assert(p.elevationM==40 and p.temperatureCentiC==1700 and p.rainfallMm==1000,"Starter pad/climate fairness")
   if elevation then assert(math.abs(p.elevationM-elevation)/(48*10)<=.02,"Starter slope") end
   elevation=p.elevationM
  end end
 end
 for x=-128,1152,32 do
  local wx,wy=Starter.rotate(x,512,layout.rotation)
  assert(sample(wx,wy).elevationM==40,"Dry expansion corridor")
 end
 for _,x in {320,704} do for y=512,704,32 do
  local wx,wy=Starter.rotate(x,y,layout.rotation)
  assert(sample(wx,wy).elevationM==40,"Future pad route")
 end end
 local totalLength=0
 for _,route in {{320,512,512,512},{512,512,704,512},{320,512,320,704},{704,512,704,704},{0,512,512,512},{512,512,1024,512}} do
  local ax,ay=Starter.rotate(route[1],route[2],layout.rotation)
  local bx,by=Starter.rotate(route[3],route[4],layout.rotation)
  totalLength+=math.sqrt((ax-bx)^2+(ay-by)^2)
 end
 local ratio=totalLength/1792;assert(math.abs(totalLength-1792)<=1/16,"Expansion route lengths")
 return {minimumPadElevationM=minimum,maxPadSlope=0,exitCount=2,routeRatio=ratio,
  equipmentMW=5,population=1000,affordabilityVerified=false}
end
return table.freeze(Starter)
