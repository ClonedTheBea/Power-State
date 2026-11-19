# Operations v1.2 interaction validation

19 November 2026. **Available validation complete; device acceptance limits remain. Fake Test only.** Operations v1.1 is owner-accepted as an isolated technical milestone. Stage A corrects shared interaction defects; Stage B is [a reinforcement decision proposal](GRID-REINFORCEMENT-DECISION-PROPOSAL.md), not purchase implementation. No real DataStore records, Rowanbridge, Production, settings or artwork are accessed or changed.

## Investigation and confirmed defects

### Touch scrolling versus tool input

The earlier v1.1 automation produced only two touch-move events near its drag endpoint and moved the drawer about one pixel. Programmatic CanvasPosition positioning in that report was never swipe acceptance. Here the owner manually tested More and fleet and reported successful scrolling in **both portrait and landscape**. That is owner-operated Studio-emulator evidence, not physical-device evidence; it supports an automation limitation for those previous swipe attempts. No native gesture handling, Active flags, touch thresholds or scrolling physics were changed.

The owner reported Bank content fit both orientations and therefore needed no scrolling. This establishes the owner's observed layout, not an overflow-swipe test. The owner initially could not find Bank; Operations More now labels its overview route **Bank / overview**, while the Bank KPI remains clickable.

Desktop injected mouse-wheel input visibly scrolled the fleet before changes. After the correction below, it reached the complete Bank text and final explanatory sentence: [native wheel evidence](operations-v12-screenshots/bank-native-wheel.png). A keyboard PageDown injection instead moved Studio Explorer focus; that attempted UI-key test is not counted as routed game input. Direct engine paging tests are separately identified below.

### Real shared-dialog overflow defect

A new four-root/150%-text test failed `Fixture genuinely overflows` at07:50:43 UTC. The Operations overview visibly clipped later text. A read-only live probe at07:52:01 measured canvas342×338, window342×338, body334×336 and reported TextBounds329×336 with AutomaticSize.Y. Thus the canvas had no scroll range even though the complete string extended beyond the visible text. This is a real content-sizing defect, distinct from the automated swipe issue.

First Playable's ConstructionClient already measured complete wrapped strings with TextService because clipped TextBounds was unreliable. Moved that exact sizing behavior into shared FeedbackView and removed the duplicate construction-only listeners. All feedback panels now use explicit measured body/canvas height, respond to width/text/text-size changes and disconnect listeners on destruction. No financial or construction transition changed.

The same previously failing assertion then passed, without increasing a deadline or weakening expected overflow. Native wheel reached the formerly hidden final Bank paragraph.

### Text-only keyboard/gamepad access

KeyboardController owns navigation and disables native auto-selection. Its existing Tab/D-pad traversal selects buttons; the Bank message has only a Close button and therefore had no explicit route to page through long text. Added a small ScrollNavigation module and PgUp/PgDn / LB/RB paging outside map-focus mode. It selects the focused scroll ancestor or visible overflowing panel within the current modal scope, clamps to content bounds and clears a scrolled-away button selection. It preserves modal Close focus for text-only Bank details. Map-focus shoulders retain their existing zoom path.

No pointer drag implementation is replaced; this is an additional accessible input route. Panels with no overflow need no movement. No GUI instances or per-frame callbacks are added by paging. The shared full-string sizing replaces the previous three construction-specific listeners with three owned dialog listeners.

### Operational feedback

Fleet rows now explain that controls affect the next dispatch and displayed last output belongs to the previous completed interval. Existing server-confirmed cap/On/Off acknowledgements, pending status, stale response handling, snapshot ordering and prices remain unchanged. Help and panel text explain paging inputs. No optimistic production or financial result is calculated on the client.

## Current validation evidence

| Check | Result |
| --- | --- |
| New interaction suite |101 engine action/layout assertions passed at07:53:58;390×640,844×390,1024×720,1366×704; Bank150% text |
| Existing Operations GUI |129 passed;44px controls, actual Bank details, caps/Off/On, focus, camera and map394/600 |
| Actual RemoteEvent security |38 passed; bounded flood produced6 snapshots |
| Complete Operations journey |11 passed at07:55:38; minute96/Bank133,691 minor restored; no offline revenue |
| Atomic physical/financial settlement |326 passed |
| Scenario/wind/exact fake accounting |3,144 passed |
| Unit security |231 passed |
| Eight-country fake lifecycle |2,062 passed;120 intervals,984 calls/writes,eight records,max profile5,712 bytes/snapshot2,139 |
| Integrated scheduling |63 workload/cadence rounds passed on both runs; native/30Hz retained. First run deliberately throttled15Hz safely suspended7 countries; second run0. Not a15Hz guarantee |
| Local checks |597 existing static assertions passed; both Rojo builds and source/remote/whitespace boundaries passed |

The new suite explicitly tests overflowing fleet/drawer/Bank, top/bottom paging clamps, modal isolation from background fleet, offscreen fleet control brought into view, cleared hidden focus after paging, drawer Bank focus/activation, Close focus, map-focus ownership and instance bounds. It calls the same paging function used by keyboard/gamepad bindings; **it does not simulate a physical swipe or prove hardware button delivery**.

