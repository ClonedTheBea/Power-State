# Operations v1.1 validation — 19 November 2026

Status: implementation, automated Test gates and eight-client isolation passed. Full mobile interaction acceptance remains open because swipe scrolling could not be verified; this is not a full device or release sign-off. Isolated Studio Test universe `10776833313`, fake storage only. Operations v1 is owner-accepted; this sprint does not authorize real persistence, schema 4, permanent fleet construction or publication. Rowanbridge and Production were not accessed. Historical synchronous 16 ms failures and the earlier preparation/checkpoint spikes remain in the v1 and Stage 1D reports.

## Whole-lifecycle investigation

The bounded profiler runs three rounds of 120 intervals for eight independent fake countries. It measures preparation, admission, cooperative solve, atomic installation (including finance/history), checkpointing, public projection/JSON encoding and job cleanup. Independent validation/copy/canonical-encoding probes run after, outside the lifecycle measurement. Each baseline/candidate contains 5,760 step/cursor/save assertions. Each round retains eight records and performs 976 fake adapter calls/writes, including acquire and release. Raw phase distributions and heap samples are in [the measurement artefact](NATIONAL-GRID-OPERATIONS-V11-PROFILE.json).

The demonstrated bottleneck is synchronous canonical checkpoint encoding: four complete record comparisons repeatedly invoke the scalar JSON encoder. The fix caches scalar encodings **within one save operation**, capped at 4,096 entries. It still traverses and validates every complete record, compares the complete canonical strings and executes the unchanged fenced/idempotent transition. No hash replaces equality, no cache crosses a save, no financial or scheduler arithmetic changes. Signed zero bypasses scalar caching because Lua table keys equate its two signs. The generic ProfileCodec and real persistence adapters are unchanged.

Matched measurements before/after the initial optimization (milliseconds, p50 / p95 / worst):

| Phase | Baseline | Candidate |
| --- | --- | --- |
| Prepare eight | 0.893 / 1.185 / 2.141 | 0.936 / 1.192 / 1.711 |
| Admit eight | 1.006 / 1.261 / 3.286 | 1.020 / 1.205 / 2.750 |
| Solver slice | 1.129 / 1.884 / 2.928 | 1.138 / 1.878 / 2.700 |
| Atomic install eight | 0.981 / 1.402 / 2.945 | 0.939 / 1.368 / 2.113 |
| Fake checkpoint eight | **20.034 / 22.492 / 41.838** | **10.130 / 11.326 / 29.491** |
| Projection and JSON eight | 0.164 / 0.427 / 0.659 | 0.157 / 0.441 / 1.092 |
| Cleanup | 0.004 / 0.007 / 0.017 | 0.004 / 0.007 / 0.016 |
| Active lifecycle eight | **24.385 / 27.815 / 47.845** | **14.509 / 16.655 / 37.228** |
| Elapsed lifecycle eight | 25.135 / 29.354 / 616.800 | 15.210 / 18.517 / 741.420 |
| Separate validation eight | 0.219 / 0.339 / 0.778 | 0.216 / 0.307 / 0.714 |
| Separate copying eight | 0.228 / 0.381 / 0.692 | 0.232 / 0.323 / 0.613 |
| Separate original canonical encode eight | 4.632 / 5.317 / 10.437 | 4.644 / 5.307 / 9.850 |

Checkpoint p95 fell approximately 50%; active lifecycle p95 fell approximately 40%. The unchanged independent canonical probe provides a control. Round elapsed times, including instrumentation and Heartbeat waits, were 5,338/3,417/3,328 ms before and 4,009/2,362/2,348 ms after. Shared Luau heap deltas were +3,388/−108/+366 KiB before and +3,149/+67/−25 KiB after. These are allocation/collection observations, not peak memory, exact GC attribution or a leak proof. No forced GC or runtime scheduling adjustment was introduced.

`os.clock` phase durations are active-region timing proxies, not OS thread CPU counters: GC, process contention and preemption can contribute. Long cold elapsed tails explicitly include waiting; they are not all solver CPU. The earlier isolated 15.18 ms preparation and 36.95 ms checkpoint spikes cannot be definitively assigned to GC from these samples. This sprint establishes repeated synchronous encoding overhead, not a complete causal explanation for every historical spike. Projection encoding is measured; packet transmission time and Roblox's internal collector are not independently instrumented. Actual client receipt/progression is tested separately below.

