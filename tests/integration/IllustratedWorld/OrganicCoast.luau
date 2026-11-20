--!strict
-- Cosmetic contract 1. No authority, instances, image allocation or mutable world data.
local Coast = {VERSION=1}
export type Corner = {x:number,y:number,radius:number,sx:number,sy:number,minorityLand:boolean}
local function finite(n:any):boolean return type(n)=="number" and n==n and math.abs(n)<math.huge end
function Coast.create(world:any,nodes:{any},links:{any},footprints:{any}?)
 assert(world.width==1024 and world.height==1024 and #world.samples==289,"Bounded saved sector")
 assert(world.generationVersion==1 and world.climateVersion==1 and world.startTemplateVersion==1,"Known saved versions")
 assert(#nodes<=32 and #links<=64 and (not footprints or #footprints<=128),"Bounded protection geometry")
 local land:{boolean}={}
 for _,s in world.samples do assert(finite(s.elevationM),"Finite saved elevation")end
 for y=0,15 do for x=0,15 do land[y*16+x+1]=world.samples[y*17+x+1].elevationM>0 end end
 local byId:{[string]:any}={};local boxes:{any}={}
 for _,n in nodes do
  assert(type(n.id)=="string" and not byId[n.id] and finite(n.x) and finite(n.y) and n.x>=0 and n.x<=1024 and n.y>=0 and n.y<=1024,"Known anchor")
  byId[n.id]=n;table.insert(boxes,{n.x-32,n.y-32,n.x+32,n.y+32})
 end
 for _,l in links do
  local a,b=byId[l.from],byId[l.to];assert(a and b,"Known route endpoints")
  -- Conservative AABB also protects non-axis-aligned routes without inventing a route.
  table.insert(boxes,{math.min(a.x,b.x)-16,math.min(a.y,b.y)-16,math.max(a.x,b.x)+16,math.max(a.y,b.y)+16})
 end
 for _,b in footprints or {} do
  assert(#b==4 and finite(b[1]) and finite(b[2]) and finite(b[3]) and finite(b[4]) and b[1]<=b[3] and b[2]<=b[4],"Valid visible footprint")
  table.insert(boxes,table.clone(b))
 end
 local corners:{Corner}={};local cells:{{Corner}}={}
 for i=1,256 do cells[i]={} end
 for y=1,15 do for x=1,15 do
  local q={land[(y-1)*16+x],land[(y-1)*16+x+1],land[y*16+x],land[y*16+x+1]}
  local n=0;for _,v in q do if v then n+=1 end end
  if n~=1 and n~=3 then continue end -- includes exact diagonal contacts and straight ports
  local vx,vy=x*64,y*64;local blocked=false
  for _,a in nodes do if (vx-a.x)^2+(vy-a.y)^2<80^2 then blocked=true end end
  local r=16+math.min(8,math.floor(math.abs(world.samples[y*17+x+1].elevationM)/15))
  local minority=n==1;local ix,iy=0,0
  for i,v in q do if v==minority then ix=(i-1)%2;iy=math.floor((i-1)/2) end end
  local sx,sy=if ix==0 then -1 else 1,if iy==0 then -1 else 1
  local x0,x1=math.min(vx,vx+sx*r),math.max(vx,vx+sx*r)
  local y0,y1=math.min(vy,vy+sy*r),math.max(vy,vy+sy*r)
  for _,b in boxes do if x0<=b[3] and x1>=b[1] and y0<=b[4] and y1>=b[2] then blocked=true end end
  if not blocked then
   local c=table.freeze({x=vx,y=vy,radius=r,sx=sx,sy=sy,minorityLand=minority})
   table.insert(corners,c);table.insert(cells[(y-1+iy)*16+x+ix],c)
  end
 end end
 for _,cell in cells do table.freeze(cell)end
 table.freeze(cells);table.freeze(corners);table.freeze(land)
 local function sample(x:number,y:number):boolean
  assert(finite(x) and finite(y),"Finite cosmetic coordinate")
  local cx,cy=math.clamp(math.floor(x/64),0,15),math.clamp(math.floor(y/64),0,15)
  local index=cy*16+cx+1;local result=land[index]
  if x<0 or x>=1024 or y<0 or y>=1024 then return result end
  for _,c in cells[index] do
   local dx,dy=(x-c.x)*c.sx,(y-c.y)*c.sy
   if dx>=0 and dy>=0 and dx<c.radius and dy<c.radius and (c.radius-dx)^2+(c.radius-dy)^2>c.radius^2 then return not c.minorityLand end
  end
  return result
 end
 return table.freeze({version=Coast.VERSION,corners=corners,cells=cells,land=land,sample=sample})
end
return table.freeze(Coast)
