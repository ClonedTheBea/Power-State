# P3c.3 — real construction proof preparation

18 November 2026. Preparation and fake-storage validation only. P3c.2 is owner-accepted. **No real DataStore read/write, real quote, purchase, lease or simulation advancement occurred in this task.** Production and existing private recovery packages remain untouched. The new real adapter's execution gate is false; ordinary real gameplay is not enabled.

## Guarded implementation

New modules:

- `src/server/Domain/ConstructionProofPlan.luau`: finite deterministic replay from the recorded schema3 country; bounds permitted country states, revisions, operations and request counts. Credits come from the existing solver, demand model and accounting kernel, never from forecast assignments.
- `src/server/Services/ConstructionProofRunner.luau`: dependency-injected Fund/Build phases using ProfileService, schema3 leases and ConstructionQuotes. Explicit steps, confirmed checkpoints, critical Build suspension, permanent receipt checks and confirmed release. No Heartbeat connection or preview service.
- `src/server/Adapters/Schema3ConstructionAdapter.luau`: closed real capability; exact stopped Test Studio, personal creator, authenticated account, store/key, uncached full-preimage comparison, user association and metadata preservation. No caller can open the local approval flag.
- `src/server/Services/ConstructionProofExecution.luau`: manual future entry, unreachable through normal startup or remotes. Keeping orchestration outside the adapter avoids a dependency cycle through ProfileService.
- `tests/unit/P3c3.spec.luau` and `scripts/ValidateP3c3.py`: fake historical-profile replay and static isolation checks.

Changed `ProfileService.luau` admits schema3 Build only for fake storage or the adapter's private registered capability with the exact schema/lease modules. No publicly forgeable `mode="Real"` exception. Existing queue, fencing, retry, lease, accounting and purchase logic remain in place. Existing static checks in Validate.ps1, ValidateP2a/P2b/P3a/P3c.py now recognize this specific disabled adapter; the old fake-only assertion is replaced by capability/closed-gate coverage. No client GUI, terrain, solver, tariff or schema contract changes.

## Historical input and exact forecast

Used the already-held P3c.2 final capture, not a new service read. Historical canonical SHA-256:

`d846d13a398113d1442ff1e0a3feeccbf2397fdf286cad88583f635524c75a65`

Rowanbridge / country `55e35a88-e3b9-4f72-9e69-d9024e7730a4`, schema/ledger3, profile26/country132/epoch8, released, generator On, step/cursor118, Bank100766 minor, no construction. The funding adapter pins this full canonical hash. A future fresh preflight must match; this report is not a claim about the current remote head.

Actual deterministic fake replay (120/80/10 economy):

| Point | Step | Bank Credits |
|---|---:|---:|
| Historical input | 118 | 1,007.66 |
| After123 intervals | 241 | 1,247.96 |
| First affordable, after124 intervals | 242 | **1,250.03** |
| After one durable purchase, no further step | 242 | **250.03** |

Funding adds789.13 Credits sales,526.09 variable expense and20.67 fixed expense: net242.37. Cumulative sales/variable/fixed are81409/54273/2133 minor units. Exact sales/variable/fixed remainders are36000/4000/20000. Financial cursor242; one opening grant remains100000 minor. Purchase adds100000 constructionSpentMinor, one terminal, one feeder and permanent receipt, with no change to these earnings/carries or completed energy history.

Normal fake result: StageA profile33/country256/epoch9, StageB profile37/country257/epoch10, both released. These revisions are conditional predictions; extra confirmed renewals can advance profile revisions. No expected Bank or revision is written over computed results.

## Fake validation and durability evidence

The new end-to-end suite passed62 assertions twice using fresh cloned modules (09:58 and10:02 UTC). Historical capture remained unchanged. Coverage includes124 actual funded intervals, checkpoints at30/60/90/120/124, first affordability crossing, exact carries, released reacquisition, server quote and durable Build, one debit/terminal/feeder, zero Build-phase steps, permanent receipt after a later checkpoint/release, AlreadyBuilt protection, pure reconnect restoration and a separately fake-only post-build two-sink step.

