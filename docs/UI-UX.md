# UI and UX

Status: P1 foundation, R1 theme/currency and R2 responsive composition are implemented under D12/D19/D32–D37. Owner visual acceptance and actual touch hardware checks remain pending. Later gameplay flows below are specifications, not implemented features.

The three GUI specifications are approved, with R1 clarifications D27–D31: [GUI vision](GUI-VISION.md), [layout](GUI-LAYOUT-SPEC.md), [components](GUI-COMPONENT-SPEC.md). R1 supplies theme tokens and Bank/Credits; R2 supplies responsive composition and navigation. R3 adds illustrated terrain and layer previews; ticker and shop remain later slices. No permanent Standard header indicator is planned; future pause/delay/unavailable status remains conditional.

## Current shell behavior (R2/R3)

The safe-area shell shows four illustrative operational metrics on desktop/tablet and Bank plus Supply / Demand on phone. Overview exposes all exact readings and explains unavailable simulation/date/history. The compact header consolidates identity, preview status and utilities; no empty ticker/footer strip is reserved. The illustrated five-marker, three-link R3 map keeps bounded mouse/single-touch pan, wheel/button zoom, drag suppression and Recenter. Layers offers Geography, label/sample-connection toggles and unavailable analytical explanations. Locate reveals the selected asset without changing zoom. See [R3 validation](R3-VALIDATION.md) for prototype art and hardware limitations.

Desktop navigation groups Operations, Strategy, Community and optional Energy Shop with an expandable/collapsible rail. Phone/short layouts use Grid, Build, Gov., Events and More. More contains all routes and utilities; future destinations explain their dependency. Build retains the same map. Inspector Close/peek/half/expanded preserve the selected asset. Camera resizing preserves world centre and zoom, subject to edge clamps; only Recenter deliberately resets it.

Tab/Shift+Tab and Enter traverse/activate visible controls; modal focus stays inside feedback/drawers and returns to the invoker. Map focus enables arrows/left stick, +/- or shoulders, Home/Recenter and A for the asset list; B returns to UI focus. M returns to Grid. Escape dismisses the top local panel while coexisting with Roblox's core menu. D-pad traverses UI controls. Session-only Settings offers 100/125/150% text with reflow. Actual touch/controller hardware remains an acceptance gate; see [R2 validation](R2-VALIDATION.md).

Help retains loading/notice/error demonstrations with no requests or implied saving. The shell has no motion, sound or flashing. No simulation-speed controls or gameplay authority are present.

## R1 currency retained in R2

The Bank card uses exact Credits on sufficiently wide cards and compact Credits on narrower cards (R2 threshold: 300 logical pixels times the local text scale). Activating the card opens exact-value details. Short layouts expose the same information through Overview. The unchanged pure formatter truncates compact suffix decimals and preserves exact minor units in full values; it uses English grouping until localisation. It never settles money or changes authoritative state.

## Navigation and information

Redesign header: identity, country/company, server grid status, simulated date, conditional paused/delayed/unavailable simulation status, alerts, Help, Settings and Profile. KPI strip: **Bank**, current delivered supply/requested demand, period-labelled reliability and population. Currency displays as `100,000 Credits`; compact abbreviations expose exact values via tap/focus/details. Budget categories remain one balance.

