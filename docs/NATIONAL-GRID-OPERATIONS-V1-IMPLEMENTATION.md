# National Grid Operations v1 — isolated training sprint

18 November 2026. **Stages A–D complete: available isolated Test acceptance gates passed; stopped for owner review.** Owner authorizes Stages A–D in Studio Test10776833313 with fake storage only. Historical synchronous16 ms failures remain recorded.

## Stage status

| Stage | Evidence |
| --- | --- |
| A | Passed before B; final 63-interval scheduling rerun and 326 atomic assertions passed |
| B | Passed: scenario domain 3,144 assertions; exact per-unit finance and fake recovery |
| C | Passed: normal-entry GUI 119 assertions at four safe-root sizes; screenshots below |
| D | Passed: complete journey, idle suspension/retry, remote/reconnect, retained world/First Playable/GUI/artwork endurance, builds/static and full-project edit-mode Script Analysis |

## Implementation

New server modules under src/server/Operations:

- OperationsLedger: temporary ledger version1, denominator60,000, national sales carry and per-generator expense meters/carries. Aggregate expense sums posted unit amounts without rounding again.
- OperationsCountry: deeply frozen state,60-entry history, energy/reliability/Bank/cursor validation. Commands advance revision. Scenario inputs pin topology, terminals, prices and recipe.
- OperationsBatch: maximum eight jobs; captures complete frozen state identity plus authenticated owner/epoch. Pure candidate preparation, then non-yielding final compare and one pointer swap. Entire admission list is validated before actor claims.
- OperationsWind / OperationsScenario: namespaced version1 seed20/coastal-training wind; hourly permille knots575,32,290,548,562. Shared repeatable recipe with independently owned country state; no terrain/climate hash change.
- OperationsStore: existing FakeDataStoreAdapter, memory only; active epoch/revision/full-record compare and unique receipt. At most two updates/two reconciliation reads; retries never recompute intervals. Not schema4 or a replacement for real ProfileService leases.
- OperationsCommands / OperationsProjection / OperationsService: strict scalar commands, sending-player authority, epoch/revision/sequence checks; six-token burst, three/second refill. Owner-only bounded snapshots, one global batch, eight retained training owners per Test server. No real adapter parameter.

OperationsClient / OperationsView reuse AppController, Native map, shared components and focus. NavigationView adds optional label overrides. Bootstraps and ConstructionTestService integrate only the guarded Test mode.

First Playable remains default. Infrastructure opens Operations Training; mobile uses More → Operations Training. Return releases training; re-entry restores confirmed state while this server lives. The inactive First Playable fake country pauses during training to avoid invisible funding. Ordinary menus within the active mode never pause it. Stop Play discards training saves.

The existing generated Native terrain descriptor is reused cosmetically. Training anchors are separate presentation coordinates; saved-country infrastructure and artwork are untouched.

## Atomicity and financial evidence

Complete immutable identity binds ownership/epoch, country/step/cursor/revisions, controls/caps, availability, demand, prices, recipe and prior meters. Replacing state invalidates pending results even if compact scheduler stamps match. Report, history, reliability, finance and cursor install together. No service call occurs during installation.

No backlog/catch-up; at most one admission round per real second. Failed/unfunded calculations suspend without billing. Retry is explicit; controls can reduce costs. Failed checkpoints block progression until bounded reconciliation. Live and confirmed Bank remain distinct.

326 atomic assertions: stale identity, control invalidation, replay, deadline/CPU/work failures, zero-fund recovery,32×8 cancellation cycles and malformed admission. One-hour fixture:624 Credits sales,418 total expenses, opening1,000 →1,206 Credits. Original state remains byte-identical.

Scenario3,144 assertions include3,001 deterministic wind samples, golden knots, forecast purity, dispatch, exact saved history/controls/carries, callback replay, lost response, before-write failure and stale ownership. Initial1,000 Credits is temporary fixture state, not an existing-country grant. Security231 assertions cover malformed/foreign/replayed/stale commands, spam, checkpoint exclusion and private projection fields.

