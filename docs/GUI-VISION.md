# GUI vision — illustrated country, clear control room

17 November 2026 owner decision: R3.7 technical validation and illustrated settlement direction are accepted for continued development; Hybrid is still not the production default. [Procedural foundation](PROCEDURAL-GAMEPLAY-FOUNDATION.md) preserves Native fallback, fixed interaction anchors and separate cosmetic descriptors. Its procedural rendering proposal uses 600 total map descendants, superseding the older 600-objects-plus-200-labels planning target; no GUI changes are made.

R3.5 follow-up: R3.4 technical evidence is owner-accepted, but Hybrid is not approved as default. The [Test-only marker experiment and proposed terrain/settlement grammar](R35-VISUAL-COHESION.md) preserve this document's interaction and art-direction requirements; future artwork remains separately gated.

R3.1 update: the owner requested visual refinement after accepting R3 technically. Current native art/framing, 1,091 passing assertions and 574-map-descendant measurements are recorded in [R3.1 validation](R31-VALIDATION.md). The [modular art recommendation](R31-ART-STRATEGY.md) remains a proposal; no uploads or future gameplay are authorized. Historical R3 measurements below are retained.

15 November 2026 · Approved design requirements · R1–R3 implemented; later slices remain gated

The owner approved the three GUI specifications in the R1 request and separately authorized R2 shell composition and the R3 illustrated-map prototype. R1 supplies theme/Bank/Credits; R2 supplies responsive chrome, navigation and inspector/input behavior. D27–D40 in [Decisions](DECISIONS.md) record clarifications and implementation choices. See [R2 validation](R2-VALIDATION.md) for measured evidence and remaining device gates. R3 measurements support the bounded native prototype; a later sprite/hybrid approach remains possible after separate review. See [R3 evidence](R3-VALIDATION.md). Read with [Layout](GUI-LAYOUT-SPEC.md), [Components](GUI-COMPONENT-SPEC.md), [Economy](ECONOMY-AND-REBIRTHS.md) and [Data/security](DATA-AND-SECURITY.md).

## Experience and hierarchy

Power State should feel like running a growing fictional country from an approachable electricity control room. The country supplies warmth, identity and visible progress; the surrounding controls supply clarity and confidence. Use colourful, coherent illustration on the map and quiet, dark surfaces around it. Keep the game GUI-only.

Visual priority, in order:

1. Country map and the player's selected asset or construction task.
2. Grid status and actionable outages; Bank, supply/demand, reliability and population.
3. Contextual explanations and the next deliberate action.
4. Navigation, active income benefit and save/service status.
5. Ambient news and optional shop discovery.

Young and casual players should understand “Demand not served: 2 MW” before encountering reserve margin or dispatch terminology. Experienced players can expand the same inspector for units, timestamps, utilisation and accounting details. Do not replace precise units with ambiguous lightning scores. Prefer plain explanations, a visible consequence and one primary action per panel.

Avoid a generic admin portal: the illustrated map is the default destination, asset silhouettes have character, and region names make the country memorable. Avoid a dense engineering console: no ornamental gauges, fake waveforms, dozens of always-visible charts or unexplained stability scores. Use neither neon outlines on every panel nor a giant cinematic header that competes with the map.

## Reference review

All eight files under `Inspiration/` were visually reviewed. They are composition references, not approved asset libraries, economic values or promises of implemented systems. Do not crop them into production GUI textures; art provenance/licensing and a coherent modular asset set must be established separately.

