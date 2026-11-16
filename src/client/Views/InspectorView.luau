--!strict
local C = require(script.Parent.Components)
local Theme = require(script.Parent.Parent.Theme)
local InspectorView = {}
function InspectorView.create(parent: Instance)
	local root = C.panel(parent, "Inspector")
	root.ZIndex = 10
	root.Active = true
	root.ClipsDescendants = true
	local title = C.label(root, "Region overview", 18)
	title.Font = Theme.fontBold
	title.TextWrapped = false
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.Position = UDim2.fromOffset(16, 8)
	title.Size = UDim2.new(1, -150, 0, 44)
	local expand = C.button(root, "Expand")
	expand.Name = "InspectorSize"
	expand.Position = UDim2.new(1, -132, 0, 8)
	expand.Size = UDim2.fromOffset(76, 44)
	local close = C.button(root, "×")
	close.Position = UDim2.new(1, -52, 0, 8)
	close.Size = UDim2.fromOffset(44, 44)
	local scroll = C.scroll(root, "Details")
	scroll.Position = UDim2.fromOffset(16, 60)
	scroll.Size = UDim2.new(1, -32, 1, -76)
	C.stack(scroll, 16)
	local tag = C.paragraph(scroll, "PRESENTATION PREVIEW", Theme.accent)
	tag.LayoutOrder = 1
	local body = C.paragraph(scroll, "Select a marker to inspect this illustrative country. Nothing on this map is simulated.", Theme.muted)
	body.LayoutOrder = 2
	local note = C.paragraph(scroll, "G  Generator\nS  Substation\nT  Settlement\n\nDrag to pan. Use + / − to zoom, or Recenter to return.", Theme.muted)
	note.LayoutOrder = 3
	local locate = C.button(scroll, "Locate on map")
	locate.Size = UDim2.new(1, -8, 0, 44)
	locate.LayoutOrder = 4
	locate.Visible = false
	local demos: { [string]: TextButton } = {}
	for index, kind in { "loading", "notice", "error" } do
		local button = C.button(scroll, "Preview " .. kind)
		button.Size = UDim2.new(1, -8, 0, 44)
		button.LayoutOrder = 4 + index
		button.Visible = false
		demos[kind] = button
	end
	for _, item in root:GetDescendants() do
		if item:IsA("GuiObject") then item.ZIndex = 11 end
	end
	return { root = root, close = close, expand = expand, locate = locate, title = title, tag = tag, body = body, note = note, demos = demos,
		apply = function(stage: string, scale: number)
			scroll.Visible = stage ~= "peek"
			expand.Text = if stage == "peek" then "Open" elseif stage == "half" then "Expand" else "Peek"
			title.TextSize = 16 * scale
			tag.TextSize = 16 * scale; body.TextSize = 16 * scale; note.TextSize = 16 * scale
			root:SetAttribute("Stage", stage)
		end,
		set = function(heading: string, category: string, description: string)
			title.Text = heading
			tag.Text = category
			body.Text = description
			scroll.CanvasPosition = Vector2.zero
		end }
end
return InspectorView
