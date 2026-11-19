# First Grid Reinforcement — Operations v1.2 decision proposal

19 November 2026. **G1–G5 subsequently approved and implemented in isolated fake Test; G6 approved as future direction only (D191).** The proposal below is retained as the design baseline, including its original approval wording. See [implementation evidence](GRID-REINFORCEMENT-V1-VALIDATION.md). This approval does not cover real services, schema4, Rowanbridge, new wind construction or its hypothetical8,000-Credit price. Solver policy, tariffs, demand and base fixtures remain unchanged; only the paid overlay changes the eligible Training feeder.

## Recommended decisions

| Decision | Recommendation awaiting approval | Consequence |
| --- | --- | --- |
| G1 | Reinforce East's existing `sb` line from 3,000 to **4,000 kW**, semantic project `east-feeder-reinforcement-v1`, once per eligible Operations country | Same line ID, endpoints `sub`→`b`, coordinates and abstract electrical tier; capacity overlay, not a second circuit |
| G2 | **500 Credits**, at least **750 Credits** at confirmation; preserve the existing 250-Credit operating buffer | An accessible reliability investment with slow financial payback; no free upgrade, loan, rebate, grant or expected-income spending |
| G3 | Immediate completion only after confirmed atomic persistence; no new upkeep or planned outage for this first proof | Larger solver capacity begins next admitted interval; never rewrite past electricity or reliability |
| G4 | Implement first in disposable Operations fake storage, with a new versioned investment record and ledger capital term | Do not promote OperationsStore into real persistence. No schema-v4 implementation or real migration is part of this approval by implication |
| G5 | Retain 30-second server quotes, Refresh Quote, one live quote/in-flight project, fenced atomic whole-country debit/topology/receipt | Apply the established P3c transaction discipline to an edge upgrade, including ambiguous-write reconciliation |
| G6 | Follow with a separately designed, player-funded surveyed wind connection for generated countries | No automatic fleet award to Rowanbridge; current training already contains wind, so that fleet cannot be used as evidence of purchased progression |

Approve/amend G1–G6 before infrastructure implementation. In particular, approve the **reliability-first, slow-payback** price deliberately. The next implementation authorization should cover pure/fake integration and tests only; real preparation, migration and execution remain separate gates.

## Why reinforcement rather than another generator

Current Operations v1 has six nodes and five lines. Gas (5 MW), wind (2 MW) and peaker (2 MW) feed a 10 MW substation through their own rated connections. North's feeder is 6 MW; East's is 3 MW. During scenario phases 90–120 inclusive, East requests 3.5 MW and North 2.5 MW. Even 9 MW nameplate cannot push more than 3 MW through `sb`.

A line-rating overlay is the smallest meaningful change. Keep its surveyed corridor, identity and electrical endpoints. Label it a reinforced transmission feeder, not an extra connection or proof of voltage/impedance engineering. A parallel 1 MW circuit would also offer 4 MW aggregate in this simplified radial model, but adds another asset, branch flow, failure identity and future maintenance semantics. Replacement unnecessarily risks ID/selection/history continuity. Neither alternative earns redundancy or N−1 claims in the present abstraction.

3.5 MW is the minimum sufficient capacity. It and 4 MW produce **identical delivery and income in today's demand envelope**. Recommend 4 MW as a clear whole-MW rating with 0.5 MW unused room; it does not create extra customers or authorize future demand. More than 4 MW provides no current gameplay benefit. The 10 MW substation, 6 MW North link and all generator spurs stay unchanged. No need to alter max-min fairness, source costs, integer rounding, solver graph limits or service contract.

This is lossless integer-kW transport flow, not AC power flow, frequency control, voltage stability or a physical contingency model. The 4 ms cooperative solver target is not a whole-server frame guarantee. Retain 80 ms aggregate eight-country work and 750 ms completion at native/30 Hz, graph/work bounds, cancellation and atomic installation.

## Price, progression and expected effects

[Reproducible local arithmetic](../scripts/AnalyzeGridReinforcement.py) and [full results](NATIONAL-GRID-REINFORCEMENT-CALCULATIONS.json) use the exact v1 seed20 wind knots, integer interpolation, 240-minute demand phases and 120/80/110 variable sale/gas/peaker rates, with 10/6/2 fixed On costs. MWh = summed kW-minutes / 60,000. Each source's variable/fixed minor units are floored separately from cumulative meters, matching the existing carries; sales are floored once nationally. These are **analytical design replays of the current radial topology**, not engine tests of an implemented purchase or a new general solver.

For this radial common-bus graph, national delivery is `min(total enabled/capped supply, North request + min(East request, East rating))`. Economic dispatch uses useful wind, then gas, then peaker. This total calculation does not independently prove per-sink fair allocation; that remains an implementation acceptance test against FleetSolver. Unit spurs have their existing ratings and the substation is nonbinding in these fixtures. No formula is installed into runtime.

