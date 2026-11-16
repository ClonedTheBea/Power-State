# R3.1 map art strategy and asset proposal

15 November 2026. Owner-authorized visual refinement; no asset upload or external artwork introduced.

Follow-up: [R3.2 planning](R32-ART-PROOF-PLAN.md) narrows the proposed proof to six motifs in one atlas. The broader candidate below remains historical; no art or uploads are approved by planning.

## Recommendation

Use the refined native renderer for the present review and as the permanent missing-art fallback. For the reference's richer illustrated finish, prefer a **modular raster/native hybrid**, subject to approval of a small art proof and measured device performance. This is an engineering recommendation, not an implemented or benchmarked sprite renderer. Do not spend the remaining native instance budget chasing painted texture with hundreds of tiny Frames.

| Approach | Visual quality | Performance tradeoff | Maintenance and expansion |
| --- | --- | --- | --- |
| Native GUI geometry (implemented) | Clean silhouettes, controllable palette, modest relief; rounded coasts and triangular peaks remain stylised | No texture download; bounded reusable instances. More artistic detail costs descendants and property/raster work | Easy code review and recolouring; shapes become cumbersome for painterly terrain. Reusable cosmetic descriptors remain suitable for bounded sectors |
| Modular illustrated sprites | Strongest individual landform/building detail and coherent baked light | Fewer objects per motif, but texture memory, transparent overdraw, download and loading failures must be measured; fewer instances alone does not prove faster rendering | Requires source art, pivots, gutters, variant discipline and revisioning. Avoid one texture per tiny tree and avoid a whole-country image |
| Raster terrain with native overlays (recommended next art proof) | Painted terrain and landmarks with crisp readable lines, labels and hit targets | Fixed visible-patch pool plus unchanged overlay pool; compare cold/warm load, texture memory and frame timings against native baseline | Swap artwork behind stable world coordinates. Native interaction and fallback remain independent. Sector edges need compatible connection metadata |

Roblox supports atlas subregions through ImageRectOffset/ImageRectSize on image UI; see the [official image API](https://create.roblox.com/docs/reference/engine/classes/ImageButton). Texture dimensions, rather than compressed file size alone, matter for memory planning; see [Roblox performance guidance](https://create.roblox.com/docs/performance-optimization/improve). Measure GraphicsTexture and CPU/GPU/frame timings on target hardware using the [performance tools](https://create.roblox.com/docs/performance-optimization/identify). The proposed benefits above are inferences, not claims of automatic batching or guaranteed memory savings.

## Coherent art grammar

Fixed elevated oblique view, north up, upper-left light, short shadows cast lower-right. Muted green/ochre land, quiet blue water, warm roof tones, pale stone and restrained snow. No baked cyan electricity, UI text, selection, ownership, condition, demand or production values. Relief decorates the flat world plane; marker/line anchors never move with mountain height. Buildings share roof/wall lighting. Newford is denser with a civic tower; Southbank is low-rise with gardens; Eastmere has a coastal pier. Westhaven is a gas station with turbine halls and twin exhaust stacks. Roads/pylons are explicitly cosmetic, with no legal-path or powered-network claim.

## Proposed asset specification — not approved for upload

A small proof set before a full library:

- Two transparent coast/headland motifs and one inlet transition; each nominally 256–512 px, with separate land/water edge masks and a documented world-space footprint. No island-wide image.
- One mountain ridge and one hill cluster, two forest clusters, two agricultural patches, one lake/ribbon junction. Compose bounded regional clusters rather than per-tree sprites.
- Three settlement silhouettes (capital, rural, coast), one gas station, one substation, one pylon motif. Nominal 128–256 px; preserve recognisability at 44–64 displayed pixels.
- Start with at most two 1024×1024 RGBA atlases for an A/B proof; this is a candidate budget, not a platform limit. Keep 4–8 px transparent/extruded gutters and test sampling at all supported zooms. Do not mirror directional lighting to create variants.
- Every entry records art ID/revision, atlas rectangle, nominal world width/height, ground pivot, overhang (initially at most 64 world units), edge/junction compatibility, palette and fallback kind. Stable asset IDs are separate from art revision. Archive editable source, artist/source, licence and approval status with each exported image.

Proposed implementation: a bounded cosmetic sprite adapter behind TerrainRenderer, using the existing fixture coordinates and culling bounds. Load approved atlas IDs once per session; retain native art until a texture is usable and on failure. Do not allocate per pan/zoom or defer selection on artwork. Keep marker/line/label/selection containers and their input contracts unchanged. Art descriptors cannot become server terrain legality or ownership data.

Acceptance before adopting sprites: owner approves a representative coast/mountain/settlement proof; explicitly authorizes uploads to the intended Roblox owner; test alpha seams, pivots, zoom detail, missing/denied/delayed textures, orientation, descendant stability, cold/warm load, texture memory and repeated map motion on actual low-end hardware. No image production/upload or renderer adapter is included in R3.1.
