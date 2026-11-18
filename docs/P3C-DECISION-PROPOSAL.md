# P3c — First player-funded construction project

18 November 2026. **Historical design proposal; D131–D135 now approved by D136 for pure/fake/Test implementation only.** [Implementation evidence](P3C-VALIDATION.md). Original proposal language below records the reviewed contract; its pending-approval wording is superseded by D136. P3b.5 is accepted evidence, not authorization for another real read, migration or purchase. Native remains default. No runtime, Studio, DataStore, settings or artwork changes accompany this proposal.

Sources: [P3b.5 outcome](P3B5-VALIDATION.md), [approved economy](P3B-DECISION-PROPOSAL.md), [persistence](P3A-DECISION-PROPOSAL.md), [starting country](STARTING-COUNTRY.md), [world](WORLD-AND-EXPANSION.md), [electricity](ELECTRICITY-SIMULATION.md), [security](DATA-AND-SECURITY.md), [gameplay](GAMEPLAY.md). Current implementation inspected: StarterValidator, DemandModel, NetworkModel, GridSolver, and the documented schema/lease/coordinator contracts. Older broad construction/growth proposals are not authority for this slice.

## Recommendation and owner choices

| Decision | Recommended choice | Approval consequence |
| --- | --- | --- |
| D131 | One **Connect new district** project: a 1 MW feeder and its customer terminal on an existing reserved pad | Introduces a fixed 250-resident-equivalent customer district, not population growth or an already-existing unserved town. |
| D132 | Fixed **1,000 Credits**, immediate completion upon durable commit; preserve 250 Credits | Requires Bank at least 1,250 Credits at the serialized purchase boundary. No recurring line maintenance, refund, sale, demolition or timed build. |
| D133 | Explicit two-demand-bus extension, district curve defined below, original starter unchanged | Requires a bounded solver/report extension; current solver has only one source/sink. No general multi-generator dispatch or demand-priority system. |
| D134 | Schema3/ledger3 and permanent one-project receipt; atomic fenced purchase | Adds construction debit accounting without changing 120/80/10, grants, carries or historical billing. |
| D135 | 30-second server quote; brief country suspension only during the critical durable operation | Keeps ordinary menus live; prevents concurrent stepping/autosaves from invalidating the purchase snapshot. Separate fake/Test implementation and later real-execution gates. |

Approval must explicitly include the district and two-sink extension. If either is rejected, stop and redesign: a spare generator or larger substation alone has no useful consequence under current demand. Do not quietly reduce existing capacity to manufacture a bottleneck.

## Useful first project and placement

The accepted starter already serves all 1,000 residents: 5 MW gas, 10 MW substation, two 10 MW links, peak 3.811 MW. There is no existing underserved satellite in the persistent profile. Southbank/Eastmere demo artwork is not an authoritative customer or a permitted migration target.

Offer a surveyed **new district** beside the town. It is a prospective service connection, not an unpaid existing electricity obligation. Before construction it contributes no requested energy, reliability denominator, revenue or cost. The original settlement remains population1,000 with its unchanged identity/coordinates. The separate district has fixed population-equivalent250, no growth, and a safe derived label `<town name> district`. This explicitly extends the one-settlement starting contract only after purchase, without backfilling historical unserved demand.

Use the existing saved starter rotation and candidate, including safe fallback rotation0. Unrotated town terminal `(704,512)` connects straight to future pad `(704,704)`: **192 world units / 1.92 map km**. Apply existing Starter.rotate to both; retain original endpoint IDs and anchors. The town demand bus also serves as the distribution take-off; it is not a new substation or an invisible junction at a line crossing. All delivery still traverses the existing substation and town-bus capacity gates. The new terminal and line are the one bundled project, not two purchases. They use the single abstract voltage tier; no real-world voltage claim or transformer mechanic.

Server validates exact allowed project/definition, original topology, owned sector `(0,0)`, integer-sixteenth coordinates, unique IDs, empty project slot, 1 MW terminal/line rating, and the reserved dry/flat corridor. Check endpoints plus seven samples at 32-unit spacing (including endpoints) and the existing 3×3 pad probes. No client waypoints, arbitrary coordinates, water crossing, terrain surcharge, reroll or clearance effect. The fixed 1,000-Credit starter-project price is an explicit exception to the future per-km/terrain pricing proposal. If preserved generation fails any route check, block the offer and investigate; do not move a terminal or rewrite terrain. Four rotations and the 10,000-seed corpus must validate identical opportunity/cost before acceptance.

