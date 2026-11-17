# R3.7 — Real settlement integration and validation

## Real integration update — isolated proof complete

The owner subsequently authorized real settlement integration in Test only. Decal **138420314032574** resolves through `InsertService:LoadAsset` to **Image 90608851718773**: both Texture and ColorMap agree. The temporary container was never parented to the scene and was destroyed. MarketplaceService metadata reports types 13 and 1 respectively, both named `power-state-settlements-proof-v1`, creator User **149564436 / missawfulname**. [Verification record](../assets/r37-settlements-v1/roblox-verification.json) retains the returned metadata. The exact local SHA-256 is unchanged. Test Studio edit-mode fetch succeeded and its visible ImageLabel reported IsLoaded=true; no permissions were altered. This verifies observed access, not every possible deployment/privacy configuration.

Implemented only under `tests/integration/`:

- `SettlementProfiles.luau`: immutable Original/Settlements descriptors. Original references the frozen approved six-motif manifest unchanged. Settlements reassigns slots 3/4 to Southbank/Eastmere, with the approved pivots/anchors and verified new image URI.
- `SettlementAtlas.luau`: bounded, asynchronous six-label/two-atlas preload and readiness adapter. At most one ImageLabel-based preload per atlas per mount (two total), shared across profile observers. Five-second timeout, expected-URI checks, fetch-status checks and cancellation ignore late engine callbacks. Direct URI-string preload returned Failure in the diagnostic probe; actual ImageLabel-based fetches succeeded. The implementation retains that verified class-specific loading path, without changing permissions or adding probe labels.
- `SettlementRenderer.luau`: six ImageLabels allocated once per mount, reused across both profiles. Native restores during loading/failure and profile reassignment. Parent camera scaling, culling and coastline pass order are preserved. Profile switches cancel old readiness work before changing slot contents. No per-pan/zoom allocation.
- `SettlementProof.luau`: Studio-client/Test-universe guard; Native default; existing R3.5 compact badges/contextual names; Test-only profile/mode attributes. Normal production builds include none of these modules or new IDs. The previous `HybridProof` and its renderer remain unchanged.
- `R37.spec.luau` and the existing client runner: real profile regression, responsive geometry, six-label identity, selection/inspector/camera, input targets, culling, labels, readiness loss, benchmarks, ten-minute profile soak, synthetic denial/timeout/late callbacks, teardown/remount. Existing suites remain in the sequence.
- `scripts/ValidateR37.py`: new atlas/profile contract and production/Test build isolation checks (27 local assertions).

The comparison deliberately restores native forest and fields while showing Southbank/Eastmere; it does not display eight simultaneous sprites. All future tier development remains a cosmetic descriptor contract, not implemented gameplay. New renderer code is confined to the test mapping to avoid changing production code or broadening the original frozen validator.

Current validation: both builds and 128 local static/artifact checks pass (83+14+4+27). The final Test Studio run passed all suites and three ten-minute endurance checks; results and captures follow. Earlier preparation results and upload-boundary text below are historical, not the current stopping point.

Test-harness corrections retained coverage rather than weakening production behavior: displaced native regions obey camera culling; mobile inspector sheets must close before map focus; a virtual 960px safe root can extend beyond the physical Studio viewport, so actual SelectedObject checks apply only to physically visible eligible targets. Other virtual targets retain selectable/action/accessible-name/selection-image checks. These are logical layout tests, not a claim of portrait-emulator input coverage.

### Real settlement results — 16 November 2026

The final run began at 21:21:53 UTC. R3.7 passed **1,411 assertions**, including actual texture/placement/profile tests and explicitly synthetic denial, timeout and stale-callback cases. Its **600.1-second endurance run completed 589 cycles**, retaining **595 map descendants** and six sprite ImageLabels. Teardown restored the 574-descendant native map and actual-texture remount passed. The retained R3.4 suite also passed **259 assertions** and **600.8 seconds / 591 cycles**, maintaining its 935 whole-shell descendants. The final Native endurance suite passed **600.9 seconds / 591 cycles**, maintaining **929 whole-shell descendants**. All suites completed: **3,717 assertions** total (350 server, 1,480 earlier client, 217 R3.5, 1,411 R3.7 and 259 R3.4). The total includes labelled synthetic tests; it is not a count of real-service assertions alone.

