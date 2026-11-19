# Illustrated World v1 — proposed production handoff

**No artwork or upload-ready PNG is included.** This is a proposed-design handoff boundary, not a new asset library. `proposed-manifest.json` is a packing/pivot template only. Existing approved atlases remain untouched. No asset IDs are invented.

## Smallest coherent landscape batch

One proposed 1024×1024 atlas, sixteen 256-square allocations with 8px gutters and 240-square content:

1. Four cardinal shoreline strips. North means water north / land south; east means water east / land west, and so on. Paint each direction independently; rotating an image would rotate the light.
2. Four convex land corners, named for the water-facing corner. Four concave land corners, named for the land-facing corner. These complete the orthogonal boundary vocabulary of the current sampled Native silhouette. Opposite edges share a colour/alpha profile. Ambiguous diagonal land contacts remain two disconnected shapes; do not invent a bridge or channel.
3. Two low, snow-free rolling-hill clusters, suitable for temperate sampled relief. No snowy mountains or baked vegetation biome boundary.
4. One recognizable substation yard and one small transmission pylon. Electrical terminals and line connections remain native overlays. Pylons decorate genuine line segments only; crossings do not create junctions.

These are sixteen small images, not sixteen new runtime pools. Ship the shoreline vocabulary together: a single reusable headland does not solve procedural joins. Existing gas, town, rural village, forest and field art is reused. New field/forest transition variations are a later optional batch if the initial composite exposes halos; do not expand the library before review.

## Exact art contract

- Soft elevated 2.5D strategy illustration, north up, fixed camera angle matching Newford/gas originals, upper-left light and short lower-right shadows. Flat underlying coordinates; no perspective transformation of endpoints.
- Quiet sage/olive land, muted ochre fields, cool grey rocks and navy/teal shallow water. Sample the approved atlas and Theme terrain roles; no neon terrain, baked labels, routes, cyan wires, selection, smoke animation or UI.
- Shore source centre pivot120,120. Nominal64×64 world canvas. Central boundary follows the documented orthogonal edge/corner; no offshore islands, protruding headlands or inland ponds. Visual rim occupies at most8 world units each side. The native land/water mask remains canonical, and the compositor must clip each side to that mask. Do not change the generator to match the art. This contract is a proposed presentation design, not an already validated compositing implementation.
- Hill pivot120,184, nominal96-square world canvas. Relief rises above the ground point; fit the footprint entirely on eligible dry sampled terrain. Eligibility must use supplied elevation/temperature/rainfall, not generate new climate. No extra resource/terrain-cost claim.
- Substation pivot120,184, nominal80-square; pylon pivot120,184, nominal32-square. Footprint and projected minimum-size readability must be confirmed locally. Cosmetic ground anchors derive from genuine nodes/lines. Changing art must never move a terminal.
- Keep content aspect ratio. Do not trim sources after pivot review. Preserve transparent padding, straight alpha and RGB edge dilation inside transparent gutters. No hard grass rectangle or opaque ocean matte. Match land-facing colour/texture transitions against multiple native elevation colours, not only one green swatch.
- Check all supported zooms0.55/0.72/1/1.2/1.8 at100% display and both land/water backgrounds. Require recognizable silhouettes at minimum zoom; tiny decorative details carry no operational information.

## Sources, naming and provenance

Retain editable layers/source where practical, individual transparent exports, prompt or artist/source/licence record, original-file hashes, revision history, a native-boundary join contact sheet and a checksumed packed PNG. Use `sources/<artId>-source.*`, `sprites/<artId>-r1.png`, `power-state-terrain-edges-proof-v1.png`, `manifest.json` and `validation-results.json`. Record whether sources are generated, commissioned or original; do not claim exclusive rights from AI generation. Reuse the established local production workflow; no new service, dependency or upload automation is proposed.

The manifest template records all allocations/pivots. Before integration add actual hashes, source provenance, compatible edge probes, projection bounds, owner visual acceptance and actual verified Roblox Image ID. The template itself must never be consumed by the renderer.

## Upload handoff, after artwork acceptance

Owner manually uploads the exact reviewed/checksummed PNG under personal `missawfulname`149564436, Restricted, for Power States - Test10776833313. Confirm current destination and permissions before upload; do not change them automatically. Owner supplies the returned ID. Resolve Decal-to-Image through the previously verified supported method if needed; never reuse an old atlas ID for new pixels. Production10776828545 stays untouched. There is no upload action, file checksum or permission request to approve yet because this atlas does not exist.

## Memory and fallback

One1024-square RGBA base level is4MiB, approximately5.33MiB with a full mip chain. With the two existing atlases the nominal combined base levels are8.5MiB (about11.33MiB with full mip chains). This is planning arithmetic, not measured Roblox memory or download size. Atlas sharing does not guarantee draw-call batching. Native remains available before loading and on timeout, denial, missing regions or invalid descriptors. No retry per camera movement; bounded per-mount preload and cancellation.

## Review gate

Review the boundary grammar and smallest batch before local artwork production. Then inspect all joins and same-seed composite previews before owner upload. A subsequent Test renderer proof must pass the existing600-descendant limit, camera/focus/controls, real readiness, bounded culling/remount, matched native/illustrated timing and world/gameplay regression gates. Nothing in this handoff authorizes a new default renderer.