A60-second injected scheduling delay caused an extra lease renewal without catch-up simulation or altered country results. Before-write failure, committed response loss and repeated callbacks in both phases produced identical final country state. Boundary probes124999/125000/125001 minor preserve the25000 buffer. Wrong keys, invented Credits, repeated Build planning and forged real capability are rejected. The closed adapter rejects before service access.

Retained P3c94 and safety31 assertions cover quote expiry, unresolved/delayed saves, critical suspension, stale ownership/revision, shutdown, concurrent operations, permanent receipts and atomicity. Existing P3a178, P3b93, P3b.3 44, P3b.4 33, P3b.5 50 and P2b.1 scheduler49 assertions passed. Full-day construction accounting passed1440 billed intervals with12 exact restores,353303 minor net; full-ring profile92283 bytes. New final proof profile16905 bytes, below196608 soft limit. The replay allowlist has at most129 country strings; this bounds storage but is not a measured production memory result.

The retained10,000-seed route/pad corpus passed all four rotations and fallback geometry, alongside2,916,780 world assertions. Unique10000/10000, fallback0, generation CPU p95 15.972ms, maximum generated encoding43705 bytes. Original single-sink regressions passed432 assertions (1000 solves14.15ms). Eight synthetic generation jobs completed840.098ms over50 Heartbeats. These are desktop Studio/fake measurements, not hosted-service or low-end-device guarantees.

Final local checks: 891 static assertions across ValidateP3a/P3b/P3b3/P3b4/P3b5/P2a/P2b/P3c/P3c2/P3c3, both Rojo builds, strict-source/mapping boundaries and git whitespace passed. Script Analysis showed 0 errors / 0 warnings with current-script filtering disabled. An initial new module-cycle diagnostic was corrected by separating ConstructionProofExecution from the adapter; no warning suppression. Existing Git LF/CRLF notices in unrelated artwork files are informational.

Fresh Test Play: P2a GUI57, P2b GUI88, actual remote transport32+32, construction GUI50 including unsubscribe/remount, and retained R1/R2/R3/R31/R33 client suite1480 assertions passed. Construction map362 descendants; generated map345; Native574 and synthetic hybrid580, all below600. The eight-fake-country purchase test measured479.553ms aggregate CPU,18473-byte maximum profile,533.0KiB observed heap delta and peak4 in-flight calls. Heap delta is a transient sample, not a leak guarantee. No new construction-adapter real latency measurement was made.

**Failed retained gate:** at10:09:35 UTC R35.spec failed `Existing focus object retained`, following `Setting GuiService.SelectedObject to invalid GuiObject`. The real atlas had reported ready; the failure occurred in the existing responsive focus loop. Root cause is not established. No client/artwork source or assertion was changed to hide it. R37/R34 full suites and the subsequent endurance suites were not reached. Earlier pass counts do not imply a fully passing client run. Studio was stopped; this failure remains a blocker to declaring the complete regression gate green and should be investigated before any real-execution approval.

[Sanitized run evidence and prepared source hashes](P3C3-EVIDENCE.json) records the actual results without full private profile/session fields.

## Proposed future procedure — separate execution approval required

Only Test universe10776833313, personal missawfulname149564436, standard storePowerStateProfilesP3aTest, default/global scope, keyu:149564436. No alternative keys/stores/players, migrations, grants, forced unlocks or resets.

Use **stopped Studio**, authenticated as that owner, in each phase. The dedicated entry never starts P2a/P2b previews or Heartbeats. This is same-account fenced release/reacquisition, not a claim of a live Player/client reconnection test. One phase is allowed per adapter module lifetime; use a fresh stopped context for StageB. Recheck identity and retain the reviewed protected record before any later approved access. Before enabling the gate, review source hashes, destination and requested phase limits with the owner.

### Stage A: bounded genuine funding

