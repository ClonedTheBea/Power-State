--!strict
-- Approved v1: byte-canonical FNV-1a, exact 16-bit multiplication, Q12 fields.
local Hash = {}
Hash.Q = 4096
local TAGS = { ["elevation-coarse"]=true, ["elevation-fine"]=true, temperature=true,
 rainfall=true, ["start-layout"]=true, ["town-name"]=true }
function Hash.seedBytes(seed: string): string
 assert(#seed == 32 and not string.find(seed, "[^0-9a-f]"), "Invalid v1 seed")
 local bytes = table.create(16)
 for i=1,32,2 do table.insert(bytes,string.char(tonumber(string.sub(seed,i,i+1),16) :: number)) end
 return table.concat(bytes)
end
function Hash.fnv(bytes: string): number
 local h = 2166136261
 for i=1,#bytes do
  h = bit32.bxor(h,string.byte(bytes,i))
  local lo,hi = h%65536,math.floor(h/65536)
  local product = lo*403 -- 16777619 = 256*65536 + 403
  h = product%65536 + ((math.floor(product/65536)+hi*403+lo*256)%65536)*65536
 end
 return h
end
local function word(n: number): string
 assert(n==n and n%1==0 and n>=-2147483648 and n<=4294967295,"Invalid hash word")
 n=n%4294967296
 return string.char(n%256,math.floor(n/256)%256,math.floor(n/65536)%256,math.floor(n/16777216)%256)
end
function Hash.prefix(seed: string, tag: string, version: number): string
 assert(TAGS[tag] and version==1,"Unsupported generation stream/version")
 return "PS2B\0"..Hash.seedBytes(seed)..word(version)..string.char(#tag)..tag
end
function Hash.sample(prefix: string, x: number, y: number, index: number): number
 assert(x>=-2147483648 and x<=2147483647 and y>=-2147483648 and y<=2147483647,"Hash coordinate range")
 assert(index>=0,"Negative candidate")
 return Hash.fnv(prefix..word(x)..word(y)..word(index))
end
function Hash.smooth(u: number): number
 assert(u%1==0 and u>=0 and u<=4096,"Q12 domain")
 return math.floor((u*u*(12288-2*u)+8388608)/16777216)
end
function Hash.lerp(a: number,b: number,w: number): number
 return a+math.floor(((b-a)*w+2048)/4096)
end
return table.freeze(Hash)
