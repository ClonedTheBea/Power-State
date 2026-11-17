# R3.6 local settlement and terrain study

16 November 2026. **Candidates for owner review, not approved runtime assets.** No uploads, runtime changes or replacement of the revision-3 atlas.

## Review files

- `contact-sheet.png`: candidates beside approved Newford, forest, fields and ridge, at zoom 1.0 and 0.55. View at 100%; chat preview may resize it.
- `zoom-pivot-review.png`: both candidates at all five supported zooms, on actual native meadow. Cyan marks proposed cosmetic ground pivots; gold marks unchanged electrical anchors. Annotations are not in sprite exports.
- `terrain-transition-concepts.png`: generated three-panel direction study (forest, fields, relief). **Opaque concept board, not a sprite or seamless tile. Do not upload it as a map background.**
- `sources/`: original transparent 1254×1254 generated settlement PNGs.
- `sprites/`: individually inspectable 240×240 RGBA candidate exports.
- `settlement-study-atlas.png`: separate 512×256 local packing proof; never overwrites or extends the approved 1024×1024 atlas.
- `manifest.json`: rectangles, cells, candidate pivots/anchors, source hashes and provenance.
- `prompts.json`: exact three prompts, built-in image_gen tool, model not exposed.
- `build_study.py`: reproducible packing and contact-sheet layout with existing Pillow. Alpha-bounds crop, aspect-preserving fit within 224×224, centred within 240×240; no repainting, alpha replacement, mirroring or colour correction.
- `validation-results.json`: 14 local packaging assertions and image hashes.

Run `python assets/r36-study-v1/build_study.py` from the project root. This rewrites only this study's derived files. Retained generated sources are raster artwork, not layered paintings; the packer and manifest are editable production controls. No new dependencies.

See [study, placement and performance proposal](../../docs/R36-ART-STUDY.md) and [validation/limitations](../../docs/R36-VALIDATION.md). Source rights are not a claim of legal clearance or exclusivity. Owner acceptance, later integration authorization and owner-performed upload remain separate gates. No new Roblox IDs exist.
