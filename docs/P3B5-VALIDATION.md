# P3b.5 — Bounded real economy execution

18 November 2026. **Completed successfully; both real economy execution gates are closed again.** The approved Test profile advanced exactly five intervals. No ordinary real-economic heartbeat service, additional real key/store, migration, grant, reset, recovery write, Production change, setting change, upload, publication, commit or push occurred.

Destination: personal creator/account `missawfulname` / `149564436`, Test universe `10776833313`, standard DataStore `PowerStateProfilesP3aTest`, default/global scope, exact key `u:149564436`. Country **Rowanbridge**, ID `55e35a88-e3b9-4f72-9e69-d9024e7730a4`, seed `1441a4d819354af7b306ef8797931e15`.

## Implementation and pre-write gates

- Added `src/server/Domain/BoundedEconomyPlan.luau`: validates the already-migrated released profile, recalculates the permitted intervals with the existing demand/solver/economy code, and gates writes to the exact complete planned country checkpoints. Missing/unexpected starting financial state, skipped checkpoints, extra intervals, mutation on renewal, premature release or changed replay records are refused. No initialization or migration path.
- Added `src/server/Services/BoundedEconomyRunner.luau`: explicit sequential ProfileService acquisition, exact restore, bounded EconomicCountry advancement, validated generator commands, whole-country checkpoints, read verification and release. No Heartbeat stepping or remotes. It waits for confirmation before further steps and stops on terminal/deadline/verification failure; uncertain leases are left to expiry, never force-cleared. Existing lease, fencing, retry, queue, shutdown and billing implementations are unchanged.
- Added `src/server/Services/BoundedEconomyProof.luau`: manual, authenticated running Studio Test server entry; one attempt per Play session. Phase1 allows four intervals; phase2 allows one and requires the SHA-256 of the exact previously released full profile. Existing ordinary persistence proofs must be absent. No client/bootstrap caller exists.
- Updated `Schema2GameplayAdapter.luau`: ordinary `create` remains disabled. A separately approved bounded factory verifies universe, personal creator, actual Player and exact identity/seed; uncached reads and metadata-preserving callbacks remain. It registers only the bounded adapter for ProfileService. `BOUNDED_P3B5_EXECUTION_APPROVED` was enabled for this proof, then restored to false. `REAL_ECONOMY_EXECUTION_APPROVED` remained false throughout.
- Added `tests/unit/P3b5.spec.luau` and `scripts/ValidateP3b5.py`. No client UI, Native renderer, tariffs, grant, buffer, schema, solver, generation or underlying lease arithmetic changed.

Before real execution, the new fake test initially counted two deliberate rejected-replay preflight probes as part of its success-path request total. Moving the count assertion before those probes corrected test instrumentation; no safety threshold or economic rule changed. Two new static type warnings were corrected before execution (diagnostic key conversion and an explicit prepared-result record).

| Pre-write validation | Actual result |
| --- | --- |
| New bounded fake lifecycle | **50 assertions**, clean path plus callback replay, lost response and before-write failure; exact five intervals, seven durable commits, five success-path reads; no real calls |
| Retained P3b.4 / P3a / P3b / P3b.3 | **33 / 178 / 93 / 44** assertions; **398** combined with new suite |
| Local static/build validation | **580 checks**: P3b.5 70, P3b.4 69, P3b.3 57, P3b149, P3a163, P2a34, P2b38 |
| Rojo | Default and Test builds passed before execution, including after bounded-gate enablement |
| Studio Script Analysis | All-script filter, **0 errors, 4 pre-existing R33/R37 artwork warnings, no new warnings** |

Fake-only measurements: P3a maximum checkpoint84,620 bytes, canonical encode p95 7.959ms; P3b full profile89,670 bytes, 8,000 serial settlements p95 0.0317ms, whole candidate step p95 0.448ms. No new physical-device, multiplayer stress or full generation sweep claim: those remain the immediately preceding P3b.4 evidence, with the relevant protected source hashes rechecked.

## Fresh preflight and actual sessions

At **07:15:01.634 UTC**, the guarded uncached read confirmed schema2, profile revision17, country revision124, epoch5, no lease, Bank100000 minor, step113, generator On, activation/cursor113 and all four financial carries zero. Existing openingGrantMinor100000 and zero billed sales/costs matched schema invariants. Actual authenticated Player was `missawfulname` /149564436; creator and Test universe were independently checked in the adapter before access. No historical revision was used instead of this read. Demand and exact expected checkpoints were recalculated from the freshly restored seed/world before acquisition.

Phase1 completed at **07:15:04.104 UTC**. The lease was released and verified by an uncached read before Stop Play. Studio recorded StopPlaySolo at07:15:45.683. A new Play session reconnected the same authenticated account; at **07:17:30.929 UTC**, its fresh uncached preflight matched the **complete canonical released profile SHA-256**, not only the Bank or step. Bank, Off state, physical history, financial carries/cursor and country data were unchanged. Approximately147 seconds elapsed from the first release verification to the reconnect preflight, with no offline progression. This was actual Studio disconnect/reconnect, not a fake session replacement.

Phase2 completed at **07:17:32.397 UTC** after the single remaining On interval, checkpoint, release and final uncached verification. No sixth interval ran.

## Confirmed durable results

