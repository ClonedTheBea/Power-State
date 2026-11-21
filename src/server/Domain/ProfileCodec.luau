--!strict
-- Canonical key ordering for fixtures/checkpoints; JSON scalar escaping is injected.
local Codec={}
-- Cosmetic/runtime immutability never substitutes for schema validation. This
-- bounded weak cache retains only canonical bytes of recursively frozen values.
-- Scalar encoder identity is part of the proof (test encoders may differ).
local frozenBytes:any=setmetatable({},{__mode="k"})
local retainedBytes=0;local retainedEntries=0
function Codec.copy(value:any):any
 if type(value)~="table" then return value end
 local result={};for key,item in value do result[key]=Codec.copy(item)end;return result
end
function Codec.encode(value:any,scalar:(any)->string):string
 local seen:{[any]:boolean}={};local count=0;local bytes=0
 -- The injected canonical scalar encoder is pure. Cache repeated field names
 -- and values for this bounded traversal only; every occurrence still counts
 -- toward depth, nodes and bytes. Preserve the scalar encoder's signed-zero form.
 local scalars:{[any]:string}={}
 local function encodedScalar(v:any):string
  if type(v)=="number"and v==0 then return scalar(v)end
  local known=scalars[v];if known then return known end
  local encoded=scalar(v);scalars[v]=encoded;return encoded
 end
 local function emit(text:string):string
  bytes+=#text;assert(bytes<=262144,"Profile exceeds 256 KiB");return text
 end
 local function visit(v:any,depth:number):(string,boolean,number)
  local startCount=count
  count+=1;assert(count<=20000 and depth<=12,"Profile traversal bound")
  local kind=type(v)
  if kind=="number" then assert(v==v and math.abs(v)<math.huge,"Nonfinite profile number")end
  if kind=="string" then assert(#v<=256 and utf8.len(v)~=nil,"Invalid profile string")end
  if kind~="table" then
   assert(kind=="string" or kind=="number" or kind=="boolean","Unsupported profile value")
   return emit(encodedScalar(v)),true,0
  end
  assert(not seen[v] and getmetatable(v)==nil,"Cyclic/metatable profile")
  local cached=frozenBytes[v]
  if cached and cached.scalar==scalar then
   count+=cached.nodes-1
   assert(count<=20000 and depth+cached.height<=12,"Profile traversal bound")
   return emit(cached.text),true,cached.height
  end
  seen[v]=true
  local keys={};local numeric=false;local textual=false
  for key in v do
   assert(type(key)=="string" or type(key)=="number","Invalid profile key")
   if type(key)=="number" then numeric=true else textual=true;assert(#key<=64,"Profile key size")end
   table.insert(keys,key)
  end
  assert(not(numeric and textual),"Mixed profile table")
  local parts={};local immutable=table.isfrozen(v);local height=0;local largeFrozenChild=false
  local function child(item:any):string
   local text,frozen,childHeight=visit(item,depth+1)
   immutable=immutable and frozen;height=math.max(height,childHeight+1)
   if frozen and #text>=512 then largeFrozenChild=true end
   return text
  end
  if numeric then
   table.sort(keys);for i,key in keys do assert(key==i,"Sparse profile array");table.insert(parts,child(v[key]))end
  else
   table.sort(keys);for _,key in keys do table.insert(parts,emit(encodedScalar(key)..":")..child(v[key]))end
  end
  seen[v]=nil
  local delimiters=emit(string.rep(",",math.max(0,#parts-1))..(if numeric then "[]" else "{}"))
  assert(#delimiters>=2)
  local text=(if numeric then "[" else "{")..table.concat(parts,",")..(if numeric then "]" else "}")
  -- Cache leaf chunks rather than their ancestors as well: duplicating a whole
  -- history in simulation/country/profile entries evicts the useful histories.
  if immutable and #text>=512 and not largeFrozenChild then
   -- Coarse eviction bounds even values retained by a long-running country.
   if retainedEntries>=128 or retainedBytes+#text>2097152 then
    frozenBytes=setmetatable({},{__mode="k"});retainedBytes=0;retainedEntries=0
   end
   frozenBytes[v]={scalar=scalar,text=text,nodes=count-startCount,height=height}
   retainedBytes+=#text;retainedEntries+=1
  end
  return text,immutable,height
 end
 local result=visit(value,0);return result
end
return table.freeze(Codec)
