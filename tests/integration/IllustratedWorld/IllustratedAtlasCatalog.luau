--!strict
-- Verified R1 crops; original frozen artwork manifests remain unchanged.
local Catalog = {}
Catalog.POOL_SIZE = 96
Catalog.PROBES = 4
Catalog.DRAW_SLOTS = 92
Catalog.atlases = table.freeze({
 main = "rbxassetid://96236605552471",
 diagonal = "rbxassetid://133413370857301",
 original = "rbxassetid://86222383311104",
 settlements = "rbxassetid://90608851718773",
})
Catalog.order = table.freeze({"main", "diagonal", "original", "settlements"})
export type Motif = {atlas: string, rect: {number}, pivot: {number}, size: number}
local motifs: {[string]: Motif} = {
 ["shore-n"] = {atlas="main", rect={8,8,240,240}, pivot={120,120}, size=64},
 ["shore-e"] = {atlas="main", rect={264,8,240,240}, pivot={120,120}, size=64},
 ["shore-s"] = {atlas="main", rect={520,8,240,240}, pivot={120,120}, size=64},
 ["shore-w"] = {atlas="main", rect={776,8,240,240}, pivot={120,120}, size=64},
 ["shore-convex-ne"] = {atlas="main", rect={8,264,240,240}, pivot={120,120}, size=64},
 ["shore-convex-se"] = {atlas="main", rect={264,264,240,240}, pivot={120,120}, size=64},
 ["shore-convex-sw"] = {atlas="main", rect={520,264,240,240}, pivot={120,120}, size=64},
 ["shore-convex-nw"] = {atlas="main", rect={776,264,240,240}, pivot={120,120}, size=64},
 ["shore-concave-ne"] = {atlas="main", rect={8,520,240,240}, pivot={120,120}, size=64},
 ["shore-concave-se"] = {atlas="main", rect={264,520,240,240}, pivot={120,120}, size=64},
 ["shore-concave-sw"] = {atlas="main", rect={520,520,240,240}, pivot={120,120}, size=64},
 ["shore-concave-nw"] = {atlas="main", rect={776,520,240,240}, pivot={120,120}, size=64},
 ["hill-low-a"] = {atlas="main", rect={8,776,240,240}, pivot={120,184}, size=96},
 ["hill-low-b"] = {atlas="main", rect={264,776,240,240}, pivot={120,184}, size=96},
 ["substation"] = {atlas="main", rect={520,776,240,240}, pivot={120,184}, size=80},
 ["pylon"] = {atlas="main", rect={776,776,240,240}, pivot={120,184}, size=32},
 ["shore-diagonal-nw-se"] = {atlas="diagonal", rect={8,8,240,240}, pivot={120,120}, size=64},
 ["shore-diagonal-ne-sw"] = {atlas="diagonal", rect={264,8,240,240}, pivot={120,120}, size=64},
 ["forest"] = {atlas="original", rect={520,264,240,240}, pivot={120,120}, size=120},
 ["fields"] = {atlas="original", rect={776,264,240,240}, pivot={120,120}, size=120},
 ["town"] = {atlas="original", rect={8,520,240,240}, pivot={120,160}, size=130},
 ["gas"] = {atlas="original", rect={264,520,240,240}, pivot={120,160}, size=140},
 ["village"] = {atlas="settlements", rect={8,8,240,240}, pivot={150,182}, size=130},
}
Catalog.patterns = table.freeze({[1]="shore-convex-se",[2]="shore-convex-sw",[3]="shore-s",[4]="shore-convex-ne",[5]="shore-e",[6]="shore-diagonal-ne-sw",[7]="shore-concave-se",[8]="shore-convex-nw",[9]="shore-diagonal-nw-se",[10]="shore-w",[11]="shore-concave-sw",[12]="shore-n",[13]="shore-concave-ne",[14]="shore-concave-nw"})
for _, motif in motifs do table.freeze(motif.rect); table.freeze(motif.pivot); table.freeze(motif) end
Catalog.motifs = table.freeze(motifs)
return table.freeze(Catalog)
