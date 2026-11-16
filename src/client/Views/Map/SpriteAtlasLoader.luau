--!strict
-- Injected readiness protocol only. No asset ID, download, retry loop or texture claim.
local Loader = {}
export type Request = ((boolean) -> ()) -> (() -> ())
function Loader.new(request: Request?, clock: (() -> number)?)
	local now = clock or os.clock
	local state = "Unconfigured"
	local token, deadline = 0, 0
	local attempted, destroyed = false, false
	local cancel: (() -> ())? = nil
	local function release()
		local fn = cancel; cancel = nil
		if fn then pcall(fn) end
	end
	local function expire()
		if state == "Loading" and now() >= deadline then
			token += 1; state = "TimedOut"; release()
		end
	end
	return {
		state = function(): string expire(); return state end,
		start = function()
			if destroyed or attempted or not request then return end
			attempted = true; token += 1
			local current = token
			state = "Loading"; deadline = now()+5
			local ok, result = pcall(request, function(success: boolean)
				expire()
				if destroyed or current ~= token or state ~= "Loading" then return end
				state = if success == true then "Ready" else "Failed"
				release()
			end)
			if not ok then state = "Failed"; token += 1
			elseif type(result) == "function" then
				if state == "Loading" then cancel = result else pcall(result) end
			end
		end,
		cancelPending = function()
			if state == "Loading" then token += 1; state = "Cancelled"; release() end
		end,
		destroy = function()
			if destroyed then return end
			destroyed = true; token += 1; state = "Destroyed"; release()
		end,
	}
end
return table.freeze(Loader)
