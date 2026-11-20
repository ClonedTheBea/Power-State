# Illustrated World v1.4 — bounded Organic Coast proof

20 November 2026. **Stopped at actual filtering gate; no visual/default acceptance claimed.** Test-only implementation under the owner's v1.4 approval. Native remains initial/default. No real DataStore, Rowanbridge, Production, settings, upload, commit, push or publication operation.

## Geometry contract and gate

Cosmetic contract1 reads the immutable saved17×17 descriptor. Native NW-sample occupancy remains authoritative. Isolated one/three-land corners use `16 + min(8, floor(abs(elevationM)/15))`; the analytic boundary bound is24(sqrt(2)-1)=9.941125497 world units. The provisional one-unit filtering allowance is a separate actual-rendering gate. Straight ports, diagonal saddles and unknown sector borders stay exact.

`OrganicCoast` stores at most225 frozen cell-indexed records, at most four disjoint patches per cell. Candidates within80 units of an anchor are rejected. Complete ±32 anchor squares, route AABBs enlarged by16 units and actual artwork footprint rectangles also reject intersecting patches. Surveyed and completed district infrastructure use the same protections. Unsupported geometry falls back to Native; no world, electrical or placement rules change.

During any modal review in Organic mode, the map displays exact Native geography. Closing the review restores the cached organic presentation without moving the camera or advancing/suspending simulation. This includes construction review; cosmetic land does not confer eligibility. No arbitrary placement is added.

Independent local validation passed4,608 full-resolution local combinations (512 masks ×9 integer radii), preserving land/water four/eight-neighbour component correspondence. The10,000-seed/four-orientation sweep passed40,000 country cases with627,049 accepted corners, maximum40 per country, in84.88s. Corpus connectivity uses8WU raster sampling backed by the exhaustive1WU local rewrites and disjoint supports; it is not a full-resolution40,000-country raster or fresh Luau fairness test. Runtime footprint exclusions only remove independent patches.

Fresh authenticated Test Play verified universe10776833313, creator149564436 and Studio user149564436. The Luau geometry suite passed2,469,900 assertions twice, covering exact circle samples, unchanged ports, protected squares, borders, descriptor preservation and whole-footprint rejection.

[Local corpus](evidence/illustrated-world-v14/geometry-corpus.json) · [Unchanged approved PNG hashes](evidence/illustrated-world-v14/approved-art-checksums.json).

## Material and resource candidate

`OrganicRibbon` uses seven520-byte scanlines (3,640-byte logical mask payload), not a permanent full-sector mask. A three-sample land-side sand/stone ribbon reuses the existing palette and source-derived world-aligned grain. It is a procedural colour treatment, not a faithful extraction of painted cliffs. No new art file, image ID or water feature is introduced; approved atlas pixels remain frozen.

Organic suppresses categorical shore sprites while keeping the existing asset/decorative pool and native connections, markers, labels and hit targets. Native/Illustrated/Ground/Ocean comparisons remain available. One map-owned cache includes immutable country/seed/sector/generation/climate/start/material/coast versions. Changing the organic-versus-categorical variant releases the old four chunks and prepares the requested variant in the same256 ImageLabels. There is no second image pool. Pan/zoom never synthesize pixels. Cross-variant preparation latency is an explicit limitation; unchanged-variant switching reuses images.

Unchanged limits:20-second preparation, five-second newly-visible label readiness, four514-square outputs, one image update per frame,600 map descendants. Source images are destroyed after sampling. Full variant failure/cancellation regression remains incomplete; actual filtering failed as recorded below.

## Initial actual evidence

Two actual-image fixtures passed23,249 Organic assertions, repeated successfully in the retained sequence. Initial preparation12.54–12.83s; accumulated synchronous work944–971ms; four write submissions0.345–0.355ms; four retained images;470 descendants. Frame p95≈17.65–17.67ms, worst42.08/21.61ms. These are Studio desktop observations, not cold-CDN, isolated GPU memory or device guarantees.

Checks cover1366/820/360/740-width roots, five supported zooms plus0.937, fractional pan/shared edges, selection, Native review/restoration, angular-shore suppression, immutable descriptors and cleanup. Retained3,128 Illustrated and39,727 Ground/Ocean assertions passed, including synthetic failure/timeout/late-callback paths. Additional variant switching checks have been added but were not executed before the filtering stop; the23,249 count belongs to the earlier suite, not those additions.

