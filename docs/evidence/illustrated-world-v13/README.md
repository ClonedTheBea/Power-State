# Illustrated World v1.3 evidence

20 November 2026. See [full report](../../ILLUSTRATED-WORLD-V13-VALIDATION.md).

- JPEGs: actual unedited Power States - Test Studio captures. The max78 fixture's displayed Rowanbridge name does not identify the real saved country. Safe-root sizes are not physical devices.
- PNGs and `*-geometry.json`: reproducible **local-only** geometry/material diagrams from `scripts/StudyOrganicCoast.py`. Actual exported descriptor seeds and explicitly synthetic adversarial masks are distinguished in `geometry-validation.json`. They are not Roblox renders, finished new artwork or upload-ready assets. `*-rejected-contour.png` demonstrates an unsafe alternative.
- `corpus.json`: fresh independent Python10,000-seed/four-rotation grammar reference. Actual Luau sweep is separately recorded in Studio output.
- `static-validation.json`: frozen-art/Test isolation checks; no real storage access.
- `benchmarks.json`, `preparation.json`, `endurance.json`, `native-control.json`: actual desktop Studio measurements. Whole-client memory/texture tags are not isolated EditableImage/GPU memory. Idle command-bar Native control and mixed-mode harness are different workloads, not causal proof.
- `studio-current.txt`: task-local CreatorOutput/Warning extract with failures, injected faults and timing evidence preserved. The first combined frame-investigation JSON was truncated by Studio; first two events and full soak summary remain usable. Do not reconstruct missing event values.
- `source-checksums.json`: code/art/descriptor provenance checksums at closeout.

Local diagrams reuse the previously approved ground PNG (SHA256107448465ac25fc182841da2eeb706bec04a2774401641161301745393d3f1e2); existing artwork rights/provenance remain in its package. No new AI artwork was generated, no source atlas altered, no dependency installed and nothing uploaded. The scripts are editable source for these diagnostic outputs.

Commands: `python scripts/StudyOrganicCoast.py`; `python scripts/ValidateIllustratedCorpus.py`; `python scripts/ValidateIllustratedRenderer.py`; `powershell -NoProfile -File scripts/Validate.ps1`. The last two Python validators write their historical v1 evidence destinations: copy the new results here and preserve the original historical files rather than replacing prior measurements.

Studio runs used the existing opt-in `RunIllustratedTests`/`RunContinuousGroundTests`/`RunContinuousGroundSoak`, `RunIllustratedServerTests`, and `OperationsV11Legacy` harnesses in separate sessions. They use fake storage only. Native remains default. Do not enable unrelated real-execution flags.