| Reference | Adopt | Adapt or exclude |
| --- | --- | --- |
| `Grid Window.png` | Illustrated terrain, recognisable generator/settlement markers, grouped rail, contextual inspector | Reduce glow and permanent legends; show four primary KPIs, alerts in header; do not say Grid stable solely from a high reliability average when supply is short |
| `Build Window.png` | Placement ghost, explicit invalid reason, cost summary, Cancel/confirm | Avoid catalogue + expanded rail + wide inspector simultaneously; straight links first; storage, many technologies and staged construction remain phase-gated |
| `Infrastructure Window.png` | Searchable asset list, output/capacity pairing, View on map, contextual maintenance/history | Mobile uses rows/cards and a separate detail sheet; no tiny multi-column table; illustrative capacities and upgrade prices are not balance |
| `Government Window.png` | Policy/project cards and readable budget allocation | Retain one Bank balance; allocations are not extra money; elections, legislation and carbon promises need their own approved systems |
| `Staff Window.png` | Departments, assignment status and workload overview | Existing design uses teams, not individual employees/personality simulation; omit portrait roster and unapproved statistics |
| `Shop Window - Credits.png` | Amber Credits category, cost/duration and active-benefit status | Only Double Income is specified. Exclude construction/research/inspection boosts and fixed 25,000 price. Replace “all revenue sources” with eligible electricity sales |
| `Shop Window - Robux.png` | Green optional-purchase category, permanent badge, survives-rebirth explanation | Exclude extra passes/bundles and “not pay-to-win” claim; show actual Roblox price and disclose financial advantage |
| `Ticker.png` | Narrow broadcast-style identity, scope labels, readable headlines | One calm headline slot rather than a perpetual marquee; event is a topic within National/Server/Global, not a fourth routing scope |

The references depict a later game. Their dates, population, money, reliability, weather, helicopters, storage and live news must not become fake operational claims in a shell preview.

## Language and numbers

Approved user-facing labels: **Bank** and **Credits**. Example: `100,000 Credits`. Bank is the existing consolidated balance, not a banking subsystem or second currency. Existing internal cash keys can remain unchanged; the design-only task does not rename code. R1 updates the existing shell to Bank/Credits while retaining its placeholder-data architecture.

Use grouped thousands and a consistent formatter. R1 uses the current English UI convention (comma grouping, decimal point); locale-specific formatting remains a later localisation adapter, without changing minor-unit inputs. Compact display may use `1.25M Credits`; activation, keyboard focus or a tap-accessible details view exposes the exact value. Never abbreviate a purchase confirmation, budget commitment or remaining balance. No conversion between Credits and Robux is offered. Legacy points and previously proposed seasonal tokens are outside this shop; this task creates no new currency or token exchange.

Keep kW, MW, GW, MWh, GWh and TWh. Pair supply/demand with a common unit; never compare `7 MW / 0.009 GW` on one card. Define supply in details as delivered power, not installed capacity. Reliability has a named observation period and can be Unknown when history is insufficient. Dates are unambiguous (`15 Mar 2032`); simulated dates and real UTC event deadlines have distinct labels.

## Art direction and map system

Use softly shaded, slightly elevated illustrated terrain with a fixed viewing direction and consistent light from the upper left. Gameplay coordinates remain a flat 2D plane; relief is decorative. Hills must not visually move a connection endpoint. Country expansion adds compatible sector art, not a single stretched island picture. Avoid tiny moving people, smoke loops or costly animated water as baseline requirements.

| Terrain/content | Visual grammar | Gameplay distinction |
| --- | --- | --- |
| Coasts, ocean, rivers, lakes | Quiet blue water, clean shoreline rims, separate river ribbons | Crossing rules come from server terrain, not image alpha |
| Hills/mountains | Layered green slopes and pale peaks with one lighting direction | Bound footprints; keep network overlays above relief |
| Forest/farmland | Clustered tree silhouettes and muted field patches | Decorative variation never changes legality or demand |
| Village/town/city | Increasing building density and silhouette tiers | Tier changes follow authoritative development thresholds; no per-household objects |
| Industrial districts/ports | Distinct warehouse/crane clusters and shoreline anchors | No implied import/export unless the connection is actually available |
| Generators/substations/storage | Clear technology silhouettes plus standard overlay icons | Storage icon is distinct from generation; labels expose MW versus MWh |
| Undeveloped/frontier sectors | Quiet terrain, owned border, hatched locked boundary and quote affordance | Preview is bounded; locked territory cannot be built on |
| International/seasonal assets | Edge connector and labelled event badge | Ordinary capacity constraints still apply; expiry/status remains explicit |

