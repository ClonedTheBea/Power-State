--!strict
-- Safe-root logical pixels; enlargement reflows chrome, never scales hit targets.
local Layout = {}
export type Rect = { x: number, y: number, width: number, height: number }
export type Options = { railExpanded: boolean?, inspectorStage: string?, textScale: number? }
export type Result = {
	mode: string, compact: boolean, short: boolean, header: Rect, metrics: Rect,
	navigation: Rect, content: Rect, footer: Rect, inspector: Rect,
	metricColumns: number, metricCount: number, inspectorOverlay: boolean,
	railExpanded: boolean, textScale: number, mapWidth: number, toolMode: boolean,
}
local function rect(x: number, y: number, width: number, height: number): Rect
	return { x = x, y = y, width = math.max(0, width), height = math.max(0, height) }
end
function Layout.resolve(width: number, height: number, options: Options?): Result
	local opts: Options = options or {}
	local scale = math.clamp(opts.textScale or 1, 1, 1.5)
	local short = height < 500
	local compact = width < 700 or short
	local wide = width >= 1440 and height >= 700
	local margin = if compact then 8 else 12
	local gap = if compact then 8 else 10
	local usable = math.max(0, width - 2 * margin)
	local headerHeight = math.ceil((if short then 44 elseif compact then 48 elseif wide then 64 else 56) * scale)
	local columns = if compact or width < 900 or (scale > 1 and width < 1100) then 2 else 4
	local metricCount = if compact then 2 else 4
	local metricHeight = if short then 0 else math.ceil((if compact then 64 elseif columns == 2 then 128 else 76) * scale)
	local navHeight = if compact then math.ceil((if short then 44 else 52) * scale) else 0
	local contentY = margin + headerHeight + gap + (if metricHeight > 0 then metricHeight + gap else 0)
	local contentBottom = height - margin - (if compact then navHeight + gap else 0)
	local toolMode = contentBottom - contentY < 160
	if toolMode then
		metricHeight = 0
		contentY = margin + headerHeight + gap
	end
	local expanded = not compact and width >= 1100 and (if opts.railExpanded == nil then wide else opts.railExpanded)
	local navWidth = if expanded then math.ceil(184 * scale) else 60
	local contentX = if compact then margin else margin + navWidth + gap
	local contentWidth = math.max(0, width - margin - contentX)
	local contentHeight = math.max(0, contentBottom - contentY)
	local stage = opts.inspectorStage or "closed"
	local panelWidth = math.min(math.ceil(300 * scale), contentWidth)
	local overlay = compact or width < 1300 or contentWidth - panelWidth - gap <= usable / 2
	local inspector: Rect
	if compact then
		local sheetHeight = if stage == "peek" then 56 elseif stage == "expanded" or short then contentHeight else math.max(180, math.floor(contentHeight * 0.45))
		sheetHeight = math.min(contentHeight, sheetHeight)
		inspector = rect(0, contentHeight - sheetHeight, contentWidth, sheetHeight)
	else
		inspector = rect(contentWidth - panelWidth, 0, panelWidth, contentHeight)
	end
	return {
		mode = if compact then "Phone" elseif width < 1100 then "Tablet" else "Desktop",
		compact = compact, short = short, toolMode = toolMode, textScale = scale, railExpanded = expanded,
		header = rect(margin, margin, usable, headerHeight),
		metrics = rect(margin, margin + headerHeight + gap, usable, metricHeight),
		navigation = if compact then rect(margin, height - margin - navHeight, usable, navHeight) else rect(margin, contentY, navWidth, contentHeight),
		content = rect(contentX, contentY, contentWidth, contentHeight),
		footer = rect(margin, height - margin, usable, 0),
		inspector = inspector, inspectorOverlay = overlay,
		metricColumns = columns, metricCount = metricCount,
		mapWidth = if stage ~= "closed" and not overlay then contentWidth - panelWidth - gap else contentWidth,
	}
end
return table.freeze(Layout)
