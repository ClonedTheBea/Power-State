--!strict
local UserInputService = game:GetService("UserInputService")
local Scope = require(script.Parent.Parent.Util.Scope)
local Transform = require(game:GetService("ReplicatedStorage").Shared.Util.MapTransform)
local MapController = {}
type View = {
	root: Frame, viewport: Frame, toolbar: Frame, markers: { [string]: TextButton },
	zoomIn: TextButton, zoomOut: TextButton, reset: TextButton,
	render: (number, number, number) -> (),
}
function MapController.attach(view: View, onSelect: (string) -> (), canInteract: (() -> boolean)?, onCluster: (() -> ())?)
	local scope = Scope.new()
	local actions: { [TextButton]: () -> () } = {}
	local function bind(button: TextButton, action: () -> ())
		actions[button] = action
		scope.add(button.Activated:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Keyboard and not string.find(input.UserInputType.Name, "Gamepad", 1, true) and (not canInteract or canInteract()) then action() end
		end))
	end
	local x, y, zoom = 0, 0, 0.8
	local previousSize = view.viewport.AbsoluteSize
	local initialized = false
	local pointer: InputObject? = nil
	local lastPosition = Vector2.zero
	local travel = 0
	local suppressClickUntil = 0
	local function draw()
		local size = view.viewport.AbsoluteSize
		x = Transform.clampAxis(x, size.X, Transform.WORLD_WIDTH, zoom)
		y = Transform.clampAxis(y, size.Y, Transform.WORLD_HEIGHT, zoom)
		view.render(x, y, zoom)
		view.root:SetAttribute("CameraX", x)
		view.root:SetAttribute("CameraY", y)
		view.root:SetAttribute("CameraZoom", zoom)
	end
	local function recenter()
		local size = view.viewport.AbsoluteSize
		zoom = Transform.homeZoom(size.X, size.Y)
		x = (size.X - Transform.WORLD_WIDTH * zoom) / 2
		y = size.Y / 2 - 390 * zoom
		draw()
		initialized = true
		previousSize = size
	end
	local function changeZoom(delta: number)
		local nextZoom = math.clamp(zoom + delta, Transform.MIN_ZOOM, Transform.MAX_ZOOM)
		local anchor = view.viewport.AbsoluteSize / 2
		x = Transform.zoomAt(x, zoom, nextZoom, anchor.X)
		y = Transform.zoomAt(y, zoom, nextZoom, anchor.Y)
		zoom = nextZoom
		draw()
	end
	scope.add(view.viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local size = view.viewport.AbsoluteSize
		if size.X <= 0 or size.Y <= 0 then return end
		if not initialized then recenter(); return end
		-- Preserve the world point at the viewport centre, subject only to edge clamps.
		x += (size.X - previousSize.X) / 2
		y += (size.Y - previousSize.Y) / 2
		previousSize = size
		draw()
	end))
	scope.add(view.viewport.InputBegan:Connect(function(input)
		if pointer or not view.root.Visible or (canInteract and not canInteract()) then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			pointer = input
			lastPosition = Vector2.new(input.Position.X, input.Position.Y)
			travel = 0
		end
	end))
	scope.add(UserInputService.InputChanged:Connect(function(input)
		local current = pointer
		if not current then return end
		if canInteract and not canInteract() then pointer = nil; return end
		if input == current or (current.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement) then
			local position = Vector2.new(input.Position.X, input.Position.Y)
			local delta = position - lastPosition
			lastPosition = position
			travel += delta.Magnitude
			if travel > 6 then suppressClickUntil = os.clock() + 0.25 end
			x += delta.X
			y += delta.Y
			draw()
		end
	end))
	scope.add(UserInputService.InputEnded:Connect(function(input)
		if input == pointer then pointer = nil end
	end))
	scope.add(UserInputService.WindowFocusReleased:Connect(function() pointer = nil end))
	scope.add(view.root:GetPropertyChangedSignal("Visible"):Connect(function() pointer = nil end))
	scope.add(view.viewport.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel and (not canInteract or canInteract()) then changeZoom(input.Position.Z * 0.1) end
	end))
	bind(view.zoomIn, function() changeZoom(0.15) end)
	bind(view.zoomOut, function() changeZoom(-0.15) end)
	bind(view.reset, recenter)
	for id, marker in view.markers do
		bind(marker, function()
			if os.clock() >= suppressClickUntil then
				if marker:GetAttribute("Cluster") == true and onCluster then onCluster() else onSelect(id) end
			end
		end)
	end
	return { destroy = scope.destroy, actions = actions, recenter = recenter, changeZoom = changeZoom,
		locate = function(worldX: number, worldY: number)
			local size = view.viewport.AbsoluteSize
			x = size.X / 2 - worldX * zoom; y = size.Y / 2 - worldY * zoom; draw()
		end, pan = function(dx: number, dy: number)
		x += dx; y += dy; draw()
	end }
end
return MapController
