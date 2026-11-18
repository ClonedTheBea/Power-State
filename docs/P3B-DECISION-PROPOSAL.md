# P3b — Bank and electricity revenue: decision proposal

17 November 2026. **D106–D112 approved for pure implementation, fake storage and isolated Test GUI validation. Real schema-v2 writes remain separately gated.** Historical design text follows; the owner approval recorded in D113 supersedes pending labels. D105 authorizes this documentation task. P3a's accepted proof is the foundation; its execution approval does not authorize revenue, migration or further DataStore operations. No runtime changes or DataStore access occur in this task.

Sources: [P3a results](P3A-VALIDATION.md), [persistence contract](P3A-DECISION-PROPOSAL.md), [economy](ECONOMY-AND-REBIRTHS.md), [minimal simulation](MINIMAL-SIMULATION.md), [electricity accounting](ELECTRICITY-SIMULATION.md), [data/security](DATA-AND-SECURITY.md), [accepted P2b coefficients](P2B-DECISION-PROPOSAL.md). Approved implementation and later decisions take precedence over historical proposed fixtures.

## Owner decisions requested

| ID | Recommendation | Consequence |
| --- | --- | --- |
| D106 | Fixed domestic price **120 Credits/delivered MWh**; gas variable cost **80 Credits/generated MWh**, including fuel; fixed On cost **10 Credits/simulated hour** | Approximately 31% starter net margin. Supersedes the old illustrative 50 variable cost only if approved. No selectable/demand-sensitive pricing or elasticity. |
| D107 | **1,000 Credits** opening grant once per country at economy activation; **250 Credits** earmarked operating buffer in the same Bank | Explicit funding for migrated zero-Bank countries; grant is not earned sales. Buffer can fund operations and is not a second wallet or untouchable floor. |
| D108 | Settle every completed simulation minute; integer hundredths with exact carried fractions; aggregate UI statements by simulated hour | Funding stays safe between statements. Existing 55–65-second persistence cadence remains separate. |
| D109 | Pre-fund each interval; unaffordable generator becomes Off with a reason; no debt, free fuel or automatic bailout | Zero cannot self-recover. Accept this narrow proof limitation or request a separate recovery design before implementation/public play. |
| D110 | Schema **2**, Bank ledger **2**, economy/balance **1**, same store/key; explicit v1 migration with a preserved country and cutover step | No retroactive revenue/costs, reroll or reset. Grant and migration receipt commit together. Real migration requires separate approval and reviewed preimage. |
| D111 | Checkpoint Bank, financial cursor/fractions/meters and simulation together under existing fenced leases | Unconfirmed energy and earnings may roll back together; no retained payout can be replayed. Future irreversible actions require durable confirmation. |
| D112 | Accessible Bank overview; effective factor **1** in P3b; preserve future 2× sales-only contract | No Shop, purchases, entitlement lookups, boost timers or pass IDs. Costs/grants never multiply. |

**Current approval gate:** owner approved these rows and implementation. Zero-balance dead-end is accepted only for this isolated proof; a non-Robux insolvency recovery system is mandatory before public release and is not implemented here. No real migration or financial checkpoint is authorized. See [implementation evidence](P3B-VALIDATION.md).

## Scope and specification conflicts

Only domestic delivered-energy revenue, starter gas costs, funded operation, Bank reporting and compatible persistence are proposed. Preserve 1,000 residents, the 5 MW generator, 10 MW substation, existing lines/anchors, climate/demand v1, bounded scheduler and Native renderer. No construction, growth, taxes, payroll, market demand, trade, storage, fuel inventory, climate events, Shop, R4 or rebirth implementation.

Older 0.75 MW/7 MW examples are arithmetic fixtures, not the accepted starting country. The accepted demand is **75.4579833333 MWh/day**, peak **3.811 MW**, protected mean **17°C**. All accepted starts use that protected climate/demand despite different seed/name/geography. Older tariff elasticity/growth proposals remain deferred.

