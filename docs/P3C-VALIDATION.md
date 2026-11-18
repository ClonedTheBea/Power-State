# P3c — First construction proof validation

18 November 2026. **Fake-storage implementation and available validation complete.** D136 approves pure/fake/Test stages only. No real DataStore calls, Rowanbridge changes, migration, purchase, Production changes, uploads, settings, publishing, commits or pushes. Both real economy gates remain false; ordinary real startup remains disabled.

## Implemented architecture

- `ConstructionProject`: fixed project/price/buffer, rotated reserved route/pad probes, stable terminal/feeder IDs and immutable candidate construction.
- `DistrictSolver`: separate composition v2; retained original GridSolver unchanged. Restricted pinned upstream capacities and maximum3811 kW starter request prove both demands fit; independently solved sink flows are summed and checked against shared physical gates. Unsupported scarcity/topology is rejected instead of selecting a priority. Off/disconnected branch reports preserve unmet demand.
- `ProfileSchema3`, `ProfileMigrations3`, `ProfileLease3`: strict schema3/ledger3, capital spending, exact prior-v2 validation projection, pure empty migration, permanent semantic receipt and fenced Build transition. One-key candidate includes latest energy/financial prefix, debit and assets. No real schema3 adapter exists.
- `ConstructionCountry`: unchanged demand/billing arithmetic with separately preserved capital debit; physical/history/financial candidate updates remain atomic. Avoids constructing complete checkpoint records merely to solve each minute; full schema validation remains at capture/stage/restore/commit boundaries.
- `ProfileService`: fake-only Build entry under the existing four-call/eight-profile queue, critical mutation barrier and uncertain-release protection. Checkpoints cannot overwrite a pending purchase. Existing schema1/2 paths and real capability restrictions retained.
- `ConstructionQuotes`: owner/session/shape/sequence/rate checks;30-second quote, one quote/purchase, server operation IDs, latest affordability and durable-only completion. Closing UI does not cancel a dispatched operation.
- `ConstructionTestService`: explicit Studio/Test10776833313 fake host, capped at eight players, same-session fake reconnect retention, no real-adapter parameter. Subscribed owner-only snapshots; bounded subscription control. Real execution is not reachable through this host.
- `ConstructionClient`: Native map, fixed prospective district slot/preview connection, review/confirm UI, live/confirmed Bank and capital spending, accessible shared controls and server-state presentation. No artwork changes or gameplay beyond the approved district.

Preserved: 120/80/10 rates;1000 opening grant once;250 buffer; existing seed/generator/demand arithmetic; starter IDs/coordinates; source single-sink solver; owned sector;180-second lease/30-second safety margin; all real gates. Schema3 migration adds no new demand until the first durable Build.

## Issues found and corrections

1. The first command-bar attempt used a previously cached ProfileService module without the new Build API. Fresh Play resolved that environment issue; it was not a passing test.
2. Four previously reported artwork warnings were traced to the generated/native terrain collection type union. Typed empty collections, explicit array iteration and the Patch annotation resolve them without removing assertions.
3. R33 retained full-sprite culling failed because MapView cached the Native callback before Hybrid attachment. Draw now obtains the current callback. The unchanged assertion subsequently passed with739 synthetic assertions; Native remains default.
4. The first construction GUI test destroyed its shell before the next retained GUI suite's WaitForChild. Its cleanup now remounts the baseline shell; the subsequent retained suite proceeded normally.
5. Continued lifecycle observation found owner snapshots filling Roblox's invocation queue after the construction view disconnected. Added explicit subscribe/unsubscribe handling, bounded subscription retry and unconditional idempotent unsubscribe. Panel dismissal is not unsubscribe and does not cancel transactions. The rapid remount regression retains the server subscription rate limit.
6. Visual inspection caught a fixture Bank value in the short-screen header and a misleading post-purchase subtraction on an already-built project. The proof now presents current authoritative compact metrics and a paid-once message; the inspector has a shorter summary and visible review action.
7. Manual mobile review found that automatic canvas sizing did not expose the lower live financial text (canvas and viewport both224px). The isolated construction view now measures the complete string to size its label and canvas and disconnects that listener on unmount. A mobile overflow/reachability/full-text-fit regression was added rather than relying only on control dimensions. The first TextBounds attempt exposed only8px; full-string measurement subsequently passed and mouse scrolling reached the capital row.

## Completed validation evidence

