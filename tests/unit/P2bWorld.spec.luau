--!strict
-- Pure modules exercised inside Roblox; the 10,000 starts are a bounded test corpus, not player worlds.
return function(sweepCount:number?,inspectConstruction:((any)->())?)
 local world=game:GetService("ServerScriptService").Server.World
 local Hash=require(world.IntegerField);local Climate=require(world.ClimateModel)
 local Generator=require(world.WorldGenerator);local Starter=require(world.StarterValidator);local Demand=require(world.DemandModel)
 local Solver=require(game:GetService("ServerScriptService").Server.Simulation.GridSolver)
 local Golden=require(script.Parent.P2bGolden)
 local Http=game:GetService("HttpService")
 local n=0;local function check(ok:boolean,label:string)assert(ok,label);n+=1 end
 local function near(a:number,b:number)check(math.abs(a-b)<1e-8,"Numeric parity")end
 check(Hash.fnv("")==0x811c9dc5,"FNV empty");check(Hash.fnv("a")==0xe40c292c,"FNV a");check(Hash.fnv("foobar")==0xbf9cf968,"FNV foobar")
 for _,v in {{seed="b5b45c5ea54b47679b7a759c9144292c",expected=0x1c4becb1},{seed="4f23d98f6df8446394bf5da476a7afaa",expected=0xe920dce0},{seed="1e900caef74c4e51959b5def23e29f4d",expected=0x65b6254f}} do
  check(Hash.sample(Hash.prefix(v.seed,"temperature",1),-1,0,0)==v.expected,"Canonical signed bytes")
 end
 for _,v in Golden.climate do local p=Climate.create(v.seed).sample(v.x,v.y);check(p.elevationM==v.e and p.temperatureCentiC==v.t and p.rainfallMm==v.r,"Independent climate vector")end
 local first=Generator.create(Golden.seed,"golden",1)
 check(first.layout.rotation==Golden.rotation and first.layout.nameId==Golden.nameId,"Independent layout vector")
 for i,p in first.chunks[5].samples do check(p.elevationM==Golden.elevations[i],"Full active-sector golden elevation") end
 print(string.format("[P2b cold] first start %.3fms; stages %s",first.cpuMs,Http:JSONEncode(first.stages)))
 local again=Generator.create(Golden.seed,"golden",1)
 check(Http:JSONEncode(first.chunks)==Http:JSONEncode(again.chunks),"Identical seed descriptors")
 for _,bad in {"",string.rep("z",32),string.rep("a",33)} do check(not pcall(Generator.create,bad,"x",1),"Invalid seed")end
 check(not pcall(Generator.create,Golden.seed,"x",2),"Unknown version")
 for _,x in {-1048576,-1024,-1,0,1024,1048575.9375} do local s,l=Generator.sectorOf(x);near(s*1024+l,x);check(l>=0 and l<1024,"Half-open ownership")end
 check(not pcall(Generator.sectorOf,1048576),"Upper bound");check(not pcall(Generator.sectorOf,0/0),"NaN")
 for _,chunk in first.chunks do for _,other in first.chunks do
  if other.sx==chunk.sx+1 and other.sy==chunk.sy then
   for row=0,16 do local a=chunk.samples[row*17+17];local b=other.samples[row*17+1];check(a.elevationM==b.elevationM and a.temperatureCentiC==b.temperatureCentiC,"Shared X edge")end
  end
  if other.sy==chunk.sy+1 and other.sx==chunk.sx then
   for col=1,17 do local a=chunk.samples[272+col];local b=other.samples[col];check(a.elevationM==b.elevationM and a.rainfallMm==b.rainfallMm,"Shared Y edge")end
  end
 end end
 local climate=Climate.create(Golden.seed)
 local points={{-1024,0},{0,1024},{3072,-2048},{-4608,512}}
 local samples={};for i,p in points do samples[i]=climate.sample(p[1],p[2])end
 for i=#points,1,-1 do check(Http:JSONEncode(samples[i])==Http:JSONEncode(climate.sample(points[i][1],points[i][2])),"Query order independence")end
 -- Reconstruct chunks in reverse order with an independent field/cache and shared reservation descriptor.
 local reverseClimate=Climate.create(Golden.seed)
 for i=#first.chunks,1,-1 do
  local chunk=first.chunks[i]
  for j=#chunk.samples,1,-1 do
   local expected=chunk.samples[j];local base=reverseClimate.sample(expected.x,expected.y)
   local e=Hash.lerp(base.elevationM,40,Starter.weight(first.layout,expected.x,expected.y))
   local actual=reverseClimate.sample(expected.x,expected.y,e)
   check(actual.elevationM==expected.elevationM and actual.temperatureCentiC==expected.temperatureCentiC and actual.rainfallMm==expected.rainfallMm,"Reverse chunk traversal parity")
  end
 end
 for _,seed in {string.rep("0",32),string.rep("f",32),string.rep("a",32),string.rep("5",32),"dfff043298824c4da9e3e4e45da85bc6"}do
  local adversarial=Generator.create(seed,"adversarial",1)
  check(adversarial.fairness.minimumPadElevationM>0 and adversarial.fairness.exitCount==2,"Adversarial starter fairness")
 end
 for _,t in {-2000,0,500,1000,1700,2000,2500,3000}do for _,r in {200,300,500,700,1000,1400,1700,2000,2400}do
  local sum=0;for _,w in Climate.biomes(t,r)do check(w>=0 and w<=1,"Biome bound");sum+=w end
  near(sum,1)
 end end
 check(not pcall(Generator.sectorOf,.01),"Sub-sixteenth rejected")
 check(not pcall(Climate.create(Golden.seed).sample,math.huge,0),"Infinite field position rejected")
 local sumR,sumB=0,0;for _,v in Demand.RESIDENTIAL do sumR+=v end;for _,v in Demand.COMMERCIAL do sumB+=v end
 check(sumR==24000 and sumB==24000,"Daily curves normalized")
 for _,step in {0,239,719,1439,1440,1000000}do
  local d=Demand.atStep(step,1700,1000);local repeated=Demand.atStep(step+1440,1700,1000)
  near(d.demandMW,repeated.demandMW);near(d.rawMW,repeated.rawMW)
  near(d.rawMW,d.residentialMW+d.commercialMW+d.heatingMW+d.coolingMW)
 end
 local fallback=Starter.layout(Golden.seed,"safe",8);check(fallback.rotation==0,"Safe template rotation")
 local function fallbackSample(x:number,y:number)
  local p=climate.sample(x,y);return climate.sample(x,y,Hash.lerp(p.elevationM,40,Starter.weight(fallback,x,y)))
 end
 check(Starter.validate(fallback,fallbackSample).exitCount==2,"Safe template validated")
 near(Demand.components(1000,20,1,1).demandMW,3);near(Demand.components(1000,10,1,1).demandMW,3.64);near(Demand.components(1000,30,1,1).demandMW,3.36)
 near(Demand.temperature(1700,240),12);near(Demand.temperature(1700,960),22)
 near(Demand.curve(Demand.RESIDENTIAL,0),Demand.curve(Demand.RESIDENTIAL,1440))
 check(not pcall(Demand.atStep,0/0,1700,1000),"Demand NaN rejected")
 check(not pcall(Demand.components,10000,-50,1.2,1.2),"No silent demand clamp")
 local dayMWh=0;local peak=0;local stepTimes={}
 for step=0,1439 do
  local before=os.clock();local d=Demand.atStep(step,1700,1000)
  first.network.demandMW=d.demandMW;local report=Solver.solve(first.network,true)
  table.insert(stepTimes,(os.clock()-before)*1000)
  check(d.demandMW<=4.10 and report.unmetMW==0 and report.headroomMW>=.90,"Full-day service envelope")
  check(math.abs(d.quantizationMW)<=.000500001,"Aggregate quantization bound")
  dayMWh+=report.deliveredMW/60;peak=math.max(peak,d.demandMW)
  if step==719 then check(Solver.solve(first.network,false).deliveredMW==0,"Generated outage");check(Solver.solve(first.network,true).unmetMW==0,"Generated recovery")end
 end
 local replay=0;for step=0,1439 do replay+=Demand.atStep(step,1700,1000).demandMW/60 end;near(dayMWh,replay)
 table.sort(stepTimes);check(stepTimes[math.ceil(#stepTimes*.95)]<=1,"Demand+solve p95 1ms gate")
 local batchTimes={};local held={};local beforeMemory=gcinfo()
 for i=1,8 do held[i]=Generator.create(Golden.seed,"memory-"..i,1) end
 local retainedKiB=math.max(0,gcinfo()-beforeMemory)/8
 print(string.format("[P2b memory] eight retained descriptors: %.2f KiB/country (allocator/GC noise)",retainedKiB))
 check(retainedKiB<=2048,"Retained memory 2MiB gate")
 for step=0,239 do
  local startBatch=os.clock()
  for _,generated in held do
   generated.network.demandMW=Demand.atStep(step,1700,1000).demandMW
   Solver.solve(generated.network,true)
  end
  table.insert(batchTimes,(os.clock()-startBatch)*1000)
 end
 table.sort(batchTimes);check(batchTimes[228]<=8,"Eight-country solve p95 8ms gate")
 print(string.format("[P2b demand] stepP95=%.4fms batchP95=%.4fms",stepTimes[math.ceil(#stepTimes*.95)],batchTimes[228]))
 local count=sweepCount or 10000;local fingerprints:{[string]:boolean}={};local unique,fallbacks=0,0;local times={};local rotations={0,0,0,0};local names={0,0,0,0,0,0,0,0}
 local maxEncoded,maxSamples=0,0
 for i=1,count do
  local seed=string.format("%08x%08x%08x%08x",Hash.fnv("seed-a:"..i),Hash.fnv("seed-b:"..i),Hash.fnv("seed-c:"..i),Hash.fnv("seed-d:"..i))
  local generated=Generator.create(seed,"sweep",1)
  if inspectConstruction then inspectConstruction(generated)end
  local f=generated.fairness;check(f.exitCount==2 and f.maxPadSlope<=.02 and f.routeRatio>=.9 and f.routeRatio<=1.1,"Seed fairness")
  check(generated.network.population==1000 and generated.network.nodes[1].capacity==5,"Equal initial equipment")
  local pieces={}
  for _,p in generated.chunks[5].samples do
   check(p.temperatureCentiC==1700 and p.rainfallMm==1000,"All starter climate protected")
   if Starter.weight(generated.layout,p.x,p.y)==0 then table.insert(pieces,tostring(p.elevationM))end
  end
  local fingerprint=table.concat(pieces,",");if not fingerprints[fingerprint] then fingerprints[fingerprint]=true;unique+=1 end
  fallbacks+=if generated.fallback then 1 else 0
  rotations[generated.layout.rotation+1]+=1;names[generated.layout.nameId]+=1
  maxSamples=math.max(maxSamples,generated.sampleCount);table.insert(times,generated.cpuMs)
  if i<=100 then maxEncoded=math.max(maxEncoded,#Http:JSONEncode(Generator.snapshot(generated)))end
  if i%100==0 then print(string.format("[P2b sweep] %d/%d unique=%d fallback=%d",i,count,unique,fallbacks));task.wait()end
 end
 table.sort(times);local p95=times[math.ceil(#times*.95)]
 print(string.format("[P2b gates] unique=%d/%d fallback=%d cpuP95=%.3fms maxEncoded=%d samples=%d dayMWh=%.6f peakMW=%.3f",unique,count,fallbacks,p95,maxEncoded,maxSamples,dayMWh,peak))
 print("[P2b distributions] rotations="..Http:JSONEncode(rotations).." names="..Http:JSONEncode(names))
 check(unique/count>=.99,"99% terrain diversity gate");check(fallbacks/count<=.01,"1% fallback gate")
 check(p95<=100,"Generation CPU p95 100ms gate");check(maxEncoded<=262144,"Full generated snapshot 256KiB gate")
 print(string.format("[Power State P2b world] PASS: %d assertions",n));return n
end
