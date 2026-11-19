--!strict
-- Operation-local scalar memoization only. Canonical traversal, bounds and every full-record
-- equality check remain in ProfileCodec; no persisted hash or cross-operation cache is trusted.
local Codec = require(script.Parent.Parent.Domain.ProfileCodec)
local Encoding = {}
function Encoding.new(scalar: (any) -> string): (any) -> string
	local cache: {[any]: string} = {}; local count = 0
	local function memo(value: any): string
		-- Lua table keys equate signed zero; a scalar encoder may distinguish it.
		if type(value) == "number" and value == 0 and 1 / value < 0 then return scalar(value) end
		local found = cache[value]
		if found then return found end
		local encoded = scalar(value)
		if count < 4096 then cache[value] = encoded; count += 1 end
		return encoded
	end
	return function(value: any): string return Codec.encode(value, memo) end
end
return table.freeze(Encoding)