Stable project semantic key `district-feeder-v1` is scoped by country identity. Allocate one built terminal and one built line using the existing monotonic serial, proposed suffixes `:b:1` and `:b:2`; require initial serial1 for this narrow migration and advance to3 only with successful construction. IDs stay within64 bytes. The line references the original town terminal and new built terminal. No alteration of the immutable starter network array: compose base plus validated deltas.

## Electrical and economic effect

Proposed `constructionDemandVersion=1`: for each step, compute existing starter requested integer kW with unchanged DemandModel v1 at the protected climate. District request is **floor((starterKW + 2) / 4)** (nearest-quarter, half upward). This deliberately scales the whole residential/commercial/heating/cooling mix. Calling DemandModel with population250 is **not equivalent**: its commercial baseline is fixed0.60 MW, independent of population. The proposed scaling rule is a new, explicitly approved district definition, not a change to existing coefficients. Store fixed250-equivalent identity separately; do not infer population from delivered MW.

After committed construction, activate the district starting with the next completed interval. Requested demand remains present if the generator is Off or the built feeder is disconnected in a fault fixture; delivery/revenue then follow actual connectivity. No backdated demand or billing. Single-source lossless conservation, prefunding (maximum684 minor per interval), fixed On cost, fractional carries and no-offline rules remain unchanged. The new line has no additional operating charge in this first slice. This is a balance proposal, not a claim that physical lines have zero real maintenance.

Extend the residual-flow adapter to exactly two sinks with independent demand/delivery reports, retaining node and shared physical-link capacity gates. Normal maximum total is **4.764 MW**, district maximum **0.953 MW**, leaving **0.236 MW** generation headroom. For this restricted topology the valid operational source is either 5 MW or Off and both sinks are fully served or both Off; an isolated branch cannot consume power. Arbitrary reduced-capacity stress fixtures must still conserve energy, but general fair partial-source allocation is deferred. Refuse unsupported capacity edits rather than exposing ID-based starvation as a gameplay policy. Preserve original single-sink solver fixtures/API through a separate versioned composition path; record solver/composition version2 for the extension without changing pinned base networkVersion1.

### Progression study

[Independent integer arithmetic](P3C-BALANCE-STUDY.json) reproduces the accepted 1,440-step starter total before evaluating the proposed curve. Normal speed is one simulated minute per active wall second; delays/Off time extend real waiting.

| Fully served simulated day (24 active minutes) | Starter | With district |
| --- | ---: | ---: |
| Delivered MWh | 75.457983 | 94.325600 |
| Posted sales Credits, starting carries0 | 9,054.95 | 11,319.07 |
| Posted variable expense | 6,036.63 | 7,546.04 |
| Fixed expense | 240.00 | 240.00 |
| Net operating earnings | 2,778.32 | 3,533.03 |

Purchase cost is separate capital spending, not an operating expense or recurring deduction. Incremental analytical net is about **754.70 Credits/day**, +27.2% against starter net; investment payback about **31.80 active minutes** after connection. Compare unrounded rates for forecasts; posted day differences can vary by a minor unit with initial carries.

From a fresh 1,000-Credit grant, earn250 net before buying: approximately **2.16 active minutes** at day-average rate. From historical Rowanbridge step118/Bank1,007.66/carries recorded in P3b.5, independent replay reaches Bank1,250.03 after **124 On intervals**; paying1,000 leaves250.03. This is a scenario, not a fresh service observation or promised timing. No extra grant, borrowing or reserve exemption. A larger project price delays the first understandable action; a price≤750 could be bought entirely from the opening grant. A 1 MW branch naturally bounds this one opportunity, with no repeat-purchase money loop.

## Quote and accessible player flow