D98's exactly-zero Bank remains correct for schema-v1/P3a. Proposed schema2 adds a separately approved rule; nonzero v1 data must still fail validation. P3a ProfileLease currently treats Bank as immutable: implementation must add explicit v2 financial-transition validation, not remove immutable-field protection wholesale. Recipe, settlement, network and land remain protected.

The older economy text says saving pauses future boost time. D30 and P3a's asynchronous saves require a narrower interpretation: a checkpoint that leaves simulation running must not stop its active-time clock; actual loading/lease suspension must. This is a compatibility clarification, not timer implementation.

## Economic model and starter scenarios

Each accepted interval is 1/60 simulated hour. Sales = domestic delivered MWh × 120. Variable expense = actual generator output MWh × 80, **including fuel**. Fixed expense = 10/60 Credits when effectively On, including zero dispatch; Off/unfunded pays zero. Net = sales − variable − fixed. Never bill unmet demand, potential/nameplate output, forecasts, old energy or offline wall time. Failed solves settle nothing.

Lossless P3b generation equals delivery because trade/storage are absent. Keep separate generation and delivery meters and assert equality; do not generalize this into a future rule that imported power/storage discharge is owned generation. Refuse unsupported graphs/technologies until separately designed.

[Offline arithmetic study](P3B-BALANCE-STUDY.json) reproduces the existing integer midpoint demand formula and checks its 1,440-step sum against the accepted reference. These are analytical values, not new Luau/Studio results or player-balance acceptance. Twenty-four simulated hours take 24 active minutes at normal scheduler speed.

| Daily scenario | Delivered MWh | Sales Credits | Variable | Fixed | Net |
| --- | ---: | ---: | ---: | ---: | ---: |
| Full starter service | 75.457983 | 9,054.958 | 6,036.639 | 240 | **2,778.319** |
| Half delivery, each sample floored to kW | 37.724183 | 4,526.902 | 3,017.935 | 240 | 1,268.967 |
| Hypothetical 1 MW bottleneck | 24 | 2,880 | 1,920 | 240 | 720 |
| Hypothetical 0.25 MW bottleneck | 6 | 720 | 480 | 240 | 0 |
| Zero delivery, On | 0 | 0 | 0 | 240 | −240 |
| Off throughout | 0 | 0 | 0 | 0 | 0 |

Stress bottlenecks are analysis fixtures, not authorized map changes. Actual operation stops charging On costs when unaffordable; the table is not permission for an overdraft. Every normal starter On interval is profitable: minimum demand 2.517 MW yields at least 90.68 Credits net per simulated hour. Off is a useful control, not a profit strategy. Break-even On delivery averages **0.25 MW**, from `10/(120−80)`.

At full service, variable costs 50 / 80 / 100 yield daily net 5,042.059 / 2,778.319 / 1,269.160 Credits and margins 55.7% / 30.7% / 14.0%. Recommend 80 for meaningful gross costs without making normal starter service precarious. Fixed 10 makes disconnected On operation visibly costly. Do not manufacture difficulty through excessive costs without viable player decisions.

### Progression benchmarks, not purchase prices

At daily-average net, earning an **additional** 1,000 / 5,000 / 10,000 / 25,000 Credits takes approximately **8.64 / 43.19 / 86.38 / 215.96 active minutes**. These exclude the grant and are average-rate estimates, not exact milestone times or approved building/boost prices. Starting clock, outages and rounding affect actual timing.

After one fully served day, the 1,000-Credit opening Bank becomes **3,778.32 Credits**. The 250 buffer covers about 36.5 seconds of worst-case 5 MW gross costs without receipts, or 57 seconds at mean demand. Starting cash covers 2.44 minutes of worst-case gross costs; normal receipts fund subsequent steps. Idle On with no delivery loses 10 Credits per active minute, approaching the conservative funding cutoff after roughly 99.3 minutes. Off stops that drain.

