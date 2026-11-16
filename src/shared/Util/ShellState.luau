--!strict
-- Local presentation state only. Closing a surface never clears asset selection.
local ShellState = {}
export type State = { route: string, selectedId: string?, inspectorStage: string, railExpanded: boolean?, mapFocus: boolean }
function ShellState.new(): State
	return { route = "Map", selectedId = nil, inspectorStage = "closed", railExpanded = nil, mapFocus = false }
end
function ShellState.select(state: State, id: string)
	state.selectedId = id
	state.route = "Map"
	state.inspectorStage = "half"
end
function ShellState.navigate(state: State, route: string)
	state.route = route
	state.mapFocus = false
end
function ShellState.closeInspector(state: State)
	state.inspectorStage = "closed"
end
function ShellState.cycleInspector(state: State)
	state.inspectorStage = if state.inspectorStage == "peek" then "half" elseif state.inspectorStage == "half" then "expanded" else "peek"
end
return table.freeze(ShellState)