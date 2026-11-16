# R1 — theme and currency presentation

15 November 2026. Historical R1 milestone: implementation, local validation and all four Studio suites passed. Desktop and emulated phone/tablet presentation were inspected. The subsequent separately authorized R2 now changes layout/navigation; see [R2 validation](R2-VALIDATION.md) for current checks and remaining hardware/visual acceptance. P2 has not started. R1 counts and geometry below describe the earlier milestone.

## Changes

- Approved navy/panel/ocean/cyan/green/amber/coral/purple/text palette and secondary/disabled/control-border tokens centralized in Theme. Shared primitives use the theme for body typography, corners, control height and scrollbar width. Buttons have a readable interactive boundary; decorative borders stay restrained.
- Bank replaces the old balance label; Credits replaces the short currency abbreviation. The same illustrative 100,000 Credits is displayed—no game state or economy was introduced.
- Pure `CurrencyFormat.format(minorUnits, compact?)` accepts integer minor units (100 per Credit), with the documented 10^15 minor-unit ceiling. Exact mode groups thousands and retains nonzero hundredths; compact mode uses K/M/B/T, truncating at two decimals to avoid overstating available funds. Missing/nonfinite/negative/fractional/out-of-range inputs show Unavailable. It is a presentation helper, not authoritative accounting.
- Cards below 240px use `100K Credits`; wider cards use `100,000 Credits`. The full Bank card is a minimum-44px keyboard/touch Details target opening the existing feedback view with the exact amount and preview notice. Navigation, map, inspector and Help behavior remain P1.
- D27–D31 record owner clarifications: no permanent Standard header status; future Government tabs; flexible R3 rendering; ordinary menus do not pause active online simulation-time boosts; unused temporary time becomes dormant on permanent ownership, never exceeding 2×. No related gameplay was implemented.

## Files changed in R1

| Area | Files |
| --- | --- |
| New formatter | `src/shared/Util/CurrencyFormat.luau` |
| Theme/primitives | `src/client/Theme.luau`, `src/client/Views/Components.luau` |
| Bank fixture/presentation | `src/client/PreviewData.luau`, `src/shared/Types/ShellTypes.luau`, `src/client/Views/DashboardView.luau`, `src/client/Controllers/AppController.luau` |
| Independent error fallback | `src/client/Bootstrap.client.luau` (matching approved colours; deliberate literals survive a Theme failure) |
| New tests | `tests/unit/CurrencyFormat.spec.luau`, `tests/integration/R1.spec.luau` |
| Test runner | `tests/Run.server.luau` adds currency suite; existing P1 suites retained |
| Documentation | README, PLANS, GUI-VISION, GUI-LAYOUT-SPEC, GUI-COMPONENT-SPEC, UI-UX, DECISIONS, ECONOMY-AND-REBIRTHS, DATA-AND-SECURITY, GOVERNMENT, TECHNICAL-ARCHITECTURE, TESTING and this report |

## Validation actually performed

- `powershell -File scripts/Validate.ps1`: normal and test Rojo builds passed; mapping, single client entrypoint, strict directives, P1 boundary checks and Git whitespace passed.
- Static palette comparison: all 10 specified base palette values match the approved hex tokens.
- Calculated sRGB contrast: 24 applicable text/control pairings passed their 4.5:1 or 3:1 thresholds. Coral text remains on Panel (5.42:1), not Raised (4.40:1).
- Source audit: reusable Views contain no Color3 constructors; no legacy currency labels remain in source. The independent emergency fallback has two documented matching literals.
- 126 local documentation links/anchors passed; whitespace checks also covered new/untracked source and tests.
- SHA-256 comparison against the pre-redesign snapshot confirmed 11 preserved files: Layout, MapTransform, MapView, MapController, KeyboardController, both original test suites, both Rojo mappings, Rokit configuration and AGENTS.md. Their contents are unchanged.

Initial Studio automation failed before accessing a window with a kernel-assets error. After the owner restarted the computer, automation worked. The test place was connected to the normal mapping on port 34872, leaving old test modules in place; that stale suite failed at Bottom sheet bounds. Connecting the test window to `rojo serve test.project.json --port 34873` refreshed the tests and resolved that failure without changing layout or assertions.

