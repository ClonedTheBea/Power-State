# UI and UX

Status: GUI-only desktop/tablet/mobile support and accessible controls are confirmed. Layout, targets and information hierarchy are proposed D12.

## Navigation and information

Persistent header: treasury, current supplied/requested MW, reliability, alerts and save status. Main destinations: Map, Infrastructure, Government, Staff, Company and News. Events appear as an optional destination only while relevant; the tutorial/help entry is always accessible. Unimplemented destinations are hidden or explicitly marked unavailable, never presented as working features.

Desktop uses a map with collapsible side panel and bottom status strip. Tablet uses a narrower side sheet. Phone uses a map plus bottom sheet with at most one primary detail panel; navigation moves to a compact bar or menu. Avoid squeezing the desktop layout onto a phone. Preserve selection and unsent form edits when rotating or resizing where safe; discard stale construction quotes explicitly.

Map layers: power flow, service coverage, condition, terrain/resources and growth. Power overlay shows line utilization, direction and outage icons. The region panel separates requested, delivered and unmet MW, delivered MWh for the selected period and the reason for shortfall. National totals must not imply every settlement receives equal service.

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
