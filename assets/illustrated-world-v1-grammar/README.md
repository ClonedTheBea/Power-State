# First landscape atlas — Stage A grammar gate

**Technical diagnostics only. No polished artwork, packed art atlas or upload-ready files.**

The owner approved local production subject to shoreline compatibility first. The approved twelve-piece shoreline vocabulary represents twelve mixed 2×2 cases, plus land/water homogeneous cases with no sprite. Two diagonal cases need a composition rule. Pairing the existing convex cases preserves the base mask but overlapping water-side strips do not have a unique coverage owner under the proposed land/water clipping rule.

## Reproduce

Run `python assets/illustrated-world-v1-grammar/validate_grammar.py` from the repository root. Uses the existing independent Python integer reference and installed Pillow. No network, runtime changes or dependency installation. Expected exit code2 records the unresolved acceptance gate; it is not a Python crash. It checks all289 stored golden elevations,512 exhaustive3×3 arrangements, the exact10,000 P2b seed corpus with natural rotations, and additionally each seed under all four reservation orientations. Those additional orientations are diagnostic cases, not newly accepted player countries. Candidate0 follows the historically validated zero-fallback corpus; this is not a new full fairness/candidate-selection engine test.

## Files

- `grammar-16-patterns.png`: all16 vertex classifications; diagnostic colours, no finished art.
- `adversarial-arrangements.png`: narrow headland/inlet, island/lake, stair, checkerboard and disconnected components.
- `corpus-mask-contact-sheet.png`: six actual corpus-reference masks with exact seed/index/rotation.
- `paired-corner-overlap.png`: source-over alpha counterexample under the proposed8-world-unit bands.
- `five-zoom-mask-check.png`: categorical-mask views at0.55/0.72/1/1.2/1.8; not painted texture/halo/readability acceptance.
- `grammar-results.json`: measurements, exact first counterexample and source hashes.
- `amendment-proposal.json`: unapproved two-tile companion-atlas proposal; no fabricated image/hash.
- `isolation-results.json`: rerun retained83/14/4/27 local checks.
- `package-hashes.json`: actual diagnostic-file hashes, not an artwork atlas checksum.

## Proposed correction — requires review

Add two independently lit diagonal-junction images, NW+SE land and NE+SW land. Keep north up and upper-left lighting; never rotate/mirror one to produce the other. Preserve the original four-connected components and Native pixel ownership at the shared point, with no invented land bridge or carved water channel. Outer ports must match the corresponding straight/convex motifs, and the central water treatment is authored once per junction rather than painted twice by overlapping sprites.

Retain the sixteen256-square allocations in the proposed1024-square main atlas. Put the two additional256-square allocations in a512×256 companion atlas, each with8px gutters and240-square content, pivot120,120 and64-square world canvas. This changes the approved batch from16 to18 elements and introduces another image; it has NOT been produced or approved. It adds0.5MiB raw RGBA base storage, about0.667MiB including a full mip chain, before platform-specific overhead. No new upload is requested now.

A twelve-sprite solution is not mathematically ruled out. An alternative is to specify and validate mutually exclusive material masks or a blend-aware compositor for paired corners. That is a new explicit composition contract; generic Native land/water clipping and ordinary source-over are insufficient. It must fit the same runtime instance/loading constraints before acceptance. The direct two-tile extension is recommended because it keeps one authored patch at each junction and avoids overlapping corner passes.

## Still required after approval

Generate coherent artwork with the existing approved motifs as style references. Validate exact edge colour/alpha ports, source ownership, straight/corner/diagonal seams, minimum-zoom readability and land-mask fidelity. Do not claim geometry coverage proves painted seams. Re-run local contact sheets and atlas packing checks before owner acceptance/upload. Preserve the Native baseline and both existing approved atlases/manifests.

Polished production, gas/forest/field composite previews, all16 final sprites, editable illustration sources, completed atlas manifest and upload instructions are pending at this explicit Stage A stop. No runtime integration, real DataStore, Production, upload, publication or commit occurred.
