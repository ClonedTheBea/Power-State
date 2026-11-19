# Operations v1.3 validation

19 November 2026. Implementation and available isolated fake Test validation completed; stopped for owner review. Owner authorizes UI/stability implementation and wind design, not wind runtime, schema4 or real services.

## Stage A gate — passed before visual restructuring

Snapshot handling called full AppController.refresh/applyLayout on every public snapshot. Fleet descriptions were assigned and appended in three separate property writes, each firing GetTextSize and resizing the card. Totals also had intermediate writes. Reinforcement's local expiry heartbeat additionally ran full refresh four times/second. No remount occurred in the measured baseline; focus/scroll offsets did not move, so do not invent a destroyed-object or dropped-snapshot cause. The observed defect is transient text/size churn and unnecessary whole-shell reconciliation.

Three12-second actual-engine panels, baseline → incremental candidate:

|Panel|Snapshots|Layout passes|Fleet+feedback measurements|Canvas changes|Total update CPU ms|
|---|---|---|---|---|---|
|Fleet|33→33|33→0|297→33|330→22|119.506→34.011|
|Bank|34→33|34→0|306→33|341→21|124.557→32.105|
|Reinforcement|36→35|82→0|750→47|820→22|293.444→42.444|

All measured panels:0 descendants added/removed,0 focus changes,0 scroll drift; authoritative simulation advanced11–12 steps. Baseline peak calculation incorrectly subtracted cumulative maxima; only baseline total CPU is reported. Candidate peak was reset per panel:3.145/2.391/3.146ms. Measurements are os.clock active-region proxies on desktop Studio, not hardware CPU guarantees. Direct CanvasPosition setup tests retention, not swipe input.

Fix: AppController exposes data-only `present`; Operations snapshots and stale/quote clock use it rather than layout. Build complete fleet/totals strings before a single changed-value assignment. Existing components, snapshots, clocks and remote authority remain. No snapshot throttling or stale data was introduced. Stage A candidate completed09:54:11 UTC before Stage B edits. Remaining canvas changes were stable final content changes, rather than repeated partial descriptions; fixed presentation slots are the next stage.


## Control-room implementation

The overview shows demand/delivery, generation/unserved demand, ready capacity and dispatchable headroom. The four desktop KPIs now prioritize Bank, delivery/demand, unserved demand and headroom. Reliability remains available in Bank history. Headroom is not presented as a transmission-delivery guarantee.

Fleet cards retain On/Off, 100 kW cap controls, Locate and 44px targets. Four concise lines show technology, current state/output, ready/capped output and costs. Fixed card geometry is measured only when width or text scale changes, not when dispatch values change. Generator details, conditional forecast and grouped Bank history reuse the existing focused, scrollable feedback component. They receive live authoritative updates without replacing their controls. Alerts opens the bounded server alerts/outcome and suspension reason; the overview selects one actionable condition. No recurring snapshot toast is added.

Desktop retains the Native map alongside the control room; narrower screens use the existing full-width page and bottom navigation. Short landscape intentionally scrolls the fleet beneath the overview. The current terrain and marker geometry are unchanged. This is a hierarchy/readability iteration, not final visual or physical-device acceptance.

### Final five-panel live stability run

12 seconds per panel on desktop Studio, 36 received snapshots and 12 completed simulation intervals each. Every panel: zero shell layout passes, zero descendants created/destroyed, zero scroll drift and no focus loss. Fleet canvas size did not change. Times cover the instrumented presenter region, not all engine/GPU work.

| Panel | Text measurements | Total update CPU ms | Peak update ms |
| --- | ---: | ---: | ---: |
| Fleet | 0 | 13.772 | 0.772 |
| Generator details | 24 | 20.967 | 1.150 |
| Forecast | 12 | 17.231 | 1.006 |
| Bank | 12 | 17.923 | 1.164 |
| Reinforcement review | 12 | 20.210 | 1.331 |

