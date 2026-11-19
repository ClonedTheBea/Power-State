# Illustrated World v1 — eighteen-motif local review package

19 November 2026. The owner-approved diagonal amendment is implemented **as local artwork only**. All18 motifs and both atlases are produced for review. This is not owner visual acceptance, an uploaded asset, an integrated renderer, or proof of Roblox filtering/performance. Native remains unchanged.

## Start with these previews

- [Complete contact sheet](previews/contact-sheet.png): fourteen shores, two hills, substation and pylon.
- [All16 painted occupancy cases](previews/all16-painted.png): includes the two homogeneous Native cases.
- [Painted difficult arrangements](previews/painted-adversarial.png), [edge pairs1](previews/edge-pairs-1.png), [edge pairs2](previews/edge-pairs-2.png), [diagonal centre pixels](previews/diagonal-centres.png).
- [Current Native colour-rule comparison](previews/native-colour-comparison.png): same corpus38 reference samples on both sides; shows remaining block colours honestly.
- [Flat-ground art-family comparison](previews/landscape-comparison.png): existing gas, Newford town, Southbank village, forest and fields beside the new art. Decorative study placements, not saved electrical anchors or a Studio screenshot.
- [Corpus cases](previews/corpus-painted.png), [ground pivots](previews/pivots.png).
- [All-motif zoom page1](previews/all-motifs-zooms-1.png), [page2](previews/all-motifs-zooms-2.png), [page3](previews/all-motifs-zooms-3.png). Inspect at100% screen display. All18 motifs at0.55/0.72/1/1.2/1.8; page labels give actual raster dimensions.
- `previews/joins-zoom-*.png`: eight difficult arrangements at each of the five zooms. These use local Pillow sampling, not Roblox image filtering.

## Files and exact hashes

| File | Dimensions | SHA-256 |
| --- | --- | --- |
| [power-state-terrain-edges-proof-v1.png](power-state-terrain-edges-proof-v1.png) |1024×1024 RGBA|`d8d3994469c68f31d800cadec9c8e3aeda3d25ecd3693c6140e781c402c5b0cb`|
| [power-state-diagonal-shores-proof-v1.png](power-state-diagonal-shores-proof-v1.png) |512×256 RGBA|`e669e58a0b8b32d0f19f21025b79cc878eed134ed285ad4880353b6d580fd62f`|

[Manifest](manifest.json) records every cell, rectangle, pivot, footprint, export/source checksum and preparation. No asset IDs exist. [Package hashes](package-hashes.json) cover the local evidence. Frozen original atlases/manifests are not modified.

Main atlas row order:

1. shore-n, shore-e, shore-s, shore-w.
2. shore-convex-ne, shore-convex-se, shore-convex-sw, shore-convex-nw.
3. shore-concave-ne, shore-concave-se, shore-concave-sw, shore-concave-nw.
4. hill-low-a, hill-low-b, substation, pylon.

Companion left/right: shore-diagonal-nw-se, shore-diagonal-ne-sw. Every cell256², content240² at cell+(8,8), transparent8px gutters. Hidden RGB is dilated without making alpha opaque. Source rectangles exclude gutters. Straight alpha; RGB intended for sRGB interpretation. No baked labels, electricity lines or selection effects.

Shore pivot(120,120),64-world-unit square; hill pivot(120,184),96-square; substation same pivot,80-square; pylon same pivot,32-square. Source crop/scale/paste is recorded per object. Ground contact is cosmetic, not an electrical terminal. Never recrop after pivot agreement. Native44px targets/labels remain separate.

## Exact shoreline composition contract

Bits NW1/NE2/SW4/SE8 describe the exact existing Native occupancy. Fourteen mixed cases use one prepared sprite each;0/15 use none. Vertex-centred64-square patches meet without overlapping. Geometry masks are retained in `sources/masks/`;1024-square guide images are in `sources/guides/`. No outside-sector ocean is assumed. Unsupported boundary context stays Native.

Each orientation was generated separately with upper-left lighting; no rotations or mirroring. Raw diagonal paint rounded the junction, so local preparation clipped wrong-side land material to the exact mask. Rejected water-side grass/rocks are filled from a retained painted shallow-water sample, in its original north-up orientation, with a quieter water tint. This is a local raster correction, not a new runtime mask or blend system. The central water treatment occurs once in each finished diagonal PNG. No stacked corner opacity.

