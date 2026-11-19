--!strict
-- Small code-native outline symbols; no external art or R3 terrain assets.
local C = require(script.Parent.Components)
local Theme = require(script.Parent.Parent.Theme)
local NavigationIcon = {}
local patterns: { [string]: { { number } } } = {
	Bank = { { 3, 2, 14, 4 }, { 3, 8, 14, 4 }, { 3, 14, 14, 4 } },
	Power = { { 10, 1, 3, 8 }, { 6, 8, 10, 3 }, { 7, 11, 3, 8 } },
	Alert = { { 9, 2, 2, 10 }, { 9, 16, 2, 2 } },
	Reserve = { { 2, 12, 3, 6 }, { 8, 7, 3, 11 }, { 14, 2, 3, 16 } },
	gas = { { 2, 11, 16, 7 }, { 3, 4, 3, 7 }, { 10, 1, 3, 10 } },
	wind = { { 9, 8, 2, 11 }, { 2, 7, 16, 2 }, { 9, 1, 2, 6 } },
	peak = { { 2, 9, 16, 9 }, { 5, 3, 3, 6 }, { 12, 3, 3, 6 } },
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
function NavigationIcon.create(parent: Instance, id: string, color: Color3?): Frame
	local root = C.frame(parent, "Icon")
	root.BackgroundTransparency = 1
	root.Size = UDim2.fromOffset(20, 20)
	if id == "Power" then
		local bolt=C.label(root,"ϟ",28,color or Theme.grid)
		bolt.Font=Theme.fontBold;bolt.Position=UDim2.fromOffset(1,-4);bolt.Size=UDim2.fromOffset(24,28)
		return root
	elseif id == "wind" then
		local mast=C.frame(root,"Mast",color or Theme.muted);mast.Position=UDim2.fromOffset(9,8);mast.Size=UDim2.fromOffset(2,12)
		for _,angle in {0,120,240} do
			local blade=C.frame(root,"Blade",color or Theme.muted);blade.AnchorPoint=Vector2.new(0,.5)
			blade.Position=UDim2.fromOffset(10,8);blade.Size=UDim2.fromOffset(9,2);blade.Rotation=angle
		end
		return root
	end
	local pattern: { { number } } = patterns[id] or {}
	for _, box in pattern do
		local part = C.frame(root, "Line", color or Theme.muted)
		part.Position = UDim2.fromOffset(box[1], box[2])
		part.Size = UDim2.fromOffset(box[3], box[4])
		if box[3] > 2 and box[4] > 2 then
			part.BackgroundTransparency = 1
			local stroke = Instance.new("UIStroke")
			stroke.Thickness = 2; stroke.Color = color or Theme.muted; stroke.Parent = part
		end
	end
	return root
end
return NavigationIcon
