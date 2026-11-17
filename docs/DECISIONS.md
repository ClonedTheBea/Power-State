# Decisions, questions and risks

Created 15 November 2026. This is the approval/status register. The owner's supplied brief confirms requirements. The subsequent explicit P1 request authorizes the foundation and initial visual choices below; future-system defaults remain proposed.

## Confirmed baseline

C01: Roblox/Luau, GUI-only, desktop/tablet/mobile, separate fictional countries with an existing imperfect grid.

C02: Physical network delivery with regional aggregated demand; generation alone earns no revenue; authoritative economy/simulation/rewards.

C03: Procedural bounded expansion, Government, maintenance/staff, storage/trade/weather, optional National Eras, permanent history, company profiles/rankings, three news scopes and data-driven global events.

C04: Fully skippable/replayable tutorial and incremental modular development. Operation Christmas Cheer runs annually 1–23 December and exports actual surplus through a temporary Lapland connector.

C05: The original bootstrap task created documentation only. The subsequent owner request authorizes P1 implementation, local validation and documentation updates only. No dependency installation, publishing, deployment, commit or push was performed. Stop before P2.

## P1 implementation decisions — 15 November 2026

Authorization: owner's explicit P1 request, including modular Luau, existing source conventions, dark dashboard styling, responsive mobile layout and no unnecessary dependencies. These are implementation choices within that scope, not approval of future mechanics. No data migrations are needed: P1 creates no persistent state.

- **D01 (P1 portion implemented):** plain strict Luau modules, separate Views/Controllers/shared presentation utilities and a minimal server entrypoint. No framework or gameplay remotes. Server mutation queues/domain services remain future work.
- **D12 (initial visual portion implemented; visual review pending):** navy/charcoal theme, mint accent, map-first dashboard, desktop inspector, tablet overlay and phone sheet/menu. Readings carry preview labels. Adviser identity, tutorials and full play flows remain deferred.
- **D17 (P1 choice implemented):** retain owner's Rojo 7.7.0 Rokit pin and mappings; observed Studio plugin 7.7.1. Dependency-free Studio assertions plus PowerShell build/boundary checks. No formatter or standalone Luau analyzer installed; Studio Script Analysis supplies engine-aware diagnostics. CI deferred.
- **D18 (P1 presentation boundary implemented):** authored static map geometry and frozen preview data live on the client. Shared Layout/MapTransform operate on presentation dimensions only. These are not country state, a solver or an authoritative catalog. Future server view models can replace the preview without moving gameplay decisions into controllers.
- **D19 (P1 input/layout implemented):** use CoreUISafeInsets; compact navigation below 700 logical pixels wide or 500 high, tablet below 1100 wide, desktop otherwise. Minimum 44-pixel interaction targets, scrollable details, bounded pan/zoom. Single-pointer drag and explicit zoom buttons do not require pinch. Tab/Shift+Tab and Enter cover registered controls; gamepad and actual hardware validation remain pending.

Verification/consequences: [P1 validation](P1-VALIDATION.md) records evidence and limitations; [Studio setup](STUDIO-SETUP.md) explains the isolated test build. The normal mapping excludes tests. Future balance values and algorithms remain unapproved.

## GUI redesign decisions — 15 November 2026

Source: owner's supplied **Power State — GUI Redesign Specification** and local Inspiration images. This follow-up authorizes design/documentation only, not GUI replacement, gameplay, dependencies, pass creation, monetisation settings, purchases, commits, publishing or deployment. Existing P1 implementation/tests are preserved. Confirmed product requirements below do not imply approval of every engineering default.

