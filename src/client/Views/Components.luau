--!strict
local Theme = require(script.Parent.Parent.Theme)
local Components = {}

function Components.corner(parent: GuiObject, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
end

function Components.frame(parent: Instance, name: string, color: Color3?): Frame
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BorderSizePixel = 0
	frame.BackgroundColor3 = color or Theme.panel
	frame.Parent = parent
	return frame
end

function Components.panel(parent: Instance, name: string): Frame
	local frame = Components.frame(parent, name)
	Components.corner(frame, Theme.panelRadius)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.border
	stroke.Transparency = 0
	stroke.Parent = frame
	return frame
end

-- Explicit chrome treatment: never add gradients to every terrain/map object.
function Components.surface(parent: GuiObject)
 if not Theme.visualRedesign or parent:FindFirstChild("SurfaceDepth") then return end
 local gradient=Instance.new("UIGradient");gradient.Name="SurfaceDepth"
 gradient.Color=ColorSequence.new(Color3.new(1,1,1),Theme.surfaceShade);gradient.Rotation=90;gradient.Parent=parent
end
function Components.action(button: TextButton, kind: string)
 local primary=kind=="primary";local money=kind=="financial"
 button:SetAttribute("VisualKind",kind)
 button.BackgroundColor3=if primary then Theme.accent elseif money then Theme.credits else Theme.raised
 button.TextColor3=if primary or money then Theme.onAccent else Theme.text
 button.Font=Theme.fontBold
end
function Components.selected(button: TextButton, selected: boolean)
 button.BackgroundColor3=if selected then Theme.selected else Theme.panel
 local stroke=button:FindFirstChildOfClass("UIStroke")
 if stroke then stroke.Color=if selected then Theme.grid else Theme.border;stroke.Thickness=if selected then 2 else 1 end
end

function Components.label(parent: Instance, text: string, size: number?, color: Color3?): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextSize = size or Theme.bodySize
	label.TextColor3 = color or Theme.text
	label.Font = Theme.font
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.TextWrapped = true
	label.RichText = false
	label.Parent = parent
	return label
end

function Components.button(parent: Instance, text: string): TextButton
	local button = Instance.new("TextButton")
	button.Name = text
	button.Size = UDim2.fromOffset(100, Theme.controlHeight)
	button.BackgroundColor3 = Theme.raised
	button.BorderSizePixel = 0
	button.TextColor3 = Theme.text
	button.TextSize = Theme.bodySize
	button.Font = if Theme.visualRedesign then Enum.Font.GothamMedium else Theme.font
	button.Text = text
	button.TextWrapped = true
	button.AutoButtonColor = true
	button.Selectable = true
	button.Parent = parent
	Components.corner(button, Theme.buttonRadius)
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Theme.borderInteractive
	stroke.Parent = button
	local selection = Instance.new("Frame")
	selection.Name = "FocusOutline"
	selection.BackgroundTransparency = 1
	selection.Size = UDim2.new(1, 4, 1, 4)
	selection.Position = UDim2.fromOffset(-2, -2)
	Components.corner(selection, Theme.buttonRadius)
	local focusStroke = Instance.new("UIStroke")
	focusStroke.Color = Theme.focus
	focusStroke.Thickness = 2
	focusStroke.Parent = selection
	button.SelectionImageObject = selection
	button.Destroying:Once(function() selection:Destroy() end)
	return button
end

function Components.scroll(parent: Instance, name: string): ScrollingFrame
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = name
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = Theme.scrollBarWidth
	scroll.ScrollBarImageColor3 = Theme.muted
	scroll.CanvasSize = UDim2.new()
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.Parent = parent
	return scroll
end

function Components.stack(parent: Instance, gap: number): UIListLayout
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, gap)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = parent
	return list
end

function Components.paragraph(parent: Instance, text: string, color: Color3?): TextLabel
	local label = Components.label(parent, text, Theme.bodySize, color)
	label.Size = UDim2.new(1, -8, 0, 0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.TextYAlignment = Enum.TextYAlignment.Top
	return label
end
return Components
