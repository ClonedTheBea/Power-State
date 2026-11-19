# Visual Redesign v1 — validation

19 November 2026. Implementation and available Test validation complete; owner visual/device acceptance remains open. Isolated Test/fake storage only.

## References inspected

All eight actual PNGs in `Inspiration/` were visually inspected. The existing v1.3 screenshots provide the before state. Adopt the navy layered surfaces, cyan selected states, strong brand/KPIs, structured asset/financial rows and focused review composition. Preserve actual procedural geometry; reference artwork, fictional Westhaven values, staff, prices, budgets, maintenance and news are not imported.

## Stage A gate

Completed 10:54:35 UTC before screen restructuring. Shared tokens, explicit chrome gradients (not per-terrain-object), navigation selection borders, KPI accents and modest native brand mark. Test palette gated by Studio and Test universe10776833313; no Production settings/publication. Two builds/static boundary checks and edit-mode Script Analysis0/0 passed. Operations GUI130 assertions passed. Five twelve-second live panels preserved zero layouts/remounts/focus loss/scroll drift/canvas changes while11–12 authoritative steps advanced. Fleet14.064ms total/.751ms peak; generator20.510/.973; Bank16.201/1.309; reinforcement17.596/1.107. No snapshot throttling or authoritative state change.


## Implemented presentation

- Shared Test navy panels, restrained surface gradients, cyan selected outlines and native lightning brand mark. Financial actions and totals use gold; status retains words as well as colour.
- Grid keeps its procedural country, Native terrain, exact anchors, layers, pan/zoom/recenter, labels and collapsible inspector. Selected infrastructure gains a stronger existing border; inspector facts have a grouped surface.
- Build and reinforcement keep real eligibility/price/quote/commit semantics. Connections is available; Generation/Storage are explicitly later. Review has fixed close, Cancel/Close review and existing Confirm/Refresh Quote. A pending close never cancels an atomic transaction.
- Infrastructure lists actual public assets with filters, status, selected details, Locate and the existing generator toggle. The separate temporary Operations country now has an explicit Training entry.
- Operations uses a full-page responsive fleet with large output values, separate status and bounded three-card pool. Detailed costs, forecast, Bank and reinforcement remain focused dialogs.
- Bank/review rows reuse a fixed pool and responsive key/value layout; live snapshots preserve mounted objects and scroll/focus. The complete canonical public message remains available, including overflow beyond the pool.
- Future Government, Staff, Shop and ticker visual specifications are recorded in GUI-VISION; no new gameplay/data/feed/transactions.

## File inventory for this sprint

New client modules: `Views/DetailRows.luau`, `Views/ProjectCategories.luau`, `Simulation/InfrastructureDirectory.luau`.

Changed client modules: `Theme`, `Navigation`, `Views/Components`, `HeaderView`, `KpiStripView`, `NavigationView`, `InspectorView`, `FeedbackView`, `DashboardView`, `Controllers/AppController`, `Simulation/ConstructionClient`, `OperationsClient`, `OperationsView`, `OperationsPresentation`, `ReinforcementView` (shared review styling/categories). Existing v1.3 modules and unrelated prior working-tree changes are retained.

Tests: new `tests/integration/VisualRedesign.client.luau`; existing Operations, OperationsJourney, OperationsMultiplayer, OperationsV13 and ReinforcementJourney entry paths now explicitly activate the Training button after opening the directory. Existing assertions are retained. No server domain, remote contract, solver, accounting or persistence changes in this sprint.

Documentation: this report, GUI-VISION, GUI-LAYOUT-SPEC, GUI-COMPONENT-SPEC, TECHNICAL-ARCHITECTURE, TESTING, PLANS and DECISIONS.

## Retained regression evidence

Fresh Studio fake-storage session, 11:17–11:21 UTC: the full 10,000 accepted seed route/pad corpus, all four rotations and safe fallback passed with retained P2b gates. Retained P2a, P3a/P3b/P3c accounting/migration/lease/security and First Playable passed. First Playable actual transport12 and normal journey34; Bank83; GUI348; currency16; R2 interaction135; R3 rendering190; R3.1 framing52; R3.3 synthetic hybrid; R3.5 presentation241. These are actual engine tests using fake storage, not real persistence tests.

Native reference-map cold mount24.33ms; warm map draw p50/p95 .321/.462ms;574 map/1046 shell descendants. Frame p50/p95:360×580 safe root16.61/17.58ms,1366×70416.66/17.73ms. Desktop Studio measurements only. Normal First Playable journey map362; Operations map394. Existing engine asset-type warning for203785492 and platform chat/telemetry network messages remain unrelated background diagnostics; no new project Script Analysis errors/warnings observed.

