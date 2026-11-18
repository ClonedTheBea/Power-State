--!strict
local C = require(script.Parent.Components)
local Theme = require(script.Parent.Parent.Theme)
local FeedbackView = {}
function FeedbackView.create(parent: Instance)
	local root = C.panel(parent, "Feedback")
	root.Visible = false
	root.ZIndex = 30
	root.Active = true
	root.ClipsDescendants = true
	local title = C.label(root, "", 18)
	title.Position = UDim2.fromOffset(16, 8)
	title.Size = UDim2.new(1, -76, 0, 44)
	title.Font = Theme.fontBold
	local close = C.button(root, "×")
	close.Position = UDim2.new(1, -52, 0, 8)
	close.Size = UDim2.fromOffset(44, 44)
	local scroll = C.scroll(root, "Message")
	scroll.Position = UDim2.fromOffset(16, 60)
	scroll.Size = UDim2.new(1, -32, 1, -76)
	local body = C.paragraph(scroll, "", Theme.muted)
	for _, item in root:GetDescendants() do
		if item:IsA("GuiObject") then item.ZIndex = 31 end
	end
	return { root = root, close = close, updateText = function(message: string) body.Text = message end, resizeText = function(scale: number)
		title.TextSize = 18 * scale; body.TextSize = 16 * scale
		local titleHeight = if scale > 1 then 80 else 52
		title.Size = UDim2.new(1, -76, 0, titleHeight)
		scroll.Position = UDim2.fromOffset(16, titleHeight + 16)
		scroll.Size = UDim2.new(1, -32, 1, -titleHeight - 32)
	end, show = function(kind: string, heading: string, message: string)
		root:SetAttribute("BankOverview", false)
		title.Text = heading
		title.TextColor3 = if kind == "error" then Theme.error elseif kind == "loading" then Theme.warning else Theme.accent
		body.Text = message
		scroll.CanvasPosition = Vector2.zero
		root.Visible = true
	end }
end
return FeedbackView