| ID / status | Decision and rationale | Consequences / approval gate |
| --- | --- | --- |
| D20 · confirmed terminology | Bank replaces Treasury in user-facing design; Credits replaces `cr`; exact values remain accessible | One consolidated balance, no new currency; internal cash keys unchanged; P1 copy changes await implementation task |
| D21 · confirmed product design | Optional Energy Shop; Credits default/amber; Robux secondary/green; temporary 30-active-minute and permanent Game Pass Double Income | Only eligible domestic/export sales ×2; expenses/energy/rewards unchanged; no prices/pass IDs or commerce implementation authorized |
| D22 · conflict resolved from explicit restriction | Brief §4.3 removes all simulation-speed controls; this overrides conflicting §6/§16 and acceptance §18.8 | Original read-only Standard indicator proposal superseded by D27; **paid 2× maximum speed is not specified or retained**. All countries use standard rate; D03 exact clock still proposed |
| D23 · confirmed no stacking / held old proposal | Temporary/permanent Double Income never stack; no additional income multiplier approved | Prior proposed legacy revenue +10% track held, not silently combined into 2.2×. Other upgrade tracks remain proposals |
| D24 · proposed, review pending | Illustrated modular sector map; map-first responsive chrome; contextual inspector, grouped rail, mobile five-item nav and calm ticker | Dimension/content budgets, rendering prototype and accessibility/device validation before replacement; no giant baked map or extra framework |
| D25 · proposed commerce engineering, review pending | Fenced atomic Credits debit/grant, active-time remainder outside era reset, timer/income checkpoint consistency and server/platform pass verification | Live implementation only after ledger/persistence. D30/D31 resolve ordinary-menu and dormant-remainder behavior; rollback exposure and ownership outages remain open |
| D26 · proposed migration, review pending | R1 tokens/copy → R2 layout/navigation → R3 map → R4 ticker/alerts → R5 nontransactional shop preview | Each slice separately authorized/reviewed; future live features remain phase-gated; preserve current successful shell/tests |

### Conflicts and remaining choices

- Screenshots are visual references, not feature approvals: exclude additional boosts/passes, “all revenue sources,” “not pay-to-win,” fixed 25,000 Credits price, individual staff simulation and implied unrestricted technology availability.
- Premium boosts were formerly excluded from MVP. D21 confirms their eventual design, but does not expand P1–P4 implementation. A new separately approved commerce milestone is proposed after P3, with export/rebirth integration in P6a/P8.
- No speed upgrade exists. The mention of paused players requires a future server-owned country-suspension policy; opening a local menu cannot freeze only the benefit while earnings continue. D30 now confirms ordinary menus do not pause active online simulation; background/server-suspension implementation still needs testing.
- Temporary remainder and permanent entitlement survive rebirth. D31 approves dormant remainder on mid-boost pass acquisition; no refund/extension is assumed.
- Credits price/banding, Robux pricing configuration, operating reserve protection and Bank leaderboard financial-advantage disclosure need balance/release review. No paid/free competitive equality is claimed.
- Existing seasonal currency proposals remain outside Energy Shop and unapproved as new currencies here. No Credits/Robux/token exchange is added.
- Desktop ticker target 34–40px conflicts with touch minimum: proposed touch variant uses 44px or a collapsed News control. Expanded chrome must collapse before consuming the majority map area.

Affected documents: [Vision](GUI-VISION.md), [Layout](GUI-LAYOUT-SPEC.md), [Components](GUI-COMPONENT-SPEC.md), UI-UX, Economy, Data/security, Architecture, Testing, multiplayer/profile terminology and PLANS. No persisted schema migration occurs in this documentation task; future commerce schema/migrations require fixtures and version review. Required evidence is in the layout migration plan.

## R1 authorization and clarifications — 15 November 2026

Source: owner's explicit **R1 — Theme Tokens and Bank/Credits Presentation** request. The three GUI specifications are approved authoritative design requirements, subject to the clarifications below. R1 implementation only is authorized; R2, R3 art, shop/commerce, gameplay, dependencies, commits, pushes and publishing are not authorized. This status supersedes the earlier design-only review-pending status for D24/D26 without authorizing their later implementation slices.

| ID / status | Confirmed decision | Consequence |
| --- | --- | --- |
| D27 · approved | No permanent read-only Standard simulation indicator in the normal header | Show pause, delay and unavailable states when relevant; no speed controls; supersedes D22's persistent-indicator wording |
| D28 · approved future layout | Government inner tabs: Overview, Policies, Projects, Priorities, Legislation | Future phase only; no Government UI or legislation gameplay in R1 |
| D29 · approved constraint | Keep illustrated-map rendering technology flexible until R3 performance tests | Sprite/GUI/hybrid approaches are candidates, not a locked choice; current map preserved |
| D30 · approved timer semantics | Consume active online simulation time; ordinary menus do not pause boosts; offline time excluded | Server authority and actual suspension still govern future timers; R1 implements no timer |
| D31 · approved transition | Remaining temporary duration becomes dormant on permanent Double Income acquisition | Effective benefit never stacks beyond 2×; removes the earlier dormant-policy approval question |
| D32 · R1 implementation | Pure minor-unit currency formatter, compact labels with an exact-value Bank details control, approved semantic palette | Presentation only; English comma/decimal formatting initially; invalid/missing amounts show Unavailable; no economy authority |