- Observed passes: **98** layout/map assertions, **26** currency assertions, **80** engine GUI assertions and **16** R1 responsive Bank assertions. All four passed again after the compatibility fix below. Engine suites check actual text/control bounds at 360×580, 640×300, 768×960 and 1366×704 safe-root sizes.
- Edit-mode Script Analysis: **0 errors and 0 warnings** after replacing unsupported `read` modifiers in ShellTypes.Preview with ordinary typed fields. PreviewData still freezes the fixture, arrays and records at runtime. Dependent scripts required a source refresh to clear stale analysis results; no dependent behavior changed.
- Desktop: exact Bank amount and click/open/close verified. iPhone 7 emulator: compact Bank amount, readable full-value panel and close verified across landscape/portrait rotation. Samsung Galaxy Tab A9+ emulator: currency/header presentation inspected in both orientations; the large emulator canvas extended beyond the docked viewport, so full-screen tablet fit evidence comes from the engine assertions, not that visual inspection.
- Final normal/test Rojo builds and local validation passed. The pre-existing Studio asset-type warning for asset 203785492 still appears; it is separate from the passing application assertions and clean Script Analysis.

## Checking in Roblox Studio

1. Keep the existing development place connected to `rojo serve default.project.json`. Stop and restart **Play (F5)** after sync so modules reload. No publishing or API-access changes are needed.
2. Check the new palette and Bank card. On desktop it should show `100,000 Credits`; on narrow cards `100K Credits`. Click/tap **BANK · DETAILS**, or use Tab then Enter, to read the exact amount. Close the panel and verify navigation, Help previews, map drag, zoom, marker selection and Recenter still work.
3. Use Device Simulator for portrait/landscape phone and tablet, and desktop resize. Check 360×640, 640×360, 768×1024 and 1366×768 viewports, plus safe-inset reductions. Verify currency text and Details/close targets are not clipped. Actual touch hardware remains necessary before claiming mobile acceptance.
4. Open Script Analysis and Output; resolve any new R1 diagnostics before accepting R1. Check 125%/150% text where supported; R1 deliberately retains P1 typography/layout rather than introducing R2 reflow.
5. Build with `powershell -File scripts/Validate.ps1`, open `.build/PowerStateTests.rbxlx` separately (no Rojo connection required), then Play. Alternatively, connect the test place to `rojo serve test.project.json --port 34873`. Do not use the normal mapping to update test scripts: it excludes them. Expected server results: P1 **98** assertions and R1 Currency **26** assertions.
6. In that test place's running **Client** Command Bar, run:

   ```lua
   local player = game:GetService("Players").LocalPlayer
   assert(player)
   local tests = player.PlayerScripts:WaitForChild("DevelopmentTests")
   local playerGui = player:WaitForChild("PlayerGui")
   require(tests:WaitForChild("Gui.spec"))(playerGui)
   require(tests:WaitForChild("R1.spec"))(playerGui)
   ```

   Expected client results: existing GUI **80** and R1 GUI **16** assertions. These tests restore the safe-root size. They check real text/control bounds; manually verify the exact-value button's activation and close behavior too.

## Differences and remaining work

R1 intentionally retains P1 geometry, compact typography, native Roblox focus treatment and authored flat map shapes. The approved larger header/KPI hierarchy, grouped navigation, full focus/state system, illustrated terrain and ticker are later slices. The map's ocean uses the approved token; its land remains the P1 placeholder. No shop, permanent Standard label, simulation controls or Government tabs were added.

Currency uses the current English UI grouping/decimal convention; locale-specific formatting is deferred and documented in GUI-VISION. Exact values are always available through Details rather than hover-only text. The emergency startup fallback keeps matching colour literals to remain independent of Theme load failures.

Before R2: obtain owner visual acceptance, complete actual touch-device and 125%/150% text checks, and request R2 separately. Broad navigation/map input regression checks were not repeated during this follow-up; existing P1 evidence and unchanged implementation remain the baseline. Studio was left stopped and connected to the test mapping on port 34873. No commit, push, publish, deployment or dependency installation occurred.
