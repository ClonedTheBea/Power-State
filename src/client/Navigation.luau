--!strict
local Types = require(game:GetService("ReplicatedStorage").Shared.Types.ShellTypes)
local destinations: { Types.Destination } = {
	{ id = "Map", label = "Grid", shortLabel = "Grid", group = "Operations", phase = "R2 preview", description = "Explore the illustrative country. No electricity is simulated." },
	{ id = "Build", label = "Build", shortLabel = "Build", group = "Operations", phase = "P3", description = "Construction is not implemented. This route preserves your map and selection; no placement or purchase is available." },
	{ id = "Infrastructure", label = "Infrastructure", shortLabel = "Assets", group = "Operations", phase = "P2 / P3", description = "Owned infrastructure and real operating data arrive with simulation and construction. Use the illustrative asset list on Grid to explore the fixture." },
	{ id = "Government", label = "Government", shortLabel = "Gov.", group = "Strategy", phase = "P7", description = "Policies, projects, priorities, legislation and research are future systems. No policy or budget is active." },
	{ id = "Staff", label = "Staff", shortLabel = "Staff", group = "Strategy", phase = "P5b / P6b", description = "Inspection and maintenance teams are not implemented. No recruitment or assignment is available." },
	{ id = "Research", label = "Research", shortLabel = "R&D", group = "Strategy", phase = "P7", description = "Research belongs to the future Government system. This route does not create a separate research economy." },
	{ id = "Events", label = "Events", shortLabel = "Events", group = "Community", phase = "P11", description = "Event data is unavailable in this preview. No event, deadline or reward is running." },
	{ id = "Company", label = "Company", shortLabel = "Co.", group = "Community", phase = "P9", description = "Company profiles, achievements and rankings are not connected." },
	{ id = "News", label = "News", shortLabel = "News", group = "Community", phase = "P10", description = "No live news feed is connected. The sample ticker is a separate R4 task." },
	{ id = "Shop", label = "Energy Shop", shortLabel = "Shop", group = "Optional", phase = "R5 preview / later live milestone", description = "The Energy Shop is not built in R2. No products, prices, boosts or purchase controls are available." },
}
for _, destination in destinations do table.freeze(destination) end
return table.freeze(destinations)