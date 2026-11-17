--!strict
-- This module and the approved URI are excluded from the production mapping.
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local Atlas = {}
-- The approved upload returned a Decal; its inspected ColorMap is this same-upload Image.
Atlas.UPLOAD_DECAL_ID = 105986918888502
Atlas.URI = "rbxassetid://86222383311104"
Atlas.TEST_UNIVERSE = 10776833313
function Atlas.assertEnvironment()
	assert(RunService:IsStudio() and RunService:IsClient() and game.GameId == Atlas.TEST_UNIVERSE,
		"Real atlas proof requires the approved Test universe in Studio client mode")
end
function Atlas.request(images: {ImageLabel})
	Atlas.assertEnvironment()
	assert(#images == 6, "Only the six approved sprite labels may be preloaded")
	for _,image in images do assert(image.Image == Atlas.URI, "Unexpected texture") end
	return function(done: (boolean) -> ())
		local alive, complete, success = true, false, false
		local started = os.clock()
		local heartbeat: RBXScriptConnection? = nil
		local function cancel()
			alive = false
			if heartbeat then heartbeat:Disconnect(); heartbeat = nil end
		end
		local function finish(result: boolean)
			if not alive then return end
			cancel()
			print(string.format("[R3.4 REAL load] ready=%s elapsed=%.3f ms; cache state unknown", tostring(result), (os.clock()-started)*1000))
			done(result)
		end
		heartbeat = RunService.Heartbeat:Connect(function()
			if not alive then return end
			if os.clock()-started >= 5 then
				print(string.format("[R3.4 REAL timeout] preloadComplete=%s success=%s",tostring(complete),tostring(success)))
				cancel(); return -- Loader owns the TimedOut state.
			end
			if not complete then return end
			if not success then finish(false); return end
			for _,image in images do
				if image.Parent == nil or image.Image ~= Atlas.URI then finish(false); return end
				if not image.IsLoaded then return end
			end
			finish(true)
		end)
		-- Engine work may outlive the five-second deadline; cancellation ignores late callbacks.
		task.spawn(function()
			local sawSuccess, failed = false, false
			local ok = pcall(function()
				ContentProvider:PreloadAsync(images, function(_id: string, status: Enum.AssetFetchStatus)
					if not alive then return end
					print("[R3.4 REAL fetch]",status.Name)
					if status == Enum.AssetFetchStatus.Success then sawSuccess = true else failed = true end
				end)
			end)
			if not alive then return end
			success = ok and sawSuccess and not failed
			complete = true
		end)
		return cancel
	end
end
return table.freeze(Atlas)
