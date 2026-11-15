# Global events

Status: data-driven limited-time shared events and Operation Christmas Cheer are confirmed. Calendar timezone, accounting protocol, targets and rewards are proposed D15. [Simulation](ELECTRICITY-SIMULATION.md) supplies physical delivery; [Data](DATA-AND-SECURITY.md) supplies durable commits.

## Definition and instance

An event definition includes ID/version, title/localization keys, UTC schedule rule, eligibility, objective types, contribution meter, temporary asset definitions, contract constraints, personal tiers, community thresholds, event-currency rules, cosmetic rewards, news templates, cleanup and record format. Definitions are server-owned validated data. Supported objective handlers are allowlisted modules; definitions cannot supply arbitrary executable expressions.

An event instance has a stable ID including year, frozen definition version, start/end timestamps, reconciliation state, community snapshot version and finalized reward thresholds. States: scheduled → active → closing → finalized → archived. A disabled/emergency-paused state stops new contributions without deleting saved contributions. Definition changes during an active instance require an explicit migration or new version; do not silently change earned thresholds.

Start is inclusive, end exclusive. Server UTC determines eligibility, and the actual completed delivery step is metered. At a boundary, use only the portion of the step within the event's wall-time window, or split the step; never credit a full tick that straddles closure. Prototype the split deterministically with an injected clock. Date checks happen during settlement, not merely when the client opens the event panel.

## Operation Christmas Cheer

Run annually **1 December 00:00 UTC through 24 December 00:00 UTC exclusive**, covering 1–23 December. UTC is proposed; the required dates are confirmed. For 2026 this is `2026-12-01T00:00:00Z` to `2026-12-24T00:00:00Z`. Do not launch automatically merely because these dates are near.

An eligible player purchases a temporary interconnector to fictional Lapland at a designated boundary site and connects it to their actual grid. It creates an export sink with a bounded MW contract. Domestic demand is routed first; the event then uses residual reachable domestic generation and line capacity. Generation behind a disconnected bottleneck cannot contribute remotely. Exports incur normal generation, fuel and transmission consequences. Domestic demand growth can reduce event surplus later.

Initial event mode forbids imported and storage-origin energy in the event meter. To avoid ambiguous flow attribution, any step with imports or storage discharge anywhere in the country disables event exports; the UI explains the conservative restriction. Storage charging may still use the remaining power after eligible exports. This is deliberately simple and can later be replaced by source-attributed flow accounting after tests. Ordinary trade exports and event exports are distinct sinks competing for residual capacity; proposed priority is domestic, event, ordinary exports, storage charging.

Propose no cash export payment for the Lapland contract: contribution earns event currency and cosmetics while consuming real operating costs. If a later definition pays cash, its delivered MWh is billed once as that contract's export, never again as an ordinary export. A free introductory temporary connector can be considered for new players, but its resale value must be zero and its grant one-time per instance.

## Personal and shared objectives

Personal record: enrolled event ID/version, eligibility baseline, cumulative eligible exported MWh, earned/spent event currency, completed tiers, claim flags and last durable source revision. Proposed baseline is max(2 MW, available generator nameplate at first enrollment); tier targets are baseline × 1, 5 and 20 simulated hours of exported energy. Freeze that baseline across rebirths and reconnects. Because early enrollment may be strategically advantageous, prototype absolute floor/cap targets and compare new versus veteran completion time before approval.

Personal tiers grant participation cosmetics and a bounded token amount. Continuous event currency can use `floor(eligibleMWh / currencyEnergyUnit)` with persisted remainder; definition specifies a per-instance cap and shop prices. Currency cannot convert to treasury or legacy points, transfer to another player, or carry into next year by default. Unspent currency expires after a proposed seven-day post-event shop window, with advance UI notice. Permanent purchased cosmetics and event history survive.

Community totals use absolute eligible MWh, not personal baseline-normalized points. Targets are fixed before the event begins from a documented participation forecast; do not invent a launch target without population data. Milestones unlock cosmetic claim eligibility for enrolled players who meet a modest personal participation floor. Claims may remain available on later login from the finalized event record. No limited stock or race against other claimants in the initial design.

