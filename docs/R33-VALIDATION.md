# R3.3 isolated hybrid renderer proof

16 November 2026. Owner approved atlas revision 3 (coast revision 3; five other motifs revision 1) **for an isolated proof only**. Implemented and tested the synthetic integration boundary. Native remains the production default. No upload, asset ID, publishing or production-map replacement.

## Implementation and boundaries

`SpriteManifest` freezes the six approved rectangles/cells, revisions, pivots, anchors, world canvases and native bundle identities. Its validator bounds dimensions, rejects invalid numbers/rectangles/revisions/identities and accepts only the approved descriptors. Rendering retains the frozen approved table rather than caller-mutable data. The local atlas and all six sources/exports were hash-verified before integration. Atlas SHA-256:

```text
e1dcb61948e575bab85d94a6eed3dce1939fe87389455fc3bce735a28cab63cb
```

`SpriteAtlasLoader` owns one injected readiness attempt per mount, a five-second deadline, cancellation, failure/timeout states and late-callback invalidation. It performs **no network/image fetch**. No request means Unconfigured. A pending load cancelled by returning to Native stays cancelled until remount; switching an already-ready proof between modes reuses its pool. New mounts have independent lifetimes. Actual ContentProvider, moderation, permissions and IsLoaded behavior remain outside this no-ID proof.

`SpriteTerrainRenderer` attaches only in Studio, creates at most six noninteractive ImageLabels once, shares the existing terrain UIScale, and culls complete sprite canvases without allocating instances during movement. Pixel offsets round half units in Roblox, so approved sprite origins use scale coordinates inside the fixed 1200×800 world root. Native marker coordinates/hit targets, connections, labels, selection and controls remain independent. The production Bootstrap never attaches the proof.

`TerrainRenderer` exposes its shore pool and a default-empty cosmetic replacement set. Both the west-cape shore and meadow bundles are suppressed together only when the proof is Hybrid/Ready. Returning to fallback reapplies current culling/detail visibility. During attachment, native chunks have sibling ZIndex 3, coast sprite 2 and native shores 1: the coast backing remains below all native meadows. Other sprite footprints are in the ordinary terrain pass. Teardown restores original ZIndex values/render function and destroys the six ImageLabels/connections.

Mock-ready ImageLabels have **empty Image properties and translucent accent footprint backgrounds**, tagged Synthetic. These are geometry diagnostics, not the actual artwork or a visual Hybrid acceptance result. Missing/failed/delayed readiness retains native art immediately. The mock can exercise replacement visibility without inventing a public asset or asserting an unloaded texture is usable.

## Files

- Changed: `src/client/Views/Map/TerrainRenderer.luau` (optional replacement ownership and shore-pool exposure).
- Added: `src/client/Views/Map/SpriteManifest.luau`, `SpriteAtlasLoader.luau`, `SpriteTerrainRenderer.luau`.
- Added test-only modules: `tests/integration/HybridProof.luau`, `R33.spec.luau`, `Run.client.luau`. The runner invokes every existing client suite, R33 and the existing native ten-minute soak; server unit suites still run separately. Default mapping excludes the test folder.
- Added: `scripts/ValidateR33.py`, this report and [benchmark data](R33-BENCHMARKS.json). Updated roadmap, decisions, architecture/setup and art-plan status pointers. No artwork PNGs or prior asset-package manifests changed.

## Observed checks

| Check | Evidence |
| --- | --- |
| Both Rojo builds | Passed `scripts/Validate.ps1`: normal/test mappings, client entrypoint, strict headers, phase boundaries, no gameplay remotes and Git whitespace. This is not a Luau type checker. |
| Local asset/manifest proof checks | **83 assertions passed**, `scripts/ValidateR33.py`: checksum/provenance readability, six source/export hashes, packed pixels, Luau descriptor parity, production/test mapping isolation and no external image IDs/fetch calls. |
| Existing server unit suites | Shell **324**, Currency **26** passed in Studio. |
| Existing client suites | GUI **348**, R1 **16**, R2 **135**, R3 **190**, R3.1 **52** passed in Studio. |
| R3.3 synthetic integration suite | **739 assertions passed** in Studio, including invalid manifests, pivots/placement at five zooms, injected failures/denial/delay/timeout/late callbacks, mode/camera/selection/inspector retention, coast ordering, bounds/culling, six safe-root sizes, counts and cleanup/remount. |
| Total engine assertions before soak | **1,830** (1,480 client + 350 server). |
| Descendants | Native **574 map / 929 shell**; attached proof **580 map / 935 shell**, below the 600-map ceiling, stable throughout repeated draws/movement/resize/mode changes. Teardown/remount returns to the baseline. |
| Script Analysis | Owner reports no errors with “Current Script Only” disabled. Direct panel inspection was unavailable because both computer-use entry points failed to initialize. Do not present this as an assistant-captured zero-warning screenshot. |
| Existing native soak | **Passed: 600.9 seconds, 591 resize/pan cycles, 929 shell descendants stable.** This is the existing native endurance suite; the synthetic hybrid workload is the repeated benchmark/regression loop, not a separate ten-minute textured soak. |

