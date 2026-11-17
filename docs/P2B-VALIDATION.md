# P2b Stage 2 — amended contract implementation and validation

**Follow-up:** the owner accepted P2b as the basis for P2b.1. Actual eight-client checks and generation scheduling remediation are recorded in [P2b.1 validation](P2B1-VALIDATION.md); the original review status below is historical.

17 November 2026. **Isolated P2b implementation and available automated/Studio validation complete; owner review pending.** Owner approval D86 changes only outer temperate radius to 4608 units. Inner radius 2048 and gradient limits 2.00°C / 150 mm/year per 64 units remain unchanged. Original failed 4096-radius evidence is preserved below as history. Physical-device and actual multi-client acceptance remain unverified.

## Current evidence

| Gate | Actual result | Evidence scope |
| --- | --- | --- |
| Amended cardinal climate | 10,000 seeds; 1,600,000 pairs; maxima 1.78°C / 69 mm; zero violations | Independent Python reference |
| 2D and diagonals | 262 seeds; 14,877,408 pairs (7,438,704 diagonal); maxima 1.68°C / 69 mm; zero violations | Independent Python reference |
| Offset/adversarial climate | 132 seeds; 2,179,584 pairs at 32 angular spokes with -1/31/63-unit offsets; maxima 1.63°C / 68 mm | Independent Python reference |
| Final local-source world suite | **2,916,780 assertions passed**, 10,000 distinct nonreserved terrain fingerprints, zero fallback starts | Roblox engine, temporary fresh copies of exact local modules |
| Generation CPU | first fresh-module start 13.077 ms; sweep p95 15.590 ms | Recorded Studio desktop host; process already warm |
| First-start stages | layout 0.012 ms, validation 0.715 ms, terrain/halo 12.347 ms | Accumulated CPU excluding yields |
| Retained Lua memory | 858.62 KiB/country for eight retained descriptors; earlier isolated batch 467.88 KiB | Incremental gcinfo; allocator/GC and background noise, not exact allocation |
| Owned descriptor | largest measured JSON 43,705 bytes in first 100 sweep samples; 2,667 final positions/start | Encoded-size proxy, not wire traffic |
| Demand/solver | step p95 0.0326 ms; eight-country batch p95 0.2563 ms | Engine pure modules |
| Full-day replay | 75.457983 MWh requested/delivered, peak 3.811 MW, no unserved demand | Exact component sum with one aggregate kW rounding |
| Round-robin schedule | eight synthetic jobs, **339.954 ms wall / 21 Heartbeats**, identical descriptors | Real engine Heartbeat with synthetic jobs, not eight real players |
| Live generation | 17.080/16.899/16.153 ms CPU; 1920.024/1830.888/1795.879 ms wall | Three actual single-player Test mounts, all below 2 s |
| Live GUI | P2a 57; final expanded P2b 88 assertions, each with two cleanup/remount checks; P2b map 345 descendants | Desktop, tablet, portrait and short-landscape safe-root sizes |
| Accounting replay | 2,941 assertions; two days requested 150.915967 / delivered 139.355967 MWh with deliberate outages | Real engine Country/IntentHandler; bounded history and atomic rejection |
| Live snapshot size | full 44,873 bytes; periodic 1,907 bytes | JSON encoded proxy, not measured wire traffic |
| Remote security | P2a and P2b each 32 actual transport assertions | Malformed payloads, wrong asset/session, stale/duplicate/out-of-order commands and bounded flood responses |
| Local validation | both Rojo builds; 34 P2a + 28 P2b preservation/source/mapping checks | Does not replace engine tests |

References: [cardinal gate](P2B-CLIMATE-AMENDED-4608.json), [2D gate and ten revised climate vectors](P2B-CLIMATE-2D-GATE.json), [offset gate](P2B-CLIMATE-OFFSETS-GATE.json). Diagonal differences are normalized by Euclidean distance using exact squared-integer inequalities against the unchanged per-64-unit thresholds. These are sampled coverage, not a proof over every possible seed/coordinate.

The final world suite also covers 289 independent active-sector elevation vectors, canonical hash vectors, negative coordinate ownership, shared X/Y sector edges, reverse-order chunk reconstruction, repeated field queries, five additional adversarial starting seeds, biome membership normalization, malformed inputs, forced safe-layout validity and midpoint/day-wrap/component/energy replay. Rotations: [2482,2460,2589,2469]; names: [1205,1258,1292,1255,1244,1219,1236,1291]. The 10,000-seed corpus is a deterministic 128-bit test fixture from four tagged hashes; runtime issuance uses independent server GUIDs.

