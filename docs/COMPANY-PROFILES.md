# Company profiles

Status: public offline profiles and permanent records are confirmed. Identity options, record limits and publication intervals are proposals D11/D13. [Data](DATA-AND-SECURITY.md) specifies durable ownership; [Multiplayer](MULTIPLAYER-AND-NEWS.md) owns leaderboard views.

## Public projection

One company belongs to one Roblox user ID. The public profile is a sanitized, independently readable projection of the latest committed private save, not permission to read the country ledger or full graph. Offline viewers read it by user ID. Return a timestamp, source revision and projection schema version so stale data is visible.

| Public field | Source / meaning |
| --- | --- |
| Company name, motto, colors, logo ID | Validated customization; safe defaults on filtering failure |
| Current population and money | Latest committed country totals, not lifetime highs |
| Financial summary | Current cash and recent aggregate revenue/expense; no raw transaction IDs |
| Lifetime generated MWh | Actual generator output across eras; excludes imports and storage discharge |
| Era count | Number of completed durable resets |
| Operational summary | Delivered energy, service ratio, renewable share and outage summary with period labels |
| Achievements and featured IDs | Server-earned catalog IDs, with bounded featured selection |
| Seasonal completion and event records | Event instance ID/year, tier, contribution and earned cosmetics |
| Milestones | First expansion, major project, era dates and selected significant achievements |

Proposed limits: company name 32 characters, motto 120, three featured achievements, preapproved logo catalog and a curated color palette. Enforce UTF-8/codepoint-aware length plus byte limits. Logos are developer-curated Roblox asset IDs, not arbitrary URLs or uploads. A later user-upload workflow would require a separate moderation design.

Custom text must use Roblox filtering before display to others. The [official text filtering guide](https://create.roblox.com/docs/ui/text-filtering) assigns responsibility for displayed uncontrolled text to the experience. Persist raw owner input only privately when needed; never return it as fallback. Use the appropriate broadcast-safe filtered output for public names/mottos, retain author ID and fail closed to a generated safe name if filtering is unavailable or cannot be refreshed. Offline filtering/refresh behavior must be tested before enabling free text; the initial safe fallback is catalog company names and mottos (D13).

## Projection lifecycle

After a successful canonical save, queue a profile projection using that saved revision. Coalesce changes; proposed write interval at most once per 120 seconds plus important committed milestones, budget permitting. Profile-key UpdateAsync accepts only a newer source revision. Epoch/era revision must be globally increasing across resets, so an old server cannot restore old money or population into the public profile.

Profile publication failure never rolls back the private save or grants compensation. Retry from the latest durable snapshot. On viewing, cache a bounded number of projections and apply per-request rate limits. Do not load a player's private country just to display a public page. Offline absence means “profile not available yet,” not a new account with zero assets.

## Achievements and history

Definitions specify ID/version, predicate, scope (era/lifetime/event), reward and visibility. Server evaluates from trusted domain events and ledger totals. Unlock IDs and reward claim flags commit together. Public display is eventual; a failed projection cannot make an already-owned achievement claimable again.

Keep recent detailed history bounded (proposed latest 100 milestones). Permanent achievements and seasonal records are compact IDs and summaries, not retained news text or every tick. Annual records can live in immutable archive pages referenced by the private profile's archive index, with a bounded recent public summary and paginated historical reads. A reference is published only after the archive write succeeds; retries use stable page IDs. Preserve lifetime aggregates when older detailed narrative is compacted. Long-term archive storage still consumes quota and needs retention/capacity review; “permanent” must not mean an infinitely growing single key.

Era history preserves date, final population, domestic delivery, points awarded and selected milestones; era infrastructure snapshots are not permanent profile records. User/account deletion and moderation may remove records, so permanence is within normal account/data lifecycle requirements.

## Acceptance and rollout

P9 introduces offline profiles, achievements and rankings. An owner can leave and another server can display a safe saved projection. Rebirth preserves achievements and event records while resetting current values. Stale writes cannot replace newer projections, raw text is never broadcast, and fake client achievement IDs cannot unlock anything. Archive pagination and failure recovery must be proven before enabling unbounded years of event records.
