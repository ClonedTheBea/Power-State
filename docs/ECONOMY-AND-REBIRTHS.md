# Economy and National Eras

17 November 2026: [Starting country](STARTING-COUNTRY.md) replaces the old multi-settlement opening requirement. The 7 MW price/boost arithmetic below remains an illustrative regression/balance example, not the new opening income. [Minimal simulation](MINIMAL-SIMULATION.md) defines P2 nonspendable estimates; P3 ledger, funded operation and balance gates are unchanged. New-country seeds at rebirth remain subject to separate reset/balance approval.

Status: delivered-energy revenue, growth and optional rebirths are confirmed. The 15 November GUI brief also confirms Bank/Credits terminology and the Double Income product rules (D20–D23), for design only. Prices, transaction/timer engineering and balance remain proposals. Electricity reports are defined in [Simulation](ELECTRICITY-SIMULATION.md).

## Single consolidated Bank balance

Use **Bank** as the user-facing name for the single consolidated national electricity balance. Currency is **Credits**, for example `100,000 Credits`, never a separate “Bank Credits” currency. Separate budget categories are allocations, not extra balances. Internal subsidies move authority between categories and never mint money. A future split government/utility ledger still requires explicit approval. Existing internal cash field names need not change.

Store cash as integer minor units (100 per Credit), transaction reason, operation ID, simulated step and revision. Maintain bounded recent transaction detail and cumulative income/expense category totals. Lifetime cash earned is distinct from current cash and is not an initial leaderboard.

For each completed simulation step:

`baseEligibleSales = domesticDeliveredMWh × effectiveTariff + eligibleExportMWh × contractPrice`.

`net = incomeFactor × baseEligibleSales − importedMWh × importPrice − fuelCost − variableOperatingCost − fixedHourlyCost × hours − payroll − fundedProgramCost`.

`incomeFactor` is 1 without a benefit, otherwise exactly 2 when either verified permanent Double Income or an eligible active temporary benefit applies. It is never 4 when both records exist. In phases before the separately authorized shop milestone, it remains 1. Excluded rewards/grants have their own ledger reasons and never pass through this multiplier. The multiplier is an explicit gameplay bonus on sales revenue, not extra delivered electricity or a tariff change imposed on simulated households.

Construction, research and repair orders debit separately at their accepted transaction boundary. Charge fixed operating costs even when generation is curtailed if the plant remains staffed/online. Price quotations include terrain and policy modifiers once. Never bill unmet demand, potential generation, storage charging, or the same exported MWh twice.

Proposed fixture prices: domestic tariff 120 Credits/MWh, gas variable cost 50 Credits/MWh inclusive of automatically purchased fuel, and station fixed cost 10 Credits/simulated hour. Avoid adding another fuel charge to that inclusive MVP cost. Initial 7 MW supply earns 840 Credits/simulated hour and costs 360 Credits/simulated hour before later payroll and policy expenses. These values demonstrate signs and units, not final pacing; all future staff costs must be balanced against the same clock.

## Tariffs, approval and demand

Tariffs have a bounded selectable range, proposed 60–180 Credits/MWh initially. Desired demand = base demand × time curve × price elasticity × policy modifiers, all clamped. A proposed elasticity curve is `(tariff/referenceTariff)^(-elasticity)` with elasticity 0.15 residential and 0.35 industrial. Enforce a positive reference price and clamp multiplier to 0.7–1.2. High tariffs also lower approval and long-run industry growth; subsidies can reduce the customer tariff only by consuming an allocated budget from the Bank.

Track each region's rolling supplied/requested energy ratio over a proposed simulated day, not the instantaneous final tick. Demand-free intervals do not imply a 100% rewardable service history. Aggregate reliability for national display by energy weighting; retain regional values so a small disconnected settlement is not hidden by a large industrial region.

## Population and industrial growth

Each region stores population, housing capacity, industry level/capacity, prior demand intensity and reliability history. On a simulated-hour cadence, derive a bounded growth rate from service ratio, approval, job availability and environmental policy. Proposed rate: base 0.2% per simulated hour × reliability factor × approval factor × jobs factor, capped at 0.5% per hour and housing capacity. Below 70% service, positive growth stops; sustained severe outages may cause a bounded decline. Retain fractional residents internally and display integers.

Industry investment consumes money and develops over time; output/job indices increase only after service and construction requirements are met. Industry increases future demand rather than immediately supplying free Credits. Any later tax income needs its own approved source/sink model. Compute demand from start-of-step population; apply growth after settlement so new residents do not create circular same-step income.

Proposed approval is 0–100 with a smoothed target from reliability, affordability, employment and environmental performance. It changes at a bounded hourly rate, with transparent components. It influences growth and political pressure, not confiscation of the player's country. Elections are deferred in [Government](GOVERNMENT.md).

## Money safeguards