## Durable contribution protocol

Do not increment one global key per tick and do not count MessagingService messages. Proposed protocol:

1. Before accepting event participation, durably register the user in an event bucket. Bucket ID is `floor(userId / 128)` and slot is `userId % 128`, so each bucket has at most 128 members. Registration alone has zero contribution and is harmless if enrollment later fails. Keys use an event-instance prefix for bounded paginated discovery.
2. Simulation accumulates eligible delivery in the private country state. Normal atomic profile saves commit cumulative event MWh plus an outbox target revision. UI labels unsaved energy as pending. A crash can lose pending energy just like other unsaved progress; do not present it as durably accepted.
3. After commit, an ingestion worker reads that committed cumulative value and updates the bucket slot with `max(previous, committedCumulative)` using UpdateAsync. In the same bucket-key update, increase bucket total only by the positive slot difference. Replays and old servers cannot duplicate contributions. Only validated server state may supply the value.
4. A replaceable aggregator enumerates registered bucket keys in bounded pages, reads bucket totals and produces a versioned community snapshot. Concurrent monotonic increases make a pass a conservative delayed total, not an instantaneous global transaction. Publish only nondecreasing totals unless an audited correction explicitly revises results.
5. At closure stop new eligible delivery. During closing, workers revisit registered members' committed profiles to drain missed outboxes, including offline players, and reconcile bucket totals. The registry makes recovery discoverable after every server crash; a transient queue alone is insufficient.
6. Finalize only after reconciliation passes complete and pending saves/ingestion have drained under the closure policy. Proposed seven-day reconciliation allowance is a target, not proof of completeness. If services remain unavailable or reconciliation cannot be proven, retain closing state and delay final community awards with a visible explanation. Do not silently finalize an incomplete total.

This protocol costs enrollment writes, batched profile saves and per-active-bucket writes, plus reconciliation reads. Coalesce updates, bound concurrent work and reserve persistence budget ahead of public display work. Workers use leases for efficiency; bucket max semantics provide duplicate safety. Prototype at projected event participation before release. If scanning registered profiles cannot finish within budget, redesign the journal/index pipeline before scaling; do not claim this works at arbitrary Roblox population.

Snapshot IDs and durable milestone IDs make news deduplication independent of worker leadership. Community rewards rely on finalized or durable reached-threshold records, never a broadcast. A player claim validates tier/milestone eligibility and writes the claim flag plus reward in the same canonical profile update. Ambiguous success requires rereading; no second grant. Cosmetic inventory uses stable catalog IDs with unique ownership semantics.

Keep active/closing event meters in the canonical profile until reconciliation has acknowledged their final revision. Only then archive compact completed records. Cap simultaneously active/closing definitions (proposed four) and stop admitting new events if unresolved reconciliation would exceed that bound. Annual scheduling must not silently evict an unfinished prior instance.

## Closure, rebirth and failure cases

At end time disable export capacity immediately, cancel event-only orders and remove or retire temporary assets without breaking ordinary graph endpoints. No full-cost refund; refund rules are definition data. Event records remain with contribution, tiers and earned items. A rebirth retains personal contribution, baseline and claims but resets the connector. A server that starts after end time cannot reopen the event from an old definition cache.

Graceful shutdown saves pending contribution with the country; failed saves can lose only uncommitted progress, never count it twice. An event definition kill switch pauses further metering and does not erase rewards. Fraud corrections require an auditable versioned adjustment process and may break monotonic totals; automatic client accusations cannot trigger deductions.

## Acceptance and rollout

P10 establishes news; P11 prototypes the event framework and this instance in a test universe. Verify exact start/end boundaries, leap/calendar year generation, disconnected and congested exports, no domestic sacrifice under default priority, import/storage exclusions, duplicate/out-of-order ingestion, lost notifications, server crash after bucket write, offline outbox recovery, delayed finalization and idempotent claims. Do not ship until both a new and advanced test country can earn participation rewards without destabilizing domestic service.