Matching edge profiles are shared from the corresponding independently lit cardinal, with a16-content-pixel inward blend. RGBA interpolation is premultiplied during blending, then exported straight-alpha. Alpha falls off within the approved8-world-unit rim. Both ends of each straight use the same profile. Source-resolution tests find zero alpha and premultiplied-RGB difference across all128 compatible directed port pairs. Pixel material classification and composited categorical ownership match all14 masks, including the exact diagonal shared point. This does **not** certify natural appearance, derivative continuity, filtered subpixel edges, mip levels or Roblox sampling.

The first two preparation previews are retained as explicitly rejected evidence. Nearest-colour extrusion produced streaks/bright patches; simple clipping alone produced dark water gaps. The final pass uses the preserved painted-water sample and premultiplied port blending. Numerical passes did not make those earlier images visually acceptable.

## Provenance and editable sources

- Eighteen successful built-in `image_gen.imagegen` outputs,19 November2026. [Object prompts](sources/provenance.json), [shore prompts](sources/shore-provenance.json). Actual model/version was not exposed; no guessed identifier or licence is recorded.
- Raw generated RGBA files are retained in `sources/`, with actual SHA-256 values in the manifest. Generated originals also remain at the tool-returned paths, but this package does not depend on those external copies.
- Style references: existing approved r32 forest-cluster, settlement and gas-station artwork; generated hill/straight-shore references were used for subsequent consistency. Geometry guides are original local diagnostics. Existing r32/r37 artwork is reused unchanged only in labelled composites.
- [Main OpenRaster](main-layers.ora) and [companion OpenRaster](diagonal-layers.ora) contain16/2 individually movable raster sprite layers. Raw illustrations are flattened, not editable brush-stroke/vector originals. Scripts/masks allow reproducible preparation; do not describe these as hand-painted layered source originals.
- AI-assisted provenance is disclosed. No external stock download, invented attribution, exclusive-rights claim or legal certification. Owner review of suitability/rights remains necessary before publication.
- Existing installed Pillow and NumPy only; no dependency installation. Runtime code is not imported or modified by these scripts.

## Reproduce and validate

From the repository root, run in order:

```powershell
python assets/illustrated-world-v1-art-r1/prepare_guides.py
python assets/illustrated-world-v1-art-r1/validate_grammar.py
python assets/illustrated-world-v1-art-r1/prepare_art.py
python assets/illustrated-world-v1-art-r1/validate_art.py
python assets/illustrated-world-v1-art-r1/package_review.py
python assets/illustrated-world-v1-art-r1/review_edges.py
python assets/illustrated-world-v1-art-r1/hash_package.py
```

Stop on a nonzero result. These commands read retained generated files; they do not call image generation or Roblox. Package hashes must be regenerated after evidence changes. `validate_grammar.py` checks the independent integer reference against289 golden elevations,512 arrangements,10,000 natural countries and40,000 orientation diagnostics. This is not a rerun of full engine fairness. `validate_art.py` passes579 assertions. OpenRaster ZIP structure/layer counts and merged PNG equality also pass. Engine performance, texture memory, physical devices and Script Analysis are not newly measured because no runtime is introduced.

## Remaining visual limits and next boundary

The compact hills/substation fit the approved illustrated family. The pylon silhouette is recognizable at larger sizes but only about13 painted pixels high in its18px minimum-zoom canvas; no operational information may depend on that decoration. Hills have visible grass-footprint transitions on the plain Native swatch. Shoreline highlights and corner textures remain nonuniform, especially at large zoom. Outer unknown-context transitions intentionally stop at the Native fallback boundary.

The country still has orthogonal shores and visible Native green/tan cell blocks. This batch is **not** reference-image parity. Smallest additional requirement for review: one subdued, neutral, seamless shared temperate ground texture with a controlled meadow/coast-colour transition treatment, clipped to the existing categorical land mask. A texture alone will not remove colour steps or change the orthogonal coastline; a separately reviewed cosmetic colour-blend policy is needed if the goal is to suppress those steps. No such asset or runtime rule was added here. Do not expand into a terrain library automatically.

Review the actual artwork and these limits before any upload. If accepted for a later isolated proof, the owner manually uploads the exact two files under personal `missawfulname`149564436, Restricted, for Test10776833313, and supplies verified Image IDs. No upload is requested as an automatic next action. Production10776828545 remains excluded.

Subsequent renderer implementation requires separate authorization, Native fallback/default, bounded pool/culling and native graph overlays. The corpus has up to78 shore junctions (p95=55), exceeding the earlier planning allocation of64 shore slots in some countries. Do not silently enlarge the pool: review deterministic whole-region fallback or a bounded allocation policy under600 map descendants. Add real texture/filtering, repeated pan/zoom/remount, accessibility and matched performance tests before adoption.
