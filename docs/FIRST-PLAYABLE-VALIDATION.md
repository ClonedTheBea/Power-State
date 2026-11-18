# First Playable Loop validation

18 November 2026. Test universe 10776833313, Studio, fake storage only. This integrates the accepted domain proof into normal gameplay; it does not authorize or exercise real persistence. Production and Rowanbridge were not accessed.

## Implemented journey

Normal Test startup now starts one schema-v3 fake construction host and mounts its GUI automatically. The explicit `RunRegressionTests` attribute defaults false; legacy previews/runners require true. Generated countries use existing generation, demand, solver, economy, grants, leases and construction transitions. No arithmetic, schema, terrain or artwork was changed.

Players can inspect generator/substation/town, toggle the generator, see authoritative supply/demand and earnings, inspect connection flows in Overview, open Bank, select Build/the surveyed district, request a quote and confirm the existing project after earning sufficient Credits. Built districts show independent delivery and remain selected. Ordinary panels do not suspend simulation. The critical durable fake Build retains the established suspension and receipt rules.

Bank groups operating totals, starting funds and the operating buffer. The completed action reads “Connected · saved in this Test server”. Loading, stale updates, suspension and live/confirmed saves remain distinct. The GUI explicitly warns that Stop Play discards fake saves. Future-feature previews remain previews.

## Changed implementation files

- `src/server/Bootstrap.server.luau`, `src/client/Bootstrap.client.luau`, `test.project.json`: normal fake entry and explicit regression mode.
- `src/server/Services/ConstructionTestService.luau`: idempotent startup, bounded loading/snapshots, generator intent integration and server-only lifecycle test handle.
- `src/server/Services/ConstructionControls.luau`: retained intent validation on a copied candidate; approved two-sink report before installation; cheap rate admission before history cloning. Controls never settle money/energy.
- `src/client/Simulation/ConstructionClient.luau`, new `PlayablePresentation.luau`, `BankPresentation.luau`: contextual controls, navigation, real state presentation, loading/cleanup and financial grouping.
- `tests/unit/FirstPlayable.spec.luau`, `FirstPlayableLifecycle.spec.luau`; `tests/integration/FirstPlayable.spec.luau`, `FirstPlayableRemote.spec.luau`: focused control, lifecycle, normal journey and actual transport coverage.
- Both existing test runners now require explicit regression mode. Existing suites remain present.
- `scripts/ValidateFirstPlayable.py`, `Validate.ps1`, `ValidateP3a.py`, `ValidateP3b.py`, `ValidateP3c.py`: integration/static boundary checks. Obsolete frozen bootstrap hashes were replaced with explicit guarded startup assertions; unrelated frozen hashes remain.
- README, roadmap, decision register, integration design/report, Git review/inventory and screenshots. `.gitignore` adds private-file exclusions. Prior P3c.5/6 uncommitted work is preserved separately in the checkpoint review.

## Engine validation actually run

| Coverage | Result |
| --- | --- |
| Normal-entry continuous journey | 34 assertions passed; genuine sales, Off/On, Bank while advancing, quote/build, buffer, two sinks, duplicate purchase, camera and private-field exclusion |
| Bank presentation | 83 assertions passed; desktop/portrait/landscape/tablet progression waits .1804/.7986/.7981/.7982s, all below1.2s |
| Copied generator controls, built/unbuilt security | 42 assertions passed, repeated after early rate admission |
| Actual remote transport | 12 assertions passed; 100 invalid requests produced only one periodic snapshot, no mutation; valid commands recovered |
| Same-server lifecycle/fake faults | 18 assertions passed; exact country restoration, fresh command epoch, lost response and failed release save reconciliation, permanent purchase and cleanup |
| P2a domain | 432 assertions passed |
| P2b accounting | 2,941 assertions passed; two-day requested 150.915967 / delivered 139.355967 MWh |
| P2b/P3c world sweep | 2,916,780 assertions; 10,000 unique seeds, zero fallback; all reserved routes/pads, four rotations and safe fallback passed |
| P2b.1 scheduler | 49 assertions; eight jobs completed in 907.439 ms across 54 Heartbeats |
| P3a | 178 assertions passed |
| P3b / P3b.3 / P3b.4 / P3b.5 | 93 / 44 / 33 / 50 assertions passed |
| P3c / safety | 94 / 31 assertions passed |
| P3c accounting | 1,440 steps / 12 restores passed; exact net 353,303 minor units |
| P2a/P2b GUI and remotes | 57 / 88 GUI assertions and 32 / 32 remote assertions passed |
| Construction GUI/lifecycle | 67 assertions passed; 362 map descendants |
| Core presentation | 1,480 assertions across R2 GUI348, R1 GUI16, R2 interaction135, R3 190, R3.1 52 and R3.3 synthetic739 |
| R3.5 focus/presentation | 241 assertions passed on three consecutive runs |