No optional sinks exist in P3b, so indefinite healthy operation necessarily accumulates money. This is an accounting proof, not a complete progression loop. Proposed acceptance is 25–35% starter margin, viable unboosted operation and visible outage costs. Construction pacing needs a later design; no spending is invented now to hide that limitation.

## Funding, reserve and insolvency

The 250-Credit buffer is an earmark within one balance. Future optional purchases would require post-purchase Bank ≥250 plus any outstanding operating commitment. P3b has no such purchase; present buffer guidance without a withdrawal action or separate pot. Operations may use the buffer.

Before an On solve, reserve the maximum next-interval integer debit from **existing live Bank**, including carried fractional costs, 5 MW available capacity and fixed cost. Maximum is **684 minor units / 6.84 Credits**. Do not count the interval's expected sales. Reservation is ephemeral inside the serialized step, not a persistent debit; no command/save interleaves with a half-applied interval. Apply actual expense, actual sales, simulation and cursor together; release unused reservation.

If unaffordable, serialize an automatic generator-Off transition with `InsufficientOperatingFunds`, recompute zero-source delivery and continue normal simulation/shortfall history without operating costs. Preserve nameplate, anchors and topology. Persist the resulting online state/reason; a legal funded restart clears the reason. On requests require funding; Off is always safe. No automatic retry/toggle loop, debt, interest, negative Bank, free fuel, hidden grant or country reset.

**Zero cannot self-recover in this milestone.** It is structurally valid but cannot buy fuel. The immutable healthy starter with the grant cannot naturally reach zero under its positive margins, but prolonged zero-delivery/future scenarios can strand a low balance. Public play needs a separately approved recovery system; restricted vouchers would add a grant/claim mechanism, not a quiet fallback. Owner must accept this isolated-proof limitation or request a recovery proposal first.

Saving suspension is different: freeze the whole country and finances when ownership is unsafe, rather than adding outage history/costs while suspended. UI distinguishes user Off, insufficient funds and saving unavailable.

## Exact server billing and rounding

Keep existing double-precision MWh and reliability arithmetic unchanged. Add exact financial meters from the already integer-kW **actual solver outputs**, never displayed numbers or subtraction of large floating cumulative totals.

1. Recover integer kW by rounding `reportMW*1000`, asserting distance ≤10^-6 kW and existing bounds. This checks representation, not a new demand/dispatch quantization. Unsupported fractional output fails rather than silently changing physics.
2. Each completed minute contributes that many **kW-minutes**. One MWh = 60,000 kW-minutes; denominator `D=60000`.
3. Rates in minor units: sales 12,000/MWh, variable 8,000/MWh, fixed 1,000/hour. For each category: `n=priorRemainder+intervalNumerator`, `postedMinor=floor(n/D)`, `remainder=n%D`.
4. Numerators: sales `deliveredKW*12000`; variable `generatedKW*8000`; fixed `effectiveOnline*1000000`. Carry categories separately through statements, midnight, On/Off, saves and reconnects. Bonus sales/carry are zero in P3b.
5. Commit `Bank + sales + bonus − variable − fixed` with the entire step only after nonnegative/cap checks. On reservation is `floor((variableRemainder+maxGeneratedKW*8000)/D)+floor((fixedRemainder+1000000)/D)`; Off reservation is zero. This covers fractional liabilities and reaches at most 684 minor units.

At constant 3 MW: each minute yields 0.05 MWh, 6.00 sales and 4.00 variable expense; fixed cost posts 0.16, 0.17, 0.17 over three steps. Three-step net is **5.50 Credits**. Truncating fixed cost to 0.16 every step is wrong. The actual full-day fixture posts sales **905,495 minor**, variable **603,663**, fixed **24,000**, net **277,832**. Remaining sales/variable/fixed numerators are **48,000 / 52,000 / 0** over 60,000 of a minor unit. These explain the difference from separately rounding analytical display columns.

