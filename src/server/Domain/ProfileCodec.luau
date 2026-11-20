--!strict
-- Canonical key ordering for fixtures/checkpoints; JSON scalar escaping is injected.
local Codec={}
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
 local function visit(v:any,depth:number):string
  count+=1;assert(count<=20000 and depth<=12,"Profile traversal bound")
  local kind=type(v)
  if kind=="number" then assert(v==v and math.abs(v)<math.huge,"Nonfinite profile number")end
  if kind=="string" then assert(#v<=256 and utf8.len(v)~=nil,"Invalid profile string")end
  if kind~="table" then
   assert(kind=="string" or kind=="number" or kind=="boolean","Unsupported profile value")
   return emit(encodedScalar(v))
  end
  assert(not seen[v] and getmetatable(v)==nil,"Cyclic/metatable profile")
  seen[v]=true
  local keys={};local numeric=false;local textual=false
  for key in v do
   assert(type(key)=="string" or type(key)=="number","Invalid profile key")
   if type(key)=="number" then numeric=true else textual=true;assert(#key<=64,"Profile key size")end
   table.insert(keys,key)
  end
  assert(not(numeric and textual),"Mixed profile table")
  local parts={}
  if numeric then
   table.sort(keys);for i,key in keys do assert(key==i,"Sparse profile array");table.insert(parts,visit(v[key],depth+1))end
  else
   table.sort(keys);for _,key in keys do table.insert(parts,emit(encodedScalar(key)..":")..visit(v[key],depth+1))end
  end
  seen[v]=nil
  local delimiters=emit(string.rep(",",math.max(0,#parts-1))..(if numeric then "[]" else "{}"))
  assert(#delimiters>=2)
  return (if numeric then "[" else "{")..table.concat(parts,",")..(if numeric then "]" else "}")
 end
 return visit(value,0)
end
return table.freeze(Codec)
