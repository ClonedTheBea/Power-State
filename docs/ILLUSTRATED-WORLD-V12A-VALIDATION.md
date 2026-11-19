# Illustrated World v1.2a — controlled ground and local continuity proof

19 November 2026. **Completed local material/comparison sprint; stopped for owner visual and renderer-contract review.** One substantial local correction approach produced the recommended candidate. No runtime ground renderer, hosted image, permission change or default adoption. V1.2's rejected candidates remain intact; this report does not relabel them as successful.

## Material and provenance

[Recommended1024x1024 RGBA PNG](../assets/illustrated-world-v12a-ground/temperate-ground-v12a.png),800,503 bytes, opaque alpha. SHA-256:

`107448465ac25fc182841da2eeb706bec04a2774401641161301745393d3f1e2`

The derivative uses both retained v1.2 AI source experiments. Source edit hash `52794fb984fa6d89a2da90f9c7baaac0a6119b0f20886f1a126bf82f04963712`; fresh-source hash `40141e82eb999ea2e6dd9735b32f3972e58ddb00dbb8a28e40888e464deabaa3`. No new image generation. Exact steps, seeds and source paths are in [material record](../assets/illustrated-world-v12a-ground/material-validation.json); [package/reproduction](../assets/illustrated-world-v12a-ground/README.md).

Approach1: Lanczos resample sources; average luminance power; mix92% radial/8% directional power; smoothly suppress wavelengths longer than approximately73px and excessive high-frequency grain; reconstruct with deterministic Hermitian phases on a1024-square periodic domain. Add quiet periodic meadow variation, then map to native RGB107/132/99. Seed120019, grain standard deviation1.9 and broad variation1.05. This is a source-derived synthesis, not an untouched painting or a resize-only correction. It removes prominent diagonal bands without creating objects, roads, rivers or shadows. No second substantial approach was needed.

Mean output RGB106.996/131.996/98.996. Colour-channel standard deviations2.19/2.08/1.87. The material intentionally stays quiet beneath infrastructure; it will not supply the reference's terrain relief by itself. Lighting is nondirectional at ground scale, compatible with the unchanged north-up/upper-left-lit sprites.

## Repetition and visual decision

[Before/after](../assets/illustrated-world-v12a-ground/before-after-repeat.png), [2x2 actual pixels](../assets/illustrated-world-v12a-ground/repeat-2x2-full.png), [4x4 actual pixels](../assets/illustrated-world-v12a-ground/repeat-4x4-full.png), [magnified wrap junction](../assets/illustrated-world-v12a-ground/edge-examination.png), [five zooms/motif compatibility](../assets/illustrated-world-v12a-ground/motif-five-zooms.png).

| Diagnostic, RGB channel levels | Wrap X / Y mean | Interior adjacent X / Y mean | Wrap X / Y maximum |
| --- | --- | --- | --- |
| Raw8-bit |0.754 /0.725|0.737 /0.742|3 /3|
| Periodic Gaussian1.5px |0.255 /0.265|0.264 /0.266|1.323 /0.959|
| Periodic Gaussian4px |0.081 /0.112|0.095 /0.095|0.284 /0.445|

No copied equal border hides a discontinuity. End pixels are adjacent periodic samples and need not be identical. Raw wrap p95 is2 levels, matching interior p95; raw interior maximum is5. Filter tests operate on wrapped local arrays, not Roblox filtering. Forty-two local contract checks include dimension/hash/alpha, preserved sources, seam diagnostics, negative-coordinate phase, sixteen256px crops and a bounded synthetic colour ramp. The1.3x seam-mean diagnostic is an investigation check, not a newly imposed owner/runtime acceptance threshold.

Visual inspection: the correction removes the previous conspicuous diagonal repetition and shows no obvious square joins in the inspected2x2/4x4 and enlarged wrap previews. Recommended for **owner review**, not declared owner-approved. Forest/field/building artwork remains legible at all five zooms; existing pylon is still tiny at minimum zoom. Hills and settlement bases are warmer than the ground and remain individually recognizable patches. That limitation is shown rather than repainted or hidden.

## Actual descriptors and matched comparisons