| Exploit / failure | Rule |
| --- | --- |
| Build/sell subsidy farming | Track net amount paid; resale below that amount after wear; subsidy nonrefundable |
| Repeated requests or save retries | Stable operation IDs; one authoritative debit and asset creation |
| Import/export arbitrage | No simultaneous country import/export; bounded contracts and explicit price spreads |
| Storage revenue loops | Charge is consumption, discharge is not generation; efficiency losses and trade rules apply |
| Reconnecting/replaying tutorial | No repeated cash grant; live progress predicates and durable claim flags |
| Negative/NaN prices, huge amounts | Server catalog prices, finite bounded inputs, checked arithmetic |
| Rebirth starter-cash farming | Starter money cannot qualify as earned surplus or be transferred across eras |
| Infinite bailout | Restricted recovery mechanism, once per era, no qualification credit |
| Global event payout duplication | Separate idempotent claims; never pay twice for one delivery meter |

No borrowing, interest or player transfers in MVP. Energy Shop is now a confirmed design requirement, superseding the blanket rejection of premium boosts as a long-term feature; it is still outside P1–P4 until a separate implementation milestone is approved. If money approaches the agreed safe integer ceiling, stop increasing it with an explicit cap notice; do not silently overflow. Proposed display/ledger cap is 10^15 minor units, below 2^53. Validate all products before converting to the integer ledger. Balance analysis must include late-game saturation before launch.

Before each solve reserve a conservative upper bound for the next step's operating costs from unencumbered cash. If unaffordable, suspend optional programmes, exports and unfunded plant operation in a documented priority order, then recompute feasible source bounds. Release unused reservation after actual costs settle; do not assume future sales will fund already-spent fuel or silently allow negative cash. A plant suspended for insolvency provides no generation and no active-staff benefit. Define a protected operating reserve in the build UI. The proposed D08 recovery package may include restricted fuel/repair vouchers with zero resale/era qualification value, but amounts and repeat-insolvency recovery need approval and testing before public play. These are explicit economic design gaps, not permission to mint unlimited rescue cash.

## National Era lifecycle

Optional transition: locked → eligible → preview → confirmed request → durable reset commit → new era active. Keep playing without resetting. Preview lists exact rewards and everything lost/preserved. The final confirmation uses a recent server quote, era ID and operation ID. Pause country mutation while committing; after ambiguous write failure, reload/resolve that operation before granting or resuming.

Proposed eligibility for era number e (starting e = 0): at least `10,000 × 1.6^e` delivered domestic MWh this era, population `20,000 × 1.4^e`, and 90% reliability over the last 24 simulated hours with actual demand. Publish attainable bounded thresholds or logarithmic comparisons before exponential overflow. Qualification uses domestic delivered energy, never generation, imported-and-resold export volume, starter money or tutorial sandbox activity.

Proposed reward is `floor(10 × sqrt(eraDomesticMWh / eraEnergyRequirement))`, capped at 30 legacy points per era. The cap limits idle grinding; the minimum qualifying reward is 10. Record the formula/balance version with the claim. Reward once for `(userId, eraId)` in the same profile update that increments era ID and resets the country. A successful reset cannot be replayed by an old request.

| Reset | Preserve |
| --- | --- |
| Cash to starter amount; ordinary assets and owned territory to starter fixture | Lifetime generation/delivery totals and era count |
| Population, industry, temporary policies, ordinary staff and projects | Legacy points and purchased permanent upgrades |
| Era research progress, ordinary faults and active orders | Achievements, cosmetics, company identity, permanent event records |
| Era qualification counters | Tutorial preference/completion and compact era history |
| No reset of commerce ownership | Verified permanent Double Income and unused temporary active-time remainder survive eras |

Active global-event cumulative contribution, claimed reward flags and currency persist until that event's defined expiry; the temporary interconnector is removed with infrastructure and must be rebuilt. Rebirth cannot reset individual objective requirements or allow duplicate event rewards. Event eligibility baseline is fixed at first participation.

## Permanent upgrades

Proposed tracks use ten levels, price `ceil(5 × 1.5^level)` points: construction discount 1%/level capped 10%; inspection technology unlocks plus bounded duration reduction; research speed +2%/level capped +20%; breakdown hazard reduction 2%/level capped 20%; administrative overhead reduction 1%/level capped 10%. The former proposed revenue +1%/level track (up to +10%) is **on hold** under D23: no extra income multiplier or 2.2× combination is approved. Choose a non-income replacement or a separately approved composition rule before P8. Other modifiers combine once from canonical derived stats and never eliminate fuel, maintenance, line capacity or demand.

## Energy Shop and Double Income — design only

