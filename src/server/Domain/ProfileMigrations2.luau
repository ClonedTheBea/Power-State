--!strict
local V1=require(script.Parent.ProfileSchema)
local V2=require(script.Parent.ProfileSchema2)
local Codec=require(script.Parent.ProfileCodec)
local Economy=require(script.Parent.Economy)
local Migration={}
-- Pure transformation. Lease2 supplies the atomic acquisition/fence/receipt.
function Migration.read(p:any,owner:number,operationId:string,scalar:(any)->string):any
 if p.schemaVersion==2 then V2.validate(p,owner,scalar);return Codec.copy(p)end
 V1.validate(p,owner,scalar)
 local n=Codec.copy(p);n.schemaVersion=2
 n.country.bank,n.country.economy=Economy.open(p.country,operationId)
 V2.validate(n,owner,scalar)
 return n
end
return table.freeze(Migration)