The first engine runs caught integer UDim2-offset rounding at half-unit origins and an overly strict UIScale float assertion. The origin implementation was corrected to scale coordinates; tests retain precise world-coordinate checks with float/integer-pixel tolerances appropriate to Roblox properties. Final passing results above are from the corrected run.

Studio test place: “Power States - Test”, test Rojo localhost:34873. User restarted Play while the assistant inspected local Studio output logs. No screenshots or direct input/accessibility inspection are claimed for this session. Existing tests exercise layout/focus behavior; physical touch/controller hardware remains untested. The historical unrelated `203785492` asset-type warning comes from the environment; the proof requests no image ID.

## Synthetic benchmark results

Windows desktop: Core i9-11900K, RTX 3090, approximately 32 GiB RAM; Studio 0.747.330.7470002. Graphics quality was not recorded. Each mode/size ran three warm passes of 360 synchronous map draws, followed by 120 rendered pan/zoom frames. Native in this comparison retains the dormant proof pool; the R3 suite also profiles the unattached native renderer. Raw per-pass data is in [R33-BENCHMARKS.json](R33-BENCHMARKS.json).

| Safe root | Mode | Median of three draw-p95 values | Per-pass draw-p95 range | Frame-p95 range |
| --- | --- | --- | --- | --- |
| 360×580 | Native with dormant pool | 0.421 ms | 0.411–0.437 ms | 17.84–17.88 ms |
| 360×580 | Mock Hybrid | 0.429 ms | 0.418–0.507 ms | 17.79–18.15 ms |
| 1366×704 | Native with dormant pool | 0.563 ms | 0.544–0.752 ms | 17.66–17.95 ms |
| 1366×704 | Mock Hybrid | 0.541 ms | 0.529–0.544 ms | 17.56–17.81 ms |

All mock draw p95 values are below the proposed 1ms CPU threshold. One phone-sized pass had a higher mock draw p95 than its matched native pass; the other two did not reproduce a >10% regression. Frame intervals show no repeated >10% regression in this sample. This limited synchronous workload is **not** a statistical performance guarantee, low-end-device result, real texture-memory measurement, draw-call measurement or GPU benchmark. No atlas upload/download, texture decode or real pixel filtering occurred. Real-device and real-texture gates remain open.

## Run and compare

1. Use only the isolated test place connected to `rojo serve test.project.json --port 34873`, or open rebuilt `.build/PowerStateTests.rbxlx`. Production remains on 34872. Restart Play after every code change so required modules are fresh.
2. The test mapping's new Run LocalScript automatically runs GUI/R1/R2/R3/R31/R33 and then the ten-minute native soak. Let it finish before mounting the comparison. Server suites print separately. The soak visibly resizes/pans the shell; this is expected test behavior.
3. In the running **Client** Command Bar, after all tests finish:

```lua
local p = game:GetService("Players").LocalPlayer
p.PlayerGui.PowerStateShell:Destroy()
require(p.PlayerScripts.DevelopmentTests.HybridProof).mount(p.PlayerGui, "ready")
```

4. In client Explorer select `PlayerGui.PowerStateShell.SafeRoot.Content.CountryMap`. Change its **RequestedProofMode** string attribute between `Native` and `Hybrid`. Read **ProofMode**, **ProofLoadState**, **ProofSynthetic** and **ProofNotice**. The attribute control is deliberately outside the player UI, so it does not cover mobile navigation or capture map input. Selection/inspector/camera should remain unchanged. Cyan translucent areas are synthetic sprite footprints, not accepted art.
5. Repeat step 3 with `"unconfigured"`, `"delayed"` (two seconds), `"denied"` or `"timeout"` (seven-second completion rejected after the five-second deadline). Change to Hybrid to start the attempt. The request runs once per mount. Return to Native during a delay to cancel; remount to retry.
6. Pan/zoom/Recenter/Locate; select station/junction, close/reopen inspector, switch navigation and Layers, resize/rotate. Existing safe-root/input checks remain applicable. Stop Play to discard the proof and all local state. Normal default.project.json has no comparison controller/runner.

## Upload requirements and recommendation

**Recommend proceeding to separately approved real-atlas testing**, not replacing production. Before that step the owner must approve upload of the exact checksum above to a named Roblox owner/experience and confirm the provenance/rights record and intended permissions. No upload approval is implied by proof-art acceptance. Do not borrow public IDs or use local-image imports to bypass this gate.

After upload and separate implementation authorization, add a bounded real ContentProvider adapter and real ImageLabel readiness checks using the returned approved ID, replacing the synthetic footprint styling. Exercise real denied/deleted/moderated images, delayed/late delivery, image rect filtering/gutters, the coast's opaque backing order, endpoint appearance, overlays, zoom/high-DPI rendering and memory/frame profiling on agreed physical hardware. Preserve native fallback and the default mode until those checks and owner review pass. The source coast's earlier alpha-254 filtered sample and endpoint style remain specific real-texture inspection items.

This task stops at the mock-integration boundary. R4, R5, P2 and procedural expansion remain untouched. No commit, push, upload, permissions change, publish or deployment.
