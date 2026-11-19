# Illustrated World v1.2 — material gate report

19 November 2026. **STOP at the Stage A/B artwork gate. No upload-ready material or runtime prototype.** Owner accepted v1.1's technical milestone and authorized local refinement/conditional Test compositing. The attachment explicitly requires stopping for review if a convincing seamless material cannot be produced. Two built-in image-generation attempts did not meet that gate; the original source and v1.1 rejected candidate remain unchanged.

## Work and visual evidence

Reviewed AGENTS, README, current PLANS/decisions, v1.1 validation/package, original `Inspiration/Grid Window.png`, existing catalogue/descriptor/composition, and architecture/starting-country/climate specifications. The reference shows continuous landscape; neither a repeated visible brush band nor independently tinted rectangles meets that intent.

[Local package](../assets/illustrated-world-v12-ground-study/README.md) includes two untouched generated PNG sources, provenance/prompt records, a reproducible analysis/contact-sheet script and detailed measurements. These are rejected candidates, not final artwork. No approved atlas was changed.

- [Edited candidate repetition](../assets/illustrated-world-v12-ground-study/candidate-edit-contact.png).
- [Fresh candidate repetition](../assets/illustrated-world-v12-ground-study/candidate-new-contact.png).
- [Approved motif compatibility at all five zooms](../assets/illustrated-world-v12-ground-study/motif-zoom-contact.png).
- Full-resolution 2x2 repetitions and 4x4 subdivision diagnostics are in the package.

The edited candidate moves toward the muted palette, but repeated diagonal brush bands remain identifiable. The fresh candidate is quieter yet still repeats directional structure and remains too yellow relative to the native base. Shore and hill grass bases also remain distinguishable. These observations are local visual judgments, not owner acceptance or Roblox observations.

## Dimensions, hashes and seam measurements

Both outputs are **1254x1254 RGB**, despite explicit 1024x1024 prompts. Neither was relabelled, cropped or rescaled into a purported final material. Preview resizing/cropping is labelled diagnostic only. Alpha is implicitly opaque; no transparent edge claim.

| Candidate | SHA-256 |
| --- | --- |
| Edited original | `52794fb984fa6d89a2da90f9c7baaac0a6119b0f20886f1a126bf82f04963712` |
| Fresh generation | `40141e82eb999ea2e6dd9735b32f3972e58ddb00dbb8a28e40888e464deabaa3` |

Absolute RGB differences, 0–255 channel units; H compares left/right and V top/bottom. Interior values compare neighbouring pixels, not a zero-error target. A periodic sampled signal need not have identical end pixels, but the wrap discontinuity should not visibly stand out. No new acceptance threshold is invented here.

| Candidate | Wrap mean H/V | Wrap maximum H/V | Interior adjacent mean H/V | Radius-4 filtered wrap mean H/V |
| --- | --- | --- | --- | --- |
| Edit | 3.021 / 2.464 | 12 / 11 | 1.142 / 1.306 | 2.485 / 1.956 |
| Fresh | 3.175 / 2.733 | 15 / 14 | 1.384 / 1.527 | 2.354 / 1.869 |

Filtered diagnostics blur each source before repetition; this is **not Roblox sampling/filtering**. Detailed p95, per-axis and crop metrics are in [validation.json](../assets/illustrated-world-v12-ground-study/validation.json). Mean RGB is 112.76/135.17/88.95 for edit and 106.44/131.00/81.84 for fresh; reference native is 107/132/99. Colour averages alone do not establish palette compatibility.

Reassembling sixteen 256px crops of each top-left 1024 region reproduces that region exactly. This proves internal crop placement only. It omits the remaining source strip and does **not** establish a repeating 1024 material; its outer-wrap errors are separately reported. No numerical or visual seamless pass is claimed.

## Continuous colour feasibility — preliminary constraint, not completed Stage C

The current 256 terrain slots can preserve categorical land ownership and world-aligned material phase. That does not solve shading. With uniform per-cell colours C1 and C2 and common boundary texture T, displayed boundaries are C1*T and C2*T; they match only where the colours agree (or the texture channel is zero). Swapping Frames for uniformly tinted ImageLabels therefore retains colour steps. A single global tint avoids those steps but omits the requested elevation/climate variation.

Smallest candidate alternative for later investigation: a bounded, cosmetic per-pixel colour/material buffer for a visible sector, sampled continuously from existing fields and cropped through the existing terrain slots. It must preserve the original mask, use matching neighbouring-sector samples, update outside pan/zoom, retain native loading/failure display, and prove runtime support and resource limits before implementation. This is neither a whole-country static illustration nor an approved architecture change. No runtime API capability, memory measurement or filtering result is claimed. Extra gradients per cell and masking failed joins with decoration are not proposed.

## Stage status and validation

- A: two local attempts retained; exact dimensions and convincing periodicity not achieved.
- B: repetition, subdivision, approved shore/hill/forest/field/building compatibility, low/high uniform colour swatches and five zooms (.55/.72/1/1.2/1.8) inspected. Swatches are local studies, not exact camera/world sampling or continuous-shading proof.
- C–E: dependent feasibility proof, four matched generated-country comparisons and optional runtime prototype **not executed**, because the material gate failed. No substitute mockup is represented as the requested country comparison.
- Both Rojo builds and existing source/remote/persistence isolation/whitespace checks: PASS this task.
- Frozen atlas/catalog/build-isolation checks: **80 PASS** this task.
- Independent Python world/shore reference: **10,000 seeds x four rotations / nine million junctions PASS**, 24.772 seconds; natural maximum 78, all-rotation maximum 80. This is grammar reference evidence, not runtime performance.
- No Luau/runtime code changed. Prior v1.1 cosmetic, camera, GUI, financial and endurance evidence remains historical and unchanged; those engine suites and full-project Studio Script Analysis were **not rerun** after this early artwork stop. Last v1.1 analysis 0/0 is not claimed as a fresh v1.2 run.
- No new instance/redraw/loading/memory/device measurements exist because no material was integrated. Physical touch/gamepad acceptance remains outstanding.

## File inventory and next step

Added `assets/illustrated-world-v12-ground-study/`: two raw PNGs, two actual-resolution repeats, two subdivision diagnostics, two repeat contact sheets, one motif/zoom sheet, `validate_and_preview.py`, `validation.json`, `provenance.json` and README. Added this report; updated PLANS/DECISIONS. Existing validator evidence files were refreshed by their established scripts. Existing game/test source, atlases and v1.1 artwork were preserved.

**Do not upload either candidate.** Review the retained attempts, then use a controlled periodic raster-authoring correction: exact-size canvas, offset-wrap seam painting across both axes, suppression of diagonal bands, palette matching and full repetition review. Resizing alone will not repair periodicity. An exact source/hash can only be supplied for upload after that work passes. No asset ID, upload destination action or default adoption is authorized by this report.

Native remains default. No real DataStore, Rowanbridge, Production, settings, asset upload, permissions, gameplay, publication, deployment, commit or push was touched. No new proof that continuous landscapes are achieved: the sprint stops incomplete at its explicit artwork-review gate.