1. After explicit approval, obtain exactly one fresh uncached preflight; require full canonical equality with the reviewed P3c.2 final capture, schema3, correct identity, released lease and exact user association. Capture returned platform version/metadata and a protected preimage outside the repository before continuing. Any difference stops for review.
2. Acquire with existing fenced lease rules. No initialization/migration or new grant. Advance at most**128** explicit intervals and stop at the first Bank≥125000; current forecast124. One interval per explicit one-second wait, with no elapsed-time catch-up. Delays never authorize extra steps.
3. Checkpoint every30 intervals and on affordability; tick the existing coordinator for renewal. Lease180 seconds and safety margin30 seconds are unchanged. Existing55–65-second save scheduling remains active. Presence/deadline checks precede progress.
4. Require uncached confirmation of the complete affordable profile before release, then confirm the exact released profile through another uncached read. Preserve the full resulting canonical record/platform evidence securely for StageB review. Do not issue a quote in StageA.

Proposed StageA deadline240 seconds; per-operation waiting deadline30 seconds. Normal updates: Acquire, five Checkpoints, Release =7; normal reads: preflight, funded confirmation, released confirmation =3. Total10 calls. Logical profile revision allowance12 permits at most5 additional confirmed renewal/checkpoint transitions beyond this normal path.

### Stage B: durable purchase only

1. Separately review StageA's exact released canonical record. Fresh authenticated stopped context; uncached preflight must match that record. A changed remote head requires a new review, not guessed expected fields.
2. Acquire the same country under a fresh fence. Issue one server-owned30-second quote and confirm with current session/Bank revalidation. Price100000 minor, minimum125000, retained buffer25000.
3. Build atomically commits latest valid finance, debit, one terminal/feeder, topology/serial, construction spending, receipt and fenced revisions. Suspend during the critical transaction. Never report Built until durable confirmation and reconciliation permit resume.
4. Perform one identical-country checkpoint without simulation to prove the permanent receipt survives lastCommit replacement. Repeated Quote returnsAlreadyBuilt. Confirm full profile, release, confirm released full profile. Preserve protected final evidence.

Proposed StageB deadline90 seconds, individual operation wait30 seconds; **zero simulation intervals**. Normal updates: Acquire, Build, identical-country Checkpoint, Release =4. Reads: preflight and two confirmations =3. Total7 calls. Logical revision allowance6 permits2 extra confirmed renewals. No controlled post-construction real delivery interval is included: that needs separately specified owner approval.

### Retry and failure ceilings

Each phase permits at most40 UpdateAsync attempts and24 guarded reads,64 combined guarded calls plus one preflight read =**65 total application calls**. Normal combined procedure uses17 calls. Existing ProfileService bounded operation retry policy (five attempts, including reconciliation work), queue limits and fencing remain authoritative; the phase deadline or lower operation ceiling may stop earlier. Roblox internal UpdateAsync callback retries are platform-controlled; callbacks have no external side effects and are idempotent. Application call counts do not claim control over internal platform retries.

Lost acknowledgements use the same pending operation identifier and approved uncached reconciliation; never generate a replacement purchase ID to bypass ambiguity. Conflicting lease, expiry, failed validation, terminal persistence status, request/deadline exhaustion or ambiguous final outcome stops the phase. **Do not continue to StageB.** The runner does not blindly release an old profile on an exception. An outstanding Roblox request cannot be cancelled by the local deadline and could complete later; retain evidence and stop for recovery review. Any additional reads/writes outside the approved envelope require new approval. No real service latency or outage result is claimed from fake tests.

## Recovery limits and remaining acceptance

Existing P3c.1/P3c.2 protected packages are unchanged. Record the StageA and StageB preimages/results before future execution, including platform version, metadata and canonical SHA-256; session tokens must not enter ordinary logs. Do not restore historical schema2 or pre-purchase schema3 over a committed purchase: that could erase receipts and refund capital. Recovery requires reviewed forward reconciliation of the actual fenced head, not rollback or forced lease removal.

Physical touch/gamepad and actual hosted competing-session acceptance remain outstanding. Completed-state button wording and narrow Bank totals grouping remain recorded polish items, not implemented. The terrain, Native default and renderer budget are unchanged. No additional construction, R4/R5, monetisation or other phase was introduced.

