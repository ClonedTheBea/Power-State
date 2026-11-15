# Economy and National Eras

Status: delivered-energy revenue, consequential growth and optional rebirths are confirmed. All formula coefficients, safeguards and reward curves are proposed D06–D08. Electricity reports are defined in [Simulation](ELECTRICITY-SIMULATION.md).

## Single consolidated treasury

Propose one national electricity treasury in the first release because the player is both government and utility. Separate budget categories are allocations, not extra balances. Internal subsidies move authority between categories and never mint money. A future split government/utility ledger would require explicit taxes, transfers and solvency rules.

Store cash as integer minor units (100 per credit), transaction reason, operation ID, simulated step and revision. Maintain bounded recent transaction detail and cumulative income/expense category totals. Lifetime cash earned is distinct from current cash and is not an initial leaderboard.

For each completed simulation step:

`net = domesticDeliveredMWh × effectiveTariff + eligibleExportMWh × contractPrice − importedMWh × importPrice − fuelCost − variableOperatingCost − fixedHourlyCost × hours − payroll − fundedProgramCost`.

Construction, research and repair orders debit separately at their accepted transaction boundary. Charge fixed operating costs even when generation is curtailed if the plant remains staffed/online. Price quotations include terrain and policy modifiers once. Never bill unmet demand, potential generation, storage charging, or the same exported MWh twice.

Proposed fixture prices: domestic tariff 120 credits/MWh, gas variable cost 50 credits/MWh inclusive of automatically purchased fuel, and station fixed cost 10 credits/simulated hour. Avoid adding another fuel charge to that inclusive MVP cost. Initial 7 MW supply earns 840 credits/hour and costs 360 credits/hour before later payroll and policy expenses. These values demonstrate signs and units, not final pacing; all future staff costs must be balanced against the same clock.

## Tariffs, approval and demand

Tariffs have a bounded selectable range, proposed 60–180 credits/MWh initially. Desired demand = base demand × time curve × price elasticity × policy modifiers, all clamped. A proposed elasticity curve is `(tariff/referenceTariff)^(-elasticity)` with elasticity 0.15 residential and 0.35 industrial. Enforce a positive reference price and clamp multiplier to 0.7–1.2. High tariffs also lower approval and long-run industry growth; subsidies can reduce the customer tariff only by consuming an allocated treasury budget.

Track each region's rolling supplied/requested energy ratio over a proposed simulated day, not the instantaneous final tick. Demand-free intervals do not imply a 100% rewardable service history. Aggregate reliability for national display by energy weighting; retain regional values so a small disconnected settlement is not hidden by a large industrial region.

## Population and industrial growth

Each region stores population, housing capacity, industry level/capacity, prior demand intensity and reliability history. On a simulated-hour cadence, derive a bounded growth rate from service ratio, approval, job availability and environmental policy. Proposed rate: base 0.2% per simulated hour × reliability factor × approval factor × jobs factor, capped at 0.5% per hour and housing capacity. Below 70% service, positive growth stops; sustained severe outages may cause a bounded decline. Retain fractional residents internally and display integers.

Industry investment consumes money and develops over time; output/job indices increase only after service and construction requirements are met. Industry increases future demand rather than immediately supplying free treasury revenue. Any later tax income needs its own approved source/sink model. Compute demand from start-of-step population; apply growth after settlement so new residents do not create circular same-step income.

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

No borrowing, interest, player transfers or premium boosts in MVP. If money approaches the agreed safe integer ceiling, stop increasing it with an explicit cap notice; do not silently overflow. Proposed display/ledger cap is 10^15 minor units, below 2^53. Validate all products before converting to the integer ledger. Balance analysis must include late-game saturation before launch.

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

Active global-event cumulative contribution, claimed reward flags and currency persist until that event's defined expiry; the temporary interconnector is removed with infrastructure and must be rebuilt. Rebirth cannot reset individual objective requirements or allow duplicate event rewards. Event eligibility baseline is fixed at first participation.

## Permanent upgrades

Proposed tracks use ten levels, price `ceil(5 × 1.5^level)` points: revenue +1%/level capped +10%; construction discount 1%/level capped 10%; inspection technology unlocks plus bounded duration reduction; research speed +2%/level capped +20%; breakdown hazard reduction 2%/level capped 20%; administrative overhead reduction 1%/level capped 10%. Multipliers combine once from canonical derived stats and never eliminate fuel, maintenance, line capacity or electricity demand. Revenue bonus is a labeled gameplay modifier on sold energy, not generation income; its fiction and competitive treatment need approval.

## Acceptance and rollout

P3 validates the ledger, delivery billing and growth. P7 adds policy effects; P8 adds eras after reliable saving and rewards exist. Verify every debit/credit against a report, exact-once reset under response loss, lifetime statistics across resets, capped arithmetic, and progression without rebirth. Run balance sweeps over tariff extremes, full curtailment, chronic outage, repeated resale and maximum upgrade stacks before accepting balance values.