| Boundary | Profile revision | Country revision | Epoch | Step/cursor | Generator | Bank Credits | Lease |
| --- | ---: | ---: | ---: | ---: | --- | ---: | --- |
| Fresh preflight | 17 | 124 | 5 | 113 | On | 1,000.00 | Absent |
| Three-On checkpoint | 19 | 127 | 6 | 116 | On | **1,005.74** | Owned |
| Off checkpoint | 20 | 129 | 6 | 117 | Off | **1,005.74** | Owned |
| First release / reconnect preflight | 21 | 129 | 6 | 117 | Off | **1,005.74** | Absent |
| Final On checkpoint | 23 | 131 | 7 | 118 | On | **1,007.66** | Owned |
| Final verified release | **24** | **131** | **7** | **118** | **On** | **1,007.66** | **Absent** |

Acquisitions accounted for revisions18 and22. Country revisions include the five completed steps and two validated generator-control mutations. Acquisition/release did not bill a step or grant money. Session ownership used the unchanged180-second lease and30-second safety margin; both fenced releases were confirmed normally.

Final exact finance:

- Base sales **2496 minor =24.96 Credits**; variable generation expense **1664 minor =16.64 Credits**; fixed On expense **66 minor =0.66 Credits**. Net earned **7.66 Credits**.
- Carries: sales0, bonus0, variable0, fixed **40000/60000 of a minor unit**. No fractional amount was discarded or independently rounded on reconnect.
- Generated/delivered financial meters **12,480 kW-minutes** each, onlineSteps4, effective multiplier1, bonus sales0. Off interval had no sale, variable expense or fixed cost.
- Opening grant remains exactly100000 minor, once only; activationStep113 and activation identity preserved. Last settled step118. No historical-energy billing or offline income.

Exact physical/reliability values from verified records:

| Field | Fresh preflight | Final release |
| --- | ---: | ---: |
| Requested MWh | 5.875999999999989 | 6.135999999999987 |
| Delivered MWh | 5.355999999999993 | 5.563999999999991 |
| History count/index | 113 /113 | 118 /118 |
| Window requested | 5.875999999999989 | 6.135999999999987 |
| Window delivered | 5.355999999999993 | 5.563999999999991 |

Increase:0.260 requested MWh and0.208 delivered MWh, subject to ordinary binary floating-point representation. Whole-country equality checks preserved the earlier history entries and validated all five new entries against deterministic replay; they did not rely on rounded UI totals. Recipe, generator/network/climate/demand versions, infrastructure and country identity were unchanged.

## Actual DataStore operations and latency

Exactly **7 UpdateAsync calls and 5 uncached GetAsync calls**. No application retry, reconciliation read, extra renewal or ambiguous result was needed. All twelve application calls returned successfully. Internal Roblox callback invocation counts were not separately instrumented; these counts are application/service-method observations, not a claim about Roblox internal retries.

| # | Phase / operation | Latency ms |
| --- | --- | ---: |
| 1 | First preflight Read | 212.608 |
| 2 | Acquire | 637.887 |
| 3 | Three-On Checkpoint | 351.202 |
| 4 | Checkpoint Read | 146.770 |
| 5 | Off Checkpoint | 356.795 |
| 6 | Release | 633.518 |
| 7 | Release Read | 148.087 |
| 8 | Reconnect preflight Read | 179.446 |
| 9 | Acquire | 502.824 |
| 10 | Final-On Checkpoint | 337.498 |
| 11 | Release | 316.496 |
| 12 | Final Read | 130.712 |

Read mean163.525ms, range130.712–212.608ms. Update mean448.032ms, range316.496–637.887ms. Minimum observed post-call read/write budgets were685/685; no throttling was reported. These twelve calls do not establish a service latency or availability guarantee.

First released canonical profile: **7,609 bytes**, SHA-256 `c111e12fd45b5ed0c9d612ba31567f32c3f3f40b95324ca38c14635dcee6fc04`. Final released canonical profile: **7,654 bytes**, SHA-256 `dcc3b32a12b48032f4d1f3ac2ea3536da68e7412ea3fbdba12c43a04dd504bd2`. Session tokens/operation IDs and complete profile contents were not exported to ordinary logs. Existing P3b.2 private recovery artefacts were not modified or used to overwrite v2 data.

[Sanitized timestamps, request measurements, balances and source hashes](P3B5-EVIDENCE.json).

## Completion boundary and limitations

Both execution flags are false again. Play was stopped, the temporary fake runner remains disabled, and the normal development test runner was restored. The old ordinary real adapter and real-economic startup remain disabled for schema2; this was a server-only bounded proof, not a rollout or normal playable real Bank UI session. Existing UI/status and Native renderer code were preserved. No additional DataStore read is required to repeat the already successful final verification.

**Isolation limitation:** normal bootstrap still ran the unrelated, nonpersistent P2a/P2b preview simulations during Play. Those use separate in-memory fixtures/generated countries, not Rowanbridge or this DataStore adapter. The ordinary persistent/economic heartbeat service was absent and Rowanbridge advanced only the five verified intervals. However, this does not satisfy a literal requirement that *all* ordinary simulation heartbeat services be stopped during the test. A future dedicated execution harness should disable the nonpersistent bootstrap too; no further real rerun is authorized or necessary to establish the recorded durable result.

Real outage/ambiguous-write/forced-expiry/corruption/competing-writer faults remain fake-tested only; no destructive real test or extra key was used. No proof of cross-server public reconnect or low-end device performance is claimed. Public-release insolvency recovery and ongoing real gameplay remain separate decisions. Stop here; no P3c/R4/R5 authority follows from success.
