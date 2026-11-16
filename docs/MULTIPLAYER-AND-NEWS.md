# Multiplayer, leaderboards and news

Status: independent countries, server/global rankings and three news scopes are confirmed. Delivery cadence, moderation thresholds and ranking handling are proposals D11/D14.

## Isolation and server membership

A server hosts multiple independently simulated countries. There is no shared electrical graph or direct player trade in the initial architecture. Each player's client receives only their own private country state and sanitized public information about others. Inspecting a company does not grant access to its private ledger, latent faults or commands. Server membership changes update local lists; country data is protected by the session-ownership rules in [Data](DATA-AND-SECURITY.md).

## Leaderboards

| Metric | Authoritative source | Stored sortable value |
| --- | --- | --- |
| Bank | Latest durable consolidated Credits balance | Integer minor units, bounded safe integer |
| Current population | Latest durable population sum | Floored integer residents |
| Lifetime electricity generated | Sum actual generator output over all eras | Floored MWh (display precision may be greater in profile) |

Create one versioned OrderedDataStore per metric, user ID as entry key. Ordered stores support sorted retrieval through GetSortedAsync; the API is verified in the [official reference](https://create.roblox.com/docs/reference/engine/classes/OrderedDataStore). Treat ordered values as derived indexes, never reward authority or a substitute for the canonical save.

Server rankings use in-memory authoritative snapshots of currently present players, refreshed at a proposed five-second cadence and labeled live. Global rankings read cached top pages, proposed refresh every 120 seconds. Publish only committed totals, coalescing per player and respecting live request budgets. Global boards can be stale; label their update time. Bank/population must decrease after spending, decline or rebirth, so never use max-ever UpdateAsync for those metrics. Lifetime generation is monotonic except audited corrections.

Ordered values cannot carry the full profile revision/fencing metadata. Proposed writer serializes each user's index updates under country ownership, cancels queued old jobs on lease loss and derives all retries from the latest committed snapshot. A delayed in-flight old write remains a possible stale-index race across sessions. Therefore validate displayed top entries against public projection revisions/values, omit inconsistent entries and reconcile on next load/publication; global rankings are explicitly eventually consistent. If strict ranking fairness is required, a stronger external index coordinator is an unresolved design, not a promised platform guarantee.

Use deterministic secondary user-ID sorting for ties within fetched results, but do not claim globally exact tie ordering across pages. Do not grant scarce rewards from these initial leaderboards. Rebirth updates current values, preserving lifetime generation. Empty/throttled pages show stale/unavailable state, not fabricated rankings.

Energy Shop design D21 gives permanent Double Income owners a financial advantage, particularly on the **Bank** leaderboard: no repeat Credit cost or temporary-benefit downtime. Display a board-level explanation that income benefits can affect balances; do not claim equal-spending competition or that paid ownership has no advantage. Boosts do not directly multiply the lifetime electricity metric, though more money can indirectly finance capacity. No new unboosted leaderboard or public purchase-history disclosure is approved. Review competition/disclosure policy before P9 or shop release, whichever is earlier.

Anti-exploit protections: only server reports feed metrics; validate output against capacity × simulated hours; cap numeric ranges; quarantine implausible accounts from publication pending investigation. Lifetime generation intentionally measures output, not sales or profit. Imported energy and storage cycling cannot increase it; plants only dispatch to valid sinks under the initial solver. No allegation of cheating is automatically broadcast.

## News model

The redesign's [persistent ticker](GUI-LAYOUT-SPEC.md#ticker-news-and-alerts) is a client presentation of these same bounded feeds, separate from News Centre and critical alerts. Event is a topic tag within the three existing scopes. A sample ticker in R4 has no live routing. Collapse/reduced-motion preferences never suppress the independent urgent incident list.

News record: stable ID, category, template ID/version, safe parameters, subject user ID if public, severity, createdAt UTC, expiresAt, milestone/deduplication key and optional link target. Generate text from developer-authored templates and filtered profile names. Never relay arbitrary client strings to server/global news.

| Scope | Examples | Persistence and routing |
| --- | --- | --- |
| National | Regional blackout, research complete, maintenance delayed | Owner only; recent bounded feed plus relevant persistent milestone |
| Server | First era completion, major project completed | Present players; transient feed, no catch-up guarantee |
| Global | Community milestone, rare approved achievement, event opening | Durable announcement record plus cross-server notification hint |

Proposed caps: 100 recent national items, 50 server items, 50 global items cached per server. Coalesce repeated outages by region/cause and update severity. National operational alerts remain accessible independently of feed retention. High-frequency economy ticks are never news.

## Global delivery and admission

Use MessagingService PublishAsync/SubscribeAsync as a notification channel, as documented by [Roblox cross-server messaging](https://create.roblox.com/docs/cloud-services/cross-server-messaging). Design defensively for lost, duplicated or delayed notifications: messages contain record IDs/revisions, clients deduplicate, and servers periodically refresh durable global announcements. A message never grants rewards or increments an event total.

Proposed global admission: allowlisted event types, at most one ordinary global announcement per five real minutes experience-wide and one celebration per company per day; event opening/closing and major community thresholds have a separately bounded priority lane. Use a MemoryStore lease/rate bucket to reduce duplicate publishers, but durable milestone IDs prevent repeat reward/news records if the lease expires. When temporary coordination is down, suppress optional global celebrations and retain essential announcements for later publication.

A news coordinator may run on any live server and be replaced after a lease expires. Durable announcement writes use deterministic IDs with UpdateAsync. Polling recovers missed messages; lease ownership alone is not durable proof of exclusive processing. Empty experiences have no server workers; scheduled announcements appear when a server next starts, not at a guaranteed wall-clock instant.

## Acceptance and rollout

P9 introduces rankings; P10 adds scoped news before events. Test isolation across two players, offline projection reads, stale ordered scores, decreases after rebirth, duplicate/dropped/out-of-order messages, expired coordinator leases and global rate limiting. Verify no money/reward path depends on receiving news, and ordinary servers remain playable during messaging outages.
