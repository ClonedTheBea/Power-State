--!strict
local C = require(script.Parent.Components)
local Theme = require(script.Parent.Parent.Theme)
local Types = require(game:GetService("ReplicatedStorage").Shared.Types.ShellTypes)
local Terrain = require(script.Parent.Map.TerrainRenderer)
local Art = require(script.Parent.Map.MapArt)
local Geometry = require(script.Parent.Map.MapGeometry)
local MapView = {}
function MapView.create(parent: Instance, preview: Types.Preview)
	assert(#preview.nodes <= 32 and #preview.links <= 64, "R3 fixture rendering budget exceeded")
	local root = C.panel(parent, "CountryMap")
	root.Size = UDim2.fromScale(1, 1); root.ClipsDescendants = true
	root:SetAttribute("PrimaryLayer", "Geography")
	root:SetAttribute("LabelsVisible", true); root:SetAttribute("LinksVisible", true)
	local viewport = C.frame(root, "Viewport", Theme.map)
	viewport.Size = UDim2.fromScale(1, 1); viewport.ClipsDescendants = true; viewport.Active = true
	local terrain = if preview.world then require(script.Parent.Map.GeneratedTerrain).create(viewport, preview.world) else Terrain.create(viewport)
	if preview.world then root:SetAttribute("WorldWidth",1024);root:SetAttribute("WorldHeight",1024)end
	local function layer(name: string, z: number): Frame
		local frame = C.frame(viewport, name)
		frame.BackgroundTransparency = 1; frame.Size = UDim2.fromScale(1, 1); frame.ZIndex = z
		return frame
	end
	local connections = layer("TransmissionConnections", 2)
	local infrastructure = layer("InfrastructureMarkers", 3)
	local labels = layer("MapLabels", 4)
	local overlays = layer("InteractionOverlays", 5)
	local byId: { [string]: Types.MapNode } = {}
	for _, node in preview.nodes do byId[node.id] = node end
	local linkFrames: { Frame } = {}
	for _, link in preview.links do
		assert(byId[link.from] and byId[link.to], "Unknown illustrative endpoint")
		local line = C.frame(connections, "IllustrativeLink", Theme.accent)
		line.AnchorPoint = Vector2.new(0.5, 0.5); line.BackgroundTransparency = 0.15
		line:SetAttribute("Illustrative", true)
		table.insert(linkFrames, line)
	end
	local markers: { [string]: TextButton } = {}
	local names: { [string]: TextLabel } = {}
	local clusters: { [string]: TextLabel } = {}
	for _, node in preview.nodes do
		local marker = C.button(infrastructure, "")
		marker.Name = "Marker_" .. node.id
		marker.Size = UDim2.fromOffset(44, 44); marker.AnchorPoint = Vector2.new(0.5, 0.5)
		marker:SetAttribute("AccessibleLabel", node.name .. " · " .. node.kind .. " · illustrative")
		if not Art.silhouette(marker, node.kind) then marker.Text = "?"; marker:SetAttribute("Fallback", true) end
		markers[node.id] = marker
		local cluster = C.label(marker, "", 14, Theme.onAccent)
		cluster.Name = "ClusterCount"; cluster.BackgroundTransparency = 0; cluster.BackgroundColor3 = Theme.accent
		cluster.Size = UDim2.fromOffset(24, 24); cluster.Position = UDim2.fromOffset(24, -4)
		cluster.TextXAlignment = Enum.TextXAlignment.Center; cluster.ZIndex = 4; cluster.Visible = false
		clusters[node.id] = cluster
		local label = C.label(labels, node.name, 14)
		label.Name = "Name_" .. node.id
		label.Size = UDim2.fromOffset(172, 28); label.AnchorPoint = Vector2.new(0.5, 0)
		label.BackgroundTransparency = 0; label.BackgroundColor3 = Theme.panel
		label.TextXAlignment = Enum.TextXAlignment.Center; C.corner(label, 4)
		names[node.id] = label
	end
	local selection = C.frame(overlays, "SelectionBrackets")
	selection.BackgroundTransparency = 1; selection.Size = UDim2.fromOffset(54, 54)
	selection.AnchorPoint = Vector2.new(0.5, 0.5); selection.Visible = false
	for _, p in { { 0, 0 }, { 44, 0 }, { 0, 44 }, { 44, 44 } } do
		Art.patch(selection, "Bracket", p[1], p[2], 10, 3, Theme.accent)
		Art.patch(selection, "Bracket", p[1], p[2], 3, 10, Theme.accent)
	end
	local locator = C.label(overlays, "", 14, Theme.accent)
	locator.BackgroundColor3 = Theme.panel; locator.BackgroundTransparency = 0
	locator.Position = UDim2.fromOffset(8, 56); locator.Size = UDim2.new(1, -16, 0, 28); locator.Visible = false
	local toolbar = C.panel(root, "MapControls")
	toolbar.AnchorPoint = Vector2.new(0, 1); toolbar.Position = UDim2.new(0, 8, 1, -8)
	toolbar.Size = UDim2.fromOffset(204, 48); toolbar.ZIndex = 6
	local zoomOut = C.button(toolbar, "−"); zoomOut.Position = UDim2.fromOffset(2, 2); zoomOut.Size = UDim2.fromOffset(44, 44)
	local reset = C.button(toolbar, "Recenter"); reset.Position = UDim2.fromOffset(50, 2); reset.Size = UDim2.fromOffset(104, 44)
	local zoomIn = C.button(toolbar, "+"); zoomIn.Position = UDim2.fromOffset(158, 2); zoomIn.Size = UDim2.fromOffset(44, 44)
	for _, button in { zoomOut, reset, zoomIn } do button.ZIndex = 7 end
	local cameraX, cameraY, cameraZoom = 0, 0, 1
	local selectedId: string? = nil
	local band = "regional"
	local function render(x: number, y: number, zoom: number)
		cameraX, cameraY, cameraZoom = x, y, zoom
		local size = viewport.AbsoluteSize
		-- Resolve the current renderer: isolated hybrid attachment replaces this callback.
		local renderTerrain: (number, number, number, Vector2) -> () = terrain.render
		renderTerrain(x, y, zoom, size); band = Geometry.band(band, zoom)
		connections.Visible = root:GetAttribute("LinksVisible") == true
		for index, link in preview.links do
			local a, b = byId[link.from], byId[link.to]
			local ax, ay, bx, by = x + a.x * zoom, y + a.y * zoom, x + b.x * zoom, y + b.y * zoom
			local dx, dy = bx - ax, by - ay
			local line = linkFrames[index]
			line.Visible = Geometry.segmentVisible(ax, ay, bx, by, size.X, size.Y)
			line.Position = UDim2.fromOffset((ax + bx) / 2, (ay + by) / 2)
			line.Size = UDim2.fromOffset(math.sqrt(dx * dx + dy * dy), 3)
			line.Rotation = math.deg(math.atan2(dy, dx))
		end
		selection.Visible = false; locator.Visible = false
		local occupied: { { point: Vector2, id: string, count: number } } = {}
		for id, marker in markers do marker:SetAttribute("Cluster", false); clusters[id].Visible = false end
		for _, node in preview.nodes do
			local px, py = x + node.x * zoom, y + node.y * zoom
			local marker = markers[node.id]
			marker.Position = UDim2.fromOffset(px, py)
			marker.Visible = Geometry.intersects(px - 22, py - 22, 44, 44, size.X, size.Y, 0)
			-- Stable first representative opens the Assets picker instead of guessing which
			-- overlapping asset was intended. Marker positions remain the exact world anchors.
			local overlap = false
			for _, entry in occupied do if math.abs(px - entry.point.X) < 44 and math.abs(py - entry.point.Y) < 44 then
				overlap = true; entry.count += 1
				markers[entry.id]:SetAttribute("Cluster", true)
				clusters[entry.id].Text = tostring(entry.count); clusters[entry.id].Visible = true
				break
			end end
			if overlap then marker.Visible = false else table.insert(occupied, { point = Vector2.new(px, py), id = node.id, count = 1 }) end
			marker:SetAttribute("UseAssetPicker", overlap)
			local label = names[node.id]
			label.Position = UDim2.fromOffset(math.clamp(px, 86, math.max(86, size.X - 86)), py + 27)
			label.Visible = marker.Visible and root:GetAttribute("LabelsVisible") == true and (band ~= "overview" or node.id == selectedId or node.id == "capital") and py + 55 < size.Y - 60 and py > 52
			for _, other in preview.nodes do if other.id ~= node.id then
				local ox, oy = x + other.x * zoom, y + other.y * zoom
				local lx = label.Position.X.Offset
				if math.abs(ox - lx) < 108 and oy + 22 > py + 27 and oy - 22 < py + 55 then label.Visible = false end
			end end
			if node.id == selectedId then
				selection.Position = UDim2.fromOffset(px, py)
				selection.Visible = marker.Visible
				locator.Text = node.name .. " · offscreen / overlap · use Locate"
				locator.Visible = not marker.Visible
			end
		end
		root:SetAttribute("ZoomBand", band)
	end
	if #root:GetDescendants() > 600 then
		root:Destroy()
		error("R3 total map descendant budget exceeded")
	end
	return { root = root, viewport = viewport, markers = markers, linkFrames = linkFrames, toolbar = toolbar, terrain = terrain,
		zoomIn = zoomIn, zoomOut = zoomOut, reset = reset, render = render,
		setSelected = function(id: string?) selectedId = id; render(cameraX, cameraY, cameraZoom) end,
		setOptions = function(showLabels: boolean, showLinks: boolean)
			root:SetAttribute("LabelsVisible", showLabels); root:SetAttribute("LinksVisible", showLinks)
			render(cameraX, cameraY, cameraZoom)
		end }
end
return MapView
