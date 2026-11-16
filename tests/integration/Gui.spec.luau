--!strict
-- Real engine text/control bounds across the approved safe-root and text-size matrix.
return function(playerGui: PlayerGui)
	local root = playerGui:WaitForChild("PowerStateShell"):WaitForChild("SafeRoot") :: Frame
	local originalSize, originalScale = root.Size, root:GetAttribute("TextScale")
	local count = 0
	local function check(condition: boolean, message: string)
		assert(condition, message); count += 1
	end
	local function visible(object: GuiObject): boolean
		local ancestor: Instance? = object
		while ancestor and ancestor ~= root.Parent do
			if ancestor:IsA("GuiObject") and not ancestor.Visible then return false end
			ancestor = ancestor.Parent
		end
		return true
	end
	local ok, problem = xpcall(function()
		for _, scale in { 1, 1.25, 1.5 } do
			root:SetAttribute("TextScale", scale)
			for _, size in { { 360, 580 }, { 640, 300 }, { 768, 960 }, { 1024, 708 }, { 1366, 704 }, { 1920, 1020 } } do
				root.Size = UDim2.fromOffset(size[1], size[2])
				for _ = 1, 5 do game:GetService("RunService").RenderStepped:Wait() end
				local content = root:FindFirstChild("Content") :: Frame
				local metrics = root:FindFirstChild("Metrics") :: Frame
				local navigation = root:FindFirstChild("Navigation") :: Frame
				check(content.AbsoluteSize.Y >= (if scale == 1 then 160 else 120), "Usable map height")
				check(navigation.AbsoluteSize.Y >= 44, "Navigation touch height")
				for _, label in metrics:GetDescendants() do
					if label:IsA("TextLabel") and visible(label) then
						check(label.TextBounds.Y <= label.AbsoluteSize.Y + 1, "Metric height: " .. label.Text .. " at " .. size[1] .. " / " .. scale)
						check(label.TextBounds.X <= label.AbsoluteSize.X + 1, "Metric width: " .. label.Text .. " at " .. size[1] .. " / " .. scale)
					end
				end
				local inspector = content:FindFirstChild("Inspector") :: Frame
				local close = inspector:FindFirstChild("×") :: TextButton
				check(close.AbsoluteSize.X >= 44 and close.AbsoluteSize.Y >= 44, "Inspector close target")
				local details = inspector:FindFirstChild("Details") :: ScrollingFrame
				check(details.AbsoluteSize.Y >= 44, "Inspector body scroll area")
				for _, id in { "Map", "Build", "Government", "Events", "More" } do
					local button = navigation:FindFirstChild(id) :: TextButton
					if visible(button) then
						check(button.AbsoluteSize.X >= 44 and button.AbsoluteSize.Y >= 44, "Five bottom targets")
						check(button.TextBounds.X <= button.AbsoluteSize.X + 1 and button.TextBounds.Y <= button.AbsoluteSize.Y + 1, "Bottom label fit: " .. id)
					end
				end
			end
		end
	end, function(message: unknown): string return debug.traceback(tostring(message)) end)
	root.Size = originalSize; root:SetAttribute("TextScale", originalScale)
	assert(ok, tostring(problem))
	print(string.format("[Power State R2 GUI] PASS: %d engine layout assertions", count))
	return count
end