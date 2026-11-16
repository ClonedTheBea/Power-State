# R3.2a coast refinement — local validation

Subsequent [R3.2b local raster correction](R32B-COAST-VALIDATION.md) fixes source opacity and the central grass seam without changing coordinates or accepted motifs. Endpoint naturalness and one filtered-alpha sample remain open. This report preserves the revision-2 evidence.

15 November 2026. Local refinement delivered for review; colour seam reduced, **complete coastline join acceptance still unmet**. The owner accepted the mountain, forest, agriculture, settlement and gas-station revision-1 motifs for proof use. That approval does not cover the revised coast, upload or integration.

## Changes

Created [atlas revision 2 package](../assets/r32-proof-v2/README.md) with a revised coast source/export, repacked atlas/OpenRaster, contact sheet, pivot/coast diagnostics, before/after and five-zoom sheets, manifest, exact prompts and validation scripts/results. Revision 1 remains intact apart from a README navigation/status note. The other five source/export images are byte-identical to revision 1.

Used the built-in imagegen edit tool on the original coast. The selected fourth edit retains painted rock relief and lighting while replacing much of the yellow grass cast with cooler sage. Three quieter/flat-grass edits were rejected after interior-alpha inspection. No scripted repaint, alpha fill, coordinate change, borrowed asset or runtime source edit was used. Packing still uses uniform premultiplied-alpha resizing and RGB edge dilation without alpha expansion. Editable sources are raster images/layers, not editable individual rock objects.

All atlas rectangles, 8px gutters, pivots, world canvases, ground anchors, visual bounds, fallback mappings and shore-before-meadow render order are unchanged. Coast art revision and atlas revision increment to 2; accepted motifs remain art revision 1. The manifest stores the acceptance distinction and image hashes.

## Actual local results

| Validation | Result |
| --- | --- |
| Local atlas packer | **70 assertions passed**, covering dimensions/RGBA/sRGB, bounds/nonoverlap, transparent gutters/unused regions, alpha variation, atlas/export equality, pivot arithmetic at five zooms, overhang bounds and OpenRaster integrity. |
| Coast comparison script | **152 assertions passed**, including unchanged descriptors, ten accepted source/export hashes, nonzero-alpha central probes, lower sampled colour mismatch and no zero-alpha holes in the specified inland sample. Passing assertions do not include the failed strict-opacity gates below. |
| Colour seam measurement | Mean absolute RGB channel mismatch to native sage at 46 fixed points, y=340..385 and 2 world units outside the native boundary: **12.2639 → 7.6118**, a **37.93% reduction**. Includes compositing over ocean using preserved alpha; 4× geometry proxy, not a perceptual metric. |
| Inland alpha | Content sample x=220..459, y=170..319 has alpha **249–253**, not fully opaque 255. **Strict opacity gate fails.** Original generated translucency is preserved, not silently normalized. |
| Endpoint overlap | At inherited proposed north/south probes, the tested 16-unit interior bands each contain alpha 0. **Both strict overlap gates fail.** These were provisional points, not approved matching cliff sockets. |
| Visual review | Cooler grass reduces the yellow discontinuity; the native circular meadow still makes a visible texture cut and both shoreline ends remain abrupt. Rock lighting and broad coastal identity retained. |
| Zoom/background diagnostics | Generated and inspected comparison sheets at 0.55, 0.72, 1, 1.2 and 1.8; separate coast previews against land/ocean. Atlas sampling in Roblox remains untested. |

The newer comparison harness respects the half-unit origin `(93.5,238.5)` with 4× supersampling and native rounded meadow geometry. The inherited `coast-join-check.png` retains the earlier rounded-placement proxy for continuity. Compare before/after within the same new harness, not different rasterizers. Both are limited local approximations, not full map renderers.

Precise proposed boundary probes and north-to-south native tangents:

| Probe | World point | Content-local world point | Native tangent |
| --- | --- | --- | --- |
| North | 187.92286,299 | 94.42286,60.5 | -0.37714,0.92616 |
| South | 187.12275,429 | 93.62275,190.5 | 0.36571,0.93073 |

See [machine-readable coast results](../assets/r32-proof-v2/coast-validation-results.json), [before/after](../assets/r32-proof-v2/coast-before-after.png) and [contact sheet](../assets/r32-proof-v2/contact-sheet.png). No matching artwork tangent or seamless tiling is claimed.

## Preservation and next step

Source/test/script/config hashes and all five accepted source/export hashes were compared to the pre-task snapshot. No runtime/gameplay, dependencies, map coordinates, Roblox upload/IDs, commits, pushes, publishing or deployment. Local packer and diagnostic scripts are confined to the asset package. Documentation records approval and the unresolved join gates.

No Rojo/Studio/runtime tests or performance profiling were run for this unintegrated art-only task. Local image results cannot establish Roblox filtering, overlay readability or physical-device performance.

Recommended next step: review the reduced-seam candidate. To meet the full join contract, a precise raster-paint pass should make the quiet native-sage band and both endpoint overlaps opaque, match the shoreline tapers and repeat the same checks. Further visual acceptance, upload and integration remain separate; R4/R5/P2 are untouched.