R1 preserves P1 geometry, map/navigation input and existing test assertions. Normal body text/status colours follow the approved contrast pairings. The startup-failure fallback deliberately retains two matching colour literals so a broken Theme module cannot prevent error display. No save migration is needed. See [R1 validation](R1-VALIDATION.md) for actual evidence and remaining Studio checks.

R1 validation follow-up: the installed Studio analyzer rejects `read` field modifiers in the Preview type. Use ordinary typed fields for compatibility; PreviewData continues to freeze its fixture, arrays and records at runtime. This changes no presentation behavior or authority boundary. All four suites passed after the fix and edit-mode Script Analysis reported zero errors/warnings.

## R2 authorization and implementation — 15 November 2026

Source: owner's explicit **R2 — Responsive GUI Shell Composition** request, including the additional requirement to reduce empty header space at short desktop resolutions. This authorizes only shell composition, input/accessibility, regression checks and documentation. Stop before R3/R4/R5/P2. No commit, push, publish, deploy or dependency installation is authorized.

- **D33 (implemented within R2):** use the approved safe-area breakpoints with a 64px wide / 56px compact desktop header, 48px phone and 44px short header at default text size. Identity, country/preview state and utilities share this compact row. Four operational cards become two on phone and Overview details on very short layouts. R4 ticker receives no empty reserved strip. This refines the initial 64–72px desktop target in response to the owner's explicit map-height priority; tests now assert the new geometry.
- **D34 (implemented within R2):** ShellState owns only local route, selected asset, inspector stage, rail preference and input mode. Close/peek/expand/navigation never clear selection. Map resizing preserves world centre and zoom subject to existing edge clamps; only Recenter deliberately resets the camera. Overlay inspectors do not resize the map; sufficiently wide layouts may dock. No save migration or authoritative state is introduced.
- **D35 (implemented within R2):** reusable Header/KPI/Navigation/Drawer views compose the shell; keyboard focus and explicit gamepad map input have separate controllers. Modal focus is bounded with invoker restoration; accessible asset list complements spatial targets. Local 100/125/150% text choices reflow content and remain session-only. The shell temporarily hides Roblox's PlayerList because its Tab shortcut conflicted with shell traversal in Studio, and restores its previous setting on teardown. Roblox menu/chat remain available. The shell owns one gamepad activation path and disables/restores default game GUI navigation while mounted, avoiding competing D-pad/A handlers. CoreGui navigation remains untouched. Focus changes wait for layout and discard stale targets after rapid resize/close.
- **D36 (implemented preview boundary):** Build explains its P3 dependency over the same map; other future destinations show their phase and unavailable state. Energy Shop is only a route explanation, with no R5 product UI. No normal Standard indicator, fabricated date, live alerts or live country statistics are added. Existing authored terrain remains untouched by the R3 illustration plan.

- **D37 (R2 device-validation fix):** while mounted, set the local PlayerGui screen orientation to Sensor and restore its previous setting on teardown. The inherited landscape-only setting prevented portrait device validation despite responsive geometry. This enables the authorized portrait/landscape interaction without changing the place's Rojo mapping or publishing settings.

Affected files/observed validation and remaining hardware checks: [R2 validation](R2-VALIDATION.md). These decisions supersede P1 layout/reset behavior and the earlier R1-only authorization for this bounded slice; all gameplay, commerce and rendering decisions remain separately gated.

## R3 authorization and implementation — 15 November 2026

Source: owner's explicit **R3 — Illustrated Country Map Prototype** request, confirming R2 automated validation and desktop visual acceptance. R3 only is authorized. No external art uploads, commits, pushes, publishing, deployment or future-phase gameplay are authorized.

