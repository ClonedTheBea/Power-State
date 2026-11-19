# Illustrated World v1 — isolated Test renderer validation



19 November 2026. Owner accepted the eighteen R1 motifs for an experimental Test proof, not final landscape acceptance. **Experimental renderer implemented and measured; overall acceptance remains limited by the retained legacy test mismatch and incomplete endurance reruns below. Native remains the default.** No real DataStore access, Production change, settings/permission change, upload, publish, deployment, commit or push belongs to this proof.



## Verified uploads and frozen sources



Verified in authenticated Studio edit mode, guarded by Test universe `10776833313`, personal creator `149564436`, and Studio user `149564436`. Marketplace metadata identifies `missawfulname` as the personal owner of both uploads. The submitted diagonal ID is a Decal; `InsertService:LoadAsset` returned its actual Texture/ColorMap dependency, then the transient model was destroyed. The dependency's own metadata identifies the same owner and matching upload name.



| Atlas | Actual Image ID | Exact source PNG SHA-256 |

| --- | --- | --- |

| Main terrain, 1024×1024 | `96236605552471` | `d8d3994469c68f31d800cadec9c8e3aeda3d25ecd3693c6140e781c402c5b0cb` |

| Diagonal, 512×256; Decal `73359575646217` | `133413370857301` | `e669e58a0b8b32d0f19f21025b79cc878eed134ed285ad4880353b6d580fd62f` |

| Original R3.2 revision 3, unchanged | `86222383311104` | `e1dcb61948e575bab85d94a6eed3dce1939fe87389455fc3bce735a28cab63cb` |

| R3.7 settlements, unchanged | `90608851718773` | `baff92a631e89bbf9a1506f5401488e40fc2d5fe56a71399b1f410df5b05ff4e` |



The two new hosted images were additionally decoded using `AssetService:CreateEditableImageAsync`, `ReadPixelsBuffer` and `EncodingService:ComputeBufferHash(...Sha256)`. Their **complete decoded RGBA pixels, including alpha, exactly match** local PNG decoding:



- Main RGBA: `45639a686c62f464fb5d2966ca63a3a1870c756a9818c20f72062716e95a60fe`.

- Diagonal RGBA: `ca4cc3a6eb27d5208ed0cc49f3396270ea57bb903c2f26bdf8de64054e988d02`.



These are decoded-pixel checksums, distinct from PNG file-byte hashes. Temporary EditableImages were destroyed. No image was substituted, repacked or uploaded. Frozen R1/R32/R37 manifests remain unchanged; resolved IDs live in a separate Test catalog. [Verification record](evidence/illustrated-world-v1/asset-verification.json). Public-domain/for-sale metadata was false; this is not a new Creator Dashboard privacy-setting audit. Actual client ImageLabel readiness is tested separately below.



## Implementation and bounded behavior



- `tests/integration/IllustratedWorld/IllustratedAtlasCatalog.luau`: approved R1 rectangles/pivots and four allowlisted Image URIs. Existing town/gas/forest/field/village crops are reused, with generated-country cosmetic anchors; old fixture manifests stay frozen.

- `IllustratedSectorDescriptor.luau`: known 1024-square, 289-sample version-1 descriptor. Uses the same NW-sample ownership as `GeneratedTerrain`, all fourteen mixed occupancy classes, fixed north-up art and no rotations/mirroring. Interior 15×15 junctions only: unknown neighboring sectors are not invented ocean. No climate, construction legality, demand or flow calculation.

- `IllustratedSectorRenderer.luau`: one fixed **96 ImageLabel pool**, shared as four readiness probes and 92 draw slots. It reuses the Native terrain root and UIScale. Complete visible shores are allocated first, then known infrastructure/pylons, then bounded decoration. If visible shores exceed 92, the whole visible sector stays Native. Panning creates no GUI instances or load requests. Native cells remain underneath; graph connections, labels, hit targets, selection and controls remain separate above.

