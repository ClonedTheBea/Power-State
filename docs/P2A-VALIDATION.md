# P2a — first interactive electricity simulation

17 November 2026. **Implemented and validated in isolated Test.** Owner's P2a request authorizes gameplay only for this slice, not P2b. Native remains default. No publishing, uploads, permissions, saving or spendable economy.

## Working contract

Fixed Westhaven fixture: 1,000 residents (no demographics), one generic 5 MW generator, one 10 MW substation, one 3 MW settlement demand bus and two 10 MW connections. All start connected/online. These owner-approved values replace the previous 3 MW/.75 MW design candidate for P2a only. The demand bus has a 10 MW aggregate distribution gate; it is not an additional substation.

Online: actual output/delivery 3 MW, unmet 0 MW, generation headroom 2 MW. Offline: available/output/delivery 0 MW, unmet 3 MW. Restoring On restores service. Generation headroom is available source capacity minus actual output, not a guarantee that spare capacity can traverse a congested network. Capacity-gated routing, not a national supply subtraction, determines delivery.

One wall-second scheduler step advances one simulated minute (1/60 hour). Two overdue steps maximum per Heartbeat; larger backlog is dropped without crediting skipped simulation time, with delayed status. Normal menus do not pause this clock. Commands change instantaneous power immediately but do not integrate extra MWh. Each completed online step delivers 3/60 = **0.05 MWh**. Session totals and an exact bounded **1,440-minute rolling energy ring** support observed reliability; zero-demand/no-history is Unknown, and the GUI labels the observed minutes. This refines the previous proposed 24 hourly buckets to avoid inaccurate partial-hour eviction. It is neither a persistent guarantee nor grid frequency.

## Architecture and authority

| Module | Responsibility |
| --- | --- |
| Server NetworkModel | Fixed starter topology, valid IDs/ratings, integer-kW input bounds |
| Server GridSolver | Deterministic residual max flow; shared bidirectional physical line gates and node throughput gates; reports flows/service/shortfall |
| Server Country | Session state, one-minute energy integration, bounded reliability, snapshot metadata |
| Server IntentHandler | Owner, exact payload shape, finite sequence/revision, epoch, asset and transition checks; token bucket |
| Server SimulationService | At most eight separate player countries; one bounded scheduler; private RemoteEvent replies; cleanup on leave |
| Client LiveViewModel / SimulationClient | Server snapshot → existing dashboard/map/inspector; confirmed toggle, stale/unavailable states, explicit placeholder labels |

Solver scope is one source and one sink with equal route cost, so deterministic max flow suffices; min-cost dispatch, priority/fairness tiers and technologies remain later work. Integer precision is 0.001 MW, graph cap 32 nodes/64 physical lines and 200,000 residual edge scans per solve. Failure commits no partial step and suspends the country. Routes use residual reverse edges, not greedy irreversible paths; tests cover rerouting, cycles and parallel links. This is a lossless strategic transport approximation, not AC/DC electrical physics.

Only the Studio Test universe **10776833313** starts this service/client profile. Modules can exist in the normal build but do not activate there; the normal published/Production path remains the authored Native shell. Production **10776828545** was not synced or reconfigured. The previous default Rojo server was stopped before edits; only Test port 34873 is served.

The server derives actor identity from OnServerEvent. Intent carries only version/kind, session epoch, next sequence, control revision, generator ID and desired boolean. No client MW, MWh, population, cash or ownership values are accepted. Maximum seven flat fields, bounded strings/numbers, one generator action; burst four/refill two per second. Throttled traffic receives no per-request reply, avoiding response amplification. Strict sequential IDs reject gaps and duplicates; valid stale/no-op intents consume sequence without changing operation. Control revision changes only on accepted operations, independently of periodic snapshot revision. Sync plus periodic private snapshots recover dropped acknowledgements; controls wait for confirmation and show unavailability after stale data. No unbounded command queue or request history.

