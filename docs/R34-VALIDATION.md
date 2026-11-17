# R3.4 — real atlas readiness and validation

Date: 2026-11-16. Stage 2 isolated real-texture implementation and available Studio validation complete; production adoption is not approved. **Identity correction:** upload ID `105986918888502` is a Decal, not an Image. Its verified image dependency is **86222383311104**, owned by `missawfulname` (`149564436`). The upload's Restricted state was verified in Creator Dashboard. The earlier upload-only report is retained below as history and superseded by this correction and the later Stage 2 authorization.

## Stage 2 implementation and current evidence

The exact uploaded decal was inspected in Test Studio through `InsertService:LoadAsset` without parenting it to the scene; the temporary container was destroyed. Both its Texture and ColorMap properties returned `rbxassetid://86222383311104`. Roblox's public asset metadata independently reports the upload as AssetTypeId 13 and the dependency as type 1, both named `power-state-map-proof-v3` with creator `149564436`. See [AssetType enum](https://create.roblox.com/docs/reference/engine/enums/AssetType). This resolves the same approved upload; it is not unrelated artwork, a new upload or a permission workaround.

Implemented files:

- `src/client/Views/Map/SpriteTerrainRenderer.luau`: optional injected real presentation, same six-label pool and camera transform, all-label readiness and native fallback/recovery. No URI or fetch implementation in production source.
- `tests/integration/RealAtlas.luau`: approved same-upload image URI; Studio/client/Test-universe guard; one asynchronous ContentProvider preload, per-content success checks and all six ImageLabel readiness checks. Five-second deadline, callback cancellation and observer cleanup retain native art on failure. No retry loop.
- `tests/integration/HybridProof.luau`: default real test comparison; explicit synthetic scenarios retained. Native initial mode and attribute controls; preserved camera/selection/inspector.
- `tests/integration/R34.spec.luau`: real readiness, responsive/zoom, state retention, local readiness-loss recovery, matched benchmarks, ten-minute real-texture endurance and remount checks.
- `tests/integration/Run.client.luau`: approved Test guard, static module paths for Script Analysis, existing suites, real suite and existing native soak; comparison shell after completion.
- `scripts/ValidateR34.py`: checksum and build isolation checks for the adapter, approved image URI and test harness.

Both Rojo builds, existing 83 local checks and 14 new isolation checks passed. These are local checks, not real rendering acceptance. Production's local `rojo serve default.project.json` processes were stopped before shared-source edits; only `test.project.json` is served on port 34873. The open Production Studio window was not operated or synced.

### Delivery findings and corrections

1. Direct use of the supplied Decal URI failed with **Asset type does not match requested type**. Native fallback remained active; terminal Failed was observed at **382.991 ms**. This is a type failure, not demonstrated permission denial.
2. The verified Image dependency fetched successfully. Fully hidden/transparent labels did not acquire IsLoaded in this Studio session, leading to correctly bounded five-second timeouts. Whole-client GraphicsTexture rose from **21.0552 to 26.3885 MiB** during the first Image attempt; the approximate 5.33 MiB delta is an observation, not isolated atlas allocation or a cold-download measurement.
3. Visible-label diagnostic resolved all six labels in **419.367 ms**, cache state unknown. The implemented correction warms labels below retained native artwork at ZIndex 0, then promotes only on all-label readiness to coast 2 / other sprites 3. Warming never suppresses native bundles; this is preparation, not a Ready state. Normal coastline order remains native shores < coast < native meadows. Lost readiness returns all sprites beneath native fallback while permitting the same image to recover.