1. A restrained construction prompt says **Connect new district — use spare generation**. Selecting it highlights the fixed route/site with dashed preview styling, distinct from energized lines. Inspector explains current customers, prospective additional load and generator headroom. No illustration or client computation establishes authority.
2. Request a server quote. Show exact price1,000 Credits, current live Bank, last-confirmed Bank, projected post-purchase Bank and250 buffer. Show forecast incremental earnings as estimates, not guaranteed payout; explain generator Off/no generation means no new revenue. Low funds shows required additional earnings and an accessible disabled confirm reason.
3. Confirm explicitly: **Build for 1,000 Credits**. Server revalidates funds and eligibility at acceptance; if changed, return a fresh quote/error, never silently charge more. Cancel before submission spends nothing. A submitted write cannot be cancelled by closing the panel.
4. During commit show **Saving construction — checking result**, with actual country suspension visible. Only verified commit shows **District connected and saved**, authoritative Bank and the new asset. Failure shows not built only when absence is positively established; uncertainty remains Checking/Unavailable. Reconnect recovers the saved project.

Desktop inspector and mobile sheet reuse theme, text/icon status and44px targets, keyboard/gamepad focus/confirm/back and touch controls. Preserve pan/zoom/recenter/Locate, selection and camera across modal/profile updates. Contextual labels and Native pool remain; no new sprite/upload. Budget preview, terminal, line, labels and hidden objects together under600 descendants; replace/reuse pooled decoration if necessary. Do not raise the cap. Opening ordinary menus does not pause simulation. The actual critical persistence suspension below does, with no catch-up revenue.

## Server protocol and durable transaction

Proposal: at most one live quote and one in-flight construction per player; quote lifetime30 seconds using a server monotonic clock. Quote lookup binds authenticated Player, country, public command-session generation, project/catalog versions, topology revision, canonical route, fixed price and server-created GUID operation ID. Lease tokens/fences stay private. Public envelope includes protocol version, bounded request sequence and command-session identifier; these are not credentials. Confirm carries only quote ID and request sequence. Reject unknown fields, other owners, foreign sessions, nonfinite values, oversized strings/payloads and replayed sequences before expensive work. Suggested quote/confirm/status limits respectively1/s burst2,1/s burst2,1/s burst2, payload≤1KiB and existing global budget. Duplicate status checks never issue DataStore calls per click.

Simulation revisions naturally advance while the quote is open. Do not invalidate on every billing tick. Bind structural/catalog revision and recheck latest balance/funding; capture exact country/profile revisions only when serialized confirmation starts. Expiry applies at server acceptance, not midway through a dispatched durable operation. A new quote invalidates the old one; once accepted its operation ID cannot be replaced for a retry.

Transaction sequence (proposed coordinator extension, **not supported by ordinary autosave today**):

1. Under the per-country mutation queue, reject if pending persistence is ambiguous, lease unsafe, project already completed, bad quote or unavailable budgets. Drain/confirm any earlier checkpoint before entering the critical barrier; if draining outlasts quote expiry, require a new quote without debit.
2. Finish any currently executing atomic step, then freeze country mutations. There is no outstanding half-step fuel reservation. Require live Bank−100000≥25000 and adequate unchanged lease safety margin. Capture latest complete energy/finance snapshot and durable base revision. Purge/coalesce obsolete queued checkpoints so none can later save pre-build topology. Ordinary menus did not cause this freeze; the transaction barrier does.
3. Prepare an immutable candidate: all preceding unsaved earnings/history/carries plus exactly one debit, one terminal, one line, serial increment, topology revision increment and permanent receipt. Advance countryRevision once for construction but **not simulation.step or settlement cursor**. Validate complete schema, references, route, size and Bank. No external effects inside a retried callback.
4. One fenced whole-profile UpdateAsync compares exact current owner/fence/baseProfileRevision and legal transition. The candidate, debit and receipt commit together; increment profileRevision and renew the existing180-second lease. A retry assigns the identical prepared state, never subtracts again. Receipt already matching the semantic project and operation means return committed result; different completed operation means AlreadyBuilt, no second debit. Do not combine a new quote with a stale captured financial snapshot.
5. Verify returned full candidate/receipt and ownership. Install committed state as both current and confirmed; clear stale save queue entries; resume only with safe lease. Publish success after this point. Next interval uses both demand buses; no physics/render activation before commit.

Preserve current four global in-flight calls/eight profile queue entries, five-attempt/30-second reconciliation bounds,180-second lease/30-second safety margin and20-second shutdown drain. One construction occupies existing profile capacity, not a second independent writer. If safe renewal is needed, do it before acceptance then recapture the base; never interleave a lease write with an unresolved purchase. A suspended country accrues no energy, cost, income or offline catch-up.

## Failure, ambiguity and reconnect

