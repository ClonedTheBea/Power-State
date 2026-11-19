--!strict
local C = require(script.Parent.Components)
local Icon = require(script.Parent.NavigationIcon)
local Theme = require(script.Parent.Parent.Theme)
local Layout = require(game:GetService("ReplicatedStorage").Shared.Util.Layout)
local Types = require(game:GetService("ReplicatedStorage").Shared.Types.ShellTypes)
local CurrencyFormat = require(game:GetService("ReplicatedStorage").Shared.Util.CurrencyFormat)
local KpiStripView = {}
function KpiStripView.create(parent: Instance, preview: Types.Preview)
	local root = C.frame(parent, "Metrics")
	root.BackgroundTransparency = 1
	local cards: { { root: Frame, label: TextLabel, value: TextLabel, button: TextButton, metric: Types.Metric, icon: Frame } } = {}
	local buttons: { [number]: TextButton } = {}
	for index, metric in preview.metrics do
		local card = C.panel(root, metric.label)
		C.surface(card)
		local accent=C.frame(card,"MetricAccent",if index==1 then Theme.credits elseif index==2 then Theme.grid else Theme.healthy)
		accent.Size=UDim2.new(1,-20,0,2);accent.Position=UDim2.fromOffset(10,0);accent.Visible=Theme.visualRedesign
		local symbol=({"Bank","Power","Alert","Reserve"})[index] or "Power"
		if string.find(metric.label,"HISTORY",1,true) then symbol="Events" end
		if string.find(metric.label,"CUSTOMERS",1,true) or string.find(metric.label,"POPULATION",1,true) then symbol="Staff" end
		local icon=Icon.create(card,symbol,if index==1 then Theme.credits else Theme.grid)
        icon.Name="MetricIcon";icon.Visible=false
        local label = C.label(card, metric.label, 14, Theme.muted)
		label.Name = "MetricLabel"
		local value = C.label(card, metric.value, 26)
		value.Name = "MetricValue"
		value.Font = Theme.fontBold
		if Theme.visualRedesign and index==1 then value.TextColor3=Theme.credits end
		local button = C.button(card, "")
		button.Name = if index == 1 then "BankDetails" else "MetricDetails"
		button.Size = UDim2.fromScale(1, 1)
		button.BackgroundTransparency = 1
		button.ZIndex = 2
		button:SetAttribute("AccessibleLabel", metric.label .. " details")
		buttons[index] = button
		table.insert(cards, { root = card, label = label, value = value, button = button, metric = metric, icon = icon })
	end
	local function apply(layout: Layout.Result)
		root.Visible = layout.metrics.height > 0
		local scale = layout.textScale
		local columns = layout.metricColumns
		local rows = math.ceil(layout.metricCount / columns)
		local width = (layout.metrics.width - 8 * (columns - 1)) / columns
		local height = (layout.metrics.height - 8 * (rows - 1)) / rows
		for index, card in cards do
			card.root.Visible = index <= layout.metricCount
			card.root.Position = UDim2.fromOffset((index - 1) % columns * (width + 8), math.floor((index - 1) / columns) * (height + 8))
			card.root.Size = UDim2.fromOffset(width, math.max(0, height))
			local inset=if Theme.visualRedesign and width>=280*scale then 48 else 10
            card.icon.Visible=inset>10;card.icon.Position=UDim2.new(0,16,.5,-10)
            card.label.Position = UDim2.fromOffset(inset, 4)
			card.label.Size = UDim2.new(1, -inset-10, 0, 20 * scale)
			card.label.TextSize = 14 * scale
			card.label.Text = if layout.compact and index == 2 then "SUPPLY / DEMAND" else card.metric.label
			card.value.Position = UDim2.fromOffset(inset, 24 * scale)
			card.value.Size = UDim2.new(1, -inset-10, 1, -26 * scale)
			card.value.TextSize = (if width < 230 * scale then 18 else 26) * scale
			if card.metric.currencyMinor ~= nil then
				card.value.Text = CurrencyFormat.format(card.metric.currencyMinor, width < 300 * scale)
			end
		end
	end
	return { root = root, cards = cards, buttons = buttons, apply = apply }
end
return KpiStripView