Detailed text still measures when its complete visible content changes; it does not reset CanvasPosition. The reinforcement expiry clock continues to run and refresh securely. The compact-height/Alerts-access changes and fleet-first order also passed the 130-assertion GUI rerun. The table above is the first full five-panel run; the final-source repeat is recorded below. No claim of pixel-identical layout across deliberate resize is made.

Actual command-to-authoritative-predicate observations in the full run were 62.202, 48.831, 50.964 and 48.936 ms. Received snapshots continue at roughly three per completed interval. Output remains the last completed electrical interval, while confirmed controls affect subsequent dispatch. No client-generated production, financial or ownership values were introduced.

## Eight-country startup investigation

The initial combined v1.3 run reproduced a failure: expected step 6, actual 5, status Suspended, reason `deadline: no interval settled; retry safely`. The 500-Credit capital debit and investment serial remained correct. This is a missed solver-service deadline, not evidence of a duplicate investment or lost partial settlement. The earlier reinforcement sprint's failure lacked enough telemetry to prove it had exactly the same cause.

That combined run overlapped server resource acceptance with aggressive client four-size GUI resizing in one Studio process. The revised harness waits for an explicit server-ready event before starting that client suite. This isolates the resource measurement from unrelated resize work; it does not change gameplay scheduling, a watchdog, a work bound, or an assertion. Added failure diagnostics report elapsed batch time, largest Heartbeat gap and batch counters. The reproducing failure occurred before those extra counters were added, so its exact pause source (rendering, GC, Studio or scheduling) remains unproven. Do not describe this as a demonstrated runtime solver fix.

Four fresh eight-country stores subsequently passed 2,065 assertions each, including 120 intervals, eight paid investments, release/reacquisition and exact canonical financial/receipt equality. Each round also passed 61 transaction/fault assertions. Three additional staggered eight-country batches exercised leave during pending work, investment during pending work, unrelated-country completion, stale-owner rejection and new-epoch exact reentry. Together with explicit deadline suspension and one requested safe retry: 131 assertions. No catch-up or implicit retry was introduced.

| Round | Preparation peak ms | Fake checkpoint peak ms | Solver peak ms | Install peak ms | Transaction peak ms | Heap delta KiB |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 17.579 | 4.147 | 1.774 | 2.011 | 1.051 | 2219 |
| 2 | 3.558 | 2.803 | 1.863 | 1.698 | 1.185 | 141 |
| 3 | 4.996 | 2.536 | 1.665 | 2.063 | 1.071 | 1610 |
| 4 | 2.715 | 2.726 | 1.930 | 2.116 | 1.058 | 554 |

These are eight fake actors, not eight newly launched network clients. Actual eight-client isolation remains prior v1.1 evidence. Each resource round retained eight records, 992 fake calls/writes, maximum encoded record 6,232 bytes and public snapshot 2,237 bytes. Heap deltas include GC and cannot establish a leak or memory ceiling. Cold preparation remains a visible performance limitation; no claim that the 4 ms solver slice bounds preparation or checkpoint work.

A separate fresh Play retained-regression run passed another 2,065 resource checks (preparation 4.031, checkpoint 3.206, solver 1.994, install 2.009, transaction 1.098 ms; heap +937 KiB). Native/30 Hz scheduler runs retained the approved 80 ms aggregate/750 ms deadline and eight-job bound. One cooperative slice measured 4.014 ms (0.014 ms overshoot), reported rather than hidden; the already-approved contract is a soft slice target with explicit overshoot reporting. This run's 15 Hz adverse cases happened to finish; that does not revoke the 30 Hz support requirement or supersede earlier safe deadline failures.

## Regression and interaction evidence

