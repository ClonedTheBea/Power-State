# National Fleet Expansion v1 — fake-storage validation

20 November 2026. **D242 continuation: fake-storage implementation and available Test validation complete; owner gameplay/device review pending.** Schema4 cutover and full-size gates pass; atomic owned wind construction, scheduled dispatch, accounting, responsive controls and fake reconnect are implemented. The final fresh journey passes90 assertions, repeated post-reconnect GUI61 and lifecycle18. No real readiness/migration/purchase is authorised. See the final closeout below.

## Historical D241 stop — superseded by explicit D242 approval

**Stopped before schema-v4 implementation at a material W5 schema issue.** W1–W7 are owner-approved for pure/fake Test work; this is not a completed wind-construction milestone. No real DataStore, Rowanbridge read/write, Production, publishing, settings, artwork, commit or push operation occurred. No Organic investigation resumed. Native/default and existing comparison modes are unchanged.

## Historical Stage A implemented scope

- `src/server/Domain/WindProject.luau`: immutable project constants and pure surveyed-site/assets/route description. Project `starter-wind-v1`, price400,000 minor units, buffer25,000,2,000kW generator and connection. No purchase method, service startup or client interface is attached.
- `tests/unit/WindSite.spec.luau`: actual generated-world site gate, retained full P2b sweep, all four reservation rotations, malformed versions/ownership/network rejection and input immutability.
- `tests/unit/WindGateRunner.luau`: explicitly invoked Studio/Test/creator guard. No automatic runner attribute or startup path added.
- `tests/unit/WindMigrationReadiness.spec.luau`: pure synthetic reproduction of the W5 baseline problem, exact cutover reconstruction check and full-history size observation. It does not define or save schema4.
- This report, roadmap, decision register, proposal approval annotation and `docs/evidence/national-fleet-expansion-v1/`.

StageA's geometry gate passed. Full purchase eligibility/quotes, schema4/ledger4, normal-country fleet dispatch, atomic wind transaction and UI remain unimplemented because of the following approval gate. The project descriptor alone does not constitute authorisation or validation of a purchase.

## Exact surveyed-site evidence

Authenticated Studio user149564436, Test universe10776833313 and creator149564436 were verified immediately before the pure tests. No real/Execution/Organic boolean gate was enabled. Tests ran in stopped Studio edit mode against synced Luau modules, with no player heartbeat or real service adapter. These are actual Luau execution results, not local Python approximations or hosted multiplayer tests.

The site is local(320,704), rotated using the saved `StarterValidator.layout` choice. The fixed route is wind→(320,512)→(512,512), length384WU, one logical edge to the substation. Its bend coincides with the existing gas pad and its second segment shares the existing corridor, as explicitly documented in W3; it does not create a gas junction or extra logical node. The wind pad itself is disjoint from all starter and district pads. There is no relocation, terrain flattening, electrical endpoint change or seed reroll.

For each accepted saved seed, validate original network equality, owned sector0,0, pinned versions/candidate/fallback, nine pad probes and fourteen route probes (32WU spacing, shared bend checked twice). Elevation remains exactly40m; pad samples have zero slope. Independently evaluate those23 probes under all four reservation rotations for each of the10,000 seeds, without changing any saved layout. The actual generated orientations occur2,482/2,460/2,589/2,469 times.

Results at10:53:15UTC:

- Wind-site suite: **930,005 checks passed** (10,000 actual sites,920,000 additional seed/rotation probes and five negative cases).
- Retained P2b world suite: **2,916,780 assertions passed**;10,000 distinct starts, zero fallback selections in this corpus, retained safe-template tests, climate/demand/conservation and shared-boundary tests.
- Generation CPU p95:16.589ms; maximum encoded active descriptor43,705 bytes;2,667 samples/start. Eight-descriptor heap observation767.50KiB/country includes allocator/GC noise. Demand step p95 0.0347ms, eight-country demand batch p95 0.2562ms. These do not measure the future two-source scheduler or schema4.

The final source adjustment clones the complete saved layout before changing the test-only rotation, instead of passing a partial typed record. It preserves exactly the same rotation/weight arithmetic; the full sweep count above predates that type-only adjustment. Final builds and Script Analysis cover the adjusted source.

## W5 incompatibility reproduced

The reviewed exact fleet baseline is:

```text
baseline = {legacyEconomy, legacyBank, legacyConstruction, migrationOperationId}
```