Initial redesigned Operations stability run: three12-second windows, zero layouts/remounts/instance additions/removals and no focus/scroll drift. Fleet36 presentations/9.682ms total/.504ms peak; Bank36/18.927/1.644; reinforcement82/20.561/.958. Shell983 and map394 fixed. Frame p95 approximately17.63–17.73ms. Final refinement repeat results follow below.

## Visual comparison and remaining limits

Matches the reference direction: navy layered chrome, cyan grid/selected states, gold financial hierarchy, outlined native icons, structured lists/details and prominent generator outputs. Every displayed asset/value comes from the existing public model.

Deliberate differences: procedural terrain remains coarse native cells; the concept's painted relief, decorative buildings and Westhaven composition are not implemented. No fictional government/staff data, research/maintenance condition, storage, catalogue inventory or event ticker. Cards and dialogs reorganize into scrolling/stacked mobile layouts rather than reproducing a desktop screenshot at reduced scale. Available systems and their actual information density remain smaller than the concepts.

A later map-art sprint should assess modular sector transitions and settlement/generator motifs using the current coordinate/pivot/layer contract, retain Native fallback and the600-map-instance limit, prepare local art/provenance for owner review and owner uploads, then validate real texture performance separately. No atlas expansion or upload is included here.

Physical touch swipes, controller ergonomics, low-end mobile performance and owner visual acceptance remain open. Earlier v1.2 owner emulator scroll feedback is historical; programmatic paging, safe-root resizing and focus assertions here do not establish new physical-input acceptance.

## Interaction acceptance — 11:29 UTC

The complete `All` run passed 5,997 directory/visible-financial-row/live-state assertions (the count includes repeated frame checks), plus the retained Operations130, paging/focus101 and remote38 suites. Quote Refresh20 exercised the real30-second server expiry against fake storage: review stayed open, simulation advanced, and refresh caused no purchase. Enlarged1.5× text fit checks inspected visible financial labels at desktop, portrait and short-landscape roots. First Playable Bank focus/scroll remained stable while the authoritative step advanced.

The normal reinforcement journey27 passed: natural East congestion, expiry/refresh, keyboard confirmation, one500-Credit capital debit,4MW topology,6MW delivered at the next natural peak, released/reacquired state, exact Bank/history and no repurchase. No steps were accelerated to shorten that test.

Repeat Operations stability: fleet36 calls/14.584ms total/1.001ms peak; Bank36/23.148/2.115; review82/23.912/1.051. Zero layouts, adds/removals, focus loss or scroll drift. Frame p95 17.61–17.81ms. All measured maps remained394 descendants. Small timing variation is retained rather than presented as a hard platform bound.

Final visual inspection found pre-existing expanded-navigation mislabelling (`Build · Later`) and a Fleet action opening Alerts. The client presentation now labels implemented Build honestly and routes Fleet back to the control room; Alerts remains available through its own controls. New explicit navigation assertions retain this coverage. Completed or pending reviews use `Close review` rather than suggesting that Cancel could undo a transaction. These are UI-only fixes, not changes to transaction semantics.

## Retained Operations and solver gates — 11:32 UTC

Reinforcement model497 and transactions61; eight-country resources2,065; encoding5,020; atomic accounting326; scenarios3,144; security231; fleet lifecycle2,062; exhaustive oracle2,187 cases; Stage1 solver8,854; resumable cancellation/lifecycle1,486 passed. Yielded exact comparisons are retained in the engine evidence. The scheduler passed63 eight-country intervals, with unsupported15Hz independent workloads safely suspending18 countries without installing partial accounting.

Native scheduler maxima:3.840ms cooperative slice,41.085ms aggregate,162.585ms elapsed. At30Hz:3.895ms slice,44.814ms aggregate,492.201ms elapsed. The unchanged native/30Hz acceptance gates passed; queue remained at most8 and retained jobs returned to0. These are Studio scheduling measurements, not hard real-time guarantees.

Eight-country reinforced resource sample: profile6,232 bytes; public snapshot2,237 bytes;992 fake writes/calls; observed heap delta1,180KiB. Peak preparation6.103ms, checkpoint5.724ms, solver2.014ms, installation2.511ms, transaction3.556ms. Preparation/checkpoint timing is recorded separately from the cooperative solver-slice target, not hidden inside it.

### Final-pass failure and correction

The larger-viewport capture run caught a new routing regression: the Fleet action correction had also changed the shared Alerts binding, causing the retained `Bounded authoritative alert details accessible` assertion to fail. The correction is confined to Fleet navigation; header/drawer Alerts again open the authoritative details. The failing assertion is retained and the final fresh run must pass before closeout. No server state or thresholds changed.