- Actual normal Training entry/control/menu suite: 129 assertions, then 130 after adding Alerts-access coverage; map 394/600 descendants.
- Operations interaction: 101 engine focus/paging assertions. Remote-security: 38, bounded flood response count 6.
- Full normal fake-host reinforcement journey: 27 assertions, genuine purchase and financial/electrical effect, permanent receipt and reentry. The journey waits for the next natural peak phase (minute modulo 240 in 91–115) with a 250-second bound, rather than assuming earlier suites finish before minute 91. Original effect/price/debit/congestion assertions remain. No scenario timing or simulation threshold changed.
- Retained reinforcement model 497 and transaction 61; Operations encoding 5,020, atomic 326, scenario 3,144, security 231, fleet lifecycle 2,062.
- Original solver 8,854 assertions including 2,187 exhaustive oracle cases; yield equivalence 9,100; cancellation/lifecycle 1,486 covering all 1,395 observed cancellation opportunities; scheduling 63 eight-country intervals.
- Both Rojo builds and source mapping/security checks pass. Local P3a 167, P3b 147, P3c 178, P3c.3 91, P3c.6 76 and First Playable 33 static assertions pass; these are static evidence, not service execution. [Machine-readable static results](operations-v13-static-results.json).
- Full-project Script Analysis showed 0 errors / 0 warnings with Current Script Only unchecked in the capture run. A final edit-mode check is recorded below.

Final retained world/legacy, repeated startup/economy and edit-mode results follow in the closeout section.

### Screenshots and input limits

Actual Studio rendered captures, not mockups: [desktop](operations-v13-screenshots/desktop.png), [tablet](operations-v13-screenshots/tablet.png), [portrait](operations-v13-screenshots/portrait.png), [short landscape](operations-v13-screenshots/landscape.png). Tablet/portrait/landscape use injected safe-root dimensions 1024×580, 390×580 and 844×390 in the desktop Studio viewport. Desktop uses a 1280×580 safe root. Frames are from different active simulation minutes and are not a matched electrical-state comparison. Studio chrome is retained for provenance.

Keyboard/gamepad action and focus routes are exercised by engine tests; programmatic CanvasPosition setup proves retention only. This sprint does not establish physical swipe or hardware gamepad input. Owner v1.2 More/fleet emulator acceptance is historical, not automatic v1.3 approval. Owner should repeat scrolling, cap controls, detail close/back, Bank overflow and reinforcement review on actual portrait/landscape touch and gamepad devices. Short landscape requires scrolling to reach fleet controls; all controls remain in the bounded panel.

## File inventory for this sprint

Runtime: `src/client/Controllers/AppController.luau` (data-only presentation entry), `src/client/Views/FeedbackView.luau` (changed-text guard/measurement instrumentation), `src/client/Simulation/OperationsClient.luau` (incremental wiring/detail navigation), `OperationsView.luau` (stable concise cards), new `OperationsPresentation.luau` (snapshot presentation), new `OperationsDetails.luau` (Bank/generator/forecast/alerts). No authoritative server gameplay module changed for v1.3.

Tests: new `tests/integration/OperationsV13.client.luau` and `tests/unit/OperationsV13.server.luau`; updated `Operations.spec.luau`, `ReinforcementJourney.spec.luau` and `ReinforcementResources.spec.luau`. Retained uncommitted reinforcement/v1.2 files were preserved.

Design/evidence: this report, screenshot directory, static/engine result JSON, `NATIONAL-FLEET-EXPANSION-DECISION-PROPOSAL.md`, `NATIONAL-FLEET-EXPANSION-CALCULATIONS.json`, `scripts/AnalyzeFleetExpansion.py`, roadmap/decision register and architecture/testing notes.

## Reproduction and next approval boundary

In isolated Test universe 10776833313, connect the existing test Rojo project, with all real-service flags disabled. Set only one opt-in runner in Edit mode: `OperationsV13="All"` for serial server-startup → normal client suites → journey; `"Server"` for repeated startup/fault/economy validation; `"Capture"` for normal GUI suite and four screenshot windows. `ReinforcementTests="Regression"` and `OperationsV11Legacy=true` are separate fresh-Play runs with OperationsV13 unset. Clear runner flags afterwards. No default startup code enables these suites.