The earlier floating-point demand prototype is superseded by the approved fixed-precision implementation. A live remount race (periodic packet before static descriptor) was found and fixed; the subsequent live GUI/remount suites passed. Strict Unsubscribe cleanup now stops unused snapshot streams without pausing simulation. No acceptance threshold or gameplay coefficient was changed.

Retained suites passed: Shell 324, Currency 26, GUI 348, R1 GUI 16, R2 interaction 135, R3 190, R3.1 52, R3.3 synthetic 739, R3.5 217, R3.7 1,411 and R3.4 real-texture 259 assertions. P2a pure simulation/security passed 432 assertions.

All four endurance runs passed: settlement 606.7 seconds / 540 cycles / 595 map descendants; real original atlas 600.7 seconds / 548 cycles / 935 shell descendants; Native shell 600.9 seconds / 591 cycles / 929 shell descendants; generated P2b 600.8 seconds / 591 cycles / 345 map descendants. Heavy server seed sweeps overlapped part of the settlement run, so that run is stability evidence rather than a clean frame benchmark.

### Rendering measurements and visual evidence

The final generated GUI suite measured the following on desktop Studio, with synthetic safe-root dimensions. These are not physical mobile measurements or Device Simulator results.

| Safe root | Map CPU p50 / p95 | Frame p50 / p95 | Map descendants |
| --- | --- | --- | --- |
| 1366×704 | 0.0962 / 0.1077 ms | 16.68 / 17.51 ms | 345 |
| 360×580 | 0.1249 / 0.1519 ms | 16.61 / 17.71 ms | 345 |
| 768×960 | 0.0980 / 0.1197 ms | 16.58 / 17.64 ms | 345 |

Actual Test captures: [desktop generated country](p2b-screenshots/desktop-generated.jpg), [portrait safe-root](p2b-screenshots/portrait-safe-root.jpg), [server Script Analysis](p2b-screenshots/script-analysis-server.jpg), [client Script Analysis](p2b-screenshots/script-analysis-client.jpg). Client/server analysis showed zero errors and warnings with the current-script filter off. The portrait capture is an intentionally constrained root inside a desktop viewport. Terrain remains coarse Native cells; these screenshots do not establish final art acceptance.

The Device Simulator command was disabled during the running test session; no emulator result is claimed. A guarded attempt to disable the runner in edit mode correctly refused while Play was still running (command-bar assertion, not a game failure). Play was subsequently stopped and the enabled development runner verified in Test edit mode. No temporary runner setting was left disabled.

### Final source review

Final edit-mode analysis exposed 14 type-inference warnings not shown in the earlier live analysis views. Explicit heterogeneous test input/biome dictionary types, scalar capture of `gsub`, a common renderer function signature and explicit protected-call success returns remove them without altering generation or demand formulas. [Final edit-model analysis](p2b-screenshots/script-analysis-final.jpg) shows **zero errors and zero warnings**, current-script filter off.

A direct edit-mode `require` reused old cached world modules and failed the new accounting suite on a missing mean-temperature field. This run is invalid evidence for current source; it also returned the older demand total. The cache-independent rerun used temporary clones populated with exact local sources and passed: **P2a 432, P2b world 35,880 (100-seed focused rerun), accounting 2,941 assertions**. It reproduced the approved 75.457983 MWh day, 3.811 MW peak and 150.915967 / 139.355967 MWh two-day outage replay. Clones were cleaned up. Both builds and all 62 local checks passed again after the type fixes. The full 10,000-seed run above remains the broad coverage evidence; the final changes are type clarification, not new algorithms. The four endurance runs preceded these type-only fixes and were not repeated.

## Implementation complete within P2b scope

Server-only `World` modules implement versioned integer fields, climate, starter reservations, deterministic validation/generation, exact demand and the isolated generated service. The service limits jobs/countries to eight, yields bounded generation slices, fails unavailable on watchdog/error, uses existing strict intent handling, and sends static descriptors only on sync. The fixed P2a fixture remains available for regression tests. A generated Native terrain view reuses the shell/map controls with separate 1024-square framing and 256 bounded terrain cells; no illustrated assets or gameplay authority on the client.

Remaining acceptance work: owner visual review, Device Simulator/physical touch and gamepad review, and actual multi-client isolation/performance. The completed synthetic eight-job checks do not substitute for real clients. No production changes, uploads, permissions, saving, construction, publication, commits or pushes. Stop after P2b; later phases require separate authorization.

## Files changed for P2b

Existing uncommitted P2a work is preserved; this inventory describes P2b additions/changes, not every uncommitted file in the workspace.

