--!strict
-- Dependency-free tests run against the actual pure modules, not copied formulas.
local Layout = require(game:GetService("ReplicatedStorage").Shared.Util.Layout)
local Transform = require(game:GetService("ReplicatedStorage").Shared.Util.MapTransform)
local ShellState = require(game:GetService("ReplicatedStorage").Shared.Util.ShellState)
return function()
	local count = 0
	local function check(condition: boolean, message: string)
		assert(condition, message)
		count += 1
	end
	for _, size in { { 360, 640 }, { 640, 360 }, { 768, 1024 }, { 1366, 768 }, { 360, 580 }, { 640, 300 } } do
		local width, height = size[1], size[2]
		local layout = Layout.resolve(width, height)
		for _, rect in { layout.header, layout.metrics, layout.navigation, layout.content, layout.footer } do
			check(rect.x >= 0 and rect.y >= 0 and rect.width > 0 and rect.height >= 0, "Nonnegative rectangles; merged metrics and absent ticker may have zero height")
			check(rect.x + rect.width <= width + 0.01 and rect.y + rect.height <= height + 0.01, "Safe root bounds")
		end
		check(layout.content.y >= layout.metrics.y + layout.metrics.height, "Map below metrics")
		if layout.compact then
			check(layout.content.y + layout.content.height <= layout.navigation.y, "Map above phone navigation")
			check(layout.content.y + layout.inspector.y >= layout.header.y + layout.header.height and layout.inspector.y + layout.inspector.height <= layout.content.height + 0.01, "Bottom sheet bounds")
			check(layout.inspector.height >= 160, "Detail sheet leaves usable scroll area")
		end
	end
	check(Layout.resolve(360, 640).metricColumns == 2, "Portrait has two-column metrics")
	check(Layout.resolve(640, 360).compact, "Landscape phone uses compact navigation")
	check(Layout.resolve(768, 1024).mode == "Tablet", "Tablet breakpoint")
	check(Layout.resolve(1366, 768).mode == "Desktop", "Desktop breakpoint")
	check(Layout.resolve(360, 580).content.height == 376, "Portrait map gains height with two primary KPIs")
	check(Layout.resolve(640, 300).content.height == 180, "Short landscape merges metrics for 180px map")
	check(Layout.resolve(640, 300).metrics.height == 0, "Short metrics live in Overview")
	check(Layout.resolve(1600, 840).railExpanded, "Wide desktop default expanded")
	check(not Layout.resolve(1366, 704).railExpanded, "Compact desktop default collapsed")
	for _, size in { { 360, 580 }, { 640, 300 }, { 768, 960 }, { 1024, 708 }, { 1366, 704 }, { 1920, 1020 } } do
		for _, stage in { "closed", "peek", "half", "expanded" } do
			for _, scale in { 1, 1.25, 1.5 } do
				local result = Layout.resolve(size[1], size[2], { inspectorStage = stage, textScale = scale })
				check(result.content.height > 0 and result.mapWidth > 0, "Positive workspace at all inspector/text states")
				check(result.inspector.y >= 0 and result.inspector.y + result.inspector.height <= result.content.height + 0.01, "Sheet stays in workspace")
				check(result.inspectorOverlay or result.mapWidth > (size[1] - 24) / 2, "Dock preserves map majority")
			end
		end
	end
	local state = ShellState.new()
	ShellState.select(state, "station")
	ShellState.closeInspector(state)
	check(state.selectedId == "station", "Close preserves selected asset")
	ShellState.navigate(state, "Government"); ShellState.navigate(state, "Map")
	check(state.selectedId == "station", "Navigation preserves selected asset")
	ShellState.cycleInspector(state)
	check(state.inspectorStage == "peek", "Explicit peek state")
	ShellState.cycleInspector(state)
	check(state.inspectorStage == "half", "Explicit half sheet")
	ShellState.cycleInspector(state)
	check(state.inspectorStage == "expanded", "Explicit expanded sheet")
	check(Transform.clampAxis(900, 400, 1200, 1) == 0, "Pan clamps near edge")
	check(Transform.clampAxis(-2000, 400, 1200, 1) == -800, "Pan clamps far edge")
	check(Transform.clampAxis(0, 1400, 1200, 1) == 100, "Small map is centered")
	local before, anchor, oldZoom, newZoom = -180, 200, 0.8, 1.3
	local after = Transform.zoomAt(before, oldZoom, newZoom, anchor)
	check(math.abs((anchor - before) / oldZoom - (anchor - after) / newZoom) < 0.00001, "Zoom preserves anchor")
	for _, zoom in { 0.55, 1, 1.8 } do
		for _, offset in { -10000, -400, 0, 10000 } do
			local result = Transform.clampAxis(offset, 360, 1200, zoom)
			check(result <= 0 and result >= 360 - 1200 * zoom, "Pan stays inside map")
		end
	end
	print(string.format("[Power State R2 Shell] PASS: %d assertions", count))
	return count
end