Resource-repeat measured peaks: preparation5.364ms, solver2.146ms, install1.688ms, fake save2.581ms; shared heap delta+2,891KiB. These are observed timings/shared allocation effects, not new guarantees. Retain the v1.1 performance evidence; v1.2 makes no server optimization or accounting change. The first scheduling run recorded a4.110ms slice at unsupported15Hz; preserve its0.110ms cooperative overshoot rather than changing thresholds.

The first failure remains in the evidence artefact. An existing Roblox asset203785492 incorrect-type warning also appeared; no unrelated asset was added or substituted. Retained GUI/persistence regression and final Script Analysis results are recorded below.

## Final retained regression and analysis

The fresh retained run completed at08:03:38 UTC. P3b Bank GUI83, First Playable actual remotes12/journey34, shared GUI348, currency16, interactions135, R3 rendering190, R3.1 framing52, synthetic R3.3 integration739 and R3.5 presentation241 passed. The retained server runner completed, including P3a/P3b persistence and financial fixtures, P3b4 fake33, P3b5 fake50, P2b.1 scheduler49, and P3c accounting1,440 intervals/12 restores (92,283-byte full-ring profile). World generation passed2,916,780 assertions and10,000 accepted seed route/pad checks across four rotations. The short First Playable journey began after the corpus; its6.888 seconds is not a fresh funding-duration claim.

Final edit-mode full-project Script Analysis initially exposed four warnings in the retained OperationsLegacy server runner: a heterogeneous function table inferred the first suite's numeric return signature and rejected void-return suites. Replaced that loop with the same five explicit calls in the same order, retaining every assertion. After Rojo sync, analysis showed **0 errors / 0 warnings**, with Current Script Only unchecked: [analysis screenshot](operations-v12-screenshots/script-analysis.png). This runner-only correction followed the passing retained execution; that full execution was not repeated solely for the equivalent call-list spelling. Both builds/source/security/whitespace checks were rerun successfully after the correction.

A bounded [Studio evidence extract](NATIONAL-GRID-OPERATIONS-V12-RESULTS.json) retains the initial failure, sizing probe and task-labelled pass/measurement lines. No private profile fields are exported. Regression flags were cleared and Play stopped. No real services or execution gates were enabled. Actual eight-client and real-artwork endurance evidence remains the earlier milestone's evidence, not a new v1.2 run.

Direct physical swipe of an overflowing corrected Bank, keyboard key delivery into the viewport, and controller-emulator/hardware LB/RB delivery were not established in this run. The new paging route passes engine-level action/layout tests; these input-device limitations remain explicit rather than inferred from CanvasPosition. Owner More/fleet emulator acceptance in both orientations is retained separately.

## Changed files in v1.2

- `src/client/Controllers/ScrollNavigation.luau` — new bounded visible-panel paging helper.
- `src/client/Controllers/KeyboardController.luau` — page-key/shoulder bindings outside map mode.
- `src/client/Views/FeedbackView.luau` — shared complete-string canvas sizing and listener cleanup.
- `src/client/Simulation/ConstructionClient.luau` — remove duplicate sizing implementation, retain construction-specific dialog geometry.
- `src/client/Simulation/OperationsClient.luau`, `OperationsView.luau` — Bank route label and control/paging explanations.
- `tests/integration/OperationsInteraction.spec.luau`, `OperationsRun.client.luau` — new retained interaction suite in existing opt-in runner.
- `tests/unit/OperationsLegacy.server.luau` — preserve explicit suite calls without heterogeneous return-type inference warnings.
- `scripts/AnalyzeGridReinforcement.py` — local analytical proposal calculator, no services or runtime integration.
- Reinforcement proposal/calculation JSON, this report/evidence/screenshots, roadmap and decisions.

No server, solver, economy, persistent schema, native terrain or asset files changed during v1.2.

## Reproduction and remaining acceptance

Use Power States - Test10776833313 connected to Rojo34873. Normal Play opens First Playable; More/Infrastructure opens disposable Operations Training. More → Bank / overview or the Bank KPI opens details. Swiping/wheeling uses native scrolling; PgUp/PgDn or LB/RB page panels; Tab/D-pad focuses actions, Enter/A activates, Escape/B dismisses. Map-focus shoulders still zoom. Ordinary menus continue simulation.

For automated checks, use only Test `RunOperationsTests=true` with other runners off; restart Play. The existing runner now includes the101-assertion suite. Clear the flag after validation. `OperationsV11Legacy=true` separately reruns retained fake/pure/First Playable/Bank/shared GUI tests. Do not enable real execution gates.

Owner-operated More/fleet emulator swipes passed in both orientations. Physical touch/controller hardware, full gamepad-only journey, hosted load and same-account network reconnect remain separate future acceptance; no such hardware/service claim is made. Overflowing Bank swipe still needs an owner/device gesture after this fix, as opposed to a fitting page or direct CanvasPosition change.

## Approval boundary

Review G1–G6 in the reinforcement proposal before purchase implementation. Recommend a3→4MW same-line reinforcement at500 Credits with250 buffer, primarily for reliability; its actual marginal payback is slow under unchanged economics. No free upgrade or new generator is installed. Stop after interaction validation and proposal review; real persistence and subsequent generator construction need separate authority.