R3 considered small raster terrain patches/sprite atlases, native GUI geometry and hybrid rendering with independent labels/hit targets. The implemented native prototype stays within its measured instance/draw budgets without uploads; later art refinement can revisit this choice (D38). Native Frame placeholders remain a fallback when art fails. Keep text, status, routes and hit testing out of baked textures. The later R3 request authorizes native illustrated artwork for the existing fixture; external art uploads still require explicit approval.

Partition by the versioned sector IDs in [World](WORLD-AND-EXPANSION.md). Render visible chunks plus the bounded margin; pool instances, apply stable chunk/revision identities, and retire stale cached art on resync. Decorative seed variation is cosmetic only; the renderer consumes authoritative descriptors and must not decide terrain costs, asset state or country ownership. Existing proposals of 600 visible objects plus 200 labels are ceilings to profile, not a target to fill. Count actual GUI descendants, including decorative pieces; prefer composited tile art to thousands of trees. Keep crossing lines visible when endpoints lie outside the viewport. Offscreen owned sectors continue to simulate on the server.

| Zoom band | Show | Suppress/aggregate | Selection |
| --- | --- | --- | --- |
| National overview | Terrain regions, major cities, trunk routes, regional service/alert summaries | Small assets and individual trees become clusters; weather/event symbols aggregate | Region/cluster opens summary; selected asset retains a locator |
| Regional view | Settlements, generators, substations, important links, regional names | Minor decoration and repeated labels reduced | Asset or nearest-asset picker for overlaps |
| Infrastructure detail | Sites, asset icons, connection endpoints, line direction/capacity on demand | Unrelated regional labels and far terrain | Exact asset/line selection with enlarged screen-space targets |

Choose zoom transitions by projected feature size, with hysteresis to prevent flicker; initial pixel thresholds must be tested in the rendering prototype. Do not use national overview to claim every link is uncongested. Keep marker targets at least 44 logical pixels even when art shrinks; cluster overlapping targets instead of allowing ambiguous taps. A selected offscreen asset remains in the inspector with Locate on map. Missing art falls back to labelled icons; missing data says Unavailable rather than zero.

## Energy Shop design contract

The shop is optional and never gates core grid play. Credits Shop opens by default on every new shop visit; tab switching is explicit. Amber + coin icon + “Credits earned in gameplay” identifies temporary purchases. Green + Roblox-appropriate icon + “Optional Robux purchase · Game Pass” identifies permanent purchases. Colour alone is insufficient.

Only **Double Income** is confirmed. It doubles eligible domestic electricity sales and eligible exports, with unchanged operating expenses. It does not multiply energy, generation, demand, population growth, maintenance, reliability, clocks, lifetime production, event contributions, grants, achievement rewards, event currencies or legacy/rebirth points. More Credits can indirectly fund expansion; never advertise that paid ownership has no competitive effect.

Credits version: 30 minutes of active online gameplay; server-saved remaining duration survives disconnects and rebirths; server-paused/offline time does not count; ordinary menus do not pause active online simulation time; repurchase after expiry. Permanent Game Pass: the same 2× benefit, across rebirths, replacing the need for temporary purchases. The two never stack. No additional income multiplier is authorized. Unused temporary duration becomes dormant when permanent ownership is acquired; the effective benefit never exceeds 2×. Exact pricing and crash/ownership recovery remain review gates in [Economy](ECONOMY-AND-REBIRTHS.md).

Show cost, duration, scope, state and confirmation before any deliberate purchase route. Use “Temporary · 30 active minutes” versus “Permanent · Game Pass,” not a bare “2×” badge. Show “2× sales income · 12:34 active time left” or “2× sales income · Permanent” near Bank, expandable into details. No upsell pop-up at expiry, outage, rebirth or insufficient Bank funds. Never auto-open a Roblox purchase prompt.

## Scope conflicts and design status