| Area | Files |
| --- | --- |
| Deterministic server generation | `src/server/World/IntegerField.luau`, `ClimateModel.luau`, `StarterValidator.luau`, `WorldGenerator.luau` |
| Demand/service | `src/server/World/DemandModel.luau`, `GeneratedService.luau`; `src/server/Bootstrap.server.luau` |
| Reused accounting/transport | `src/server/Simulation/Country.luau` (optional generated network/demand), `IntentHandler.luau` and `SimulationService.luau` (subscription lifecycle) |
| Generated Native presentation | `src/client/Views/Map/GeneratedTerrain.luau`, `Views/MapView.luau`, `Controllers/MapController.luau`, `src/shared/Types/ShellTypes.luau` |
| Live client adapter | `src/client/Simulation/SimulationClient.luau`, `LiveViewModel.luau`, `src/client/Bootstrap.client.luau` |
| New engine tests | `tests/unit/P2bWorld.spec.luau`, `P2bGolden.luau`, `P2bScheduling.spec.luau`, `P2bAccounting.spec.luau`; `tests/integration/P2b.spec.luau`, `P2bSoak.spec.luau` |
| Retained transport/runner | `tests/integration/P2aRemote.spec.luau` (optional P2b profile), `Run.client.luau` |
| Final type cleanup | `tests/unit/P2a.spec.luau` (explicit heterogeneous input list); shared/client/server files listed above |
| Local checks | `scripts/ValidateP2b.py`, `ValidateP2bClimate.py`, `ValidateP2bClimate2D.py`, `ValidateP2bClimateOffsets.py` |
| Documentation/evidence | `README.md`, `PLANS.md`, decision register, P2b contract/report/JSON evidence, relevant climate/starting-country/world/architecture/testing specifications, `docs/p2b-screenshots/` |

## Reproduce in Studio

1. Serve `test.project.json` on port **34873** and connect only **Power States - Test**, Universe **10776833313**. Stop/restart Play after source synchronization; loaded ModuleScripts otherwise retain their old implementation.
2. The normal Test bootstrap opens the generated Native country. The development runner exercises fixed P2a and generated P2b GUI/remotes, retained renderer regressions and four ten-minute soaks. Allow approximately 43 minutes. It then returns to the generated live GUI.
3. For a short manual review, disable only `StarterPlayer.StarterPlayerScripts.DevelopmentTests.Run` in the Test edit model before Play, then restore it afterward. Select Starter Generator through Assets, switch Off/On, observe server-confirmed delivery/shortfall, and check that camera, selected asset and inspector survive. Bank remains a placeholder; rejoining creates a fresh unsaved country.
4. For pure tests, use the **Server** command bar after fresh Play: `require(game.ServerScriptService.DevelopmentTests.unit["P2bWorld.spec"])(10000)`. Run `P2bAccounting.spec` and `P2bScheduling.spec` similarly without arguments. The large synchronous corpus intentionally loads the server; run separately from frame benchmarks for clean timing. The scheduling suite uses eight synthetic jobs, not eight real players.
5. Check Script Analysis with **Display only current script off**, in both client and server views. Check desktop/tablet/portrait/landscape layouts, pan/zoom/recenter/Locate, 44px targets, the asset picker, keyboard/gamepad navigation and unavailable-state messaging. Physical-device input/performance is a separate acceptance check.

Local commands: `powershell -NoProfile -File scripts/Validate.ps1`, `python scripts/ValidateP2a.py`, `python scripts/ValidateP2b.py`, and the three climate scripts. Climate cardinal full corpus uses `--seeds 10000 --outer-radius 4608`; 2D defaults to 256 random seeds plus six adversarial seeds. The offset probe has a fixed 132-seed corpus. None uploads, publishes or changes permissions.

## Known limits

- This is a session-only, Studio/Test-gated proof. Production stays untouched and its normal renderer remains Native.
- Terrain is a bounded 64-unit Native cell presentation of the generated field, not the illustrated Hybrid artwork or a final coast/settlement art treatment. Water, land and relief colours are cosmetic; no rivers, fuel deposits, weather events or expansion gameplay are invented.
- Eight-job scheduling and eight-country memory/solver batches are synthetic engine tests. Actual multi-client isolation and low-end physical-device performance are not established by these measurements.
- Initial live generation measured close to the 2 s watchdog in background Studio (1.80–1.92 s), despite low CPU time. The watchdog remains unchanged and fails unavailable instead of changing a seed or template. Foreground eight-job scheduling passed in 340 ms; neither number is a service guarantee.
- No prices, affordability, ten-hour operating reserve, saving, growth, construction, sector purchases, monetisation, R4 or R5 are implemented or validated.

## Historical pre-amendment gate (superseded status)

The following records the original stopped attempt. Statements of unimplemented/pending status in this historical section apply only to that attempt.

