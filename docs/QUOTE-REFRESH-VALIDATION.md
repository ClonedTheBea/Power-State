# Construction quote usability correction

18 November 2026. Owner-authorized Task A; Studio Test10776833313, fake storage only. No real DataStore read/write, Rowanbridge record access, Production, settings, assets, publication or Git commit/push.

## Root cause and fix

Source inspection established that ConstructionQuotes.status correctly marks a quote expired at server time>=expiry and reports expiresIn0. ConstructionClient previously made the sole modal purchase action Active/Selectable only for Available with positive remaining lifetime. The modal stayed open, but contained no refresh action; the user had to close it and reopen the inspector review. This is a client recovery-path omission, not evidence of a broken30-second server security contract. No pre-fix recording was available for inspection; the cause was traced from source and the corrected path tested at actual server expiry.

A small pure presentation helper chooses Confirm, Quote or Disabled. The existing44px modal action becomes **Refresh Quote** after expiry (including conservative elapsed time since the last snapshot), missing quote, save-drain re-review, or newly affordable previously-insufficient quote. Its AccessibleLabel follows the text. Activating refresh sends only the existing Quote command; it does not confirm the returned quote or close the panel. The next purchase still needs an explicit action on a valid quote.

Re-evaluate at activation so an old displayed button cannot locally send Confirm after its known lifetime. The server remains final authority if network delay means its expiry precedes the client's estimate. Unavailable/uncertain, Saving, built, suspended and stale-data states remain disabled. No timer closes the menu, pauses the country or automatically submits a purchase. Mouse/touch Activated and keyboard/gamepad action bindings reuse the same control and focus object.

Server logic is unchanged: owner/epoch/sequence/shape/rate gates; new server-generated ID invalidates old quote; server site/eligibility checks and fixed catalogue price; actual serialized Build rechecks latest1250-Credit affordability,250 buffer, ownership/fence/topology and permanent receipt. The quote carries no client price or Bank. Refresh itself performs no persistence mutation. All debit/asset/receipt atomicity and ambiguous-result protections remain in the approved coordinator.

## Files changed for this correction

- `src/client/Simulation/ConstructionClient.luau`: action presentation, activation recheck, accessible label, expiry heartbeat refresh and clearer status text.
- New `src/client/Simulation/ConstructionQuoteAction.luau`: pure client action eligibility; no authority, services or accounting.
- New `tests/integration/QuoteRefresh.spec.luau`: real30-second fake-host expiry, policy boundaries, refresh/no debit, panel continuity, four safe-root layouts and engine focus.
- `tests/integration/FirstPlayable.spec.luau`: wait for an authoritative Available quote as well as an active button, since an active button can now mean Refresh Quote. Deadline remains3seconds; no assertions removed.
- This report, the national-grid proposal, roadmap and decision register. No server, solver, economy, schema or artwork source changed.

## Validation results

- Corrected GUI runs passed20 assertions at14:59:46,15:05:57 and15:11:28 UTC, including real30-second expiry, menu continuity and new quote ID without capital spending.
- Subsequent normal-entry journey passed34 assertions at15:01:29:102.666s,step134,Bank253.08 after the single1000-Credit debit,362 map descendants. Generator controls, panels, earned funds, duplicate-purchase protection and both sinks passed.
- Retained server P3c safety31, P3c94, P3b93 and P2a432 assertions passed. Safety includes exact expiry before dispatch, superseded quote rejection, wrong owner/epoch, forged price, ambiguous committed writes, late callbacks and atomic receipt preservation. No server security rule was relaxed.
- Final actual-transport security suite passed12 assertions, including100 invalid requests producing only one periodic snapshot and no mutation.
- Full-project Studio Script Analysis showed zero errors/warnings with Display only current script unchecked.
- Both Rojo builds and mapping/strict/service-boundary/whitespace checks passed. FirstPlayable33 and P3c178 static assertions passed; retained P3b static validation also passed.
- Safe-root sizes1366×704,768×960,360×580 and640×300 retain the44px refresh action. Native map and camera unchanged. Physical touch/controller acceptance remains separate; virtual safe roots and programmatic focus are not hardware evidence.

P3c eight-fake commit workload511.393ms/max18473B/peak4calls; P3b candidate step p95.424ms,89670B; P2a1000 solves16.06ms. These are retained local suite observations, not a quote latency benchmark or hosted service guarantee.

## Reproduction

Connect Test to `rojo serve test.project.json --port 34873`; normal fake entry and RunRegressionTests=false. Start a fresh Play, select Build, leave the review open more than30seconds. Confirm Refresh Quote appears, activate it and inspect new eligibility. Once Bank>=1250, refresh if needed and explicitly confirm the1000-Credit project. It must build once, leave at least250 and show saved completion. Keep real execution gates closed.

The focused ModuleScript suite runs from an actual client LocalScript context after ConstructionClient.active exists: require PlayerScripts.DevelopmentTests["QuoteRefresh.spec"] with LocalPlayer.PlayerGui. It requires an unbuilt fake country. Server regressions use the existing unit suites. Temporary validation scripts used for this task are not part of normal startup and must be detached after testing.

No real persistence or multi-generator implementation follows from this correction. Review [N1–N8](NATIONAL-GRID-OPERATIONS-PROPOSAL.md) separately.

## Visual and input evidence

[Desktop expired quote](quote-refresh-screenshots/desktop-expired.jpg), [360×580 safe-root expired quote](quote-refresh-screenshots/mobile-expired.jpg), and [keyboard-refreshed quote](quote-refresh-screenshots/mobile-refreshed.jpg) are actual Studio captures. Mouse activation changed the expired state back to a fresh insufficient-funds quote without closing the panel. On the narrow root, Tab reached Refresh Quote and Return obtained a fresh Available quote once actual earnings exceeded1250. No purchase was automatically submitted by either refresh.

The earlier first-session randomly generated fake country happened to use the curated name Rowanbridge; it was a fresh fake profile, not the protected real country. Name equality is not identity or evidence of real DataStore access. Test Bootstrap, fake host and all real capability gates remain unchanged.

Proposal validation: local document links, four operating-cost scenarios and the fixed-cost minor-unit conversion were checked. Solver limits, wind/progression values and per-generator migration remain unimplemented proposals, not measured behavior.

## Final gate

Final fresh run on the final source passed at15:13:13 UTC: expiry suite20, actual remotes12 and normal journey34;96.231s journey,step135,Bank253.08,map362. This run includes the retained immediate disabled-click guard and the updated authoritative-quote wait. No failed required gate remains for this scoped correction. All server/solver/economy/persistence source and both project mappings are unchanged relative to the starting commit `f19069e`.

Studio is stopped after validation; the temporary QuoteValidation script is detached, regression startup remains false and no real capability is enabled. Physical touch/gamepad remains outstanding. The multi-generator design stops at owner review of N1–N8, with no implementation or real-service authority.
