# R2 — responsive GUI shell composition

15 November 2026. Implemented under the owner's explicit R2 request. R3/R4/R5/P2 have not started. All data remains illustrative and non-authoritative. No dependencies, commits, pushes, publishing or deployment were performed.

## Delivered behavior

- Compact identity/preview-status/utilities header and operational KPI hierarchy. Default desktop header is 56px (64px wide desktop), with no reserved ticker/footer strip. Four cards become two primary cards on phone; short landscape puts primary readings in the header with exact/full details in Overview.
- Grouped desktop navigation, expandable/collapsible rail, geometric icons and full labels on keyboard focus or through More. Phone/short layouts use five items: Grid, Build, Gov., Events, More. More exposes every route and utility.
- Contextual inspector with Close, peek, half and expanded stages, readable scrolling content and explicit controls. Selected asset survives close/reopen and navigation. Dock resizing preserves panned world centre and zoom subject to existing edge clamps; overlay sheets leave camera geometry unchanged.
- Explicit map/UI input modes, keyboard traversal/activation, modal focus containment/restoration, accessible asset list, gamepad D-pad/A/B/stick/shoulder paths and existing single-touch/mouse pan and zoom buttons. Session-only 100/125/150% text choices reflow chrome rather than scaling the whole GUI.
- Bank/Credits, exact-value access, theme tokens, help/loading/notice/error demonstrations and honest future-route explanations retained. Build is a P3 preview over the same map; Energy Shop has only an explanation, not R5 product UI.

## Files created or changed by R2

Paths are relative to the repository. Earlier uncommitted work was preserved; Git's broader dirty-file list includes prior phases.

| Area | Files |
| --- | --- |
| New reusable views | `src/client/Views/HeaderView.luau`, `KpiStripView.luau`, `NavigationView.luau`, `NavigationIcon.luau`, `DrawerView.luau` |
| Updated composition/components | `src/client/Views/DashboardView.luau`, `Components.luau`, `InspectorView.luau`, `FeedbackView.luau`, `MapView.luau` |
| Input/routing | `src/client/Controllers/AppController.luau`, `KeyboardController.luau`, `MapController.luau`; new `MapInputController.luau`; `src/client/Navigation.luau` |
| Shared presentation | `src/shared/Util/Layout.luau`; new `ShellState.luau`; `src/shared/Types/ShellTypes.luau` |
| Tests | Updated `tests/unit/Shell.spec.luau`, `tests/integration/Gui.spec.luau`, `R1.spec.luau`; new `R2.spec.luau`, `Soak.spec.luau` |
| Documentation | `README.md`, `PLANS.md`, `docs/DECISIONS.md`, `GUI-VISION.md`, `GUI-LAYOUT-SPEC.md`, `GUI-COMPONENT-SPEC.md`, `UI-UX.md`, `TECHNICAL-ARCHITECTURE.md`, `TESTING.md`, `STUDIO-SETUP.md`, `R1-VALIDATION.md`, this report |

`Theme`, `CurrencyFormat`, `MapTransform`, frozen preview data, server bootstrap and Rojo mappings are unchanged by R2. MapView only hides its old redundant title beneath the new shell toolbar; terrain/markers/links remain the P1 renderer. No new art assets or service integrations exist.

## Automated and Studio evidence

Environment: existing Rojo CLI 7.7.0 / Studio plugin 7.7.1, isolated **Power States - Test** Studio window, connected test mapping on localhost:34873. The separate development window was not modified.

| Check | Observed result |
| --- | --- |
| `powershell -File scripts/Validate.ps1` | Passed both normal/test Rojo builds, source mapping, strict-directive/boundary checks and Git whitespace |
| Additional local audit | Markdown file links resolve; whitespace scan passed for all 32 Luau files, including untracked source; no standalone Luau analyzer/formatter/runner is installed on PATH |
| Studio server Shell suite | 324 assertions passed |
| Studio server CurrencyFormat suite | 26 assertions passed; unchanged formatter coverage |
| Studio client GUI suite | 348 assertions passed: six safe-root sizes at 100/125/150% text; metric text bounds, map height, inspector and five bottom targets |
| Studio client R1 currency GUI suite | 16 assertions passed, including exact Bank details and short-layout Overview access |
| Studio client R2 interaction suite | 135 assertions passed: selection, zoom and panned world-centre preservation, inspector stages, routes, modal focus/return, asset list, rotation, input-mode state and clean remount |
| Ten-minute resize/pan smoke | Passed: 600.8 seconds, 591 resize/pan cycles, 411 GUI descendants stable; no new focus warnings. Completed before the final orientation/covered-focus corrections, which receive targeted rotation and regression checks. |
| Script Analysis | Passed after the final device/focus fixes: zero errors and zero warnings in edit mode, with current-script-only filtering off |