The same specification requires future full v4 validation to verify this immutable legacy baseline through the **unchanged schema3 projection**. The existing schema3→schema2→economy validation binds financial cursor, energy meters, online counts and reliability history to `country.simulation`.

The pure test uses the pre-existing explicitly synthetic `P3b4Fixture`, migrated to schema3 in memory. It is not a read/copy of the real Rowanbridge profile, even though that fixture deliberately reuses known identity strings.

1. Validate cutover step113 and retain canonical profile bytes.
2. Copy the four approved baseline fields.
3. Advance one legitimate existing single-source interval to114 using unchanged demand and billing.
4. Reconstruct the legacy projection using the frozen baseline and current simulation.
5. Unchanged validation rejects at `Economy:45: Settlement cursor`.
6. Supply a local-only copy of the original cutover simulation: unchanged schema3 validation passes and the entire projected country is canonically identical to the original. Original input bytes remain unchanged.

This reproduced twice. The second run also advanced1,440 further ordinary synthetic intervals and validated the resulting full history ring. After enough intervals, current history overwrites old entries; baseline economy totals cannot reconstruct the original ordered reliability ring or historical On state. Replacing the old cursor, inventing history or weakening the previous validator would not preserve the approved baseline guarantee.

This is a **specification completeness issue**, not a demonstrated fault in the existing schema3 validator. A new validator could adopt a weaker baseline-only invariant instead, but that would change the approved validation contract and also requires owner review.

## Proposed minimal amendment — requires approval

Add exactly one mandatory immutable field:

```text
country.fleet.baseline.legacySimulation = canonical deep copy of
                                        country.simulation at v3→v4 cutover
```

It retains simulationVersion, step, online state, cumulative requested/delivered energy, the bounded history ring, index and window totals. Its step must equal `fleet.cutoverStep` and the frozen legacy financial cursor. It never advances. All other approved fields, versions, prices, carries, seed adapter, receipt rules and live simulation remain as specified.