- `IllustratedAtlasSession.luau`: reuses `SpriteAtlasLoader`'s five-second observer deadline/cancellation. At most one actual fetch per each of four approved atlases per Play client, shared across remounts. Terminal failure does not retry on camera movement or repeated mode switches. A fresh Play session is the explicit retry boundary. Uncancellable engine requests cannot multiply through remounts; destroyed observer callbacks cannot revive a pool.

- `IllustratedController.luau`: reuses Layers → Geography's existing accessible button and shell action registry for **Native / Illustrated (Experimental)**. Native is initial. The pool is allocated lazily after choosing Illustrated. Selection, inspector, country and camera are not replaced by mode changes.

- `AppController.luau`: a guarded optional attachment discovers this Test-only module after mount. No catalog, loader, renderer or new texture URI is mapped into Production. `test.project.json` exposes an optional proof flag; explicitly false disables it, while retained regression runs remain isolated.

- `HybridPresentation.luau`: reuses accepted R3.5 compact badges with an explicit generated marker count; old default five-marker contract remains. Targets remain the same 44px buttons. Avoids assigning unchanged art parents during camera draws. Native restores the original presentation.

- New pure/client tests, `IllustratedRun.client.luau`, independent retained diagnostic runners, and `scripts/ValidateIllustratedRenderer.py` cover the isolated implementation. No server gameplay, world generation, economy, persistence, electrical coordinates, topology or artwork files were changed.



The proposed district's existing Native preview stays available, but occupied-house/pylon artwork is withheld until the existing server-derived `PreviewOnly` flag explicitly becomes false. The renderer does not issue a construction request. Other assets use bounded cosmetic ground offsets; the electrical nodes/line endpoints remain unchanged. Pylons occupy genuine line segments and are omitted near other segments' crossings, avoiding implied electrical junctions. Unsupported wind/peaker illustrations remain native glyphs.



## Investigation corrections



1. A running Rojo process retained an older project attribute set. The optional Test attachment no longer relies on a newly added attribute being present; explicit false still disables it. Native remains initial.

2. Initial string preload callbacks did not establish the required ImageLabel readiness. Actual probe labels are preloaded. Fully transparent/offscreen labels were culled and stayed `IsLoaded=false` despite successful downloads. Four near-transparent screen-space pixels now warm textures; drawing labels also warm at near-zero opacity before the complete layer is exposed. Native remains beneath throughout. Loader and label deadlines remain five seconds; no timeout was increased.

3. The first responsive test attempted to focus a marker behind the modal mobile inspector. The test now asserts a valid active-scope focus target: map marker on desktop, inspector close control when mobile modal rules apply. It still checks exact focus/selection/inspector preservation.

4. Screenshot review found that lazy attachment initialized culling with an empty viewport until the next pan. The renderer now initializes from the existing camera attributes/viewport; a regression requires nonempty drawing immediately after readiness without camera movement.



## Geography and local evidence



- Studio pure contract suite: **4,179 assertions** before the final retained rerun; all sixteen occupancy classes, exhaustive 512 small arrangements, known-boundary uniqueness, crop/gutter/pivot validation, deterministic replay, and actual WorldGenerator fixtures.

- Independent integer reference rerun: **10,000 seeds × four reservation rotations**, nine million interior-junction inspections. Natural maximum remains **78**, seed `fe0512aa351b994df1656b88f0d94f1b` (corpus index 2408). All-four-rotation maximum is **80**, still within 92. [Exact corpus result](evidence/illustrated-world-v1/corpus.json).

- Diagonal fixture: corpus index 38, seed `12fee3f76be963c09033cdfd9ccffb36`, pattern 6 at world `(192,640)`.

- Static catalog/art/Production-isolation suite: **79 assertions**. [Results](evidence/illustrated-world-v1/static-validation.json).



The independent corpus is a geography reference, not a replacement for the retained Luau fairness/route/solver suite. Actual engine performance, regression outcomes and screenshots are recorded below.



## Ground treatment assessment and separate proposal



