--!strict
local V1=require(script.Parent.ProfileSchema)
local Codec=require(script.Parent.ProfileCodec)
local Economy=require(script.Parent.Economy)
local Schema={MAX_INTEGER=V1.MAX_INTEGER,integer=V1.integer}
-- A validation projection only. Never write this representation or downgrade a save.
function Schema.legacyCountry(country:any):any
 local c=Codec.copy(country);c.economy=nil
 c.bank={currency="Credits",minorUnitsPerCredit=100,ledgerVersion=1,balanceMinor=0,earnedMinor=0,spentMinor=0}
 return c
end
function Schema.legacy(profile:any):any
 local p=Codec.copy(profile);p.schemaVersion=1;p.country=Schema.legacyCountry(p.country)
 if p.lastCommit.kind=="MigrateAcquire" then p.lastCommit.kind="Acquire" end
 return p
end
function Schema.country(c:any)
 V1.country(Schema.legacyCountry(c))
 Economy.validate(c.bank,c.economy,c.simulation,c.recipe.countryId)
end
function Schema.validate(p:any,owner:number,scalar:(any)->string):(number,boolean)
 local encoded=Codec.encode(p,scalar)
 assert(p.schemaVersion==2,"Schema 2 required")
 V1.validate(Schema.legacy(p),owner,scalar)
 Schema.country(p.country)
 assert(#Codec.encode({bank=p.country.bank,economy=p.country.economy},scalar)<=16384,"Finance exceeds 16 KiB")
 return #encoded,#encoded>196608
end
return table.freeze(Schema)
