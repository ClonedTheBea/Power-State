# GUI layout specification

R3.1 update: the owner requested visual refinement after accepting R3 technically. Current native art/framing, 1,091 passing assertions and 574-map-descendant measurements are recorded in [R3.1 validation](R31-VALIDATION.md). The [modular art recommendation](R31-ART-STRATEGY.md) remains a proposal; no uploads or future gameplay are authorized. Historical R3 measurements below are retained.

15 November 2026 · Approved layout design · R2 shell composition implemented

Sources: [Vision](GUI-VISION.md), [Components](GUI-COMPONENT-SPEC.md), [Architecture](TECHNICAL-ARCHITECTURE.md), [World](WORLD-AND-EXPANSION.md). Dimensions below are logical pixels inside `CoreUISafeInsets`, not physical screen pixels or hardcoded device models. Preserve the running P1 shell until implementation is authorized.

## Shared layout rules

One shell owns header, metrics, navigation, workspace, overlays and news. Grid is the default workspace. Build is a mode over that same map; asset selection and pan/zoom do not reset on ordinary tab changes. Management pages may replace the workspace deliberately, with Grid always one action away. Do not keep a live full-size map behind a full-page shop merely for decoration.

The map receives more than half the horizontal working width during ordinary Grid/Build observation, excluding temporary explicit detail/confirmation overlays. At medium sizes close the inspector by default and collapse the rail; at short heights reduce secondary metrics and ticker before consuming the map. Maintain at least 160px useful map height in the short-layout target; if a smaller safe area cannot meet it, enter a clear compact-tool mode, not negative rectangles or unreadable scaling.

R2 breakpoints (implemented and covered by layout/engine tests; supersede D19 geometry):

| Safe area | Presentation | Default inspector |
| --- | --- | --- |
| Width ≥1440 and height ≥700 | Wide desktop, expanded rail; full four-card strip | Compact National Overview or 300px contextual panel |
| Width 1100–1439 and height ≥600 | Compact desktop; 60px rail | Closed; dock only while map keeps majority width, otherwise overlay |
| Width 700–1099 and height ≥500 | Tablet; 60px rail, two-by-two metrics if needed | Overlay, 280–320px wide; one at a time |
| Width <700 or height <500 | Phone/short layout; bottom navigation | Bottom sheet in portrait; wide shallow sheet or full detail page in short landscape |
| Remaining wide-but-short cases | Compact desktop chrome with short-height metric policy | Overlay; no forced side-by-side layout |

Use measured text fit and available rectangles as final constraints. Breakpoints are presentation decisions, not claims that a device is a phone. Large text can trigger the next simpler layout. No whole-screen UIScale trick that shrinks 44px targets.

## Desktop composition

