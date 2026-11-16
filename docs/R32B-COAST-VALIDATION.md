# R3.2b coastline seam correction

16 November update: the owner accepted revision 3 for the isolated R3.3 renderer proof. See [R3.3 validation](R33-VALIDATION.md). This is not upload or production-map approval; the local limitations below remain historical inspection items for later real-texture testing.

15 November 2026. Local compositing correction delivered; **grass seam and source-opacity issues corrected**, with endpoint naturalness and one filtered-alpha sample still unresolved. Owner visual acceptance is pending.

## Deliverables and method

[Revision-3 package](../assets/r32-proof-v3/README.md) contains the corrected 1024×1024 atlas, six exports, six-layer OpenRaster, original sources, corrected content source, masks, reproducible scripts, manifest/provenance, high-resolution comparison, five-zoom before/after sheets, actual-size contact sheet and annotated native geometry reference. Five accepted motif source/export files are byte-identical to revision 2. Both earlier packages remain unchanged.

The owner's R3.2b request explicitly authorizes local raster compositing. Used existing Pillow; no generation, uploads or new dependencies. On the fixed 496-square coast content, the native boundary is `x=350-sqrt(175²-(y-365)²)` in world space, with origin `(93.5,238.5)` and 0.5 world units per pixel. Conservative chroma selection isolates opaque green grass; neutral rocks and teal shoreline outside native land are protected. A smoothstep blend removes grass texture/colour mismatch over distances -30 to -4 world units from the native edge. New opaque grass fills missing coverage only beneath the native meadow, including both documented endpoint bands. The fill follows the existing curve and its tangents; no country geometry is moved or redrawn.

Atlas slot, gutter, pivot, world canvas, ground anchor, fallback identity, visual bounds and render order remain unchanged. The corrected content is packed directly, without recropping/refitting. Coast/atlas revisions become 3, other art revisions stay 1. Original generated source/packing metadata remains provenance; the manifest separately hashes the fixed-canvas correction source.

## Validation actually performed

| Area | Result |
| --- | --- |
| Atlas regression | **70 assertions passed**: dimensions, RGBA/sRGB, gutters, allocation/nonoverlap, content equality, alpha variation, pivot round-trips at five zooms, overhang bounds and OpenRaster archive integrity. |
| Coast regression/correction | **161 assertions passed**: descriptor preservation, ten accepted source/export hashes, seam probes, source overlaps plus neighbourhoods, inland opacity, preservation of exposed non-grass pixels and no new exterior coverage. |
| Inland opacity | Existing content sample x=220..459, y=170..319 now **255–255**, previously 249–253. |
| Northern endpoint | World `(187.92286,299)`, local world `(94.42286,60.5)`, native tangent `(-0.37714,0.92616)`. Source 16-unit overlap minimum **255**; neighbourhood ±2 world units also **255**; 4× filtered minimum **255**. |
| Southern endpoint | World `(187.12275,429)`, local world `(93.62275,190.5)`, native tangent `(0.36571,0.93073)`. Source overlap/neighbourhood minimum **255**. One 4× Lanczos sample is **254**, so the existing strict filtered-opacity flag remains **false**. No opaque-source claim is substituted for filtered evidence. |
| Grass-colour mismatch | Same 46 central probes and composite method as R3.2a: mean absolute RGB-channel error **7.61182 → 0.0**. This is exact matching at the defined probes, not a perceptual score for the entire coast. |
| Coast preservation | **16,697** exposed non-grass pixels retain exact RGBA. **Zero** originally transparent pixels acquire coverage outside native land. Chroma-mask classification is a practical protection rule, not semantic proof that every rock pixel was identified; visual inspection supplements it. |
| Coordinates | All six descriptor geometries preserved. No camera, marker or runtime source modification. |

Commands run: `correct_coast.py`, `build_local.py`, `validate_coast.py` in `assets/r32-proof-v3`. Machine results are in `validation-results.json`, `coast-validation-results.json` and `correction-record.json`. Passing counts exclude the southern strict filtered-opacity failure; that flag is retained visibly.

## Visual assessment and remaining discontinuities

Inspected before/after at **0.55, 0.72, 1, 1.2 and 1.8**, the contact sheet and enlarged annotated geometry reference. The curved grass-to-meadow texture cut is no longer visible in these local composites. Western rock relief, highlights and shallow-water fringe retain their appearance. Near the coast, texture fades into a quieter meadow rather than being clipped along a circle.

However, the preserved rocks still terminate abruptly against the smooth native shoreline at the northern and southern joins, particularly enlarged. Filling below native land resolves coverage but does not invent a naturally painted continuation. Thus **full natural coastline/tangent visual acceptance is not claimed**. This limitation is retained rather than moving the shoreline, tapering away existing cliffs or adding decorative objects. A future art-direction decision may accept that stylistic transition or authorize a precise painted endpoint treatment within the same footprint.

The [high-resolution comparison](../assets/r32-proof-v3/coast-high-resolution-comparison.png) uses four display pixels per world unit; it is an inspection enlargement, not higher-detail art. [Actual-size sheets](../assets/r32-proof-v3/coast-comparison-zooms.png) require 100% image viewing. [The motif contact sheet](../assets/r32-proof-v3/contact-sheet.png) shows the raw sprite too: the inland backing appears rectangular against isolated ocean, but is wholly below native meadow in the intended composite. It must not be treated as a stand-alone island or reordered above native land.

The reference uses exact half-unit origin and 4× supersampling. Lanczos ringing can reduce a boundary-adjacent alpha from 255 to 254; the southern case is recorded, not silently rounded away. Actual Roblox filtering remains untested. The original rounded-placement `coast-join-check.png` is also retained for continuity; comparisons use the same newer rasterizer for both revisions.

## Scope and next step

Runtime/test/config and previous artwork-package hashes were compared against the pre-task snapshot. No runtime integration, gameplay, camera/coordinate change, dependencies, asset IDs, uploads, commits, pushes, publishing or deployment. Roadmap and decisions record this local result. Rojo/Studio/game tests and performance profiling were not run because no runtime content changed; these image tests provide no Roblox performance or visual acceptance claim.

Next step: owner review of the corrected grass transition and remaining endpoint style. Stop here; no integration or later phase is started.
