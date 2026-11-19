--!strict
-- Cosmetic version 2. Never writes geography or uses the authoritative hash namespace.
local Catalog=require(script.Parent.IllustratedAtlasCatalog)
local Composition={VERSION=2,MAX_DECORATIONS=25}
function Composition.create(world:any,nodes:{any},links:{any})
 assert(type(world.seed)=="string" and type(world.countryId)=="string","Saved cosmetic identity required")
 local salt=2166136261
 for i=1,#(world.seed..world.countryId..":cosmetic:2") do
  salt=bit32.bxor(salt,string.byte(world.seed..world.countryId..":cosmetic:2",i))
  salt=(salt*65599)%4294967296 -- exact below 2^53; independent of gameplay generation
 end
 local function hash(x:number,y:number,tag:number):number
  local n=bit32.bxor(salt,x*7381,y*19391,tag*83491)
  n=bit32.bxor(n,bit32.lshift(n,13));n=bit32.bxor(n,bit32.rshift(n,17))
  return bit32.bxor(n,bit32.lshift(n,5))
 end
 local centres={Vector2.new(160+hash(0,0,1)%704,160+hash(0,0,2)%704),Vector2.new(160+hash(0,0,3)%704,160+hash(0,0,4)%704)}
 local byId:{[string]:any}={};for _,node in nodes do byId[node.id]=node end
 local function fits(art:string,x:number,y:number):boolean
  local m=Catalog.motifs[art]
  local left,top=x-m.pivot[1]*m.size/m.rect[3],y-m.pivot[2]*m.size/m.rect[4]
  if left<0 or top<0 or left+m.size>1024 or top+m.size>1024 then return false end
  for row=math.floor(top/64),math.floor((top+m.size-.001)/64) do
   for col=math.floor(left/64),math.floor((left+m.size-.001)/64) do
    if world.samples[row*17+col+1].elevationM<=0 then return false end
   end
  end
  return true
 end
 local candidates:{any}={}
 for row=1,14 do for col=1,14 do
  local x,y=col*64+8+hash(col,row,5)%48,row*64+8+hash(col,row,6)%48
  local sample=world.samples[row*17+col+1]
  local clear=true;local townDistance=math.huge
  for _,node in nodes do
   local distance=(Vector2.new(node.x,node.y)-Vector2.new(x,y)).Magnitude
   if distance<115 then clear=false end
   if node.kind=="Settlement" then townDistance=math.min(townDistance,distance) end
  end
  -- Leave a quiet corridor beneath functional connections and their selection overlays.
  for _,link in links do
   local a,b=byId[link.from],byId[link.to]
   local dx,dy=b.x-a.x,b.y-a.y
   local t=math.clamp(((x-a.x)*dx+(y-a.y)*dy)/math.max(1,dx*dx+dy*dy),0,1)
   if (x-a.x-t*dx)^2+(y-a.y-t*dy)^2<65^2 then clear=false end
  end
  local forestDistance=math.min((Vector2.new(x,y)-centres[1]).Magnitude,(Vector2.new(x,y)-centres[2]).Magnitude)
  local art:string?=nil;local score=0
  if sample.elevationM>75 then
   art=if hash(col,row,7)%2==0 then "hill-low-a" else "hill-low-b";score=sample.elevationM
  elseif townDistance<300 and sample.elevationM>12 and sample.elevationM<65 and hash(col,row,8)%3==0 then
   art="fields";score=200-townDistance*.3
  elseif forestDistance<185 and (sample.rainfallMm or 1000)>=600 then
   art="forest";score=200-forestDistance*.5
  end
  if clear and art and fits(art,x,y) then
   table.insert(candidates,{id="land-v2:"..col..":"..row,art=art,x=x,y=y,score=score})
  end
 end end
 table.sort(candidates,function(a,b)if a.score==b.score then return a.id<b.id end;return a.score>b.score end)
 local result:{any}={}
 for _,candidate in candidates do
  local clear=true
  for _,other in result do
   if (candidate.x-other.x)^2+(candidate.y-other.y)^2<85^2 then clear=false;break end
  end
  if clear then
   table.insert(result,{id=candidate.id,art=candidate.art,x=candidate.x,y=candidate.y})
   if #result==Composition.MAX_DECORATIONS then break end
  end
 end
 return result
end
return table.freeze(Composition)