The 4 ms target remains cooperative **solver work**, not a whole-server frame guarantee. Eight synchronous checkpoints still have a 29.49 ms observed peak. The 80 ms aggregate solver and 750 ms native/30 Hz contract, fair service, cancellation, stale-owner rejection, atomic installation and deterministic replay remain unchanged. Stage A's existing oracle, yield, scheduler and atomic/financial/security/resource checks passed before proceeding to multi-client work. A later integrated repeat observed a 4.498 ms slice (0.498 ms overshoot); it remains reported under the approved cooperative contract. At deliberately unsupported 15 Hz, six countries safely suspended without partial installation in that repeat.

## Actual Studio multiplayer

A fresh Server & Clients session launched eight actual local Studio players, IDs −1 through −8. This required allowing nonzero negative owner IDs **only in Studio and the approved Test universe**; the server still obtains identity from the sending Player. Zero is rejected. The existing positive account path and Production boundary are unchanged. Training countries deliberately share the same scenario recipe; independent identity/state is not a claim of different procedural seeds.

All eight clients passed normal First Playable → Training entry, forged-owner rejection through the actual RemoteEvent, unique accepted gas caps, independent progression, a 300-frame sample and same-player exit/re-entry with exact saved step/Bank/cap restoration. Server checks confirmed distinct country IDs, state and ledger tables, matching Player ownership and epoch 2. Each map had **394 / 600** descendants. Server observations at completion: 48 intervals, peak solver **1.607 ms**, peak install **1.504 ms**, zero suspended intervals, maximum snapshot **2,113 bytes**. Closing player −7's window then passed actual PlayerRemoving cleanup and released its fake record.

| Client | Gas cap kW | Frame p50 / p95 ms | Worst frame ms | Observed command acknowledgement ms |
| --- | ---: | ---: | ---: | ---: |
| −1 | 4,900 | 66.628 / 74.667 | 6,496.646 | 416.275 |
| −2 | 4,800 | 66.605 / 70.919 | 7,187.634 | 415.800 |
| −3 | 4,700 | 66.669 / 70.427 | 4,373.749 | 416.553 |
| −4 | 4,600 | 66.660 / 69.557 | 3,778.360 | 415.347 |
| −5 | 4,500 | 66.662 / 69.808 | 2,456.082 | 832.840 |
| −6 | 4,400 | 66.644 / 68.462 | 2,199.645 | 416.637 |
| −7 | 4,300 | 16.616 / 19.369 | 2,237.345 | 416.153 |
| −8 | 4,200 | 66.658 / 69.930 | 1,657.766 | 416.448 |

These measurements include startup contention and background-window throttling on one desktop. Commands are observed at 0.4-second polling intervals with bounded retries; these numbers are **not precise network latency**. Most clients rendered around 15 Hz while the foreground client rendered around 60 Hz. The worst stalls are retained. This proves eight connected clients and isolation, not a smooth eight-window experience, hosted server performance or low-end mobile performance. Same-player in-session Training re-entry is not network disconnection/rejoin under the same authenticated account. Actual departure was verified; that network reconnect remains outstanding.

The first attempt failed: the server's client-count deadline elapsed during slow manual launch; two clients accessed Client before replication; one fixed-window flood assertion counted additional periodic snapshots during a long scheduling stall. The harness now uses bounded replication readiness. Multiplayer exercises ownership/control isolation without treating unsolicited snapshots as attack responses. The **unchanged original flood suite** subsequently passed in the separate single-client run (38 assertions, nine responses). No runtime rate limit or test threshold was relaxed. The corrected eight-client run started clients together through Studio, with arrivals spread over approximately seven seconds; perfectly simultaneous network arrival is not claimed.

## Control-room changes

- Generator controls precede detailed financial totals; operational alerts stay near the top. Gas, wind and peaker roles are explained, including standby cost, variable wind and curtailment.
- Rows distinguish last completed production from currently ready capacity, and On-but-not-dispatched from Off. Caps remain upper limits, not forced output.
- Forecasts retain their issue minute and identify unchanged-controls/capacity-estimate assumptions; headroom is explicitly not guaranteed deliverable power through a constrained feeder.
- The Bank/KPI/header/More overview now displays actual training values with a snapshot-at-opening label, live versus confirmed fake balances, sales, costs, net earnings and service. It no longer opens an unrelated illustrative overview.
- Delayed, stale-command and suspended messages explain recovery. Retry is disabled during a save; no new automatic retry, simulation pause, catch-up or income rule was added.
- Native terrain, coordinates, marker hit targets, mouse/touch/keyboard/gamepad bindings and map camera behavior are retained. No new art or generator technology.

## Regression results

