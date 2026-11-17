--!strict
local Field=require(script.Parent.IntegerField)
local Climate=require(script.Parent.ClimateModel)
local Starter=require(script.Parent.StarterValidator)
local Generator={}
function Generator.sectorOf(x:number):(number,number)
 assert(x==x and x*16%1==0 and x>=-1048576 and x<1048576,"World address")
 local sector=math.floor(x/1024);return sector,x-sector*1024
end
function Generator.create(seed:string,countryId:string,version:number,yieldWork:(()->())?)
 assert(version==1,"Unsupported world version")
 local climate=Climate.create(seed)
 local sampleCount=0;local sinceYield=0;local sliceStart=os.clock();local cpu=0
 local function budget()
  sampleCount+=1;sinceYield+=1;assert(sampleCount<=25000,"World sample budget")
  if yieldWork and (sinceYield>=128 or os.clock()-sliceStart>=.002) then
   cpu+=os.clock()-sliceStart;yieldWork();sliceStart=os.clock();sinceYield=0
  end
 end
 local function elapsedCPU():number return (cpu+os.clock()-sliceStart)*1000 end
 local function prepare(candidate:number)
  local began=elapsedCPU()
  local layout=Starter.layout(seed,countryId,candidate)
  local cache:{[string]:Climate.Sample}={}
  local function sample(x:number,y:number):Climate.Sample
   local key=tostring(x)..":"..tostring(y);local found=cache[key];if found then return found end
   budget();local p=climate.sample(x,y)
   local elevation=Field.lerp(p.elevationM,40,Starter.weight(layout,x,y))
   if elevation~=p.elevationM then p=climate.sample(x,y,elevation) end
   cache[key]=p;return p
  end
  local layoutMs=elapsedCPU()-began;local validationStart=elapsedCPU()
  local fairness=Starter.validate(layout,sample)
  local network=Starter.network(layout)
  local town=network.nodes[3]
  local meanTemperatureCentiC=sample(town.x,town.y).temperatureCentiC
  local validationMs=elapsedCPU()-validationStart;local terrainStart=elapsedCPU()
  local chunks={}
  for sy=-1,1 do for sx=-1,1 do
   local cells={}
   for ly=0,1024,64 do for lx=0,1024,64 do table.insert(cells,sample(sx*1024+lx,sy*1024+ly)) end end
   table.insert(chunks,{sx=sx,sy=sy,samples=cells})
  end end
  -- One-sample halo; cached shared edges are reused, not regenerated with local seeds.
  for y=-1088,2112,64 do for _,x in {-1088,2112} do sample(x,y) end end
  for x=-1024,2048,64 do for _,y in {-1088,2112} do sample(x,y) end end
  return {seed=seed,countryId=countryId,generationVersion=1,climateVersion=1,demandVersion=1,
   startTemplateVersion=1,namePoolVersion=1,candidate=candidate,fallback=candidate==8,
   layout=layout,fairness=fairness,network=network,meanTemperatureCentiC=meanTemperatureCentiC,chunks=chunks,
   sampleCount=sampleCount,cpuMs=0,width=1024,height=1024,
   stages={layoutMs=layoutMs,validationMs=validationMs,terrainMs=elapsedCPU()-terrainStart}}
 end
 -- Validation errors cannot silently choose another seed. Candidate search is bounded.
 local lastProblem=""
 for candidate=0,8 do
  local ok,result=pcall(prepare,candidate)
  if ok then
   result.cpuMs=(cpu+os.clock()-sliceStart)*1000
   assert(result.cpuMs<=2000,"World generation CPU watchdog")
   return result
  end
  lastProblem=tostring(result)
  if sampleCount>=25000 then break end
 end
 error("No valid starter: "..lastProblem)
end
function Generator.snapshot(world:any)
 -- Only the owned sector is a client descriptor; the validation neighborhood is server-only.
 return {seed=world.seed,countryId=world.countryId,generationVersion=1,climateVersion=1,demandVersion=1,
  startTemplateVersion=1,namePoolVersion=1,candidate=world.candidate,fallback=world.fallback,
  name=world.layout.name,nameId=world.layout.nameId,width=1024,height=1024,samples=world.chunks[5].samples}
end
return table.freeze(Generator)