The wind proposal recommends one player-funded 2 MW farm for 4,000 Credits after the district, with a surveyed connection, exact per-unit accounting and separately approved schema4. Its 32 synthetic-seed calculations are design arithmetic, not real-profile or future-solver validation. W1–W7 require owner approval before implementation. No permanent wind assets, migration, new schema, real services, Rowanbridge access, Production change, publication, upload, commit or push occurred.


## Final closeout — 10:29 UTC

Final fleet-first source repeated all five twelve-second stability samples: each received 33 snapshots, advanced 11 authoritative steps, and retained zero layout passes, remounts, canvas changes, focus loss and scroll drift. Fleet/generator/forecast/Bank/reinforcement total presenter times were 10.892/19.320/15.762/18.039/18.158 ms; peaks 0.772/1.583/1.542/1.782/1.039 ms. Measurement counts 0/22/11/11/11. The last 130-assertion normal GUI run and four captures use this same final fleet-first order. Reinforcement remains available through Build/inspector and below the fleet, not removed.

A second fresh Studio session passed another four resource rounds (2,065 each), four transaction rounds (61 each), and 131 staggered/recovery checks. Their maximum preparation/checkpoint/solver/install/transaction regions measured 4.859/4.599/3.763/2.173/1.510 ms. The existing actual-solver reinforcement economy suite passed **20,179 assertions**, with preparation/solve/install peaks 0.965/0.947/0.856 ms. These are fake-storage operations; no hosted durability claim.

Retained fresh-Play results:

| Coverage | Result |
| --- | --- |
| P2a / P3c / construction safety / First Playable controls | 432 / 94 / 31 / 42 assertions |
| P2b accounting | 2,941 assertions |
| P3a / P3b / P3b.3 / P3b.4 / P3b.5 fake persistence | 178 / 93 / 44 / 33 / 50 assertions |
| P2b.1 scheduler | 49 assertions; eight synthetic jobs 929.822 ms across 54 Heartbeats |
| P3c accounting | 1,440 billed intervals, 12 exact restores, full-ring profile 92,283 bytes |
| P2b world / P3c routes | 2,916,780 assertions; 10,000 accepted seeds, four rotations and safe fallback |
| First Playable actual remotes / normal journey | 12 / 34 assertions |
| Bank GUI | 83 assertions; synthetic status faults, fake server |
| Shared GUI / currency / interaction | 348 / 16 / 135 assertions |
| R3 / R3.1 / synthetic R3.3 / R3.5 focus/presentation | 190 / 52 / 739 / 241 assertions |

Final native scheduling maximum: 4.014 ms cooperative slice, 39.981 ms aggregate, 165.069 ms elapsed. Throttled 30 Hz: 3.883 ms slice, 39.299 ms aggregate, 444.017 ms elapsed. Queue ≤8 and retained jobs 0. The reported 0.014 ms native overshoot is not erased or represented as a hard 4 ms bound.

Final two Rojo builds/source-security/whitespace checks passed after the layout-order change. Final full-project **edit-mode Script Analysis: 0 errors, 0 warnings**, Current Script Only unchecked; [inspection screenshot](operations-v13-screenshots/final-script-analysis.png). Opt-in runner/readiness flags were cleared and Play stopped; normal fake First Playable startup is restored. [Selected actual engine test output](operations-v13-engine-results.json) preserves baseline, failed startup and successful repeats without exporting private persistence data.

Remaining acceptance limits: owner review of the new hierarchy; physical touch/gamepad and low-end hardware; hosted load/service guarantees; cold preparation spikes and the unidentified source of the reproduced Studio scheduling pause. There is no remaining failed accounting/security/retained regression assertion in the final runs, but these limits remain open. No permanent wind purchase or schema4 work should begin until W1–W7 are reviewed.