## Final repeated acceptance — 11:43 UTC

After the Alerts correction, fresh Studio passed Operations130 and interaction101 again, plus5,993 visual acceptance assertions including the explicit Fleet route and available Build label checks. No required assertion remains failed. Final three12-second windows retained zero layout/rebuild/instance churn/focus loss/scroll drift with394 map/983 shell descendants: fleet36 presentations,10.035ms total/.547ms peak; Bank36,18.430/1.592; review82,24.657/2.821. Frame p95 17.51–17.67ms. Snapshot updates remained incremental. Mouse click opened Bank and actual injected mouse-wheel input reached lower financial history; this is mouse evidence, not a physical touch swipe.

The repeated server-only run also passed four fresh eight-country resource rounds (2,065 assertions each), four transaction rounds (61 each),131 staggered/recovery checks and20,179 actual-solver economy assertions. No real DataStore calls were made.

Final two Rojo builds, source/security boundary checks and whitespace check passed after the routing correction. All eight applicable local validators passed; [static results](visual-redesign-v1-static-results.json). [Selected actual engine results](visual-redesign-v1-engine-results.json) include the failed Alerts pass and successful repeats. Prior milestone evidence is unchanged.

## Genuine Studio screenshots

These are unaltered Studio captures, not rendered mockups. Desktop final safe root1612×735; tablet1024×540, portrait390×580 and short landscape844×390 are injected logical safe-root sizes inside the desktop Studio viewport. Earlier Bank/First Playable captures use independent temporary countries; values are live snapshots, not matched simulation-time comparisons. Phone/tablet empty space outside the injected root belongs to the larger Studio viewport.

| View | Actual screenshot |
| --- | --- |
| Before: Operations v1.3 | [Prior desktop](operations-v13-screenshots/desktop.png) |
| Main Grid | [Desktop](evidence/visual-redesign-v1/grid-desktop.png) |
| Selected infrastructure | [Generator inspector](evidence/visual-redesign-v1/grid-selected.png) |
| Build | [District review](evidence/visual-redesign-v1/build-review.png) |
| Reinforcement | [Quote review](evidence/visual-redesign-v1/reinforcement-review.png) |
| Infrastructure | [Actual asset directory](evidence/visual-redesign-v1/infrastructure.png) |
| National Operations | [Three-generator control room](evidence/visual-redesign-v1/operations.png) |
| Bank | [Financial summary](evidence/visual-redesign-v1/bank-operations.png), [mouse-wheel lower details](evidence/visual-redesign-v1/bank-scrolled.png) |
| Tablet | [Grid](evidence/visual-redesign-v1/grid-tablet.png) |
| Portrait | [Stacked control room](evidence/visual-redesign-v1/operations-portrait.png) |
| Short landscape | [Grid](evidence/visual-redesign-v1/grid-landscape.png), [control room](evidence/visual-redesign-v1/operations-landscape.png) |

Comparison: desktop fleet cards now expose prominent output and stable controls in columns, replacing the previous narrow text-heavy panel. Infrastructure provides a real list/detail composition. Financial summaries use sections and aligned values rather than uninterrupted prose. Mobile is deliberately scrollable; not every fleet card/control fits above the fold. Header identity can ellipsize on narrow screens; full Training identity remains available through overview. Native terrain appearance and modest native icons remain the principal artistic gap from the reference images.

## Owner inspection and next step

Final edit-mode full-project Script Analysis reported **0 errors and 0 warnings**, with `Display only current script` unchecked; [captured evidence](evidence/visual-redesign-v1/final-script-analysis.png). Play is stopped and opt-in acceptance runner flags have been cleared. The normal fake-storage Test startup remains available through the connected Rojo server.

Connect only Power States - Test to the existing Rojo test server (port34873), then Play with opt-in runners cleared. Start on Grid, inspect/Locate an asset, open Build and let a quote expire, then Refresh. Open Infrastructure to filter/select actual assets; use its explicit Training button to enter the independent fleet. Test cap/On-Off controls, Alerts, Bank and Build/reinforcement. Check portrait/short landscape, large-text settings, keyboard paging and focus return. Fake progress disappears when the Studio server stops.

Review the actual screenshots and test physical touch/gamepad and low-end hardware next. Any illustrated terrain work, permanent wind W1–W7 or further gameplay requires its own approval. No real profile access, Production change, upload, permission change, publication, deployment, commit or push occurred. Native remains the default. This sprint stops for owner review.