Studio edit mode was verified as Test Universe10776833313 with Play stopped. Existing pure `IllustratedWorld.spec` generated the same two fixtures; its4,179 assertions passed during export. A transient unparented clone supplied the current composition-v2 module and was destroyed. There was no service startup, DataStore read/write or purchase.142 bounded log chunks reconstructed the descriptor JSON; large initial chunks were truncated and discarded. A decorative middle-dot in one description became a replacement character in the log; coordinate/identity/numeric fields are intact.

| Local comparison | Geometry and framing |
| --- | --- |
| [Normal](../assets/illustrated-world-v12a-ground/country-normal-comparison.png) | seed`12fee3f76be963c09033cdfd9ccffb36`; fixture1;36 shores; full1024 sector scaled to600x600 |
| [Diagonal junction](../assets/illustrated-world-v12a-ground/country-diagonal-comparison.png) | same fixture; crop(64,512)–(320,768), same600x600 view across all three modes |
| [Maximum complexity](../assets/illustrated-world-v12a-ground/country-maximum-comparison.png) | seed`fe0512aa351b994df1656b88f0d94f1b`; fixture2;78 shores; full-sector600x600 |
| [Connected district](../assets/illustrated-world-v12a-ground/country-connected-district-comparison.png) | same fixture2, existing surveyed terminal/feeder shown as built for presentation only |

These are **local artwork simulations, not actual Studio renders**. Native terrain is reconstructed from the real elevation-colour rule; labels/lines are schematic. Approved atlas crops, pivots and exported asset/decorative coordinates are unchanged. The illustrated/proposed panels share exact selected entries and the92-slot cap; maximum cases use92 and the normal case66. No imaginary assets fill gaps. Curated name Rowanbridge in fixture2 is not real Rowanbridge: country IDs are `illustrated-fixture-1/2`.

The proposed treatment visibly reduces rectangular land-land colour steps and the broad tan block boundaries. It preserves the angular land/water boundary. Existing sprite bases and repeated hill forms remain visible. No new river/channel/junction is painted, and transmission anchors/connections are untouched. The result is a credible continuity improvement, **not a match to the full illustrated inspiration or a completed terrain redesign**.

## Continuous colour contract — local proof

The proposed cosmetic function reads the existing17x17 elevation/rainfall/temperature samples without mutating them. For local u,v in a64-unit cell, use smoothstep `s(t)=t*t*(3-2*t)` in a bilinear interpolation. Shared vertices and edge interpolation are identical from either cell. Fields drive a restrained meadow-to-hill blend, soft low-elevation earth tint and bounded climate tint. Formula and constants are in `composite.py`; they are cosmetic candidates, not approved world-generation or balance rules.

Both actual fixtures have rainfall1000mm and temperature17C, so climate tint is neutral. A separately labelled synthetic colour ramp exercises nonconstant climate values; it is not invented geography. Across93,600 independently evaluated edge comparisons per view, maximum shared-field error is0. The synthetic colour ramp's maximum neighbouring-pixel difference at cell boundaries is0.00298 channel levels. Reassembling256 cropped64px cells exactly reproduces each continuous output image.

Material phase uses4 source texels/world unit, repeating every256 world units, with local downfiltering to1 output pixel/world unit. Global floor/modulo coordinates handle negative positions. Ownership remains **the original NW-sample categorical mask**, never the interpolated elevation sign. Normal mask815,104 land pixels; maximum700,416. Every original water background pixel remains unchanged before the same approved shore overlays. Edge evidence is in [composite validation](../assets/illustrated-world-v12a-ground/composite-validation.json).

Uniform ImageLabel colour cannot implement this: different per-cell tints multiply the same boundary texture into different colours. A global tint removes steps but loses spatial variation. Hundreds of gradients are not the proposed solution.

## Runtime feasibility and approval boundary

