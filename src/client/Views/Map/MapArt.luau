--!strict
local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Parent.Theme)
local Art = {}
function Art.shade(frame: Frame, light: Color3, shadow: Color3)
	frame.BackgroundColor3 = T.artWhite
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(light, shadow)
	gradient.Rotation = 35
	gradient.Parent = frame
end
function Art.peak(parent: Instance, x: number, y: number, width: number, color: Color3, shadow: Color3?)
	local clip = C.frame(parent, "MountainFacet")
	clip.BackgroundTransparency = 1; clip.ClipsDescendants = true
	clip.Position = UDim2.fromOffset(x, y); clip.Size = UDim2.fromOffset(width, width / 2)
	local facet = C.frame(clip, "Triangle", color)
	facet.AnchorPoint = Vector2.new(0.5, 0.5)
	facet.Position = UDim2.fromScale(0.5, 1)
	facet.Size = UDim2.fromOffset(width / math.sqrt(2), width / math.sqrt(2)); facet.Rotation = 45
	if shadow then Art.shade(facet, color, shadow) end
end
function Art.patch(parent: Instance, name: string, x: number, y: number, w: number, h: number, color: Color3, radius: number?, rotation: number?): Frame
	local frame = C.frame(parent, name, color)
	frame.Position = UDim2.fromOffset(x, y)
	frame.Size = UDim2.fromOffset(w, h)
	frame.Rotation = rotation or 0
	if radius then C.corner(frame, radius) end
	return frame
end
function Art.ribbon(parent: Instance, name: string, ax: number, ay: number, bx: number, by: number, width: number, color: Color3)
	local dx, dy = bx - ax, by - ay
	local line = Art.patch(parent, name, (ax + bx) / 2, (ay + by) / 2, math.sqrt(dx * dx + dy * dy) + width / 2, width, color, width / 2, math.deg(math.atan2(dy, dx)))
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	return line
end
function Art.tree(parent: Instance, x: number, y: number)
	Art.patch(parent, "Trunk", x + 9, y + 21, 4, 12, T.landShadow)
	Art.peak(parent, x + 3, y + 7, 30, T.forest)
	Art.peak(parent, x, y, 27, T.forestLight)
end
function Art.building(parent: Instance, x: number, y: number, w: number, h: number, industrial: boolean?)
	-- All buildings share a north-west lit roof, darker east wall and south face.
	Art.patch(parent, "EastWall", x + w - 5, y + 5, 10, h, T.buildingShadow)
	Art.patch(parent, "FrontWall", x, y + 7, w, h, T.building)
	if industrial then
		local roof = Art.patch(parent, "Roof", x - 2, y, w + 3, 10, T.stone, nil, -8)
		Art.shade(roof, T.stone, T.stoneShadow)
	else
		Art.peak(parent, x - 3, y - 4, w + 6, T.roof)
	end
	Art.patch(parent, "Windows", x + 4, y + 13, math.max(3, w - 10), 4, T.map)
end
function Art.silhouette(parent: Instance, kind: string): boolean
	if kind == "Generator" then
		Art.building(parent, 8, 17, 25, 14, true)
		Art.patch(parent, "Stack", 12, 6, 6, 20, T.stone)
		Art.patch(parent, "StackRim", 11, 5, 8, 3, T.snow)
		Art.patch(parent, "SecondStack", 25, 3, 5, 15, T.stone)
		Art.patch(parent, "StackBand", 25, 7, 5, 3, T.roof)
	elseif kind == "Substation" then
		Art.patch(parent, "Busbar", 8, 12, 28, 3, T.snow)
		for _, x in { 11, 29 } do
			Art.patch(parent, "Insulator", x, 10, 4, 22, T.stone)
			Art.patch(parent, "Transformer", x - 3, 25, 10, 9, T.building)
		end
	elseif kind == "Settlement" then
		Art.building(parent, 7, 16, 13, 15)
		Art.building(parent, 23, 9, 12, 22)
	else return false end
	return true
end
return Art
