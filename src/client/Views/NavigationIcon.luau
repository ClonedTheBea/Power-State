--!strict
-- Small code-native outline symbols; no external art or R3 terrain assets.
local C = require(script.Parent.Components)
local Theme = require(script.Parent.Parent.Theme)
local NavigationIcon = {}
local patterns: { [string]: { { number } } } = {
	Map = { { 2, 2, 6, 6 }, { 12, 2, 6, 6 }, { 2, 12, 6, 6 }, { 12, 12, 6, 6 } },
	Build = { { 9, 2, 2, 16 }, { 2, 9, 16, 2 } },
	Infrastructure = { { 2, 3, 5, 5 }, { 13, 12, 5, 5 }, { 5, 7, 2, 8 }, { 5, 13, 9, 2 } },
	Government = { { 2, 3, 16, 2 }, { 3, 7, 2, 8 }, { 9, 7, 2, 8 }, { 15, 7, 2, 8 }, { 2, 17, 16, 2 } },
	Staff = { { 3, 2, 4, 4 }, { 13, 2, 4, 4 }, { 2, 9, 6, 9 }, { 12, 9, 6, 9 } },
	Research = { { 7, 2, 6, 2 }, { 8, 4, 4, 7 }, { 4, 12, 12, 6 } },
	Events = { { 2, 4, 16, 14 }, { 4, 1, 2, 5 }, { 14, 1, 2, 5 }, { 6, 10, 8, 2 } },
	Company = { { 3, 2, 14, 16 }, { 7, 6, 6, 2 }, { 7, 11, 6, 2 } },
	News = { { 2, 3, 16, 14 }, { 5, 6, 10, 2 }, { 5, 11, 10, 2 } },
	Shop = { { 3, 7, 14, 11 }, { 7, 2, 6, 5 } },
}
function NavigationIcon.create(parent: Instance, id: string): Frame
	local root = C.frame(parent, "Icon")
	root.BackgroundTransparency = 1
	root.Size = UDim2.fromOffset(20, 20)
	local pattern: { { number } } = patterns[id] or {}
	for _, box in pattern do
		local part = C.frame(root, "Line", Theme.muted)
		part.Position = UDim2.fromOffset(box[1], box[2])
		part.Size = UDim2.fromOffset(box[3], box[4])
		if box[3] > 2 and box[4] > 2 then
			part.BackgroundTransparency = 1
			local stroke = Instance.new("UIStroke")
			stroke.Thickness = 2; stroke.Color = Theme.muted; stroke.Parent = part
		end
	end
	return root
end
return NavigationIcon