The previous 98 layout/map and 80 engine checks were evolved into the 324/348 suites, not removed to force a pass. R2 intentionally permits zero-height hidden metrics/footer regions, raises default minimum map height to 160px and asserts approved mobile geometry. Enlarged text at the constrained 640×300 target uses compact-tool mode and retains at least 120px. Tests use logical safe-root sizes, not physical screen dimensions.

Direct Studio interaction checks: mouse drag, zoom buttons, Recenter, selection and inspector reopening; keyboard Tab/Enter; Controller Emulator D-pad focus, A opening Overview, B closing/restoring focus, explicit Map focus, shoulder zoom, left-stick pan, A opening the asset list and D-pad/A selecting a station. Device Simulator also exercised iPhone 16 portrait/landscape with an open selected-asset sheet and Samsung Galaxy Tab A9+ landscape. Five phone destinations, compact metrics/header, scrollable details and tablet rail/overlay were inspected. These are emulator observations, not real controller/touch hardware certification.

Device checks found the inherited landscape-only orientation policy; the shell now enables Sensor locally while mounted and restores the prior policy at teardown (D37). Focus candidates behind an open inspector are excluded, and native automatic game-GUI selection is disabled/restored with shell ownership. The final interaction suite covers orientation and covered-control exclusion.

The first endurance attempt was stopped after exposing repeated invalid-focus warnings during rapid resize. Focus requests now wait for layout, reject offscreen/stale targets and cannot outlive teardown. Initial gamepad testing also exposed competing native/custom activation; the shell now owns one activation route and restores the previous native navigation setting on teardown. The pre-existing Studio asset-type warning for `rbxassetid://203785492` remains unrelated; Power State loads no external image/audio assets.

## Run in Studio

For normal preview, keep the development Rojo connection on 34872 and press **Play (F5)**. Stop/restart Play after source changes because required modules are cached. Do not use Run, which has no local player GUI. No API-service access or publishing is needed.

For tests, use the connected isolated test place on 34873, or build and open `.build/PowerStateTests.rbxlx` locally. If its server is stopped, run `rojo serve test.project.json --port 34873` from the repository; do not start another server on an occupied port. Press Play and inspect the two automatic server PASS lines. In the **Client** Command Bar run:

```lua
local player = game:GetService("Players").LocalPlayer
assert(player)
local tests = player.PlayerScripts:WaitForChild("DevelopmentTests")
for _, name in { "Gui.spec", "R1.spec", "R2.spec" } do
    require(tests:WaitForChild(name))(player:WaitForChild("PlayerGui"))
end
```

Run the endurance check separately; leave the client running for ten minutes without interacting with it:

```lua
local player = game:GetService("Players").LocalPlayer
require(player.PlayerScripts.DevelopmentTests["Soak.spec"])(player.PlayerGui)
```

It prints progress every 60 cycles and a final elapsed-time/cycle/instance-count result. A stable GUI instance count is a bounded smoke check, not proof of zero memory leaks or low-end frame rate. The normal mapping deliberately excludes all tests.

Manual review: desktop 1366×768/1920×1080, tablet 768×1024/1024×768, phone 360×640/640×360 and safe roots 360×580/640×300. Select an asset, pan/zoom, close/reopen Details, change routes and rotate with the sheet open. Check More and Settings at enlarged text; open exact Bank details and Help demonstrations. Keyboard and gamepad must reach all actions, stay within modal panels and coexist with the Roblox menu. Single-finger drag plus explicit +/- is the supported touch path; pinch is not required.

## Design differences and remaining acceptance

- R2 deliberately retains the authored P1 map, lettered asset markers and decorative links. Illustrated terrain/layers remain R3. No ticker or empty ticker space is present before R4; no shop UI before R5.
- Compact desktop header is 56px rather than the earlier 64–72px draft range, following the owner's explicit map-height requirement (D33). No live date/status is invented; Overview explains missing data.
- At 150% text and the smallest short safe root, the map is 128px high in compact-tool mode. Detailed information remains in scrollable panels. This is an intentional accessibility/space tradeoff, not a claim that arbitrary smaller screens are supported.
- Actual low-end touch hardware, cutouts, physical-controller ergonomics, OS/Roblox preferred text settings, long translations and owner visual acceptance remain checks before release. The local text-size setting is session-only and does not claim account-preference integration.
- No new gameplay or commerce approval is requested. R3 requires a separate explicit request; stop after R2.
