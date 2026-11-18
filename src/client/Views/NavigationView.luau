--!strict
local C = require(script.Parent.Components)
local Theme = require(script.Parent.Parent.Theme)
local Navigation = require(script.Parent.Parent.Navigation)
local Layout = require(game:GetService("ReplicatedStorage").Shared.Util.Layout)
local NavigationIcon = require(script.Parent.NavigationIcon)
local NavigationView = {}
function NavigationView.create(parent: Instance)
	local root = C.frame(parent, "Navigation")
	root.BackgroundTransparency = 1
	local rail = C.scroll(root, "Rail")
	rail.Size = UDim2.new(1, 0, 1, -52)
	local collapse = C.button(root, "Expand")
	collapse.Name = "ToggleRail"
	collapse.Position = UDim2.new(0, 0, 1, -44)
	collapse.Size = UDim2.new(1, 0, 0, 44)
	local buttons: { [string]: TextButton } = {}
	local headings: { [string]: TextLabel } = {}
	local labels: { [string]: TextLabel } = {}
	local icons: { [string]: Frame } = {}
	local markers: { [string]: Frame } = {}
	for _, destination in Navigation do
		if not headings[destination.group] then
			headings[destination.group] = C.label(rail, destination.group, 14, Theme.muted)
		end
		local button = C.button(rail, destination.label)
		button.Name = destination.id
		button:SetAttribute("AccessibleLabel", destination.label .. (if destination.id == "Map" then "" else " · Later"))
		buttons[destination.id] = button
		button.Text = ""
		icons[destination.id] = NavigationIcon.create(button, destination.id)
		labels[destination.id] = C.label(button, destination.label, 14)
		local marker = C.frame(button, "SelectedMarker", Theme.accent)
		marker.Size = UDim2.new(0, 3, 1, -12); marker.Position = UDim2.fromOffset(0, 6)
		markers[destination.id] = marker
	end
	local bottom: { [string]: TextButton } = {}
	for _, id in { "Map", "Build", "Government", "Events", "More" } do
		local label = if id == "Map" then "Grid" elseif id == "Government" then "Gov." else id
		local button = C.button(root, label)
		button.Name = id
		button:SetAttribute("AccessibleLabel", if id == "Government" then "Government" else label)
		bottom[id] = button
	end
	local function apply(layout: Layout.Result, route: string)
		rail.Visible = not layout.compact
		collapse.Visible = not layout.compact
		collapse.Text = if layout.railExpanded then "Collapse" else "More"
		collapse.TextSize = 12 * layout.textScale
		collapse:SetAttribute("AccessibleLabel", if layout.railExpanded then "Collapse navigation" else "Expand navigation / full destination labels")
		local y = 0
		local group = ""
		for _, destination in Navigation do
			if destination.group ~= group then
				group = destination.group
				local heading = headings[group]
				heading.Visible = layout.railExpanded
				heading.Position = UDim2.fromOffset(6, y)
				heading.Size = UDim2.new(1, -12, 0, 26)
				if layout.railExpanded then y += 30 else y += 6 end
			end
			local button = buttons[destination.id]
			button.Position = UDim2.fromOffset(2, y)
			local height = math.ceil(56 * layout.textScale)
			button.Size = UDim2.new(1, -8, 0, height)
			button.TextSize = (if layout.railExpanded then 14 else 12) * layout.textScale
			local label = labels[destination.id]
			label.TextSize = (if layout.railExpanded then 14 else 10) * layout.textScale
			label.Text = if layout.railExpanded then destination.label .. (if destination.id ~= "Map" then " · Later" else "") else destination.shortLabel
			local override = button:GetAttribute(if layout.railExpanded then "LabelOverride" else "ShortLabelOverride")
			if type(override) == "string" then label.Text = override end
			label.Position = if layout.railExpanded then UDim2.fromOffset(34, 2) else UDim2.fromOffset(0, 29)
			label.Size = if layout.railExpanded then UDim2.new(1, -40, 1, -4) else UDim2.new(1, 0, 1, -30)
			label.TextXAlignment = if layout.railExpanded then Enum.TextXAlignment.Left else Enum.TextXAlignment.Center
			icons[destination.id].Position = if layout.railExpanded then UDim2.new(0, 7, 0.5, -10) else UDim2.new(0.5, -10, 0, 6)
			markers[destination.id].Visible = route == destination.id
			label.TextColor3 = if route == destination.id then Theme.accent else Theme.muted
			button.TextColor3 = if route == destination.id then Theme.accent else Theme.muted
			button.BackgroundColor3 = if route == destination.id then Theme.raised else Theme.panel
			button:SetAttribute("Selected", route == destination.id)
			y += height + 6
		end
		for index, id in { "Map", "Build", "Government", "Events", "More" } do
			local button = bottom[id]
			button.Visible = layout.compact
			button.Position = UDim2.new((index - 1) / 5, 2, 0, 0)
			button.Size = UDim2.new(1 / 5, -4, 1, 0)
			button.TextSize = 14 * layout.textScale
			button.TextColor3 = if route == id then Theme.accent else Theme.text
			button:SetAttribute("Selected", route == id)
		end
	end
	return { root = root, buttons = buttons, bottom = bottom, collapse = collapse, apply = apply }
end
return NavigationView
