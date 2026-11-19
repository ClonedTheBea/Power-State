# GUI component specification

R3.1 update: the owner requested visual refinement after accepting R3 technically. Current native art/framing, 1,091 passing assertions and 574-map-descendant measurements are recorded in [R3.1 validation](R31-VALIDATION.md). The [modular art recommendation](R31-ART-STRATEGY.md) remains a proposal; no uploads or future gameplay are authorized. Historical R3 measurements below are retained.

15 November 2026 · Approved component requirements · R1 theme/currency, R2 shell and R3 map prototype implemented

Read [Vision](GUI-VISION.md) and [Layout](GUI-LAYOUT-SPEC.md). R2 extracts HeaderView, KpiStripView, NavigationView, NavigationIcon and DrawerView from the composition layer and retains shared primitives, inspector and feedback views. R3 map refinements are noted below; news/shop components remain future phase contracts. Desktop/tablet/mobile share behavior and state models, with layout variants rather than duplicated business logic. See [R2 evidence](R2-VALIDATION.md).

R3 implementation note: MapView delegates cosmetic patch construction/culling to `Views/Map` modules and keeps separate marker/connection/label/selection containers. LayerSelector reuses the responsive modal drawer on all device classes, preserving its focus/close behavior; only Geography and optional labels/sample connections are available. The explicit Locate action preserves zoom and selection. Unknown art kinds retain labelled native fallbacks. See [R3 validation](R3-VALIDATION.md) and D38–D40. News/shop contracts remain future work.

## Theme tokens and typography

Centralize colours, spacing, typography, corner radii, focus outlines and motion settings in the existing Theme module during R1. Raw colours should not be repeated in views. Keep semantic roles separate even where two roles initially share a colour.

| Token/role | Initial value | Use |
| --- | --- | --- |
| Background | `#0B1420` | Shell/backdrop |
| Panel | `#162333` | Quiet content surfaces |
| Raised | `#203347` | Hover, selected-neutral surface and elevated controls |
| MapOcean | `#112A3C` | Water; no transparent text directly over variable terrain |
| Accent / focus | `#54D0CD` | Selection and primary navigation emphasis |
| Healthy / Robux category | `#39B98A` | Distinct semantic tokens sharing green; always labelled |
| Warning / Credits category | `#F2B85D` | Distinct semantic tokens sharing amber; always labelled |
| Critical | `#F16D70` | Critical icon, border or filled badge with dark text |
| Event | `#A78BFA` | Event topic/badge, not generic notification urgency |
| TextPrimary | `#EDF4F8` | Values, titles and ordinary body text |
| TextSecondary | `#B7C8D6` | Supporting text; cool, lower-luminance counterpart to primary |
| TextDisabled | `#8FA6B8` | Disabled text remains readable, plus explicit unavailable reason |
| BorderInteractive | `#668398` | Boundaries needed to identify controls; lighter than decoration |
| BorderDecorative | `#30475C` | Nonessential separators only; not a focus or state cue |
| OnAccent | `#0B1420` | Dark text on solid cyan/green/amber/coral/purple buttons |

Derivation policy: surfaces progress Background → Panel → Raised; hover uses the next surface, pressed uses Panel plus an inset/outline, selected uses a narrow Accent marker and labelled state. Accent fills use OnAccent text. Muted/disabled text uses explicit solid tokens, not arbitrary opacity on a changing backdrop. Further colours must be added by semantic role and contrast-checked. Map terrain has its own muted green/ochre/stone art palette; UI status colours remain recognisable above it.

Calculated sRGB contrast ratios for opaque tokens (15 November 2026):

| Foreground | On Panel | On Raised | Rule |
| --- | --- | --- | --- |
| TextPrimary | 14.29:1 | 11.62:1 | Safe for normal text |
| TextSecondary | 9.26:1 | 7.53:1 | Safe for normal text |
| TextDisabled | 6.29:1 | 5.11:1 | Readable but noninteractive |
| Accent | 8.53:1 | 6.94:1 | Text/focus safe |
| Healthy | 6.41:1 | 5.22:1 | Text/icon safe, still label the meaning |
| Warning | 8.92:1 | 7.25:1 | Text/icon safe |
| Critical | 5.42:1 | **4.40:1** | Do not use normal-size coral text on Raised; use primary text and coral icon/border |
| Event | 5.84:1 | 4.75:1 | Text/icon safe |
| BorderInteractive | 3.98:1 | 3.24:1 | Suitable nontext control boundary |

