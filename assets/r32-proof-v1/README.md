# Power State R3.2 local artwork proof, revision 1

**R3.2a update:** the owner accepted the five non-coast motifs for proof use. A coast-only refinement is available in [revision 2](../r32-proof-v2/README.md); its colour seam is reduced, but strict opacity/endpoint overlap and coast acceptance remain unresolved. This revision-1 package is retained as the historical baseline. Statements below describe its original production review.

Local review candidate, not approved game artwork. Start with `contact-sheet.png` at 100% image scale. All six generated motifs have transparent exports in `sprites/`; `power-state-map-proof-v1.png` is the exact 1024×1024 atlas.

- `manifest.json`: authoritative export rectangles, unchanged planned pivots/world canvases/anchors, hashes and provenance status. No Roblox asset ID.
- `sources/`: original full-resolution generated raster sources, preserved without alteration.
- `production-inputs.json`: exact text prompts, tool/date/model disclosure and original source locations. There were no input reference images or downloaded stock assets.
- `power-state-map-proof-v1.ora`: editable OpenRaster document with six independently movable/paintable motif layers. These are raster layers, not editable individual trees/buildings or vectors. Archive integrity was checked; no external painting application was operated.
- `build_local.py`: deterministic packing, contact-sheet generation and assertions using the already installed Pillow. Run `python assets/r32-proof-v1/build_local.py` from the repository root. It uses bundled copies in `sources/` after the first run; original generation paths are historical provenance.
- `validation-results.json`: actual local automated results. `pivot-check.png` adds cyan pivot crosses for inspection only. `coast-join-check.png` is a 2× nearest-neighbour enlargement of a local geometry proxy, not a Studio screenshot.

## Coast revision handoff

**Join acceptance failed:** the native grass circle visibly occludes the headland at a hard colour/texture boundary. The headland is attractive in isolation but needs a dedicated native-join paint revision. Do not integrate this atlas as accepted artwork.

Keep the existing rectangle, pivot and coordinates. Native west land is the rounded rectangle `(175,190,420,350)`, radius 175; the atlas canvas starts at world `(93.5,238.5)`. Approximate observed north/south contact targets are world `(188,299)` and `(187,429)`, or local-world `(94.5,60.5)` and `(93.5,190.5)`. Candidate north-to-south tangents along the native boundary are about `(-0.38,0.93)` and `(0.37,0.93)`. These are **unapproved geometry targets**, not artist-validated coastline sockets. Re-measure on the revised silhouette; no claim of matching current cliff tangents.

Paint an opaque quiet eastern band matching native sage `#6B8463`, maintaining at least 16 world units of overlap at each actual join. Match both shoreline tangent transitions and remove the abrupt grass seam in the existing shore-before-meadow order. Current central grass extends well into native land, but central overlap alone does not pass endpoint/texture continuity. Do not move native land or hide the defect by changing rendering order. Test at zoom 0.55, 0.72, 1, 1.2 and 1.8 on land/ocean before owner review.

## Other review limitations

Muted painted terrain and warm roofs are coherent; the station is more architectural and the town more traditional than a final modern-country library might require. Fine roofs/furrows disappear at minimum zoom; silhouettes remain distinct. Do not rely on small texture details as gameplay signals. Local preview cannot prove overlay readability, Roblox texture filtering, target-device performance or owner visual acceptance.

See [local validation](../../docs/R32-LOCAL-ART-VALIDATION.md). No upload, game integration or later phase is authorized by these outputs.