Settle each completed interval in memory; no client claim or amount. Replicate at most once per second; aggregate statements at 60-step clock boundaries. Retain at most two overdue steps per frame slice and no offline/backlog billing. Commands between steps affect only future intervals.

Proposed cap: **10^15 minor units** per balance/cumulative category; retain maximum completed simulation step **10^9**. Validate finite/integer/nonnegative bounds before arithmetic. Financial meters are bounded by 5,000×10^9 kW-minutes, remainders <60,000; per-step products are safe below 2^53. Never multiply a whole lifetime meter directly by price: validate cumulative cents by quotient/remainder decomposition, `floor(meter/D)*rate + floor((meter%D)*rate/D)`. Stop the entire candidate step on cap exhaustion, rather than truncating only income while charging expenses.

## Compatible schema version 2

Same standard store `PowerStateProfilesP3aTest`, default/global scope and owner key. No new store per schema. Retain owner, country GUID, exact seed, six pinned algorithm/template/name/network versions, settlement name/IDs, online state, network/anchors, land, old energy/history and creation time. Schema1 remains a validated **migration input**, not an economy-enabled record.

| Record | Proposed fields and invariants |
| --- | --- |
| Envelope | `schemaVersion=2`; existing lease/revisions/sessionEpoch/receipt rules; recognized `MigrateAcquire` receipt kind. No revision reset. |
| country.bank | Credits, 100 minor/Credit, `ledgerVersion=2`; balanceMinor, earnedMinor, spentMinor; `openingGrantMinor=100000`, `openingGrantId="P3bOpeningV1:<countryId>"`, `operatingBufferMinor=25000`. Grant is not earned income. |
| country.economy identity | `economyVersion=1`, `balanceVersion=1`, activationStep, lastSettledStep, activation operation ID/from-schema. Prices come from a pinned server catalogue, never client fields. |
| Baseline | Exact pre-economy requested/delivered MWh and activation step. No retroactive billing or historical-generation reconstruction from the limited ring. |
| Exact post-activation meters | deliveredKwMinutes, generatedKwMinutes, onlineSteps. These do not replace physical MWh/history. |
| Category totals | baseSalesMinor, bonusSalesMinor (0), variableExpenseMinor, fixedExpenseMinor; earned=base+bonus; spent=variable+fixed. No purchases/events mixed into these fields. |
| Fractions | baseSalesRemainder, bonusSalesRemainder (0), variableExpenseRemainder, fixedExpenseRemainder; integers 0..59999. |
| Statements | At most 24 completed simulated-hour summaries and one partial: start/end step, observed steps, category deltas, meters/version. Migration's partial first hour is labelled partial. Display history is not the replay guard. |
| Funding status | Optional last insufficient-funds reason/step. Saved generator online flag remains authoritative; legal funded restart clears the reason. No loan/bailout record. |

Invariants: `Bank=openingGrant+earned−spent`; `lastSettledStep=simulation.step`; `activationStep<=lastSettledStep`; `onlineSteps<=lastSettledStep−activationStep`; generation/delivery meter equality for this graph; bonus fields zero. Totals/remainders agree exactly with meters/prices via overflow-safe decomposition. Existing physical totals minus activation baseline agree with financial meters/60,000 within the unchanged P3a MWh tolerance; never re-round legacy energy. Validate statement ordering/nonoverlap and category deltas. Evicted statements never make old intervals payable again.

Each statement is assigned by `floor(startStep/60)` with exclusive endStep; migration at step 113 yields a seven-interval partial statement ending 120. Display the last 24 **completed statement hours**, plus current partial, rather than claiming this is exactly the same rolling window as electrical reliability. Lifetime financial totals remain independent of statement eviction.

Keep 192 KiB soft /256 KiB hard profile bounds. Proposed finance extension ≤16 KiB including summaries; measure with full reliability history and worst-case identifiers before migration acceptance. No unbounded per-tick ledger, raw text or new keys. Legacy v1 still rejects nonzero Bank; v2 allows it only through validated economic transitions.

## Migration and real-profile protection gates