| Conflict | Resolution for these specifications |
| --- | --- |
| Brief §4.3 removes speed controls; §6/§16 request them and acceptance §18.8 asks for paid 2× maximum speed | Explicit simulation restriction governs: **no speed purchase or control**. Do not permanently show Standard in the normal header; show paused, delayed or unavailable states only when relevant. Acceptance §18.8 is superseded by Double Income design, recorded D22 |
| Old MVP excludes premium boosts | Retain P1–P4 scope; document a separately approved shop milestone after economy/persistence, not a hidden P1/P2 expansion |
| Proposed legacy +10% revenue track | On hold under no additional stacking; do not silently create 2.2× sales |
| Paused players versus fixed shared simulation rate | Standard rate is unchanged; define a server-owned country suspension contract before timers ship. Ordinary menus do not pause the simulation or boost; only server-known inactive/suspended simulation excludes time |
| 34–40px ticker versus 44px touch targets | Desktop mouse strip may be 36px; touch layouts reserve 44px or collapse into a 44px News control |
| Full expanded chrome versus map-majority requirement | Collapse rail/inspector before shrinking map; numeric examples in Layout show the width budget |

## Review and success criteria

The three GUI specifications are approved; replacing the shell still requires authorization for the relevant implementation slice. Success means a player can locate Bank, recognise a shortage, select an asset, reach a close/cancel control and distinguish Credits from Robux without coaching. Art is secondary to readability and truthful status.

