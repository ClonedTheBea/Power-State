# Illustrated World v1.2b — capability-gated landscape audit

19 November 2026. **Latest v1.2c: shared-edge correction and actual capability retest pass; conditional Test landscape implemented. Available automated and Studio validation is complete below; owner visual/device acceptance remains outstanding. Native remains default.**

Historical first attempt: **Stopped at the required runtime capability gate. Not a completed landscape integration or visual acceptance.** Native remains default; existing Illustrated comparison, approved atlases, gameplay and authoritative geography are unchanged.

## Verified upload

Authenticated Studio edit context verified Test universe `10776833313`, personal creator and Studio user `149564436` (`missawfulname`). InsertService resolved uploaded Decal `98440954924603` to **Image `82421581539732`**. Marketplace metadata independently identified types 13/1 and the same personal creator. Both names are `temperate-ground-v12a`; public-domain metadata is false. This metadata is not a separate Creator Dashboard privacy-settings audit.

- Local source: `assets/illustrated-world-v12a-ground/temperate-ground-v12a.png`, 1024×1024 RGBA.
- Fresh file SHA-256: `107448465ac25fc182841da2eeb706bec04a2774401641161301745393d3f1e2`.
- Actual hosted decoded RGBA SHA-256: `0797df255894c517e38a249805ddc712f747d8ddb737855259a65eb536cc9cbd`, exactly matching the approved local decoded pixels.
- Actual edit-mode CreateEditableImageAsync/read/hash: 881.127 ms, cache state unknown. Temporary image and loaded Decal model destroyed.
- Edit-mode access succeeded; this **does not establish client EditableImage access**. No asset or experience permissions changed.

Read-only identity, resolution, hash and failure evidence: [Studio extract](evidence/illustrated-world-v12b/studio-evidence.txt).

## Stage B: actual client gate failed

Added `tests/integration/GroundCapability.client.luau`, a standalone opt-in Test/account-guarded capability probe. It is excluded from the production project and returns immediately unless `RunGroundCapability` is explicitly true. It is not a terrain renderer and does not change the normal map or its presentation slots.

Planned probe sequence: load the approved source; allocate four 514×514 images (512 content plus one-pixel gutters); write and independently read back every pixel; display 256 cropped ImageLabels; inspect supported zooms; explicitly destroy source, chunks and GUI. Allocation/waiting is asynchronous with a 20-second cancellation boundary and late-source destruction. This is a quarter-copy capability analogue, not the proposed climate/elevation synthesis or proof of actual slot reuse.

Fresh authenticated Test Play failed at the **first client source allocation**, before any chunks or GUI were created, at 20:19:38.628 UTC:

> EditableImage is not accessible. Go to the Security Tab in Experience Settings to enable this API.

This is a client experience-API access failure, not evidence of bad pixels, wrong ownership, memory exhaustion or a crop/filtering defect. The failure path cleaned its empty allocation list. Native gameplay remained visible with fake-save messaging. Play was stopped and the temporary opt-in attribute removed at 20:20:37.886 UTC. No setting was changed or bypass attempted.

[Actual Native fallback and full-project Script Analysis capture](evidence/illustrated-world-v12b/native-after-capability-denial.jpg) shows 0 errors/0 warnings, current-script filtering off. An initial probe xpcall return-type warning was corrected before this Play run; no runtime gameplay files were changed.

**Not reached:** chunk allocations, 1,056,784 pixel comparisons, client display/readiness, actual terrain slot reuse, gutters/filtering at five zooms, runtime preparation CPU, frame p50/p95/worst, texture memory, pressure, late callback/remount/switching tests, and device/resource acceptance. Do not interpret code for these tests as passing results. No dependent ground/ocean renderer was enabled.