Actual Studio rendering makes forests, fields and terrain relief recognizable, but large flat green/tan Native cells and angular ownership edges remain dominant. This does **not** match the softly blended Westhaven concept. The illustration improves landmarks without changing the authoritative coastline. At minimum zoom, hills/pylons are small; compact badges help buildings remain visible. Categorical tan-to-green boundaries and the painted shore's transition into those colors remain visible. Do not claim final visual acceptance from source port equality or successful image loading.



Recommend a separately approved small ground study:



1. One seamless, low-contrast, north-up temperate grass texture, proposed 256×256 RGBA, no landmarks, roads, shadows or baked labels. Local production and owner upload only after approval; no new image is included here.

2. Reuse the **existing 256 Native cell slots**, replacing their Frame presentation with same-count image presentation in the experimental branch, or investigate one repeated land layer with exact cell clipping. Do not add 256 descendants. Keep 600 unchanged; four existing atlas families and masks stay intact. Initial raw texture estimate 0.25 MiB, approximately 0.33 MiB with a full mip chain, not a measured Roblox allocation.

3. Blend cosmetic colors only across land-land boundaries, using supplied elevation/biome fields; never blur the categorical water boundary or modify world generation. Prototype a bounded precomputed color treatment rather than adding per-frame geometry or claiming that a flat tile tint is smooth blending.

4. Review land/shore joins at all five zooms and minimum-size readability. Reject any approach that leaks grass into water, shifts the coast, hides infrastructure, exceeds the descendant cap or changes climate/gameplay arithmetic.



This is a proposal, not permission to produce/integrate ground art. The owner acceptance gate remains before default adoption or additional artwork.



## Studio reproduction



Connect **Power States - Test** to the Test Rojo project, start ordinary fake-storage Play, open **Layers**, and select **Illustrated (Experimental)**. Native is selected at startup. Allow the bounded load to finish; any failure leaves Native usable. Switch back using the same button. Use normal map pan/zoom, Recenter, asset selection, Locate, inspector, and construction review. No real save mode is needed or authorized.



For isolated automated geometry fixtures, in Test edit mode run `require(game.ServerScriptService.DevelopmentTests.unit["IllustratedWorld.spec"])()` and serialize its returned two fixture previews into a StringValue named `IllustratedFixtures` under ReplicatedStorage. Set `RunIllustratedTests=true`, with `RunRegressionTests=false`, and restart Play. `IllustratedRun` runs actual texture, layout, focus, pool, synthetic failure and performance checks. Disable `RunIllustratedTests` afterward. The capture fixture's built/unbuilt toggle is a **presentation test**, not a purchase or durable save.



Physical touch/gamepad and low-end-device acceptance remain separate. Desktop Studio layout/frame measurements cannot establish those results.



## Actual rendering and matched measurements



The final renderer suite passed **2,774 assertions** at 15:08 UTC. This includes actual four-atlas ImageLabel readiness, first draw without camera input, two generated seeds, all five supported zoom levels, four responsive sizes, 44px hit targets, camera/selection/inspector/focus preservation, culling, fixed pool counts, remount cleanup and synthetic denied/failed/timeout/late-callback cases. Synthetic failures are not claims of inducing a real Roblox moderation failure.



Matched 180-frame paths in desktop Studio, milliseconds:



| Fixture/mode | CPU p50 / p95 / worst | Frame p50 / p95 / worst | Map descendants |

| --- | --- | --- | --- |

| 38 Native | 0.438 / 0.574 / 0.805 | 16.587 / 17.592 / 18.086 | 470 |

| 38 Illustrated | 0.575 / 0.782 / 1.191 | 16.630 / 17.575 / 17.988 | 470 |

| 2408 Native | 0.467 / 0.574 / 0.768 | 16.605 / 17.616 / 18.249 | 470 |

| 2408 Illustrated | 0.669 / 1.008 / 1.227 | 16.633 / 17.632 / 18.357 | 470 |



