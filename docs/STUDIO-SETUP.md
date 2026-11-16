# Opening and testing the presentation shell

P1 with R1–R3 is an interface preview. Current evidence and full commands are in [R3 validation](R3-VALIDATION.md). No saves, purchases, simulation, HTTP access or publishing are required. All readings are illustrative.

## Existing connected place

1. Open the owner's Power State development place in Roblox Studio.
2. Keep the existing Rojo session connected to `localhost:34872`. If it is stopped, run the following from PowerShell and connect using the installed Rojo plugin:

   ```powershell
   Set-Location 'C:\Users\matt9\Desktop\Roblox Games\Power State'
   rojo serve default.project.json
   ```

   The existing `Serve.ps1` is an equivalent convenience script. Do not start a second server on the same port.
3. Confirm Explorer contains `ReplicatedStorage.Shared`, `ServerScriptService.Server` and `StarterPlayer.StarterPlayerScripts.Client`.
4. Press **Play (F5)**, not Run. The GUI is built locally under `Players.<you>.PlayerGui.PowerStateShell`; it is not visible in edit mode. Automatic character spawning is disabled.
5. Stop and restart Play after source changes to reload required modules. Edit mapped scripts on disk; Studio-only edits can be overwritten by Rojo.

Rojo CLI 7.7.0 is pinned by the existing `rokit.toml`; Studio plugin 7.7.1 was observed. No additional packages were installed for P1.

## Local validation and isolated test place

R3.3 update: the test mapping now includes a client test runner. Restart Play after sync; GUI/R1/R2/R3/R31/R33 suites and synthetic benchmarks run automatically, followed by the existing ten-minute native soak. Server suites still run separately. Let the runner finish before manual comparisons. See [R3.3 Native/Hybrid instructions](R33-VALIDATION.md#run-and-compare). Production mapping has no runner or comparison controls.

```powershell
Set-Location 'C:\Users\matt9\Desktop\Roblox Games\Power State'
powershell -File scripts/Validate.ps1
```

This produces `.build/PowerState.rbxlx` and `.build/PowerStateTests.rbxlx`. Both are disposable, ignored build artifacts. Open the **test** file with Studio's File > Open from File. It already contains source and tests; a Rojo connection is unnecessary. Rebuild/reopen it to test changed source. Keep it separate from the connected development place.

Press Play. Server Output should print:

```text
[Power State R2 Shell] PASS: 324 assertions
```

For the GUI suite, select the running **Client** tab. Open Window > Script > Command Bar, paste this Luau and click **Run**:

```lua
local player = game:GetService("Players").LocalPlayer
assert(player)
local tests = player.PlayerScripts:WaitForChild("DevelopmentTests")
require(tests:WaitForChild("Gui.spec"))(player:WaitForChild("PlayerGui"))
```

Expected: `[Power State R2 GUI] PASS: 348 engine layout assertions`. The suite temporarily resizes the safe root and restores it. The normal `default.project.json` deliberately excludes tests, so the command is for the test build only.

Open Window > Script > Analysis to inspect Luau diagnostics. The PowerShell script validates build structure and scope; it is not a type checker. The final normal source was checked using Studio Script Analysis.

## Interaction checklist

- Desktop: four preview metrics, left navigation, large map and collapsible inspector; click future destinations and verify their phase notices.
- Map: drag empty map space and markers, release outside the map, zoom with wheel or +/−, use Recenter, and select markers. Dragging should not accidentally inspect a marker; limits should prevent losing the map completely.
- Keyboard: click the game viewport, then Tab/Shift+Tab to move focus and Enter to activate; M returns to Map. Choose Map focus to enable arrow-key panning. Escape clears focus and closes shell panels; Roblox may also show its core menu.
- Help: scroll to Preview loading/notice/error, open each, read its text and dismiss it. These are demonstrations, not requests to a service.
- Device Simulator: stop Play, enable Test > Device Simulator, select phone/tablet, then Play. Check portrait and landscape, particularly 360×640/640×360 phone, 768×1024 tablet and 1366×768 desktop. Sizes are viewport targets; Roblox safe insets reduce usable height.
- Phone: Grid/Build/Gov./Events/More remain accessible; More scrolls to all destinations and utilities; Details and Help scroll; opening a sheet preserves bottom navigation.
- Resize/rotate with details or feedback open. Read the long error and verify close targets remain reachable. Repeated Stop/Play must create only one shell.

## Remaining acceptance work

Actual phone/tablet touch dragging, screen cutouts, rotation and long-session behavior still require hardware checks. R2 adds gamepad paths and session-only text-size settings; see the current validation report for emulator evidence and hardware limitations. Construction, save/reload and tutorial checks in the broader UX document belong to later phases and cannot be performed in P1.

An existing Studio `rbxassetid://203785492` asset-type warning was observed before the shell loaded. P1 uses no external image/audio asset IDs. Treat new Power State stack traces separately from that pre-existing environment warning. The owner subsequently connected the isolated test place to test.project.json on localhost:34873. Keep the development connection on 34872 separate.
