--!strict
-- R1 currency regression adapted for R2's merged short-height Overview route.
return function(playerGui: PlayerGui)
	local root = playerGui:WaitForChild("PowerStateShell"):WaitForChild("SafeRoot") :: Frame
	local originalSize = root.Size
	local count = 0
	local function check(condition: boolean, message: string) assert(condition, message); count += 1 end
	local ok, problem = xpcall(function()
		for _, size in { { 360, 580 }, { 640, 300 }, { 768, 960 }, { 1366, 704 } } do
			root.Size = UDim2.fromOffset(size[1], size[2])
			for _ = 1, 5 do game:GetService("RunService").RenderStepped:Wait() end
			local metrics = root:WaitForChild("Metrics") :: Frame
			local bank = metrics:WaitForChild("BANK")
			local button = if metrics.Visible then bank:WaitForChild("BankDetails") :: TextButton else root:WaitForChild("Header"):WaitForChild("Overview") :: TextButton
			check(button.Selectable and button.AbsoluteSize.X >= 44 and button.AbsoluteSize.Y >= 44, "Exact-value route accessible")
			if metrics.Visible then
				local label = bank:WaitForChild("MetricValue") :: TextLabel
				check(label.TextBounds.X <= label.AbsoluteSize.X + 1, "Currency fits width")
				check(label.TextBounds.Y <= label.AbsoluteSize.Y + 1, "Currency fits height")
				check(string.find(label.Text, "Credits", 1, true) ~= nil, "Credits remains explicit")
			else
				check(root:GetAttribute("LayoutMode") == "Phone", "Short layout uses compact navigation")
				check(button.AbsoluteSize.Y >= 44, "Merged Overview target")
				check((root:WaitForChild("Content") :: Frame).AbsoluteSize.Y >= 160, "Merged currency gives map useful height")
			end
		end
	end, function(message: unknown): string return debug.traceback(tostring(message)) end)
	root.Size = originalSize
	assert(ok, tostring(problem))
	print(string.format("[Power State R1 Currency GUI] PASS: %d assertions", count))
	return count
end
