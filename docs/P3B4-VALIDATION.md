# P3b.4 — Guarded real economy preparation

**P3b.5 bounded real economy proof complete (18 November 2026):** exactly five intervals across two authenticated Test sessions; seven updates/five uncached reads. Rowanbridge Bank1,007.66 Credits, step118, generator On, profile revision24/country revision131/epoch7/no lease. Both economy execution gates closed afterward; ordinary real startup remains disabled. [Actual results and remaining boundaries](P3B5-VALIDATION.md). Earlier statuses below are historical.

18 November 2026. **Preparation and fake-storage testing only. Real execution is disabled and requires separate owner approval.** No real DataStore reads or writes were performed during this task. No migration, opening grant, lease or gameplay change was made to the real Rowanbridge profile. Production, settings, artwork and publishing were untouched.

## Prepared implementation

- `Schema2GameplayAdapter`: separate manual factory, with `REAL_ECONOMY_EXECUTION_APPROVED=false` checked before service access. Once separately authorized, requires running server Studio in Test universe `10776833313`, personal creator `149564436`, and that actual authenticated Player. Fixed standard store `PowerStateProfilesP3aTest`, implicit default/global scope, exact key `u:149564436`; no caller-selected destination. Reads are uncached; update callbacks preserve platform metadata and associated user IDs. A 64-record ring holds timing/budget summaries without profile contents or session tokens.
- `ExistingEconomyStore`: shared injected-transport policy exercised with fake storage. Requires a complete valid schema-v2 profile for country `55e35a88-e3b9-4f72-9e69-d9024e7730a4`; rejects absent/v1/corrupt/wrong-country/active-lease preflight. First atomic update must match the freshly read complete canonical profile or the exact first operation result. Every transition preserves identity, recipe, infrastructure, activation boundary and approved cumulative finance invariants. No initialization, migration or additional grant path.
- `ExistingEconomyLease`: validates v2 before delegating Acquire/Checkpoint/Renew/Release to the unchanged fenced lease implementation. Retains 180-second duration, 30-second safety margin, revisions and idempotent receipt behavior.
- `ProfileService`: accepts real schema-v2 only with the adapter's private capability registration, exact v2 schema and existing-only lease module. An arbitrary `{mode="Real"}` object cannot pass. Existing v1 and fake paths remain. Queue, retry, reconciliation and shutdown policies are unchanged.
- `PersistentTestService`: adds explicit `startRealEconomy(player)` (currently fails at the disabled gate) and a fake existing-profile entry. Existing restore uses the saved recipe rather than generating a replacement candidate. Normal bootstrap and `startEconomy()` remain unchanged; no automatic real startup. Existing Bank UI distinguishes live and confirmed balances, and confirms that unsaved energy/earnings can roll back together.

The existing P3a real adapter remains v1-only. The P3b.3 migration-only adapter is unchanged and must not be rerun. No tariffs, grants, buffer, demand coefficients, schema, world algorithms or renderer changed.

## Fake validation and issues found

`P3b4Fixture` generates a synthetic, already-migrated profile at simulation step113 with the approved country ID and a public test seed. It is not the private real profile or a new real key. Its preparation uses the old migration path only inside fake test setup; the new gameplay path refuses migration.

The first fresh Play run failed the new checkpoint/carry assertion. Evidence showed the added first-write guard remained active after a lost acquisition response had been reconciled. A repeated checkpoint callback then compared against the wrong first-operation state. Correction: a validated uncached reconciliation read that exactly equals the recorded first result retires the first-write guard. Retained regression: lost acquisition response → reconciliation → callback-replayed checkpoint. No accounting or timing threshold changed.

Verified in Studio with fake storage:

| Check | Result |
| --- | --- |
| New P3b.4 domain/coordinator tests | 33 assertions; includes disabled real gate, counterfeit capability, absent/v1/corrupt/wrong profile, exact key, preflight race, lost acquisition/checkpoint responses, callback replay, On/Off, exact checkpoint/restoration, no offline billing/grant, lease expiry/stale owner and cleanup |
| P3a persistence regression | 178 assertions; 32 fake reconnects, 64 calls, one retained key; max checkpoint 84,620 bytes |
| P3b economy regression | 93 assertions; full-day billing, fractional carries, migration/replay, insolvency, atomic rejection; full profile 89,670 bytes |
| P3b.3 migration regression | 44 assertions, fake only |
| P2b accounting | 2,941 assertions, two-day demand/delivery conservation |
| P2b.1 scheduling | 49 assertions, eight synthetic jobs; not a new eight-client session |
| Existing-profile P3b GUI and remote tests | 88 GUI + 32 actual transport assertions against fake server state |
| Bank overview | 83 assertions at 1366×704, 360×580, 640×300 and 768×960; same authoritative progression deadline |
| Retained shell/currency | 324 / 26 unit assertions; 348 GUI / 16 currency GUI / 135 interaction assertions |
| P2a/P2b GUI and remote security | 57 / 88 GUI; 32 / 32 actual remote transport assertions |
| P2a solver/security | 432 assertions; 1000 starter solves 14.58ms |
| Retained P2b world sweep | **2,916,780 assertions**, 10,000 unique starts / 10,000 seeds, zero fallbacks; existing deterministic/climate/fairness gates passed |
| Local static checks | P3b.4 69, P3b.3 57, P3b149, P3a163, P2a34, P2b38 = **510** checks |
| Rojo and Script Analysis | Both default/Test builds and whitespace/source checks passed. All-script Studio analysis: 0 errors, 4 unchanged R33/R37 artwork warnings, no new source warnings |

