# R3.2b coast correction — atlas revision 3

Local raster correction only. Five accepted motifs remain byte-identical. Coast slot `(8,8,496,496)`, 248×248 world canvas, pivot `(248,248)`, anchor `(217.5,362.5)` and all other descriptors are unchanged. Revision 2 is retained intact.

## Inspect

- [Before/after at five zooms](coast-comparison-zooms.png): 0.55, 0.72, 1, 1.2 and 1.8, actual logical sizes at 100% image viewing.
- [High-resolution comparison](coast-high-resolution-comparison.png): 4 display pixels per world unit, for inspection; enlargement does not add painted detail.
- [Actual-size motif contact sheet](contact-sheet.png): normal/minimum zoom on representative land/ocean.
- [Native geometry reference](native-boundary-reference.png): cyan boundary, yellow probe points/tangents, magenta 16-world-unit overlap measurements. Annotation is not baked into the art.
- [Before/after overview](coast-before-after.png), [raw coast backgrounds](coast-background-zooms.png), `correction-mask.png`, `preserved-coastal-pixels.png` and `pivot-check.png`.

## What changed

Owner-authorized Pillow compositing, with no new generated art: smooth grass-only colour/texture reduction from 30 to 4 world units outside the fixed native boundary. The quiet end matches `#6B8463` exactly. Grass becomes opaque; missing coverage is filled **under** the existing meadow only. A narrow subpixel ramp follows the native curve; its tangents are the documented endpoint tangents. Nothing moves or changes the exterior coastline geometry. Visible neutral rock/teal shoreline pixels outside the grass mask remain exact RGBA matches.

The inland sample and both 16-unit source overlaps (also tested ±2 world units vertically) are alpha 255. Central sampled colour error is zero. The curved grass texture seam is removed in inspected composites.

**Remaining limits:** natural rock-to-smooth-native-shore transitions are still abrupt at both endpoints, especially enlarged. One southern 4× Lanczos-filtered sample has alpha 254 despite opaque source samples; this strict filtered-opacity failure remains recorded. Owner visual acceptance and Roblox filtering/performance are not established. The new rectangular inland backing is intentionally hidden beneath native meadow; raw ocean-isolation previews expose it. This sprite must retain its approved pass order and placement and is not a free-standing island tile.

## Reproduce

```powershell
python assets/r32-proof-v3/correct_coast.py
python assets/r32-proof-v3/build_local.py
python assets/r32-proof-v3/validate_coast.py
```

Existing Pillow only. The first script reads the retained revision-2 export, writes fixed-size `sources/coast-corrected-content.png` and editable correction/protection masks. The packer bypasses crop/refit for this corrected content. Original generated sources and historical prompts are retained; `correction-record.json` records the current compositing operation. `manifest.json` distinguishes original sources and correction source hashes. `power-state-map-proof-v3.ora` contains six editable final raster layers; the deterministic script/masks retain the correction controls.

Results: 70 atlas assertions and 161 coast assertions pass; the filtered southern strict-opacity gate is separately false, not counted as passing. See [full validation](../../docs/R32B-COAST-VALIDATION.md). No upload, Roblox ID, runtime modification, commit, push, publish or deployment.
