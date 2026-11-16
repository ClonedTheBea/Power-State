# R3.2 — modular illustrated art proof plan

15 November 2026 · Planning complete · Subsequent local artwork proof produced; coast join revision needed

R3.2a update: five non-coast motifs are owner-accepted for proof use. A [coast-only local refinement](R32A-COAST-VALIDATION.md) reduces the colour seam but does not satisfy the complete join contract. Atlas layout/pivots and runtime/upload gates remain unchanged.

R3.2b update: separately authorized [local raster correction](R32B-COAST-VALIDATION.md) removes the inspected grass seam and makes source inland/endpoint bands opaque. Natural cliff termination and one filtered-alpha sample remain unresolved; no owner acceptance or integration approval is inferred. Native geometry, atlas layout and accepted motifs are preserved.

16 November R3.3 update: owner accepted all six motifs for an isolated proof. [Mock renderer integration](R33-VALIDATION.md) now implements bounded placement/replacement, synthetic load states and test-only comparison. No upload or real asset ID; Native remains default. The plan's real delivery/filtering/device gates still require later approval and evidence.

This document records the original planning task. Subsequently, the owner approved the six-motif atlas specification for **local artwork production only**. See [local artwork validation](R32-LOCAL-ART-VALIDATION.md) for produced files and the unresolved coast join. R3.1 remains the running baseline and missing-art fallback. Runtime modules, performance thresholds and integration below remain proposals, not measured hybrid results or upload approval. Historical planning evidence below remains unchanged. No external Roblox asset IDs are supplied.

Read with [GUI vision](GUI-VISION.md), [layout](GUI-LAYOUT-SPEC.md), [components](GUI-COMPONENT-SPEC.md), [R3.1 strategy](R31-ART-STRATEGY.md) and [R3.1 validation](R31-VALIDATION.md).

## 1. Proof scope and art direction

Recommend one 1024×1024 atlas containing six motifs, placed once each in the existing country. This narrows the earlier R3.1 candidate of up to two atlases and a larger motif list. Decide whether painted detail materially improves the map while native interaction stays reliable. A full library, all coastline orientations, city tiers and procedural generation are excluded.

Use softly illustrated 2.5D relief, north up, fixed elevated view, upper-left light and short lower-right shadows. Match Theme's muted land/forest/field/stone/roof/water roles. No animation, baked UI text, cyan connections, selection, condition or ownership graphics. Keep the flat 1200×800 preview plane and five asset IDs/coordinates. Art never determines connectivity, terrain legality or production.

Compare Native and Hybrid through a test-only renderer option using identical camera/selection state. Do not add a player-facing map layer or change Geography/Labels/Sample connections. Native remains the default until acceptance. This proof is not permission to ship a hybrid or build a full asset library.

## 2. Atlas and required assets

Proposed export: `power-state-map-proof-v1.png`; sRGB, 8-bit-per-channel RGBA PNG, transparent canvas. Editable layered sources and provenance accompany it. No screenshot crops or whole-country illustration.

Rectangles use integer top-left pixel coordinates. Each allocated cell has an 8px gutter on all sides. ImageRectOffset/Size select the inner rectangle, excluding the gutter. Leave transparent breathing room inside the content for relief/shadows; trimming an export requires pivot revision.

| Art ID, revision 1 | Cell x,y,w,h | Content offset x,y | Content size w,h | Required depiction |
| --- | --- | --- | --- | --- |
| coast-headland | 0,0,512,512 | 8,8 | 496,496 | Irregular west-facing headland, shore/cliff and shallow fringe; east side joins native land |
| mountain-ridge | 512,0,512,256 | 520,8 | 496,240 | Three unequal peaks, rocky facets, restrained snow and foothill shadow |
| forest-cluster | 512,256,256,256 | 520,264 | 240,240 | Bounded mixed-height cluster with irregular silhouette; no per-tree instances |
| agriculture | 768,256,256,256 | 776,264 | 240,240 | Fields, hedgerows and subtle furrows, transparent outer contour |
| settlement | 0,512,256,256 | 8,520 | 240,240 | Low-rise town/civic landmark and short streets; no people or labels |
| gas-station | 256,512,256,256 | 264,520 | 240,240 | Turbine halls, twin exhaust stacks, compact yard; no nuclear cooling towers |

Unused space stays transparent. Produce a separate contact sheet at actual projected sizes against ocean and land. The native substation remains a control for overlay readability.