Protocol rationale reviewed against official [client/server boundary guidance](https://create.roblox.com/docs/scripting/security/client-server-boundary) and [RemoteEvents](https://create.roblox.com/docs/scripting/events/remote) on 17 November 2026. API guidance is not evidence of our implementation's behavior; tests below are separate.

## GUI and retained proofs

The live profile reuses the existing dashboard, native terrain, selection, inspector, input/navigation and camera. Its three server-described terminals use the existing station/junction/capital positions without changing the demo fixture. Westhaven replaces Newford's name only in this live view model. Unused Southbank/Eastmere terrain bundles are hidden only in this profile. Terrain remains cosmetic; interactive links show server flow and the inspector gives textual service status. No artwork implies demand or connectivity.

The generator inspector has a registered 44px On/Off control for mouse/touch/keyboard/gamepad. Live supply/demand, available capacity/output, unmet demand, headroom, MWh and history come from snapshots. Bank says PREVIEW and is not spendable; population says FIXED. The old five-asset Native, six-motif Hybrid and settlement Hybrid proofs still mount through their original test modules and remain regression-tested. No experimental Hybrid is promoted to default.

## Validation status

- Both normal/Test Rojo builds passed; strict directives, permitted remote senders, no persistence API and Git whitespace checks passed.
- Existing artifact/isolation checks: 83 +14 +4 +27 = **128** passed.
- New `ValidateP2a.py`: **34** static/build checks passed. Server domain modules remain under ServerScriptService; old preview/geometry/manifest and both approved PNGs unchanged (text comparison normalizes Git CRLF; artwork comparison is byte-exact).
- First Test engine run: **432 P2a server assertions** passed; 1,000 starter solves took **14.64 ms total** in Studio desktop (not maximum graph/device proof).
- P2a client suite: **57 reported assertions** passed across 1366×704, 360×580, 640×300, 768×960 safe roots, plus cleanup/remount checks after the printed count. Real On/Off/On replies, preserved camera/selection/inspector/navigation, energy progression and **541 map descendants** observed.
- Script Analysis: client and server views both showed zero errors/warnings with Current Script Only disabled. Captures: `p2a-screenshots/script-analysis.png` and `script-analysis-server.png`.
- Supplementary `P2aRemote.spec`: **32 actual transport assertions passed**, including malformed payloads, wrong asset/session, sequence gaps, duplicate/no-op/stale revision, Off/On recovery and burst response bounds. Executed the exact local module body in the Test client command bar because it was added after Play started; no runtime source was replaced.
- All retained engine suites passed: Shell 324, Currency 26, GUI 348, Currency GUI 16, Interaction 135, R3 190, R3.1 52, R3.3 739 synthetic, R3.5 217, R3.7 1,411 (real profile plus labelled synthetic faults), R3.4 259 real-texture assertions: **3,717 retained assertions**. New P2a suites add **521 reported assertions**, plus two cleanup/remount checks.
- Three ten-minute soaks passed: settlement Hybrid **600.1 s / 589 cycles / 595 map descendants**; original Hybrid **600.5 s / 590 cycles / 935 shell descendants**; Native **600.9 s / 591 cycles / 929 shell descendants**. Map counts and whole-shell counts are different scopes. These retained GUI soaks ran with the P2a server active; they are not a separate P2a GUI endurance claim.
- Actual desktop inspector clicks verified normal, lost and restored supply at matching camera/viewport. Phone Device Simulator (iPhone 17 Pro) verified portrait Off/On, rotation to landscape, inspector scrolling, drag/pan, zoom and recenter with selection retained. No physical device/controller or two-client session was tested.
- Local documentation link check: **143 targets, zero missing** before adding the screenshot links below.
- Timing/log records: [P2A-MEASUREMENTS.json](P2A-MEASUREMENTS.json). Main regression run: 09:23:34–09:55:44 UTC on 17 November 2026. Test Play was stopped after manual review; the temporary runner disable was reverted and confirmed true in Studio. Native remains the normal default; no publication or Production changes.

## Visual evidence and usability

| State | Desktop | Phone emulator |
| --- | --- | --- |
| Normal: 3/3 MW, no shortfall | [Normal](p2a-screenshots/supply-normal.png) | [Portrait normal](p2a-screenshots/mobile-normal.png) |
| Lost: 0/3 MW, 3 MW shortfall | [Offline](p2a-screenshots/supply-lost.png) | [Portrait offline](p2a-screenshots/mobile-offline.png) |
| Restored: 3/3 MW, history retains outage | [Restored](p2a-screenshots/supply-restored.png) | [Portrait restored](p2a-screenshots/mobile-restored.png) |

[Landscape control after scrolling](p2a-screenshots/mobile-landscape-control.png) and [landscape map after recenter](p2a-screenshots/mobile-landscape-map.png) document the short-height path. The half-height inspector may require Expand or scrolling to reach the generator action; the expanded portrait sheet exposes it directly. Landscape retains the scrollable control and compact live supply header. This is a usability limitation, not hidden gameplay: the action remains reachable. The country uses the existing Native artwork, not the experimental Hybrid proof. Desktop history is already below 100% because the preceding transport tests deliberately switched supply off.

## File inventory

- Added server modules: `src/server/Simulation/{NetworkModel,GridSolver,Country,IntentHandler,SimulationService}.luau`.
- Added client modules: `src/client/Simulation/{LiveViewModel,SimulationClient}.luau`.
- Changed the two Bootstrap scripts, `AppController.luau`, `HeaderView.luau` and `MapView.luau` to expose the isolated live profile and reuse existing components.
- Added unit and integration `P2a.spec.luau`, supplementary `P2aRemote.spec.luau`, and `scripts/ValidateP2a.py`; updated both test runners and `scripts/Validate.ps1`.
- Updated README, roadmap, decisions, technical architecture, electricity simulation, minimal simulation, starting-country and testing documents; this report and its evidence files are new.
- No changes to the approved artwork, preview fixture, map geometry, sprite manifest or project mappings.

## Studio reproduction

Serve `rojo serve test.project.json --port 34873`, connect only **Power States - Test**, then Play. The development runner first exercises P2a and then all retained visual suites, including three ten-minute soaks; allow roughly 33 minutes. At completion it mounts the live P2a interface. In Assets choose **Starter Generator**, inspect confirmed values, Switch generator Off, observe 0/3 MW and 3 MW unmet, then Switch On and observe 3/3 MW. History retains the outage while instant service recovers. Bank does not grow.

For a manual-only review after completing suites: stop Play; temporarily disable `StarterPlayerScripts.DevelopmentTests.Run` in Test Studio; start Play (Bootstrap mounts P2a). Restore Run.Enabled after review; do not publish this local test setting. Use Device Simulator before Play for actual emulator input/orientation review; safe-root tests alone are not physical-device evidence. Full original proofs remain available by stopping/remounting their documented Test modules after destroying the current shell.

Supplementary remote suite: in the Test client command bar require the Test `P2aRemote.spec` module; it sends deliberately malformed/stale/duplicate requests through the real remotes, restores generator On and disconnects its observer. Do not run during an interactive player action. It cannot spoof a different player's actual Roblox connection identity; multi-client isolation still requires a separate observed session.

## Boundaries and next step

No climate, procedural generation, construction, population growth, economy settlement/costs, fuel buying, persistence, planning/events, storage/imports, boosts, ticker or shop. The earlier proposed P2a financial estimates are deferred under this request's narrower accounting boundary. Single-client tests plus pure owner-isolation fixtures are not a multiplayer load test. Physical touch/controller hardware, larger-graph performance and cold-start network stress remain separate limitations.

Recommend review of this operating proof, then a separately authorized P2b for deterministic seeded starts and climate-aware demand after its algorithm/version/fairness gates. Do not begin that work here.
