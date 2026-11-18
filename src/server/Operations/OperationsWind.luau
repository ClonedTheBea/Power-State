--!strict
-- New namespaced recipe. Does not use or modify terrain/climate hash arithmetic.
local Model = require(script.Parent.FleetNetworkModel)
local Wind = {VERSION = 1}
function Wind.knot(seed: number, region: string, hour: number): number
	Model.integer(seed, 0, 2147483646); Model.integer(hour, 0, 16666668)
	assert(type(region) == "string" and #region > 0 and #region <= 32, "Bounded wind region")
	local hash = seed + 1
	for i = 1, #("operations.wind.v1|" .. region) do
		hash = (hash * 48271 + string.byte("operations.wind.v1|" .. region, i)) % 2147483647
	end
	hash = (hash + hour * 104729) % 2147483647
	for _ = 1, 3 do hash = (hash * 48271) % 2147483647 end
	return hash % 801
end
function Wind.potential(seed: number, region: string, step: number): number
	Model.integer(step, 0, 1000000060)
	local hour = math.floor(step / 60); local part = step % 60
	local a, b = Wind.knot(seed, region, hour), Wind.knot(seed, region, hour + 1)
	local permille = math.floor((a * (60 - part) + b * part) / 60)
	return math.floor(2000 * permille / 1000)
end
return table.freeze(Wind)