Formula: linearise each sRGB channel (`c/12.92` when c≤0.04045, otherwise `((c+0.055)/1.055)^2.4`), luminance `0.2126R+0.7152G+0.0722B`, contrast `(lighter+0.05)/(darker+0.05)`. Target ≥4.5:1 normal text and ≥3:1 large text/essential control graphics. OnAccent against the five accent fills ranges from 6.31:1 to 10.39:1; white-on-amber/green is not the default. These calculations do not validate antialiasing, image overlays or actual device readability; check rendered states again. Use opaque label backplates over terrain.

Retain the current Gotham/GothamBold family initially; no font dependency needed. Proposed scale: page title 24–28, section title 18–20, primary body/control 16, metadata 12–14, KPI value 24–30 desktop or 18–22 compact. Avoid all-caps paragraphs and letter-spacing on small labels. Metadata cannot contain the only explanation of payment, warning or failure. Wrap long labels; expose full value/details instead of silently clipping. Text enlargement reflows, not just shrinks numbers with TextScaled.

Spacing grid 4px, normal padding 12/16, gaps 8/12, corners 6–8px; avoid pill shapes everywhere. Standard action height 44–48; compact artwork can be 20–24 inside a 44px hit target. Focus is a visible 2px outline with separation from status borders. Use consistent outline icons, 2px-equivalent stroke at nominal size; selection brackets/status glyphs differ in shape. No essential meaning resides in a decorative image.

## Common component protocol

Views receive display data, availability and callbacks. Controllers own local transitions; authoritative values arrive through explicit server-view-model adapters later. Shared fields: stable ID, label, status, data freshness, enabled reason, selected/focused state, accessible explanation and optional intent callback. Do not put currency debits, duration accrual, entitlement checks, simulation, news admission or remote validation inside component constructors.

Every interactive component defines normal, hover (when available), focused, pressed, selected, disabled and pending states. Disabled controls retain an explanation route without emitting the unavailable action. Pending controls prevent repeat submit but preserve navigation/cancel where safe. Loading, empty, error, stale and unavailable are different data states; an unloaded balance is `— / Loading`, not `0 Credits`.

Focus order follows reading/task order. Opening a modal traps focus and remembers its invoker; closing restores a still-visible invoker or a safe heading. A sheet is not automatically modal: observation sheets allow map interaction; confirmations suspend it. Invisible/clipped controls are not focus targets. Scroll focused items into view. Escape/B dismiss the topmost local layer and never submit; coordinate with Roblox core menus/native prompts. Disconnect all listeners when a component is destroyed; repeated remounts cannot create duplicate handlers.

## Component catalogue