Initial measured readiness was **32.617ms Original / 32.188ms Settlements** in this Studio session. Cache state was unknown; these are not cold-download measurements. Profile changes reused at most two atlas preload operations per mount. Script Analysis with Current Script Only disabled reported **0 errors / 0 warnings** ([capture](r37-screenshots/script-analysis.png)).

| Test mode | Safe-root size | Draw p50 / p95 (ms) | Frame p50 / p95 (ms) | Map descendants |
| --- | --- | --- | --- | --- |
| Native | 360×580 | 0.067 / 0.472 | 16.61 / 17.64 | 595 |
| Original | 360×580 | 0.066 / 0.435 | 16.63 / 17.61 | 595 |
| Settlements | 360×580 | 0.065 / 0.480 | 16.62 / 17.70 | 595 |
| Native | 1366×704 | 0.066 / 0.099 | 16.62 / 17.66 | 595 |
| Original | 1366×704 | 0.083 / 0.218 | 16.66 / 17.63 | 595 |
| Settlements | 1366×704 | 0.071 / 0.113 | 16.64 / 17.62 | 595 |

These matched scripted paths measure CPU draw work and Studio desktop frame intervals. Native here is the comparison mount with its fixed allocated sprite/badge pool, not the 574-descendant production baseline. No isolated new-atlas texture-memory or GPU cost was measured. Logical safe-root tests are not physical-device performance evidence.

### Actual rendering captures and inspection

- [Desktop Native](r37-screenshots/desktop-native.png) / [desktop Settlements](r37-screenshots/desktop-settlements.png): identical 1394×551 map root; camera `(322.2459016393,25.6639344262)`, zoom `0.6245901639`, confirmed by logged attributes. Studio chrome is intentionally retained in these evidence captures.
- [Southbank selected](r37-screenshots/desktop-southbank-selected.png): actual mouse selection opens the Southbank inspector and preserves its outline/contextual label. Clicking Locate closes the inspector and retains the selected asset.
- [Mobile safe-root Native](r37-screenshots/mobile-safe-root-native.png) / [Settlements](r37-screenshots/mobile-safe-root-settlements.png): same 360×580 safe root, 344×376 map, camera `(-268,-26.5)`, zoom `0.55`. Recenter and actual mouse drag were exercised before the matched pair; switching modes did not move the map.
- [Unfiltered Script Analysis](r37-screenshots/script-analysis.png): zero errors and warnings.

These are real Roblox-rendered textures, not local composites. The mobile pair uses a manually constrained safe root inside desktop Play, **not Device Simulator or physical touch hardware**. Device Simulator was disabled during the running session; a dedicated emulator orientation/input pass and physical-device testing remain outstanding. Automated layout tests covered 360×580, 640×300, 768×960 and 1366×704; all five supported zooms and engine selection/targets, profile switching, labels, culling, readiness loss/recovery and remount were exercised.

Both settlements appear at the approved cosmetic anchors with compact badges and readable native transmission overlays. No adjacent-cell bleeding or obvious rectangular alpha halo was observed in the captured views. This is an inspection result, not owner visual acceptance. At minimum zoom the roof-cluster silhouettes are useful, but gardens and small coastal details are not dependable information. The flat native forests/fields visibly contrast with painted settlements and relief; that is the deliberate six-slot trade-off. Eastmere's coastal character is small at this scale, and native substation geometry remains visually simpler. No new terrain artwork or geometry was introduced to conceal those limitations.

[Measurement record](R37-MEASUREMENTS.json) retains the final run's timestamped outputs. Studio also emitted temporary HTTP-cache file warnings; the application suites continued and passed. No application assertion failure occurred in this final run. Earlier interrupted/failed harness runs are not counted as successful evidence.

### Completion and recommendation