```text
1024 px
+----------------------+----------------------+
|                      | mountain ridge       | 256
| coast / headland     +-----------+----------+
|                      | forest    | fields   | 512
+-----------+----------+-----------+----------+
| town      | station  | reserved transparent | 768
+-----------+----------+----------------------+
|             reserved transparent            | 1024
+---------------------------------------------+
```

### Transparency and sampling

Use antialiased alpha, no opaque matte/checkerboard. Keep shadows within motif bounds. Dilate nearby RGB into transparent edge texels during export and isolate gutters; this precaution does not guarantee Roblox processing preserves those RGB values. Inspect uploaded images against ocean/land for halos, neighbouring-cell bleed and downsampling artefacts. Revise alpha/gutters before increasing resolution blindly.

Proposed ImageLabel settings: BackgroundTransparency=1, white ImageColor3, ImageTransparency=0, Active/Selectable=false, no rotation, smooth resampling. Preserve source aspect ratio in world-space Size; Stretch is then uniform. No nine-slice terrain. ImageRectOffset/Size support sprite sheets; zero rectangle dimensions select the whole image, so reject them. IsLoaded must not be awaited indefinitely, particularly for moderated images. These facts were checked in the [official ImageLabel documentation](https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/ImageLabel.yaml); actual filtering still needs Studio/device testing.

## 3. Pivots, coordinates and edge compatibility

Manifest fields: artId/artRevision, atlas revision/key (no ID until approved), sourceRect, worldCanvasSize, pivotPx relative to content, groundAnchorWorld, fallbackPatchIds, renderOrder, visualBounds, edgeProfile and provenance record. Freeze validated descriptors. Art identity is separate from cosmetic patch/asset identity. Invalid entries retain native art.

| Motif | Existing cosmetic patch suffix (`art1:0:0:`) | Ground anchor x,y | World canvas w,h | Content pivot x,y |
| --- | --- | --- | --- | --- |
| Coast | west-cape | 217.5,362.5 | 248,248 | 248,248 |
| Ridge | highlands | 587.5,180 | 248,120 | 248,120 |
| Forest | wood-west | 290,422.5 | 150,150 | 120,120 |
| Fields | fields | 772.5,430 | 160,160 | 120,120 |
| Settlement | newford | 755,300 | 150,150 | 120,160 |
| Station | industry | 340,345 | 150,150 | 120,160 |

Town/station cosmetic ground anchors sit below their unchanged marker anchors `(755,250)` and `(340,320)` to accommodate elevated silhouettes. Review their visual association; adjust cosmetic pivots only, never markers or transmission endpoints.

For source dimensions `(cw,ch)`, world canvas `(ww,wh)`, pivot `(px,py)` and ground anchor `(ax,ay)`:

```text
worldTopLeft = (ax - px * ww/cw, ay - py * wh/ch)
screenTopLeft = cameraOffset + zoom * worldTopLeft
screenSize = zoom * (ww, wh)
```

Inside TerrainArtwork's existing UIScale root, set world position/size and apply zoom once through the parent. Keep 44px screen-space marker targets in their separate layer. Preserve 0.55–1.8 zoom, hysteresis, framing, Locate and camera retention. At maximum zoom, 240px motifs project to 270–288 logical pixels; some enlargement is expected and needs high-DPI review. No extra zoom textures in this proof.

Cull using full visual bounds including relief/shadows, not the pivot alone. Require artwork to fit within the existing patch's 64-world-unit overhang allowance; reject or explicitly revise/test bounds otherwise. Keep line culling independent.

### Coast join test

Retain native ocean and surrounding land. Replace only west-cape's shore/meadow bundle. Its east join overlaps native west-land in a quiet grass band, without cliff/shadow crossing the interior join. Paint this sprite in the shore/base pass before neighbouring native meadows; other sprites replace artwork in the ordinary terrain pass. Never overlay a rectangular ocean background over native land.

Proposed `west-headland-v1` contract: east overlap at least 16 world units; artist records two coastline join points and tangents in local world coordinates, matching native shore intersections. Require opaque interior coverage with no double-dark shadow, water wedge, gap or rectangular edge at tested zooms. If the single motif cannot join cleanly, revise it rather than remodel the country or silently add assets.

Future descriptors retain edge classes, ordered coast/river/road sockets, coordinates/tangents, overlap bands and art revision. A versioned authoring contract supplies matching neighbours; sprites are not square world sectors. A bounded seam harness repeats/repositions motifs without rotating or mirroring baked lighting. One headland proves one join, not a complete tile set. Future generation chooses compatible cosmetic descriptors from authoritative terrain; no generation or ownership system is implemented here.

## 4. Practical Roblox integration

