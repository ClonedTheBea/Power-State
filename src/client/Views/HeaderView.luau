--!strict
local C = require(script.Parent.Components)
local Theme = require(script.Parent.Parent.Theme)
local Layout = require(game:GetService("ReplicatedStorage").Shared.Util.Layout)
local HeaderView = {}
function HeaderView.create(parent: Instance)
	local root = C.frame(parent, "Header")
	root.BackgroundTransparency = 1
	local overview = C.button(root, "")
	overview.Name = "Overview"
	overview.BackgroundTransparency = if Theme.visualRedesign then 0 else 1
	C.surface(overview)
	local mark=C.label(overview,"ϟ",38,Theme.grid);mark.Name="AuthorityMark";mark.Font=Theme.fontBold
	mark.Position=UDim2.fromOffset(8,0);mark.Size=UDim2.new(0,36,1,0);mark.Visible=Theme.visualRedesign
	local brand=C.label(overview,"POWER STATE",28);brand.Font=Theme.fontBold;brand.Name="Brand";brand.Visible=false
    local strap=C.label(overview,"N A T I O N A L   G R I D",11,Theme.grid);strap.Name="BrandCaption";strap.Visible=false
    local identity = C.label(overview, "POWER STATE", 18)
	identity.Font = Theme.fontBold
	identity.Position = UDim2.fromOffset(if Theme.visualRedesign then 50 else 8, 2)
	identity.Size = UDim2.new(1, if Theme.visualRedesign then -58 else -16, 0.5, -2)
	identity.TextWrapped = false
	identity.TextTruncate = Enum.TextTruncate.AtEnd
	local status = C.label(overview, "Westhaven · Illustrative grid", 14, Theme.muted)
	status.Position = UDim2.new(0, if Theme.visualRedesign then 50 else 8, 0.5, 0)
	status.Size = UDim2.new(1, if Theme.visualRedesign then -58 else -16, 0.5, -2)
	status.TextWrapped = false
	status.TextTruncate = Enum.TextTruncate.AtEnd
	local buttons: { [string]: TextButton } = {}
	for _, id in { "Alerts", "Help", "Settings", "Profile" } do
		buttons[id] = C.button(root, id)
	end
	local function apply(layout: Layout.Result)
		local scale = layout.textScale
		local narrow = layout.header.width < 900
		local ids: { string } = if narrow then { "Alerts", "Help" } else { "Alerts", "Help", "Settings", "Profile" }
		for _, button in buttons do button.Visible = false end
		local width = math.ceil((if narrow then 48 else 76) * scale)
		for index, id in ids do
			local button = buttons[id]
			button.Visible = true
			button.TextSize = (if narrow then 12 else 14) * scale
			button.Size = UDim2.fromOffset(width, layout.header.height)
			button.Position = UDim2.new(1, -(#ids - index + 1) * (width + 6) + 6, 0, 0)
		end
		local available=layout.header.width - #ids * (width + 6)
        local branded=Theme.visualRedesign and available>=760*scale
        overview.Size = UDim2.fromOffset(if branded then available-12 else math.min(available,540*scale), layout.header.height)
        brand.Visible=branded;strap.Visible=branded
        overview.BackgroundTransparency=if branded or not Theme.visualRedesign then 1 else 0
        local border=overview:FindFirstChildOfClass("UIStroke");if border then border.Transparency=if branded then 1 else 0 end
        brand.Position=UDim2.fromOffset(50,0);brand.Size=UDim2.fromOffset(270*scale,38*scale);brand.TextSize=28*scale
        strap.Position=UDim2.fromOffset(52,38*scale);strap.Size=UDim2.fromOffset(270*scale,18*scale)
        local inset=if branded then 350*scale elseif Theme.visualRedesign then 50 else 8
        identity.Position=UDim2.fromOffset(inset,2);identity.Size=UDim2.new(1,-inset-8,.5,-2)
        status.Position=UDim2.new(0,inset,.5,0);status.Size=UDim2.new(1,-inset-8,.5,-2)
		identity.TextSize = (if layout.compact then 16 else 18) * scale
		status.TextSize = (if layout.compact then 12 else 14) * scale
		identity.Text = if layout.metrics.height == 0 then "100K Credits · 7 / 9 MW" else "POWER STATE"
		status.Text = if layout.metrics.height == 0 then "Preview · Overview" elseif narrow then "Illustrative grid · Overview" else "Westhaven · Illustrative grid · Overview"
	end
	return { root = root, brand=brand, identity = identity, status = status, overview = overview, buttons = buttons, apply = apply }
end
return HeaderView