The proposed four chunk payloads total 4,227,136 RGBA bytes, plus 4,194,304 source bytes before scratch buffers, engine and GPU overhead. This is arithmetic only, not a measured allocation or memory guarantee. Studio and device budgets differ; see [EditableImage API](https://create.roblox.com/docs/reference/engine/classes/EditableImage).

## Land, ocean and coastline audit

Reviewed the original `Inspiration/Grid Window.png` and actual prior Illustrated capture `docs/evidence/illustrated-world-v11/normal-illustrated-v2.jpg`. The reference uses quiet teal/deep-blue water and blended terrain; current geography remains visibly angular and locally patchy.

`GeneratedTerrain.luau` chooses `Theme.map` (#112a3c) for every non-land cell. These are opaque solid-colour Frames; there is no missing ocean texture. The surrounding map background uses the same dark colour. Land changes colour independently at 64-unit boundaries. Painted shallow water/foam is lighter than the flat ocean, and painted grass bases differ from native per-cell land. Those transitions, fixed straight shore ports and repeated local motif outlines account for the principal discontinuities; decoding the new grass alone cannot fix them.

**Ocean proposal, not implemented:** first evaluate a continuous cosmetic deep-blue/teal field using the same bounded ground buffers and existing categorical mask, with subdued shore-distance lightening and quieter offshore colour. Avoid independently tinted water cells and retain a consistent outer-sector background. Compare actual shoreline edge colours before selecting constants. This could avoid a fifth hosted atlas or extra map instances, but depends on the failed capability gate. No new water artwork, hosted resource or colour contract has been introduced. If existing resources cannot meet quality, prepare one minimal local periodic water candidate for separate owner review/upload.

**Coastline finding:** the existing fourteen mixed ownership patterns already include convex, concave and both diagonal cases with shared ports. Their internal rock/sand relief can soften local appearance, but their fixed 64-unit coverage and categorical underlying land remain angular. Changing the visible land/water boundary, enlarging protrusions or bridging corners is not an ordinary palette correction. No such geometry was changed. First test colour continuity under the existing contract after capability access is resolved. If that remains insufficient, present a separately versioned cosmetic boundary proposal with bounded offsets, diagonal-component preservation, narrow-inlet tests and unambiguous buildable-land feedback before implementing it. New coastline geometry is **not** approved by this report.

## Coastal placement audit

[Detailed local audit](evidence/illustrated-world-v12b/placement-audit.json) uses the two previously exported actual Test descriptors, including the maximum 78-junction fixture and its district presentation. It tests exact existing sprite pivots/sizes against Native NW-sample ownership, with no coordinate changes.

- Eight infrastructure anchors examined: all on Native land.
- 51 asset/decorative entries examined. Three conservative sprite rectangles overlap non-land cells: the gas station in each fixture and the maximum-fixture district village.
- Source-alpha refinement found **zero alpha≥16 texel centres over water** for those three candidates. Their rectangle overlap is transparent padding, not demonstrated visible sea placement. This is a local texel-centre check, not an engine-filtering guarantee.
- Composition-v2 forest/field/hill decorations already require their entire rectangle to fit land. Pylons check their anchor; building sprite rectangles are not fully constrained. Larger cosmetic footprints can therefore still pose a risk in other seeds.
- Native and Illustrated descriptors use the same NW ownership convention; no mismatch was found in this inspected path. No genuine invalid gameplay placement is established by this limited audit. The 10,000-seed shoreline test below does not certify every sprite's visible footprint or gameplay legality.

Recommendation: retain fixed infrastructure anchors and functional overlays. If an actual visible overhang is reproduced, conservatively suppress the cosmetic motif and retain its Native representation rather than move the electrical asset. Any genuine gameplay placement defect requires a separate review before changing saved positions/generation. No visual correction was applied on speculative evidence.

## Comparisons and validation actually performed

No new ground or ground+ocean Studio comparison exists because the prerequisite failed. The normal/diagonal/maximum/completed-district [v1.2a local comparisons](ILLUSTRATED-WORLD-V12A-VALIDATION.md) remain historical local studies, not new screenshots or runtime acceptance. Desktop/tablet/portrait/short-landscape comparisons of the proposed renderer remain unrun.

Fresh checks for this task:

| Check | Result |
| --- | --- |
| Exact uploaded owner/type/dependency and decoded pixels | Pass in Studio edit mode |
| Real Test client EditableImage access | **Fail: experience API disabled** |
| Both Rojo builds/source mappings/remote and real-service gates/Git whitespace | Pass |
| Frozen atlas/catalog/production isolation checks | 80 pass |
| Independent 10,000-seed/four-rotation shoreline corpus | Pass; 9,000,000 junctions; 25.661 seconds; natural maximum78, all-reservation maximum80 |
| Full-project Studio Script Analysis after probe fix | 0 errors / 0 warnings, filter off |
| Limited local coastal footprint audit | Results above; no visual/gameplay acceptance claim |

Current outputs are retained under `docs/evidence/illustrated-world-v12b/`. Prior corpus evidence is preserved separately. Existing GUI/economy/security/persistence/construction and endurance suites were **not freshly rerun** after the early gate; no production/runtime implementation changed. Historical passes are not relabelled. No new 600-descendant, mobile, GPU or full-regression acceptance is claimed.

## Inventory, next approval and stop

New: opt-in capability script, this report and evidence directory (Studio extract/capture, placement audit, fresh corpus/static results). Updated: `PLANS.md` and `docs/DECISIONS.md`. No source atlas or runtime source change.

The next action requires owner review of **Test-only EditableImage API enablement** in Experience Settings → Security. The engine identifies the required setting family; this task did not inspect/change the checkbox. Enablement is not an asset-permission change and is not authorized here. The owner may enable the appropriate API setting manually or separately authorize a narrowly specified setting change, then authorize resuming the capability gate. Production `10776828545` must remain untouched. No lower resolution, alternate asset or raised budget is proposed as a bypass.

After access is available, rerun the standalone probe first; require actual crop/gutter/filter/cleanup success before integrating four chunks into the 256 presentation slots. Then complete continuous land/ocean work, matched fixtures/responsive views, fallback/resource regressions and fresh performance/endurance evidence. Any new ocean upload or coastline geometry contract remains separately gated. Native remains the default throughout.

Stopped as explicitly required on runtime capability failure. No real DataStore access, Rowanbridge changes, Production modifications, uploads, settings changes, publication, deployment, commits or pushes.


## Reauthorised capability continuation — 19 November 2026, 20:30–20:34 UTC

Owner reports manually enabling Allow Mesh & Image APIs and explicitly reauthorizes the exact Test/account/image capability proof, with dependent integration conditional on every mandatory gate. This supersedes the need for API enablement approval above; the original denial evidence remains intact. No further settings changes were made.

**Outcome: allocation/readback/readiness pass; fractional-zoom visual correctness fails. Stop before Stage B.** No renderer, source atlas, economy or authoritative code was modified during this continuation.

### Fresh environment and gates

Edit-mode assertions confirmed universe10776833313, personal creator149564436 and authenticated Studio user149564436 immediately before fresh Play. The probe independently asserts Studio/Test/creator and LocalPlayer149564436. ReplicatedStorage attributes were recorded; unrelated execution/test flags remained false. Both-build/source validation confirmed live persistence and real-economy access gates remain false before DataStore service access. The ordinary Test session showed fake-save messaging. Source PNG SHA-256 again matched107448465ac25fc182841da2eeb706bec04a2774401641161301745393d3f1e2. The unchanged opt-in probe used only approved Image82421581539732.

### Actual results

| Measurement | Observed |
| --- | --- |
| Source CreateEditableImageAsync + read | 1,559.829 ms; cache state unknown |
| Allocations | One1024 source + all four514×514 chunks; no nil allocation |
| Pixel writing/readback | 1,056,784 exact u32 comparisons pass, including copied gutters |
| Copy-loop accumulated CPU | 28.929 ms; excludes source load, allocation, engine writes/readback and comparison loops |
| Start through six display frames | 2,742.734 ms wall time |
| Bound ImageLabels | 256/256 IsLoaded true |
| Post-preparation120-frame sample at0.72× | p50 16.700 ms; p95 17.543 ms; worst18.041 ms |
| Total client-reported memory during frame sample | 1,979.207 MiB |
| Total memory before /120 frames after cleanup | 1,981.109 /1,972.957 MiB; decrease8.152 MiB |
| Cleanup | Destroy called for all five EditableImages and GUI; owned allocation list0; GUI absent after120 frames |

Memory is Stats:GetTotalMemoryUsageMb for the whole running client/Studio environment, including concurrent fake gameplay. The decrease is an observation, **not an isolated GPU texture-memory measurement, proof of exact byte reclamation, leak-free remounts or low-end-device capacity**. No pre-allocation baseline or preparation-frame histogram was collected. The120-frame sample measures steady display, not worst preparation impact or a Native-versus-new-renderer comparison. Raw source+chunk payload arithmetic remains8,421,440 bytes before CPU buffers/engine overhead.

The existing probe yields every32 copy rows (16 Heartbeats per chunk), so successive chunk writes occur in different frames; it waits six RenderStepped events after binding all labels. This avoids issuing the four writes in a single frame and allows multiple-image presentation to settle. There is no continuously updated-image path. IsLoaded alone is not treated as visual correctness.

### Display failure and diagnosis

Actual screenshots were captured at all five supported zoom values:

- [0.55×](evidence/illustrated-world-v12b/capability-zoom055.jpg): visible regular gaps.
- [0.72×](evidence/illustrated-world-v12b/capability-zoom072.jpg): visible vertical gaps.
- [1.00×](evidence/illustrated-world-v12b/capability-zoom100.jpg): no obvious gaps in the visible region.
- [1.20×](evidence/illustrated-world-v12b/capability-zoom120.jpg): numerous horizontal/vertical gaps.
- [1.80×](evidence/illustrated-world-v12b/capability-zoom180.jpg): visible vertical gaps.

Larger views are clipped by the Studio viewport; these are probe screenshots, not complete country comparisons. Four chunks are allocated/read back and all256 labels loaded, but screenshots do not certify every offscreen crop. The gutters contain exact source pixels; this does not prove downsampling/mipmap coverage.

A read-only AbsolutePosition/AbsoluteSize diagnostic at1.8× confirmed **a real one-screen-pixel uncovered interval**: Cell4_0 starts at460, width115, next cell starts576. The probe computes fractional positions and widths independently, which the engine rounds separately. The visible gap at that boundary matches the measured geometry. This establishes a probe placement defect; it does not prove an EditableImage filtering failure or require a new world/coastline geometry contract. Other filter/mipmap defects have not been excluded.

Recommended next narrowly scoped correction: calculate a shared screen-space edge sequence, derive each cell width from adjacent rounded edges, and verify identical neighbour boundaries under fractional camera offsets and every zoom. Preserve source dimensions, atlas crops, world mask,256 slots and600-map ceiling. Do not hide gaps by arbitrarily overlapping cells or changing land ownership. This is a proposed probe correction, not applied during this failed-gate run. Re-test filtering after coverage is correct, then repeat cleanup/remount and resource tests before integration. The explicit instruction to stop on a mandatory correctness failure was followed.

### Cleanup, checks and remaining boundary

[Cleanup screenshot](evidence/illustrated-world-v12b/capability-cleanup.jpg) shows the Native fake-country GUI restored and full-project Script Analysis0 errors/0 warnings with current-script filtering off. Play was stopped; RunGroundCapability and GroundCapabilityZoom were removed in edit mode. [Timestamped identity, measurements, edges and cleanup](evidence/illustrated-world-v12b/reauthorised-capability.txt) preserves the exact observations.

Both Rojo builds, source/security/disabled-real-service checks and Git whitespace passed freshly. No code changed, and the initial run's geography/static results remain historical. Full economy/construction/security/GUI suites, failure/late-callback/remount stress, physical devices,600-descendant integration and endurance were not rerun after this mandatory stop. No new matched Native/Illustrated/ground/ocean comparison or natural-landscape success is claimed.

Updated this report, roadmap and decision register; added five zoom captures, cleanup capture and timestamped evidence. Retained the existing probe unchanged and disabled. No DataStore access, Production, settings, upload, publication, deployment, commit or push. Owner review should authorize the isolated fractional-edge correction/retest before resuming conditional renderer integration; no extra artwork or resource-budget increase is proposed.


## v1.2c continuation — shared edges and conditional Test integration

Owner-authorized on19 November2026. **Available Test validation complete; no default adoption or owner visual acceptance claimed.** Historical denial, allocation success and fractional-gap failures above remain evidence, not retroactively passed tests.

### Exact boundary correction

`ScreenGridEdges.axis` transforms boundary i in a common unscaled GUI parent using `floor(origin + i*64*zoom + 0.5)`. Each cell begins at its shared rounded boundary; width/height are the difference between consecutive boundaries. Negative coordinates use the same floor rule. There is no arbitrary overlap, crop enlargement or change to the64-world-unit mask. The former460/115/576 geometry now shares the same boundary by construction and actual engine measurement.

The probe retained four514-square chunks, the same256 crops and approved source. It passed23,552 actual AbsolutePosition/AbsoluteSize/crop assertions per run across eight zooms (.55,.613,.72,.937,1,1.2,1.437,1.8) and four positive/negative fractional offsets. New [five-scale captures](evidence/illustrated-world-v12c/) show continuous coverage;1.8 includes negative fractional offsets. The original v1.2b gap screenshots remain separately linked above.

Each full probe still passes1,056,784 exact pixel write/readback checks and256 readiness checks. Three repeated clone/remount/cleanup cycles passed. Cancellation after an explicit ProbeStarted signal passed, with late source disposal and no recreated GUI. A first cancellation attempt incorrectly changed the flag before the cloned probe started; its command-bar assertion failure is retained and the test was changed to wait for a bounded explicit state, not sleep longer. Initial telemetry type warnings were corrected. Whole-client memory observations are not isolated texture reclamation or device-budget proof.

### Bounded cosmetic implementation

- `GeneratedTerrain.replaceCells` is a presentation hook; ordinary production construction still creates Frames. The Test adapter replaces the256 slots once with ImageLabels, preserving Native background colours/culling and adding no terrain slots. No authoritative modules changed.
- `ContinuousGround` is excluded from production. It owns one immutable map/sector cache keyed by country ID, seed, generation/climate/template versions, approved Image82421581539732 and cosmetic colour revision1. Pan, zoom and mode changes reuse resources. Country remount destroys the cache; no unbounded cross-country cache exists.
- The approved1024-square source is loaded and box-prefiltered4×4 to a256-square periodic sampling buffer (four source texels/world unit). The source artwork file and image resolution are unchanged. Four514-square output images retain512 content and1px neighbour gutters; output is one pixel/world unit, as proposed in v1.2a. This runtime box filter differs from the earlier local Lanczos preview and is explicitly cosmetic.
- Existing elevation/rainfall/temperature fields use shared smoothstep bilinear interpolation for quiet meadow/hill/lowland colour. Ground texture phase uses world integer modulo, including negative gutter samples. Exact NW categorical ownership selects land versus water; interpolated elevation never decides ownership, construction or topology.
- Ocean colour uses the same chunks and existing source's quiet variation: deep RGB24/53/70 blending toward31/78/90 with a bounded smooth elevation-derived shallowness cue. It introduces no river, channel, island, uploaded material or new geometry. The outside-sector background uses deep colour; unknown adjacent geography is not fabricated.
- Preparation yields after approximately1ms of accumulated row work and writes no more than one chunk per rendered frame. There is a20-second preparation timeout and explicit resource disposal on failure/cancellation. Source images are destroyed after prefiltering. Four output images remain while mounted.
- Native/current Illustrated/Ground/Ocean modes retain the existing Layers control, overlays, markers, labels and inspector. Native remains initial/default. New modes require the Test tree and opt-in comparison flag. Ready ground is drawn below the illustrated terrain root, while electrical overlays remain above both.
- Culled ImageLabels may correctly report IsLoaded=false. Initial visible cells must pass readiness; newly exposed cells retain their Native background at near-transparent preload until their own binding is ready. Ground observes the existing atlas readiness signal so it can resume without moving the camera; all-art failure retains Native.

### Failures investigated during integration

1. Requiring IsLoaded from every terrain cell incorrectly failed64 offscreen cells while all192 visible cells were ready. Replacement now preserves culling and validates visible readiness, retaining per-cell Native fallback.
2. The replacement initially omitted the old Visible flag; fixed while keeping the same geometry/crops/count.
3. The maximum fixture exposed a readiness handoff; ground now observes IllustratedActive rather than waiting for another camera event.
4. A1060px-high virtual test root exceeded the actual616px Studio render target and caused the retained atlas label deadline to fail on physically offscreen sprites. The actual-render integration test now uses1366×560,820×560,360×560 and740×320 roots, preserving every boundary/readiness assertion. These exercise responsive widths and short landscape; they do not claim a1060px physical display or hardware acceptance. No five-second atlas timeout was loosened.

### Validation status

The first complete corrected run passed35,484 new integration assertions on both fixed fixtures at470/600 map descendants, plus the retained3,090 Illustrated engine checks and49,008 cosmetic composition checks. Synthetic source denial and delayed cancellation remain explicitly labelled. This was an intermediate run. The expanded final tests, fresh endurance, screenshots and retained regressions are recorded below; historical failures remain unchanged.

Initial integrated preparation measurements: approximately0.66–0.69s accumulated work spread over9.8–10.2s elapsed, with preparation frame p95 approximately17.5–17.7ms and observed worst approximately20–22ms in these runs. These are desktop Studio observations. CPU instrumentation excludes source service latency and is not a GPU measurement. Final per-mode and endurance results are recorded below.

Remaining visual limits: angular categorical coastline, repeated hill shapes, painted grass bases, tiny minimum-zoom pylons, and some shore-water/ground mismatches. No new organic boundary or art contract is implemented. Owner visual approval and physical-device memory/touch/gamepad acceptance remain required before adoption.


### Actual matched Studio comparisons

These are unedited Studio window captures. Logical safe roots occupy the upper-left of a larger desktop viewport; they are not physical mobile-device performance tests. Fixture1 uses seed `12fee3f76be963c09033cdfd9ccffb36`; fixture2 uses `fe0512aa351b994df1656b88f0d94f1b`. Fixture2's curated name Rowanbridge is unrelated to the real persisted country; its ID is `illustrated-fixture-2`. Built district flags here are cosmetic fixtures only. Short-landscape header numbers are illustrative fixture defaults, not earned-money measurements.

| Comparison | Captures |
| --- | --- |
| Normal country,1366×704,0.55×,matched recenter | [Native](evidence/illustrated-world-v12c/normal-native-desktop.jpg), [existing Illustrated](evidence/illustrated-world-v12c/normal-illustrated-desktop.jpg), [continuous Ground](evidence/illustrated-world-v12c/normal-ground-desktop.jpg), [Ground+Ocean](evidence/illustrated-world-v12c/normal-ocean-desktop.jpg) |
| Maximum78 shores and built district,1366×704,0.55× | [Native](evidence/illustrated-world-v12c/max78-native-built-desktop.jpg), [Ground+Ocean](evidence/illustrated-world-v12c/max78-ocean-built-desktop.jpg) |
| Tablet-width820×704,0.55× | [Illustrated](evidence/illustrated-world-v12c/normal-illustrated-tablet.jpg), [Ground+Ocean](evidence/illustrated-world-v12c/normal-ocean-tablet.jpg) |
| Mobile360×704,0.55× | [Native](evidence/illustrated-world-v12c/normal-native-mobile.jpg), [Ground+Ocean](evidence/illustrated-world-v12c/normal-ocean-mobile.jpg) |
| Short landscape740×320,0.55× | [Ground+Ocean](evidence/illustrated-world-v12c/normal-ocean-short-landscape.jpg) |
| Exact diagonal junction,fixture1,(192,640),1.8× | [Illustrated](evidence/illustrated-world-v12c/diagonal-illustrated-180.jpg), [Ground+Ocean](evidence/illustrated-world-v12c/diagonal-ocean-180.jpg) |
| Maximum-shore fixture detail,1.8× | [Illustrated](evidence/illustrated-world-v12c/max78-illustrated-closeup180.jpg), [Ground+Ocean](evidence/illustrated-world-v12c/max78-ocean-closeup180.jpg) |

The uncovered one-pixel grid gaps are absent in inspected corrected views. Large flat land-colour blocks are replaced by continuous colour and quiet texture. Remaining differences are **not all seams solved**: existing shore sprites retain a conspicuous turquoise fringe and angular corners; some painted bases remain visible; categorical diagonal ownership remains a point contact. Ocean colour inside the finite1024-square sector can end visibly against the constant deep-blue outside background. No neighbouring sector, new coastline or land is fabricated to hide that edge. These are owner-review limitations, not claimed natural-coastline acceptance.

### Matched camera-path measurements

Fresh21:28–21:29UTC run;180 frames/mode,1366×560 safe root, identical fractional camera path/zoom sequence. Native is measured before replacing its Frames; Illustrated is measured before attaching the continuous-ground adapter. Later Native fallback retains the replacement ImageLabel slots and should not be confused with this baseline.

| Mode | Render CPU p50 / p95 / worst ms | Frame p50 / p95 / worst ms | Map descendants | Whole-client MiB |
| --- | --- | --- | --- | --- |
| Native |0.103 /0.129 /0.206|16.600 /17.567 /17.841|362|2008.32|
| Existing Illustrated |0.802 /1.058 /1.951|16.628 /17.536 /18.559|470|1999.33|
| Ground |1.360 /1.823 /3.757|16.606 /17.564 /19.164|470|2008.36|
| Ground+Ocean |1.350 /1.706 /2.516|16.612 /17.501 /17.782|470|2006.05|

[Raw matched values](evidence/illustrated-world-v12c/matched-benchmarks.json). CPU is synchronous map-render wall duration on this Studio desktop, not GPU cost. Source service time is excluded from accumulated synthesis CPU. Whole-client memory varies with unrelated Studio/client work and GC; differences are not exact texture allocations or leak freedom.

Fresh mixed-mode endurance21:16–21:26UTC completed601.01s/591 cycles with a fixed470 map descendants. Frame p50/p95/worst16.629/17.626/**270.778ms**; whole-client2096.96→1987.59MiB. The worst frame is retained; this run does not establish universal smoothness or low-end device performance. [Raw endurance](evidence/illustrated-world-v12c/endurance.json). This run preceded the final synthetic nil-chunk/20-second-timeout test additions and readiness-timeout cleanup hardening; the later expanded35,489-assertion run passed those final paths. It is not relabelled as a post-edit endurance run.

### Test controls and review boundary

Only `test.project.json` enables `ContinuousGroundProof`; production excludes the entire adapter/asset ID/tests. Ordinary Test startup still begins Native. Open Layers and use the existing Geography comparison action to cycle Native → Illustrated → Ground → Ocean → Native. Ground preparation is asynchronous; Native remains visible while loading or after failure. The existing keyboard/gamepad action router and44px control are reused. No extra gameplay menu or automatic real-service startup is introduced.

For explicit validation, set `RunIllustratedTests=true` and `RunContinuousGroundTests=true` in Test edit mode, keeping `RunRegressionTests=false`; restart Play. Add `RunContinuousGroundSoak=true` only for the ten-minute mixed-mode test. Remove execution flags afterwards. Never use Production or enable real-service gates. Physical touch/gamepad and constrained-device EditableImage budgets remain owner/device acceptance work.


### Changed files in v1.2c

- `tests/integration/IllustratedWorld/ScreenGridEdges.luau`: shared rounded boundaries.
- `tests/integration/GroundCapability.client.luau`: corrected screen placement, fractional-offset coverage, start/cancel/remount observability and preparation telemetry. The capability probe was already present from v1.2b; it remains opt-in.
- `src/client/Views/Map/GeneratedTerrain.luau`: bounded presentation-slot replacement hook; default remains native Frames.
- `tests/integration/IllustratedWorld/ContinuousGround.luau`: Test-only immutable cosmetic cache, source/pixel synthesis, four padded images, readiness, culling and disposal.
- `tests/integration/IllustratedWorld/ContinuousGround.spec.luau`: actual image/edge/crop/mode/resize/cleanup checks, explicitly synthetic denied/delayed resource tests, matched benchmarks and optional600-second soak.
- `tests/integration/IllustratedWorld/IllustratedController.luau`: existing-control mode cycle, status and whole-Native fallback after ground failure.
- `tests/integration/IllustratedRun.client.luau`: opt-in integration suite and four-mode capture support.
- `test.project.json`: exposes the four-mode comparison only in Test; no tests or image loading run automatically, and initial mode remains Native.
- `scripts/ValidateIllustratedRenderer.py`: extends production-exclusion/asset-isolation checks to the new modules and approved ground ID.
- This report, `PLANS.md`, `docs/DECISIONS.md`, and `docs/evidence/illustrated-world-v12c/`: dated validation, screenshots, measurements and approval boundary.

No server, solver, economy, persistence, construction eligibility, authoritative terrain, electrical anchor or approved artwork file changed. Earlier v1.2b uncommitted documentation/evidence is preserved.

### Resource accounting limits

The four output buffers contain4,227,136 RGBA bytes (~4.03MiB). The1024-square source is4MiB decoded; the runtime periodic sampling buffer is0.25MiB and one514-square staging buffer is~1.01MiB. These are payload arithmetic, not measured engine/GPU totals. The source EditableImage is destroyed before output synthesis; raw source pixels and Lua/engine overhead still contribute to preparation memory. GC can retain unreachable CPU buffers temporarily. A nil allocation is a failed proof and restores Native; there is no lower-resolution retry or budget expansion.

Final fallback review tightened one detail: failure must disable older illustrated decorations as well as new ground. The controller now restores the whole Native presentation and cannot re-enable partial artwork by switching Ground/Ocean on the failed cache. No new resource is allocated on that failed cache; remount is required for a fresh attempt. Separate injected failure tests cover this behavior without using unrelated assets or changing permissions.


### Fresh retained regression results

The separate21:38UTC fake-server session passed Operations Atomic326, Security231, Scenario3,144, Fleet Lifecycle2,062, Reinforcement Model497, Transaction61, Economy20,179 and Resources2,065 assertions. Operations scheduling passed63 eight-country intervals including native/30Hz and15Hz runs, retaining safe suspension rather than weakening limits. No real storage adapter was involved.

The separate21:39–21:43UTC retained session passed the P3a/P3b/P3c fake migration, lease, financial replay and purchase suites; the actual Luau10,000-seed route/pad/fairness run passed2,916,780 world assertions with four rotations and safe fallback. The client then passed First Playable remote12 and normal journey34 assertions, Bank83, GUI364, Currency16, interaction135, map190, framing52, synthetic hybrid739 and focus/presentation241. Results are preserved in the timestamped regression evidence; these are fresh runs, not prior milestone citations.

The complete client sequence begun21:44UTC separately passed P2a/P2b GUI57/88, actual remote transport32/32, real30-second quote expiry/refresh20, P3c GUI lifecycle2,027 (including1,944 Bank structured-value/layout checks), base presentation1,496 and three repeated241-assertion R3.5 focus suites. R3.7 then passed1,413 assertions and a fresh600.1-second/589-cycle soak at595 map descendants. The later original-atlas/Native/live-country endurance results also passed, as recorded below.


At22:09UTC, retained R3.4 passed260 real-texture assertions, remount readiness and600.9s/591 cycles. Its1,075-descendant measurement is the **whole ScreenGui**, not the map; do not compare it directly to the600-map budget. The existing map assertion remains unchanged. Native and live P2b endurance subsequently passed in the same uninterrupted client sequence.


### Final code rerun,22:30–22:32UTC

The final expanded engine suite passed **35,497 assertions**, plus3,128 retained Illustrated engine assertions (dynamic visible-entry count at the larger physical Studio viewport),4,179 pure fixture checks and49,008 landscape checks. The new checks confirm exactly four retained chunks, immediate telemetry disconnection on cancellation, late disposal, the real20-second deadline, and whole-Native fallback even after a mode-switch attempt on a failed cache. Injected nil-source/nil-chunk warnings are expected negative-test evidence, not real resource denials. No final resource/correctness assertion failed.

Final preparation observations: source290–474ms; accumulated work649–686ms; four writes0.353–0.435ms total; binding and scheduled presentation waits99–100ms; overall9.66–10.02s. Preparation frame p95 approximately17.55–17.85ms, worst approximately19.65–23.82ms. CPU-labelled figures sum `os.clock` durations around synchronous work, excluding explicit waits; they are not OS thread CPU counters. Write timings measure API submission, not isolated GPU upload time. The20-second limit is unchanged. Cache/network state was not flushed, so these are not cold-CDN measurements. [Exact final preparation](evidence/illustrated-world-v12c/final-preparation.json).

| Final matched mode | CPU p50 / p95 / worst ms | Frame p50 / p95 / worst ms | Map | Whole-client MiB |
| --- | --- | --- | --- | --- |
| Native baseline |0.101 /0.135 /0.208|16.653 /17.752 /18.167|362|2231.94|
| Illustrated |0.788 /1.033 /2.166|16.612 /17.837 /18.088|470|2227.31|
| Ground |1.328 /1.727 /2.190|16.679 /17.536 /18.047|470|2235.82|
| Ground+Ocean |1.343 /1.598 /3.595|16.622 /17.498 /18.093|470|2233.51|

[Final benchmark values](evidence/illustrated-world-v12c/final-matched-benchmarks.json). The exposed `GraphicsTexture` tag stayed41.713989MiB in all four modes despite EditableImage allocations. It therefore does not isolate their texture memory; no zero-cost or exact-reclamation claim is made. Earlier benchmark/endurance measurements remain intact rather than selecting only the better run.

The uninterrupted retained client sequence also completed Native600.3s/590 cycles/1,069 whole-GUI descendants and live P2b600.2s/590 cycles/345 map descendants, preserving demand bounds, service conservation, monotonic accounting, seed, selection and pool size. All four legacy full-duration soaks were freshly completed in this sprint. Final post-change Ground/Ocean endurance also passed, as recorded below.


### Final post-change endurance

At22:42:41UTC, the final code completed **600.83s/591 cycles at470 map descendants** across Native/Illustrated/Ground/Ocean with repeated zoom/fractional pan. Frame p50/p95/worst16.636/17.622/**242.556ms**; whole-client2236.20→2213.63MiB. This is the fresh post-cleanup/fallback-change run. The earlier601.01s run and its270.778ms worst frame remain in [both raw records](evidence/illustrated-world-v12c/endurance.json).

Both long runs show an isolated large frame stall; cause was not isolated, and no claim attributes it to unrelated Studio work or rules out the renderer. No assertion failed and pool/readiness remained stable, but these measurements do not establish hitch-free play or low-end performance. Physical-device and longer profiling remain acceptance limitations before default adoption.


### Final interaction, analysis and handoff

Actual desktop mouse dragging over the new ground changed the camera; zoom-button clicks enlarged it; clicking the generator opened its inspector with visible selection feedback. [Observed pan/zoom/selection](evidence/illustrated-world-v12c/mouse-pan-zoom-selection.jpg). The Layers control switched Ocean back to Native while retaining the selected generator and inspector. Recenter returned the fixture to its default scale. Automated Locate/camera/focus regressions passed. A computer-control transport reset interrupted observation of the separate Locate click sequence, so no additional manual Locate claim is made.

An automated mouse-wheel scroll did not produce an observed zoom change; this is inconclusive input-tool evidence, not proof of physical wheel behavior or an established new runtime defect. Zoom buttons and actual mouse drag were observed working; owner-operated wheel, physical touch/gamepad and low-end device acceptance remain outstanding. No map input handler was modified. Computer control recovered for the final check and cleanup.

[Full-project Script Analysis](evidence/illustrated-world-v12c/script-analysis-final.jpg) showed **0 errors/0 warnings**, with current-script-only filtering off. Edit-mode analysis also remained0/0 after stopping Play. Both Rojo builds, source/security/disabled-real-service checks, Git whitespace and93 frozen-art/build-isolation checks passed. The independent10,000-seed/four-rotation grammar corpus passed9,000,000 junctions (maximum78 natural/80 across all reservations); actual Luau world/fairness/route tests passed separately as recorded above. The existing unrelated asset-type warning for203785492 and Studio social/chat403 messages were retained; no substitute terrain assets were introduced.

At22:52:56UTC, edit-mode verification confirmed Test10776833313, creator149564436 and authenticated Studio user149564436. All task execution/probe/capture attributes were removed or disabled, Play stopped, and only the Test comparison opt-in remains enabled. Start Play in the connected Test project and use Layers → Geography to cycle Native, Illustrated, Ground and Ocean. Native is still the initial mode. This requires no settings changes or publishing.

**Result:** bounded Test integration and available regression gates passed; stop for owner visual review. Recommend retaining Native as default while the owner reviews the continuous-ground/ocean screenshots, the finite-sector ocean boundary, painted shore/base mismatches and the observed242–271ms isolated long-run frame stalls. Do not infer low-end-device safety or approve default adoption from these desktop results. No new coastline geometry/art, real services, Production changes, uploads, permission changes, commits, pushes or publication occurred.
