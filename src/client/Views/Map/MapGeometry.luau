--!strict
-- Screen geometry only. No terrain legality or electrical connectivity is inferred here.
local Geometry = {}
function Geometry.intersects(x: number, y: number, w: number, h: number, width: number, height: number, margin: number): boolean
	return x + w >= -margin and y + h >= -margin and x <= width + margin and y <= height + margin
end
function Geometry.segmentVisible(ax: number, ay: number, bx: number, by: number, width: number, height: number): boolean
	-- Conservative AABB includes crossing lines whose endpoints are both offscreen.
	return Geometry.intersects(math.min(ax, bx), math.min(ay, by), math.abs(bx - ax), math.abs(by - ay), width, height, 8)
end
function Geometry.band(previous: string, zoom: number): string
	if zoom >= 1.25 or (previous == "detail" and zoom > 1.15) then return "detail" end
	if zoom < 0.68 or (previous == "overview" and zoom < 0.76) then return "overview" end
	return "regional"
end
return table.freeze(Geometry)
