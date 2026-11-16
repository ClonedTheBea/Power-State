# Power State R3.2a — coast refinement / atlas revision 2

Only `coast-headland` changes artwork revision (1 → 2). The owner accepted the other five revision-1 motifs for proof use in the R3.2a request; their source/export PNG bytes are unchanged. The original [revision-1 package](../r32-proof-v1/README.md) remains available for comparison.

Start with [before/after](coast-before-after.png), [all motifs](contact-sheet.png), [five zoom comparisons](coast-comparison-zooms.png) and [coast on land/ocean](coast-background-zooms.png). Before/after is enlarged 2×; the zoom sheets use the labelled logical-pixel sizes when viewed at 100%. These are local composites, not Studio screenshots.

## Refinement and limits

The coast has cooler sage grass, less yellow cast and a reduced colour jump into native land. Painted relief, western rocks, teal fringe and upper-left lighting remain. Native render order and map geometry are unchanged. A fixed central seam sample reports 37.93% lower mean absolute RGB mismatch; this is a local diagnostic, not perceptual acceptance. The texture boundary and abrupt northern/southern shoreline joins remain visible.

**Not integration-ready:** the two inherited proposed endpoint probes fail the 16-world-unit opaque overlap contract. Their exact points and native boundary tangents are in `coast-validation-results.json`. They are measured probes, not approved cliff sockets. The inland sample has alpha 249–253, not the strict 255 required for an opaque contract. No zero-alpha hole occurs in that sample; the generated alpha was preserved. Native land hides much of the interior in the intended pass order, which does not waive the authoring requirement.

Further work, if requested: paint exact native-sage transition values, opaque interior/overlap and both endpoint tapers in a raster editor against the same fixed geometry, then repeat diagnostics. Do not move coordinates, pivots or native meadows to conceal the seam. Owner acceptance of this revised coast is pending.

## Files and reproducibility

- `power-state-map-proof-v2.png`: 1024×1024 RGBA/sRGB atlas, unchanged cells and 8px alpha-zero gutters.
- `sprites/`: six inspectable exports, only coast artwork changed.
- `sources/`: selected full-resolution coast edit and unchanged accepted sources.
- `power-state-map-proof-v2.ora`: six editable raster layers; no semantic/vector object layers. Archive integrity checked; editor application not opened.
- `manifest.json`: revision, hashes, rectangles, pivots, ground anchors, per-motif acceptance and provenance.
- `production-inputs.json` and `refinement-history.json`: exact prompts and edit history using built-in OpenAI image_gen; model identifier not exposed. Input was the project's generated revision-1 coast. Attempts 1–3 were rejected for interior alpha loss; attempt 4 is selected. Earlier `coast-refinement-provenance.json` is explicitly superseded history. Rejected files remain in the generator's output directory; the selected source is bundled here.
- `build_local.py`: repacks from bundled sources using the already-installed Pillow; creates atlas, exports, contact sheet, pivot/native-coast diagnostics and 70 packing checks.
- `validate_coast.py`: compares against revision 1; creates before/after and zoom sheets, checks unchanged descriptors/accepted bytes, records seam measurements and failed authoring gates separately from 152 passing assertions.

Run from repository root:

```powershell
python assets/r32-proof-v2/build_local.py
python assets/r32-proof-v2/validate_coast.py
```

No Roblox IDs, upload approval, integration or performance evidence. See [R3.2a validation](../../docs/R32A-COAST-VALIDATION.md).
