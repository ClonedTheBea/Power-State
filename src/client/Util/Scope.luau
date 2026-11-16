--!strict
-- Own external connections so remounting the shell never multiplies input handlers.
local Scope = {}
function Scope.new()
	local connections: { RBXScriptConnection } = {}
	return {
		add = function(connection: RBXScriptConnection)
			table.insert(connections, connection)
		end,
		destroy = function()
			for _, connection in connections do
				connection:Disconnect()
			end
			table.clear(connections)
		end,
	}
end
return Scope