- **D38 (R3 measured implementation):** retain native GUI artwork for this bounded prototype. A versioned immutable 17-patch cosmetic fixture feeds reusable MapArt/TerrainRenderer modules, with separate infrastructure, link, label and interaction containers. Measured population is 448 map descendants; a hard 600-descendant map ceiling includes decorators. Fixed pools avoid allocation during pan/zoom; culling uses conservative patch bounds and a 64-world-unit overhang margin. This resolves D29 for R3 only; it does not approve unlimited scale or rule out a later measured sprite/hybrid renderer. No asset upload or dependency is required. All mapped positions/IDs remain unchanged; no persisted migration occurs.
- **D39 (R3 truthful layers):** Geography is the only available primary layer. Labels and sample connections are local optional overlays. Power flow, demand, condition, development, weather and events expose explicit unavailable explanations rather than invented analysis. Layer selection uses the existing responsive drawer/focus contract, including desktop, instead of a second popover implementation. Selection and camera survive overlay changes. No ownership or operational state is inferred from art.
- **D40 (R3 selection/detail):** fixed 44px marker targets, stable overlap representatives opening Assets, separately drawn selection brackets and an offscreen locator. Locate explicitly centres the camera on the selected asset subject to existing edge clamps while preserving zoom and closes its inspector to reveal the map. Zoom detail uses hysteresis to avoid flicker; overview reduces decoration/labels without hiding primary fixture assets. Label collision suppression cannot remove the Assets/inspector name route. On safe-root resize, clear and rebind native selection after two render frames to the visible modal/inspector close control or previous control; this prevents stale focus outlines during orientation changes without changing asset selection or map coordinates. Verified by regression and phone emulation.

Validation and limitations: [R3 report](R3-VALIDATION.md). Native geometric art is simpler than the reference; owner visual review and real-device performance remain gates. Server sector revisions/resync, procedural territory, construction, simulation, R4 ticker and R5 shop remain unimplemented.

## R3.1 authorization and refinement — 15 November 2026

Owner review accepted R3 technically but found its visual result too simple. The explicit R3.1 request authorizes focused native art/camera refinement and an asset investigation; it does not authorize external uploads or later phases.

- **D41 (implemented R3.1):** frame after initial layout settles, use the cosmetic 1000×610 envelope and full existing zoom range for Recenter, with y=390 framing centre. Keep world coordinates, later-resize preservation and clamping unchanged. Portrait minimum-zoom cropping remains deliberate and navigable.
- **D42 (implemented R3.1):** refine native art with 22 cosmetic patches and 574 map descendants, retaining the 24-patch/600-descendant limits, separate layers and fallbacks. Art revision 2 changes no saved/gameplay schema. Cosmetic roads/pylons do not establish network connectivity or construction legality.
- **D43 (recommendation, not upload approval):** a modular raster terrain/native overlay proof is the preferred next step toward the reference's painted finish. Native geometry remains available and serves as fallback. The asset specification, provenance/pivot/edge contracts and performance approval gates are in [R3.1 art strategy](R31-ART-STRATEGY.md); no sprites or upload IDs are introduced.

See [R3.1 validation](R31-VALIDATION.md). Stop after R3.1; owner visual acceptance and real-device checks remain outstanding.

## R3.2 art-proof planning — 15 November 2026

- **D44 (authorized scope):** the owner requested R3.2 planning deliverables only after R3.1 technical completion. No artwork production, renderer implementation, asset upload or external Roblox IDs are authorized by this task. Keep R3.1 as baseline/fallback; stop after planning.
- **D45 (proposed, pending review):** narrow D43's broader art candidate to six motifs in one 1024×1024 atlas, with six pooled ImageLabels and retained native fallback (estimated 580 map descendants). Separate art revision/pivots from stable asset coordinates. Test one coast join, bounded loading failures and same-device A/B performance. No full procedural compatibility or performance gain is claimed.

The [R3.2 plan](R32-ART-PROOF-PLAN.md) contains the atlas layout, provenance requirements, implementation stages and acceptance gates. Review the actual artwork and destination before any later upload; planning completion grants no later-phase approval.

### R3.2 local artwork production — 15 November 2026

- **D46 (owner-authorized scope, delivered local candidate):** the later local-production request approves D45's six-motif atlas dimensions, rectangles, pivots and gutters for local production only. Store generated original rasters, exact prompts, checksums and an editable six-layer OpenRaster alongside exports. No runtime source, upload, Roblox IDs or dependency installation. This extends D44's historical planning scope, not upload or implementation authority.
- **D47 (observed limitation, not visual approval):** local artwork packing passes 70 assertions, but the native-coast proxy exposes a painted/flat grass seam and abrupt joins. Retain the candidate and a targeted revision handoff; do not call it integration-ready or change world coordinates/render order to conceal the problem. Owner style acceptance and Studio/device evidence remain pending. See [local artwork validation](R32-LOCAL-ART-VALIDATION.md).

### R3.2a coast refinement — 15 November 2026