Native measurements include the dormant comparison pool and compact-badge objects. They are not the allocation count of a never-enabled Native shell. [Raw measurements](evidence/illustrated-world-v1/performance.json). Whole-client GraphicsTexture was 41.714 MiB before and after these warm paths; this does not isolate atlas GPU memory. Four source atlases total 9 MiB decoded RGBA, approximately 12 MiB with a complete mip chain: estimates only. Actual readiness was 55.664 ms on fixture 1 (29.907 ms session observer) and 31.221 ms on fixture 2 warm remount (14.900 ms observer); total fetch count remained four. A guaranteed cold network/cache measurement was not available; first mount and warm remount must not be labelled cold-download measurements.



## Genuine Studio visual evidence



These are actual Studio captures using hosted textures, not Pillow composites. Fixture names come from the approved name pool. The maximum-complexity fixture happens to be named Rowanbridge but has ID `illustrated-fixture-2`; it is **not the persisted Rowanbridge country**.



- Matched fixture 38: [Native](evidence/illustrated-world-v1/studio-seed38-native.jpg), [Illustrated](evidence/illustrated-world-v1/studio-seed38-illustrated.jpg).

- [Second seed / maximum natural 78 junctions](evidence/illustrated-world-v1/studio-seed2408-maximum78.jpg).

- [Diagonal coastline at 1.8 zoom](evidence/illustrated-world-v1/studio-diagonal-zoom180.jpg).

- [Selected gas generator](evidence/illustrated-world-v1/studio-built-fixture-gas-selected.jpg), [selected substation](evidence/illustrated-world-v1/studio-built-fixture-substation-selected.jpg).

- [Tablet 900×744](evidence/illustrated-world-v1/studio-tablet-900x744.jpg), [portrait 390×700](evidence/illustrated-world-v1/studio-mobile-390x700.jpg), [short landscape 640×360](evidence/illustrated-world-v1/studio-landscape-640x360.jpg).

- Ordinary fake-storage playable journey: [unbuilt](evidence/illustrated-world-v1/studio-fake-playable-unbuilt.jpg), [saving](evidence/illustrated-world-v1/studio-fake-purchase-pending.jpg), [durably confirmed in fake storage](evidence/illustrated-world-v1/studio-fake-purchase-confirmed.jpg), [built and selected district](evidence/illustrated-world-v1/studio-fake-playable-built.jpg). The 1,000-Credit purchase used genuinely earned fake income; confirmed Bank was 329.10 Credits. Occupied artwork appeared only after confirmation, and the selected district subsequently showed 0.802 MW requested/delivered. This was not a real DataStore transaction.



OS mouse drag and keyboard Right navigation were exercised on the portrait safe root; art and graph remained aligned. These are desktop Studio safe-root tests, not physical touch or controller acceptance. No obvious adjacent-sprite bleeding or opaque rectangular backgrounds were seen in these captures. At high zoom the unknown outer-sector rim exposes abrupt painted-strip terminations; Native boundaries remain authoritative. Flat land colors, small relief/pylons and visible shore/ground color changes remain visual limitations.



## Retained regression evidence and unresolved gate



The pure/fake batch passed P2a, P3c, P3cSafety, FirstPlayable, P3cRegression (including retained P3a/P3b persistence and accounting), FleetSolver and the 10,000-seed P3c world/route corpus. P2b world reported 2,916,780 assertions, zero fallback countries, generation p95 16.522 ms and maximum snapshot 43,705 bytes. The exact solver reported 8,854 assertions and its 2,187-case oracle. [Pure log](evidence/illustrated-world-v1/retained-pure-log.txt).



A separate actual Test-server run passed Operations atomicity/security/scenario/lifecycle, reinforcement model/transaction/economy/resources, and all 63 eight-country scheduling intervals, including native/30 Hz and 15 Hz stress, with zero safely suspended countries in this run. An earlier edit-mode invocation correctly rejected server-only context; that invocation is not counted as a pass. [Runtime log](evidence/illustrated-world-v1/retained-runtime-log.txt).



