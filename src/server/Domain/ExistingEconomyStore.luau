--!strict
-- Shared policy for a real transport and fake tests. No service access or migration.
local Codec=require(script.Parent.ProfileCodec)
local Schema=require(script.Parent.ProfileSchema2)
local Economy=require(script.Parent.Economy)
local Policy={KEY="u:149564436",OWNER=149564436,COUNTRY_ID="55e35a88-e3b9-4f72-9e69-d9024e7730a4"}
function Policy.create(transport:any,scalar:(any)->string,utcMs:()->number):any
 local function validate(value:any)
  Schema.validate(value,Policy.OWNER,scalar)
  assert(value.country.recipe.countryId==Policy.COUNTRY_ID,"Unexpected country; stop")
 end
 local initial=transport.read(Policy.KEY);validate(initial)
 assert(not initial.lease or initial.lease.expiresAtUtcMs<=utcMs(),"Active lease; stop")
 local baseline=Codec.encode(initial,scalar);local first=true;local firstResult:string?=nil
 local function keyCheck(key:string)assert(key==Policy.KEY,"Only the approved exact key is authorized")end
 return {
  mode=transport.mode,preflight=Codec.copy(initial),budget=transport.budget,stats=transport.stats,
  read=function(key:string):any
   keyCheck(key);local value=transport.read(key);validate(value)
   Economy.transition(initial.country,value.country,scalar)
   -- A lost first response can be confirmed by the coordinator's uncached read.
   if first and firstResult and Codec.encode(value,scalar)==firstResult then first=false end
   return value
  end,
  update=function(key:string,transform:(any)->any):any
   keyCheck(key)
   local result=transport.update(key,function(value:any):any
    validate(value);Economy.transition(initial.country,value.country,scalar)
    if first then
     local encoded=Codec.encode(value,scalar)
     assert(encoded==baseline or encoded==firstResult,"Profile changed since preflight; stop")
    end
    local updated=transform(Codec.copy(value));if updated==nil then return nil end
    validate(updated);Economy.transition(value.country,updated.country,scalar)
    assert(updated.lastCommit.kind~="MigrateAcquire","Migration forbidden")
    if first then firstResult=Codec.encode(updated,scalar)end
    return updated
   end)
   if result~=nil then first=false end
   return result
  end,
 }
end
return table.freeze(Policy)