- **D48 (owner-approved visual scope):** the R3.2a request accepts revision-1 forest, ridge, agriculture, settlement and gas-station for proof use; coast remains unaccepted for integration. Only coast artwork/local materials may change. This grants no upload or runtime implementation approval.
- **D49 (local result, pending coast acceptance):** deliver atlas revision 2 with cooler coast grass and unchanged descriptor geometry; retain the five accepted motif bytes. Local central colour mismatch falls 37.93%, but texture/shoreline seams remain and strict interior/endpoint opacity gates fail. Preserve generated alpha and report limits rather than claim seamless integration. See [R3.2a validation](R32A-COAST-VALIDATION.md); precise raster-paint endpoint/opacity work is the recommended follow-up.

### R3.2b local raster correction — 15 November 2026

- **D50 (owner-authorized local correction):** the R3.2b request permits deterministic raster compositing of coast grass/overlap using fixed native geometry. Preserve exposed rocks, shore, lighting, atlas descriptors and the five accepted motifs. Generated alpha preservation from R3.2a is superseded only for the requested grass opacity/occluded coverage correction. No runtime, uploads or later-phase authority.
- **D51 (observed result, coast acceptance pending):** revision 3 corrects the inspected grass seam and source overlap opacity. Both 16-unit source endpoint bands and inland sample are alpha 255; central sampled RGB mismatch is zero. Preserve the southern 4× filtered alpha-254 failure and abrupt cliff-to-native-shore visual transitions as open limitations. Do not call mathematical source coverage full visual acceptance. See [R3.2b validation](R32B-COAST-VALIDATION.md).

### R3.3 isolated renderer proof — 16 November 2026

- **D52 (owner-approved scope):** revision-3 coast and the other five motifs are accepted for an isolated integration proof. This supersedes their pending proof-use acceptance status, not upload, publishing or production-map adoption. Keep the original art-package records/checksums as historical evidence; current approval is recorded here.
- **D53 (implemented mock boundary):** frozen six-motif descriptors, six pooled noninteractive ImageLabels sharing the native world scale, and default-empty native replacement ownership. Test-only comparison mounts in Studio; production Bootstrap never attaches it. No hosted ID exists, so Image stays empty and injected readiness displays clearly labelled synthetic footprints. No actual texture loader/network request is introduced under this task.
- **D54 (placement/fallback/lifecycle):** preserve half-world-unit origins through scale coordinates in the fixed 1200×800 terrain root; integer UDim2 offsets round them. Coast order is shores < coast sprite < native meadows. Suppress both native west-cape bundles only when mock-ready; restore current culling on fallback. One readiness attempt per mount, five-second deadline, pending-mode cancellation and late-callback invalidation; remount to retry. Cleanup restores original ordering/render function and releases instances/connections.
- **D55 (evidence limits):** engine regressions and synthetic benchmarks prove cosmetic state/geometry/pool behavior, not Roblox asset delivery, filtered image quality, texture memory or GPU cost. Proceed to real atlas testing only after a separate checksum/destination-specific upload approval and real-adapter task. See [R3.3 validation](R33-VALIDATION.md).

### R3.4 real texture proof — 16 November 2026

- **D56 (owner-authorized scope):** real-texture loading and comparison only in Studio client mode for Test universe `10776833313`. Production `10776828545` stays Native and must not be synced, published or reconfigured under this task. The local production Rojo server was stopped before shared-source edits; only the test mapping is served.
- **D57 (asset identity correction):** upload `105986918888502` is a Decal (Roblox AssetTypeId 13), despite the uploader's Image label. Read-only Test Studio inspection of its Texture/ColorMap returned Image `86222383311104`; public metadata confirms type 1, same atlas name and personal creator `149564436`. This is the image dependency of the exact approved upload, not additional artwork. Preserve both identifiers and the source checksum in evidence; no permission changes or re-upload.
- **D58 (loading boundary):** test-only RealAtlas owns the URI and asynchronous ContentProvider adapter; shared renderer only accepts optional injected presentation. Existing one-attempt/five-second loader lifecycle remains. Require fetch success and all six ImageLabel readiness checks before replacing native bundles. Ignore late engine work and release observers on cancellation/destruction; native returns if actual readiness is lost. No gameplay authority or camera state changes.
- **D59 (owner-directed future art workflow):** prepare local artwork and upload instructions, but the owner performs future Roblox uploads and supplies resulting IDs. Automated Creator Dashboard uploads require a specific new request. This supersedes any expectation of automatically performing future uploads after general art approval.