## Actual filtering failure and attempted correction

Lossless PNGs were captured with Studio's built-in Screenshot command. Computer-control JPEGs are retained for visual comparisons only: JPEG ringing cannot establish this strict bound. No screenshot permission or Roblox setting was changed. The high-contrast diagnostic uses the same approved source, real chunks, gutters, ImageRect crops, shared screen edges and engine image presentation. Only land/water colour is replaced with white/black, and decorative images are hidden locally for measurement.

A radius18 corner passed the pixel-centre test at all five supported zooms, but that did **not** establish the general gate. The adversarial saved radius17 SW-land corner at world(320,704), with a116×116 displayed cell at1.8×, fails: a nonzero pixel at PNG(710,491), intensity4/255, lies1.206439WU outside the analytic curve. No brightness threshold was applied. The actual rectangle was AbsolutePosition(603,427), with PNG viewport offset(0,58) calibrated from unchanged straight ports. Mapping is x=256+(pixelX+0.5−603)×64/116 and y=704+(pixelY+0.5−485)×64/116; circle centre(303,721), radius17. This failure does not depend on a full-pixel-footprint interpretation.

A nearest-neighbour (`Pixelated`) diagnostic alternative reduced that pixel-centre witness to0.426933WU outward/0.331946 inward. However, the minimum0.55× case has a36×36 displayed cell: its visible land pixel footprint reaches1.152305WU outward. Pixel centres alone pass this inspected case, but this does not prove the stated visible one-unit allowance. The full-pixel extent is a conservative coverage interpretation, explicitly distinguished from the centre measurements. No acceptance definition or threshold was silently changed. These are local counterexamples, not global maxima.

| Diagnostic | Outward pixel-centre witness | Outward full-pixel extent | Result |
|---|---:|---:|---|
| Default filtering, radius17,1.8× |1.206439WU|1.596216WU|Fails even at pixel centres|
| Nearest filtering, radius17,1.8× |0.426933WU|0.816678WU|Inspected case only|
| Nearest filtering, radius17,0.55× |0WU (no outward centre)|1.152305WU|Not full visible-bound acceptance|

Reproduce the retained measurements with `python scripts/MeasureOrganicFilter.py`. It reads the unchanged PNG evidence and asserts that the known failures remain observable; successful execution of this evidence checker is **not** a renderer acceptance pass. See [default-filter witness](evidence/illustrated-world-v14/filter-r17-180-lossless.png), [nearest minimum-zoom witness](evidence/illustrated-world-v14/filter-r17-055-nearest.png), and [all five initial radius18 measurements](evidence/illustrated-world-v14/filter-measurements.json).

The nearest-filter change was removed from the renderer. It remains available only inside the diagnostic probe through `OrganicProbeNearest`. Organic is now excluded from the ordinary comparison cycle and direct requests unless the explicit Test-only `OrganicCoastProof` attribute is true. That attribute is absent/default-off. Native, Illustrated, Ground and Ocean retain their existing presentation. The candidate code and failed evidence are preserved for review, not promoted.

## Actual visual comparisons

Same fixture, camera and1366×704 root:

- Normal starter0.72×: [existing Ocean](evidence/illustrated-world-v14/ocean-normal-072.jpg) / [Organic candidate](evidence/illustrated-world-v14/organic-normal-072.jpg).
- Maximum78-junction fixture0.55× with selected generator and completed district: [existing Ocean](evidence/illustrated-world-v14/ocean-max-built-055.jpg) / [Organic candidate](evidence/illustrated-world-v14/organic-max-built-055.jpg).

The second fixture's Rowanbridge label is synthetic test data, not a read of the real profile. Curves soften isolated convex/concave corners; narrow inlets, an island and exact diagonal contact remain. Long straight segments and protected corners deliberately remain angular. The thin procedural ribbon is flatter and less rock-like than the painted shoreline sprites; it has not received artistic acceptance. Suppressing categorical shores frees existing bounded decorative draw slots, so additional existing hill decorations can appear in the maximum fixture. These comparisons therefore include that presentation difference, not just altered boundary pixels.

Tablet/mobile geometry was exercised in the engine suite; matched actual screenshots for those layouts and the full dedicated diagonal/selection/filtering matrix were not completed before the failed gate. JPEG captures are actual Studio views, not generated mockups.

## Performance and remaining gates