Retain MapView's separate terrain, infrastructure, connection, label and selection containers. After implementation authorization, extend only `Views/Map` and a development harness:

| Proposed module/responsibility | Boundary |
| --- | --- |
| SpriteManifest | Immutable six-motif records, source rectangles, pivots and fallback mappings |
| SpriteAtlasLoader | One-atlas load state and cleanup; injected clock/fetch adapter for faults; no gameplay remotes |
| SpriteTerrainRenderer | Fixed six ImageLabels, existing transform/culling, no authoritative calculations |
| TerrainRenderer extension | Native/sprite bundle visibility ownership; preserve native constructors |
| DevelopmentTests A/B harness | Change art mode without remounting shell, losing selection or moving camera |

Retain all native fallback instances, even when hidden. Add six ImageLabels under existing roots, with no per-frame allocation. When ready, atomically show a sprite and hide only its matching native bundle. Land bundles include both the shore entry and meadow; restore both on failure. All unrelated patches and overlays stay native. On return to Native, visibility still obeys culling/detail rules, not unconditional Visible=true. Do not rebuild the GUI for comparisons.

Proposed loader states: Unconfigured→Native, or Loading→Ready/Failed/TimedOut. Native appears immediately. Once an approved atlas is configured, issue one session request off the UI startup path using PreloadAsync. Check completion status and each ImageLabel's readiness. At 5 seconds without usable art, retain native and record a test diagnostic. Timeout does not cancel the engine request: use mount/revision tokens to ignore late callbacks after timeout, mode switch, revision replacement or destruction. One attempt per atlas revision per mounted proof; no retries on pan/zoom. Explicit test remount can retry. No modal error or fake gameplay alarm for cosmetic failure.

PreloadAsync yields and reports per-asset completion status; asset-fetch status signals are also available. Use bounded readiness checks with cleanup, not an endless IsLoaded loop or RequestQueueSize percentage. See [official ContentProvider documentation](https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/ContentProvider.yaml). EditableImage, runtime raster generation and a new framework are unnecessary for this proposal.

Roblox-hosted delivery requires approved artwork and usable permissions for the intended owner/experience. A local image or manifest mock cannot validate delivery. Before upload approval, a separately authorized code task may use an injected fake loader, explicitly labelled as mock evidence. Do not import through Studio to bypass the upload gate.

## 5. Rendering and memory estimates

| Item | Estimate or prior evidence |
| --- | --- |
| R3.1 baseline | 574 map / 929 shell descendants, 22 patches; 600 map ceiling |
| Proof pool | Six added ImageLabels: approximately 580 map / 935 shell including hidden fallback; 20 descendants headroom |
| Uncompressed RGBA base arithmetic | 1024×1024×4 bytes = 4 MiB |
| Hypothetical full mip chain | Approximately 4/3 of base = 5.33 MiB; model only |
| Two-atlas alternative | 8 MiB base / about 10.67 MiB with that model; unnecessary for six motifs |
| Visible work | At most six sprite rectangles; no allocation or atlas reassignment per pan. Fewer visible native shapes do not guarantee faster GPU time |

Byte estimates exclude compression/transcoding, streaming, CPU copies, caches and engine overhead. They are not measured usage or an upper bound. Blank regions still consume texture dimensions. Hiding/culling does not promise texture eviction. Retaining native fallback deliberately saves no native instance memory. One reused atlas ID avoids intentional duplicate textures, but does not guarantee one draw call. Roblox's [performance guidance](https://create.roblox.com/docs/performance-optimization/improve) explains pixel-dimension costs and texture reuse.

Benchmark Native/Hybrid on the same device, settings, viewport and camera path. Record hardware, Studio/client version, graphics settings, first encounter versus warm load, atlas readiness time, GraphicsTexture/total memory, descendants, CPU map-draw p50/p95 and frame CPU/GPU timings. Run three warm passes per mode: 360 draw samples plus 120-frame movement loops per selected size. Add a ten-minute resize/pan soak after integration. Use separate restarted runs for baseline texture-memory comparisons; switching to Native does not unload a cached atlas. Disclose cache limitations rather than calling a fresh GUI a cold download.

Proposed gates: ≤600 map descendants; no growth after initialization; same-device warm p95 map draw below 1ms; no repeatable frame-time regression above 10% against baseline. The 10% threshold triggers repeated investigation, not a statistical claim. Target at least 30 FPS on an agreed low-end physical device. Investigate incremental texture memory above 12 MiB for this one-atlas proof; that is a review threshold, not predicted Roblox allocation. Missing hardware remains an open acceptance gate.