## Work completed

Added `scripts/ValidateP2bClimate.py`, an independent standard-library Python integer reference for canonical FNV-1a input, absolute-coordinate value fields, Q12 interpolation, the elevation lapse correction and squared-radius climate blend. This is a validation reference, not the Luau generator. It operates outside the starter-pad reservations; it does not need to approximate their geometry.

Primitive FNV vectors (empty/a/foobar) and Q12 endpoints passed. Three canonical signed-coordinate message vectors are recorded in the result JSON for future Luau parity. Negative-coordinate lattice endpoint parity was checked. A separate exact rational recomputation confirmed the worst pair's blend weights and final temperature values, ruling out floating-point rounding as the reason for the breach.

## Approved v1 failure

Reproduce from the repository root:

```powershell
python scripts/ValidateP2bClimate.py --seeds 10000 --outer-radius 4096
```

Expected exit status **1**: the tool intentionally preserves the failing threshold. [Approved-contract evidence](P2B-CLIMATE-GATE.json) records **10,000 deterministic UUID-shaped seeds**, four cardinal rays through (512,512), radii 2048..4096, and **1,280,000 adjacent 64-unit pairs**. Corpus seeds are SHA-256-derived test fixtures with UUID version/variant bits; this is not a replacement for approved runtime GUID seed issuance.

| Check | Required | Observed |
| --- | --- | --- |
| Temperature difference per 64 units | <=2.00°C | **4 violating pairs; maximum 2.07°C** |
| Rainfall difference per 64 units | <=150 mm/year | 0 violating pairs; maximum 77 mm/year |

Worst counterexample, seed `dfff043298824c4da9e3e4e45da85bc6` (corpus index 8832):

| Quantity | A | B |
| --- | --- | --- |
| World coordinate | (512,-2752) | (512,-2816) |
| Elevation | 111 m | 172 m |
| Raw mean temperature | -19.42°C | -19.42°C |
| Elevation correction | -0.67°C | -1.03°C |
| Temperate weight /4096 | 1967 | 1761 |
| Final temperature | -2.28°C | -4.35°C |

The points are exactly 64 units apart on the shared global sample grid. The temperate overlay fades while the elevation correction also becomes colder; their combined change exceeds the approved limit. This is within the required transition-ring contract, though outside the active starter sector. The protected starting region remains a separate check, not a reason to waive the gradient limit.

## Proposed correction — not approved or integrated

Recommend keeping the <=2.00°C threshold, hash, Q12 kernel, field ranges and inner protected radius unchanged, and widening only the outer blend radius from **4096 to 4608 units (4 to 4.5 sectors)**. This is a revision to the approved v1 formula and needs explicit owner approval. It expands the taper area without changing the owned starting sector, electrical fixtures, demand coefficients or terrain positions. It does not purchase or render extra territory. No persistent countries exist to migrate; the specification and future v1 golden vectors must reflect the approved final formula before any generated profile is accepted.

A clearly labelled, unapproved local comparison is available:

```powershell
python scripts/ValidateP2bClimate.py --seeds 10000 --outer-radius 4608
```

[Candidate evidence](P2B-CLIMATE-CANDIDATE-4608.json): **1,600,000 pairs**, zero temperature/rainfall violations; maxima **1.78°C** and **69 mm/year**. Default script execution continues to test the approved 4096-unit radius and fail; the candidate writes a different file. These are cardinal-ray samples, not all 2D coordinates, not a fairness/diversity sweep, and not proof that the candidate meets every later gate. Broader ring/diagonal/adversarial testing remains necessary after approval, with the same thresholds. No algorithm, threshold or production setting was silently changed.

## What is not yet done

No Luau world generator, generated-country adapter, live climate-aware demand, renderer integration, generated-country screenshot or engine measurement exists for P2b. The 10,000-seed run above checks climate gradients only: **starting fairness, terrain diversity, fallback frequency and full-day electrical replay remain untested for P2b**. No CPU/memory guarantee is inferred from this Python calculation. P2a's real engine results remain historical evidence for P2a only.

Both Rojo builds and Studio Script Analysis will be run when runtime implementation proceeds; they were not repeated for this reference/document-only change. No Studio controls, Roblox settings, assets, permissions, production, dependencies, commits, pushes, publishing or deployment were changed in this Stage 2 attempt. Native and P2a remain the running defaults.

## Historical review request — resolved by D86

Approve the 4608-unit outer transition radius as the sole contract amendment, or select another correction for investigation. Keep all acceptance thresholds. After approval, continue the authorised Stage 2 implementation and its original full validation plan; stop again if a required gate fails. No P3 or other phase is authorized.
