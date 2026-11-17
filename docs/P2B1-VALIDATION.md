# P2b.1 — Multiplayer and generation stability

17 November 2026. **Available validation complete; remaining acceptance limits below.** P2b is owner-approved as the basis for this narrowly scoped verification/remediation task. Test universe 10776833313 only; Production 10776828545 is untouched.

## Scheduler investigation and change

The former service resumed each country once per Heartbeat. A normal start yielded 20 times, imposing approximately 21 frames of latency even when generation consumed only tens of milliseconds. Earlier Play Solo/background observations of 1.80–1.92 seconds are consistent with scheduling delay, not a demonstrated CPU bottleneck.

A two-real-client Server and Clients baseline measured 329.630 / 330.179 ms elapsed, 26.942 / 19.886 ms accumulated generation work, 1.348 / 1.108 ms initial queue delay and 300.943 / 308.798 ms between resumes. Each performed 21 resumes / 20 yields. These are actual Studio measurements; foreground/background scheduling and process load differ from earlier Play Solo runs.

`GenerationScheduler` now resumes round-robin jobs repeatedly within a 2 ms per-Heartbeat work target, with a hard 64-resume ceiling and at most eight pending jobs. Each generator still yields at the existing 128 samples or 2 ms boundary. The final cooperative slice can overrun the frame target by its own duration; this is not a preemptive CPU limit. Initial queue delay and all suspension time still count toward the unchanged two-second watchdog, checked before and after every resume. A timed-out final slice cannot publish its completed world. Leave cancels and removes pending work immediately.

No hash, Q12 kernel, climate field, radius, candidate order, reservations, seed/version rule, demand coefficient, fairness threshold or solver algorithm was changed. `WorldGenerator`, `IntegerField`, `ClimateModel`, `StarterValidator`, `DemandModel` and the P2a fixture remain unchanged during P2b.1.

Diagnostics are server-only, Studio/Test-guarded copied records; no diagnostic remote or private world folder is replicated. Timing records distinguish accumulated generation work, total resume work, initial queue delay, inter-resume wait, wall time, yields and resumes. The `os.clock` intervals measure active elapsed work, not operating-system per-thread CPU counters. Diagnostic history is not retained by the service.

## Actual multi-client evidence

Studio's **Server and Clients** launched eight real client processes, all connected simultaneously to one local Test server. Roblox assigned local test UserIds -1 through -8. Eight-player launch was requested together, but process startup staggered joins over approximately 20 seconds; players -2 and -3 generated concurrently. This is not eight perfectly simultaneous joins.

All eight starts completed: elapsed **162.287–333.276 ms**, accumulated generation **27.046–33.850 ms**, initial queue **1.204–4.736 ms**, suspension wait **129.062–301.074 ms**. No watchdog limit was raised. The distinct seeds and country IDs were checked server-side, each state owner matched its actual Player.UserId, and every owned terrain descriptor reproduced exactly from that player's server-owned seed.

Eight synthetic jobs submitted together to the real scheduler/Heartbeat completed in **866.826 ms / 51 Heartbeats** while eight real clients were open. The scheduler suite passed **47 assertions**, including round-robin order, eight-job ceiling, cancellation, queue expiry, final-slice deadline expiry, error cleanup, hard resume bound, full chunk equality and unchanged candidate choice. This scheduling burst is explicitly synthetic, not additional players.

All eight actual clients passed 14 control/isolation assertions each (112 total), observing 119 gameplay packets. Cross-player epoch/asset commands and forged owner fields were rejected. Each own Off/On cycle preserved every peer's controls, identity and independent delivered/requested accounting; all eight server peer checks passed.

After disconnecting local user -8, PlayerRemoving released its country and seven retained countries passed verification. A new actual client joined as -9: generation completed in 221.375 ms, eight countries were present again, all retained identities stayed unchanged and the newcomer received fresh identity/seed/state. This proves removal and replacement joining, **not same-account reconnection**: Studio assigned a new UserId.

Final expanded scheduler suite: **49 assertions passed**, including queued and already-suspended cancellation; eight synthetic jobs completed in **1004.223 ms / 59 Heartbeats**. Earlier 47-assertion timing above is a separate run.

## Regression and resource results