Fresh180-frame retained comparison measurements (Studio desktop):

| Mode | CPU p50/p95 ms | Frame p95/worst ms | Map descendants |
|---|---:|---:|---:|
|Native|0.101/0.134|17.448/18.068|362|
|Illustrated|0.788/1.067|17.644/18.045|470|
|Ground|1.392/1.842|17.719/22.072|470|
|Ocean|1.415/1.913|17.612/18.283|470|

Whole-client reported texture memory was40.699MB in these samples; total memory ranged1814.8–1822.1MB. These values do not isolate image/GPU memory and are not matched Organic-versus-Native performance results. The four output buffers contain4,227,136 RGBA bytes logically; engine overhead/residency is not inferred from that arithmetic. High-contrast preparation also observed90–93ms worst frames during diagnostic activity; these outliers are retained in the log, not suppressed or assigned a speculative cause.

`OrganicSoak` prepares matched30-second idle/moving phases and a dedicated600-second Organic movement run with bounded frame-event telemetry and a profiler marker. It was **not run** because correctness acceptance failed. No new MicroProfiler causal attribution was obtained. Historical242–279ms stalls remain unresolved. Default adoption remains blocked by these stalls, the filtering failure, incomplete visual acceptance and physical-device/input testing.

Fresh checks completed: independent40,000-country geometry corpus,2,469,900 Luau geometry assertions twice,23,249 initial Organic assertions twice,4,179 retained pure art and49,008 landscape assertions,3,128 Illustrated engine and39,727 Ground/Ocean assertions; final two Rojo builds/source mapping/security/whitespace and117 frozen-art/build-isolation/cosmetic-source checks passed. [Studio output](evidence/illustrated-world-v14/studio-current.txt) and [static report](evidence/illustrated-world-v14/static-validation.json) retain the evidence.

Not completed in this sprint: fresh full10,000-seed Luau world/route/fairness suite, complete fake gameplay/economy/construction/persistence/security sequence, extended Organic variant/cancellation tests, dedicated soak and final full-project Script Analysis. Prior v1.3 passes remain historical evidence only. Computer control failed/reset while opening Script Analysis; no fresh0/0 result is claimed. A command-bar diagnostic attempting to retrieve an app from a separate module cache also errored before the fresh probe approach; this is retained as a harness investigation error, not a gameplay defect.

## Changed-file inventory

New Test modules in `tests/integration/IllustratedWorld/`: `OrganicCoast.luau`, `OrganicCoast.spec.luau`, `OrganicRibbon.luau`, `OrganicGround.spec.luau`, `OrganicFilterProbe.luau`, `OrganicSoak.luau`.

Modified Test modules: `ContinuousGround.luau` (single-cache organic synthesis/cancellation), `IllustratedSectorRenderer.luau` (conditional shore suppression), `IllustratedController.luau` (explicitly gated experimental mode and Native modal boundary), and `tests/integration/IllustratedRun.client.luau` (opt-in runners/captures).

Local validation: new `scripts/ValidateOrganicCoast.py`, `scripts/MeasureOrganicFilter.py`; extended `scripts/ValidateIllustratedRenderer.py` isolation coverage. Documentation: this report, evidence directory, `PLANS.md` and `docs/DECISIONS.md`. Existing uncommitted v1.2/v1.3 files, production `GeneratedTerrain` changes and project configuration were preserved; they are not presented as v1.4 gameplay changes.

## Review boundary and recommended next step

Stop under the owner's required correctness-gate clause. Keep the existing Ocean experiment and Native default. Do not approve a larger fringe, increased image count, changed authoritative geometry or new artwork by inference.

Recommended next task: a focused filter/raster correction study within the same four-image contract, with an explicit reviewed measurement convention covering pixel centres, visible pixel extent, minification and all corner radii/phases. The current attempts do not prove that every possible bounded correction is impossible; they do demonstrate that neither tested presentation establishes the required visible allowance. A revised convention or larger allowance would require owner review, not an automatic test change. After a passing correction, rerun the deferred acceptance matrix and review the ribbon's visual quality before adoption.

At closeout Play was stopped; `RunIllustratedTests`, task Organic flags and capture trigger were removed, comparison mode reset to Native. Remaining enabled flags were only existing `IllustratedWorldProof`/`ContinuousGroundProof`; `RunRegressionTests` was false. No real-service execution gates were enabled and no real DataStore, Rowanbridge, Production, settings, artwork upload, publication, commit or push operation occurred.