See [GUI vision](GUI-VISION.md#energy-shop-design-contract) and [component states](GUI-COMPONENT-SPEC.md#shop-and-purchase-states). No prices, passes, settings or purchase code are created by this design.

| Offer | Payment | Benefit | Duration/repurchase |
| --- | --- | --- | --- |
| Temporary Double Income | Earned Credits, exact server price not yet balanced | 2× eligible domestic sales and exports | 1,800 active online seconds; pauses/offline time excluded; survives rebirth; repurchase only after expiry |
| Permanent Double Income | Optional Robux Game Pass, current price supplied by Roblox | Same 2× eligible sales; no stacking | Permanent across rebirths; temporary purchases unnecessary and unavailable while owned |

Expenses remain unchanged. No direct multiplier on generation, demand, population growth, maintenance, reliability, simulated time, lifetime generated energy, event export meters, grants, achievements, event currencies or legacy points. The increased Bank balance can indirectly finance more infrastructure and improve future rankings/event capacity; disclose that advantage. Core play must remain viable at factor 1. The Bank leaderboard is financially advantaged by permanent ownership; do not describe it as an equal-spending competition or claim “not pay-to-win.” A separate unboosted leaderboard is not approved; retain no scarce rank rewards and review disclosure/competition policy before release.

Do not sell extra income stacks, top-ups while active or auto-renewals. No second currency is added. Previously proposed seasonal currency is an independent future event design, not an Energy Shop balance and not newly approved here. Government grants and event rewards retain their ordinary rules.

### Pricing and usefulness

25,000 Credits in the reference is illustrative only. Do not seed a real catalogue with it. Compare price P to incremental eligible sales over 30 active minutes, B = integral of unboosted eligible sales rate over the active window. Extra net income attributable to the benefit is approximately B − P when the operating plan is unchanged; expenses are not halved and profit is not simply doubled. Purchasing during a blackout may produce little benefit; show that honestly, not a guaranteed return.

Under the **proposed** D03 clock (one real second = one simulated minute), 30 active real minutes contain 30 simulated hours when running normally. The earlier 7 MW fixture produces 840 Credits/simulated hour base sales, or 25,200 Credits additional sales over that window. At an illustrative P = 25,000 the incremental gain is just 200 Credits before opportunity cost; buying may displace a much better grid investment. This arithmetic is a design warning, not a price recommendation. Lag/pauses and varying delivery change the realised outcome.

Balance study must cover:

- Starter/recovery countries: affordability from ordinary net earnings while preserving the operating reserve; never make the boost the only way out of insolvency.
- Expanding countries: fixed prices become trivial as sales grow; compare a fixed low price versus published, capped progression bands. Do not silently price by wallet balance or punish an immediate purchase after earning money.
- Rebirth: reduced starter earnings can make a mature-country price useless; any band must have explicit era/reset rules, while an existing remaining duration is preserved. Test buying immediately before rebirth and repeated era transitions.
- Free-to-play repeat use: measure time to first purchase, incremental value/price, sustainable repurchase cadence, outages and opportunity cost against construction. It must be a meaningful repeatable alternative, not a token discount next to an overwhelmingly stronger paid effect.
- Permanent ownership: identical instantaneous 2× rate, but no repeated Credit cost and no duration downtime; quantify Bank leaderboard divergence and indirect progression advantage.

No final Credits price, Robux base price, price-band formula or advertised return is approved. Propose candidate prices only after P3 telemetry/fixtures exist and the standard clock is settled. Native Roblox pricing may vary per player; never infer or display a Credits-to-Robux exchange rate.

### Active time, suspension and transitions

Timer units are real active-play seconds, not simulated minutes and not a UTC expiry timestamp. Server monotonic elapsed time advances it only while the owner is connected and their live country is in an eligible running state. Saving/loading, lease suspension, confirmed country pause, disconnect/offline and isolated tutorial practice must not consume it. Normal idle observation of a running grid is gameplay; do not require constant clicks.

**Confirmed R1 clarification (D30):** duration consumes active online simulation time; ordinary menus do not pause it. Offline time and actual server-known simulation suspension do not consume it. There is no client menu/focus flag that freezes only the benefit while earnings continue, and R1 adds no pause mechanism. Server timing/checkpoint details still require implementation testing; this is not a paid or selectable simulation speed.

Split a settlement interval at activation/expiry so only the eligible fraction receives 2×; preserve fractional money remainders and deterministic replay. Income, duration consumption and operation revision must reconcile together on crash; reconnect must not restore spent duration while keeping its associated extra earnings. See [Data/security](DATA-AND-SECURITY.md#energy-shop-persistence-and-authority-design-only).

When permanent ownership is verified during a temporary boost, immediately select one effective factor of 2. Confirmed policy (D31): retain unused temporary time dormant without refund, transfer or extension; show Permanent as dominant. A platform lookup failure is Unknown, not an entitlement revocation or invitation to repurchase. Define revalidation and revocation/recovery policy before sale.

### Approval and validation gates

Live commerce requires explicit authorization after P3 ledger/persistence, and later regression coverage for P6a exports and P8 rebirth. Resolve price model, timer/checkpoint implementation, ownership-outage policy and leaderboard disclosure; ordinary-menu and dormant-remainder behavior are confirmed by D30/D31. Validate duplicate/ambiguous purchases, timer checkpoints, expiry boundaries, disconnects, concurrent sessions, grants excluded, no stacking and unchanged physical energy. Mocks cannot prove platform ownership, personalised prices or shutdown durability.

## Acceptance and rollout

P3 validates the ledger, delivery billing and growth. P7 adds policy effects; P8 adds eras after reliable saving and rewards exist. Verify every debit/credit against a report, exact-once reset under response loss, lifetime statistics across resets, capped arithmetic, and progression without rebirth. Run balance sweeps over tariff extremes, full curtailment, chronic outage, repeated resale and maximum upgrade stacks before accepting balance values.
