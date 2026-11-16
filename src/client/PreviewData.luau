--!strict
local Types = require(game:GetService("ReplicatedStorage").Shared.Types.ShellTypes)
local CurrencyFormat = require(game:GetService("ReplicatedStorage").Shared.Util.CurrencyFormat)
-- Frozen authored display strings/geometry. No simulation, balances, or server claims.
local preview: Types.Preview = {
	metrics = {
		{ label = "BANK", value = CurrencyFormat.format(10000000), currencyMinor = 10000000, detail = "Illustrative balance, not live funds" },
		{ label = "SUPPLY / DEMAND", value = "7 / 9 MW", detail = "Example demand" },
		{ label = "RELIABILITY", value = "92%", detail = "Example service" },
		{ label = "POPULATION", value = "10,000", detail = "Example residents" },
	},
	nodes = {
		{ id = "station", name = "Westhaven Station", kind = "Generator", x = 340, y = 320, description = "A placeholder gas station. Capacity, dispatch and fuel will arrive in a later phase." },
		{ id = "junction", name = "Central Substation", kind = "Substation", x = 575, y = 345, description = "An illustrative network junction. These lines do not transmit or calculate electricity." },
		{ id = "capital", name = "Newford", kind = "Settlement", x = 755, y = 250, description = "A sample capital marker. Residents and demand are not simulated in this preview." },
		{ id = "south", name = "Southbank", kind = "Settlement", x = 665, y = 535, description = "A sample riverside settlement. Selecting it only changes this local information panel." },
		{ id = "east", name = "Eastmere", kind = "Settlement", x = 930, y = 455, description = "An illustrative unconnected settlement. Construction and grid connectivity are outside P1." },
	},
	links = { { from = "station", to = "junction" }, { from = "junction", to = "capital" }, { from = "junction", to = "south" } },
}
for _, item in preview.metrics do table.freeze(item) end
for _, item in preview.nodes do table.freeze(item) end
for _, item in preview.links do table.freeze(item) end
table.freeze(preview.metrics)
table.freeze(preview.nodes)
table.freeze(preview.links)
return table.freeze(preview)
