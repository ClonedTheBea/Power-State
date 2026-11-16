--!strict
local MapTransform = {}
MapTransform.MIN_ZOOM = 0.55
MapTransform.MAX_ZOOM = 1.8
MapTransform.WORLD_WIDTH = 1200
MapTransform.WORLD_HEIGHT = 800

-- Cosmetic country envelope including coastline overhang; no ownership or gameplay extent.
function MapTransform.homeZoom(width: number, height: number): number
	return math.clamp(math.min(width / 1000, height / 610), MapTransform.MIN_ZOOM, MapTransform.MAX_ZOOM)
end

function MapTransform.clampAxis(offset: number, viewport: number, world: number, zoom: number): number
	local extent = world * zoom
	if extent <= viewport then
		return (viewport - extent) / 2
	end
	return math.clamp(offset, viewport - extent, 0)
end

function MapTransform.zoomAt(offset: number, oldZoom: number, newZoom: number, anchor: number): number
	-- Preserve the map coordinate under the anchor before clamping to map bounds.
	return anchor - (anchor - offset) * newZoom / oldZoom
end
return table.freeze(MapTransform)