Comparison assumes reinforcement exists before the measured window and excludes capital from operating net; an actual later purchase cannot earn retroactive benefit. Initial temporary training Bank is 1,000 Credits, not a new grant. Controls and demand are identical between each base/reinforced pair.

| Measured design window / controls | Extra delivery MWh | Extra operating net Credits | Base → reinforced energy service | Extrapolated 500-Credit incremental payback |
| --- | ---: | ---: | --- | --- |
| Steps 0–239, all units On at full caps | 0.258333 | 2.80 | 98.565% → 100% | 714.29 simulated hours |
| Steps 0–1439, all units On | 1.550000 | 31.61 | 98.565% → 100% | 379.63 simulated hours |
| Steps 0–1439, peaker Off throughout | 0.537067 | 21.48 | 96.695% → 97.192% | 558.66 simulated hours |
| Steps 0–10079, all units On | 10.850000 | 244.65 | Per-window values in artefact | 343.35 simulated hours |

First-day ready-fleet details: requested108 MWh; delivery106.45→108; sales12,774→12,960 Credits (+186); variable expense6,978.24→7,132.63 (+154.39); fixed432 unchanged; net5,363.76→5,395.37 (+31.61). Gas rises84.450967→84.988033 MWh; peaker2.019733→3.032667; wind19.9793 unchanged. This is additional delivered electricity with real operating costs, not 186 Credits of pure profit.

At a sustained 0.5 MW bottleneck with adequate supply, additional sales are60 Credits/simulated hour. If the marginal generator is gas, extra fuel40 gives20 net/hour; if peaker, fuel55 gives5 net/hour; otherwise-curtailed wind could give60, but that is **not** what the current first-day trace does. With insufficient total generation, reinforcement can deliver no national energy gain (though it may change fair regional allocation). With gas unavailable or caps too low, it cannot guarantee full service.

The current clock nominally completes one simulated minute per active real second. Thus 379.63 simulated hours corresponds to379.63 active real minutes (about6.33 hours), **only if that sampled average persisted**. Wind is not a repeating four-hour curve; the seven-day comparison shows sensitivity. Pauses, disconnection, costs, caps and changing conditions make this extrapolation a scenario, not an income promise. No offline accrual is proposed.

500 Credits is already affordable from the temporary1,000-Credit fixture while keeping250: an immediate purchase would leave500, with no new grant. With all units On throughout the analytical replay, Bank at completed step90 is1,313.56 Credits; a500-Credit purchase then would leave813.56 before further intervals. By the first visible constraint the player has also earned genuine income. These are illustrative starting conditions, never a hardcoded purchase balance. Do not add an undisclosed time lock or claim this forces saving. If the owner wants a saving gate instead,1,000 Credits/1,250 threshold is an alternative, but doubles already slow marginal payback. A lower100-Credit price would shorten first-day extrapolated payback to75.93 active minutes but makes spending almost trivial. Recommend500 as a small, comprehensible reliability purchase; acknowledge that current economics alone do not strongly motivate it. Do not invent reliability rewards, penalties, new demand or tariff changes to disguise this tradeoff.

The candidate spends from the same Bank; no second wallet. Require actual Bank >= price +250 **and** sufficient post-debit cash for the existing next-step gross operating reservation. At today's capacities250 comfortably exceeds one-step gross costs, but keep the invariant explicit. Saved/pending valid earnings must be preserved in the transaction candidate. Never spend forecast revenue.

## Player interaction and feedback

1. Control-room alert names East, requested/delivered MW and the 3 MW rating. Keep generation shortage and network constraint distinct.
2. Selecting East or the substation exposes a server-owned `Review reinforcement` action. No unsolicited purchase popup and no client inference of eligibility from painted terrain.
3. Review: same surveyed route highlighted natively,3→4 MW,500 Credits, live Bank, confirmed checkpoint, projected post-purchase Bank and250 buffer. Preserve camera/selection and 44px controls on mobile. No new terrain/art assets.
4. Explain: “Widens this feeder. It does not generate power. Up to0.5 MW extra can reach East under today's demand when supply is available.” Forecast estimates remain conditional, not payable income.
5. Show Available/Insufficient/Already reinforced, Quote expired with Refresh Quote, Saving/Reconciling/Unavailable and Confirmed. Menu stays open across expiry. Refresh replaces the server quote; never silently purchases or revives an expired quote. Cancel closes a review, not a submitted mutation.
6. Confirm locks repeated submission. Keep a readable acknowledgement in the panel. Only confirmed receipt updates the map rating and dispatch input. Next completed interval displays the changed flow; lifetime reliability recovers gradually because history is preserved, not reset to100%.