Navigation groups: Operations (Grid, Build, Infrastructure); Strategy (Government, Staff, Research); Company/community (Events, Company, News), plus separately labelled optional Energy Shop. Grid is the presentation name of the existing Map route. Research still belongs to GovernmentService. Mobile prioritises Grid/Build/Government/Events/More. Future routes remain honest unavailable previews. Events can show No active event rather than a false notification. Full layout/phase mapping is in [Layout](GUI-LAYOUT-SPEC.md#navigation-and-page-ownership).

Desktop uses a map with collapsible side panel and bottom status strip. Tablet uses a narrower side sheet. Phone uses a map plus bottom sheet with at most one primary detail panel; navigation moves to a compact bar or menu. Avoid squeezing the desktop layout onto a phone. Preserve selection and unsent form edits when rotating or resizing where safe; discard stale construction quotes explicitly.

Redesign layers: Geography, Power flow, Electricity demand, Infrastructure condition, National development, Weather and Seasonal events. One primary analytical layer at a time over quiet geography; always retain selection, ownership, required construction feedback and critical incident locators. Power overlay shows utilisation, direction and outage icons. Inspectors separate requested/delivered/unmet MW and period energy; national totals must not imply uniform service. Illustrations consume descriptors and never decide simulation outcomes.

Ordinary desktop play includes a calm persistent news ticker, separate from News Centre. It supports scope labels, Open, pause/collapse and reduced motion; tablet condenses it and phone may collapse it. Critical alerts persist independently, using icon + severity text + cause/action. No speed control or paid simulation acceleration exists in the redesign; the brief's contradictory acceptance item is superseded under D22.

Energy Shop defaults to amber Credits Shop (temporary Double Income, 30 active online minutes); green Robux Shop offers an optional permanent Game Pass. Explicit labels/icons, exact prices, duration/ownership, no-stacking, active timer and deliberate confirmation are required. The benefit affects only eligible domestic/export sales revenue, not expenses, energy or time. See [Economy](ECONOMY-AND-REBIRTHS.md) and [Data/security](DATA-AND-SECURITY.md); no shop transaction is implemented or authorized by this design.

## Construction flow

Choose asset → select a valid site or line endpoints → inspect route/cost/capacity preview → confirm → display pending request → accepted asset or actionable rejection. Phone uses tap-start/tap-end, optional waypoint taps and a clear cancel control. Desktop may support drag as a shortcut, but every action must also be possible without dragging. A pending command disables its repeat submit while still permitting cancel of the local preview; cancellation of an accepted order is a separate server command.

Distinguish predicted preview and authoritative result visually. When the server rejects a changed quote, show the new cost and require another deliberate submit. Do not optimistically increase cash, population or event contributions. Noncritical interpolation of gauges is allowed if values converge to server snapshots.

## Accessibility defaults

Proposed minimum touch target: 44 × 44 logical pixels with spacing; typical phone body text 16 logical pixels or larger, verified at device sizes rather than assumed from offsets. Support text scaling, wrapped labels, constrained panel widths and scrolling for localized content. Use icons and text alongside red/green indicators; each capacity bar has a numeric label. Target 4.5:1 text contrast and validate chosen colors.

Include reduced motion, optional sound, no required flashing effects, and dismissible noncritical news. Essential warnings persist in an alert list rather than forcing repeated modals. Tooltips have tap-accessible equivalents. Keyboard/gamepad focus order is a proposed additional accessibility goal; keyboard navigation must at least cover primary desktop actions. No hover-only actions or timed tutorial responses.

GUI uses ScreenGui and standard Roblox layout/constraint objects; responsive sizing can use AutomaticSize, UIScale and size/text constraints, whose availability is documented in the [official UI guide](https://create.roblox.com/docs/ui/size-modifiers). Specific sizing choices require device tests, not merely use of a scale object. Respect platform safe areas and avoid obstructing core Roblox controls.

## Failure and loading states

Loading distinguishes loading save, retrying service, locked session and incompatible save. Never show a blank/new country on load failure. A save warning shows time since last confirmed save; when persistence is unsafe, explain why spending/progression is paused. Public profiles/rankings include “as of” timestamps and may display unavailable/stale states. No blank page should masquerade as a zero score.

News has separate National, Server and Global filters. Critical grid alerts outrank social celebrations. Event panels distinguish delivered locally, durably recorded personal contribution and reconciled community total. Explain that global updates can lag. Era confirmation lists losses and permanent gains, with a final server-validated action.

## Performance and acceptance

Use [World](WORLD-AND-EXPANSION.md) culling and object budgets. Reuse map objects; do not rebuild the whole map each simulation step. Update visible labels only when values change or at a capped cadence. Local pan/zoom stays responsive even while waiting for a server command.

P1 validates layout shells; P2–P4 validate actual play. Test proposed 360×640 and 640×360 phone viewports, 768×1024 tablet and 1366×768 desktop, plus Studio/device safe areas. At each size, connect a settlement, inspect a shortage, cancel a preview, read a long error and complete/skip tutorial without clipped actions. Touch hardware tests remain necessary before declaring mobile support verified.
