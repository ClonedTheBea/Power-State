--!strict
-- Authored cosmetic patches within the unchanged 1200x800 preview plane.
-- Version/sector/local identity is presentation-only, not ownership or generated world data.
export type Patch = { id: string, kind: string, x: number, y: number, width: number, height: number, radius: number? }
local patches: { Patch } = {
	{ id = "art1:0:0:coast-west", kind = "land", x = 175, y = 190, width = 420, height = 350 },
	{ id = "art1:0:0:coast-north", kind = "land", x = 410, y = 110, width = 480, height = 400 },
	{ id = "art1:0:0:coast-east", kind = "land", x = 670, y = 235, width = 390, height = 350 },
	{ id = "art1:0:0:coast-south", kind = "land", x = 425, y = 360, width = 400, height = 310 },
	{ id = "art1:0:0:isle", kind = "land", x = 160, y = 580, width = 110, height = 65 },
	{ id = "art1:0:0:west-cape", kind = "land", x = 125, y = 295, width = 185, height = 135, radius = 55 },
	{ id = "art1:0:0:north-cape", kind = "land", x = 740, y = 95, width = 160, height = 190, radius = 80 },
	{ id = "art1:0:0:south-cape", kind = "land", x = 740, y = 545, width = 150, height = 135, radius = 68 },
	{ id = "art1:0:0:substation-yard", kind = "substation", x = 550, y = 360, width = 80, height = 55 },
	{ id = "art1:0:0:highlands", kind = "mountains", x = 485, y = 120, width = 205, height = 120 },
	{ id = "art1:0:0:hills", kind = "hills", x = 245, y = 195, width = 175, height = 100 },
	{ id = "art1:0:0:wood-west", kind = "forest", x = 225, y = 375, width = 130, height = 95 },
	{ id = "art1:0:0:wood-east", kind = "forest", x = 865, y = 300, width = 120, height = 100 },
	{ id = "art1:0:0:fields", kind = "fields", x = 700, y = 380, width = 145, height = 100 },
	{ id = "art1:0:0:fields-west", kind = "fields", x = 430, y = 430, width = 120, height = 90 },
	{ id = "art1:0:0:lake", kind = "lake", x = 440, y = 245, width = 95, height = 65 },
	{ id = "art1:0:0:river", kind = "river", x = 470, y = 290, width = 145, height = 345 },
	{ id = "art1:0:0:routes", kind = "routes", x = 300, y = 250, width = 500, height = 320 },
	{ id = "art1:0:0:newford", kind = "town", x = 705, y = 255, width = 110, height = 95 },
	{ id = "art1:0:0:southbank", kind = "village", x = 635, y = 555, width = 100, height = 70 },
	{ id = "art1:0:0:eastmere", kind = "village", x = 895, y = 475, width = 100, height = 70 },
	{ id = "art1:0:0:industry", kind = "industry", x = 285, y = 290, width = 125, height = 110 },
}
for _, patch in patches do table.freeze(patch) end
return table.freeze(patches)
