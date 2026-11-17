# R3.5 validation

16 November 2026. R3.5 implementation and available validation complete; owner visual acceptance remains pending. Isolated Test universe 10776833313 only. Production 10776828545 untouched; Native remains its default. The owner's R3.5 request accepts R3.4 technical results, not Hybrid production adoption.

## Files and behavior

- `tests/integration/HybridPresentation.luau`: Test-only compact badge/contextual label decorator, native restoration and cleanup.
- `tests/integration/HybridProof.luau`: optional cohesion attachment (default enabled); explicit false retains the R3.4 baseline.
- `tests/integration/R35.spec.luau`: real-image presentation, original targets/actions, mode/anchor preservation, label toggle/focus, bounded movement, missing-art restoration and cleanup checks.
- `tests/integration/R34.spec.luau`: explicitly mounts the unchanged R3.4 presentation for its established baseline-count/performance assertions. No assertions removed.
- `tests/integration/Run.client.luau`: adds R3.5 to the existing suites; retains both endurance suites.
- `scripts/ValidateR35.py`: verifies the new decorator and suite are in the Test build and absent from production.
- `PLANS.md`, `README.md`, `docs/DECISIONS.md`, `docs/GUI-VISION.md`, `docs/TESTING.md`, this report and [visual treatment / future settlement contract](R35-VISUAL-COHESION.md) document implemented versus proposed work. Actual captures are in `docs/r35-screenshots/`.

No files under `src/`, atlas assets, coordinates, manifests, project mappings or dependencies changed for R3.5. Earlier uncommitted R3.4 work remains present and is preserved.

## Current evidence

Both Rojo builds and static boundary checks passed. Existing local atlas checks: 83 passed; R3.4 isolation checks: 14 passed; R3.5 build isolation: 4 passed (**101 total**). These are not runtime/type checks. The atlas checksum remains `e1dcb61948e575bab85d94a6eed3dce1939fe87389455fc3bce735a28cab63cb`.

Studio existing regression suites passed 1,830 assertions; R3.4 passed 259 real-texture assertions. Initial R3.5 passed 214; after adding overview focus-name behavior and explicit budget guard, a fresh Play session passed the final **217** assertions. Total retained/new coverage: **2,306 assertions**, without double-counting the initial R3.5 run. Final edit-mode Script Analysis: **0 errors and 0 warnings**, Display only current script unchecked ([capture](r35-screenshots/script-analysis-final.png)).

Retained R3.4 real-texture soak: **600.9 seconds / 591 cycles / 935 stable shell descendants**. Native soak: **600.9 seconds / 591 cycles / 929 stable descendants**. These are the baseline renderer endurance paths, not a ten-minute run of the new decorator. R3.5 tests exercised four responsive sizes (1366×704, 360×580, 640×300, 768×960), 240 pan/zoom iterations, mode/selection/anchor retention, label off/focus at overview, actual local image-readiness loss and teardown. Its **595 map descendants** remain stable, adding 15 to the six-image proof and staying below 600. No claims of R3.5 GPU improvement, isolated texture-memory savings or physical-device performance are made.

The final focus refinement specifically fixes the case where a non-selected asset had keyboard/gamepad GUI focus at overview zoom but its name was suppressed by the old zoom-band rule. Contextual names now use the existing viewport/collision constraints independently of that band. No control or input route was replaced.

## Visual comparisons and limitations

Each pair uses the same real atlas, camera, selection and viewport; only `CohesionEnabled` changes. These are unedited Studio captures.

| View | R3.4 marker treatment | R3.5 marker treatment |
| --- | --- | --- |
| Desktop, observed map viewport 1518×519 | [Before](r35-screenshots/desktop-r34-markers.png) | [After](r35-screenshots/desktop-r35-markers.png) |
| iPad Air 5th Generation emulator, landscape | [Before](r35-screenshots/tablet-r34-markers.png) | [After](r35-screenshots/tablet-r35-markers.png) |
| iPhone 17 Pro emulator, landscape | [Before](r35-screenshots/mobile-r34-markers.png) | [After](r35-screenshots/mobile-r35-markers.png) |

Station and Newford illustrations are substantially less obstructed. Transmission connections, native substations and all five targets remain visible. Selected station retains its name and brackets; other names no longer form a permanent wall. Tablet station tap opened its existing inspector ([capture](r35-screenshots/tablet-r35-selected.png)); phone Newford tap opened the existing short-layout detail sheet ([capture](r35-screenshots/mobile-r35-selected.png)). Recenter and switching between desktop/tablet/phone layouts were observed with selection retained.

The 22px badges have less technology detail at overview than the old 44px silhouettes; owner/device usability review remains necessary. Native hills, forest triangles, villages, field strips and shore outlines still visibly differ from the painted motifs. R3.5 does not repaint them, change the atlas or conceal mismatches by moving terrain. Selected captions can still cover a small part of artwork, deliberately prioritising identification. Short mobile landscape still crops the country at the preserved minimum zoom.

This session's phone rotation control changed landscape direction rather than producing a portrait capture, despite the PlayerGui reporting Sensor. No orientation code/settings were altered to force a screenshot. Portrait/short-layout dimensions passed automated tests; a fresh portrait emulator capture and physical-device usability remain outstanding. Emulator LAN/Q21 was visible for tablet/phone review; desktop showed Auto. These captures are not physical hardware or benchmark evidence.

Recommendation: retain this as an isolated review candidate, with Native the default. Owner review of badges/contextual labels should precede the small local village/terrain-transition study described in the treatment document. A full library, uploads and production adoption require separate approval. No extra selection ring is implemented; existing brackets/focus feedback remain.

Cleanup: Test Play stopped and its temporarily disabled runner restored to Enabled=true, confirmed in the Studio log. Test Rojo remains on port 34873; no production server was started or production window operated. No additional artwork, permissions changes, uploads, publishing, commits or pushes.

## Comparison instructions

Serve only `test.project.json` on port 34873 and open Power States - Test. The isolated runner executes the retained suites and leaves a real proof in Native mode. Select CountryMap in the client PlayerGui shell, set `RequestedProofMode` to `Hybrid` and wait for `ProofLoadState=Ready`. Set `CohesionEnabled` false/true to compare R3.4/R3.5 markers without changing camera, atlas or selection. Native mode is the separate whole-renderer baseline. Do not run the proof in Production.

Inspect station/settlement recognition, hover/focus names, 44px taps, selection/inspector, Assets list, Layers/Labels, pan/zoom/Locate/Recenter and portrait/landscape. A missing image must restore the original marker treatment. Physical touch/gamepad hardware and owner visual acceptance remain outstanding; desktop emulator results do not prove low-end mobile performance.
