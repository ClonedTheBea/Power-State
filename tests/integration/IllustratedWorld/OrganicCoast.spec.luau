--!strict
return function(fixtures:{any})
 local Coast=require(script.Parent.OrganicCoast)
 local checks=0
 local function check(v:boolean,m:string)assert(v,m);checks+=1 end
 for bits=0,511 do
  local world={width=1024,height=1024,generationVersion=1,climateVersion=1,startTemplateVersion=1,samples={}}
  for y=0,16 do for x=0,16 do
   local inside=x>=5 and x<=7 and y>=5 and y<=7
   local value=inside and bit32.band(bits,bit32.lshift(1,(y-5)*3+x-5))~=0
   table.insert(world.samples,{elevationM=if value then 120 else -120})
  end end
  local coast=Coast.create(world,{},{})
  check(#coast.corners<=225,"Bounded corner records")
  for _,c in coast.corners do
   check(c.radius==24,"Elevation radius")
   for dy=0,23 do for dx=0,23 do
    local x,y=c.x+c.sx*(dx+.5),c.y+c.sy*(dy+.5)
    local outside=(24-dx-.5)^2+(24-dy-.5)^2>576
    check(coast.sample(x,y)==(if outside then not c.minorityLand else c.minorityLand),"Exact circle coverage")
   end end
  end
  -- Centre/port invariants leave the original four/eight neighbour graph intact.
  for y=4,8 do for x=4,8 do
   local land=world.samples[y*17+x+1].elevationM>0
   for _,p in {{32,32},{.5,32},{63.5,32},{32,.5},{32,63.5}} do check(coast.sample(x*64+p[1],y*64+p[2])==land,"Unchanged component ports")end
  end end
  if bits%16==0 then game:GetService("RunService").Heartbeat:Wait()end
 end
 for _,f in fixtures do
  local before=game.HttpService:JSONEncode(f)
  local c=Coast.create(f.world,f.nodes,f.links)
  for _,n in f.nodes do for y=-32,32 do for x=-32,32 do
   local wx,wy=n.x+x,n.y+y
   local index=math.clamp(math.floor(wy/64),0,15)*16+math.clamp(math.floor(wx/64),0,15)+1
   check(c.sample(wx,wy)==c.land[index],"Complete protected anchor square")
  end end end
  for p=0,1023 do
   for _,v in {{p+.5,.5},{p+.5,1023.5},{.5,p+.5},{1023.5,p+.5}} do
    local index=math.floor(v[2]/64)*16+math.floor(v[1]/64)+1
    check(c.sample(v[1],v[2])==c.land[index],"Unknown borders frozen")
   end
  end
  check(before==game.HttpService:JSONEncode(f),"Descriptor infrastructure immutable")
  local allProtected=Coast.create(f.world,f.nodes,f.links,{{0,0,1024,1024}})
  check(#allProtected.corners==0,"Whole native fallback for protected footprint")
 end
 print("IW14_GEOMETRY_PASS",checks)
 return checks
end