Timestamped task outputs are retained in [the results artefact](NATIONAL-GRID-OPERATIONS-V11-RESULTS.json). Counts are per suite, not a deduplicated total.

| Check | Observed result |
| --- | --- |
| Canonical encoder equivalence/bounds | 5,020 assertions, including cache ceiling and signed zero |
| Operations atomic / scenario / security | 326 / 3,144 / 231 passed |
| Operations resource lifecycle | 2,062 passed; eight countries, 120 intervals, 984 fake calls/writes, eight records, max profile 5,712 bytes / snapshot 2,139 bytes |
| Independent solver oracle | 2,187 exhaustive configurations / 8,854 assertions passed |
| Exact yield equivalence / scheduler lifecycle | 9,100 comparisons / 1,486 assertions passed |
| Integrated scheduling | 63 eight-country intervals per repeat; native/30 Hz pass, unsupported 15 Hz failures safely suspend |
| Operations GUI / actual remotes / journey | 129 / 38 / 11 passed; minute 96 and Bank 133,691 minor units restored without offline revenue |
| P2a / P3a / P3b | 432 / 178 / 93 passed |
| P3b.3 / .4 / .5 fake proofs | 44 / 33 / 50 passed; no real calls |
| P3c / safety / First Playable controls | 94 / 31 / 42 passed |
| P2b accounting | 2,941 assertions; two-day requested 150.915967 / delivered 139.355967 MWh |
| P3c accounting | 1,440 billed intervals / 12 restores; net 353,303 minor units; full-ring profile 92,283 bytes |
| P2b.1 generation scheduling | 49 assertions; eight synthetic jobs in 936.327 ms / 56 Heartbeats |
| World and construction corpus | 2,916,780 assertions; 10,000 unique starts, zero fallback, all four rotations/routes/pads; generation p95 14.953 ms; maximum snapshot 43,705 bytes |
| First Playable actual remotes / purchase journey | 12 / 34 passed; step 164, Bank 310.48 Credits, map 362 descendants |
| Bank GUI | 83 passed across four roots; observed authoritative progression 0.798–1.197 s |
| Shared layout / currency / interaction | 348 / 16 / 135 passed |
| Map / framing / synthetic hybrid / R3.5 presentation | 190 / 52 / 739 / 241 passed |
| Local checks | 597 passed; both Rojo builds and whitespace/remote/source boundaries passed |

The retained First Playable host earned normally while the seed corpus ran; its purchase journey therefore began already funded and took 5.823 seconds. It is not a new timed zero-to-purchase progression result. The prior full fresh-country journey remains in the v1 report. All legacy tests remain present and unchanged. Unmodified R3.4/R3.7 real-atlas ten-minute endurance was **not rerun** in this sprint; its prior v1 evidence is retained, not relabelled as new validation.

The final signed-zero-safe candidate repeated Stage A successfully. Checkpoint8 p50/p95/worst was 10.360/11.905/17.620 ms; activeLifecycle8 14.796/17.005/24.865 ms. The earlier larger candidate peaks remain in the table and artefact. Resource-repeat peaks: preparation 3.247 ms, solver 2.389 ms, install 1.824 ms, fake save 2.646 ms. Four unsupported-15-Hz countries suspended safely in this repeat. These are measured repeats, not tighter contractual guarantees.

## Visual and input evidence

Actual Studio captures: [desktop congestion](operations-v11-screenshots/desktop-congestion.png), [portrait 390×640](operations-v11-screenshots/portrait-390x640.png), [portrait Bank](operations-v11-screenshots/portrait-bank.png), [tablet 1024×640](operations-v11-screenshots/tablet-1024x640.png), [short landscape 844×390](operations-v11-screenshots/landscape-844x390.png), [emulated gamepad activation](operations-v11-screenshots/gamepad-overview.png). The four-size automated matrix also covers 1366×704, 1024×720, 390×780 and 844×390. Safe-root captures are actual engine layouts inside a desktop viewport, not physical-device performance tests or identically timed country snapshots. Long financial/help text remains scrollable; narrow layouts intentionally hide the map while operating the fleet and expose it through Grid/Locate.

