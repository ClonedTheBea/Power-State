--!strict
local Country = require(script.Parent.OperationsCountry)
local Commands = {}
function Commands.admit(bucket: any, payload: any, now: number): boolean
	bucket.tokens = math.min(6, (bucket.tokens or 6) + math.max(0, now - (bucket.at or now)) * 3)
	bucket.at = now
	if bucket.tokens < 1 then return false end
	bucket.tokens -= 1
	if type(payload) ~= "table" or getmetatable(payload) ~= nil then return false end
	local keys = {version = true, kind = true}
	if payload.kind == "Control" then
		keys = {version = true, kind = true, epoch = true, revision = true, sequence = true, sourceId = true, on = true, capKW = true}
	elseif payload.kind == "Retry" then keys = {version = true, kind = true, epoch = true, revision = true, sequence = true}
	elseif not table.find({"Enter", "Exit", "Sync"}, payload.kind) then return false end
	local count = 0
	for k, v in payload do
		count += 1
		if count > 8 or not keys[k] then return false end
		if type(v) == "number" then if v ~= v or v % 1 ~= 0 or v < 0 or v > 1000000000 then return false end
		elseif type(v) == "string" then if #v > 64 then return false end
		elseif type(v) ~= "boolean" then return false end
	end
	for k in keys do if payload[k] == nil then return false end end
	return payload.version == 1
end
function Commands.apply(actor: any, ownerId: number, payload: any): string
	local state = actor.state
	if not actor.active or actor.ownerId ~= ownerId then return "Unauthorized" end
	if payload.epoch ~= actor.epoch or payload.epoch ~= state.epoch then return "StaleSession" end
	if payload.sequence ~= actor.nextSequence then return "ReplayRejected" end
	actor.nextSequence += 1
	if payload.revision ~= state.countryRevision then return "StaleRevision" end
	if actor.saving or actor.saveBlocked then return "CheckpointUnavailable" end
	if payload.kind == "Retry" then
		if actor.status ~= "Suspended" and actor.status ~= "Invalidated" then return "NoChange" end
		actor.status = "Accepted"; actor.reason = nil
		return "Accepted"
	end
	if payload.kind ~= "Control" then return "Rejected" end
	local ok, nextState = pcall(Country.control, state, ownerId, payload.epoch, payload.revision, payload.sourceId, payload.on, payload.capKW)
	if not ok then return "InvalidControl" end
	actor.state = nextState; actor.status = "Accepted"; actor.reason = nil
	return "Accepted"
end
return table.freeze(Commands)
