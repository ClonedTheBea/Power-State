# R3.6 — Settlement and terrain art study

16 November 2026. Local study complete; visual acceptance pending. The owner accepts R3.5 technical validation and prefers smaller badges/contextual labels, subject to final device testing. This does not approve Hybrid as production default. Native, all runtime code, coordinates, existing atlas and test settings are unchanged.

## Artwork and visual hierarchy

The [local package](../assets/r36-study-v1/README.md) contains two settlement candidates, a three-panel terrain concept, actual-size comparisons, a separate packing proof and provenance. Built-in image_gen used the approved Newford export as a style reference for settlements, and the approved motif contact sheet for terrain. Exact prompts and original raster outputs are retained. No third-party reference art was introduced.

**Southbank:** three cottages, one low barn, gardens and a loose earth lane. Low/open silhouette and fewer roofs distinguish a village from Newford's denser civic town. **Eastmere:** five cottages, a stone storehouse and wind-shaped tree. Warm roofs and cream walls match Newford; maritime timber details suggest a coastal settlement without introducing a pier, sea, cliff, lighthouse or new shoreline geometry. Those details are subtle at overview zoom and must not imply functional port gameplay.

Both use elevated 2.5D illustration, upper-left light and restrained lower-right shadows. Candidates are somewhat softer and warmer than the approved Newford export. They do not contain labels, grid lines, badges or selection effects. A future city should have a stronger bounded skyline and denser aggregate silhouette; no city art or development system is produced here. Settlement tier remains future authoritative data, never inferred from an illustration.

## Proposed sprite contract — not a runtime manifest

Separate local atlas: **512×256 RGBA**, two 256×256 cells, 8px transparent gutters, 240×240 source rectangles. Generated source alpha is retained; bounds-fitting is recorded for reproducibility. No automatic trimming after this version without updating pivots. Existing revision-3 atlas and its six descriptors stay frozen.

| Candidate | Cell | Source rectangle | Pivot within content | World canvas | Proposed ground anchor | Existing terminal |
| --- | --- | --- | --- | --- | --- | --- |
| Southbank | 0,0,256,256 | 8,8,240,240 | 120,160 | 130×130 | 685,590 | 665,535 |
| Eastmere | 256,0,256,256 | 264,8,240,240 | 120,160 | 140×140 | 945,510 | 930,455 |

Ground anchors are the centres of the **existing cosmetic patches**, not newly chosen electrical positions: Southbank patch `(635,555,100,70)`, Eastmere `(895,475,100,70)`. Existing entity IDs `south` and `east`, their terminals and all links remain unchanged. Candidate art IDs are separate. Southbank world rectangle is approximately `(620,503.33,130,130)`; Eastmere `(875,416.67,140,140)`. Both fit within their current patch rectangle plus the existing 64-world-unit overhang envelope, but actual neighbouring-terrain overlap still needs Studio review.

Placement uses the existing contract: top-left = ground anchor − pivot × world canvas / source dimensions; parent camera transform applies zoom once. Ground pivot is a proposed local art reference, not a claim that the electrical terminal lies at a doorway. The five-zoom preview shows Southbank's terminal floating just above the roofline; review cosmetic alignment before integration without moving the terminal. Maintain independent 44px targets, lines, labels, focus, selection and inspector identity.

## Terrain transitions: reuse first

The [concept board](../assets/r36-study-v1/terrain-transition-concepts.png) proposes three compatible edge treatments. It is generated concept art, not a pixel-preserving edit of the approved motifs.

| Region | Reuse and limited future treatment | Slots and boundary contract |
| --- | --- | --- |
| Forest | Reuse mixed conifer/broadleaf family; a sparse low shrub/grass fringe instead of a geometric patch outline | One replacement forest image, including its fringe; no separate trees or edge overlay objects. Irregular alpha perimeter with quiet meadow colour beneath |
| Agriculture | Reuse curved gold/olive plots and hedgerows; quieter grass verge outside hedges | One replacement field image in the existing field slot; no per-field GUIs or extra transition strip |
| Painted relief / native land | Retain ridge silhouette; restrain foothill contrast and taper texture into native meadow | One replacement ridge image with integrated transition; preserve ground pivot/culling envelope, no giant terrain texture |

