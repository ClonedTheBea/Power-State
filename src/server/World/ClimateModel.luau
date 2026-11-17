--!strict
local Hash=require(script.Parent.IntegerField)
local Climate={}
Climate.OUTER_RADIUS=4608
export type Sample={x:number,y:number,elevationM:number,rawTemperatureCentiC:number,lapseCentiC:number,
 temperateWeightQ12:number,temperatureCentiC:number,rainfallMm:number}
function Climate.create(seed:string)
 local prefixes:{[string]:string}={}
 for _,tag in {"elevation-coarse","elevation-fine","temperature","rainfall"} do prefixes[tag]=Hash.prefix(seed,tag,1) end
 -- Lattice values are deterministic; this bounded cache is an optimization, never part of the seed state.
 local cache:{[string]:number}={};local entries=0
 local function field(tag:string,x:number,y:number,spacing:number,low:number,high:number):number
  local ix,iy=math.floor(x/spacing),math.floor(y/spacing)
  local wx=Hash.smooth(math.floor((x-ix*spacing)*4096/spacing))
  local wy=Hash.smooth(math.floor((y-iy*spacing)*4096/spacing))
  local function corner(dx:number,dy:number):number
   local key=tag..":"..tostring(ix+dx)..":"..tostring(iy+dy)
   local value=cache[key]
   if value==nil then
    value=low+math.floor(math.floor(Hash.sample(prefixes[tag],ix+dx,iy+dy,0)/65536)*(high-low+1)/65536)
    if entries>=4096 then table.clear(cache);entries=0 end
    cache[key]=value;entries+=1
   end
   return value
  end
  return Hash.lerp(Hash.lerp(corner(0,0),corner(1,0),wx),Hash.lerp(corner(0,1),corner(1,1),wx),wy)
 end
 local function sample(x:number,y:number,elevationOverride:number?):Sample
  assert(x==x and y==y and math.abs(x)<=1048640 and math.abs(y)<=1048640 and x*16%1==0 and y*16%1==0,"Invalid world coordinate")
  local elevation=elevationOverride or (60+field("elevation-coarse",x,y,512,-160,160)+field("elevation-fine",x,y,128,-40,40))
  local raw=field("temperature",x,y,8192,-2000,3000)
  local lapse=math.floor((-6*math.max(elevation,0)+5)/10)
  local rain=field("rainfall",x,y,4096,200,2400)
  local r2=(x-512)^2+(y-512)^2
  local bounded=math.clamp(r2-2048^2,0,4608^2-2048^2)
  local u=math.floor(bounded*4096/(4608^2-2048^2))
  local weight=4096-Hash.smooth(u)
  return {x=x,y=y,elevationM=elevation,rawTemperatureCentiC=raw,lapseCentiC=lapse,
   temperateWeightQ12=weight,temperatureCentiC=Hash.lerp(raw+lapse,1700,weight),rainfallMm=Hash.lerp(rain,1000,weight)}
 end
 return {sample=sample,field=field}
end
function Climate.biomes(temp:number,rain:number)
 local cold=math.clamp((1000-temp)/1000,0,1)
 local warm=math.clamp((temp-2000)/1000,0,1)
 local dry=math.clamp((700-rain)/400,0,1)
 local wet=math.clamp((rain-1400)/600,0,1)
 local weights:{[string]:number}={}
 local thermalWeights:{[string]:number}={cold=cold,temperate=1-cold-warm,warm=warm}
 local moistureWeights:{[string]:number}={dry=dry,normal=1-dry-wet,wet=wet}
 for thermal,t in thermalWeights do
  for moisture,r in moistureWeights do weights[thermal.."-"..moisture]=t*r end
 end
 return weights
end
return table.freeze(Climate)
