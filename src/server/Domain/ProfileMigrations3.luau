--!strict
local V2=require(script.Parent.ProfileSchema2)
local V3=require(script.Parent.ProfileSchema3)
local Codec=require(script.Parent.ProfileCodec)
local Project=require(script.Parent.ConstructionProject)
local Migration={}
function Migration.read(profile:any,owner:number,scalar:(any)->string):any
 if profile.schemaVersion==3 then V3.validate(profile,owner,scalar);return Codec.copy(profile)end
 V2.validate(profile,owner,scalar)
 local n=Codec.copy(profile);n.schemaVersion=3;n.country.bank.ledgerVersion=3
 n.country.bank.constructionSpentMinor=0;n.country.construction=Project.empty()
 V3.validate(n,owner,scalar);return n
end
return table.freeze(Migration)