Mouse KPI activation and keyboard Escape were inspected (Escape also opens Roblox's normal menu). Automated keyboard focus/activation, acknowledgements and camera preservation passed. Direct virtual-controller D-pad/A/B inputs moved focus, opened the authoritative overview and returned focus after dismissal. The initial mapped-key emulator attempt did not route input and is not a passing keyboard-mapping result; no mappings were changed. Roblox documents direct widget controls as real emulated input in [Controller Emulator](https://create.roblox.com/docs/studio/controller-emulator). Physical controllers, analog dead zones and full gamepad-only playthrough remain outstanding.

An attempted Command Bar call to `OperationsClient.active()` returned no mounted instance in that execution context; no game state changed. Layout capture instead resized the actual PlayerGui SafeRoot and restored scale sizing afterward. This was an inspection harness issue, not a claimed runtime failure or skipped gameplay assertion.

The iPhone17 Pro simulator then confirmed clean normal First Playable startup with all regression flags off (`TouchEnabled=true`, `KeyboardEnabled=false`). Touch-mode taps opened More, entered Operations, returned to Grid and selected National Substation with its actual server flow inspector: [training entry](operations-v11-screenshots/mobile-emulator-training.png), [selected infrastructure](operations-v11-screenshots/mobile-emulator-inspector.png). The current simulator orientation was short landscape; portrait was separately checked using the safe-root matrix above.

**Unresolved manual acceptance:** automated swipe/wheel attempts did not reliably move the short More drawer. A bounded trace saw only two Touch movement events near the drag endpoint (about one pixel apart), so it did not establish a usable swipe gesture. Temporarily setting the frame Active=true did not resolve it; the original false value was restored and no shared scrolling code changed. To test the subsequent taps, the drawer was positioned programmatically at CanvasPosition.Y=140; this is explicitly **not** swipe acceptance. An owner-driven emulator/physical swipe must confirm More/fleet/Bank scrolling before full mobile interaction sign-off. No automatic pass or confirmed runtime defect is claimed from this tool-limited trace. Stop Play removed all temporary probes.

## File inventory and rerun procedure

Runtime changes: `OperationsEncoding`, `OperationsStore`, `OperationsCountry`, `OperationsClient`, `OperationsView`. New tests: `OperationsEncoding.spec`, `OperationsProfile.spec`, `OperationsV11Run.server`, actual multiplayer client/server probes and retained legacy client/server runners. Existing Operations GUI assertions expanded. `scripts/Validate.ps1` allows the isolated multiplayer probe's intentional remote sends. No production startup or project mapping change.

Use `rojo serve test.project.json --port 34873` with Power States - Test. All flags below are Test-only opt-ins, absent/false normally. Restart Play to reload modules. Run one family at a time:

1. `OperationsV11Run="Candidate"`: bounded profiling, canonical equivalence and retained Operations/oracle/scheduler gates. `Baseline` is a label for collecting a pre-optimization build, not a runtime switch that restores the old encoder.
2. `OperationsMultiplayer=true`, `OperationsExpectedClients=8`: launch eight Server & Clients players; inspect all eight PASS outputs and server output; close one client to check release. Clear other runners.
3. `RunOperationsTests=true`: normal entry, GUI, actual remotes, conditional forecast/shortage/congestion, deliberate two-second delay, Retry and fake re-entry.
4. `OperationsV11Legacy=true`: retained pure/fake finance, construction, 10,000-seed geometry/world gates, First Playable journey, Bank and shared GUI coverage. The new orchestration allows up to 600 seconds for corpus readiness; existing suite assertions/deadlines are unchanged.
5. Clear flags and Stop Play. Ordinary Test entry remains First Playable, with explicit navigation into disposable Training. Production remains Native and unaffected.

## Final diagnostics and cleanup

Full-project Studio Script Analysis on the final source showed **0 errors / 0 warnings** during the Play validation, with Current Script Only disabled. An additional edit-mode recheck was attempted at closeout; computer control stalled before the Analysis panel could be inspected, so no additional edit-mode result or screenshot is claimed. Both Rojo builds and local source checks passed again at closeout.

Play was stopped after mobile inspection; the regression flags were cleared and temporary input probes removed. Ordinary Test entry remains First Playable. Rojo remains connected on port 34873. No real DataStore, Rowanbridge, Production, permissions, publication, commit or push operations were performed.

## Remaining boundaries and recommendation

Hosted load, same-account network reconnect, physical touch/gamepad and low-end devices remain outstanding. Full-frame server CPU/GC and network transport attribution are not established by solver timings or projection JSON timings. Fake storage is disposable and not a production persistence protocol. No real service operation, migration or permanent purchase is authorized by this report.

Recommended next step: manually verify More, fleet and Bank swipe scrolling in short landscape, then owner playtest of control-room clarity plus hosted/device validation, then a separately reviewed first operational investment milestone (for example relieving the visible East feeder bottleneck). Do not automatically implement it: permanent infrastructure, schema changes and real persistence need their own safety/design approval.