**Approval gate:** approve the bounded StageA/StageB procedure and limits separately before enabling any real capability. This task stops at preparation; fake success is not real construction acceptance.

## P3c.3a — keyboard focus investigation (18 November 2026)

Owner authorizes only the focus correction and retained validation. No real DataStore access, quotes, funding or construction execution. Both real execution gates remain closed.

### Confirmed cause and reproduction

The R35 test assigned engine focus to a marker outside the actual ScreenGui. Setting a virtual SafeRoot to 768×960 does not enlarge Studio's rendered viewport. With the expanded command bar and analysis dock, the ScreenGui was 1612×432; the station marker occupied (221,506)–(265,550). The marker and all ancestors were Visible, it remained Active/Selectable and mounted under the same PlayerGui, and object identity was unchanged. The engine rejected this offscreen target and chose the navigation Rail. There was no destroyed reference, remount or replacement at the failure.

Control runs before correction:

- Isolated R35, taller host viewport: all 217 assertions passed at10:16:18 UTC.
- Complete preceding client sequence, original short viewport: reproduced warning and failed `Existing focus object retained` at10:20:37 UTC.
- Fresh isolated R35, same short viewport: reproduced the identical failure at10:21:52 UTC. Diagnostics explicitly recorded guiSize1612×432 and markerY506 before assignment, immediately afterward and after layout settled.

Thus preceding test contamination is not required. There is also a directly related runtime eligibility omission: KeyboardController.valid previously returned true for this offscreen non-scrolling marker. Its visibility walk stopped below the ScreenGui and did not check its rendered bounds.

### Scoped correction and coverage

- `src/client/Controllers/KeyboardController.luau`: reject disabled/unmounted ScreenGuis and fully offscreen non-scrolling targets; validate the target before focus assignment. Existing scrolling-list candidates remain reachable through the established scroll-into-view path. No input bindings, targets, gameplay or camera rules changed.
- `tests/integration/FocusTarget.luau`: bounded state-based test preparation. Preserve the virtual layout dimensions, close the occluding inspector and use existing camera pan/zoom controls to bring the same 44px marker into the intersection of the map and actual ScreenGui. Verify rendered position/eligibility; fail within two seconds if impossible. No test is skipped and no existing threshold is increased. Camera clamping is respected; zoom is used only when a fitted country cannot pan.
- `tests/integration/R35.spec.luau`: retain the original assertion for every size; add eligibility, identity, mode-switch focus, culling exclusion and reveal/reuse checks. Bounded diagnostic records contain GUI names, parentage, dimensions, visibility, eligibility and focus before/during/after assignment, not persistence data.
- `tests/integration/P3c.spec.luau`: add focus assertions for construction review, disabled completed-project traversal, Bank close/reopen and invoker restoration.
- `tests/integration/Run.client.luau`: three R35 repeats following the retained client sequence; explicit Test-only R35FocusOnly attribute permits three isolated repetitions. Normal production excludes this runner. The attribute is cleared for the complete run.

During new culling-test development, the engine's automatic valid fallback could be activated accidentally after the marker was hidden, opening another panel. The probe now activates only if the invalid marker is still selected, and retains the assertion that it cannot remain the active target. Initial reveal attempts also exposed the approved camera clamp when the country fits the virtual viewport; the helper uses ordinary zoom/pan rather than altering clamp rules. These intermediate test failures are not reported as passing runs.

Three corrected isolated repetitions passed **241 assertions each** at10:27:00/03/06 UTC in the short viewport. Full-sequence and endurance outcomes are recorded below when complete. Physical touch/gamepad acceptance remains separate.

The first corrected full sequence passed construction GUI67, retained interaction135, primary presentation1480 and three further R35 runs of241 assertions each (10:31:25/27/30 UTC). R37 then exposed the same setup defect in its minimum-zoom Southbank label probe, again with the invalid SelectedObject engine warning. `tests/integration/R37.spec.luau` now translates that direct-render fixture into the actual screen while retaining zoom0.55 and its contextual-label assertion, and explicitly checks engine focus before testing the name. No sprite position/world anchor or runtime camera logic is changed. This later failure is included in the investigation, not omitted from the run history.