- Actual server P2a: **432 assertions**; P2b 10,000-seed sweep: **2,916,780 assertions**, 10,000 unique starts, zero fallback; P2b accounting: **2,941 assertions**. Deterministic vectors, climate thresholds, fairness/diversity and replay coverage retained.
- Generation active-work p95 **18.700 ms** in the sweep; eight retained countries approximately **728.12 KiB/country** (allocator/GC-sensitive). Demand step p95 **0.0384 ms**, eight-country batch **0.3420 ms**. This synchronous stress sweep is not a normal join/frame benchmark.
- Actual client regressions: P2a GUI **57**, P2b GUI **88**, GUI layout **348**, R2 interaction **135**, P2a remote **32**, P2b remote **32**, plus cleanup checks. Generated map count remained **345**.
- Client render CPU p95 desktop **0.1467 ms**, portrait **0.1864 ms**, tablet **0.1628 ms**. Frame p95 approximately **67 ms** while many local Studio windows ran in the background: host/background throttling, not physical-mobile performance evidence.
- Both Rojo builds and source boundary/whitespace validation passed. P2a local mapping checks **34**, P2b/P2b.1 checks **38**. Studio Script Analysis reported **zero errors and warnings**, with Current Script Only disabled.

Machine-readable selected log evidence is in [measurements](P2B1-MEASUREMENTS.json). [Script Analysis capture](p2b1-screenshots/script-analysis.jpg).

## Changed files

Runtime: new `src/server/World/GenerationScheduler.luau`; updated `src/server/World/GeneratedService.luau` scheduling, cancellation and guarded diagnostics. Tests: new `tests/unit/P2b1Scheduler.spec.luau`, `tests/unit/P2b1Multiplayer.spec.luau`, `tests/integration/P2b1.spec.luau`, `tests/integration/P2b1Probe.client.luau`. Static validation: `scripts/Validate.ps1`, `scripts/ValidateP2b.py`. Documentation: this report/measurements/capture, `PLANS.md`, `README.md`, `docs/TESTING.md`, `docs/DECISIONS.md`, and the historical P2b report cross-reference. Existing unrelated uncommitted work is preserved.

## Test harness corrections and unrelated diagnostics

- Studio Command Bar `require` has a separate module context from running server Scripts. Its first live-service inspection correctly reported “Generated service not started”; rerunning via a temporary server Script reached the actual service. This was not a live generation failure.
- A server test Script cannot assign Script.Source. Client probe source is prepared through Studio, then cloned by the server; no capability, permission or setting was changed.
- The first client test used the latest periodic snapshot to inspect the full Sync descriptor and raced with the next periodic packet. The test now retains the explicit Sync response. That failed harness attempt made no generator mutation; its results are excluded from acceptance.
- The first leave probe asserted cleanup after exactly one second, racing PlayerRemoving; subsequent inspection verified completed removal. No service change was needed. Final cancellation fixtures were corrected to avoid binary floating-point subtraction at an exact fake-clock slice/deadline; runtime thresholds were unchanged.
- Studio emitted built-in legacy ChatScript/CoreGui registration errors and an existing unrelated asset-type warning during local startup. No chat or asset changes were made under this task.

## Reproduction

Use `test.project.json` on Rojo port 34873 and only the approved Test experience. Temporarily disable `StarterPlayer.StarterPlayerScripts.DevelopmentTests.Run` for a focused multiplayer session so eight clients do not each run the unrelated 43-minute GUI runner. Restore it afterward. Select Server and Clients, set eight clients, start, and wait for generation timing messages.

Run live diagnostics from a **server Script**, not a direct command-bar module require. A temporary Studio-created Script can call `require(game.ServerScriptService.DevelopmentTests.unit["P2b1Multiplayer.spec"]).runAll(8)`. The supplied dormant `P2b1Probe` is cloned with adversarial peer identifiers for each client; those fixture identifiers are deliberately provided by the test harness, not leaked by the gameplay channel. The client checks only the gameplay Snapshot stream for foreign data, while the server independently verifies that other countries' controls and accounting remain unaffected.

Run `P2b1Scheduler.spec` on the server for scheduling/timeout/cancellation tests. Retain `P2bWorld.spec(10000)`, `P2bAccounting.spec`, fixed P2a and client remote/GUI suites. Do not run a synchronous 10,000-seed stress sweep while measuring normal join latency.

Studio cleanup completed: all local server/client windows closed, ordinary single-client Test mode restored, automatic `DevelopmentTests.Run` re-enabled, and Rojo remains connected to Test on port 34873.

## Scope and remaining limits

No persistence, spending, construction, events, artwork, uploads, permission changes, commits, pushes or publishing. Native remains the default. Local multi-client results do not prove hosted-server latency or physical-device performance. Same-account rejoining, actual disconnect during pending generation, hosted-server/network conditions and physical devices remain outstanding. Queued/suspended cancellation is automated coverage, not proof of an actual pending-player disconnect. Eight-client startup was staggered, while the simultaneous eight-job burst was synthetic. The packaged runAll wrapper is provided for repeatability; this session used equivalent Studio-created client probes and server peer checks, not that final convenience wrapper. No new soak claim is made; earlier P2b endurance evidence remains historical. Stop after P2b.1; next step is owner review and those remaining acceptance checks, not a later gameplay phase.
