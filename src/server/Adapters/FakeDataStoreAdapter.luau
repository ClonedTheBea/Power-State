--!strict
local Codec=require(script.Parent.Parent.Domain.ProfileCodec)
local Fake={}
function Fake.create(seed:any?)
 local values=Codec.copy(seed or {});local versions:{[string]:number}={}
 local calls=0;local writes=0;local fault:string?=nil
 local hook:((string,string)->())?=nil
 local budget=true
 local function consume(kind:string,key:string)
  calls+=1;if hook then hook(kind,key)end
 end
 return {
  mode="Fake",
  budget=function():boolean return budget end,
  setBudget=function(value:boolean)budget=value end,
  inject=function(value:string?)fault=value end,
  setHook=function(value:((string,string)->())?)hook=value end,
  read=function(key:string):any
   consume("Read",key)
   if fault=="ReadFailure" or fault=="Unavailable" then error("Injected read failure")end
   return Codec.copy(values[key])
  end,
  update=function(key:string,transform:(any)->any):any
   consume("Update",key)
   if fault=="BeforeWrite" then fault=nil;error("Injected before-write failure")end
   if fault=="Unavailable" then error("Injected unavailable")end
   local candidate:any=nil
   for attempt=1,8 do
    local version=versions[key] or 0
    candidate=transform(Codec.copy(values[key]))
    if fault=="CallbackReplay" then candidate=transform(Codec.copy(values[key]));fault=nil end
    if version==(versions[key] or 0) then break end
    assert(attempt<8,"Fake contention bound")
   end
   if candidate==nil then return nil end
   if values[key]==nil then local count=0;for _ in values do count+=1 end;assert(count<64,"Fake store capacity")end
   values[key]=Codec.copy(candidate);versions[key]=(versions[key] or 0)+1;writes+=1
   if fault=="AfterWrite" then fault=nil;error("Injected lost response")end
   return Codec.copy(values[key])
  end,
  inspect=function(key:string):any return Codec.copy(values[key])end,
  stats=function()local count=0;for _ in values do count+=1 end;return {calls=calls,writes=writes,profiles=count}end,
 }
end
return table.freeze(Fake)
