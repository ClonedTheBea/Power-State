--!strict
local C = require(script.Parent.Components)
local Theme = require(script.Parent.Parent.Theme)
local Navigation = require(script.Parent.Parent.Navigation)
local Types = require(game:GetService("ReplicatedStorage").Shared.Types.ShellTypes)
local DrawerView = {}
function DrawerView.create(parent: Instance, preview: Types.Preview)
	local root = C.panel(parent, "Drawer")
	root.Visible = false
	root.ZIndex = 20
	root.Active = true
	local title = C.label(root, "More · navigation", 18, Theme.accent)
	title.Position = UDim2.fromOffset(12, 6)
	title.Size = UDim2.new(1, -72, 0, 44)
	local close = C.button(root, "×")
	close.Position = UDim2.new(1, -52, 0, 6)
	close.Size = UDim2.fromOffset(44, 44)
	local scroll = C.scroll(root, "Items")
	scroll.Position = UDim2.fromOffset(12, 56)
	scroll.Size = UDim2.new(1, -24, 1, -68)
	C.stack(scroll, 6)
	local buttons: { [string]: TextButton } = {}
	local items: { { object: GuiObject, mode: string } } = {}
	local order = 0
	local function heading(text: string, mode: string)
		order += 1
		local label = C.paragraph(scroll, text, Theme.accent)
		label.LayoutOrder = order
		table.insert(items, { object = label :: GuiObject, mode = mode })
	end
	local function add(id: string, text: string, mode: string)
		order += 1
		local button = C.button(scroll, text)
		button.Name = id
		button.LayoutOrder = order
		button.Size = UDim2.new(1, -8, 0, 48)
		buttons[id] = button
		table.insert(items, { object = button :: GuiObject, mode = mode })
	end
	local group = ""
	for _, destination in Navigation do
		if destination.group ~= group then group = destination.group; heading(group, "More") end
		add(destination.id, destination.label .. (if destination.id == "Map" then "" else " · Later"), "More")
	end
	heading("Utilities", "More")
	for _, id in { "Overview", "Assets", "Alerts", "Settings", "Profile", "Help" } do add(id, id, "More") end
	heading("Illustrative assets · not live data", "Assets")
	for _, node in preview.nodes do add("Asset_" .. node.id, node.name .. " · " .. node.kind, "Assets") end
	heading("Local text size · no account settings changed", "Settings")
	for _, percent in { 100, 125, 150 } do add("Text" .. percent, tostring(percent) .. "% text", "Settings") end
	heading("Geography · authored illustration, not live data. Buildings show types; cyan links are sample connections, not electricity flow.", "Layers")
	add("Geography", "Geography · selected", "Layers")
	add("Labels", "Labels · on", "Layers")
	add("Links", "Sample connections · on", "Layers")
	for _, name in { "Power flow", "Electricity demand", "Infrastructure condition", "National development", "Weather", "Seasonal events" } do
		add("Layer_" .. name, name .. " · unavailable", "Layers")
	end
	for _, item in root:GetDescendants() do if item:IsA("GuiObject") then item.ZIndex = 21 end end
	local function show(mode: string)
		root:SetAttribute("Mode", mode)
		title.Text = if mode == "More" then "More · navigation" elseif mode == "Assets" then "Illustrative assets" elseif mode == "Layers" then "Layers · illustration" else "Display settings"
		for _, item in items do item.object.Visible = item.mode == mode end
		scroll.CanvasPosition = Vector2.zero
		root.Visible = true
	end
	local function resizeText(scale: number)
		for _, button in buttons do button.TextSize = 16 * scale; button.Size = UDim2.new(1, -8, 0, 52 * scale) end
	end
	return { root = root, close = close, buttons = buttons, show = show, resizeText = resizeText }
end
return DrawerView