## v1.4a — bounded correction investigation (20 November 2026)

**Stopped at the unchanged full-visible-footprint gate. Neither authorised correction is integrated.** The owner accepts prior geometry/initial integration as progress, not milestone acceptance. This investigation changes local analysis/documentation only; Native remains default and Organic remains behind the absent/default-off `OrganicCoastProof` gate. Ground + Ocean remains the recommended experimental presentation.

### Measurement contract and unavoidable limit

Keep five quantities separate:

1. **Analytic geometry:** displacement of the circular fillet from categorical geography, bounded by24(sqrt(2)−1)=9.941125497WU. Unchanged.
2. **Raster pixel centres:** signed distance from a displayed sample's centre to that analytic curve. This alone does not describe the complete displayed pixel.
3. **Full visible footprint:** the entire final screen pixel carrying any land contribution must be within1WU on the water side; any water contribution must be within1WU on the land side. This is the previously retained full-footprint convention, now explicitly tested on both sides as requested. It does not infer microscopic physical display subpixels.
4. **Filtering/coverage:** bilinear filtering combines neighbouring source texels; antialiasing produces fractional land/water contributions. Alpha over an ocean background still contributes water. Zero alpha cannot erase the screen pixel or circumvent its underlying colour. No opacity cutoff is introduced. The reference quantizes to actual8-bit output levels; that hardware-format model is distinguished from a chosen visibility threshold.
5. **Appearance:** subtle low-level fringes can be inconspicuous at gameplay zoom, but subjective inconspicuousness cannot waive the numerical rule.

The existing three requested observations are preserved unchanged: default radius17 pixel-centre witness1.206439WU; nearest radius17/1.8× full extent0.816678WU; nearest radius17/0.55× full extent1.152305WU. `MeasureOrganicFilter.py` reproduced them again. The original PNGs and their checksums remain unchanged.

A stronger counterexample is already present in the retained actual lossless0.55× PNG. The same radius17 SW-land corner, circle centre(303,721), is displayed through a36×36 cell spanning64×64WU. PNG pixel(712,485), observed RGB(0,0,0), covers world rectangle x=[307.555556,309.333333], y=[704,705.777778]. Exact circle-distance extrema over that rectangle are:

- Nearest: −1.110722615WU (inside land).
- Farthest: +1.141419766WU (outside land).

Any single colour assigned to this pixel fails the requirement: pure water encroaches1.110723WU into land; pure land extends1.141420WU into water; a mixture has both contributions across that same footprint and therefore both errors. Making it transparent exposes the background rather than eliminating the displayed footprint. Assigning an unrelated third boundary colour to exempt it from measurement would require a new visibility convention and would not be an authorised fix.

This is an **output-resolution lower bound**, independent of the intermediate mask resolution, alpha function or GPU sampler. The best binary choice still has an error of at least1.110723WU at an already observed supported view. A single such counterexample disproves the universal1WU requirement; no assertion that every possible appearance is unattractive is intended. The sampled reference additionally finds a1.236254WU unavoidable lower bound at radius24,0.55×,35×36 cell, local pixel(5,2). That second number is a sampled mathematical witness, not a new Studio capture or global supremum.

### Exactly two candidate families evaluated

The new read-only `scripts/StudyOrganicFiltering.py` operates on a66×66 local patch including one-unit gutters. It uses the current one-world-unit output texel scale,64-unit ImageRect region and shared rounded screen-edge dimensions. It does not allocate Roblox images, change runtime code, retain a sector mask or introduce dependencies.

**Candidate1 — conservative alpha/inset/material clipping.** Evaluate a one-unit linear coverage transition `clamp(0.5 − signedDistance − inset,0,1)` for insets0,0.25,0.5,0.75,1WU, composed over water before reference bilinear display. This models clipping land material with premultiplied coverage rather than leaking unassociated transparent RGB. Insetting reduces some outward coverage but increases inward water encroachment. Across the sampled local cases, largest two-sided full-footprint deviations are2.831296,2.988827,3.302548,3.572049 and3.733746WU respectively. These are reference-model results, **not actual candidate rendering measurements**. None passes. More aggressive erosion is not pursued because it cannot solve the indivisible-pixel counterexample and risks losing apparent land. No topology-changing inset is integrated.

