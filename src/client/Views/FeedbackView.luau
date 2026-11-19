--!strict
local C = require(script.Parent.Components)
local Theme = require(script.Parent.Parent.Theme)
local DetailRows=require(script.Parent.DetailRows)
local FeedbackView = {}
function FeedbackView.create(parent: Instance)
	local metrics = {textMeasurements = 0}
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
	local details=if Theme.visualRedesign then DetailRows.create(scroll,metrics) else {active=function()return false end,clear=function()end,resize=function(_scale:number)end,set=function(_message:string)end}
	C.surface(root)
	-- AutomaticSize/TextBounds can report only the clipped text viewport. Measure
	-- the complete wrapped string so every detail remains reachable at large text.
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.None
	body.AutomaticSize = Enum.AutomaticSize.None
	local function resizeCanvas()
		if details.active() then return end
		metrics.textMeasurements += 1
		local width = math.max(1, scroll.AbsoluteSize.X - 8)
		local bounds = game:GetService("TextService"):GetTextSize(body.Text, body.TextSize, body.Font, Vector2.new(width, 100000))
		body.Size = UDim2.new(1, -8, 0, bounds.Y + 4)
		scroll.CanvasSize = UDim2.fromOffset(0, bounds.Y + 12)
	end
	local connections = {
		body:GetPropertyChangedSignal("Text"):Connect(resizeCanvas),
		body:GetPropertyChangedSignal("TextSize"):Connect(resizeCanvas),
		scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeCanvas),
	}
	root.Destroying:Once(function() for _, connection in connections do connection:Disconnect() end end)
	resizeCanvas()
	for _, item in root:GetDescendants() do
		if item:IsA("GuiObject") then item.ZIndex = 31 end
	end
	return { root = root, close = close, metrics = metrics, updateText = function(message: string) details.clear();body.Visible=true;if body.Text ~= message then body.Text = message else resizeCanvas() end end,
		updateDetails = function(message: string)
		 if not Theme.visualRedesign then if body.Text~=message then body.Text=message end;return end
		 if body.Text~=message or not details.active() then details.set(message);body.Text=message end;body.Visible=false
		end, resizeText = function(scale: number)
		title.TextSize = 18 * scale; body.TextSize = 16 * scale;details.resize(scale)
		local titleHeight = if scale > 1 then 80 else 52
		title.Size = UDim2.new(1, -76, 0, titleHeight)
		scroll.Position = UDim2.fromOffset(16, titleHeight + 16)
		scroll.Size = UDim2.new(1, -32, 1, -titleHeight - 32)
	end, show = function(kind: string, heading: string, message: string)
		details.clear();body.Visible=true
		root:SetAttribute("OperationsDetail", nil)
		root:SetAttribute("BankOverview", false)
		root:SetAttribute("ReinforcementReview", false)
		title.Text = heading
		title.TextColor3 = if kind == "error" then Theme.error elseif kind == "loading" then Theme.warning else Theme.accent
		body.Text = message;resizeCanvas()
		scroll.CanvasPosition = Vector2.zero
		root.Visible = true
	end }
end
return FeedbackView
