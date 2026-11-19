--!strict
local C = require(script.Parent.Parent.Views.Components)
local Theme = require(script.Parent.Parent.Theme)
local View = {}
function View.create(app: any): any
	local v = app.view
	local panel = C.scroll(v.page, "OperationsConsole"); panel.Size = UDim2.fromScale(1, 1)
	C.stack(panel, 10)
	local title = C.paragraph(panel, "OPERATIONS TRAINING · temporary Test country", Theme.accent); title.LayoutOrder = 1
	local guide = C.paragraph(panel, "Your task: keep customers supplied as demand rises and wind falls. Gas is flexible supply; wind is cheap but variable; the peaker covers shortages at higher cost. Stop Play discards this training country.")
	guide.LayoutOrder = 2
	local status = C.paragraph(panel, "Waiting for authoritative state"); status.LayoutOrder = 3
	local totals = C.paragraph(panel, ""); totals.LayoutOrder = 9
	local fleet = {}
	for index, id in {"gas", "wind", "peak"} do
		local card = C.panel(panel, id); card.Size = UDim2.new(1, -8, 0, 150); card.LayoutOrder = 4 + index
		local text = C.label(card, "", 14); text.Position = UDim2.fromOffset(8, 4); text.Size = UDim2.new(1, -16, 0, 94); text.TextYAlignment = Enum.TextYAlignment.Top
		local toggle = C.button(card, "Switch On"); toggle.Position = UDim2.fromOffset(8, 98); toggle.Size = UDim2.new(1, -198, 0, 44)
		local minus = C.button(card, "−"); minus.Position = UDim2.new(1, -182, 0, 98); minus.Size = UDim2.fromOffset(44, 44)
		local plus = C.button(card, "+"); plus.Position = UDim2.new(1, -134, 0, 98); plus.Size = UDim2.fromOffset(44, 44)
		local locate = C.button(card, "Locate"); locate.Position = UDim2.new(1, -86, 0, 98); locate.Size = UDim2.fromOffset(78, 44)
		minus:SetAttribute("AccessibleLabel", id .. " output cap minus 100 kW")
		plus:SetAttribute("AccessibleLabel", id .. " output cap plus 100 kW")
		local function fit()
			local width = math.max(200, text.AbsoluteSize.X)
			local bounds = game:GetService("TextService"):GetTextSize(text.Text, text.TextSize, text.Font, Vector2.new(width, 10000))
			local height = math.max(78, math.ceil(bounds.Y) + 8)
			text.Size = UDim2.new(1, -16, 0, height)
			card.Size = UDim2.new(1, -8, 0, height + 60)
			for _, button in {toggle, minus, plus, locate} do button.Position = UDim2.new(button.Position.X.Scale, button.Position.X.Offset, 0, height + 8) end
		end
		text:GetPropertyChangedSignal("Text"):Connect(fit)
		text:GetPropertyChangedSignal("TextSize"):Connect(fit)
		local lastWidth = 0
		card:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			if card.AbsoluteSize.X ~= lastWidth then lastWidth = card.AbsoluteSize.X; fit() end
		end)
		fleet[id] = {card = card, text = text, toggle = toggle, minus = minus, plus = plus, locate = locate}
	end
	local forecast = C.paragraph(panel, ""); forecast.LayoutOrder = 8
	local alerts = C.paragraph(panel, "", Theme.warning); alerts.LayoutOrder = 4
	local retry = C.button(panel, "Retry suspended operation"); retry.Size = UDim2.new(1, -8, 0, 44); retry.LayoutOrder = 10
	local back = C.button(panel, "View grid"); back.Size = UDim2.new(1, -8, 0, 44); back.LayoutOrder = 11
	local leave = C.button(panel, "Return to First Playable"); leave.Size = UDim2.new(1, -8, 0, 44); leave.LayoutOrder = 12
	return {panel = panel, status = status, totals = totals, fleet = fleet, forecast = forecast, alerts = alerts, retry = retry, back = back, leave = leave}
end
return table.freeze(View)