Rowanbridge was last observed in P3a as schema1, country ID `55e35a88-e3b9-4f72-9e69-d9024e7730a4`, seed `1441a4d819354af7b306ef8797931e15`, Bank 0, On, step 113, profileRevision 15, fence 4 and no lease. These are **recorded observations**, not fresh reads or an assumption that the key cannot change.

After separate authorization only:

1. Implement pure v1 validation and v1→v2 transformation on local fixtures. Corruption, nonzero v1 Bank, wrong owner, bad history, unsupported recipes or unknown versions stop without a write. Preserve v1 regression fixtures.
2. Present the exact proposed diff, grant, cutover and preservation evidence. Obtain implementation approval, then separate real migration authorization naming Test 10776833313, account 149564436, store/scope/key `u:149564436` and grant. No additional real key is implied.
3. Reverify universe, authenticated Player/creator and uncached head. Stop conflicting writers; wait for normal release/expiry, never force-unlock. Capture a reviewed local preimage/checksum and source revision/version metadata under explicit authorization. No backup export or Roblox request occurs in this design task.
4. Prepare a stable migration operation ID. Atomically compare current v1 content/revision/owner with the reviewed preimage, validate again, refuse an unexpired lease, preserve the country/simulation, replace only Bank with the approved grant/zero earned/spent, add zero economics at `activationStep=simulation.step`, set schema2 and acquire a new fenced lease. Increment profileRevision, countryRevision and sessionEpoch; record `MigrateAcquire` and grant identity together. No randomness, yielding or external effects inside the callback.
5. Callback retry/lost response recognizes the same migration, never another grant. If schema2 already exists, validate/load its existing grant/boundary rather than reconvert. Changed preimages or another owner require stop/reload, not overwrite.
6. Reconstruct and verify exact legacy preservation plus v2 invariants before economic activation. Reconcile uncertain results using the same operation ID and uncached read. If migration committed but restore fails, preserve the record and suspend; do not reset or downgrade.
7. For a newly approved v2 country, grant once at activationStep 0. Test direct initialization in fake storage unless an additional real key is expressly authorized. Do not reset Rowanbridge to test initialization.

At the recorded cutover, prior intervals through completedStep 113 remain unbilled. First eligible interval starts 113 and ends 114. Prior 5.355999999999993 delivered MWh earn **zero retroactive Credits**; prior operation incurs zero retroactive costs. On state and the energy/history ring stay intact. The grant is the only intentional opening money mutation and needs explicit approval.

Schema2 is not backward-writable by old v1 servers. Test old readers refusing v2 without overwrite; no active old lease may persist across migration. There is no automatic downgrade. Separately reviewed recovery writes a coherent complete state with a higher fence/revision; it cannot replay an old grant or retain earnings while rewinding energy. Preserve platform user-ID associations and metadata. Backup availability is not permission to reset.

## Checkpoints and replay safety

Use the existing one-key, one-writer coordinator. Persist whole snapshots, never additive `IncrementAsync` payouts or adding sales inside a retried save callback. Each interval identity is `(countryId,economyVersion,startStep)`; accept only `startStep==lastSettledStep==simulation.step`. Commit both cursors once at its exclusive end. Reject duplicate/older or gapped intervals; no client can request settlement. The durable monotonic cursor, not a bounded receipt/statement cache, prevents old payout replay.

Retain 55–65-second checkpoint cadence, 180-second lease, 30-second safety margin, one operation per profile, four outstanding service calls globally, eight admitted sessions and bounded retries. A checkpoint includes Bank, categories/fractions/meters/statements, generator state, clock/MWh/history, receipt and fence. Queue one newer immutable snapshot while an older one saves. Later snapshots may skip save revisions but must already contain billing for every intervening simulation interval. Retried callbacks conditionally assign the snapshot rather than recompute income.

