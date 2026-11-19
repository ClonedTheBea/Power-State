--!strict
-- Paging complements native touch/wheel scrolling; it never synthesizes a swipe.
local ScrollNavigation = {}
local function visible(object: GuiObject, root: GuiObject): boolean
	if not object:IsDescendantOf(root) then return false end
	local at: Instance? = object
	while at do
		if at:IsA("GuiObject") and not at.Visible then return false end
		if at == root then return true end
		at = at.Parent
	end
	return false
end
function ScrollNavigation.target(root: GuiObject, selected: GuiObject?): ScrollingFrame?
	local function eligible(scroll: ScrollingFrame): boolean
		return visible(scroll, root) and scroll.ScrollingEnabled and scroll.AbsoluteWindowSize.Y > 0
			and scroll.AbsoluteCanvasSize.Y > scroll.AbsoluteWindowSize.Y + 1
	end
	if selected then
		local scroll = selected:FindFirstAncestorWhichIsA("ScrollingFrame")
		if scroll and eligible(scroll) then return scroll end
	end
	local best: ScrollingFrame? = nil
	for _, child in root:GetDescendants() do
		if child:IsA("ScrollingFrame") and eligible(child) then
			if not best or child.ZIndex > best.ZIndex
				or (child.ZIndex == best.ZIndex and child.AbsoluteWindowSize.X * child.AbsoluteWindowSize.Y
					> best.AbsoluteWindowSize.X * best.AbsoluteWindowSize.Y) then best = child end
		end
	end
	return best
end
function ScrollNavigation.page(root: GuiObject, selected: GuiObject?, direction: number): boolean
	assert(direction == -1 or direction == 1, "One page direction")
	local scroll = ScrollNavigation.target(root, selected)
	if not scroll then return false end
	local maximum = math.max(0, scroll.AbsoluteCanvasSize.Y - scroll.AbsoluteWindowSize.Y)
	scroll.CanvasPosition = Vector2.new(scroll.CanvasPosition.X,
		math.clamp(scroll.CanvasPosition.Y + direction * math.max(44, scroll.AbsoluteWindowSize.Y * .8), 0, maximum))
	-- Do not leave an invisible button armed after paging away from it.
	if selected and selected:IsDescendantOf(scroll) then game:GetService("GuiService").SelectedObject = nil end
	return true
end
return table.freeze(ScrollNavigation)
