--!strict
-- Isolated fake storage boundary: transform canonical profiles atomically in one key.
local Fake=require(script.Parent.FakeDataStoreAdapter)
local F=require(script.Parent.Parent.Domain.FleetStorageFormat)
local Adapter={}
function Adapter.create(seed:any?,scalar:(any)->string):any
 local raw=Fake.create(seed,true)
 local function owner(key:string):number
  local value=tonumber(key:match("^u:(%d+)$")or key:match("^fake:(%-%d+)$"))
  assert(value and value~=0,"Exact profile key required");return value
 end
 local function decode(v:any,key:string):any
  return if v==nil then nil else F.read(v,owner(key),scalar)
 end
 return {
  mode="Fake",budget=raw.budget,setBudget=raw.setBudget,inject=raw.inject,setHook=raw.setHook,stats=raw.stats,
  read=function(key:string):any return decode(raw.read(key),key)end,
  inspect=function(key:string):any return decode(raw.inspect(key),key)end,
  inspectStored=raw.inspect,
  update=function(key:string,transform:(any)->any):any
   local result=raw.update(key,function(current:any):any
    local nextValue=transform(decode(current,key))
    return if nextValue==nil then nil else F.pack(nextValue,owner(key),scalar)
   end)
   return decode(result,key)
  end,
 }
end
return table.freeze(Adapter)
