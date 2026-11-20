--!strict
local Hash=require(script.Parent.Parent.World.IntegerField)
local Seed={VERSION=1,REGION="starter-0-0"}
function Seed.fromCountry(seed:string):number
 return Hash.fnv("PSFLEET\0v1\0"..Hash.seedBytes(seed))%2147483647
end
return table.freeze(Seed)