| Boundary | Required result |
| --- | --- |
| Invalid/expired quote, route, funds, cap or schema | No write/debit/asset; useful reason; refreshed quote only after new intent. |
| Definitely not committed | Keep intact pre-purchase country, discard tentative asset/debit; resume only if current ownership/head verified. |
| Timeout/error with unknown result | Keep mutation and success acknowledgement suspended; uncached reconciliation of same operation. Never refund, invent a new operation or assume failure. |
| Read proves exact candidate/receipt committed | Install saved state; report success only under safe ownership; if another owner now holds lease, report saved status but old server stays suspended. |
| Read proves unchanged base under same safe lease | Retry identical operation within existing limits. No new debit computation or quote expiry rejection after dispatch. |
| Newer/unexpected head, conflicting receipt, unknown/corrupt data | Stop; no overwrite, forced unlock or automatic recovery. |
| Crash before commit / after commit but before reply | Reconnect loads either complete old state or complete built state. Durable semantic receipt prevents repurchase even after lastCommit is superseded. |
| Leave/shutdown during operation | Finish/reconcile existing operation before any release; never race release/old autosave against it. Deadline leaves lease to expiry. |

Permanent semantic receipt is retained for the life of this country; the single lastCommit receipt is insufficient because later saves replace it. Old public session requests reject after reconnect. A fresh quote for a built project returns AlreadyBuilt with sanitized receipt, no write. Stale local Bank cannot override a newly acquired owner's record. Recovery remains operator-reviewed and separately authorized; no automatic rollback/refund or restore of old leases/revisions. A successful operation is not undone because the client missed its response.

## Schema3 proposal and migration

Retain one standard profile key and original recipe, seed, settlement, network and owned sector. Schema1 and2 validators remain strict historical validators. Do not make old Economy.transition accept arbitrary changed immutable fields. Add explicit schema3 transformation/transition validation and preserve the unchanged billing kernel with a versioned accounting wrapper.

| Field | Proposed addition/change |
| --- | --- |
| Envelope | schemaVersion3; same fenced revisions/lease, recognized Build receipt kind; no revision resets. |
| Bank | ledgerVersion3; constructionSpentMinor initially0; spentMinor = variableExpenseMinor + fixedExpenseMinor + constructionSpentMinor; earned remains eligible sales; balance = openingGrant + earned − spent. |
| Economy | Existing economyVersion1/balanceVersion1, activation/grant IDs, baseline, cursor, totals, carries, statements unchanged; operating net excludes capital purchases. Explicit schema3 accounting wrapper validates expanded spent invariant. |
| Construction | constructionVersion1, constructionDemandVersion1, compositionVersion2, topologyRevision0 initially; project absent or exactly one completed receipt. |
| Built deltas | builtNodes≤1, builtLines≤1, serial1→3; all other deltas/tombstones/orders remain empty. No queued timed orders. |
| Permanent receipt | projectId, definitionVersion1, operation GUID, priceMinor100000, terminalId/lineId, construction step, before/after Bank, countryRevision and committed profileRevision. Server-owned, bounded, immutable. |

Receipt sum equals constructionSpentMinor (0 or100000). Require receipt, terminal and line all absent together or present together with matching IDs/route/cost. Historical before/after balances certify the debit at its step; current Bank may change later through valid billing. At a Build transition, compare exact prior/current candidate finances: delta balance−100000, spent/constructionSpent+100000, other financial categories/carries/meters unchanged from captured snapshot, step/cursor unchanged, one country revision increment. Existing pending unsaved billing is independently validated as an allowed prefix before that debit. No backdated arbitrary financial corrections. Checkpoint/Renew/Release cannot create/delete/alter purchase receipts or infrastructure; only the dedicated Build transition can.

Pure v2→v3 migration adds empty construction fields/zero capital category and ledger3, preserving every existing value including balance/spent, opening grant, activation, energy history, online state and financial carry. It does not construct, debit, grant or bill. Schema3 reload is validation only. Unsupported nonempty old deltas or unexpected schema stop. Keep original network definition/generation versions pinned; extension composition is a separate version. Preserve all future country identity mappings without regeneration.

Keep192KiB soft/256KiB hard profile cap and16KiB finance cap; propose≤4KiB construction subtree including receipt. Validate worst-case history and receipt before any purchase. No unbounded ledger, extra key or separate inventory write. Schema3 absence means NotBuilt, not a reason to recreate country. Retain old schema/grant migration tests; v1 cannot bypass the approved v1→v2 path, and Rowanbridge must never repeat that grant.

