--!strict
-- Byte-for-byte comparison against the pre-optimization bounded encoder.
return function(fixtures:any)
 local New=require(game.ServerScriptService.Server.Domain.ProfileCodec)
 local Old=require(script.Parent.FleetCodecBaseline)
 local H=game:GetService("HttpService");local checks=0
 local function scalar(v:any):string return H:JSONEncode(v)end
 local function check(v:boolean,m:string)assert(v,m);checks+=1 end
 for _,p in {fixtures.funded,fixtures.built,fixtures.post,{a=0,b=-0.0,c="0",d=true,e=false,f="\"\\\në"}}do
  check(New.encode(p,scalar)==Old.encode(p,scalar),"Exact historical canonical bytes, including signed zero and escaped strings")
 end
 local cyclic:any={};cyclic.self=cyclic
 local deep:any={};local cursor=deep;for _=1,14 do cursor.child={};cursor=cursor.child end
 local many={};for i=1,20001 do many[i]=true end
 local huge={};for i=1,2000 do huge[i]=string.rep("x",256)end
 for _,v in {cyclic,deep,many,huge,{[1]=true,[3]=false},{a=0/0},{a=math.huge},setmetatable({a=1},{}),{a=string.rep("x",257)}}do
  local old=pcall(Old.encode,v,scalar);local new=pcall(New.encode,v,scalar)
  check(not old and not new,"Unchanged malformed/traversal/size rejection")
 end
 local before,after=0,0
 local p=fixtures.built
 Old.encode(p,function(v)before+=1;return scalar(v)end)
 New.encode(p,function(v)after+=1;return scalar(v)end)
 check(after<before,"Bounded scalar cache reduces engine encoding calls")
 print("FLEET_CODEC_PASS",checks,"scalar calls",before,after)
end