R1–R3 are implemented under separate requests from the migration plan in [Layout](GUI-LAYOUT-SPEC.md#migration-and-validation-plan). R3 preserves the shell/input and placeholder-data boundary while replacing only the map presentation. Its measured native rendering choice, layer availability and limitations are documented in [R3 validation](R3-VALIDATION.md). Stop after R3; ticker, shop and live systems remain separately gated.

## Design acceptance and evidence

| Brief acceptance item | Specification coverage |
| --- | --- |
| 1. Visual hierarchy | Vision priorities and reference review above |
| 2. Desktop/tablet/mobile | Layout wireframes, breakpoints and numeric safe-area budgets |
| 3. Component responsibilities/states | Component catalogue, common protocol and shop state machine |
| 4. Illustrated map | Modular terrain, sector culling, zoom bands; Layout interaction/layer matrix |
| 5. Navigation/inspector | Grouped routes, phase dependencies, mobile More and asset-specific panels |
| 6. Persistent ticker | Desktop strip, scoped feeds, calm/static modes, separate critical alerts |
| 7. Bank/Credits | Approved documentation terminology; existing code deliberately unchanged |
| 8. Paid 2× speed | **Not retained:** conflicts with explicit §4.3 restriction; D22/D27 retain standard-speed simulation without a permanent header indicator; Double Income remains separate |
| 9. Architecture | Existing modules/authority preserved; proposed narrow renderer/commerce adapters |
| 10. Incremental implementation/validation | R0–R5 with separate review gates and live-commerce prerequisites |

Design-task checks performed on 15 November 2026: all eight local references reviewed; proposed opaque theme contrasts calculated using the stated sRGB formula; 40 source/test/script/config/reference/asset files compared by SHA-256 with no change, including AGENTS.md; local Markdown file/anchor links checked; Git whitespace check run. These checks validate documentation and preservation, not a redesigned running GUI. P1's 98/80 runtime results were not rerun or reattributed to the design. No code, tests, dependencies, game settings, passes, purchases, commits, pushes or published content changed.

Created: GUI-VISION.md, GUI-LAYOUT-SPEC.md, GUI-COMPONENT-SPEC.md. Updated: README.md, PLANS.md, UI-UX.md, DECISIONS.md, ECONOMY-AND-REBIRTHS.md, DATA-AND-SECURITY.md, TECHNICAL-ARCHITECTURE.md, TESTING.md, ELECTRICITY-SIMULATION.md, MULTIPLAYER-AND-NEWS.md and COMPANY-PROFILES.md. Terminology-only alignment also touched GOVERNMENT.md, INFRASTRUCTURE-AND-STAFF.md, EVENTS.md and TUTORIAL.md. Existing P1 validation/setup records remain unchanged. AGENTS.md needed no new enduring instruction and was preserved.

## Visual Redesign v1 — isolated Test presentation (19 November 2026)

The eight `Inspiration/` concepts guide chrome and hierarchy, not country data or gameplay. Use midnight/navy layered native panels, cyan grid/selection accents, gold financial actions, and text plus colour for status. Preserve the real procedural map, native terrain and electrical anchors. Live values update mounted components; they do not reconstruct screens. The Test identity and temporary Training identity remain explicit.

Implemented: shared chrome depth, KPI accents, selected navigation and infrastructure outline, fixed reusable financial rows, construction categories and explicit cancellation, an actual-asset directory and responsive three-generator control room. New artwork is not part of this sprint. See [validation](VISUAL-REDESIGN-V1-VALIDATION.md).

### Future screens — visual specification only

Government: header with country identity; inner tabs Overview, Policies, Projects, Priorities, Legislation. Desktop uses an information list and selected proposal panel; narrow screens use one column and a back action. Until approved data/services exist, show `Coming later` and explanatory text; no approval rating, budget, policy effects or actionable approval controls.

Staff: reuse the asset-list/detail pattern for future departments and selected staff. Reserve sections for assignments and qualifications without inventing employees, wages, condition or maintenance histories. No hiring/assignment controls in the current build.

Shop: separate Credits and Robux tabs, bounded offer cards, clear eligibility and confirmation space. Example concept prices are not approved prices. Future temporary 2× Income consumes 30 active online simulation minutes; ordinary menus do not pause it. Permanent Double Income makes remaining temporary duration dormant. Maximum effective multiplier is 2× and applies only to eligible electricity sales; costs, grants, rewards and rebirth points are excluded. No speed boosts, purchases, entitlement checks or transactions are implemented.

Ticker: future single-line headline component, source badge (National / Server / Global), timestamp and accessible open/dismiss controls; bounded queue and detail drawer, paused motion for accessibility. On mobile use a compact alert entry rather than sacrificing map height. No running feed, fake headlines, cross-server service or fabricated events in this sprint. Delivery, moderation, rate and retention rules require later approval.

## Visual Redesign v1.1 — reference polish

Owner accepts v1 as the technical foundation. This Test-only pass strengthens native composition: wide-screen Power State wordmark separated from actual country identity; compact grouped rail; semantic KPI symbols; technology-marked fleet cards with actual/available output bars; structured asset rows and investment reviews. It does not import fictional concept values, flags, dates, condition, maintenance or staff. Natural procedural terrain remains deliberately unchanged. [Comparison and validation](VISUAL-REDESIGN-V11-VALIDATION.md).


## Illustrated World v1 audit boundary

The owner accepts v1.1 chrome as the baseline; no further shell redesign is authorized. The [Illustrated World audit](ILLUSTRATED-WORLD-V1-VALIDATION.md) stops before renderer code at the explicit existing-art sufficiency gate. Frozen authored headland/1200×800 placements are not a generated-sector contract. The proposed shore-edge family, flat-coordinate pivots, same-lighting variants and bounded Test adapter are design handoff only. Native,44px targets, authoritative graph overlays, selection/camera and600 total descendants remain unchanged. No new atlas, upload, mode control or default renderer is implemented. See the report for exact gaps and owner-review options.


**Local artwork follow-up (D210/D211):** the audit boundary above is historical. Owner subsequently approved18 local motifs across the original main atlas and a two-diagonal companion. [Actual artwork and pixel/visual evidence](ILLUSTRATED-WORLD-V1-ART-VALIDATION.md) are ready for review; no upload, integration or visual/default adoption follows automatically. Native geometry/default, overlays,44px targets and600-descendant ceiling remain unchanged. Ground transitions and bounded shore-slot issues require review before a later renderer proof.