### R3.5 visual cohesion — 16 November 2026

- **D60 (authorized isolated experiment):** owner accepts R3.4 technical validation but withholds Hybrid default approval. R3.5 adds only a Test-mapped presentation decorator; production source, artwork, anchors and mappings remain unchanged. A 22px badge exposes building art inside each original 44px target; contextual names respond to selection/hover/focus. Existing brackets/focus treatment remain instead of adding a competing ring. Native/loading/failure restore baseline markers. Five fixed bundles add 15 descendants, bounded at 595 map descendants. This is a review candidate, not production adoption.
- **D61 (proposed future art contract):** replace conflicting native regions incrementally with modular compatible motif families; separate settlement art tier/pivot/footprint revisions from stable settlement and electrical anchor identities. Server development data determines eventual tier; art never calculates growth, demand or connectivity. Village/town/city/industrial visual grammar and acceptance checks are in [R3.5 treatment](R35-VISUAL-COHESION.md). No future art, progression system, atlas repacking or upload is authorized by documenting this proposal. Owner handles any future uploads under D59.

- **D62 (16 November 2026, owner-authorized local study):** the R3.6 request accepts R3.5 technical results and prefers smaller badges/contextual labels, subject to final device testing. It authorizes two local settlement candidates and a limited terrain-transition study, not runtime integration, atlas replacement, uploads or Hybrid default adoption. [R3.6](R36-ART-STUDY.md) retains the frozen six-motif atlas and separates candidate art pivots from unchanged terminals. Proposed six-slot comparison profiles restore native forest/fields while reviewing settlements rather than adding instances to the 595-descendant proof. This comparison tradeoff and any later pool redesign remain proposals, requiring implementation authorization and fresh measurements. Owner art review, exact edge/pivot checks and later real-device validation remain gates; owner uploads under D59.

- **D63 (16 November 2026, R3.7 owner decision):** Southbank and Eastmere R3.6 artwork are accepted for isolated proof use; terrain transitions are artistic direction only. Prepare the exact two-settlement PNG for owner upload, preserving accepted pixels and all electrical IDs/anchors. Southbank local placement pivot changes from120,160 to150,182 to align its silhouette within existing culling bounds; Eastmere remains unchanged. [R3.7](R37-VALIDATION.md) stops at the upload boundary with no runtime changes or invented ID. Six-slot replacement is the prepared bounded comparison contract, not evidence of an implemented profile. Real texture, interactions, fallback and performance require subsequent Test integration/validation; Native stays production default.

- **D64 (16 November 2026, authorized R3.7 continuation):** the owner supplied Decal 138420314032574 and authorized isolated Test integration. Unparented InsertService inspection resolves Texture/ColorMap to Image 90608851718773; both Roblox metadata records identify missawfulname/149564436. A Test-only profile renderer keeps six fixed labels and cancels prior loading before reassigning slots 3/4 from forest/fields to the accepted settlements. Native replaces displaced/failed illustrations. The original frozen six-motif manifest, renderer and production source are unchanged. Keeping the experimental two-atlas implementation in tests avoids widening production contracts during this proof; consolidation requires a later approved adoption decision. Native remains default, no permission changes or uploads are authorized, and engine/device evidence must remain distinct from synthetic faults.

## Procedural world and gameplay foundation — 17 November 2026

Source: owner's **Procedural World and Gameplay Foundation** request. This authorizes documentation only; no P2/R4/R5 implementation, source edits, art uploads, production changes or publication. [Design package](PROCEDURAL-GAMEPLAY-FOUNDATION.md) records deliverables and risks.