## Initial Stage A measurements

[Baseline data](NATIONAL-GRID-OPERATIONS-STAGEA-BASELINE.json); [atomic integration data](NATIONAL-GRID-OPERATIONS-STAGEA-SCHEDULE.json). Three rounds × seven workloads × eight countries per cadence.

| Cadence | Completed | Max solver CPU/batch | Peak solver slice | Max elapsed | Peak candidate/install |
| --- | ---: | ---: | ---: | ---: | ---: |
| Native |168/168|42.931 ms|3.789 ms|181.497 ms|2.900 ms|
| Throttled30 Hz |168/168|41.132 ms|3.778 ms|484.070 ms|2.861 ms|
| Throttled15 Hz |160/168|38.883 ms|3.837 ms|778.686 ms|3.058 ms|

Failed15 Hz interval preserved all eight complete states and released retained jobs. Cleanup happens on the next service opportunity; expired results cannot install. Sampled solver overshoots above4 ms:zero. Candidate preparation/install is additional work;4 ms is not total-frame or hard real-time performance. Historical16 ms synchronous failure remains failed.

Retained initial run:2,187 oracle configurations/8,854 assertions,9,100 yield/permutation comparisons,1,486 scheduler assertions,63 integrated intervals. Shared-Luau heap deltas are not a peak RAM guarantee.

## Gameplay

Approved gas5MW80 Credits/MWh+10/hour On; wind2MW0+6; peaker2MW110+2; sales120. Fixed costs apply even at zero dispatch. Gross prefunding includes capped availability and carries, never expected sales.

Demand rises3→6 MW in60 minutes while wind falls1.150→.064 MW. Peaker Off leaves936 kW unmet; enabling it restores936 kW at higher cost. Minutes90–120 place3.5 MW demand behind the3 MW East feeder:500 kW remains unserved despite spare generation. Lossless transport flow, not AC/frequency simulation.

Five conditional forecast samples refresh after15 steps or controls change; routing estimates are explicitly approximate. Headroom excludes wind and is not guaranteed deliverable reserve/N−1 security. Alerts deduplicate and cap at8.

## Final scheduling rerun

[Final integrated scheduling data](NATIONAL-GRID-OPERATIONS-INTEGRATED-SCHEDULE.json), measured at21:20 UTC after the recovery fix. The [earlier final rerun](NATIONAL-GRID-OPERATIONS-STAGEA-FINAL-SCHEDULE.json) remains preserved.

| Cadence | Completed | Max solver CPU/batch | Peak solver slice | Max elapsed | Peak candidate/install |
| --- | ---: | ---: | ---: | ---: | ---: |
| Native |168/168|37.638 ms|3.773 ms|148.726 ms|3.191 ms|
| Throttled 30 Hz |168/168|41.230 ms|3.833 ms|431.482 ms|2.825 ms|
| Throttled 15 Hz |168/168|36.718 ms|3.798 ms|715.025 ms|3.262 ms|

No sampled solver overshoot; all queues released to zero. This later 15 Hz pass does not erase the initial 15 Hz failures or establish a 15 Hz guarantee. The earlier failed interval and a separate actual two-second host delay prove suspension with unchanged Bank, physical history and cursor. Explicit Retry completes one interval without catching up missed time. Native/30 Hz are the approved minimum-service acceptance conditions.

The final type-clean rerun at21:42 UTC also passed all63 intervals: Native168/168, CPU40.327 ms, peak slice3.816 ms, elapsed174.564 ms;30Hz168/168, CPU37.307 ms, slice3.781 ms, elapsed419.111 ms;15Hz168/168, CPU37.262 ms, slice3.772 ms, elapsed717.106 ms. No solver overshoot; candidate/install peaks2.990/2.790/2.797 ms. [Complete final repeat](NATIONAL-GRID-OPERATIONS-TYPE-CLEAN-SCHEDULE.json).

## Operator journey and responsiveness

