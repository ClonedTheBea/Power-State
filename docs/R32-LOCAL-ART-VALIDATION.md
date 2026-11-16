# R3.2 local artwork validation

**Subsequent R3.2a review:** the owner accepted the five non-coast motifs for proof use. [Coast refinement validation](R32A-COAST-VALIDATION.md) records atlas revision 2, reduced colour mismatch and unresolved strict-opacity/endpoint-overlap gates. The report below remains historical evidence for revision 1, not current acceptance status.

15 November 2026. Local production complete as a review candidate; **coast join needs revision**. Owner visual acceptance, upload and integration are pending. R3.1 remains the running native baseline.

## Deliverables and scope

Produced [1024×1024 atlas](../assets/r32-proof-v1/power-state-map-proof-v1.png), six transparent motif exports, original generated sources, six-layer OpenRaster source, [projected-size contact sheet](../assets/r32-proof-v1/contact-sheet.png), pivot/coast diagnostics, [manifest](../assets/r32-proof-v1/manifest.json), exact prompts/provenance, repeatable local packer and machine-readable results in [the artwork folder](../assets/r32-proof-v1/README.md).

All planned atlas content rectangles, 8px gutters, world canvases, pivots and anchors are unchanged. Artwork is fitted uniformly into each content canvas with internal transparent breathing room. Exports are straight-alpha RGBA with embedded sRGB; resizing uses premultiplied alpha, then nearby RGB is dilated eight steps into transparent texels without expanding alpha. Empty allocations/gutters have zero alpha. Sources are not screenshots or a whole-country background.

Built-in OpenAI image generation produced each motif independently from recorded text briefs. Tool model name was not exposed. No input reference images, stock downloads or new dependencies were used. Generated originals and hashes are retained. Rights/exclusivity are not guaranteed by provenance; owner rights and destination review remain prerequisites for any upload. The editable source has independent raster motif layers, not semantic/vector building or tree objects.

## Checks actually run

`python assets/r32-proof-v1/build_local.py` passed **70 assertions**: RGBA/dimensions, six cell bounds/nonoverlap, transparent gutters and unused allocations, exact sprite-to-atlas bytes, transparent/opaque/intermediate alpha, pivot round-trips at five planned zooms, six 64-world-unit overhang bounds, embedded sRGB and OpenRaster archive integrity. Results are recorded in [validation-results.json](../assets/r32-proof-v1/validation-results.json). PNG checksums are in the manifest. Existing Pillow 10.0.0 was used.

Visual inspection covered generated motifs, the contact sheet, pivot overlay and local native-coast proxy. Contact-sheet canvases use exact logical sizes at zoom 1 and 0.55, on representative sage land/teal ocean. View at 100% scale; app fit-to-window is not an actual-size test. The coast proxy is enlarged 2× for seam inspection and approximates one native rounded land patch, not a complete renderer. OpenRaster archive structure was checked without opening a painting application.

| Check | Result |
| --- | --- |
| Six motifs, readability | Coast, three-peak ridge, forest, fields, town and twin-stack station remain distinguishable at normal and minimum-zoom local previews. Fine furrows/roof details disappear at minimum size as expected. |
| Alpha/background | Transparent irregular silhouettes and antialiased edges; no opaque rectangular matte or baked labels/lines/selection. No conspicuous light matte in inspected previews; uploaded filtering is untested. |
| Pivots | Planned coordinates preserved exactly; cyan diagnostic crosses lie within appropriate ground/cluster areas. These overlays are not in exports. In-game association with markers remains untested. |
| Style/lighting | Soft painted forms, generally upper-left highlights and short shaded lower-right edges. Forest/fields and architecture have different relief/detail density; owner cohesion review remains necessary. Town is traditional and station more architectural. |
| Coast join | **Needs revision.** Native meadow hides the square east connection as intended, but its flat grass boundary visibly cuts across painted land; shoreline transitions are abrupt. Central overlap is ample, but endpoint/tangent/quiet-band acceptance is not met. |
| Memory/performance | No Roblox result. Atlas base arithmetic is 4 MiB uncompressed RGBA, independent of PNG file size. No frame-time, memory or instance claim. |

The [artwork README](../assets/r32-proof-v1/README.md#coast-revision-handoff) records provisional local-world join targets/tangents and a focused coastline production handoff. They are geometry targets, not approved artist sockets. Revise grass blending and both coastline joins within the unchanged rectangle/pivot; preserve the shore-before-native-meadows order. Do not move the country or add gameplay to conceal seams.

## Preservation and remaining work

Source/test/script/config/contributor-instruction SHA-256 comparison against the pre-production snapshot passed. No gameplay/GUI source, renderer, map coordinates, dependencies or Roblox IDs changed. No upload, commit, push, publish or deploy occurred. Roadmap, decision log and planning status were updated only for this local production step. Existing unrelated workspace changes were preserved.

Rojo builds, runtime tests, Studio and device profiling were **not run**: this task creates unintegrated local artwork only. Prior R3/R31 checks are not claimed as results for these images. No visual acceptance is inferred from automated checks.

Recommended next step: owner review of the contact sheet and coast diagnostic, followed by a focused local coast revision. Upload/integration remain separately authorized work and should wait for acceptable joins, final artwork checksums, rights review and a named destination. R4/R5/P2 remain untouched.