## 6. Tests and acceptance criteria

| Area | Required future evidence |
| --- | --- |
| Manifest | Six unique art IDs; positive integer nonoverlapping rectangles/gutters inside 1024²; preserved aspect ratios; finite pivots/bounds; invalid revision/entry falls back |
| Coordinates | Pivot formula within 1px rounding at zoom 0.55, 0.72, 1, 1.2 and 1.8; unchanged five asset coordinates/three endpoints; no double scaling; full shadow culling |
| Coast/alpha | Both join endpoints approved; no halo, rectangular ocean, gap, atlas bleed or doubled shadow; seam harness does not imply full tile compatibility |
| Input/overlays | Lines, labels, markers and brackets above relief; ≥44px hit targets and overlap picker retained; sprites do not intercept dragging; keyboard/gamepad/touch paths unchanged |
| Failure | Unconfigured, invalid rect, denied/deleted/moderated image, failure, delay beyond 5s, late callback, remount and revision replacement retain/restore native without stale writes |
| State | Framing, repeated pan/zoom/Recenter/Locate; route/A-B changes preserve selection/camera; Layers and label toggles work; no gameplay pause |
| Responsive | Safe roots 360×580, 640×300, 768×960, 1024×708, 1366×704, 1920×1020; rotation with selection; 100/125/150% text; physical cutouts/touch separately |
| Regression | All existing suites including R3/R31; both Rojo builds; Script Analysis; counts, timing/memory comparisons and ten-minute soak; no server/remote change |
| Visual | Owner recognises six motifs, prefers Hybrid at normal viewing size, approves lighting/palette and infrastructure readability; tests alone are not visual acceptance |
| Provenance | Source/export/licence records complete; approved checksum/owner before upload; no reference screenshot material |

Synthetic load tests prove lifecycle behavior only. Actual access, filtering and delivery failures require approved assets in an isolated environment. Record passed/failed/not run separately; do not present R3.1's 1,091 assertions as R3.2 results.

## 7. Implementation plan and approval gates

1. **Current task — planning only:** atlas, six briefs, pivots/joins, integration, estimates and test plan. No art or source changes.
2. **Separate art-production authorization:** create local editable motifs, atlas and contact sheet; record provenance. Review coast/ridge/station together first to lock lighting and scale. Any later authorized generated art records tool/model/date and editing history; reference images confer no licence.
3. **Owner art/upload approval:** review actual export, checksum, destination Roblox owner/experience and rights record. Plan approval alone is not upload approval. Upload only approved artwork, then record returned IDs. Game publishing remains separate.
4. **Separate implementation authorization:** implement the narrow modules and test-only harness, with native fallback pools and fault tests. Start with atlas key unconfigured; never borrow example asset IDs.
5. **Isolated Studio proof:** regressions, failure/seam tests, matched A/B screenshots and profiling. Normal build retains fallback; harness stays in test mapping. Default remains Native pending acceptance.
6. **Decision:** adopt the six-motif proof, revise, or retain native. Record owner visual verdict and hardware gaps. Full library/procedural integration requires new scope. Stop before R4/R5/P2.

Provenance fields: art ID/revision; artist/tool/date; sources/references and permitted use; licence/commission terms covering modification, game distribution and platform upload; source/export hashes; third-party dependencies; owner review; approved destination/date; Roblox ID only after approval. Unclear rights block that motif, not the native map. This is a rights-record workflow, not a legal assurance.

## 8. Planning validation

Official API sources checked on 15 November 2026. This task checks atlas bounds/gutters/nonoverlap, aspect/pivot/bounds arithmetic, memory arithmetic, documentation file links and Git whitespace, and compares source/test/config/art hashes before/after. No new build, Script Analysis, runtime or hybrid performance result is claimed: executable content is unchanged and no atlas exists yet.

Observed planning checks: all six atlas cell/content rectangles and gutters passed bounds/nonoverlap checks; all six proposed canvas aspect ratios, pivot round-trips and 64-unit overhang bounds passed. Texture/count arithmetic, Markdown local file links, UTF-8 checks and `git diff --check` passed. SHA-256 comparison confirmed **56 source, test, script, config, reference/art and contributor-instruction files unchanged**. A pre-existing CRLF conversion warning in COMPANY-PROFILES is not a whitespace failure.

Created this plan; updated README.md, PLANS.md, DECISIONS.md and R31-ART-STRATEGY.md for navigation, scope and proposal status. No artwork, code, tests, dependencies, Roblox configuration or asset IDs changed. Studio was not operated for this planning task.