| ID / status | Decision / rationale | Consequences and remaining gate |
| --- | --- | --- |
| D65 · owner-confirmed | R3.7 technical results and illustrated settlement direction accepted for continued development; Native remains default. New country: curated random settlement name, temperate environment, one small settlement/generator/substation, connected sufficient supply, reproducible country and fair early opportunities | Supersedes old three-settlement opening proposal and “imperfect grid” as an initial forced shortage. Demo IDs/anchors remain unchanged; old 7 MW case remains a regression fixture. Numeric ratings/population are not approved |
| D66 · proposed engineering | Seed/version-pinned absolute-coordinate fields, bounded starter reservation/candidate search and safe fallback; persist player deltas/tombstones and selected names independently of art | Review hash/kernel/golden vectors, country uniqueness semantics, fairness thresholds and migration retention. Proposed 600 total map descendants replaces incompatible older 600 objects + 200 labels target; no higher budget or renderer change authorized |
| D67 · owner-confirmed inputs; proposed model | Climate includes temperature/rainfall/elevation/coastal exposure/wind/renewable/geological resources; gradual biomes and temperate start. Demand depends on population/hour/season/temperature/HVAC/activity/industry/efficiency/events | Component MW model, 365-day calendar, coefficients/curves and seeded anomalies in Climate and demand are proposals. No permanent biome demand multiplier; artwork remains non-authoritative |
| D68 · proposed first simulation contract | One healthy lossless network; fixed P2a demand and optional validated On/Off intent; actual routed delivery, shortage, bounded reliability and nonspendable sales/cost estimate | D02 solver and D03 clock remain approval gates; 3 MW ratings/.75 MW demand/1,000 residents are candidates. P3 still owns spendable income/costs and persistence; no shop multiplier or full technology model |
| D69 · proposed sequencing | Split P2 into small interactive fixed-start proof, then seed-generated start/climate-aware demand; sector acquisition remains P5a | Supersedes earlier “all procedural work waits until P5a” proposal only at design level. No phase starts automatically. P3/P4 retain full saved first-playable loop |
| D70 · confirmed future direction; proposed lifecycle | Planning applications support approve/defer/conditional/reject and eventual staff review; national events must change actual demand and have imperfect forecasts | State machines, limits, estimates/reservations, uncertain event realizations and scheduling are proposals. Neither system enters initial simulation; no political values/rewards/automation approved |

No existing save migration or code change occurs. Future persistence must retain pinned generator versions and coordinate identities; do not promote the cosmetic fixture into player data. Rebirth seed changes remain later balancing, not a guaranteed reroll feature. Global exclusive terrain/name uniqueness remains unresolved; random diversity alone cannot guarantee it.

## Earlier architectural proposals

| ID | Proposal and rationale | Alternatives / consequences | Approval needed before |
| --- | --- | --- | --- |
| D01 | Plain strict Luau modules, one country mutation queue, server-only domain logic | Framework adoption adds dependencies; explicit modules are simpler initially | P1 source architecture |
| D02 | Lossless deterministic transport-flow solver with priority/fairness stages | Greedy routing can miss feasible delivery; DC/AC flow adds complexity; transport is not real electrical physics | P2 solver implementation |
| D03 | 1 wall-second step = 1 simulated minute; no offline progress; lag slows simulation | Different speed changes all balance; offline simulation needs bounded catch-up and event exclusions | P2 clock and P3 economy |
| D04 | One-sector starter fixture and straight node-to-node MVP lines | Freehand waypoints and voltage tiers follow later; fixture prices need playtesting | P2/P3 content |
| D05 | One-key active save, 16 sectors/256 nodes/512 lines/64 demand groups, eight countries/server initially | Larger limits require profiling; regional consolidation is unresolved long-term work | P3 persistence; P5a expansion |
| D06 | One consolidated Bank balance with explicit spending envelopes and delivered-energy billing | Separate government/utility accounts need a transfer/tax model; tariff bounds and growth rates are provisional | P3 economy; P7 Government |
| D07 | Optional eras, bounded legacy tracks and qualifying domestic delivery/reliability | Formula pacing untested; no forced rebirth at world cap | P8 |
| D08 | No debt initially; restricted once-per-era recovery restructuring | Unlimited bailout is exploitable; no aid may create irreversible failure | Public first-playable testing |
| D09 | Fictional policy mandates/elections deferred; policy effects derived at step boundary | Full political simulation is outside current scope | P7 policy; later election work |
| D10 | Staff teams, latent faults, separate inspection/repair and constrained automation | Individual employees add simulation/storage cost; failure curves need tuning | P5b/P6b |
| D11 | Eventually consistent public rankings, no rank-based scarce rewards, actual generation lifetime metric | Rich competition may need stronger index coordination; intentional output farming requires balance review | P9 |
| D12 | Alex Rowan adviser, live onboarding and isolated practice replay, phone bottom sheets | Name/style and exact layout are creative defaults; sandbox must not affect progression | P1 UI; P4 tutorial |
| D13 | Curated logos/colors, safe identity presets initially, filtered free text only after offline-display validation | Free-form uploads require more moderation; raw text must never be fallback | P9 |
| D14 | Global news admission limits and durable announcements with messaging hints | Real-time delivery is not guaranteed; optional celebrations may be suppressed | P10 |
| D15 | UTC event window; domestic-first event export; no import/storage contribution; bucketed cumulative ingestion | Source attribution could allow richer trade; worldwide reconciliation cost is an unresolved scale gate | P11 |
| D16 | Fenced profile lease, 60-second save/180-second lease targets, critical operations durable before success | Requires tested lost-response handling; session-library choice remains open | P3 |
| D17 | Pin tools in P1; choose minimal test harness before extra dependencies | No exact Rojo/test/formatter versions selected or installed; CI setup deferred until repository exists | P1 setup |