| Check | Actual observation |
| --- | --- |
| Construction pure/fake |94 assertions passed in fresh Play; callback replay, pre-write failure, committed response loss, later receipt supersession, release/restore, affordability and full-day solver fixture |
| Additional safety |31 assertions passed: quote/epoch/owner/expiry/forged-price checks,8-profile admission,4-call bound, uncertain committed purchase preserved through timeout/close/late callback |
| GUI |Final fresh run:50 engine assertions at08:46:14 UTC; desktop/tablet/mobile/landscape,44px controls, earned affordability, menu progression, closed-panel durable build, repeat prevention, camera/selection/Locate, full Bank overflow and unsubscribe/rapid remount;362 map descendants. Earlier38/40/42/43/47/49 runs are superseded by the final coverage. |
| Retained fake persistence/economy |P3a178, P3b93, P3b.3 44, P3b.4 33, P3b.5 50; no real service calls |
| Retained scheduler |P2b.1 49 assertions;8 synthetic jobs869.458ms /51 Heartbeats |
| Generated world + construction sites |10,000/10,000 distinct terrain fingerprints,0 fallbacks; all route/pad probes, all4 rotations and explicit safe fallback; retained P2b2,916,780 assertions; generation CPU p95 15.715ms versus100ms gate |
| Retained client |P2a57/P2b88 GUI;32+32 remote assertions; R2 GUI348, R1 16, R2 interaction135, R3 190, R3.1 52, R3.3 739, R3.5 217 |
| Full-day built accounting |1,440 billed intervals with12 exact checkpoint/restores;5,659,536 delivered kW-min;353,303 minor-unit operating net; opening grant and100,000 minor-unit capital debit each occur once. Full-ring profile92,283 bytes; final fresh run1.123s. |
| Retained Bank integration |83 assertions passed; authoritative progression waits1.3470/0.7990/0.7990/0.7828s within the approved3s bound. The first exceeds the old1.2s reference and remains observable. |
| Retained real-art proof |R37:1,409 assertions including labeled synthetic failures; actual existing textures and600.7-second/530-cycle soak,595 map descendants. No upload or asset change. |
| Local checks |Both Rojo builds; retained static scripts583 checks; P3c176 static/build checks. No tests removed to pass. |

Final fresh Play reran construction94, safety31, full-day accounting and50 GUI checks. Both builds and all759 static assertions passed on the final source. Script Analysis was inspected with current-script filtering off:0 errors,0 warnings. The four reported artwork warnings are resolved. The temporarily disabled client test runner was restored to Enabled after stopping Play; both real economy flags remain false. No unresolved automated failure remains in the completed runs; incomplete/manual coverage is listed below.

## Measurements and interpretation

- Pure fake fixture profile18,476 bytes. Two-sink solve p50 0.0675ms / p95 0.1225ms over1,440 steps in Studio desktop. Single-source gates remain unchanged; this is not physical mobile performance.
- Eight cloned fake-profile workloads committed through the shared coordinator in493.299ms aggregate measured CPU/wall execution of synchronous test operations; maximum encoded profile18,473 bytes, peak4 in-flight calls. This is not DataStore latency or eight real networked clients.
- Heap delta−506KiB was GC-sensitive and is not peak memory or a negative allocation claim. Structural admission/queue/history/receipt limits are asserted separately.
- Fault-clock suspension total1.10s across four synthetic scenarios is injected-clock evidence, not measured Roblox service latency. Live Test GUI uses actual engine scheduling with fake storage.
- No real service memory/latency/durability measurements are claimed for construction. Prior P3b.5 measurements remain historical schema2 evidence.

## Limits of this evidence

The eight-country measurement uses eight fake profile workloads, not eight actual Studio clients. UI assertions exercise shared action bindings and safe-root geometry in the engine; physical touch and gamepad testing remains outstanding. Actual mouse opening of the mobile inspector, saved review and Bank was inspected. Escape dismisses the review and also opens Roblox's core menu; a second Escape returns to the game. Desktop Studio is not evidence of low-end mobile performance. Heap deltas are not peak memory. Fake commit timings do not predict real service suspension or request latency.

Mobile presentation uses the existing expandable inspector: expand or scroll to reach lower actions. Long Bank/review details require scrolling. The compact header may truncate its combined summary; KPI cards retain separate values. The disabled built-project confirmation retains its price caption, while the state and paid-once text identify it as already built. These are presentation limits, not permission for another purchase or final device/visual acceptance.