Official Roblox documentation describes EditableImage pixel buffers, ImageLabel content referencing and a1024-square limit; editable allocations have client memory constraints. This establishes API surface, not support/performance in this Test build or on devices. [EditableImage reference](https://create.roblox.com/docs/reference/engine/classes/EditableImage). Allocation failure must be handled rather than assuming sufficient memory. [AssetService reference](https://create.roblox.com/docs/reference/engine/classes/AssetService).

**Proposed smallest practical padded study:** four512x512-world-unit cosmetic chunks, each514x514 pixels including a1px neighbouring-sample gutter. Reuse the existing256 terrain slots as ImageLabels,64 per chunk, with no per-cell gradients and no new decorative GUI instances. One whole1024 image is smaller in object count but has no room for a genuine outer gutter at that resolution. Four chunks keep integer cell crops and internal neighbouring samples; a future known-sector boundary requires the real neighbour field, never fabricated terrain. Unknown boundaries remain clipped exactly as now.

This is a **different rendering resource contract requiring owner review**, not implemented code. Four RGBA chunk payloads total4,227,136 bytes (~4.03MiB); the source is4MiB raw. Source CPU pixels and one staging buffer could add roughly5.01MiB before engine overhead. These are arithmetic estimates, not measured GPU/Roblox memory. A smaller resolution is a fallback proposal, not silently substituted here. Worst-case client allocation,1px-gutter filtering under zoom, ImageRect/content interaction, exact edge alignment and update scheduling remain untested. One pixel may not cover wider mip/filter footprints; that must be measured rather than assumed safe.

Future Test feasibility must be capability-gated, cancelable, bounded per-frame, cached by immutable descriptor/art revision, and never run synthesis per pan/zoom. All chunks must be ready before switching; allocation/read/permission/fetch/timeout failure keeps Native visible and releases resources. Remount tests must show cleanup and stable counts. Never change settings to force support. No runtime EditableImage, whole-sector buffer or terrain replacement was implemented during this sprint.

## Checks actually run

- Local material reproduction, dimensions/alpha/hash, repeat/crop/edge diagnostics: pass; one correction approach.
-42 local contract assertions: pass, including synthetic climate-ramp separation.
- Four matched comparisons: exact mask, same overlays and256-cell reassembly pass;93,600 edge comparisons each (two unique worlds, some repeated views).
- Pure Studio fixture suite during export:4,179 assertions pass. The unchanged full-project edit Script Analysis panel shows0 errors/0 warnings with current-script filtering off: [capture](../assets/illustrated-world-v12a-ground/studio-edit-analysis.jpg).
- Both Rojo builds, source/remote/real-persistence gates and Git whitespace: pass.
-80 frozen-art/catalog/build-isolation checks: pass. Original approved atlas hashes retained in the local validation record.
- No Luau/runtime source changes. Prior v1.1 GUI, camera, financial,10,000-seed and endurance results remain historical; not rerun or presented as new material runtime acceptance.
- No actual Roblox image loading/filtering, GPU, redraw, new descendant count, mobile-device or gamepad/touch result for the new material.

## Proposed owner upload and Test integration procedure

1. Review the material, repeats, all four comparisons and remaining motif/coast limitations. Approve the exact material/hash separately from the padded-chunk runtime contract.
2. If proceeding, the owner manually uploads only `assets/illustrated-world-v12a-ground/temperate-ground-v12a.png`, after SHA verification, to personal Development Items under missawfulname/User149564436, Restricted, intended for Test Universe10776833313. No composite/fixture PNG or approved atlas replacement. Production10776828545 excluded. This report does not grant upload permission or change access settings.
3. Owner supplies the returned ID. Verify ownership/type/access; resolve a Decal's actual Image dependency if needed, and compare the downloaded image pixels to the approved derivative. Never invent an ID or reuse another image.
4. Separately authorize the bounded Test capability/resource proof. Verify existing account/API prerequisites without changing settings; stop on denial/unsupported allocation. Test crop/gutter filtering at all zooms, loading/failure Native fallback, masks/anchors,256 slot reuse,600-map ceiling, selection/camera and cleanup. Measure CPU/loading/frame/memory on actual clients. Do not claim Studio's memory allowance establishes device safety.
5. Keep Native default. Owner reviews actual hosted-texture screenshots/performance before any broader renderer decision. No real persistence/gameplay authority follows.

## Inventory and stop

New local folder `assets/illustrated-world-v12a-ground/`: corrected PNG; editable Python production/comparison/check scripts; source/metric records; pure fixture export recipe and JSON; actual repetitions; edge/crop/motif studies; four matched comparison sheets plus full local panels; synthetic colour diagnostic; edit-mode Script Analysis capture. This report, PLANS and DECISIONS updated. Existing source/artwork/default preserved.

Stopped at owner visual and runtime-contract review. No uploads, permissions/settings changes, real DataStores/Rowanbridge, Production, publication, deployment, commits or pushes. Current terrain and gameplay remain unchanged in Roblox.