Final fresh full sequence started at 10:33 UTC. Construction GUI passed 67 assertions; primary R1/R2/R3/R31/R33 presentation passed 1,480; R35 passed three more repetitions of 241 (10:36:52/54/57). Across the corrected runs, R35 has passed three isolated and six post-sequence repetitions. R37 diagnostics showed Southbank at (425,436) outside a 1612×432 ScreenGui, then the same marker at (425,216) with engine focus retained after the test-only translation. Its full suite passed **1,413 assertions**, including the **600.0-second / 589-cycle / 595-descendant** endurance run. Other final endurance outcomes follow below.

R34 subsequently passed **259 real-texture assertions** and its **600.9-second / 591-cycle / 935-shell-descendant** run. Actual approved atlas readiness was 45.816ms with cache state unknown; whole-client GraphicsTexture was 27.531MiB before/after, not atlas-only memory. This verifies the previously blocked retained suite, not a new artwork or device-performance approval.

The retained Native shell endurance run passed **600.1 seconds / 590 cycles / 929 stable GUI descendants**, preserving selection and zoom bounds across six virtual safe-root sizes.

The final generated-country endurance run passed **600.1 seconds / 590 cycles / 345 map descendants** at11:18:13 UTC. Three additional R35 repetitions after the entire client/endurance sequence passed241 assertions each at11:18:53/56/58. Total corrected R35 evidence: **12 successful runs** (three isolated, six following preceding suites, three after the entire sequence). The original focus assertion remains in every run.

The additional P3b fake-storage host passed88 generated GUI assertions,32 actual remote-transport/security assertions and83 Bank assertions. Bank progression waits were0.9811/0.8013/0.7831/0.7983 seconds for desktop/mobile/short-landscape/tablet; rendered finances matched authoritative revisions. No real storage adapter was started. Construction GUI67 assertions include modal focus across responsive sizes, completed-state traversal, Bank invoker restoration and lifecycle cleanup/remount. Physical touch/gamepad hardware remains untested; these are engine-level interaction assertions.

### Final gate and evidence

Fresh cloned server modules passed the62-assertion fake funding/construction proof again at11:23:42 UTC, with the unchanged124-interval/125003-minor affordability and25003-minor post-purchase result. Retained P3a178/P3b93/P3b.3 44/P3b.4 33/P3b.5 50/P2b.1 49 assertions passed. Full-day billing passed1440 intervals and12 exact restores; full-ring profile92283 bytes. The10,000-seed route/pad corpus, all four rotations and safe fallback passed at11:26:20 alongside2,916,780 retained world assertions. These were local fake-storage tests using the previously captured historical input, with no fresh real-profile access. The earlier live Play run also retained432 original solver,94 construction and31 safety assertions.

Both Rojo builds and891 static assertions passed after the final source correction. Final full-project Script Analysis, with Current Script Only disabled, showed **0 errors / 0 warnings** after the fake run. Source hashes for the seven prepared P3c.3 server/runner/static files remain unchanged. Real construction and economy execution gates remain false. No approved gameplay arithmetic, schema, lease, coordinates or persistence contract changed.

**Available regression gate: PASS.** The initial failure and intermediate test-development failures above are retained as history; they are superseded by the final successful sequence. [Sanitized focus and regression evidence](P3C3A-EVIDENCE.json) records actual diagnostic lines and changed-source hashes. Exact task file inventory: KeyboardController, FocusTarget (new), R35.spec, R37.spec, P3c.spec, Run.client, this report, PLANS, DECISIONS and the new evidence JSON. Other existing workspace changes belong to earlier phases and were preserved.

Remaining limitations: physical touch/gamepad and low-end mobile acceptance are outstanding; virtual safe-root testing is not physical-device testing. The completed-project button wording and narrow Bank totals remain deferred polish. No real funding, quote, construction, DataStore access or Production operation occurred. Studio is stopped. The prepared Stage A/Stage B procedure is ready for separate owner review and explicit execution approval; this correction grants no real-service authority.