Implementation and isolated Test validation are complete. New files: five `Settlement*`/`R37.spec` Test modules, `scripts/ValidateR37.py`, verification/measurement records and screenshots. Updated the Test runner, this report, asset-package README, roadmap, project README and decision D64. No production source was changed by this integration; earlier uncommitted R3.4/R3.5 work is preserved. Both approved atlases and placement manifests remain byte-for-byte unchanged.

Test Play was stopped after capture. Rojo remains connected to the Test project on port 34873. No upload, permission change, publish, commit, push, production modification or new gameplay occurred. Native remains the normal default, and build checks prove the new modules and Image ID are absent from the production build.

Recommended next step: owner review of the matched settlement captures, followed by a focused device-emulator/physical-device usability and performance pass before any default-renderer decision. Retain the six-slot comparison and Native fallback; do not expand terrain assets or begin another phase without authorization. The historical package manifest below records the preparation milestone; the separate verification record holds the confirmed upload relationship and runtime access evidence.

### Comparing in Test Studio

Serve `test.project.json` on 34873 only. Restart Play after sync and let the runner finish. In the client PlayerGui, select CountryMap. Set `RequestedProofProfile` to `Original` or `Settlements`, and `RequestedProofMode` to `Native` or `Hybrid`. Wait for `ProofLoadState=Ready` before reviewing Hybrid. Profile changes retain camera/zoom/selection; native fallback shows during a new profile load. `CohesionEnabled=false` still provides the existing badge comparison. No controls are exposed to production players. Do not use or publish Production 10776828545.

The returned upload is a Decal; only its verified Image dependency is configured. On denial or timeout the proof retains Native; report failures before proposing any permission change. Native mode never requires successful cosmetic loading.

## Historical preparation record

16 November2026. **Upload preparation complete; runtime settlement integration and real-texture validation pending.** Owner accepted Southbank and Eastmere for isolated proof use. Terrain-transition concepts are direction only, never runtime textures. Native remains production default. No runtime files, IDs, map geometry, electrical links, settings or existing atlases changed in this task.

## Exact deliverable and placement

[Owner upload package](../assets/r37-settlements-v1/README.md): `power-state-settlements-proof-v1.png`, 512×256 RGBA, SHA-256 **baff92a631e89bbf9a1506f5401488e40fc2d5fe56a71399b1f410df5b05ff4e**. Byte-identical to the accepted R3.6 atlas. Source rectangles remain Southbank `(8,8,240,240)` and Eastmere `(264,8,240,240)` with8px transparent gutters. Approved six-motif atlas remains unchanged at `e1dcb61948e575bab85d94a6eed3dce1939fe87389455fc3bce735a28cab63cb`.

| Settlement | Electrical identity/anchor — unchanged | Cosmetic ground anchor — unchanged | Content pivot | World canvas |
| --- | --- | --- | --- | --- |
| Southbank | `south`, 665,535 | 685,590 | **150,182**, corrected from 120,160 | 130×130 |
| Eastmere | `east`, 930,455 | 945,510 | 120,160, retained | 140×140 |

Southbank's pivot correction shifts only the proposed artwork top-left **16.25 world units left and 11.9167 up**, placing the fixed terminal over a roof rather than nearly transparent pixels above it. New top-left is `(603.75,491.4167)`; Eastmere stays `(875,416.6667)`. Both full canvases remain within their existing cosmetic patch plus 64-unit overhang. No authoritative anchor is derived from image alpha; alpha was only an authoring diagnostic to assess this cosmetic placement. The new manifest is local metadata, not an active game configuration.

Visually reviewed [all five zooms](../assets/r37-settlements-v1/alignment-five-zooms.png). Roof clusters remain identifiable at minimum zoom 0.55; gardens and coastal details remain too small to carry essential information. Keep contextual names and 44px targets. Gold terminal annotations overlap the intended settlement silhouettes; cyan cosmetic references are not clickable points. Ground-reference pivots need not lie on an opaque pixel. Whole-map overlap, badge occlusion and actual Roblox filtering still need engine review.

## Bounded integration contract after upload

The current renderer intentionally validates exactly six frozen descriptors and reads one atlas URI. It cannot safely consume this two-cell atlas by merely replacing an ID. No ID has been supplied for the new texture. Per the requested upload boundary, the renderer and frozen manifest have therefore been left intact rather than weakening validation or substituting the old texture.