| Component | Responsibility and inputs | State/interaction rules |
| --- | --- | --- |
| Header | Identity, grid status, simulated date, read-only clock status, alerts/help/settings/profile routes | Long identity truncates with details; compact overflow; service unknown cannot display healthy |
| NavigationEntry / group | Destination ID, icon, label, phase, selected state, optional factual count | Expanded/collapsed variants; active marker + label; future destination opens explanation; no promotional fake badge |
| KpiCard | Label, formatted/full value, unit, period, freshness, optional details route | Loading/ready/stale/error; full value via keyboard/tap; status accents subtle; numbers never animate through invented values |
| StatusBadge | Severity/status enum, icon, label, optional reason | Normal/Attention/Critical/Paused/Unknown and domain states remain explicit; colour never sole cue |
| ProgressIndicator | Server-reported bounded amount/total, period and state | Determinate only for known progress; paused/failed labelled; indeterminate text for unknown work; reduced motion static |
| NewsTicker | Bounded headline list, scope/topic, selected ID, playback/collapse preferences | Reading pauses rotation; stable identity/dedup; Open story separate from collapse; no focus stealing |
| AlertBanner / AlertList | Incident IDs, severity, cause, affected asset/region, action/ack state | Dedup/update same incident; acknowledgement not resolution; critical persists independently of news; see Layout severity rules |
| MapToolbar | Current mode, zoom, recenter/layer/legend intents | 44px controls; zoom limits disabled with reason; no invisible gesture-only action; tool input cannot drag map |
| LayerSelector | Primary layer, availability, optional labels, legend entries | Single primary layer; unavailable future data explained; close restores focus; mobile drawer/desktop popover same behavior |
| AssetMarker / cluster | Stable asset IDs, type icon, world position, known state, selected status | Screen-space hit target; overlap picker, noncolour state pattern; hidden latent faults never inferred |
| AssetInspector | Selection ID, summary, sections, permissions, blocked reasons | Empty overview, loading, ready, stale, removed; view variant changes only layout; preserve selection on resize |
| Button / icon button | Label/icon, intent, kind, enabled reason | Neutral/primary/destructive; no double action from keyboard plus Activated; pending text does not resize layout |
| ConfirmationDialog | Explicit subject, consequence, exact quote, current/resulting balance when relevant | Cancel default safe route; quote change requires new confirmation; sending/reconciling not duplicate resubmit |
| Tooltip / InfoPopover | Plain-language explanation, full value/unit | Hover shortcut only; focus/tap equivalent; dismissible and kept inside safe area; cannot cover its only close route |
| LoadingState | Task name and service state | Distinguish loading save, checking ownership, retrying and waiting for lease; no fake percentage; no indefinite animation without text |
| ErrorState | Actionable cause, retry availability, preserved-state explanation | Long body scrolls; no raw stack trace/private data in product UI; retries use existing operation identity |
| EmptyState | Successful empty result and useful next route | “No active event” / “No recent news” differs from network failure; no purchase upsell as recovery |
| SimulationStatus | Server clock condition, Paused/Delayed/Unavailable label only when relevant | **Read-only and conditional; no permanent Standard header label.** No selectable speed or paid 2× control |
| SeasonalIndicator | Event ID/topic, UTC end, availability, participation/progress freshness | Countdown from server deadline is display only; reconcile at expiry; no reward on timer reaching zero |
| ProductCard / ShopTabs / BoostStatus | Payment type, price state, duration model, eligibility, ownership/remaining-time view | Shared across devices; no client grant/timer authority; detailed states below |

Inspector actions and transaction confirmation are separate components: selecting an asset or product never counts as consent to buy, demolish, repair or reset. Ordinary loading/notice/error previews remain available through development Help while testing; clearly mark them Sample and keep them out of live operational status.

## Shop and purchase states

Common product copy: “Double Income · 2× eligible domestic electricity sales and exports. Operating expenses stay the same.” Expanded details list excluded grants, achievements, event currencies, rebirth points, energy and clocks. Explain that this increases earnings, not guaranteed net profit. Exact Credits and Robux prices are independent and must not imply a conversion rate.

Credits Shop is default, with amber/coin/text. Robux Shop is green/Roblox-appropriate icon/text and says Optional paid purchase. Entering or switching tabs never opens a purchase prompt. One initial product; do not add screenshot-only boosts or fake Coming soon products. Use scoped status badges, not large promotional banners.