The normal First Playable Infrastructure entry opened the training country through actual remotes. Tests changed the gas output cap, switched wind and gas Off/On, used Locate, pan, zoom, Recenter, keyboard activation and Help, and retained the focused control and camera. Ordinary menus allowed authoritative progression. Map descendants stayed at **394**, below 600, through movement and resize.

The real-time fake journey observed the minute-61 shortage, enabled the peaker to restore service, then observed the minute-91 East feeder constraint. The injected host delay suspended the pending interval without billing; Retry resumed once. Leaving and re-entering restored minute96 and Bank **1,336.91 Credits** with the peaker state and exact financial history, without offline revenue. This is same-session fake reconnection, not real DataStore durability.

The actual RemoteEvent test passed38 assertions, including malformed fields, stale ownership/revision, invalid caps, non-finite values, oversized strings and replay. Controls remained unchanged after invalid requests. A100-request flood produced9 snapshots within the existing allowance (including ordinary progression snapshots). Unit security passed231 assertions and verified bounded owner-only projections with no seed, ledger or storage receipt.

Actual Studio captures (virtual safe roots, different elapsed training minutes, not physical-device or identical-time comparisons):

- [Desktop1366×680](operations-v1-screenshots/desktop.png): map and scrollable control room together.
- [Tablet768×680](operations-v1-screenshots/tablet.png): full-width fleet controls; Grid remains a separate route.
- [Mobile390×680](operations-v1-screenshots/mobile.png): five-item bottom navigation and scrollable fleet/forecast. Partially visible rows at scroll edges are normal clipping by the scroll viewport.

Automated safe-root checks additionally covered1366×704,1024×720,390×780 and844×390. Fleet text fits its measured row height and interactive controls remain at least44px. Shared R3 frame sampling after the final camera fix measured p95 **17.60 ms at360×580** and **17.55 ms at1366×704** on this desktop Studio host; these are retained map measurements, not Operations-specific low-end device results.

## Retained validation

[Selected timestamped Studio output](NATIONAL-GRID-OPERATIONS-SPRINT-RESULTS.json) supplements the scheduling JSON files. Counts are per suite, not a deduplicated total.

| Check | Actual result |
| --- | --- |
| Independent fleet oracle |2,187 configurations /8,854 assertions passed |
| Yield/permutation equivalence |9,100 comparisons passed |
| Scheduler lifecycle |1,486 assertions passed |
| Expanded Stage1C fairness/conservation |1,037 assertions passed; historical synchronous16 ms timing failures retained |
| Operations atomic / scenario / security |326 /3,144 /231 passed |
| Operations GUI / RemoteEvent / journey |119 /38 /11 passed; complete runner repeated after final type corrections |
| P2a / P3a / P3b |432 /178 /93 passed |
| P3b.3 / P3b.4 / P3b.5 fake regressions |44 /33 /50 passed |
| P3c construction / safety / First Playable controls |94 /31 /42 passed |
| First Playable actual remote / complete journey |12 /34 passed;122.818s journey, one purchase, final step135 and Bank253.08 Credits |
| P2b.1 scheduler |49 passed; eight synthetic generation jobs,899.594 ms across52 Heartbeats |
| P2b accounting |2,941 passed; two-day requested150.915967 / delivered139.355967 MWh |
| P3c accounting |1,440 billed steps /12 restores; net353,303 minor units; full history profile92,283 bytes |
| P2b world |2,916,780 assertions;10,000 unique seeds, zero fallback; generation CPU p9515.628 ms, max snapshot43,705 bytes |
| P3c geometry |10,000 seeds, all four rotations and safe fallback passed |
| Shared GUI after final layout fix |348 layout,16 currency,135 interaction,190 map,52 framing,739 synthetic hybrid,241 R3.5 presentation passed |
| Bank overview |83 assertions passed before final layout hook; its normal route uses unchanged default geometry |
| R3.7 real settlement presentation |1,413 assertions;600.2-second endurance,589 cycles,595 map descendants |
| R3.4 real atlas presentation |259 assertions;600.9-second endurance,591 cycles,935 whole-shell descendants (not map count) |
| Local static checks |597 passed: First Playable33,P2a34,P2b38,P3a167,P3b147,P3c178 |
| Rojo |Both default and Test builds passed; strict/source/remote boundary and whitespace checks passed |
| Full-project Script Analysis |Final edit mode0 errors/0 warnings; Current Script Only disabled |