```text
┌ Identity · country/company ─── Grid status · date            ─ Alerts Help Settings Profile ┐
├ Bank ───────── Supply / Demand ───────── Reliability ───────── Population ────────────────┤
│ Operations  │  Layers                                  Selection/critical locator │ Asset │
│ Strategy    │                                                                     │ details│
│ Community   │                 ILLUSTRATED COUNTRY MAP                              │       │
│ Energy Shop │                                                                     │       │
│ Collapse    │                                  Recenter   −  Zoom  +               │ Action│
├ News · NATIONAL · relevant headline ─────────────────────────────── Open   Pause Collapse ┤
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

Header 64–72, KPI strip 76–92, rail 176–200 expanded/56–64 collapsed, inspector 280–340, ticker 34–40, gutters 8–12. Start at 68/80/184/300/36 with 12px outer padding and 10px gutters. Header identity is text plus a modest mark, not a full-width image. Secondary subtitle disappears first.

**R2 geometry refinement (D33):** the owner's explicit shorter-header requirement takes precedence over the initial desktop header range above. At default text size, use 64px wide-desktop / 56px compact-desktop and tablet / 48px phone / 44px short-landscape header, 76px one-row / 128px tablet two-row / 64px phone KPI region, 184px expanded / 60px collapsed rail, and 300px inspector. R2 reserves zero ticker/footer height because R4 has not started. The allocation examples below describe the fuller future composition, not current R2 output. Current safe-root map heights: 1600×840 →656; 1366×704 →528; 768×960 →732; 360×580 →376; 640×300 →180. Short landscape merges primary readings into Overview and removes the KPI strip. At enlarged text sizes, compact-tool mode may hide the separate strip to preserve useful map space; 640×300 at 150% retains 128px. No whole-screen scaling is used.

Width/height examples, already measured in safe-area pixels:

| Safe area | Width allocation | Vertical allocation | Result |
| --- | --- | --- | --- |
| 1600×840 | 24 outer +184 rail +20 gutters +1072 map +300 inspector | 24 outer +68 header +80 KPI +36 ticker +30 gaps +602 workspace | Map 68% of inner width |
| 1366×704 | 24 outer +60 rail +20 gutters +962 map +300 inspector | 24 outer +64 header +76 KPI +36 ticker +30 gaps +474 workspace | Map 72% of inner width; collapse inspector for more room |
| 1100×620 | 24 outer +60 rail +10 gap +1006 map; inspector overlays | 24 outer +64 header +76 KPI +36 ticker +30 gaps +390 workspace | Map retains working width; overlay is deliberate |

At 1366 wide an expanded 184px rail with a 300px inspector still leaves room, but the compact default avoids visual crowding. User rail expansion is allowed only if all labels fit and the map-majority rule remains true. Docked inspector width is bounded, not user-stretched until the map disappears.

## Header and metrics

Header: Power State identity; country/company name (truncate with full-name details); server-derived grid status; simulated date; **conditional paused/delayed/unavailable simulation status**; Notifications; Help; Settings; Profile. On narrow screens move date/Settings/Profile into an accessible overflow panel. Do not permanently display Standard in the normal header. Keep Help and alerts one action away. Core Roblox menus remain outside the game header; do not draw counterfeit Roblox controls from the references.

Grid status states are Normal, Attention, Critical, Paused and Data unavailable, with text/icon. The server supplies operational state; a current deficit must not be hidden behind yesterday's reliability. A preview uses “Illustrative grid,” not Normal or a fabricated date. Reserve margin/system stability are hidden until definitions and server data exist; a later details view explains capacity minus demand and observation window rather than inventing a score.

Four cards: Bank, Supply / Demand, Reliability, Population. Value 24–30 desktop/20–24 tablet, label 14, supporting text 12–14; compact values 18–22 with 14px labels. Operational explanations use 16px body text. Bank includes the exact-value route, financial breakdown and active-benefit badge. Supply opens unmet-demand/region details. Reliability opens its period definition; population opens national development. Cards receive a keyboard/tap target only if there is a real details view. Alerts are not a fifth equal-width card.

## Navigation and page ownership

| Group | Label | Route/behavior | Live dependency |
| --- | --- | --- | --- |
| Operations | Grid | Existing Map route can retain its internal ID; overview, layers and selection | Shell now; real readings P2 |
| Operations | Build | Opens catalogue and map placement mode, not a second map instance | P3; later technology types remain gated |
| Operations | Infrastructure | Search/filter owned assets, View on map; share inspector | P2 inspection/P3 construction, P5b maintenance |
| Strategy | Government | Inner tabs: Overview, Policies, Projects, Priorities, Legislation | P7; not part of R1 |
| Strategy | Staff | Teams, assignments, budgets | P5b/P6b |
| Strategy | Research | Dedicated navigation entry into the Government research domain | P7; no duplicated service |
| Company/community | Events | Current event or “No active event”; no false urgency | P11 |
| Company/community | Company | Identity, history, rankings | P9 |
| Company/community | News | Full News Centre with National/Server/Global filters | P10 |
| Separate optional group | Energy Shop | Credits default, Robux secondary; never a forced destination | Preview slice R5; live milestone separately gated |

Expanded rail uses icon + label + selected marker. Collapsed rail uses consistent icons with focus/tap-accessible labels, not hover alone. Scroll the navigation within its region; keep group titles out of the tab order. Future entries show “Later” and open an honest phase explanation in a preview; they must not execute a game action. The shop has no promotional unread badge.

Bank opens finance from its KPI; it is not a second Government budget. All budget categories debit the same balance. Management pages share the shell and route state. Infrastructure selection survives return to Grid; keep filters locally without exposing private server data. Long lists use bounded pagination/virtualisation later, not one GUI per asset in the save.

## Tablet

At 768×960 safe area, propose 12px outer padding, 56px header, 128px two-row KPI block, 60px rail, 10px gaps and 44px touch ticker. Workspace height is 678px and map width 674px before an overlay. Inspector 300px or at most 45% of available width; close by default. Do not simultaneously open rail drawer, layer drawer and inspector.

Toolbar buttons remain 44px; compact icons have text on focus/tap. Ticker shows one shortened headline with a full-story target; secondary scope filters live in News. Landscape tablet may use a one-row KPI strip if exact numbers fit. Shop tabs stretch across the content width and product information scrolls vertically; no competing three-column product grids.

## Mobile portrait and short landscape

```text
Identity                     Alerts / Help
Bank [exact value route]  Supply / Demand
[Reliability · Population details]
┌ Layers ───────────────────────────────┐
│                                      │
│          COUNTRY MAP                 │
│                                      │
│ Recenter   −   +                      │
└──────────────────────────────────────┘
[Optional compact News / alert status]
Grid       Build       Gov.       Events       More
```

At 360×580 safe area: 8px outer padding, 48px header, 64px primary KPI row, 52px bottom navigation and three 8px gaps leave 376px map height when news/secondary KPIs are collapsed. The header/metrics together provide a 44px expandable overview route for reliability and population; do not force four tall cards onto every phone. A persistent critical alert may consume 44px above the map, still leaving 332px. Every destination has an accessible text label; “Gov.” is expanded to Government in focus/help and More.

Five bottom destinations: Grid, Build, Government, Events, More. At 360px with 8px side padding, each receives about 69px width and at least 44px height. More contains Infrastructure, Staff, Research, Company, News, Energy Shop, Settings, Profile and Help, grouped as above. If text enlargement makes five labels impossible, show short icon/label pairs and full labels in More; never shrink the hit targets. Disabled future screens remain explicit previews, including Build/Events.

At 640×300 safe area: 8px outer padding, 44px header, 44px primary metrics, 44px bottom navigation, and 8px gaps produce a 128px map, below the 160px target. Therefore merge Bank and Supply into the header/overview control, remove the separate metric row and collapse news: map becomes 180px with two 8px gaps. Reliability/population/date are in Overview. This compact-height exception takes precedence over decorative header targets.

Portrait inspector: closed → peek (title/status, no hidden required action) → half sheet → expanded sheet. Start at roughly 45% of workspace, allow up to the safe height above navigation; scroll only the body and keep heading/close plus action footer visible. Expose explicit Expand/Collapse buttons so gestures are optional. At short landscape, use a wide detail sheet with internal scroll or an explicit full details page; never a narrow letterbox body squeezed below giant KPIs. Close returns to the same map selection and camera.

In Build mode collapse details to a cost/status summary so the map is visible. Confirm/Cancel remain reachable above navigation. Opening keyboard/text input reflows the panel; closing or rotating must not silently submit a quote. Rotation preserves selection and form intent but revalidates any stale server quote; camera recentring should be deliberate or documented, not move a chosen endpoint unexpectedly.

## Map tools, layers and states

R3 prototype implementation: Layers occupies the first top-left shell tool slot, followed by Assets and Map focus; Details remains at the right. The existing bottom-left zoom/Recenter row is retained to preserve short-screen behavior. Layers uses the existing modal drawer on desktop and touch, rather than adding a separate popover. Geography is the sole available primary layer, with optional Labels/Sample connections. Other entries explain unavailable future data. These bounded refinements are recorded in D39; no empty ticker strip or new operational layer is introduced. See [R3 evidence](R3-VALIDATION.md).

Keep Layers at top-left, zoom/recenter bottom-right on desktop or in a compact bottom tool row on touch; offset them around visible alerts/sheets. Only one expanded floating tool panel at a time. A legend opens from Layers and shows only active meanings. Tool panels consume input; a drag beginning on a button cannot pan the map beneath it.

| Primary layer | Focus | Retained context |
| --- | --- | --- |
| Geography | Terrain, settlements and ownership | Selection, critical incidents, major network anchors |
| Power flow | Direction, utilisation, capacity and bottlenecks | Muted geography; flow width/dashes plus numeric details, not glow alone |
| Electricity demand | Regional requested/delivered/unmet MW | Region labels and outage markers; no per-household rendering |
| Infrastructure condition | Inspected condition, faults and work orders | Unknown condition remains Unknown; no client reveal of latent faults |
| National development | Population/development tier and opportunities | Actual server thresholds; no decorative growth claims |
| Weather | Regional conditions and affected technologies | Effective period and unavailable/stale state; no gameplay calculation in GUI |
| Seasonal events | Connector, objective zones and event status | UTC deadline, ordinary grid consequences and route selection |

One primary analytical layer at a time, with muted Geography underneath and optional labels. Always retain owned/unowned boundaries, current selection, construction validity/cancel controls, critical incident locators, and minimal endpoints relevant to the current action. No layer hides required safety or transaction feedback. Layers unavailable in the current phase explain why; do not fabricate weather or demand to make them attractive.

| State | Visual/interaction rule |
| --- | --- |
| Observe | Quiet terrain/network, no permanent full label wall |
| Hover/highlight | Thin dashed outline plus name; never indistinguishable from selection |
| Selected | Solid cyan outline, selection brackets, title in inspector; remains selected across layers |
| Build | Labelled mode banner, snapped/quoted candidate and persistent Cancel; world art remains secondary |
| Invalid construction | Coral cross + hatched ghost + reason text; confirmation disabled, explanation accessible |
| Under construction | Work icon, dashed footprint, server progress/status; no working power shown before commissioning |
| Maintenance | Wrench/inspection icon, assignment and downtime warning; preview does not reveal hidden faults |
| Analysis | Layer/period label and legend; inspection remains possible without changing infrastructure |
| Overload/constraint | Amber warning triangle, patterned line, numeric demand/capacity; do not draw physical flow above a solver cap |
| Damaged | Broken-tool icon + condition text and pattern; severity comes from server consequences |
| Offline | Broken-link/power-off icon, dashed grey line and explicit reason; different from damaged |
| International active | Border arrow + Import/Export label + actual MW; no double counting |
| Seasonal | Purple event badge, connector status and deadline; not automatically urgent |

Mouse: drag to pan, wheel or buttons to zoom, click asset/line to inspect; click endpoints for a connection. Keyboard: logical Tab/Shift+Tab groups, Enter activate, arrows pan in map focus, +/− zoom, Home/Recenter command, Escape cancels topmost local mode before returning focus (coexist with Roblox core menu). Retain M shortcut for Grid. No shortcut fires while typing.

Touch: single-finger pan, tap select, endpoint taps build, optional pinch zoom with +/− alternatives; hold is never the sole route to details. Gamepad proposal: explicit Map focus versus UI focus; left stick pans only in Map focus, shoulder buttons zoom, A selects/confirms the current local step, B cancels/back, D-pad traverses UI; on-screen hints and a focusable asset list provide an alternative to precise pointer placement. Validate mappings against Roblox core controls before shipping. Detect input mode changes without resetting selection. Capture one gesture owner, cancel on lost focus and suppress selection after drag.

## Contextual inspector

No selection: compact National Overview with unmet demand/alerts and a Close option; never force an empty 300px column. Every inspector has identity/type, labelled status, primary values, cause/explanation, secondary tabs or sections, and bounded action footer. History is paginated. On touch use accordions instead of five narrow tabs. Show only actions supported by the current phase and server permissions; blocked actions expose the reason, not a mysterious grey button.

| Selected type | Primary information | Secondary information/actions |
| --- | --- | --- |
| Generator | Status, available MW, current output MW, expense rate with period | Condition/inspection, fuel/technology later; Locate, maintain, upgrade only when supported |
| Substation | Current load/capacity, connected routes, known condition | Connections list, inspection/repair, upgrade eligibility |
| Settlement | Population, requested/delivered MW, service ratio with period | Growth trend and causes, development opportunities, Locate underserved network |
| Transmission line | Rating MW, actual flow/utilisation, endpoints, status | Condition, inspection history, repair/upgrade, quote/cancel where relevant |
| Storage (later) | Stored MWh/capacity and charge/discharge MW | Efficiency, operating state, maintenance; never counted as generated energy |

During construction, inspector becomes quote summary rather than a second catalogue. Preserve place/endpoint visibility. Full cost and impact summary appears in deliberate confirmation; final acceptance belongs to the server. Destructive actions require explicit object identity and consequence; Escape/Back cancels, not confirms.

## Ticker, news and alerts

Ordinary desktop gameplay retains a 36px bottom strip: small Power State News identity, labelled scope, one headline, Open, Pause/Resume and Collapse. It is separate from the full News Centre. Proposed minimum 10 seconds per headline, longer for long text; pause on hover, focus, explicit pause or reduced-motion mode. Reduced motion uses a static selected headline with Previous/Next controls. No perpetual sideways crawl. Reserve 44px touch height or collapse into News. Ticker never steals keyboard focus.

Prefer relevant National developments, then active-event milestones, then Server/Global stories with bounded fairness so one category cannot starve the rest. Deduplicate by stable news ID/milestone; coalesce recurring incidents by cause/region. Cap visible queue (proposed 20); rely on the bounded server feeds for history. Do not fetch per animation frame. Stale stories say when updated; empty means “No recent news,” offline means “News unavailable.” Event tags retain a National/Server/Global scope. Never broadcast private data or unfiltered user text.

Open routes to the matching story/asset while preserving Grid state; if the subject is gone show archived details. News selection never executes an action. A preview ticker is labelled “Sample headlines · not live” and uses authored examples. Do not insert fake server players or live community totals.

| Severity | Presentation | Interruption |
| --- | --- | --- |
| Informational | Info icon + label, calm notice/history/ticker | No focus stealing; optional dismissal |
| Warning | Amber triangle + cause + Inspect action; persistent alert list | Nonmodal banner/badge; no forced map jump |
| Critical | Coral octagon/exclamation + Critical + affected region/cause; persistent panel/banner | May open one focused incident presentation for a new critical cause, never repeated duplicate pop-ups; defer around a transaction confirmation/native purchase prompt |

Urgent grid incidents remain discoverable even if ticker is collapsed. Dismiss/acknowledge is not repair; unresolved incidents remain in the alert list. Rate-limit/coalesce escalation; reopening uses the same incident. Server/world achievements stay noninterrupting. Loading-save, lease failure and unsafe spending use service/error states, not a misleading grid alarm.

## Energy Shop layouts

Desktop replaces workspace with page title, two labelled tabs, small active-benefit status and one Double Income product card. Avoid giant Buy buttons and filler products. Keep cost, duration, eligible-sales description and financial-advantage disclosure together. Credits details use amber; Robux details green; both retain text/icons. Full product copy and exclusions are expandable, but payment type, exact cost, temporary/permanent and non-stacking are visible before confirmation.

Tablet stacks product facts into two columns, then full-width confirmation route. Mobile uses two 44px tabs and a single scroll column with a fixed, nonoverlapping action area above bottom navigation. Full confirmation fits by scrolling its body; Cancel and explicit purchase action remain accessible. In the design/preview stage, action says “Purchase unavailable in preview,” with no MarketplaceService calls.

Credits confirmation later: product, exact server quote, current Bank, remaining Bank, 30 active minutes, eligibility/non-stacking and Cancel/Buy for X Credits. Robux later: product, Roblox-supplied price, Permanent Game Pass, optional-paid label, non-stacking, Cancel/Continue to Roblox. Roblox owns its native final transaction prompt. Unknown price/ownership disables purchase with Retry; an unknown state must never look unowned or free. Full flow states are in [Components](GUI-COMPONENT-SPEC.md#shop-and-purchase-states).

## Migration and validation plan

The owner separately authorized R1–R3. All three are implemented; see [R3 validation](R3-VALIDATION.md) and historical [R2 validation](R2-VALIDATION.md). Remaining slices still require separate authorization. Review each slice before proceeding; keep source control changes independently reviewable and retain existing map behavior. No framework/tool installation, purchases, publishing or asset uploads are implied.

| Slice | Bounded change after approval | Evidence before next slice |
| --- | --- | --- |
| R0 — this task | Three specifications, terminology/economy/security decisions and plan updates only | Link/consistency/contrast checks; verify implementation/test/config hashes unchanged |
| R1 — implemented | Theme tokens and Bank/Credits presentation, exact-value formatting; no new navigation or gameplay | Historical evidence in R1-VALIDATION; retained currency regression coverage |
| R2 — implemented | Responsive header/metrics, rail grouping/collapse, mobile five-item nav, contextual inspector; future routes remain previews | Current build, layout/focus/rotation/runtime evidence and remaining hardware acceptance in R2-VALIDATION |
| R3 — implemented prototype | Modular authored terrain/asset silhouettes for existing fixture, layers with sample labels, zoom detail/culling contract | No solver changes; pan/zoom invariants, crossing lines, overlapping targets, missing-art fallback, instance budget, cold/warm-load profiling |
| R4 — news/alerts preview | Static sample ticker, collapse/reduced motion, alert severity presentation | No news backend; deduplication/focus/critical handling tests, no lost urgent alerts when collapsed |
| R5 — shop preview | Credits/Robux tabs, product/status/confirmation mock states, no purchase capability | Payment comprehension tests, mobile full cost/close access, unavailable/owned/checking states; zero MarketplaceService/remote purchase paths |
| Later live integration | P2 data, P3 construction/ledger, P5–P11 services; shop milestone only after explicit authorization and prerequisites | Domain/security/persistence suites plus real platform integration, not UI mocks |

Current module mapping: evolve `Theme.luau` first; `DashboardView` remains composition, extracting Header/KpiStrip/Navigation views as needed; `Components` stays shared primitives. `AppController` coordinates routes/selection, not a giant state store. `MapController` and `MapTransform` retain local input/math; `MapView` can delegate chunk/layer rendering. `Layout.resolve` remains pure and unit-tested. Keep Scope lifecycle cleanup. Future shop/news view controllers consume injected view models; server Services/Adapters own commerce and feeds. No server logic goes into a view or shared cosmetic catalog.

Preserve the current 98 layout/map and 80 engine assertions as regression coverage during R1. When R2 intentionally changes rectangles, revise geometry expectations with documented before/after behavior, never delete tests simply to make the redesign pass. Keep normal Rojo mappings test-free. Snapshot current accepted screenshots and establish a rollback commit only when the owner authorizes committing; until then preserve files/diffs locally without overwriting unrelated work.

Review matrix: 1366×768 and 1920×1080 desktop; 768×1024 and 1024×768 tablet; 360×640 and 640×360 phone, plus reduced safe areas 360×580/640×300. Exercise 125%/150% text, long names/translations, full Credits values, missing art/data, input-mode switching, open sheet rotation and ten-minute resize/pan smoke sessions. Actual low-end touch hardware remains a release gate; emulator screenshots alone do not prove it. Validate all primary tasks with keyboard and gamepad; map focus and core Roblox menus must coexist.

Acceptance follows behavior, not pixel imitation of the references. No simulation-speed feature is a gate: the conflicting brief item is replaced by the conditional simulation status and non-stacking Double Income design (D22/D27).

## Visual Redesign v1 layout refinement

Existing safe-root/breakpoint and inspector contracts remain authoritative. The normal Grid retains its four desktop/two mobile KPI arrangement, five mobile navigation entries, map controls and collapsible inspector. Test chrome adds visual depth without changing world coordinates.

Infrastructure is an actual-asset directory, not an implicit switch to the independent Training country. Its explicit `Open National Operations Training` action retains that workflow. Directory list/detail are side by side above 860px of usable content width, stacked below; one parent scroll region retains access in short landscape. Category filtering does not change electrical state.

The Training fleet occupies the available page rather than a 420px panel beside an unused map. Cards use three columns at 1050px usable width, two at720px, one below. Width/font determine geometry; changing generation values does not. Details remain separate focused review panels. Grid camera/selection survive returning from the full-page view.

Test review dialogs use at most620×560px within the safe root (16px clearance), fixed close/action targets, and scrollable details. Financial rows are side by side at480px × text scale, otherwise stacked. Build tabs remain above the scroll body, Cancel/confirmation below. Category previews are explicitly unavailable and cannot purchase. The existing server30-second expiry and Refresh Quote path remain unchanged.

## Visual Redesign v1.1 responsive refinement

Preserve the existing safe-root rectangles. Expanded Test rail rows are 44px × text scale; collapsed rows retain their icon/label geometry. Wide headers separate brand and country when at least 760px × text scale remains after utilities; compact headers retain the existing summary. KPI icons appear only when card width reaches 280px × text scale, preserving value space on phones.

Financial key/value rows retain 44px minimum wide-row height and stack below 480px × text scale. Investment review adds a compact context caption above the existing categories; footer controls remain fixed and body scrolls. Three fleet cards retain 3/2/1 columns and 44px actions; output bars occupy reserved fixed space and never change card height. Infrastructure retains four bounded asset slots and its existing list/detail breakpoint.


## Illustrated World v1 audit boundary

The owner accepts v1.1 chrome as the baseline; no further shell redesign is authorized. The [Illustrated World audit](ILLUSTRATED-WORLD-V1-VALIDATION.md) stops before renderer code at the explicit existing-art sufficiency gate. Frozen authored headland/1200×800 placements are not a generated-sector contract. The proposed shore-edge family, flat-coordinate pivots, same-lighting variants and bounded Test adapter are design handoff only. Native,44px targets, authoritative graph overlays, selection/camera and600 total descendants remain unchanged. No new atlas, upload, mode control or default renderer is implemented. See the report for exact gaps and owner-review options.


**Local artwork follow-up (D210/D211):** the audit boundary above is historical. Owner subsequently approved18 local motifs across the original main atlas and a two-diagonal companion. [Actual artwork and pixel/visual evidence](ILLUSTRATED-WORLD-V1-ART-VALIDATION.md) are ready for review; no upload, integration or visual/default adoption follows automatically. Native geometry/default, overlays,44px targets and600-descendant ceiling remain unchanged. Ground transitions and bounded shore-slot issues require review before a later renderer proof.