| State | Display | Permitted action |
| --- | --- | --- |
| Preview (R5) | Sample product; price not set or explicitly illustrative; transactions unavailable | Explore mock details, no spend or native prompt |
| Checking price/ownership | Checking…; do not assume unowned or zero-price | Retry after failure; purchase unavailable while unknown |
| Available temporary | Exact server Credits price; 30 active minutes; Bank and protected-reserve implications | Review Credits purchase |
| Insufficient Credits | Exact price and shortfall; core play remains available | Return to Grid, not an automatic Robux upsell |
| Temporary active | 2× sales · mm:ss active time left; survives rebirth | Details; repurchase unavailable until expiry |
| Temporary paused | Remaining time plus paused reason | Resume route only if a supported server pause policy permits it |
| Permanent verified | Owned · Permanent · active across rebirths | Details; no repeated purchase, temporary purchase disabled |
| Native prompt open | Awaiting Roblox; no fabricated success | User controls native prompt; block duplicate prompt launch |
| Verifying/reconciling | Checking result; no re-charge/resubmit | Safe close; server resolves the same operation/ownership check |
| Cancelled | No completed purchase; unchanged local status unless server says otherwise | Return to product; a pending Credits operation still reconciles if already sent |
| Unavailable/off sale/error | Clear reason, no invented price or entitlement | Retry/read details; core gameplay available |
| Expired temporary | Benefit ended, no modal upsell | Deliberate repurchase available after authoritative expiry |

Temporary purchase transition: browse → review quote → explicit confirm → server pending → committed active, rejected, or reconciling. Once a command is sent, closing a window does not revoke a possibly committed purchase; the UI must say so and recover the result. Quote expiry, Bank change or new permanent ownership invalidates confirmation and requests a fresh quote; never silently alter price.

Permanent transition: browse → explicit paid-product review → native Roblox prompt → server ownership verification → permanent active. Cancelling/dismissing the prompt is not proof of a purchase. Pass ownership is established by the server/platform path, not a client boolean. If ownership cannot be checked, show Pending verification and block another paid prompt. Joining after an external purchase must reconcile without asking the player to buy again.

