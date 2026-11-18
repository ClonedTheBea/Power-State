--!strict
local Schema=require(script.Parent.ProfileSchema)
local Codec=require(script.Parent.ProfileCodec)
local Migrations={}
function Migrations.read(value:any,owner:number,scalar:(any)->string):any
 -- No older durable schema exists. Unknown versions are never defaulted or repaired.
 Schema.validate(value,owner,scalar)
 return Codec.copy(value)
end
return table.freeze(Migrations)
