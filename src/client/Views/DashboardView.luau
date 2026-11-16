--!strict
local C = require(script.Parent.Components)
local Theme = require(script.Parent.Parent.Theme)
local HeaderView = require(script.Parent.HeaderView)
local KpiStripView = require(script.Parent.KpiStripView)
local NavigationView = require(script.Parent.NavigationView)
local DrawerView = require(script.Parent.DrawerView)
local MapView = require(script.Parent.MapView)
local InspectorView = require(script.Parent.InspectorView)
local FeedbackView = require(script.Parent.FeedbackView)
local Layout = require(game:GetService("ReplicatedStorage").Shared.Util.Layout)
local Types = require(game:GetService("ReplicatedStorage").Shared.Types.ShellTypes)
local DashboardView = {}
local function place(object: GuiObject, rect: Layout.Rect)
	object.Position = UDim2.fromOffset(rect.x, rect.y)
	object.Size = UDim2.fromOffset(rect.width, rect.height)
end
function DashboardView.create(playerGui: PlayerGui, preview: Types.Preview)
	local gui = Instance.new("ScreenGui")
	gui.Name = "PowerStateShell"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 10
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	gui.ClipToDeviceSafeArea = true
	local background = C.frame(gui, "Backdrop", Theme.background)
	background.Position = UDim2.fromOffset(-200, -200)
	background.Size = UDim2.new(1, 400, 1, 400)
	local root = C.frame(gui, "SafeRoot", Theme.background)
	root.Size = UDim2.fromScale(1, 1)
	root:SetAttribute("TextScale", 1)
	local header = HeaderView.create(root)
	local kpis = KpiStripView.create(root, preview)
	local navigation = NavigationView.create(root)
	local content = C.frame(root, "Content")
	content.BackgroundTransparency = 1
	local map = MapView.create(content, preview)
	local inspector = InspectorView.create(content)
	local tools = C.frame(map.root, "ShellTools")
	tools.BackgroundTransparency = 1
	tools.ZIndex = 7
	tools.Position = UDim2.fromOffset(8, 8)
	tools.Size = UDim2.new(1, -16, 0, 44)
	local layers = C.button(tools, "Layers")
	layers.Size = UDim2.fromOffset(64, 44)
	local assetList = C.button(tools, "Assets")
	assetList.Position = UDim2.fromOffset(68, 0)
	assetList.Size = UDim2.fromOffset(64, 44)
	local mapFocus = C.button(tools, "Map focus")
	mapFocus.Position = UDim2.fromOffset(136, 0)
	mapFocus.Size = UDim2.fromOffset(96, 44)
	local details = C.button(tools, "Details")
	details.AnchorPoint = Vector2.new(1, 0)
	details.Position = UDim2.fromScale(1, 0)
	details.Size = UDim2.fromOffset(80, 44)
	local focusHint = C.label(map.root, "Map focus · Arrows / stick: pan · +/- / shoulders: zoom\nHome: recenter · A: asset list · B: UI focus", 14, Theme.text)
	focusHint.Name = "MapFocusHint"
	focusHint.BackgroundTransparency = 0
	focusHint.BackgroundColor3 = Theme.panel
	focusHint.Position = UDim2.fromOffset(8, 56)
	focusHint.Size = UDim2.new(1, -16, 0, 48)
	focusHint.ZIndex = 8
	focusHint.Visible = false
	for _, item in tools:GetDescendants() do if item:IsA("GuiObject") then item.ZIndex = 8 end end
	local page = C.panel(content, "DestinationPreview")
	page.Size = UDim2.fromScale(1, 1)
	page.Visible = false
	local pageScroll = C.scroll(page, "PageContent")
	pageScroll.Position = UDim2.fromOffset(16, 16)
	pageScroll.Size = UDim2.new(1, -32, 1, -32)
	C.stack(pageScroll, 16)
	local pageTitle = C.paragraph(pageScroll, "", Theme.text)
	pageTitle.Font = Theme.fontBold
	pageTitle.LayoutOrder = 1
	local pageTag = C.paragraph(pageScroll, "", Theme.accent)
	pageTag.LayoutOrder = 2
	local pageBody = C.paragraph(pageScroll, "", Theme.muted)
	pageBody.LayoutOrder = 3
	local pageBack = C.button(pageScroll, "Return to Grid")
	pageBack.Size = UDim2.new(1, -8, 0, 44)
	pageBack.LayoutOrder = 4
	local blocker = C.frame(root, "ModalInputBlocker", Theme.background)
	blocker.BackgroundTransparency = 0.35
	blocker.Size = UDim2.fromScale(1, 1)
	blocker.ZIndex = 19
	blocker.Active = true
	blocker.Visible = false
	local drawer = DrawerView.create(root, preview)
	local feedback = FeedbackView.create(root)
	local function applyLayout(layout: Layout.Result, route: string, stage: string)
		place(header.root, layout.header); place(kpis.root, layout.metrics)
		place(navigation.root, layout.navigation); place(content, layout.content)
		header.apply(layout); kpis.apply(layout); navigation.apply(layout, route)
		place(inspector.root, layout.inspector)
		inspector.apply(stage, layout.textScale)
		map.root.Size = UDim2.fromOffset(layout.mapWidth, layout.content.height)
		local scale = layout.textScale
		pageTitle.TextSize = 24 * scale
		pageTag.TextSize = 16 * scale; pageBody.TextSize = 16 * scale
		pageBack.TextSize = 16 * scale; pageBack.Size = UDim2.new(1, -8, 0, 44 * scale)
		drawer.root.Position = UDim2.fromOffset(layout.content.x, layout.content.y)
		drawer.root.Size = UDim2.fromOffset(math.min(440 * scale, layout.content.width), layout.content.height)
		drawer.resizeText(scale)
		local messageWidth = math.min(480 * scale, root.AbsoluteSize.X - 16)
		local messageHeight = math.min(300 * scale, root.AbsoluteSize.Y - 16)
		feedback.root.Position = UDim2.fromOffset((root.AbsoluteSize.X - messageWidth) / 2, (root.AbsoluteSize.Y - messageHeight) / 2)
		feedback.root.Size = UDim2.fromOffset(messageWidth, messageHeight)
		feedback.resizeText(scale)
		root:SetAttribute("LayoutMode", layout.mode)
		root:SetAttribute("CompactTools", layout.toolMode)
	end
	gui.Parent = playerGui
	return { gui = gui, root = root, header = header, kpis = kpis, navigation = navigation,
		map = map, inspector = inspector, drawer = drawer, feedback = feedback, blocker = blocker,
		layers = layers, assetList = assetList, mapFocus = mapFocus, focusHint = focusHint, details = details, page = page,
		pageTitle = pageTitle, pageTag = pageTag, pageBody = pageBody, pageBack = pageBack,
		applyLayout = applyLayout }
end
return DashboardView