**Candidate2 — supersampled mask with controlled downsampling.** Evaluate4×4 and8×8 subpixel coverage per final texel, area-average into the unchanged one-WU output texel, quantize toRGBA8 and use the same reference bilinear presentation. Largest sampled local full-footprint deviations are2.831296WU and2.830287WU. Better coverage estimation does not reduce the final screen-pixel footprint; fractional coverage also has nonzero support on both sides. Neither passes. The study accumulates coverage into the small output patch instead of retaining a large supersampled bitmap. No higher-resolution final image or extra pool is proposed as an implicit fix.

Both reference candidates fail even before complete channel/port/infrastructure validation. The proof does not require inventing a third candidate or changing the coast model.

### Coverage, evidence and limits

The reference evaluated2,079 raster cases: seven parameter settings across the two families, nine radii16–24, nine zooms(0.55,0.6,0.72,0.837,0.937,1,1.2,1.337,1.8) and all possible floor/ceil width/height combinations of a64-unit cell. For the current integer-snapped ImageLabel origins, arbitrary fractional camera phases select one of those width/height outcomes; screen-integer translations preserve local distances. Four orientation transforms and land/water complements were rerendered numerically (16,632 checks); half-level byte rounding can differ by one level and is recorded as format rounding, not an acceptance threshold. Every parameter variant has297 failing raster cases in this reference.

Results: [filter-study.json](evidence/illustrated-world-v14a/filter-study.json). Reproduce with `python scripts/StudyOrganicFiltering.py`. The script asserts the unavoidable counterexample and candidate failures; its successful execution means the investigation is reproducible, **not that Organic passes**.

The lower-bound witness uses the unchanged real Studio PNG, recorded crop/viewport offset and actual displayed rectangle from v1.4. No new candidate was integrated or captured in Studio, and no new engine/GPU performance claim is made. Reference maxima concern pixels fully inside local quarter-circle patches, not a global all-map worst case. The existing actual radius17 failure and the mathematical impossibility establish the stop; they do not substitute for a full acceptance matrix.

A passing candidate would still need fresh actual lossless captures, diagonal saddles, narrow channels, cropping/gutter/filter tests, protected sites and full phase/zoom verification. These dependent acceptance checks were not run after the StageA/B failure. No live account/service access was needed for this local investigation. Prior build, instance, preparation and memory results remain historical; no new runtime resource usage is asserted.

### Artistic and regression status

StageD material polish and StageE full validation are explicitly conditional on filtering success, so neither began. Existing matched Ocean/Organic screenshots above remain the artistic evidence: curves soften some corners but the procedural ribbon is flatter than the painted shore. No new artwork, painting, material change or acceptance claim is made. Historical242–279ms stalls and prior incomplete Organic soak/Script Analysis remain unresolved. No additional test threshold, gameplay rule, geography, electrical anchor, protection or construction review behaviour changed.

Fresh local checks: candidate/reference study, preserved PNG witness reproduction, Python syntax compilation and Git whitespace. No fresh Studio regression, Rojo build or Script Analysis result is claimed for this documentation/local-analysis-only continuation; conditional StageE has not been reached.

### Specific alternative for owner review — NOT APPROVED

Recommend retaining Ground + Ocean and deferring Organic to a later visual-geography milestone, as directed when neither method succeeds.

If the owner instead wants to revise the presentation contract, a specific candidate policy is: keep the analytic9.941125497WU bound and require at most1WU **pixel-centre** error on both sides, while separately bounding full visible support by `1 + 0.5*sqrt((64/displayWidth)^2 + (64/displayHeight)^2)`WU per cell. This adds the unavoidable half-diagonal screen-pixel footprint explicitly; it is not an opacity threshold. For35×35 pixels at minimum zoom this ceiling is2.292995WU; for115×115 at1.8× it is1.393520WU. It would be a genuine relaxation requiring explicit owner approval, not clarification that retroactively passes v1.4. The present filtered candidates are not certified under that alternative either. Smooth antialiasing and appearance would require separate proof, and a change to physical pixel density/minimum zoom would likewise need review.

No allowance or convention has been changed in code or accepted here. Stop at this review gate. Changed files in v1.4a are only this report, `PLANS.md`, `docs/DECISIONS.md`, `scripts/StudyOrganicFiltering.py` and its local JSON result; all earlier work and failed evidence are preserved.
