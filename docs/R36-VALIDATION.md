# R3.6 local artwork validation

16 November 2026. Local study only; not Roblox rendering or visual acceptance evidence.

## Checks performed

`python assets/r36-study-v1/build_study.py` passed **14 local packaging assertions**: approved-atlas SHA-256, new atlas RGBA/dimensions, both rectangle bounds, non-overlapping cells, pivots inside source bounds, fully transparent gutters, transparent/opaque pixels and intermediate antialias alpha. See [machine-readable results](../assets/r36-study-v1/validation-results.json). Existing Pillow10.0.0 used; no dependencies installed.

Approved revision-3 checksum remains `e1dcb61948e575bab85d94a6eed3dce1939fe87389455fc3bce735a28cab63cb`. Original atlas, six motifs and runtime files were not edited in this task. Source/generated candidate hashes and exact prompts are retained in the new package. Historical provenance fields in the old manifest were not rewritten; later approval/hosting evidence remains in R3.3/R3.4 records.

Visually inspected generated settlement sources, terrain board, [actual-size comparisons](../assets/r36-study-v1/contact-sheet.png) and [five-zoom/pivot preview](../assets/r36-study-v1/zoom-pivot-review.png). Contact-sheet backgrounds use actual native meadow #6B8463 and diagnostic ocean. Supported zooms0.55/0.72/1/1.2/1.8 are shown without changing runtime camera settings. Packaging preserves aspect ratio and generated alpha; it does not repair colours or paint new edges.

Git whitespace validation (`git diff --check`) passed; Git reported only existing LF/CRLF conversion notices. All 8 local links in the three new Markdown documents resolve. These are documentation checks, separate from the 14 packaging assertions.

## Visual findings and unresolved issues

- Village/cottages, denser coastal grouping and Newford civic tower are distinguishable in the local sheet. At0.55, Southbank's gardens and Eastmere's maritime details collapse to texture; coastal identity is not reliably conveyed by the sprite alone. Names/context remain essential. No physical-device readability claim.
- Candidates are slightly warmer and softer than Newford. Roof/wall family and upper-left illumination are compatible in this local review; owner acceptance remains pending.
- Southbank's broad alpha fringe reduces the apparent building size relative to its canvas. On meadow it is unobtrusive at these sizes; ocean reveals a grassy halo. Neither settlement is suitable for placement partly over water. Do not infer coastline continuity from transparency.
- Proposed Southbank terminal sits just above its visible roofline. Eastmere's terminal is nearer its upper buildings. These are preserved electrical coordinates; any needed adjustment must be to cosmetic pivot/export composition in a later reviewed revision.
- Terrain board has a non-calibrated green gradient and clipped left-side content. It communicates integrated fringes but is not a tiling or alpha-join test. No new terrain sprite is declared ready. Future edges require actual native-background colour/alpha validation, preserving the approved coast separately.
- Sources are flattened raster PNGs; no hand-painted layers are available. Editable packing script/manifest and unmodified generated originals are retained.
- Local transparent gutters do not prove Roblox filtering, colour-halo absence, mip behaviour, upload rights or delivery. No new upload or Studio run was performed.

No runtime changes: engine suites, Rojo builds, Script Analysis and endurance tests were not rerun for this artwork-only task. R3.5's measured595 descendants and prior passing tests are historical inputs to the proposal, not fresh R3.6 measurements. A six-slot reassignment could keep595 by construction, but requires implementation and measurement later; the full eight-motif composition remains budget-gated.

## Changed files and scope

Created `assets/r36-study-v1/` (two source PNGs, two packed sprite PNGs, separate study atlas, contact sheet, five-zoom sheet, terrain concept board, prompts, manifest, packer, validation JSON, README), this report and `R36-ART-STUDY.md`. Updated roadmap, README and decision log to record this local milestone and owner preference. No runtime, existing atlas, Roblox settings, asset IDs or production changes. No commit, push, publish or deploy.

Recommendation: owner art review next, then a focused local refinement if needed. Do not adopt Hybrid or extend the renderer based solely on these previews.
