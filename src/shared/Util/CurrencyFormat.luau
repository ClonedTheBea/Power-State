--!strict
-- Presentation only: accepts integer minor units (100 per Credit), never settles money.
local CurrencyFormat = {}
local MAX_MINOR_UNITS = 10 ^ 15

local function grouped(whole: number): string
	local digits = string.format("%.0f", whole)
	local reversed = string.reverse(digits)
	local separated = string.gsub(reversed, "(%d%d%d)", "%1,")
	local result = string.gsub(string.reverse(separated), "^,", "")
	return result
end

function CurrencyFormat.format(minorUnits: number?, compact: boolean?): string
	if minorUnits == nil or minorUnits ~= minorUnits or minorUnits < 0
		or minorUnits > MAX_MINOR_UNITS or minorUnits % 1 ~= 0 then
		return "Unavailable"
	end
	local whole = math.floor(minorUnits / 100)
	if compact and whole >= 1000 then
		local divisor, suffix = 1000, "K"
		if whole >= 10 ^ 12 then divisor, suffix = 10 ^ 12, "T"
		elseif whole >= 10 ^ 9 then divisor, suffix = 10 ^ 9, "B"
		elseif whole >= 10 ^ 6 then divisor, suffix = 10 ^ 6, "M" end
		-- Truncate at two decimals: a preview never rounds up available funds.
		local hundredths = math.floor(minorUnits / divisor)
		local numberText = string.format("%d.%02d", math.floor(hundredths / 100), hundredths % 100)
		numberText = string.gsub(string.gsub(numberText, "0+$", ""), "%.$", "")
		return numberText .. suffix .. " Credits"
	end
	local fraction = minorUnits % 100
	return grouped(whole) .. (if fraction == 0 then "" else string.format(".%02d", fraction)) .. " Credits"
end

return table.freeze(CurrencyFormat)