No new input system: use current shell/modal focus, scroll/paging and Map/Locate controls. At most one reused highlight and panel; retain <=600 map descendants. Screenshots are future implementation acceptance, not delivered by this design.

## Versioned state and migration design

### Isolated fake implementation proposed first

Keep current Operations v1 fixtures and records as regression inputs. Introduce **Operations record v2 / training ledger v2 / investment contract v1 / topology composition v2**, explicitly separate from persistent profile schema versions. New empty fields: `investments.version=1`, `investments.receipts={}`, `investments.overrides={}`, `investments.serial=0`; ledger `capitalExpenseMinor=0`. Preserve all step/cursor, history, exact cumulative source meters/carries, controls, Bank, country ID, ownership and original graph. Empty conversion is pure, applies no grant/debit/upgrade and advances no step. Reject unsupported/mixed versions.

After purchase: exactly one override keyed `sb` with base rating3000/new rating4000 and project/version; serial1; increment topology and country revisions once. Retain immutable base recipe. Every preparation must compose and validate the override **after Scenario.network(step)**; otherwise that function would restore3000 on the next tick. Projection, inspector, alert and forecast must use composed authoritative ratings rather than today's hard-coded3000 checks. Invalidate conditional forecast/cache on topology revision. No alternate visual-only capacity.

Ledger v2 identity: `balance = opening + sales - operatingExpenses - capitalExpense`. Capital must never enter per-generator variable/fixed meters or eligible sales. Permanent receipt must agree with both capital50000 minor units and the exact one-line overlay. No debit without rating/receipt, and no rating/receipt without debit. Do not treat the existing ledger v1 equation as valid after spending.

### Later real country migration — separate work and approvals

Rowanbridge has schema3 district construction and its own generated asset IDs/network; it has **no training `sb` feeder or free three-generator fleet**. Therefore this project is ineligible there. Preserve the original First Playable and all schema1/2/3 fixtures and real receipts; never manufacture an East link or rename a saved district to make a migration pass.

A future schema4/ledger4/operations1 country integration requires its own field-level proposal and fake proof before any real readiness. Preserve immutable legacy accounting prefix (sales, costs, capital, grant, energy/history/carries) and start versioned per-unit post-cutover meters at the exact activation cursor. Carry monetary fractions forward exactly; do not reset them or charge history again. Store bounded investment overrides/receipts alongside the preserved district receipt. Empty migration is not asset construction. Training ledger v2 is not serialized directly as a real profile.

Before future real operations: separately approved read-only preflight, exact identity/key/universe and schema/head/lease validation, protected complete preimage plus metadata/version/checksum, pure diff reviewed, guarded write approval and then separate purchase authority. Retain192KiB soft/256KiB hard profile limits and whole-key atomicity. No automatic upgrade, downgrade, reset, lease stealing or restore from a historical pre-purchase snapshot after a purchase.

## Quotes and atomic completion contract

Use the established P3c serialized ProfileService/Build pattern when integrating persistent operations; keep a fake adapter during the next proposed stage. The current lightweight OperationsStore is not sufficient proof of real leases or DataStore durability.

- Quote catalog: project/version, authenticated owner, country ID, opaque session command epoch (never private lease token), server-generated quote/operation IDs, monotonic expiry30s, fixed price50000 minor, base/composed topology revisions and surveyed `sb` endpoints. One live quote and one in-flight investment per country. Bound scalar fields, lengths, version, rate and sequence as existing remotes do. Client sends intent/quote ID, never price, Bank, capacity, seed or topology.
- Ordinary simulation may change Bank while a quote is open. At confirmation revalidate current owned session, expiry, semantic receipt absence, exact topology/site/version, price, post-debit buffer and gross operating reservation. Bind the actual candidate to the **latest** whole-country state; do not restore the quote's financial snapshot. Topology changes invalidate the quote. All expiry/clock checks are server-owned.
- Drain/reconcile any prior save. Renew first if necessary; retain180-second lease/30-second safety margin. Suspend only the critical transaction and invalidate/cancel any pending solver job before capturing the base. Menus do not suspend. No clock backlog, energy, billing or offline catch-up during genuine suspension.
- Prepare one immutable candidate once: current valid earnings/carries/history + debit50000 + `sb` rating override + topology/country revision + capital50000 + permanent semantic receipt. Receipt includes country/project/catalog version, operation ID, cost, line ID, base/new topology and committed revision. One receipt per project, not an unbounded transaction log.
- The one-key UpdateAsync transformation checks owner/fence, unexpired lease, expected profile/country revisions and complete expected state, validates candidate size/invariants, then assigns the entire candidate and envelope receipt atomically. No side effects, yield, ID generation, money subtraction or simulation recomputation on callback replay. Renewal and profile revision increment accompany the same commit.
- Exact matching receipt on replay returns the confirmed result. A different operation for the already-built semantic project returns AlreadyBuilt with no charge. Later checkpoints may replace `lastCommit` but must retain the permanent project receipt/override/capital invariant forever.
- Only after returned candidate/receipt verification may the server install the new topology and acknowledge completion. Re-admission uses the new revision; old jobs cannot install. In fake tests label completion explicitly “confirmed fake save”; do not claim service durability.