Balance numbers in system documents inherit proposal status even when absent from this table. Link a new D-ID when a tuning change materially changes the architecture or player contract.

## Contradictions and clarifications

| Tension / unclear requirement | Proposed resolution | Remaining owner choice |
| --- | --- | --- |
| Virtually unlimited expansion versus finite storage/CPU | Finite disclosed active caps, repeatable upgrades and later tested consolidation | Accept caps and consolidation editing tradeoffs; do not advertise infinite active map |
| Permanent event history versus unbounded records | Compact immutable summaries and paginated archives; no permanent tick/news logs | Capacity plan and account-deletion behavior before launch |
| Both utility owner and national government | One Bank balance; budgets/subsidies are internal allocations | Whether later independent tax/utility ledgers are desired |
| Sophisticated electricity versus approachable play | Capacity-constrained transport and clear cause labels | Whether DC load flow ever adds enough player value |
| Actual surplus event exports versus domestic reliability | Route domestic first and meter reachable export; conservative import/storage exclusion | Whether explicit domestic-sacrifice policies are desirable later |
| Lifetime generation leaderboard versus no free generation income | Track actual dispatched generator energy; billing only on delivery | Whether purposeful low-value output for ranking is acceptable |
| Offline profiles versus private country and moderation | Sanitized persisted projection with timestamp; safe presets/fallback | Free text scope after filtering tests |
| Rebirth resets infrastructure versus active event progress | Reset connector; preserve contribution, baseline and claims | Rebuild cost/one-time starter connector balancing |
| Global schedules versus no servers online | UTC eligibility computed on server start; no promise of an always-running worker | Whether external scheduling infrastructure is needed later |

## Major risks and mitigation gates

| Risk | Severity | Mitigation / evidence required |
| --- | --- | --- |
| Save duplication/loss from overlapping sessions | Critical | P3 fault-injection and real isolated-universe tests, fencing and no default overwrite on failure |
| Solver too slow or unfair on cyclic grids | High | P2 residual-flow/fairness fixtures and maximum graph profiling; reduce limits or redesign before expansion |
| Exponential progression overwhelms numbers or storage | High | Checked numeric caps, compact history, late-game balance sweeps and approved consolidation strategy |
| Event total loses or duplicates offline contributions | Critical | Durable enrollment registry, cumulative bucket slots and closing reconciliation; load-test before P11 acceptance |
| Derived ranking stale write races | Medium | Eventual consistency labels, canonical projection validation, repair jobs and no competitive reward reliance |
| Full replay contaminates real progress | High | Separate practice state and adapters; tests forbid economy/events/lifetime side effects |
| Mobile map becomes unusable | High | Early touch prototype, viewport culling, actual device validation before claiming support |
| API/tool changes invalidate assumptions | Medium | Official source register dated; reverify at phase start; pin installed versions |
| One Bank balance makes subsidies confusing | Medium | Internal transfer labels, clear expense ledger, usability tests |
| Automation removes meaningful decisions | Medium | Player policies/budgets, transparent work explanations and enduring capacity constraints |

## Next approval checkpoint

Review the [17 November foundation package](PROCEDURAL-GAMEPLAY-FOUNDATION.md). The recommended smallest next request is P2a, after explicitly approving its solver/clock, fixed starter values and operating-intent scope. Seed algorithm, climate curves, fairness/uniqueness and persistence migration remain later P2b/P3 review gates. R3.7 direction is accepted, but Hybrid default and device acceptance are still separate. R4/R5, planning/events and all later implementations remain independently gated.

Record future changes with date, status (proposed/approved/rejected/superseded), owner/source of approval, rationale, affected files, migration impact and verification required. Do not rewrite a rejected option into an apparently approved historical decision.