Responsive journey checks covered safe roots 1366×704, 768×960, 360×580 and 640×300. These are Studio layout tests, not physical mobile/gamepad acceptance. Tests drive the same bound GUI actions as normal input; temporary validation scripts were used to invoke tests, not to fund or build through privileged domain shortcuts.

The first journey passed at14:11:18 UTC (34 assertions,6.970s,step152,Bank287.52,map362); genuine earnings had already accrued before that harness began. The fresh Play run passed at14:30:17 UTC: 126.197 seconds from journey start, step135, Bank255.00 Credits after genuine funding and the1,000-Credit purchase,362 map descendants. All12 remote checks preceded it; all83 Bank checks followed. The final harness restored the normal country GUI at14:30:21. No fabricated Bank or accelerated simulation was used.

The lifecycle test calls the normal host's departure/arrival handlers for the authenticated Player while the server stays alive. It does not demonstrate a real network disconnect or hosted multiplayer reconnect. Fake store contents disappear with Stop Play. Destructive/adversarial tests use fake storage only.

## Performance and local checks

P2a1,000 solves15.66ms. P3a maximum encoded profile84,620B, encode p95 7.526ms. P3b full profile89,670B, candidate p95 .518ms. P3c full-ring profile92,283B; full-day accounting1.172s. Fake lifecycle observed13 calls/10 writes/one profile. Normal generated map362 descendants, below600. These are local Studio observations, not service latency or mobile hardware guarantees.

Retained R3 baseline draw p50 .327/p95 .440ms, cold mount22ms; safe-root frame p50/p95 16.62/17.55ms phone and16.61/17.37ms desktop. That baseline has574 map descendants; it is not the new generated-country renderer's CPU benchmark. No new GPU/texture-memory claim.

Both Rojo builds and repository mapping/strict-mode/service-boundary/whitespace checks passed. All16 listed Python validation scripts passed using Python UTF-8 mode; results in `FIRST-PLAYABLE-STATIC.json`. Existing Windows default-codepage failures when reading UTF-8 generated XML were resolved by running `python -X utf8`, without changing test thresholds.

Full-project Studio Script Analysis was inspected with Current Script Only disabled: zero errors/warnings. Temporary harness setup initially selected a separate command-bar module cache and later raced PlayerScripts replication; neither run established acceptance. The final harness uses WaitForChild and the actual LocalScript context. These setup failures are retained as investigation history. Unrelated built-in Studio plugin/asset warnings are not project Script Analysis diagnostics.

## Screenshots and remaining acceptance

Actual Test GUI captures in `first-playable-screenshots/`: desktop built district (`desktop-built-final.jpg`, Oakcombe), narrow completed-project review and narrow Bank (earlier Elmstead run). Current technical Native artwork is intentionally retained. Screenshots are evidence, not runtime assets.

Studio was stopped and temporary validation scripts detached afterward; regression mode remains false. No real DataStore call, live adapter, permissions change, publication, upload, commit or push occurred. Real-art R3.4/R3.7 and ten-minute artwork soaks were not newly completed in this integration pass; unchanged prior acceptance remains historical. Physical touch/gamepad, low-end devices and hosted multiplayer remain release requirements. Owner visual review is still required. No new gameplay phase is authorized.

## How to play locally

1. In this repository run `rojo serve test.project.json --port 34873` (reuse an already-running matching server).
2. Connect only Power States - Test (universe10776833313) to that Rojo server. Leave `ReplicatedStorage.RunRegressionTests` false.
3. Press Play. The generated country and fake-save warning appear automatically; no command-bar/proof runner is needed.
4. Inspect generator and toggle Off/On; open Overview and Bank. Earn at least1,250 Credits, choose Build, request the quote and confirm1,000 Credits. Inspect district delivery and the saved completed state.
5. Stop Play only when finished: this discards the fake server's saves. A new Play starts a new fake country. Same-server restoration is validated through the lifecycle test, not across Stop/Play.

To run legacy regressions explicitly set the Test attribute true before Play, then restore false. Keep all real execution capabilities disabled. Do not connect this test setup to Production.

## Separately gated future real integration

First review this fake player journey and device/input limitations. A future proposal must identify the exact authenticated Test account/universe/store/key, freshly verify the saved schema/country/lease and prepare a protected preimage. Review bounded ordinary-play session/heartbeat limits, checkpoint/renew/release failure behavior and suspended uncertain-state UI before enabling any real route. Obtain separate explicit approval for the exact real reads/writes and financial/construction operations; historical Rowanbridge results are not fresh preflight or permission. Never remigrate, regrant or replay its existing purchase. No automatic real-startup toggle is provided by this milestone.

Git checkpoint preparation is in `FIRST-PLAYABLE-GIT-REVIEW.md`; the inventory distinguishes earlier uncommitted work. Stop here pending owner review; no real-service execution or next feature phase.