Retain one in-flight request per profile, existing four global calls/eight queued profiles, at most five attempts/30s observation window and20s shutdown drain when using ProfileService. A timeout does not cancel an underlying request: keep its slot until completion, do not overlap a new write, and stop before lease safety expiry. Current fake OperationsStore's two-attempt/two-read behavior is not silently widened; bridge to the approved coordinator in a separate pure/fake implementation with explicit tests.

| Failure | Required behavior |
| --- | --- |
| Expired/invalid quote, stale topology, insufficient actual funds | No write; show reason/Refresh Quote |
| Known precommit failure | Old complete state retained; resume only after ownership/head is positively safe |
| Response lost/unknown | Remain suspended; reconcile same operation through uncached read in future approved real execution; no automatic refund or new ID |
| Read proves candidate/receipt | Confirm saved result; old server cannot resume if fence/lease ownership has changed |
| Read proves unchanged base and safe owner | Retry identical prepared candidate inside existing bounds; expiry does not retroactively cancel a dispatched purchase |
| Newer/conflicting/corrupt head | Stop; never overwrite or merge stale funds |
| Crash/reconnect | Load either complete old state or complete reinforced state; semantic receipt blocks repurchase even after checkpoint receipt replacement |
| Leave/shutdown while pending | Same serialized finalization, no competing save/release; unresolved lease expires normally |

## Implementation stages and acceptance gates after approval

1. Pure catalog/composition/ledger-v2 conversion and radial/reference comparisons. Keep every legacy solver/economy fixture unchanged. Reject invalid target, endpoint, capacity, duplicate overlay, future version or half receipt.
2. Fake transactional coordinator: price boundaries74999/75000/75001 minor, post-buffer, once-only capital, fresh/expired/replaced quote, controls/billing interleavings, callback replay, commit-then-error, failure-before-commit, lease expiry/stale owner, queue limits and unresolved shutdown. Retain pure schema3 preservation and all prior construction tests.
3. Fake Test panel + Native route feedback. Confirm selected asset/camera/focus survive review/Refresh/commit/resize/remount. Mouse, keyboard, gamepad and touch; preserve the explicit v1.2 overflow cases,44px targets and600 descendants.
4. Solver: compare3/3.5/4 MW through unchanged FleetSolver, all demand phases/seeds, source caps/Off/wind0, disconnected `sb`, constrained upstream, reverse/shared edge capacities and fair sink allocation. Sum source output=delivered, ratings never exceeded. Assert future preparations preserve overlay, forecasts invalidate, no precommit demand/service change and no old-job installation.
5. Exact accounting: full-day/seven-day replay with capital excluded from income, unchanged fraction carries, split checkpoint/reconnect equivalence, no offline progress, same receipt after later checkpoints and distinct country isolation. Validate192/256KiB limits/full historical ring, bounded queues, eight-country native/30Hz80ms/750ms and4ms cooperative slice reporting. No threshold changes to force passes.
6. Owner review of fake playability and price. Real persistent-country operations design/migration/readiness/purchase procedures remain individually gated, not automatic continuations.

## Subsequent generator-construction milestone

Recommend **one surveyed 2 MW wind farm plus its rated spur** for eligible generated countries, retaining gas5MW, existing district and approved demand. Use the established0 Credits/MWh +6 Credits/On hour model and existing versioned wind potential; actual output must be useful/routed. Suggested8,000-Credit capital is a previously proposed hypothesis, not an approved price. At30% useful capacity factor replacing gas, net saving42 Credits/hour gives190.48 simulated-hour payback; at10%,10/hour gives800 hours; fully curtailed On wind loses6/hour. All require site/route/climate and progression review.

Do not sell extra firm capacity as necessary for today's <=4.764MW starter peak under a5MW generator. A later separately approved demand expansion may justify a peaker. Establish how the real country's graph obtains these assets through paid atomic projects; do not copy training fleet/Bank/history. Reinforcement teaches route bottlenecks, wind then teaches fuel substitution/variable availability, and later growth may motivate firm reserve. No new population curve, project or price is implemented here.

## Stop boundary

No infrastructure purchase code or runtime capacity change was made by this design. No real reads/writes, Rowanbridge migration, Production changes, uploads, settings, commit, push, publish or deployment. Review G1–G6 before the next implementation stage.
