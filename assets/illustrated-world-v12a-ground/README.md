# Controlled temperate ground — owner review candidate

Recommended file: **`temperate-ground-v12a.png`**, 1024x1024 opaque RGBA, 800,503 bytes.

SHA-256: `107448465ac25fc182841da2eeb706bec04a2774401641161301745393d3f1e2`.

This is a **processed derivative**, not untouched generated art. One substantial correction approach was used: source-derived periodic spectral synthesis, directional-band suppression, restrained seeded detail and palette correction. No new image-generation call or dependency. Original AI sources remain in the v1.1/v1.2 packages. Their exact hashes and transformation parameters are in `material-validation.json`; original generation prompts/provenance are in `../illustrated-world-v12-ground-study/provenance.json`. Scripts are editable procedural sources, not layered hand-painted artwork. No claim of exclusive rights or legal clearance is added.

## Review order

1. `before-after-repeat.png`, then actual-resolution `repeat-2x2-full.png` and `repeat-4x4-full.png`.
2. `edge-examination.png` and `crop-256-reassembly.png`.
3. `motif-five-zooms.png` — approved shore, hill, forest, field, town, gas, village, substation and pylon artwork.
4. `country-normal-comparison.png`, `country-diagonal-comparison.png`, `country-maximum-comparison.png`, `country-connected-district-comparison.png`.

All country comparisons are **local artwork simulations**, not Roblox renders. Anchors/shore entries/decorations come from `fixtures.json`, exported by existing pure Test modules in Studio edit mode. Names can include Rowanbridge, but IDs are `illustrated-fixture-1/2`, not the real saved profile. Connected district is a presentation flag using the existing surveyed asset; no purchase or simulation occurred. Labels/lines are schematic overlays. Native panel reconstructs the actual terrain colour rule, not the complete Native GUI artwork. The maximum scene retains the92 drawing-slot cap, so some decorations are omitted identically in both illustrated panels.

## Reproduce

With the existing Pillow/NumPy installation:

```
python assets/illustrated-world-v12a-ground/produce.py
python assets/illustrated-world-v12a-ground/composite.py
python assets/illustrated-world-v12a-ground/check_contract.py
```

Run from the repository; scripts also resolve paths from their location. The first script pins both source hashes. Sources and approved atlases are never overwritten. `export-fixtures.luau` records the guarded edit-mode export, not an automatically mapped runtime script. Initial6000-character log chunks were truncated; final700-character chunks were reconstructed successfully. Studio's log replaced a decorative middle-dot in a description; numerical fields, IDs and placement data are unaffected.

`material-validation.json` records dimensions/provenance/seams, `composite-validation.json` records identity/mask/edge/slot checks, and `contract-checks.json` contains42 local checks. `synthetic-colour-ramp.png` exercises the proposed climate colour term separately: both actual fixture climates are constant17C/1000mm. It is not a generated country.

## Boundary

Owner visual approval is pending. Upload **only the recommended material**, never a whole-country composite or diagnostic sheet, after review. Owner uploads manually to the approved personal Test workflow; no asset ID exists yet. Do not integrate the local PNG into runtime, replace approved atlases, or enable Illustrated by default. Continuous per-pixel shading needs a separately reviewed Test capability/resource proof; see the [validation and proposed procedure](../../docs/ILLUSTRATED-WORLD-V12A-VALIDATION.md).
