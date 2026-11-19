--!strict
return function(fixtures:{any})
 local root=game.StarterPlayer.StarterPlayerScripts.DevelopmentTests.IllustratedWorld
 local Descriptor=require(root.IllustratedSectorDescriptor)
 local Catalog=require(root.IllustratedAtlasCatalog)
 local Http=game.HttpService
 local checks=0
 local function check(v:boolean,m:string)assert(v,m);checks+=1 end
 for _,fixture in fixtures do
  local before=Http:JSONEncode(fixture)
  local legacy=Descriptor.create(fixture.world,fixture.nodes,fixture.links,1)
  for variant=0,63 do
   local world=Http:JSONDecode(Http:JSONEncode(fixture.world))
   world.countryId=world.countryId..":"..variant
   local d=Descriptor.create(world,fixture.nodes,fixture.links,2)
   check(#d.decorations<=25,"Bounded existing decoration budget")
   check(Http:JSONEncode(d)==Http:JSONEncode(Descriptor.create(world,fixture.nodes,fixture.links,2)),"Identity/version deterministic replay")
   check(Http:JSONEncode(d.shores)==Http:JSONEncode(legacy.shores) and Http:JSONEncode(d.assets)==Http:JSONEncode(legacy.assets),"Exact coastline and infrastructure preserved")
   for i,e in d.decorations do
    local m=Catalog.motifs[e.art];local left=e.x-m.pivot[1]*m.size/m.rect[3];local top=e.y-m.pivot[2]*m.size/m.rect[4]
    check(left>=0 and top>=0 and left+m.size<=1024 and top+m.size<=1024,"Art footprint in owned sector")
    for y=math.floor(top/64),math.floor((top+m.size-.001)/64) do for x=math.floor(left/64),math.floor((left+m.size-.001)/64) do
     check(world.samples[y*17+x+1].elevationM>0,"Whole art footprint on original land")
    end end
    for j=i+1,#d.decorations do local b=d.decorations[j];check((e.x-b.x)^2+(e.y-b.y)^2>=85^2,"No piled duplicate motifs")end
    for _,node in fixture.nodes do check((e.x-node.x)^2+(e.y-node.y)^2>=115^2,"Quiet infrastructure anchors")end
   end
  end
  check(before==Http:JSONEncode(fixture),"Cosmetic composition cannot mutate authoritative input")
  check(not pcall(Descriptor.create,fixture.world,fixture.nodes,fixture.links,3),"Unknown cosmetic version rejected")
 end
 print("[Landscape v2 pure] PASS",checks,"assertions /128 identity cases; no geography mutation")
end
