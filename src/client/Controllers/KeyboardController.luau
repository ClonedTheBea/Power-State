--!strict
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Scope = require(script.Parent.Parent.Util.Scope)
local Theme = require(script.Parent.Parent.Theme)
local StarterGui = game:GetService("StarterGui")
local C = require(script.Parent.Parent.Views.Components)
local ScrollNavigation = require(script.Parent.ScrollNavigation)
local KeyboardController = {}
function KeyboardController.attach(root: GuiObject, actions: { [TextButton]: () -> () }, getFocusRoot: () -> GuiObject, isMapFocus: () -> boolean, onBack: () -> (), mapInput: (InputObject) -> (), getOccluder: () -> GuiObject?)
	local scope = Scope.new()
	-- The shell owns Tab traversal. The Roblox menu/chat remain available.
	local playerListEnabled = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	local nativeNavigation = GuiService.GuiNavigationEnabled
	local autoSelection = GuiService.AutoSelectGuiEnabled
	GuiService.GuiNavigationEnabled = false
	GuiService.AutoSelectGuiEnabled = false
	local focusLabel = C.label(root, "", 16, Theme.text)
	focusLabel.Name = "FocusLabel"
	focusLabel.BackgroundTransparency = 0
	focusLabel.BackgroundColor3 = Theme.panel
	focusLabel.ZIndex = 40
	focusLabel.Visible = false
	local function isVisible(button: TextButton, focusRoot: GuiObject): boolean
		if not button:IsDescendantOf(focusRoot) or not button.Selectable then return false end
		-- A virtual/test safe root can exceed the rendered ScreenGui. The engine
		-- rejects focus outside that area even when every GuiObject is Visible.
		local gui = button:FindFirstAncestorWhichIsA("ScreenGui")
		if not gui or not gui.Enabled then return false end
		local p, s = button.AbsolutePosition, button.AbsoluteSize
		local a, b = gui.AbsolutePosition, gui.AbsoluteSize
		-- Scroll-list candidates remain reachable: focus() scrolls them into view.
		if (p.X + s.X <= a.X or p.Y + s.Y <= a.Y or p.X >= a.X + b.X or p.Y >= a.Y + b.Y)
			and not button:FindFirstAncestorWhichIsA("ScrollingFrame") then return false end
		local cover = getOccluder()
		if cover and cover.Parent and button:IsDescendantOf(cover.Parent) and not button:IsDescendantOf(cover) then
			local centre = button.AbsolutePosition + button.AbsoluteSize / 2
			local p, s = cover.AbsolutePosition, cover.AbsoluteSize
			if centre.X >= p.X and centre.X <= p.X + s.X and centre.Y >= p.Y and centre.Y <= p.Y + s.Y then return false end
		end
		local ancestor: Instance? = button
		while ancestor and ancestor ~= root.Parent do
			if ancestor:IsA("GuiObject") and not ancestor.Visible then return false end
			if ancestor:IsA("GuiObject") and ancestor.ClipsDescendants and not ancestor:IsA("ScrollingFrame") then
				local p, s = button.AbsolutePosition, button.AbsoluteSize
				local a, b = ancestor.AbsolutePosition, ancestor.AbsoluteSize
				if p.X + s.X <= a.X or p.Y + s.Y <= a.Y or p.X >= a.X + b.X or p.Y >= a.Y + b.Y then return false end
			end
			ancestor = ancestor.Parent
		end
		return true
	end
	local function candidates(): { TextButton }
		local result: { TextButton } = {}
		for button in actions do if isVisible(button, getFocusRoot()) then table.insert(result, button) end end
		table.sort(result, function(a: TextButton, b: TextButton): boolean
			if a.AbsolutePosition.Y ~= b.AbsolutePosition.Y then return a.AbsolutePosition.Y < b.AbsolutePosition.Y end
			if a.AbsolutePosition.X ~= b.AbsolutePosition.X then return a.AbsolutePosition.X < b.AbsolutePosition.X end
			return a:GetFullName() < b:GetFullName()
		end)
		return result
	end
	local function focus(button: TextButton)
		local scroll = button:FindFirstAncestorWhichIsA("ScrollingFrame")
		if scroll then
			local top = button.AbsolutePosition.Y - scroll.AbsolutePosition.Y
			local bottom = top + button.AbsoluteSize.Y
			if top < 0 then scroll.CanvasPosition += Vector2.new(0, top)
			elseif bottom > scroll.AbsoluteSize.Y then scroll.CanvasPosition += Vector2.new(0, bottom - scroll.AbsoluteSize.Y) end
		end
		if isVisible(button, getFocusRoot()) then GuiService.SelectedObject = button end
	end
	local function step(direction: number)
		local list = candidates()
		if #list == 0 then return end
		local index = 0
		for i, candidate in list do if candidate == GuiService.SelectedObject then index = i end end
		focus(list[(index - 1 + direction) % #list + 1])
	end
	local function scrollPage(direction: number): boolean
		if isMapFocus() then return false end
		return ScrollNavigation.page(getFocusRoot(), GuiService.SelectedObject, direction)
	end
	local function activate()
		local selected = GuiService.SelectedObject
		if selected and selected:IsA("TextButton") and selected:IsDescendantOf(root) and not isVisible(selected, getFocusRoot()) then
			GuiService.SelectedObject = nil
			return
		end
		if selected and selected:IsA("TextButton") and isVisible(selected, getFocusRoot()) then
			local action = actions[selected]
			if action then action() end
		end
	end
	scope.add(UserInputService.InputBegan:Connect(function(input)
		if UserInputService:GetFocusedTextBox() or GuiService.MenuIsOpen then return end
		if input.KeyCode == Enum.KeyCode.Tab then
			step(if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then -1 else 1)
		elseif input.KeyCode == Enum.KeyCode.Return then activate()
		elseif input.KeyCode == Enum.KeyCode.PageUp then scrollPage(-1)
		elseif input.KeyCode == Enum.KeyCode.PageDown then scrollPage(1) end
		if isMapFocus() then mapInput(input)
		else
			if input.KeyCode == Enum.KeyCode.ButtonL1 then scrollPage(-1)
			elseif input.KeyCode == Enum.KeyCode.ButtonR1 then scrollPage(1)
			elseif input.KeyCode == Enum.KeyCode.ButtonA then activate()
			elseif input.KeyCode == Enum.KeyCode.ButtonB then onBack()
			elseif input.KeyCode == Enum.KeyCode.DPadUp or input.KeyCode == Enum.KeyCode.DPadLeft then step(-1)
			elseif input.KeyCode == Enum.KeyCode.DPadDown or input.KeyCode == Enum.KeyCode.DPadRight then step(1) end
		end
	end))
	-- One navigation owner avoids duplicate native D-pad/A dispatch and modal escapes.
	-- CoreGui navigation is separate; the Roblox menu button is never intercepted.
	local lastSelected: GuiObject? = nil
	scope.add(GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
		if lastSelected then
			local stroke = lastSelected:FindFirstChildWhichIsA("UIStroke")
			if stroke then stroke.Color = Theme.borderInteractive; stroke.Thickness = 1 end
		end
		local selected = GuiService.SelectedObject
		lastSelected = selected
		focusLabel.Visible = false
		if selected and selected:IsDescendantOf(root) then
			local stroke = selected:FindFirstChildWhichIsA("UIStroke")
			if stroke then stroke.Color = Theme.focus; stroke.Thickness = 2 end
			if selected.Parent and selected.Parent.Name == "Rail" then
				focusLabel.Text = tostring(selected:GetAttribute("AccessibleLabel") or "")
				local width = math.min(280, root.AbsoluteSize.X - 16)
				focusLabel.Size = UDim2.fromOffset(width, 56)
				local relative = selected.AbsolutePosition - root.AbsolutePosition
				focusLabel.Position = UDim2.fromOffset(math.clamp(relative.X + selected.AbsoluteSize.X + 8, 8, math.max(8, root.AbsoluteSize.X - width - 8)), math.clamp(relative.Y, 8, math.max(8, root.AbsoluteSize.Y - 64)))
				focusLabel.Visible = true
			end
		end
	end))
	return { step = step, activate = activate, focus = focus, scrollPage = scrollPage,
		first = function() local list = candidates(); if list[1] then focus(list[1]) end end,
		valid = function(button: TextButton) return isVisible(button, getFocusRoot()) end,
		destroy = function()
			scope.destroy(); focusLabel:Destroy()
			GuiService.GuiNavigationEnabled = nativeNavigation
			GuiService.AutoSelectGuiEnabled = autoSelection
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, playerListEnabled)
		end }
end
return KeyboardController
