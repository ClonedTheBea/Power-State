# P3b design validation

17 November 2026. **Historical design-phase evidence; superseded approval status is recorded in D113 and P3B-VALIDATION.md. Documentation and offline arithmetic only during that phase.** P3b implementation and schema2 migration remain unapproved. Rowanbridge was not read or changed; no Studio controls, DataStore requests, settings, builds, runtime test runs, commits, pushes or publishing occurred.

## Work delivered

- [Decision proposal](P3B-DECISION-PROPOSAL.md): candidate prices/funding, starter scenarios, exact accounting, insolvency, schema2/cutover migration, replay safety, Bank UI, future 2× compatibility, implementation stages and acceptance matrix.
- [Balance-study results](P3B-BALANCE-STUDY.json): inputs, source checksum, daily scenarios, alternative variable prices, progression benchmarks and exact posted totals/carries. Values are proposals, not approved gameplay.
- [Protected-file manifest](P3B-PRESERVED-SOURCE.json): 217 runtime/test/script/artwork/Rojo-mapping SHA-256 values captured before documentation changes and verified unchanged afterward.
- `PLANS.md`, `README.md`, `DECISIONS.md`, `ECONOMY-AND-REBIRTHS.md` and `DATA-AND-SECURITY.md` now point to the P3b approval gate. Existing P3a evidence and profile identity remain preserved.

## Checks actually performed

1. Read contributor instructions, roadmap, persistence reports/proposal, economy, electricity/minimal simulation and security specifications; inspected current DemandModel and solver representation. Distinguished accepted P2b values from older 0.75 MW/7 MW examples and proposed tariff/growth rules.
2. Reproduced the accepted 1,440-step demand numerically in Python with exact integer midpoint arithmetic: **4,527,479 kW-minutes / 60,000 = 75.4579833333 MWh**, minimum 2.517 MW, peak 3.811 MW. Matched the recorded P2b reference; no change to or execution of Luau.
3. Evaluated prices 120/80/10, alternatives 50/100 variable cost, and full/partial/bottleneck/zero/Off cases. Full service gives analytical net **2,778.319333 Credits/day**. Proposed minor-unit posting gives **277,832 net minor units**, with carries preserved, and final Bank **377,832 minor units** from a 100,000-minor grant.
4. Checked all 60,000 possible variable remainders and 60,000 fixed remainders: maximum next-step expense **667+17=684 minor units**. Checked eight exact meter/price partition cases and the three-step fixed-cost total of 50 minor units.
5. Verified protected-file hashes, local documentation links, proposed/approved decision labels and Git whitespace. Counts/results below record the final documentation pass.
6. Rechecked official Roblox DataStore and versioning/caching documentation to avoid implying callback purity, service durability or platform versions are proven by a local model. References are linked beside claims in the proposal.

## Limits and unresolved approval

No economy module, schema2 validator, migration, live financial state, Shop or purchase mechanism exists as a result of this task. No claim of real economic replay safety, migration safety, device performance or player pacing acceptance. The analysis reproduces a known demand reference but does not replace Luau/Studio regression testing after implementation.

Owner must decide D106–D112, particularly the 1,000-Credit migration grant and the absence of self-recovery at zero. The buffer is usable for operations; it cannot cure insolvency or mint funds. Unbounded healthy savings without construction sinks are an explicit limitation of this narrow proof. Real Rowanbridge migration needs a separate exact-key/preimage authorization after fake tests, even if the design is approved.

Stop after the proposal. No P3c, Shop, R4, climate events or Production action is authorized.

Final documentation pass: **147 local links/anchors**, **217 protected-file hashes**, and **seven pending decision labels (D106–D112)** passed. `git diff --check` passed.