If a permanent pass is acquired during a temporary benefit, effective income stays 2×, never 4×. Confirmed R1 clarification: retain the unused temporary remainder dormant and show Permanent as dominant; no extra time, refund or transferable item is silently granted. This dormant-remainder policy is approved; live commerce itself remains unauthorized. Storage/timer protocol and crash-replay gates are in [Data/security](DATA-AND-SECURITY.md#energy-shop-persistence-and-authority-design-only).

Display countdown may interpolate between server snapshots for readability, capped at zero, but cannot decide grant, expiry, pause or renewal. Consume active online simulation time; ordinary menus do not pause it, and offline time is excluded. Use an active-time label so it is not confused with UTC event time or simulated hours. Expiry/resume reconciles from server revision; do not keep granting while a client animation says active.

### Roblox integration boundary, verified 15 November 2026

Passes are one-time Robux entitlements; the temporary Credits offer is an internal game transaction, not a repeat-purchase Robux developer product. See [Roblox passes](https://create.roblox.com/docs/production/monetization/passes).

The current API reference provides `GetProductInfoAsync`, `PromptGamePassPurchase` and `UserOwnsGamePassAsync`; it marks `GetProductInfo` deprecated even though the pass tutorial still contains older examples. A later adapter should use current APIs, handle failures and reverify server ownership after the prompt. See [MarketplaceService](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService).

Display Roblox-supplied player-appropriate prices, fetched in the appropriate client context for regional/personalised presentation; never hardcode a global Robux number. Treat that price as display data, not a client-authorized charge. Roblox's native purchase prompt handles payment. See [regional pricing](https://create.roblox.com/docs/production/monetization/regional-pricing). No IDs, product creation, settings changes or purchases are part of this task.

## Validation contracts

For each component, exercise all applicable states above at desktop/tablet/phone safe areas, including long names, large/full Credits values, 150% text, missing icons and server delays. Verify focus restoration, text bounds, 44px touch access, contrast, gesture exclusion, reduced motion, and no clipped confirmation/cancel. Loading errors never replace country data with defaults.

Integration invariants: one local shell after remount; no leaked connections; map input disabled beneath a modal; a queued notification cannot replace a purchase confirmation; closing a shop never cancels reconciliation; keyboard and pointer activation emit one intent; unseen/unauthorized assets never appear in layers. News/timer rendering does not trigger network calls every frame.

Live-commerce validation is deferred: identical 2× factor for both benefit sources, no stacking, expiry in a settlement interval, active/pause/offline transitions, crash/reconnect/lease races, rebirth preservation, pass obtained mid-boost, unknown ownership, price changes and duplicate request IDs. A UI mock passing does not prove any of these server guarantees. Use the phase gates in [Layout](GUI-LAYOUT-SPEC.md#migration-and-validation-plan) and [Testing](TESTING.md).

## Operations v1.3 control-room detail contract

The isolated Training console uses stable fleet cards, concise overview/cause-action text and existing 44px controls. Bank, generator costs/history, forecast samples and bounded server alerts are secondary live detail views using the shared feedback scroller. A detail update must preserve its focus owner and CanvasPosition; route/viewport changes may intentionally recalculate geometry. Do not rebuild a card on each snapshot or intermediate text fragment. Card measurement uses available width and text scale, not changing MW/Credit values. This changes presentation only; Training, Native map and all authority/economy contracts remain.

## Visual Redesign v1 shared components

`Theme` owns midnight background, panel/raised, cyan grid/selection, financial gold, healthy/warning/error, spacing and typography roles. The experimental palette is gated to Studio/Test10776833313. `Components.surface` explicitly applies restrained depth to chrome; never attach it indiscriminately to terrain. `action` distinguishes primary/financial/secondary intent; `selected` retains a visible outline and label. Existing outlined icons and44px controls remain.

`DetailRows` is a fixed20-row pool with section, key/value and narrative presentation. Values retain exact canonical public text, including financial carries/history descriptions; content beyond the pool remains in a measured text tail. It is display-only. Width/font measurements are cached; numeric snapshot changes reuse existing instances. The original canonical message remains available as a fallback. On narrow layouts values stack under labels. Scroll position is not reset by data updates.

`ProjectCategories` shares Connections, Generation Later and Storage Later tabs plus Cancel/Close review and the existing server-controlled confirmation/Refresh action. Closing a pending review is not cancellation of a committed purchase. Saving, uncertain, expired and already-built semantics remain owned by existing clients/server responses.

`InfrastructureDirectory` uses existing public nodes and built district only, with filters, current status, supported generator toggle and Locate. No condition/history/staff/upgrade claims. `OperationsView` uses stable fleet cards with separate name, prominent actual MW, status, available/cap/cost information and existing cap/On-Off/Locate/details controls. See the vision document for future Government/Staff/Shop/ticker contracts.

## Visual Redesign v1.1 components

NavigationIcon adds native Bank/power/alert/reserve and gas/wind/peaker symbols using bounded primitives; no uploaded assets. Technology identity is paired with text, not colour alone. Fleet output bars display completed public output divided by available output, clamped to [0,1]; zero availability produces an empty bar. They are cosmetic projections, never dispatch calculations. Exact output, availability, cap and costs remain textual.

Directory rows separate asset name from actual status and retain accessible labels and existing targets. Its generator bar uses the existing 5MW capacity. Financial rows retain the full canonical source message and measured overflow; compact geometry must still pass enlarged-text checks. No fake maintenance ratings or catalogue entries are added.


## Illustrated World v1 audit boundary

The owner accepts v1.1 chrome as the baseline; no further shell redesign is authorized. The [Illustrated World audit](ILLUSTRATED-WORLD-V1-VALIDATION.md) stops before renderer code at the explicit existing-art sufficiency gate. Frozen authored headland/1200×800 placements are not a generated-sector contract. The proposed shore-edge family, flat-coordinate pivots, same-lighting variants and bounded Test adapter are design handoff only. Native,44px targets, authoritative graph overlays, selection/camera and600 total descendants remain unchanged. No new atlas, upload, mode control or default renderer is implemented. See the report for exact gaps and owner-review options.


**Local artwork follow-up (D210/D211):** the audit boundary above is historical. Owner subsequently approved18 local motifs across the original main atlas and a two-diagonal companion. [Actual artwork and pixel/visual evidence](ILLUSTRATED-WORLD-V1-ART-VALIDATION.md) are ready for review; no upload, integration or visual/default adoption follows automatically. Native geometry/default, overlays,44px targets and600-descendant ceiling remain unchanged. Ground transitions and bounded shore-slot issues require review before a later renderer proof.
