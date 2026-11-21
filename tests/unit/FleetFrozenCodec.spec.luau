--!strict
return function(fixtures:any)
 local S=game.ServerScriptService.Server;local C=require(S.Domain.ProfileCodec)
 local R=require(S.Domain.FleetRecord);local Old=require(script.Parent.FleetCodecBaseline)
 local H=game:GetService("HttpService");local checks=0
 local function scalar(v:any):string return H:JSONEncode(v)end
 local function same(v:any)
  local a,x=pcall(Old.encode,v,scalar);local b,y=pcall(C.encode,v,scalar)
  assert(a==b and (not a or x==y),"Exact original bytes/rejection");checks+=1
 end
 for _,p in {fixtures.built,fixtures.post,fixtures.funded}do
  local n=R.freeze(C.copy(p));same(n);same(n);same({a=n,b=n})
  local wrapper:any=n;for _=1,12 do wrapper={child=wrapper};same(wrapper)end
 end
 local leaf={};for i=1,7000 do leaf[i]=true end;R.freeze(leaf);same(leaf);same({leaf,leaf,leaf})
 local shallow=table.freeze({child={text=string.rep("x",256),other=string.rep("y",256)}})
 same(shallow);shallow.child.text="changed";same(shallow);shallow.child.bad=0/0;same(shallow)
 local p=R.freeze(C.copy(fixtures.built));same(p)
 local alternate=function(v:any):string if type(v)=="number"then return "123"end;return scalar(v)end
 assert(C.encode(p,alternate)==Old.encode(p,alternate),"Encoder identity cannot reuse different scalar bytes");checks+=1;same(p)
 for i=1,160 do same(R.freeze({text=string.rep("z",256),other=string.rep("x",256),index=i}))end
 same(p)
 local mutable={a={value=1},b=R.freeze({value=2})};local captured=R.snapshot(mutable)
 assert(captured~=mutable and captured.a~=mutable.a and captured.b==mutable.b,"Share only deeply immutable branches");checks+=1
 mutable.a.value=3;assert(captured.a.value==1 and R.immutable(captured),"Staged copy cannot change with caller");checks+=1
 local cyclic:any={};cyclic.self=cyclic;table.freeze(cyclic)
 assert(not pcall(R.immutable,cyclic),"Frozen cycle cannot establish an immutable proof");checks+=1
 print("[Fleet11 frozen codec] PASS",checks,"exact bytes, mutable descendants, depth/node/byte limits, encoder identity and eviction")
end