No permission changes were needed or made. Actual denied/moderated image cases are not claimed; protocol fault tests remain synthetic. Official [ContentProvider](https://create.roblox.com/docs/reference/engine/classes/ContentProvider) and [ImageLabel](https://create.roblox.com/docs/reference/engine/classes/ImageLabel) documentation was reviewed for preload status and readiness behavior.

### Isolated comparison instructions

Use only Power States - Test (`10776833313`) connected to `rojo serve test.project.json --port 34873`. Restart Play after sync. The test runner requires this universe; an unassociated local build is intentionally refused by the real adapter. Let automated suites finish before visual inspection.

To manually mount the real comparison in the **client** Command Bar after tests:

```lua
local p = game:GetService("Players").LocalPlayer
p.PlayerGui.PowerStateShell:Destroy()
require(p.PlayerScripts.DevelopmentTests.HybridProof).mount(p.PlayerGui, "real")
```

Change `PlayerGui.PowerStateShell.SafeRoot.Content.CountryMap.RequestedProofMode` between `Native` and `Hybrid`. Read `ProofLoadState`, `ProofSynthetic` (false for real), and `ProofNotice`. Normal production has no RealAtlas, R34 suite, runner or comparison harness. Remount for an explicit retry after failure/cancellation. Never add a different asset or alter permissions to make a test pass.

### Measurements and final validation

Matched warm benchmark results (three passes, 360 property-update samples and 120 movement frames per pass; full rows in [R34-BENCHMARKS.json](R34-BENCHMARKS.json)):

| Safe root | Native median draw p95 | Hybrid median draw p95 | Native frame p95 range | Hybrid frame p95 range |
| --- | --- | --- | --- | --- |
| 360×580 | 0.439 ms | 0.431 ms | 17.29–17.51 ms | 17.29–17.41 ms |
| 768×960 | 0.632 ms | 0.645 ms | 17.59–17.69 ms | 17.60–17.84 ms |
| 1366×704 | 0.636 ms | 0.617 ms | 17.33–17.71 ms | 17.28–17.57 ms |

All measured draw p95 values are below 1ms. One tablet pass showed a >10% Hybrid CPU draw increase; the other two did not reproduce it. These small samples do not establish statistical equivalence or low-end-device performance. Frames are RenderStepped intervals, not separated CPU/GPU frame costs. Native comparisons retain the dormant six-sprite pool and cached texture, so they are not unloaded-memory baselines. Hardware: Core i9-11900K, RTX 3090, 31.88 GiB physical RAM; Studio 0.747.330.7470002. Graphics quality was not recorded during measurement.

The final corrected mount reported all-label Ready after **34.623 ms**, adapter completion **31.863 ms**; this is a warm/cache-unknown run, not a cold download. Whole-client GraphicsTexture was **31.7224 MiB** both before and after that mount. Previous warm mounts and unrelated Studio textures prevent atlas-only attribution.

Final corrected run: **2,089 engine assertions passed** (350 server, 1,480 existing client, 259 real-texture). Real-texture endurance passed **600.8 seconds / 591 cycles / 935 shell descendants**; native endurance passed **600.9 seconds / 591 cycles / 929 descendants**. The proof adds six pooled ImageLabels (580 map descendants versus 574 native). Real remount readiness completed in 49.227 ms. Studio Script Analysis showed **0 errors / 0 warnings**, with Display only current script unchecked. The unrelated pre-existing Studio ContentId warning for `203785492` was also present; it is not the atlas and was not introduced/substituted by this task.

The real suite covers six safe-root dimensions, all five zoom levels, placement/readiness, selection/inspector/camera retention, layer state, induced local ImageLabel readiness loss and recovery, bounded instances and cleanup/remount. Denied assets and late-callback fault scenarios are synthetic regression evidence, not claims of real permission changes. The endurance test asserts loader state/count stability; it does not inspect every rendered pixel on every cycle.

### Actual rendered visual evidence

These are unedited Studio captures of the real Image dependency, not generated mockups. Each Native/Hybrid pair uses the same viewport and camera; switching only the proof mode preserves state.

- Desktop 1366×704 safe root: [Native](r34-screenshots/desktop-native.png), [Hybrid](r34-screenshots/desktop-hybrid.png).
- Compact 360×580 safe-root fixture: [Native](r34-screenshots/mobile-safe-root-native.png), [Hybrid](r34-screenshots/mobile-safe-root-hybrid.png). This fixture deliberately preserves the previous camera and clips the country horizontally.
- Studio iPhone 16 emulator, landscape: [Native](r34-screenshots/iphone16-native.png), [Hybrid](r34-screenshots/iphone16-hybrid.png); [Hybrid after portrait rotation](r34-screenshots/iphone16-portrait-hybrid.png).
- Studio iPad Air 5th Generation emulator, landscape: [Native](r34-screenshots/ipad-air-native.png), [Hybrid](r34-screenshots/ipad-air-hybrid.png); [closer coast and selected station](r34-screenshots/ipad-coast-selected-close.png).
- [Script Analysis and endurance progress](r34-screenshots/studio-endurance.png).

All six motifs appeared at their existing anchors. Mountains, forest and agriculture are recognisable, and the native lines, markers and selection remain above artwork. No obvious adjacent-cell bleeding or hard rectangular sprite backgrounds were seen in the captured views. Coast inland grass blends at overview scale without the earlier curved texture boundary; close views retain an abrupt stylistic transition from painted cliff endpoints to the native outlined shore. This is an inspection finding, not owner visual acceptance.

The six-motif proof remains visually mixed: unreplaced forests, fields and villages use native geometry; large markers/labels obscure much of the small power station and settlement. The map is cropped at short landscape/portrait sizes until panned or zoomed, consistent with preserved framing behavior. Tablet portrait exceeded the available Studio viewing panel, so full tablet visual capture uses landscape. No map geometry, anchors or camera rules were changed to conceal these limitations.

Manual tablet interaction confirmed station selection/inspector, two zoom increments, Locate (collapses inspector while retaining selection) and simulated-touch pan. Phone orientation changed the responsive shell with artwork retained. Automated tests provide broader layer/zoom/state coverage than these screenshots. Emulator toolbar showed LAN/Q21 during visual review; benchmark graphics quality was not recorded.

Recommendation: retain Native as production default and keep Hybrid for owner review. Refine visual consistency and marker/art readability before considering adoption; no new artwork was created in this stage. Physical mobile/controller hardware, low-end performance, isolated texture/GPU timing, cold network loading and owner visual acceptance remain outstanding. A desktop emulator is not physical-device evidence.

Review cleanup: Test Play stopped, the temporarily disabled Test runner restored to Enabled=true (verified in Studio log), Test Rojo port 34873 left available. Production sync remains stopped. No publish, upload, permissions change, commit or push occurred.

Future artwork uploads are owner-operated: prepare local assets/instructions and wait for owner-supplied IDs. Automated Creator Dashboard uploads require a specific new request (D59).

## Historical upload-only result

## Final approval and upload verification

The owner's final R3.4 approval explicitly authorized this exact PNG/checksum, personal destination and Restricted privacy, followed only by read-only verification. The owner also manually verified the Test experience page displays **By @missawfulname**, closing the earlier Test creator verification gap. That evidence is owner-observed; the prior unauthenticated lookup limitation is retained below as history.

Immediately before upload, `Get-FileHash` again returned the approved SHA-256. Through the existing authenticated Opera Creator Dashboard window, the assistant observed **Uploading to missawfulname**, selected only the exact absolute path to `assets/r32-proof-v3/power-state-map-proof-v3.png`, and verified the queue contained one `power-state-map-proof-v3` Image PNG (423 KB). The already-enabled Restricted default had been manually verified by the owner; no setting was changed.

The single **Upload 1 asset** submission returned **1 file uploaded successfully**, Image ID **105986918888502**, with the six-motif thumbnail. The resulting [asset configuration page](https://create.roblox.com/dashboard/creations/store/105986918888502/configure) was inspected read-only. Its **Restricted** radio option was visibly selected and Open Use unselected. Ownership evidence is the authenticated personal upload destination and successful result under that same account, whose numeric identity was independently verified earlier. No unrelated public asset was substituted and no second file was uploaded.

No permission grants, privacy changes, Production operations, game publishing, Stage 2 code changes, commits or pushes occurred. Production universe `10776828545` remains untouched and Native remains default. The intended later isolated test target is Power States - Test, universe `10776833313`. Upload/privacy verification does not establish in-experience delivery, moderation completion, rendering quality or performance. Those checks remain for separately authorized integration.

Follow-up local validation: exact SHA-256 match and `git diff --check` passed. The 83 local assertion result below is earlier validation, not a newly run engine or real-texture suite. The original revision-3 manifest is retained unchanged as historical provenance; this report records the new Roblox ID and upload approval.

## Historical readiness record

The following entries document the pre-upload checks and blockers; the final approval/result above supersedes their pending status.

## Verified local input

- Exact file: `assets/r32-proof-v3/power-state-map-proof-v3.png`.
- Fresh SHA-256: `e1dcb61948e575bab85d94a6eed3dce1939fe87389455fc3bce735a28cab63cb`, matching both the revision-3 manifest and the owner's R3.4 request.
- `python scripts/ValidateR33.py`: **83 assertions passed**, covering source/export hashes, atlas pixels, manifest parity and test/production isolation. This is local evidence, not Roblox texture validation.
- Manifest records a 1024×1024 straight-alpha RGBA PNG with embedded sRGB and 8px gutters. All six existing descriptors remain unchanged.
- Provenance records historical OpenAI image generation without third-party input art, followed by owner-authorized local Pillow coastline compositing. Prompts, refinement history and correction record remain in the package. The manifest's rights record explicitly leaves owner rights/destination review pending; proof-use visual approval does not resolve that gate. Historical manifest was not rewritten.

## Ownership readiness follow-up — stop before upload

The owner supplied these destinations and approved the recorded provenance for private development/testing subject to applicable policies and outstanding rights checks. This is review authorization, explicitly not upload permission. The historical artwork manifest remains unchanged; this report records the subsequent confirmation.

| Item | Evidence/status |
| --- | --- |
| Intended personal asset owner | `missawfulname`, user `149564436`; no group or other account authorized. |
| Independently verified account | Public Roblox Users API `https://users.roblox.com/v1/users/149564436` returned id `149564436`, name `missawfulname`, displayName `Bea`, isBanned `false`. This verifies identity, not the signed-in session or upload authority. |
| Intended Test | Owner supplied universe `10776833313`, Power State — Test. [Dashboard](https://create.roblox.com/dashboard/creations/experiences/10776833313/overview). Ownership remains unverified. |
| Public Test lookup | `https://games.roblox.com/v1/games?universeIds=10776833313` returned a redacted/unavailable record: id/rootPlaceId `0`, title `[TITLE UNAVAILABLE]`, creator id `0`, name `[UNKNOWN]`. This establishes neither ownership nor invalidity of the supplied universe. |
| Authenticated Test lookup | Direct navigation to the supplied Test dashboard redirected to Roblox login. No authentication bypass or credential entry attempted. |
| Production exclusion | User-designated universe `10776828545` is out of scope. Its dashboard, settings, permissions and Studio window were not operated in this verification. |
| Local repeat validation | Fresh file SHA matched the approved value; all 83 `ValidateR33.py` assertions passed again. |

Owner's subsequent manual verification: the open Creator Dashboard Upload assets dialogue explicitly displays **Uploading to missawfulname**, accepts PNG files, and the account's Asset Privacy setting is enabled for newly created assets to be Restricted. Record this as owner-observed evidence, not assistant inspection. This closes the upload-destination and default-privacy questions. The owner reconfirmed **Power States - Test**, universe `10776833313`, as the intended isolated target and excluded Production `10776828545`.

The latest message does not explicitly confirm the Test experience's displayed creator/owner. That remaining ownership check must not be inferred from the upload dialogue. Before executing the proposed upload, obtain confirmation that the Test dashboard lists personal owner `missawfulname` (`149564436`), in addition to explicit upload approval. No credentials are needed.

Fresh SHA-256 rechecked after this manual verification: `e1dcb61948e575bab85d94a6eed3dce1939fe87389455fc3bce735a28cab63cb`, exact match. The previously recorded 83-check pass remains valid historical evidence; only checksum and documentation whitespace were rerun for this follow-up.

## Exact proposed action for final approval

Upload only `assets/r32-proof-v3/power-state-map-proof-v3.png` (1024×1024 RGBA, revision 3, checksum above) through the verified personal Upload assets dialogue to `missawfulname` / `149564436`, retaining the already-enabled Restricted default. Purpose: isolated real-atlas testing in Power States - Test, universe `10776833313`. After upload, record returned asset identifier(s), owner and Restricted status through read-only inspection. Do not change settings or permissions, add collaborators, grant Production access, publish a game, or begin Stage 2 under this upload action. Any additional grant or changed destination requires separate approval. Approval has not yet been given and no upload has occurred.

## Proposed permissions, pending verification and approval

Proposed destination: personal Creator Dashboard Development Items under `missawfulname` (`149564436`), for the one approved atlas. This is account-owned artwork, not an upload into Production. Use Restricted image access; do not choose Open Use, list on Creator Store or add collaborators. Inspect the account's Asset Privacy setting before upload and verify the resulting image and any decal dependency afterward. Do not change account privacy settings without approval. If restriction on creation is disabled, stop and obtain separate authorization before changing it or uploading.

Current [Roblox asset privacy documentation](https://create.roblox.com/docs/projects/assets/privacy), rechecked 2026-11-16, says owners can use their assets in their own games regardless of privacy. Thus Restricted upload and Test use are supported in principle if common ownership is verified; this is not a demonstrated runtime result. Same-owner accessibility is not a Test-only restriction and could also cover other owner experiences, but does not insert the atlas or change Production settings/code. No explicit Production grant will be made. If a separate Test grant proves necessary, stop for approval naming only universe `10776833313`. Open Use and experience grants are irreversible; metadata remains visible even for Restricted assets. Moderation and actual loading can only be checked after an approved upload.

## Remaining real-texture evidence after upload

Image ID `105986918888502` is uploaded and Restricted status verified. No permissions changes, runtime edits, game publication, commits or pushes. Production remains Native. No R3.4 Studio screenshots, loading measurements, texture memory, Native/Hybrid performance comparison or endurance results exist yet. R3.3 synthetic results remain separately documented and must not be presented as real-atlas evidence.

Stop after upload verification under the latest approval. A separately authorized Stage 2 can configure the recorded Image ID, implement the bounded real loader and ImageLabel readiness checks, then proceed to the approved visual/regression/performance scope. Any additional permission grant requires separate approval.