Eight-country lifecycle validation runs120 intervals for each independent fake owner, checkpoints each interval, releases/reacquires all eight and rejects a delayed stale writer. Initial measurements:2,061 assertions, max fake profile5,712 bytes,984 fake update calls, eight retained records, zero retained jobs. Preparation peak4.106 ms, solver2.159 ms, candidate/install1.873 ms and fake checkpoint6.041 ms were measured separately. Shared Luau heap delta was−258 KiB; garbage collection makes this neither a peak memory bound nor proof of no leaks. The final repeat added public-projection measurement:2,062 assertions passed; max snapshot2,139 bytes and max profile5,712 bytes, again984 updates/eight records. Preparation peaked4.918 ms, solver2.649 ms, install1.726 ms and fake checkpoint5.991 ms; heap delta+1,189 KiB. An earlier scheduling run measured a4.195 ms install phase. These costs are explicitly outside the4 ms cooperative solver slice. The post-reopen repeat still passed2,062 resource assertions but recorded preparation15.176 ms and fake checkpoint36.953 ms peaks, solver2.947 ms, install1.853 ms and heap delta+2,707 KiB. These spikes are retained, not averaged away; profile/snapshot sizes stayed5,712/2,139 bytes. They warrant further profiling before hosted eight-player rollout. The observed normal one-player host at21:23 reported175 admitted rounds, one injected suspension, peak solver0.418 ms, install0.270 ms and actual maximum snapshot2,186 bytes. No real service latency is claimed.

## Corrections

The initial invalidation fixture completed before mutation; the corrected test retains the assertion and proves heavy-job pending state before mutation. Batch prevalidation prevents malformed admission from stranding ownership. Navigation label overrides fix overlapping icon text.

An actual camera regression was caught by the unchanged Help/camera assertion: the training presenter first received a full-width map and then shrank it, allowing viewport clamping to shift the camera on each refresh. AppController now offers an optional layout adapter, applied before its single layout pass. The default layout is unchanged. The camera assertion and keyboard focus checks now pass. Measured dynamic fleet text heights prevent narrow-screen clipping.

The first legacy GUI harness incorrectly left live First Playable mounted while a fixture-only test waited for the preview Bank label. The temporary runner now destroys that controller and mounts the original preview before running the unchanged legacy suites. No assertion, timeout or financial rule was weakened.

Final code review found that a safely suspended country sent no more status snapshots. After three seconds the client could classify it as disconnected and disable Retry. The host now sends a bounded one-second status heartbeat when no jobs are admitted, without advancing state or writing storage. The journey regression deliberately waits4.1 seconds while suspended, checks unchanged step/Bank and enabled Retry, then resumes. The final integrated run passed all11 journey assertions twice, at21:22 and21:44 UTC. Both restored minute96 and Bank1,336.91 Credits.

Full-project **edit-mode** Script Analysis initially exposed34 warnings that were absent from the Play view. Corrections give dynamic actor fixtures explicit container types, malformed test inputs an explicit heterogeneous type, and requires stable relative paths. Scenario/inspector definitions now use named records instead of mixed string/number arrays; the command guard and multiline formatting are clearer. Values, ordering, rules and test assertions are unchanged. Final full-project analysis reports **0 errors /0 warnings**, and the complete Operations runner passed again afterward. [Accessible analysis record](operations-v1-screenshots/script-analysis.txt).

An attempted enlargement undocked Script Analysis outside the capture surface. Studio was reopened and its Test project resynced; keyboard control and accessibility inspection completed validation. The panel remains floating and may need manual docking/closing. No experience was published. Normal startup flags were cleared and verified after the final run.