Two fresh Play sessions passed the new33 + P3a178 + P3b93 + migration44 + accounting2941 + scheduler49 suites and existing-profile Bank/remote checks. Second Bank waits: 0.0972/0.7991/0.7983/0.7812 seconds. The extra GUI harness initially waited for `PowerStateShell` after deliberately destroying the live shell; remounting the prerequisite preview shell resumed and passed the unchanged GUI suites. This was test harness sequencing, not a runtime fix. Temporary runners were disabled afterward and the normal development runner restored. No fresh eight-client or physical-device claim is made.

The separate stopped-Studio 10,000-seed stress sweep completed at06:58:20UTC: generation CPU p95 **16.149ms**, maximum encoded generated snapshot43,705 bytes, maximum samples2,667; daily demand75.457983MWh / peak3.811MW. It ran without active country gameplay and is not a join-wall-time or concurrent-server throughput benchmark. All approved solver, generation, schema-v1 and economic arithmetic source hashes checked by the retained static validators remained unchanged.

First successful run: P3b.4 fake lifecycle 14 adapter calls / 8 writes, one retained key, final encoded profile 7,683 bytes. P3a canonical encode p95 7.339ms; P3b 8,000 serial economic settlements p95 0.0305ms; whole candidate step p95 0.485ms. These are desktop Studio/fake results, not real-service latency, concurrent-player throughput or device-memory guarantees. GUI maps held 345 descendants. P3b GUI CPU p95 0.1136/0.1359/0.1197ms and frame p95 17.70/17.92/17.61ms at desktop/mobile-safe/tablet sizes respectively. Four Bank waits were 0.0973/0.7989/0.7991/0.7818 seconds, all below the separately reported 1.2-second reference.

## Proposed real-service procedure — NOT executed

Requires explicit approval for the exact target and operations below, a reviewed bounded test driver, and deliberate enablement of the adapter gate. Do not simply call the unbounded heartbeat service and estimate the number of steps from a wall-clock wait. Use a server-only test coordinator over the same ProfileService/EconomicCountry contract with **five completed intervals maximum**; no automatic heartbeat advancement or client-controlled test stepping. Stop ordinary fake regression runners before this real proof.

1. Verify actual Studio server, Test universe, personal creator and authenticated Player149564436. Create the guarded adapter: perform a fresh uncached read of the exact key. Require valid v2, approved country identity and no active conflicting lease. Record actual revision/epoch/Bank/cursor/On state and platform metadata privately. Historical revision17/countryRevision124/epoch5/Bank100000/step113 is a comparison point only. If economic starting values differ from those below, stop and review the new arithmetic before acquiring. Never remigrate or replay the opening grant.
2. Construct a fresh session/command epoch; Acquire through ProfileService with ExistingEconomyLease. Its atomic callback compares against the full preflight. Verify fenced ownership and preserved country before activating. Freeze stepping until restore is complete.
3. Run exactly three On intervals using Demand.atStep(currentStep, saved-world mean temperature, 1000), the existing solver and EconomicCountry.advance. Stage whole-country state atomically after each. Assert live Bank differs from its last-confirmed balance; checkpoint once and wait for confirmation. Use an uncached read to verify the exact checkpoint, Bank, carries, history and cursor.
4. Issue the approved generator Off intent; complete exactly one Off interval. Check zero incremental sales/variable/fixed expenses. Checkpoint the whole country and verify confirmation. Freeze stepping. Release; wait for confirmation and perform an uncached read proving no lease and exact Off/history/finance preservation.
5. Disconnect the authenticated account, then reconnect the same account. Fresh adapter/preflight; no active lease; fresh fenced Acquire. Compare all financial fields and physical history to the confirmed released profile before any step. An offline wall-time gap must produce no simulation, revenue, costs or grant. Do not use another real key/account for this test.
6. Issue generator On; complete exactly one interval and checkpoint it. Verify exact next-step billing, then release with no additional intervals. Final uncached read must prove no lease and exact expected durable finance/history. Disable the real execution gate again after verification. Do not publish.

### Expected arithmetic if the fresh head remains step113 / Bank1,000 / zero financial carries