The prepared first comparison profile reuses the six existing image slots: coast, ridge, Newford and station remain; forest's slot becomes Southbank and fields' slot becomes Eastmere. Restore the displaced forest/fields native bundles. Retain all native settlement fallback bundles and the approved coast ordering. This trades two illustrations for the settlements during the proof; it does not show all eight at once. Target remains 595 map descendants, not a new measured result.

After the owner supplies the uploaded ID, a narrow Test-only implementation needs explicit validated two-atlas descriptors and bounded readiness for the relevant labels. Preserve the original six-motif profile. Switch ownership atomically: restore previous native replacements before reassigning slots; on absent/denied/timed-out artwork keep the corresponding Native presentation. Do not create labels on pan/zoom or leave obsolete hidden sprite pools. Retain selection, camera, inspector, labels, target objects and their 44px geometry. New texture changes must not mutate gameplay data or the existing SpriteManifest. Any shared implementation changes must remain unused by production Bootstrap.

Future village→town→city visuals reuse `settlementId`, fixed connection anchor, cosmetic ground reference, source rectangle/pivot, art revision and a bounded footprint. Author each tier around the same reference; do not move the electrical terminal to follow roofs. Swap a ready image in the same slot; unknown tier or failed texture falls back to Native without losing identity/selection. Expansion of the footprint requires independent bounds/overlap validation. Server-owned future development state chooses the tier; the art does not calculate population, demand, growth, connectivity or construction legality. No tier system is implemented here.

## Checks actually run

- `python assets/r37-settlements-v1/prepare.py`: **46 local checks passed**. Exact accepted bytes, original atlas hash, dimensions, source bounds, pixel equality, transparent gutters, pivots, terminal silhouette samples, full 64-unit culling envelopes and placement transforms at five zooms × three pan offsets per settlement.
- `powershell -NoProfile -File scripts/Validate.ps1`: **both Rojo builds passed**, with source mappings, client entrypoint, scope checks and Git whitespace validation. These create local ignored files only; no publish or deploy.
- `ValidateR33.py`: **83** local checks passed; `ValidateR34.py`: **14** passed; `ValidateR35.py`: **4** passed. Total current local assertions: **147**. No new runtime modules or build inclusion changes.
- Inspected fixture IDs, fixed terminal coordinates and native patch bounds directly. Reviewed the new local five-zoom preview.

**Studio settlement tests not run:** the accepted texture has not been uploaded and the integration stops at that boundary. Studio is available, but rerunning the old profile would not validate these new sprites. R3.5 engine results are historical, not reattributed to R3.7. Selection, responsive layouts, pan/zoom, fallback transitions and 595 descendant stability for the settlement profile remain **unverified in engine**. No new Script Analysis, texture memory, frame-time, endurance or physical-device results are claimed.

Once the ID is available, run the retained suites plus settlement-profile checks at 1366×704,360×580,640×300 and768×960 safe-root sizes; zoom 0.55/0.72/1/1.2/1.8; repeated pan/zoom and Native/profile switches; Southbank/Eastmere selection, Locate, inspector and label/focus checks; missing/delayed/denied image injection; remount/cleanup; stable descendant counts including hidden fallback; ten-minute endurance and unfiltered Script Analysis. Capture matched desktop/mobile comparisons with the real texture. Physical-device testing remains a separate gate.

## Files and stop point

Created `assets/r37-settlements-v1/` containing exact PNG, placement manifest, preparation/validation script, results, five-zoom preview and upload README; created this report. Updated PLANS, README and DECISIONS. Earlier uncommitted work is preserved. No automated upload, asset ID substitution, permission change, runtime integration, production modification, gameplay, R4/R5, commit, push or publication.

**Next action belongs to the owner:** upload only the exact verified file to personal missawfulname Development Items, Restricted, for isolated Test use; provide the returned ID/type. Destination must be checked again at upload time. Stop if it differs. Do not upload anything to or change Production. The earlier atlas's permissions do not establish this file's access. Continue real integration only after the new asset can be verified.
