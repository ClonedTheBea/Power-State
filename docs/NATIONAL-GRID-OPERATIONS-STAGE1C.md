# Stage 1C exact cut-constraint candidate

Investigation, 18 November 2026. Not accepted until differential/oracle and all retained performance gates pass.

## Correctness argument prepared before acceptance

For a fixed network, replace customer terminal arcs with target capacities. Feasibility means the maximum source-to-super-sink flow equals the sum of these targets. At a failed maximum flow, let R be the residual source-reachable vertices. The super-sink is outside R. Its minimum-cut capacity consists of fixed network/source arcs crossing R, plus target arcs whose terminal is in R. Therefore every feasible target vector x satisfies sum(x_i for terminals outside R) <= C, where C equals the failed maximum-flow value minus the current target sum inside R. C is independent of subsequent targets. Node gates, shared bidirectional physical gates, source limits and residual rerouting are already represented by this graph; none are relaxed.

The candidate remembers these necessary subset inequalities only during the current solve. At most255 nonempty sink subsets exist. Each rejection adds a new subset or tightens its capacity. Universal node-capacity and aggregate-source inequalities are safe starting constraints. A feasible flow remains the certificate before accepting any nontrivial candidate vector; constraints alone never declare a new vector feasible.

For a progressive round, each active target is max(previous target, floor(request * f / 1000)). This is monotone in integer f. Choose the greatest f satisfying all known cuts. If a full flow rejects it, add its violated cut and repeat with a strictly smaller f. No feasible f is skipped because every rejected higher value violates a necessary inequality. A successful full flow at the greatest remaining f therefore gives exactly the fraction selected by the reference binary-feasibility procedure. Zero-demand sinks remain excluded.

For the remainder, generate the reference sequence of single-kW increments using exact delivered/requested cross products and the same persisted-step rotating tie order. Stop generation at the same first full-sink event, or one increment beyond the approved quantum bound. Feasible prefixes are downward closed: reducing any terminal withdrawal cannot destroy feasibility. Choose the longest prefix satisfying known cuts, certify by full flow, and add a cut on rejection until certified. This is exactly the prefix before the reference's first failed increment, with no approximate batching or changed tie order. The empty prefix is already certified by the progressive phase. A cut binding at the chosen prefix makes each member individually unaugmentable while retaining the other minima. Freezing these members together cannot remove a feasible later increment: later minima only grow. At least one active bus freezes or a full bus leaves each round; retain the eight-round limit.

The final delivery vector is then routed by the unchanged Stage1B minimum-cost path. Thus customer priority, cost objective, physical capacities and atomic pure failure remain unchanged. Numerical arithmetic stays integral and within the existing exact ranges. Operation accounting covers every traversed flow edge across all passes with the unchanged2,000,000 ceiling. Prefix lists and cut tables are bounded; no cross-call dispatch cache exists.

## Island and cost decisions

Explicit island decomposition was evaluated but deferred: the cut constraints already separate independently constrained islands, while retaining one global rotating remainder order. Splitting and recombining local solvers would need extra proof of equivalence for quantized transitions. Stage1B cost routing and equal-cost behavior remain unchanged for this first candidate. These are deliberate limits on the investigation, not permission to change the acceptance gate.

## Reference and reproduction

`tests/unit/FleetStage1B` preserves the exact Stage1B modules and hashes. `FleetBaseline` preserves the earlier algorithm. New allocation logic is in `FleetAllocation`; normal First Playable entry remains unchanged. Candidate acceptance and measurements are recorded in the main Operations validation report after testing.

## Incremental residual refinement

After the first correct but over-budget trial, retain the last certified residual and target vector within the solve. Every later candidate component is at least that certified target. Increase only each terminal arc's residual capacity by its nonnegative delta; the existing flow stays feasible. A residual maximum flow supplies exactly the additional demand or exposes the same necessary minimum-cut inequality. Failed trial residuals are discarded, so they cannot contaminate later trials. Reverse arcs still permit rerouting existing paths without reducing the certified sink withdrawals. This preserves feasibility and all target decisions; it is not a cache across changed input calls. The final economic dispatch remains a fresh solve.