- Before-save crash: restore the earlier complete energy/Bank/cursor/fraction state. Unconfirmed intervals may execute again, but their former credits did not survive, so durable income is not duplicated.
- Commit with lost response: reconcile the same receipt; never create a replacement grant. A newer owner fences the old server even if its write had once committed.
- Save failure/no budget: show Delayed and retain bounded latest state; suspend under existing lease/deadline rules. No earnings during suspension. A deadline cannot cancel a yielding request or free its slot early.
- Leave/shutdown: checkpoint and release together, best effort. Reconnect loads the committed step then advances the next; no offline elapsed-time payout or rebilling cumulative old energy.
- Invalid arithmetic/caps: freeze the entire candidate step, with no partial expense/revenue/history. Legitimate insufficient funds instead produces the defined generator-Off behavior.

Live Bank is explicitly labelled live, with last-confirmed Bank/step available. Healthy rollback is normally up to 65 seconds, potentially longer during faults before lease safety suspension; no zero-loss shutdown promise. No P3b purchases, transfers, rankings or permanent rewards use unsaved earnings. Future construction, rebirth and commerce must durably commit preceding financial state and their debit/grant/action ID together before success. Ordinary autosave alone is insufficient for those irreversible actions.

## Accessible Bank overview

Keep the compact header/Bank KPI and responsive shell. Bank opens an overview, not a Shop. Detail shows exact hundredths such as `3,778.32 Credits`; compact header formatting retains Credits terminology and an exact accessible label. No Robux conversion.

Order: live Bank/save status; confirmed Bank/step; electricity sales; fuel/variable operations; fixed running costs; net; operating-buffer guidance. Separate the grant from earned sales. Label completed statement hours, partial hours and totals since economy activation. Forecasts based on current output are estimates, never mixed with settled receipts. Day-average study values are not promises.

Desktop uses a compact category table; mobile uses stacked rows with the same information and 44px targets. Preserve keyboard/gamepad focus and dismissal, map camera/selection, and reusable theme/components. Text/signs/icons accompany colour. Distinguish Off, low buffer, insufficient funds, Saving, Delayed and Suspended. No per-tick cash animations, ticker, giant buttons or additional economic navigation.

Only sanitized owner totals, bounded statements, save status and reasons are replicated. Clients cannot set Bank, prices, clock, grant, step or multiplier. Opening Bank neither pays nor pauses anything. Retain ownership/version/epoch/rate/shape checks; prefer the existing read-only snapshot over a new mutable remote.

## Future Double Income contract — no implementation

P3b factor is **1** and bonus fields zero. Preserve separate base/bonus categories; no Shop, purchase endpoint, marketplace lookup, pass ID or fabricated ownership record.

Future temporary 2× costs earned Credits and lasts **1,800 active online seconds**; permanent 2× is a Robux Game Pass. Either produces factor 2 on eligible electricity sales, never 4. Fuel/fixed costs, grants, rewards and rebirth points remain unchanged. Only server-verified entitlements generate bonus. Timer consumption and associated earnings share the same checkpoint.

Ordinary menus/asynchronous saving do not pause a running simulation; loading, actual suspension and offline time do. An Off generator may still belong to a running country: time eligibility does not guarantee revenue. Permanent ownership leaves unused temporary time **dormant**, without stacking/refund/extension. Unknown ownership is not revocation.

Activation/expiry within an interval needs a separately versioned exact subinterval allocation/timer design. The whole-step denominator must not pay an entire interval at 2× for partial eligibility. This is a future gate, not a claim of implemented commerce support.

Hypothetical full-day 2× starter sales are 18,109.916 Credits, net 11,833.277 versus 2,778.319: **about 4.26× net profit**, because costs do not double. Do not describe this as simply doubled profit. No boost price is selected; the old 25,000 illustration is not a catalogue value. Future review must quantify affordability/return and preserve viable 1× play.

## Implementation stages after approval

