--!strict
return function()
 local S=game.ServerScriptService.Server
 local Project=require(S.Domain.WindProject)
 local Starter=require(S.World.StarterValidator)
 local Hash=require(S.World.IntegerField)
 local Codec=require(S.Domain.ProfileCodec)
 local checks=0;local seen={}
 local function country(world:any):any
  return {recipe={countryId=world.countryId,seed=world.seed,candidate=world.candidate,fallback=world.fallback,
   generationVersion=1,climateVersion=1,demandVersion=1,startTemplateVersion=1,namePoolVersion=1,networkVersion=1},
   network=world.network,ownedSectors={{x=0,y=0}}}
 end
 local function inspect(world:any)
  local c=country(world)
  assert(Project.validateSite(c)==23);checks+=1;seen[world.layout.rotation]=true
  local climate=require(S.World.ClimateModel).create(world.seed)
  local points={}
  for _,dx in {-48,0,48}do for _,dy in {-48,0,48}do table.insert(points,{320+dx,704+dy})end end
  for y=512,704,32 do table.insert(points,{320,y})end
  for x=320,512,32 do table.insert(points,{x,512})end
  for r=0,3 do
   local rotated=table.clone(world.layout);rotated.rotation=r
   for _,point in points do
   local x,y=Starter.rotate(point[1],point[2],r)
   local weight=Starter.weight(rotated,x,y)
   assert(weight==4096 and Hash.lerp(climate.sample(x,y).elevationM,40,weight)==40,"All-rotation saved-seed wind geometry")
   checks+=1
  end end
 end
 require(script.Parent["P2bWorld.spec"])(10000,inspect)
 for r=0,3 do assert(seen[r],"All saved rotations covered")end
 local w=require(S.World.WorldGenerator).create(string.rep("0",32),"wind-site",1)
 local c=country(w);local before=game.HttpService:JSONEncode(c)
 Project.validateSite(c);assert(before==game.HttpService:JSONEncode(c),"Site validation immutable")
 for _,key in {"generationVersion","climateVersion","networkVersion"}do
  local bad=Codec.copy(c);bad.recipe[key]=2;assert(not pcall(Project.validateSite,bad));checks+=1
 end
 local bad=Codec.copy(c);bad.ownedSectors[1].x=1;assert(not pcall(Project.validateSite,bad));checks+=1
 bad=Codec.copy(c);bad.network.nodes[1].x+=1;assert(not pcall(Project.validateSite,bad));checks+=1
 print("[National Fleet wind site] PASS",checks,"checks; 10000 accepted worlds and four reservation rotations")
end