## Changed-file inventory for this sprint

Earlier quote/solver investigation files were already uncommitted and have been preserved.

- New server files: `src/server/Operations/OperationsBatch.luau`, `OperationsCommands.luau`, `OperationsCountry.luau`, `OperationsLedger.luau`, `OperationsProjection.luau`, `OperationsScenario.luau`, `OperationsService.luau`, `OperationsStore.luau`, `OperationsWind.luau`.
- New client files: `src/client/Simulation/OperationsClient.luau`, `OperationsView.luau`.
- Integration changes: `src/server/Bootstrap.server.luau`, `src/server/Services/ConstructionTestService.luau`, `src/client/Bootstrap.client.luau`, `src/client/Controllers/AppController.luau`, `src/client/Views/NavigationView.luau`, `scripts/Validate.ps1`.
- New unit suites: `tests/unit/OperationsAtomic.spec.luau`, `OperationsSchedule.spec.luau`, `OperationsScenario.spec.luau`, `OperationsSecurity.spec.luau`, `OperationsFleetLifecycle.spec.luau`.
- New engine suites: `tests/integration/Operations.spec.luau`, `OperationsJourney.spec.luau`, `OperationsRemote.spec.luau`.
- Repeatable opt-in runners: `tests/OperationsRun.server.luau`, `tests/integration/OperationsRun.client.luau`; server mapping in `test.project.json`. No opt-in attribute is enabled by default.
- Documentation: this report, three StageA JSON captures, final integrated and type-clean scheduling JSON, selected sprint output, screenshots, `PLANS.md`, `docs/DECISIONS.md`, `docs/TECHNICAL-ARCHITECTURE.md`, `docs/TESTING.md`.

## Reproduction and next gate

Connect **Power States - Test**10776833313 to `rojo serve test.project.json --port 34873`. Leave `RunRegressionTests=false` and `RunOperationsTests` absent/false, then start Play. First Playable remains the default. Choose Infrastructure / Operations Training; on a phone use More. The training country has no relationship to Rowanbridge's real profile. Switch on Reserve Peaker before the first forecast shortage; later inspect East's feeder bottleneck. Return to First Playable releases training; re-entry restores it only while this Test server lives. Stop Play discards fake progress.

To rerun the new suites, set the Test-only ReplicatedStorage attribute `RunOperationsTests=true`, keep `RunRegressionTests=false`, then start fresh Play. The two OperationsRun scripts run the domain/resource/scheduling checks, normal entry, UI/remotes and bounded delayed journey. Restart Rojo after project-mapping changes so the new server runner is present. Clear the attribute afterward. The retained oracle, world, legacy and artwork suites remain separate existing tests. Operations GUI requires normal First Playable startup, not the preview-only legacy runner. Do not enable any real execution capability to run these tests.

Next recommended step is owner hands-on review of dispatch clarity, forecast usefulness and control-room navigation, followed by physical touch/gamepad acceptance and hosted load measurements. Permanent fleet purchases and real persistence require a separate reviewed schema/migration and protected preimage. This temporary FakeDataStoreAdapter protocol is not approved for production: an ambiguous initial acquisition fails closed and may require restarting the disposable training server. Do not infer cross-server lease guarantees from it.

Physical touch/gamepad, hosted eight-player networking and low-end hardware remain unverified. Eight-country figures are server-side fake actors, not eight simultaneous physical devices. Terrain and station icons remain Native placeholders. The final forecast caption identifies its issue minute; offsets refer to that issue time, avoiding an implication that the cached +0 sample is the latest measurement. Screenshots precede this caption clarification. The model is a bounded lossless transport abstraction; forecasts do not solve future congestion, and headroom is not a grid-frequency or N−1 guarantee.

No real DataStore access, Rowanbridge mutation, schema4 migration, fleet purchase, Production/settings/permissions change, uploads, commit, push, publish or deploy.