The protected 17°C mean, 1000-resident demand curve produces **3.120MW** at interval starts113–117. Existing graph serves all demand. Each On interval delivers/generates 0.052MWh, sales624 minor, variable cost416 minor; fixed1000000/60000 minor carries separately. Off still advances requested-energy/history and cursor, but delivers zero and costs zero.

| Completed step | Operation | Cumulative sales | Variable cost | Fixed cost | Bank (Credits) | Fixed carry numerator |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 113 | Fresh baseline | 0 | 0 | 0 | 1,000.00 | 0 |
| 114 | On | 624 | 416 | 16 | 1,001.92 | 40,000 |
| 115 | On | 1,248 | 832 | 33 | 1,003.83 | 20,000 |
| 116 | On, checkpoint | 1,872 | 1,248 | 50 | 1,005.74 | 0 |
| 117 | Off, checkpoint/release/reconnect | 1,872 | 1,248 | 50 | 1,005.74 | 0 |
| 118 | On, checkpoint/final release | 2,496 | 1,664 | 66 | 1,007.66 | 40,000 |

Category columns are integer hundredths of a Credit. Sales and variable carries remain zero; effective multiplier1. Final billing cursor118, activationStep113 unchanged, onlineSteps4, delivered/generated meters12,480 kW-minutes. Requested MWh increases0.260 and delivered MWh0.208 relative to the fresh preflight. Physical floating-point history must match deterministic replay, not rounded decimal totals. No historical energy is billed.

For any separately reviewed different starting step/carries, compute each posting as `floor((oldCarry + numerator)/60000)`, retaining modulo60000. Numerators: delivered integer kW×12000; generated integer kW×8000; On1000000, Off0 fixed. Use actual demand/solver results, never the rounded UI MW.

### Expected requests and recovery limits

Success path: **2 Acquires + 3 Checkpoints + 2 Releases = 7 UpdateAsync calls**; **2 fresh preflights + checkpoint verification + first-release verification + final-release verification = 5 uncached GetAsync calls**. No Renew is expected within the short active sessions; if needed, the ordinary 55–65-second cadence may add a fenced Renew without simulation advancement. Record actual calls, callback retries, budgets and latency individually; counts are not a guarantee about Roblox internal requests. No alternate keys/stores or backup writes.

Coordinator limits remain eight profiles, four outstanding requests, one operation and one coalesced checkpoint per profile. At most five attempts including reconciliation, 30-second operation deadline, bounded jitter up to8 seconds; shutdown20 seconds. Never reuse the slot of a still-yielding request. On ambiguous results, suspend further test stepping and use uncached receipt/fence/content reconciliation. No blind grant, reset, migration, forced unlock, overwrite of another lease, or rollback of the real profile. If exact ownership/durable state cannot be established, stop; permit lease expiry rather than forcibly clearing it. Recovery/restoration writes require their own authorization. Preserve the existing protected P3b.2 preimage; it is historical v1 evidence, **not** a current v2 overwrite candidate.

## Remaining boundary

Real schema-v2 gameplay, actual financial saves and authenticated reconnect are untested in this task by design. Fake adapter success does not prove Restricted service access, platform metadata behavior, request-budget availability, service latency or recovery under actual Roblox outages. Physical-device testing and public-release insolvency recovery remain outstanding. Request separate approval for the bounded procedure above; do not start P3c/R4/R5 or ordinary real startup.

## Files changed and rerun instructions

New runtime files: `src/server/Adapters/Schema2GameplayAdapter.luau`, `src/server/Domain/ExistingEconomyLease.luau`, `src/server/Domain/ExistingEconomyStore.luau`. Modified integration: `src/server/Services/ProfileService.luau`, `src/server/Services/PersistentTestService.luau`. No client, world-generation or billing-formula module changed.

New tests: `tests/unit/P3b4.spec.luau`, `tests/unit/P3b4Fixture.luau`, `scripts/ValidateP3b4.py`. Narrow adapter-boundary updates: `scripts/Validate.ps1`, `scripts/ValidateP2a.py`, `scripts/ValidateP2b.py`, `scripts/ValidateP3a.py`, `scripts/ValidateP3b3.py`. Documentation: this report, `P3B-VALIDATION.md`, `DECISIONS.md`, `PLANS.md`; sanitized evidence in `P3B4-EVIDENCE.json`.

Run `pwsh -NoProfile -File scripts/Validate.ps1`, then the six Python validators listed above. In a fresh Test Play server, run `require(game.ServerScriptService.DevelopmentTests.unit["P3b4.spec"])()`; it uses only fake storage. For the existing-profile UI proof, create `P3b4Fixture`, seed `FakeDataStoreAdapter` with its profile at `u:149564436`, and call `PersistentTestService.startExistingEconomyFake(store)` once. After normal client shell startup, run the existing integration `P3b.spec(playerGui)`. Keep that fake proof isolated from the ordinary integration runner to avoid overlapping mounts. All fixtures and runners are excluded from the production mapping. **Do not call `startRealEconomy` or alter its approval flag as part of rerunning these tests.**