Start by reviewing unchanged approved forest/field sprites on the remaining native patches in a future local composition study. Reuse without mirroring or rotation to preserve baked lighting. If repetition or edges remain distracting, author only the necessary compatible fringe revision. The concept board demonstrates those possible variations; it does not justify a new biome library.

The board's prompt requested RGB(107,130,95), which differs from actual native meadow **RGB(107,132,99), #6B8463**. Its generated empty areas also contain a gradient. Therefore it is explicitly **not colour-calibrated or seam-ready**. Future transition exports must use the actual theme colour, controlled alpha and native-background composites, not sampled colours from this board. The board also clips some content at its left edge. Do not cut it into runtime tiles.

Proposed terrain export targets, only if a revision is later needed: forest 240×240 / pivot120,120 / world150×150; fields 240×240 / pivot120,120 / world160×160; ridge496×240 / pivot248,120 / world248×120, preserving existing ground anchors. These are replacements for corresponding descriptors, not additional simultaneous overlay layers. No terrain atlas exports were created in this task. Keep the coast unchanged, including opaque backing below native meadow and its approved join probes/tangents.

## Bounded integration proposal — no implementation authorization

R3.5 measured 595 map descendants, ceiling600, including hidden fallback. Hiding native art does not free descendants. Do not simply add two settlement images and then spend the remaining three on terrain edges.

For a first isolated comparison, retain the **six existing ImageLabel slots**:

| Slot | Settlement-study comparison | Terrain comparison |
| --- | --- | --- |
| Coast, ridge, Newford, station | Retain current motifs | Retain current motifs; optional ridge revision in its same slot |
| Forest | Temporarily assign to Southbank; restore native forest | Existing forest or approved compatible revision |
| Fields | Temporarily assign to Eastmere; restore native fields | Existing fields or approved compatible revision |

This proposes 595→595 descendants by reassignment, with all native fallback bundles retained. It deliberately cannot show all eight illustrated regions simultaneously. It is a Test-only comparison profile, not the recommended final country composition. A future isolated implementation must introduce validated profile descriptors and restore old fallback ownership before slot reassignment; the current frozen six-motif validator cannot accept these candidates unchanged. Do not swap descriptors every pan or silently alter the approved manifest.

A complete composition with both new settlements and all six old motifs needs a separately reviewed pool/budget change with measured savings elsewhere. Do not remove fallback, accessibility targets or the accepted badge treatment to make the count fit. Additional forest/field/hill patches also need a bounded allocation plan. No such refactor is implemented or approved here.

The two-cell texture is 512×256×4 = **0.5 MiB** uncompressed base arithmetic; hypothetical full mip chain ≈0.67 MiB. With the existing 1024-square atlas, total arithmetic is 4.5 MiB base / about6 MiB with mips. This excludes engine copies, caching, compression and GPU overhead, and is not measured memory or a bound. Loading two textures may change batching; six GUI rectangles do not imply six or fewer draw calls. No CPU/GPU improvement is claimed.

## Next review and acceptance gates

1. Owner reviews candidates, village/town distinction, Eastmere coastal identity and the five-zoom contact sheet. Choose whether the warmer/softer rendering needs refinement.
2. Refine only rejected candidate aspects locally. Resolve Southbank terminal association and meadow edge treatment before asking for a later integration task. Review full-map overlap without moving coordinates.
3. If approved for a later proof, owner uploads the separate accepted file and supplies an ID. Never upload the opaque terrain board or overwrite the approved atlas. Confirm owner/privacy/Test access using the established owner-led workflow.
4. Separately authorize bounded Test comparison profiles. Test load denial/timeouts/late completion, Native restoration, image filtering/gutters, anchors, 44px input paths, inspector/selection retention, culling, resize and stable counts at all zooms. Run regression and endurance tests then; physical touch/gamepad testing remains necessary.

No runtime integration, new IDs, permission changes, production adoption, procedural expansion, gameplay, R4/R5/P2, commits, pushes or publication occurred. See [local validation](R36-VALIDATION.md).
