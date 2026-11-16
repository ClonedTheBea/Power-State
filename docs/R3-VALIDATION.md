# R3 — illustrated country map prototype

Historical R3 evidence. The owner accepted this milestone technically and requested a richer visual result; see [R3.1 refinement validation](R31-VALIDATION.md) for current measurements and remaining visual limitations.

15 November 2026. Implemented under the owner's explicit R3 request, following R2 desktop visual acceptance. This is a client presentation prototype, with no simulation, construction, procedural expansion, commerce or live events. No external artwork was uploaded; no dependencies, commits, pushes, publishing or deployment were performed.

## Delivered behavior and rendering choice

- Native, modular artwork depicts a continuous coastline and offshore island, surrounding water, shaded hills, snowy mountain silhouettes, forest clusters, farmland, lake/river, towns/villages, industrial warehouses, a generator and substation. Light/roof highlights come from the upper left; shadows offset down/right. Muted semantic terrain tokens keep cyan infrastructure distinct.
- `MapFixture` contains 17 immutable cosmetic patch descriptors with stable versioned local IDs. The existing 1200×800 world plane, five asset IDs/positions and three sample links are unchanged. These cosmetic IDs are not persisted sector identities or proof of ownership. No future 1024-unit sector schema is imposed on the existing fixture.
- Terrain artwork, infrastructure markers, transmission connections, labels and interaction overlays have independent view containers. The camera/input controller remains separate. Artwork makes no electrical, condition, ownership or construction decisions.
- A fixed reusable pool is allocated once per map mount; draws change transforms/visibility only. Maximum 24 terrain patches, 32 asset markers, 64 links and **600 total map descendants** (including non-GuiObject decorators) are enforced. The actual fixture is smaller. No per-tree animation or background network work exists.
- Patches use conservative viewport culling with a 64-world-unit margin for shore/relief overhang. Crossing links remain visible when both endpoints are offscreen. Zoom bands have hysteresis: overview below 0.68 (retained until 0.76), detail at 1.25 (retained above 1.15), regional otherwise. Overview reduces trees/furrows and labels; all five primary assets retain 44px targets. Detail retains the same non-authoritative fixture, without invented readings.
- Overlapping targets become a counted representative that opens the existing Assets picker; full names/types remain available there. No ambiguous tap guesses a hidden asset. Labels that would cover another target are suppressed. Selection brackets remain separate from artwork. Offscreen selection retains its inspector and locator text; **Locate on map** centres the camera on that asset subject to the existing world-edge clamps, without changing zoom and closes the inspector to reveal it.
- Layers opens a keyboard/gamepad/touch-accessible modal drawer with a legend, Geography and optional labels/sample connections. Analytical layers explain why their data is unavailable; they do not become fabricated heatmaps. Toggling overlays preserves selection and camera. Closing Layers restores its invoker.
- Unknown terrain kinds show a labelled native fallback; unknown infrastructure kinds retain a question-mark target and accessible name/type. Native geometry has no remote image-loading dependency.

The measured native prototype is retained for R3 (D38). It is not a permanent ban on a later measured sprite/hybrid implementation. Future server sector snapshots, ownership boundaries, revision resync/LRU eviction and large-world clustering are not implemented. The fixed fixture pool has no stale network cache to reconcile; remount retires all its instances.

## Files changed by R3

Earlier uncommitted phases remain intact. Paths below are relative to the project root.

| Area | Files |
| --- | --- |
| New modular map implementation | `src/client/Views/Map/MapArt.luau`, `MapFixture.luau`, `MapGeometry.luau`, `TerrainRenderer.luau` |
| Updated map/composition | `src/client/Views/MapView.luau`, `DashboardView.luau`, `DrawerView.luau`, `InspectorView.luau` |
| Updated presentation coordination | `src/client/Controllers/AppController.luau`, `MapController.luau`, `src/client/Theme.luau` |
| New tests | `tests/integration/R3.spec.luau` |
| Documentation | `README.md`, `PLANS.md`, `docs/DECISIONS.md`, `GUI-VISION.md`, `GUI-LAYOUT-SPEC.md`, `GUI-COMPONENT-SPEC.md`, `TECHNICAL-ARCHITECTURE.md`, `WORLD-AND-EXPANSION.md`, `TESTING.md`, `UI-UX.md`, `STUDIO-SETUP.md`, this report |

PreviewData, MapTransform, shared Layout/ShellState, keyboard/gamepad controllers, server bootstrap, currency formatter, existing regression suites and Rojo configuration are unchanged. The prior P1 map primitives are replaced, not layered behind the new renderer.

## Validation evidence

Existing Rojo CLI 7.7.0, plugin 7.7.1 and the isolated **Power States - Test** Studio window, test mapping localhost:34873. The owner's separate development Studio session was not operated.

| Check | Observed result |
| --- | --- |
| `powershell -File scripts/Validate.ps1` | Passed normal/test Rojo builds, mapping/entrypoint, strict directives, no gameplay service/remotes and Git whitespace checks |
| Server Shell / Currency | 324 / 26 assertions passed |
| Client GUI / R1 / R2 | 348 / 16 / 135 assertions passed unchanged |
| Client R3 | 190 assertions passed: coordinates, 44px hit targets, hysteresis, crossing-line/patch culling, missing-art fallback, overlapping targets, budgets, layers, selection/camera, Locate and instance reuse |
| Total | **1,039 assertions passed** |
| Script Analysis | Passed: zero errors / zero warnings in edit mode; current-script-only filter off |
| Ten-minute resize/pan smoke | Passed: 600.8 seconds, 591 cycles, 803 GUI descendants stable; no new runtime/focus warnings |

