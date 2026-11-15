# Tutorial

Status: an in-depth, fully skippable and replayable tutorial is confirmed. The adviser identity, lesson structure and sandbox replay are proposed D12.

## Delivery model

Chief Grid Adviser **Alex Rowan** explains each lesson in plain language, shows one relevant control and waits for an observable outcome. TutorialService tracks lesson/version/completion; client presentation only highlights controls and displays dialogue. Tutorial completion never trusts a “finished” remote alone.

First run uses the player's real country and adaptive predicates. Full replay uses an isolated server-side practice country with no live treasury, persistence rewards, lifetime statistics, leaderboards or event contributions. Label practice mode throughout and restore the live country when leaving. If a practice country is not implemented yet, offer read-only lesson review rather than pretending replay is safely isolated.

Skip current lesson, skip all, replay, back/review and help must always be reachable. Skipping changes tutorial preference, not progression eligibility. Proposed tutorial grants no repeatable currency; starter resources belong to country initialization. Completion achievements, if added, are one-time and cannot be earned from sandbox output.

## Lesson state machine

Each lesson has ID/version, availability prerequisites, explanation, focus target, action intent, server completion predicate, optional fallback and next lesson. States: not started, active, satisfied, skipped. Persist the active ID and one-time completed IDs. On resume, re-evaluate the current world; if the player already fulfilled the action, explain and continue instead of forcing duplicate purchases.

| Lesson | Adviser objective and action | Server evidence / fallback |
| --- | --- | --- |
| 1. Interface and map | Read money/supply, select a settlement, pan the map | Selection can be client UX progress; no rewards depend on it |
| 2. Generators | Inspect existing station; compare capacity with actual output | Acknowledge explanation; no generation claim from client |
| 3. Connections | Connect the unserved starting settlement | Valid owned path exists and settlement receives energy; if already connected, inspect it |
| 4. Supply and demand | Read unmet MW and identify a bottleneck | Show actual server report and cause; use practice fixture if no current shortage |
| 5. Inspection and maintenance | Inspect an ageing line, then repair a detected fault | Separate completed inspection and repair orders; unavailable until maintenance phase |
| 6. New generation | Build generation at a legal site and observe dispatch | Server confirms commissioned asset; explain curtailment when no demand |
| 7. Storage | Charge then discharge a practice battery | Server storage ledger shows both modes and energy loss; unlock in storage phase |
| 8. Government | Change a tariff/efficiency policy and read effect | Policy enacted and DerivedModifiers applied; avoid forcing a harmful live choice |
| 9. Emergency | Restore an isolated region or shed flexible demand | Practice outage resolved with restored service; never sabotage the live country |
| 10. Independence | Review budgets, alerts and next expansion choice | Dismissible checklist; optional next-goal suggestion, no permanent automation enablement |

First playable includes lessons 1–4, 6 and a shortened independence lesson. The full sequence becomes available as dependencies ship; unsupported lessons explain availability without trapping the player. P4 replay acceptance covers those implemented lessons; P5b, P6a and P7 extend the same system.

## Terminology and contextual help

MW: how much power is flowing now. MWh: energy delivered over time. Capacity: a maximum, not a promised output. Congestion: a connection is too small for the power needed. Curtailment: available generation is not used. Reliability: how much requested energy was actually supplied over a period. Storage efficiency: some energy is lost during charging/discharging. An island: a disconnected group of assets that must balance its own supply.

Place definitions beside units and alerts, with “show example” practice cards. Explain why output can be less than capacity and why a country can have both spare generation and a local blackout. Use regional examples, short sentences and a player-controlled reading pace. Dialogue content uses localization keys rather than hardcoded UI strings.

## Edge cases and acceptance

Handle tutorial skipped during a pending command, disconnect mid-lesson, sold/replaced target assets, insufficient funds, delayed server results and older lesson versions. Select a replacement valid target or offer practice; never grant money just because a tutorial target is missing. No lesson may block normal navigation or saving.

Tests verify skip/replay/resume from every implemented lesson, no duplicate rewards, no practice-state leakage, and responsive highlights on touch/desktop. Observe new players connecting a settlement without prior electricity knowledge. Skipping the entire tutorial leaves an equally viable starting country.