Future validation would reconstruct the exact legacy country from unchanged recipe/network/settlement/ownership plus baseline Bank/economy/construction/**simulation**. Original district deltas can be reconstructed from the existing fixed project contract and frozen permanent receipt; later wind deltas are excluded from that legacy projection. Validate through unchanged schema3 first, then validate the separate live fleet arithmetic and transitions. Checkpoint/renew/release/build must not mutate the frozen baseline. No restore-to-baseline operation is implied.

Measured canonical sizes:

| Synthetic observation | Bytes |
|---|---:|
|Original step113 profile|7,436|
|Four-field approved baseline, preview marker|970|
|Proposed step113 simulation copy|4,511|
|Full1,440-entry simulation record at step1554|89,092|
|Full-history schema3 country at step1554|96,305|

The extra history is materially larger than the scalar metadata in the proposal. These component sizes are not a measured final schema4 profile or proof over all possible serialized numbers. Preserve192KiB warning/256KiB hard limits; after approval, test complete v4 profiles at full history, both receipts, maximal statements and supported numeric ranges before accepting migration. If the hard cap fails, stop rather than truncate history or silently change limits. No baseline copy was persisted.

## Validation and remaining work

Both Rojo builds, source mapping, existing boundary/security checks and Git whitespace passed. Full-project Script Analysis with current-script filtering off shows **0 errors,3 warnings**, all pre-existing in diagnostic-only Organic modules: OrganicCoast23:13 and OrganicRibbon14:50/14:82. They remain untouched under the explicit no-Organic-work restriction. One new readiness-test return-count warning was corrected; no new Fleet warning remains. [Analysis screenshot](evidence/national-fleet-expansion-v1/script-analysis.jpg).

[Timestamped actual Luau output](evidence/national-fleet-expansion-v1/stage-a-studio.txt) and [schema counterexample/size records](evidence/national-fleet-expansion-v1/schema-gate.json) retain the evidence. Builds do not substitute for runtime tests.

No schema4 migration, purchase, two-source financial settlement, security remote, normal player journey, GUI screenshot, balance replay or new solve/replication/instance performance result is claimed. Those are dependent stages, not omitted passing tests. Existing Operations and First Playable regressions are preserved but have not all been rerun in this stopped sprint. No extra Credits or Training generators were introduced.

The earlier4,000-Credit progression/payback calculations remain design estimates pending actual fleet replay and gameplay-feel assessment. No price change is proposed by this gate.

## Owner decision and continuation

Approve or reject the single `baseline.legacySimulation` addition above. The user's development-authority boundary explicitly requires stopping if **“The approved schema-v4 contract requires a material change.”** The additional persisted history and its size impact meet that boundary; no approval is inferred from the general implementation authorisation.

After approval, resume schema4 implementation and the remaining internal gates under the existing fake-only authorisation. Keep all real readiness/migration/purchase gates separate. Studio remains in edit mode, no automatic runner was enabled, and Native remains the default.


## D242 continuation — chronological evidence, 20 November2026

Owner approves exactly `fleet.baseline.legacySimulation`; the preceding D241 stop is historical. Pure migration and schema4 modules now capture the complete canonical simulation, reconstruct the exact original country through unchanged schema3, reject changed cutover/carry/Bank/history, and preserve separate live/frozen history tables. No runtime migration or real store is enabled.

Initial actual Studio edit-mode Luau results (synthetic fixtures, not real Rowanbridge):

| Complete profile | Canonical bytes |
|---|---:|
| Newly migrated empty starter, step113 |13,397|
| District, both full history rings, step3414 |179,066|
| Both receipts and constructed wind, step3414 |180,105|
| Additional1,441 actual two-source solver intervals |176,953|
| Supported high-number fixture, two full rings/25 statements each |211,900|
| Same high-number fixture with both investments |212,969|
| Same fixture after100 actual two-source intervals |211,983|

The high-number fixture is algebraic supported-range storage stress near step1e9, not a claim to have replayed a billion minutes. Full historical electricity and finance validate through schema3 before migration. The largest observed record exceeds192KiB and retains that warning; it leaves49,175 bytes under256KiB. Reserving24 encoded characters for every numeric scalar and1,024 bytes for bounded identity/name variation produces a247,483-byte structural envelope (14,661-byte hard-limit headroom). This supports the fixed two-source scope only. No history truncation, compression, raised bound or second key is introduced.

The size suite reports6,348 checks, mostly scalar-width coverage, and repeats its pure1,441-step post-wind solver/billing replay. Eighty-five fake transaction assertions pass including exact debit, node/line count, quote expiry/refresh, retained buffer, BeforeWrite/AfterWrite/CallbackReplay, no billing during Build, receipt survival after checkpoint, reconnect without offline revenue, stale ownership and basic control admission. Further adversarial, full coordinator, GUI and retained regressions are pending.

The first eight-country synthetic measurement exposed74.92ms admission and127.96–139.61ms installation callbacks, despite1.09–1.14ms solver CPU. Corrected code reuses a proof only for a deeply frozen baseline with an identical canonical geography signature, avoids redundant state copies and installs at most one country per callback. Mutable/loaded profiles still take the complete unchanged schema3 path; this is not relaxed validation. Repeated measurement:0.59–0.75ms admission,3.26–3.56ms peak callbacks,1.11–1.33ms solver CPU and237.91–348.95ms completion for eight countries at requested60/30Hz yields. These are edit-mode synthetic scheduler results, not actual player/device/frame acceptance. Full ProfileService staging cost and actual Test Play remain to be measured.

Prepared but not yet accepted: schema4 lease and fake BuildWind path, immutable country/financial composition, Test-host flag, quote/control transport and responsive owned-wind presentation. `NationalFleetProof` remains absent/default-off. Normal Native renderer and all real execution boundaries remain unchanged. Do not infer completed sprint acceptance from these intermediate results.

### Integration inventory and measured scheduling scope

New domain modules: `CountryFleetSeed`, `ProfileMigrations4`, `ProfileSchema4`, `ProfileLease4`, `FleetRecord`, `FleetStatements`, `FleetEconomy`, `CountryFleetNetwork`, `CountryFleetForecast`, `FleetCountry`, and the extended `WindProject`. New services: `CountryFleetBatch` and `FleetControls`. Existing `ProfileService`, `ConstructionQuotes` and the fake-only `ConstructionTestService` provide fenced whole-profile BuildWind, one live cross-project quote, ownership/control admission, scheduled results and snapshots. No schema4 real adapter exists. Schema1/2/3, their migrations, approved solver kernels, terrain arithmetic and prices remain unchanged.

Client integration adds `OwnedFleetPresentation`, extends ConstructionClient, InfrastructureDirectory, PlayablePresentation, BankPresentation and ProjectCategories, and lets MapView render two cosmetic route segments for one electrical edge. ShellTypes carries optional cosmetic segment points. FeedbackView clears the fleet modal marker on reuse. Native remains default; no terrain artwork was changed by this sprint. The directory has five bounded rows for the five owned assets. Map controls use existing markers, focus/actions and44px targets.

Test inventory: FleetSchemaSize, FleetCodec/FleetCodecBaseline, OwnedFleetAccounting, FleetTransactions, OwnedFleetSecurity, OwnedFleetCancellation, OwnedFleetPerformance, OwnedFleetBalance, the opt-in OwnedFleetRun, and OwnedFleet GUI journey. OwnedFleetFundJourney is an explicit fake-only diagnostic helper for bounded genuine electricity earnings, not automatic startup or a grant. FirstPlayableLifecycle also supports the new fake schema through the host-selected country/control modules, preserving the original legacy path.

The full coordinator probe exposed costs omitted by the initial pure installation sample above. At11:53 Studio Play, requested60/30Hz: peak callbacks22.947/26.359ms; aggregate admission/solver/installation/staging CPU167.685/168.754ms; elapsed354.945/479.553ms. Solver peaks0.936/0.986ms and solver aggregate1.197/1.311ms. These are not whole-frame4ms results. The approved [v1.1 contract](NATIONAL-GRID-OPERATIONS-V11-VALIDATION.md) explicitly scopes4ms/80ms to solver work, with preparation/checkpoint costs measured separately. The750ms result deadline remains unchanged. Profile staging is a material latency limitation before hosted eight-player rollout; no claim of smooth low-end hardware follows from solver compliance.

Repeated canonical scalar encoding was reduced with a per-call bounded cache in ProfileCodec. The retained original encoder comparison passes14 assertions, including exact signed-zero/escaped-string bytes and unchanged malformed/cycle/depth/node/size rejection. Scalar calls for the full built fixture drop12,821→1,185. The size suite's assertion counter consequently drops6,348→227 because its scalar-width callback is invoked once per distinct scalar, while every emitted occurrence still contributes to encoded bytes and traversal limits. The size envelope and thresholds are unchanged.

Corrections found during integration: a nonexistent feedback title member caused the first Play's GUI refresh error; fixed without changing geometry. Public customer ordering now follows town then district rather than lexical ID order. A same-session committed purchase preserves command sequence/rate admission and advances control revision, preventing replay of pre-build control intents. Valid but unaffordable control intents consume their rate token. Forecasts are bounded five-point capacity outlooks under current controls, not predicted routed delivery or payable energy. All require the final fresh-run checks below before acceptance.

Retained server suites completed in actual Test Play at12:02–12:08: P3a/P3b/P3b3–5 persistence/economy, P2b scheduling/accounting, P3c accounting and10,000-seed routes/pads, Operations encoding/atomic/scenario/security/lifecycle, exact solver/oracle/yield/scheduler. All63 retained eight-country scheduling intervals were exercised; native/30Hz passed,12 countries safely suspended in deliberately unsupported15Hz cases. Three existing Organic Script Analysis warnings remain separate and untouched. Final owned journey, new cancellation/security/day replay and final diagnostics are still pending at this intermediate entry.

## Fresh Test Play results — 20 November2026,12:19 onward

The approved Test universe10776833313, creator/account149564436 and default-off real gates were checked before Play. This run creates the normal fake country **Elmstead**, not the real Rowanbridge record. `NationalFleetProof` and `RunOwnedFleetTests` were explicitly enabled in the local edit session only. The checked-in defaults remain off. No real adapter, read, write, permission change, asset upload or Production operation occurred.

| New engine suite | Result |
|---|---|
| Complete schema4 migration/size |227 assertions; original country reconstruction, independent histories, cutover/carry rejection and full-profile envelope pass |
| Canonical encoder equivalence |14; exact bytes and existing malformed/size/traversal rejection |
| Per-unit accounting |138; twelve On/Off/cap combinations, conservation, deterministic settlement, legacy equivalence and immutable baseline |
| Fake construction transactions |85; expiry/refresh, one debit/node/edge, critical suspension, BeforeWrite/AfterWrite/callback replay, checkpoint/reconnect and AlreadyBuilt |
| Owned controls/security |69; malformed/foreign/stale/replayed/rate-limited intents and unchanged finances on controls |
| Scheduled cancellation |36; owner/state replacement, close, operation/deadline failure, bounded admission and no stale installation |
| Four full-day actual-solver replays |5,766; each1440 intervals with exact per-unit and national accounting |
| Normal district GUI/actual remote checks |34/12 before the wind journey |
| Post-purchase GUI |56; responsive targets, actual engine focus after paging, caps/On/Off, directory, remount, private-field exclusion, completed purchase |
| Normal fake host disconnect/reconnect |18; AfterWrite and BeforeWrite, exact full-country restoration, fresh epoch, old controls rejected and permanent district receipt retained |

The original wind GUI journey reached a real30-second quote expiry, refreshed it, advanced ordinary production while menus stayed open, confirmed through bound GUI actions and submitted a double-click. Exactly400,000 minor capital was recorded with the buffer retained. It then failed an incorrect test assumption that a clipped portrait inspector control was immediately focusable. Diagnostics showed the control atY684 was clipped; paging moved it toY434 and real `GuiService.SelectedObject` selected it. The corrected test uses existing inspector expansion/paging and real engine focus; no target size, runtime focus rule or threshold was weakened. A post-purchase resume avoids a second purchase or resetting funds. The run is reported as completed across that corrected resume, not a single uninterrupted full-suite pass. Loading an older copied StarterPlayer test once repeated the unbuilt precondition; directly loading the current test source corrected that harness mismatch.

Funding used1,463 genuine approved single/two-sink intervals, step314→1777, Bank653.78→4,251.49 Credits, with fake checkpoints. The helper took18.934s because it deliberately accelerates pure intervals; this is **not** ordinary wall-clock progression. No grant, manufactured Bank or Training asset supplied the wind funds. Normal simulation continued before the actual later GUI purchase. Turning gas Off produced visible unmet demand; turning it back On restored full service. Wind cap1900/2000 and Off/On were accepted by the server. The new map uses379/600 descendants and the measured public snapshot is54,937 JSON bytes, below the unchanged262,144-byte bound; this is not a network bandwidth or eight-client device benchmark.

[Actual desktop view](evidence/national-fleet-expansion-v1/owned-wind-desktop.png) and [portrait control view](evidence/national-fleet-expansion-v1/owned-wind-portrait.png) are Studio captures. The portrait capture is a resized safe root, not a physical phone, and shows a transient stale-update banner during the diagnostic/remount sequence. Do not infer sustained subscription acceptance from a still image. Bound actions and engine focus do not establish physical swipe/gamepad acceptance. The approved existing generator symbol is reused for wind; terrain is unchanged.

### Final eight-country synthetic coordinator measurement

| Requested yield rate | Solver peak / aggregate CPU | Peak full callback / staging-install | Whole batch CPU | Elapsed |
|---|---:|---:|---:|---:|
|60Hz|1.0252 /1.3145ms|24.0931 /24.0814ms|169.9849ms|367.3567ms|
|30Hz|0.9281 /1.1999ms|22.4785 /21.5489ms|161.1011ms|484.3518ms|

Each installed eight valid countries, bounded queue8, zero retained solver jobs, coordinator peak one in-flight operation. Cleanup leaves zero profiles/jobs. Shared Studio Lua-heap delta was+34,924KiB; GC and other session work were not isolated, so this is neither a proven leak nor a peak-memory bound. The retained4ms/80ms solver and750ms deadline pass. Full canonical staging still causes22–24ms callbacks; hosted eight-player frame smoothness and physical device performance remain outstanding. A subsequent normal fake-host observation advanced2509→2514 in five seconds, Live, one profile, zero in-flight, peak one; fake autosaves continued.

### Exact full-day economics

Reference full-history fixture, same phase/seed and delivered demand, real solver plus ledger,1440 intervals each. Values below are Credits (source evidence uses integer minor units).

| Operating mode | Sales | Gas variable costs | Total On costs | Operating net |
|---|---:|---:|---:|---:|
|Wind Off|11,319.07|7,546.05|240.00|3,533.02|
|Normal wind|11,319.07|5,864.93|384.00|5,070.14|
|Wind capped500kW|11,319.07|6,642.04|384.00|4,293.03|
|Wind disconnected but On|11,319.07|7,546.05|384.00|3,389.02|

Normal wind displaces21.0139MWh gas in this day, saves1,681.12 variable Credits, costs144 extra fixed Credits and improves net1,537.12 Credits. Extrapolating this one day gives62.45 simulated hours to recover4,000; this is not guaranteed payback. Sales do not increase because gas already serves all demand. Disconnected wind earns nothing and still costs6/hour On. Cap500 sacrifices savings. The earlier32-seed analytical design results remain a different sample, not contradicted by this actual-solver fixture. Preserve price/rates; the meaningful decision is fuel savings versus variable availability and reliable gas backup. No storage, export, new demand or frequency model is implied.

### Outstanding closeout checks

The retained R37 and R34 real-art ten-minute suites completed in the preceding fresh Play. A Native soak started in that session but was intentionally stopped for the final source reload; it is not counted as a pass. Fresh full Native and P2b ten-minute suites are now running. Final sustained remount progression, fresh progression/availability observations, final full-project Script Analysis and final local checks are recorded below when complete.

### Progression and calm-wind follow-up

`OwnedFleetProgression.spec` creates three fresh synthetic countries through the original initialization/grant and pure v3/v4 migrations. Seeds `df307a52185f423288df5749229f0808`, all-zero and all-f produce the same protected17°C demand progression: district at step131, wind eligibility at step1751,1,620 intervals between investments, Bank4,250.07→250.07 Credits at the wind purchase. Electricity alone supplies the funds; exactly the original1,000-Credit grant and1,000+4,000 capital debits remain. An initial test incorrectly compared total spending (which includes operating costs) with capital only; corrected to the two explicit capital categories, with no runtime or price change. Full schema validation passes after each project.

At one simulated minute per real second this is2m11s to the district, then27 minutes to wind, before delays and player actions. The pure accelerated measurement is not an owner-operated27-minute playtest. That long gap has few useful interventions while gas serves all demand; do not call pacing accepted. Retain the approved4,000 price for owner review. A possible later2,000-Credit price would roughly halve that earning gap and payback, but is a **proposal only**, would alter the approved economy and must not be implemented without approval. Prefer reviewing the current loop before changing it or adding unrelated engagement systems.

The exact daily availability replay observed24–1,572kW, with nine intervals below75kW.75kW is the instantaneous fuel-saving break-even threshold from6 Credits/hour divided by80 Credits/MWh; below it, an On wind unit can temporarily cost more than displaced gas fuel. Normal operation used all available wind in this uncongested fixture. Cap500 left582,830kW-minutes unused (9.713833MWh); disconnection left1,260,834kW-minutes unused (21.0139MWh). No unused potential was billed. These observations do not alter the seed/kernel or guarantee a minimum wind output.

### Diagnostic launcher lifetime correction

The initial post-purchase GUI launcher called `script:Destroy()` after mounting the final GUI. Its event callbacks then stopped, producing the captured stale banner. Likewise the temporary lifecycle launcher started GeneratedService and immediately destroyed itself; diagnostic inspection showed `ready=false,pending=true,timing=nil`, because the generation heartbeat had lost its owning launcher. This was a test-launcher lifecycle defect, not demonstrated country/accounting loss. The corrected launchers remain alive for the service/mounted GUI lifetime. A new preview-only service completed generation in102.03ms wall /16.95ms generation CPU, with20 yields; no watchdog or startup deadline changed. The failed P2b snapshot attempt is retained, and its600-second soak is rerun from the beginning.

The corrected P2b soak passed600.1s/590 cycles/345 map descendants. Its subsequent owned-GUI remount uncovered a **separate real transport defect**; launcher lifetime was not the full explanation. There was exactly one construction remote folder. The new mount accepted an old queued snapshot at step2373/revision2386, then rejected actual server snapshots at step3879–3883/revision3892–3896 because their session epoch differed. The normal server had continued correctly and passed its host soak; client controls became unavailable. The failure was retained rather than relaxing the five-second acknowledgement deadline.

ConstructionClient now creates a fresh36-character subscription identifier per mount, includes it in Subscribe/Unsubscribe, and accepts only the matching server echo before applying existing epoch/revision ordering. ConstructionTestService validates the exact three-field transport shape and bounded GUID syntax, stores only the current identifier, echoes it on snapshots/loading replies and ignores an older mount's Unsubscribe. Existing ownership, rate limits, lease and financial state are unchanged; this identifier is correlation, **not authorization or a persisted field**. No schema amendment is introduced. The owned GUI regression now requires a different acknowledged identifier after remount, three further authoritative steps, and continued progression after a stale unsubscribe. The final fresh journey below validates the changed transport; earlier subscription-based GUI passes are retained as historical evidence.

The fresh Native soak completed600.5s/590 resize-pan cycles with1,069 shell descendants stable. This is the retained placeholder shell count, not the379-descendant owned map. A separate opt-in `OwnedFleetHostSoak.spec` measures600 seconds of the actual normal fake host alongside retained UI tests, checking immutable baseline/receipt, one grant/capital charge, cursor progression, country size and bounded coordinator state. No real service is used by either soak.

Local source audit passes31 checks: unchanged legacy schemas/leases, solver, wind kernel, climate/demand/terrain; no real adapter calls in new domain modules; Production manifest excludes diagnostics; fake host/client retain Test guards. Existing FirstPlayable33, P3c178 and P3c3 95 static checks pass. [Audit](evidence/national-fleet-expansion-v1/source-audit.json). Four temporary strict-type warnings in a new malformed-payload test table were corrected by explicitly declaring its heterogeneous test inputs; no runtime changes were needed. Final edit-mode Analysis remains the authoritative diagnostic count.

Owned-host endurance passes600.012s/590 observations, step2901→3495, unchanged baseline and permanent receipt, one original grant/one wind debit, exact financial cursor and bounded coordinator. Maximum canonical **country** bytes89,999 (not the whole-profile worst-case gate); capture+encoding observation peak12.761ms. Coordinator at end: one profile, zero in-flight, peak one,64 accumulated calls since session startup. Shared heap delta+3,242KiB is not a peak-memory or leak conclusion. This is one actual normal fake-country host, not eight hosted players or real DataStore durability.

### Reproduce the isolated owner review

1. Open **Power States - Test**, universe10776833313, with the existing Test Rojo project on34873. Do not open/publish Production or enable any real-service gate.
2. In edit mode set the local ReplicatedStorage boolean attribute `NationalFleetProof=true`. Leave `RunRegressionTests=false` and `RunOwnedFleetTests=false` for ordinary hands-on play. The repository leaves Fleet opt-in; this attribute selects only the guarded fake host. Native stays the renderer default.
3. Start Play. A fresh generated country begins with its original opening grant, gas station and surveyed district/wind sites. Fake saves disappear when the Test server stops. No Rowanbridge record is read.
4. Earn and connect the district, then accumulate4,250 Credits. Select the wind site (map or Build→Generation), review4,000 Credits and variable production, allow the quote to expire, refresh and confirm. Menus do not pause billing. Confirmed wind has one feeder and appears in Infrastructure.
5. Inspect each generator, use On/Off and100kW cap controls, compare source output/costs and open the Bank KPI. Wind alone can leave demand unmet; gas On supplies the residual. The survey bend is cosmetic, not a gas connection. On narrow screens expand/page the inspector to reach its44px controls.
6. Test portrait/landscape swipes and an actual gamepad as owner-operated acceptance. Automated safe-root sizing, bound actions and `GuiService.SelectedObject` checks do not establish physical input behavior.

For repeat automated pure/fake suites, opt in to `RunOwnedFleetTests=true` before a fresh Play. The runner waits30 seconds, runs schema/size/codec/accounting/transactions/security/cancellation/eight-country/balance/progression, and prints completion. Normal end-to-end GUI and host endurance require genuine funded/built fake prerequisites; `OwnedFleetFundJourney` is a separately invoked bounded diagnostic accelerator, not ordinary gameplay or a grant. Keep a diagnostic Script/LocalScript alive for any service/GUI it starts. Never run a migration/readiness/real-execution harness as part of this procedure.

### Remaining acceptance boundaries

- Owner gameplay-feel and physical touch/gamepad review are outstanding. The27-minute inter-project earning stretch deserves explicit review;4,000 remains unchanged.
- Whole-profile staging22–24ms callback peaks and shared-heap observations need further hosted/device profiling before rollout. Solver-budget compliance is not smooth-frame acceptance.
- The conservative size envelope leaves14,661 bytes. The fixed two-source contract fits; future technologies, additional history or assets need renewed schema/size review.
- Reused wind symbol/placeholder Native terrain remain intentional. No new artwork or Organic correction is part of this milestone.
- All saves, ambiguous-write recovery and reconnect tests use fake storage. Real schema4 readiness requires a new separately approved guarded read/preimage/diff; migration execution and any permanent wind purchase each require their own later approval. No real adapter was enabled or implemented here.


## Final closeout — 20 November2026,13:14 UTC

**Available fake-storage implementation and Test verification complete. Stop for owner review.** All mandatory schema/site/accounting/transaction/solver/storage gates passed without changing approved prices, limits, geography or historical validators. Physical touch/gamepad, hosted eight-player smoothness and owner pacing acceptance remain explicitly unverified; no real-service guarantee follows.

After the subscription correction, a fresh normal fake country **Oakcombe** completed:

- First Playable district journey34 assertions, actual remote security12. Genuine district funds accumulated at normal cadence; completion step134, Bank253.08 Credits.
- Bounded diagnostic electricity funding1,555 intervals, step199→1754, Bank409.43→4,251.24 Credits,24.571s accelerated execution. No manufactured funds, additional grant or price change.
- Complete `OwnedFleet.spec` journey **90 assertions in one uninterrupted run**: four responsive sizes,30-second quote expiry and refresh, ordinary menu progression, one durable fake purchase, double-click protection, camera/selection, actual per-source output, caps/On/Off, keyboard focus, directory, remount, new subscription echo, stale unsubscribe rejection, malformed real remote payloads and continued steps. Map379; sampled snapshot54,627 bytes.
- Repeated fake-host disconnect/reconnect lifecycle18 assertions with BeforeWrite/AfterWrite faults. Exact financial/energy/baseline/infrastructure restoration and new session epoch; one profile,41 accumulated fake calls/38 writes at that observation.
- Post-reconnect GUI **61 assertions**, then additional sustained progression1954→1958 across five seconds. The old-queued-epoch failure is corrected, not bypassed. Snapshot54,611 bytes in this later sample. All epoch/revision and timeout rules remain in force.

The final genuine Studio captures are [desktop wind](evidence/national-fleet-expansion-v1/owned-wind-final-desktop.png), [portrait Native map](evidence/national-fleet-expansion-v1/owned-wind-final-portrait.png), and [Bank totals](evidence/national-fleet-expansion-v1/owned-wind-final-bank.png). `Control: Rejected` in the desktop inspection is the deliberate malformed-remote test's last result, not a suspended economy. Bank distinguishes live1,365.89 from confirmed1,195.51 Credits in the captured frame and shows the single4,000-Credit investment separately. These are transient fake-country measurements, not a saved real balance. A command-bar string-delimiter typo during screenshot preparation was corrected; it changed no source or gameplay.

Both final Rojo builds, source mapping/security/strict-mode checks and Git whitespace pass. `Validate.ps1` explicitly adds only `OwnedFleet.spec` to the allowed Test remote-sender list; no wildcard or service boundary was loosened. Final edit-mode full-project Script Analysis, current-script filtering off: **0 errors,3 existing Organic warnings**, exactly OrganicCoast23:13, OrganicRibbon14:50 and14:82. No new Fleet diagnostic. [Final Analysis capture](evidence/national-fleet-expansion-v1/script-analysis-final.png).

All four retained600-second suites completed across the recorded sessions: R37, R34, Native and P2b; the additional owned-host600-second run also passed. The final transport correction was validated by fresh ordinary startup, full journey, malformed remotes, repeated remount and new-epoch recovery; those long soaks preceded that correction and were not silently claimed as rerun afterwards. Historical failures, interrupted runs, diagnostic quoting/lifetime errors and corrected results remain in [timestamped output](evidence/national-fleet-expansion-v1/w5-continuation-studio.txt).

Additional test files beyond the inventory above: `OwnedFleetProgression.spec` and `OwnedFleetHostSoak.spec`. The normal Test fake-host feature remains opt-in in repository configuration; the current local Studio edit session retains `NationalFleetProof=true` for owner review with both automatic test flags false. Play is stopped and the command bar cleared. Native stays default; Organic stays diagnostic-only. No real DataStore, Rowanbridge, Production, settings, artwork, publishing, deployment, commit or push action occurred.

Recommended next step: owner hands-on review of the4,000-Credit progression gap, wind/gas controls and narrow-screen interaction, followed by targeted hosted/device staging performance work. Only after that review consider a separately authorised schema4 real-readiness task. Do not infer migration or real wind-purchase approval from this report.