The ten-minute smoke preceded a final resize-focus correction. The correction was followed by the complete 1,039-assertion regression run and phone orientation checks, not a second ten-minute run.

Manual inspection verified desktop drag/zoom, asset selection, Locate, Layers and keyboard dismissal. iPhone 16 emulation preserved Central Substation selection across portrait/landscape and kept focus on the visible inspector close control. An initial stale focus outline was corrected by clearing and rebinding selection after two render frames; final rotation checks emitted no new focus warnings. Tablet geometry was covered by automated safe-root sizes; R3 physical touch/controller operation was not tested.

The first R3 coordinate test used an unrealistically strict 0.01px tolerance. Roblox stores GUI offsets in integer pixels; the test now permits less than 1.01px rounding and still compares every marker against its unchanged world coordinate at every tested zoom. No existing assertions were deleted or relaxed.

Final short profiling run, 15:25 local Studio output:

| Measurement | Result |
| --- | --- |
| New shell/renderer instance construction | 22.89 ms |
| 360 warm map draws | p50 0.173 ms; p95 0.219 ms |
| Instance population | **448 map descendants / 803 shell descendants** |
| 120 frames while panning/zooming, 360×580 safe root | p50 16.62 ms; p95 17.58 ms |
| 120 frames while panning/zooming, 1366×704 safe root | p50 16.63 ms; p95 17.49 ms |

Construction measurement creates fresh instances with modules already required; it is not a cold Roblox launch/network-load benchmark. Draw timing measures Luau property updates, not GPU raster cost. Frame intervals are `RenderStepped` observations on this desktop with Studio open, not isolated renderer timings or low-end mobile evidence. Instance stability is a bounded smoke check, not proof of no memory leak. A maximum 16-sector world was not simulated or rendered.

## Open and inspect in Studio

1. Keep the test Rojo mapping connected on **34873**, or open the locally built `.build/PowerStateTests.rbxlx`. If needed, run `rojo serve test.project.json --port 34873` in the project folder. Do not start a duplicate server on an occupied port. Normal development uses the existing 34872 mapping.
2. Press **F5 / Play**, not Run. Restart Play after source changes because required modules are cached. No publishing or API-service access is needed.
3. In Grid, inspect coastline/water and the northern peaks; zoom in to see forest/farmland detail, village/town silhouettes and the western industrial district. Cyan connections are explicitly sample lines, with no direction or MW claims.
4. Drag and use +/−, mouse wheel or Recenter. Select Westhaven Station; close/reopen Details; visit Government and return to Grid. Selection and camera should persist. Pan the selected asset offscreen, open Details and activate Locate on map.
5. Open Layers: toggle Labels and Sample connections, close/reopen it and inspect the preserved camera/selection. Open Power flow to read its unavailable explanation. Tab/Enter and gamepad D-pad/A/B must reach and close these controls; ordinary map focus retains arrows/stick and +/-/shoulder controls.
6. Use Device Simulator for phone portrait/landscape and tablet. Check five bottom navigation items, 44px controls, open-sheet rotation and scrollable Layers at 100/125/150% text. Logical regression sizes are 360×580, 640×300, 768×960, 1024×708, 1366×704 and 1920×1020 safe roots.

Server unit suites run automatically in the test mapping. In the **Client Command Bar**, run (Ctrl+Enter):

```lua
local p = game:GetService("Players").LocalPlayer
local tests = p.PlayerScripts.DevelopmentTests
for _, name in { "Gui.spec", "R1.spec", "R2.spec", "R3.spec" } do
    require(tests[name])(p.PlayerGui)
end
```

Separately run the unchanged ten-minute smoke harness, and leave it uninterrupted until PASS:

```lua
local p = game:GetService("Players").LocalPlayer
require(p.PlayerScripts.DevelopmentTests["Soak.spec"])(p.PlayerGui)
```

## Visual differences, limitations and next step

- This is a simplified native illustration with geometric coastline unions, stylised peaks and small building groups. It is less detailed and less painterly than the approved reference; it does not reproduce its textured terrain, baked lighting, port cranes, animated water or later-game asset variety. No mockup image was cropped or used as production art.
- Layers uses the existing responsive modal drawer on desktop as well as mobile, preserving one tested focus/input path. Geography is the only available primary layer. No ownership/frontier/gameplay data is invented; illustrative links do not mean a powered or functioning network.
- The preview's fixed minimum zoom can crop country extents on small safe areas; pan, Assets and Locate retain access. Low-zoom label suppression is intentional; names remain in Assets/inspector. More complex cluster layouts and dynamic sector revisions require their own later data contract and tests.
- Actual low-end touch hardware, physical-controller ergonomics, cutouts, preferred OS/Roblox text settings and long translations remain release checks. The pre-existing Studio asset-type warning for `rbxassetid://203785492` is unrelated; the map uses no external image/audio IDs.
- Recommended next step: owner visual review of this R3 prototype and real-device interaction/performance checks. Consider an explicitly approved modular art/hybrid refinement if the simplified style is insufficient. R4 or any gameplay phase requires a separate request. **Stop after R3.**