The ordinary full legacy client sequence passed P2a/P2b GUI and both 32-assertion actual remote transport suites, then failed P3c's `Completed review excludes disabled purchase from traversal` at 15:24:29. Inspection showed the current redesign's valid `Generation · Later` category control selected, with the completed purchase disabled. The historical assertion requires Close to be the only selectable control, which is no longer the approved UI layout. No construction or focus runtime change was made to conceal this mismatch. The legacy suite remains a **failed overall gate**, pending a focused test-contract update; this proof does not claim all regressions pass.



Independent reporting runs the later retained presentation/endurance suites with the original placeholder mount that the normal runner establishes after P3c. An initial independent attempt incorrectly used the live shell; R1 waited for static `BANK` while live presentation uses `BANK · LIVE`. That harness setup was corrected without editing R1. New diagnostic runner type warnings were corrected with explicit named records and static require paths. Full-project **edit-mode** Script Analysis then showed 0 errors / 0 warnings, with Current Script Only disabled. [Analysis capture](evidence/illustrated-world-v1/studio-script-analysis.jpg).



Independent legacy presentation results: Gui **364**, R1 **16**, R2 **135**, R3 **190**, R3.1 **52**, R3.3 **739 synthetic**, R3.5 **241** assertions passed. R3.7 actual original/settlement textures and benchmarks ran successfully, with 120 recorded movement cycles at a stable 595 descendants. Its ten-minute endurance run was deliberately interrupted to run current redesigned GUI acceptance after the earlier failed legacy gate; **R3.7 completion, R3.4 and the later Native/P2b ten-minute suites are not claimed as passes in this sprint**. [Independent client log](evidence/illustrated-world-v1/retained-client-log.txt). These limitations must remain visible rather than treating the reporter's partial run as full acceptance.

Both Rojo builds, source/security boundaries, whitespace and all sixteen retained static validators passed after the final typed-runner corrections. [Static results](evidence/illustrated-world-v1/retained-static.json). New diagnostic runners are opt-in Test-only and ordinary startup does not run them.


## Closeout and next action

Implementation inventory: the five `tests/integration/IllustratedWorld` modules and their engine suite; `IllustratedRun.client.luau`, `IllustratedRetained.client.luau`, `tests/unit/IllustratedWorld.spec.luau`, `tests/unit/IllustratedRetained.server.luau`; the two new Python validators; optional AppController Test attachment; bounded-count HybridPresentation support; Test project flag; roadmap/decision/art-audit follow-ups; this report and its evidence directory. Existing art PNGs/manifests, authoritative server modules, financial schemas and real execution gates were not changed.

The next technical action is to align the retained P3c completed-review focus assertion with the already-approved category controls, retaining disabled-purchase exclusion and modal focus containment, then finish the interrupted legacy endurance sequence. This is a test-contract issue observed with Illustrated disabled, not evidence that an asset failed to load. No all-regression acceptance is asserted here. Physical touch/gamepad, low-end hardware and guaranteed cold-cache timing also remain outstanding.

Separately, the owner should review the genuine map captures and decide whether to commission the small ground study described above. No additional artwork or default adoption follows automatically. Native remains the normal renderer, the experimental choice is Studio/Test-only, and all storage used during this sprint was fake. No real profile reads/writes, Production changes, settings changes, uploads, publication, deployment, commits or pushes occurred.


Final current-GUI run completed at 15:44:14 UTC: **6,097 visual acceptance checks**, Operations GUI **130**, paging/focus **101**, remote security **38**, quote refresh **20**, reinforcement journey **27**. Actual 30-second quote expiry, normal fake purchase, subsequent natural peak (6 MW delivered), release/reconnect and permanent receipt/Bank restoration passed. Fleet, Bank and review each retained zero descendant additions/removals and zero full layout calls during twelve-second live-update windows. These results validate the current redesigned flow; they do not erase the historical P3c assertion failure above. [Current GUI log](evidence/illustrated-world-v1/current-gui-log.txt).

All temporary runner flags were cleared and Play stopped after validation. The next ordinary Test Play opens the fake-storage country in Native, with Layers offering the opt-in Illustrated comparison. No test remains advancing in the background.