Before any real migration: separate authorization, authenticated exact Test account/universe/key check, fresh uncached read, schema2/head/lease validation, secure reviewed preimage/checksum and complete field-level v3 diff. Preserve metadata. Unexpected head stops review. Migration-only approval is not purchase-execution approval. Historical Rowanbridge revision24/country131/epoch7/Bank1007.66 is context, not a future compare token. No real calls in this task.

## Implementation and acceptance gates

1. **Now:** owner reviews D131–D135, especially the new district, quarter-demand rule, price, straight take-off and short persistence suspension. Stop before code.
2. After explicit implementation authority: pure project catalogue/route validator, bounded two-sink composition/report, schema3/transaction validator, quote coordinator with fake storage. Keep original domain/services/adapters boundaries; no dependency or ordinary real startup.
3. Fake Test GUI and full regressions; measure new graph CPU, render counts and critical freeze/queue behavior. Block on any invariant/performance failure, not increase budgets automatically.
4. Separate real migration-readiness review and exact-key execution approval; no incidental real access from test runners. Disable unrelated preview heartbeats in any future dedicated real harness, addressing P3b.5's isolation limitation.
5. Separately approve a bounded real purchase/checkpoint/reconnect procedure using only Test10776833313/account149564436 and the existing approved key. Record actual debit/receipt/delivery/financial restoration and release. Production10776828545 remains excluded. No construction implementation or future real action is approved by this proposal.

| Tests after approval | Required assertions |
| --- | --- |
| Affordability | 124999/125000/125001 minor; exact buffer, committed snapshot includes preceding earnings, no half-step reservation; Off/low balance and forged price. |
| Geometry | All rotations/fallback,10,000 accepted seeds, pad/route probes, ownership, wrong endpoints/voltage, malformed coordinates, duplicate IDs, cap failure; base hashes unchanged. |
| Electricity | Before-build unchanged P2b, connected full-day totals, Off and disconnected branch zero revenue,1 MW branch/10 MW substation gates, conservation, deterministic replay, bounded solver exhaustion commits nothing. |
| Money | Exact carries over build/save/hour boundaries; no increase in fixed cost or grant, capital counted once, per-step receipts match actual delivered/generation, no retroactive/offline billing. |
| Transactions | Double click/two quotes/different operation same project, repeated callbacks, lost success, pre/postcommit crash, later lastCommit eviction, stale epoch/fence/revision, expired quote accepted before dispatch only, save/build interleavings. |
| Recovery | Pending purchase vs leave/shutdown, hung call retaining slot, budget starvation, unchanged-head retry, unexpected newer head, expired lease, same-account reconnect, no mixed debit/asset state or fabricated refund. Faults fake-only. |
| Migration | v2→v3 byte-preservation of unchanged subtrees, one grant, no charge, future/corrupt versions fail, round-trip old fixtures, nonempty unsupported deltas, full ring/profile caps, no schema2 weakening. |
| UI | Desktop/tablet/mobile safe areas,44px targets, touch/keyboard/gamepad, accessible price/buffer, quote expiry, Saving/Unknown/Failed/AlreadyBuilt states, no premature success, Native selection/camera/Locate retained,≤600 descendants under movement/remount. |
| Regression | P2a/P2b/P2b.1,10,000-seed climate/fairness corpus, P3a/P3b/P3b.1–5 fake suites, both Rojo builds, Script Analysis and repeated timing; no real runners/gates automatically enabled. |

Measure eight fake countries, before/after solver p50/p95 and operation counts, profile bytes, queue maxima, memory/remount stability and commit freeze latency separately from service latency. Existing200,000 solver-operation budget,32-node/64-line validation ceilings and600 map descendants remain unchanged; this project uses four nodes/three lines. Existing real12-call P3b.5 evidence does not predict construction latency or device performance. Public-release insolvency recovery remains unresolved and mandatory; this is not a complete first-playable release.

## Documentation validation and stop

See [design validation](P3C-DESIGN-VALIDATION.md) for checks actually performed. Runtime/Studio/build and real-service tests above are planned, not newly passed. No Rowanbridge read/write, extra key, settings, Production, upload, publish, commit or push. Await owner decisions before implementation.