The retained R37 ten-minute soak completed. R34's subsequent benchmark began but its complete suite/soak was not rerun to completion during this task; neither a new complete native endurance run nor a new full P2b endurance run is claimed. Existing historical reports remain separate evidence. No real construction recovery or service guarantee follows from fake tests.

## Files in this implementation

New runtime modules: `src/server/Domain/{ConstructionProject,ConstructionCountry,ProfileSchema3,ProfileMigrations3,ProfileLease3}.luau`, `src/server/Simulation/DistrictSolver.luau`, `src/server/Services/{ConstructionQuotes,ConstructionTestService}.luau`, `src/client/Simulation/ConstructionClient.luau`.

Changed runtime modules: `src/server/Services/ProfileService.luau`, `src/client/Views/Map/GeneratedTerrain.luau`, `src/client/Views/MapView.luau`. The latter two address retained artwork diagnostics/culling, not new artwork.

New tests: `tests/unit/{P3c,P3cSafety,P3cAccounting,P3cWorld,P3cRegression}.spec.luau`, `tests/integration/P3c.spec.luau`, `scripts/ValidateP3c.py`. Updated test runners, optional construction hook in `P2bWorld.spec`, typed iteration in `R33.spec`/`R37.spec`, and the remote allowlist in `scripts/Validate.ps1`. Documentation: roadmap, decision register, proposal status and this report. Other pre-existing working-tree changes belong to earlier phases and were preserved.

## Reproduction and boundaries

Use only **Power States - Test**, universe10776833313, connected to `test.project.json` on Rojo34873. Normal production mapping has no test runners and normal startup does not call the construction host. Test server runner executes pure/fake P3c suites then starts the explicit fake host. The client runner checks construction after existing P2a/P2b remote tests; it waits for genuinely earned Credits rather than granting extra money. Later retained presentation suites continue.

Server-only manual regression entry in the Test Play server: `require(game.ServerScriptService.DevelopmentTests.unit["P3cRegression.spec"])()`. This is fake/local only and includes the10,000-seed sweep; do not run it as a client. Construction is1000 Credits and requires1250 Bank, so a fresh fake country needs roughly two active minutes. Stop Play discards fake storage; same-server player reconnect should retain the fake profile through the lease coordinator.

For manual GUI review after automated suites, mount `Client.Simulation.ConstructionClient` from the Test client with its PlayerGui. Select the surveyed district or an existing asset, choose Review connection, inspect price/buffer and confirm. Close/reopen during Saving; only a confirmed result becomes built. Inspect Bank separately for live/confirmed values and construction spending. Use keyboard/gamepad focus and touch-device emulation; physical devices/controllers remain separately testable.

## Future real migration preparation — not authorized

Next possible task is read-only schema3 readiness: explicitly authorize exact Test/account/store/global/key, fresh uncached head/owner/lease verification, secure reviewed preimage/checksum and field-level v2→v3 diff. Preserve Rowanbridge identity, energy, cursor/carries, Bank and single opening grant. No construction occurs in migration. Migration execution requires another approval; a later bounded real purchase requires a separate approval after migrated state is verified. Never reuse historical revision24/Bank1007.66 as a fresh preflight. A future real harness must isolate unrelated preview heartbeats as noted in P3b.5.

No public insolvency recovery, general construction, land, planning, growth, storage, multi-generator dispatch, R4/R5, entitlement or Production rollout is included.

## Screenshots and machine-readable evidence

- [Desktop saved district](p3c-screenshots/desktop-built.jpg): actual Studio Native view, selected district and live metrics.
- [Mobile saved project review](p3c-screenshots/mobile-saved-review.jpg):360×580 safe root, already-built state and paid-once explanation.
- [Mobile Bank capital row](p3c-screenshots/mobile-bank-capital.jpg): final full-text correction, mouse-scrolled to construction spending; the floating Studio debugger is an editor panel, not game UI.
- [Sanitized pass logs and source hashes](P3C-EVIDENCE.json). Screenshot values differ because simulation continued normally between captures. Earlier mobile-bank.jpg records the pre-correction top portion; use mobile-bank-capital.jpg for the final overflow evidence.

Stop: fake-storage scope complete. Recommend owner visual/device review, then a separately authorized read-only schema3 migration-readiness task. Do not enable real economy or treat this as migration/purchase approval.
