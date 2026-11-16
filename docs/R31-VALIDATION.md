# R3.1 illustrated map refinement — validation

15 November 2026. R3 accepted technically by the owner; its visual simplicity prompted this separately authorized refinement. Stop after R3.1. No R4/R5/P2, external assets, uploads, dependencies, commits, pushes, publishing or deployment.

## Changes

Default framing now waits two rendered frames for initial responsive geometry, uses a cosmetic 1000×610 framing envelope and the existing 0.55–1.8 zoom limits, and centres vertically on world y=390. Large screens no longer stop at a default 1×. Later resizes, pan/zoom, selection, Locate and navigation preserve their existing contracts. Narrow/short views still allow country cropping at minimum zoom; Assets and Locate remain the accessible alternatives.

Native art revision 2 adds three asymmetrical headlands, differently sized shaded peaks/slopes, conifer silhouettes, hedgerows, gabled houses, varied capital building heights/civic tower, Southbank gardens, Eastmere pier, twin gas exhaust stacks/turbine halls, substation yard and cosmetic access roads/pylons. Upper-left lighting and theme palette are shared. Labels, selected brackets and sample transmission lines remain native independent overlays. Five asset IDs/coordinates and three link endpoints are unchanged. The 22 cosmetic patches remain bounded by the existing maximum 24 and hard 600 map descendants. No live condition/production/connectivity/ownership is inferred.

File inventory for this refinement:

- Code: `src/client/Views/Map/MapArt.luau`, `MapFixture.luau`, `TerrainRenderer.luau`; `src/client/Theme.luau`; `src/client/Controllers/MapController.luau`, `AppController.luau`; `src/shared/Util/MapTransform.luau`.
- New test: `tests/integration/R31.spec.luau`. All existing suites retained unchanged.
- Documentation: this report, `R31-ART-STRATEGY.md`, README, PLANS, DECISIONS, GUI-VISION, GUI-LAYOUT-SPEC, GUI-COMPONENT-SPEC, WORLD-AND-EXPANSION and TESTING. R3-VALIDATION gains a pointer while retaining historical measurements.

## Observed validation

Isolated Power States - Test window, Rojo test mapping localhost:34873. Existing development window untouched.

| Check | Result |
| --- | --- |
| Normal/test Rojo builds and static boundary/strict/whitespace script | Passed |
| Server Shell / Currency | 324 / 26 assertions passed |
| GUI / R1 / R2 / R3 | 348 / 16 / 135 / 190 assertions passed |
| R3.1 | 52 assertions passed: settled startup framing, larger-screen default zoom, limits, cosmetic identities/landmarks, five safe-root sizes, selection/Locate, instance stability |
| Total | **1,091 assertions passed** |
| Script Analysis | Zero errors and warnings; current-script-only filter off |
| Instance population | **574 map / 929 shell descendants**; unchanged across repeated rendering, resizing and inspector use |
| New shell construction (modules already loaded) | 23.53 ms |
| 360 warm map draws | p50 0.329 ms / p95 0.463 ms |
| 120 pan/zoom frames, 360×580 safe root | p50 16.61 ms / p95 17.39 ms |
| 120 pan/zoom frames, 1366×704 safe root | p50 16.63 ms / p95 17.60 ms |

Studio output at 15:44 local time. Draw timings measure CPU property updates; frame intervals include the desktop/Studio workload and do not establish GPU or low-end device performance. R3's 600.8-second endurance result remains historical; R3.1 ran the repeated-movement/resize regression workload above, not another ten-minute soak. The old unrelated asset-type warning for `rbxassetid://203785492` remains; no new art uses asset IDs.

Desktop manual inspection verified default framing, + zoom/detail, station selection/inspector, Locate and direct drag with retained selection. iPhone 16 emulation verified the landscape five-item bar, substation selection, portrait rotation with preserved selection and correctly positioned inspector focus, closing back to the map, and opening Layers. No new runtime/focus warnings appeared. The portrait device extended below the Studio canvas at the selected emulator scale; this is not claimed as a full physical-screen review. Tablet geometry is covered by automated safe-root tests. Physical touch/controller hardware was not available for this pass; existing keyboard/gamepad code and R2 tests remain intact.

## Inspection instructions

1. Keep the test mapping on port 34873 connected, or open `.build/PowerStateTests.rbxlx`. Press F5 / Play. Restart after code changes to avoid cached modules. Do not publish.
2. Inspect default framing, especially in a tall desktop viewport: the country should grow beyond the prior 1× cap. At short desktop heights the improvement is smaller because country height is limiting. Recenter intentionally reframes; ordinary navigation does not.
3. Zoom once or twice to inspect station stacks, capital tower, coastal pier, conifers, field rows and pylons. Use Layers to toggle Labels and Sample connections. Roads/pylons are illustration only.
4. Select station, close/reopen inspector, activate Locate; pan, zoom, visit Government and return. Selection and camera should persist except deliberate Recenter/Locate.
5. Try phone portrait/landscape and tablet, including orientation with selection. At minimum zoom, pan to country edges or use Assets/Locate. Check 44px targets, visible cyan selection and close controls.
6. In a desktop Play session, run the Client Command Bar regression command:

```lua
local p = game:GetService("Players").LocalPlayer
local t = p.PlayerScripts.DevelopmentTests
for _, name in {"Gui.spec", "R1.spec", "R2.spec", "R3.spec", "R31.spec"} do
    require(t[name])(p.PlayerGui)
end
```

## Limitations and recommendation

The result is a more distinctive native illustration, not a painterly match to the approved reference. Coastlines remain rounded unions, relief stays geometric, and tiny silhouettes lose detail in overview. Roads and pylons are fixed authored decoration; they do not represent legal routes or real electrical assets. Camera fitting does not attempt to fill both axes at the expense of distortion; a very wide short map naturally retains water at the sides.

No external artwork is required for this implementation. For a substantially richer finish, review the [native/sprite/hybrid comparison and proposed asset specification](R31-ART-STRATEGY.md). A modular raster terrain/native overlay proof is recommended next, with explicit art/upload approval and real-device measurements before adoption. No hybrid rendering or uploads have been started. Owner visual acceptance remains separate from passing tests.