1. Pure server economy/versioned catalogue; exact billing/funding tests, no services. Preserve Domain/Services/Adapters boundaries and P2a behavior.
2. Schema2/migration and fake failure tests; retain v1 fixtures. Permit only valid new financial transitions; no blanket relaxation of immutable world fields.
3. Fake Test GUI and accessibility; eight-country workloads, size and queue checks. Proposed economy-only p95 target ≤0.25 ms/country step on reference Studio desktop, separate from generation and network latency; investigate failures rather than weaken bounds. No device guarantee.
4. Present results and reviewed Rowanbridge migration diff/preimage for **separate real authorization**. Reverify exact destination; no additional keys or reset/repeat grant.
5. Report actual evidence and limitations; stop at P3b. No construction/P3c, Shop, climate events, R4 or Production rollout.

## Failure, recovery and anti-exploit test plan

| Area | Required evidence after implementation |
| --- | --- |
| Billing | On/Off, zero demand, disconnected, curtailed and bottlenecked fixtures; actual outputs only; no unmet/nameplate payout; conservation retained. |
| Rounding | 3 MW three-step 5.50 example; full-day 277,832-minor net/carries; step versus batch/save partitions, fractional edges and long-run overflow-safe decomposition. |
| Funding | Below/equal/above exact reservation with all carry extremes; no future-sale funding; unused reserve released; zero/low-buffer behavior and no Off cost. |
| Atomicity | Solver/finance exception, cap or size breach changes neither Bank nor step/history; automatic Off transition is serialized and persisted. |
| Replay | Repeated steps, gaps, evicted statements/receipts, callback retry, stale command epoch, reconnect: no durable duplicate income. |
| Faults | Failed read is not new; ambiguous migration/checkpoint/release, delayed callbacks, concurrent fake owners, expiry, crash before/after boundaries, queue mutation; coherent money/energy/carry restoration. |
| Migration | v1 step 0, Rowanbridge-shaped 113, midnight/ring-wrap/Off; preserve IDs/versions/history; one grant; no retroactive billing; schema2 reload; changed preimage/future/corrupt versions stop without writes. |
| Exploits | Forged owner/amount/price/factor/grant/step/time, spam, NaN/infinity/negative/huge data, manipulated counters/snapshots; checked server authority and limits. |
| Future factors | Pure synthetic 1×/2× contract tests with identical physical energy/costs, no 4× or grant multiplication. No runtime entitlement activation; timer tests belong to later commerce. |
| UI | Partial hours, statement eviction, exact/compact numbers, Live/Saving/Delayed/Suspended, low/zero cash; mobile/desktop/touch/keyboard/gamepad; panel preserves camera and never pauses. |
| Resources/regressions | Full profile≤256KiB, finance≤16KiB, bounded statements/requests/queues; eight-country profiling; P2a/P2b/P2b.1/P3a, golden vectors and 10,000-seed coverage retained; both builds and Script Analysis after implementation. |
| Real gate | Separately approved one-key migration/checkpoint/reconnect/release preserves country and one grant. Confirm money/cursors/carries by fresh reads. Destructive and competing-writer injection stays fake unless separately approved. |

These tests are **planned**, not claimed passed by this document. P3a evidence does not prove schema2, financial replay safety, hosted contention or economic recovery.

## Platform notes and design validation

Official documentation rechecked 17 November 2026: UpdateAsync callbacks cannot yield; Studio accesses experience data, so separate Test isolation remains essential. [Roblox data stores](https://create.roblox.com/docs/cloud-services/data-stores). Uncached verification and reviewed preimages remain necessary; platform versioning is not a backup of every checkpoint. [Versioning/caching](https://create.roblox.com/docs/cloud-services/data-stores/versioning-listing-and-caching). These facts do not validate the proposed application protocol.

[Balance arithmetic](P3B-BALANCE-STUDY.json), [protected source hashes](P3B-PRESERVED-SOURCE.json), and [documentation validation](P3B-DESIGN-VALIDATION.md) record work actually done. No runtime tests/builds, Studio controls, DataStore calls, migrations, settings, commits, pushes or publishing in this design task.
