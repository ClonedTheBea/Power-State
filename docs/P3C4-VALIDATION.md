# P3c.4 — Stage A funding and released-profile verification

**Current result: Stage A successfully completed after explicit reauthorisation.** Rowanbridge is confirmed at step242, Bank1,250.03 Credits, profile33/country256/epoch9 with no lease. Seven updates and three uncached reads; no construction. See [resumed execution](#resumed-stage-a--explicit-owner-reauthorisation). The failed initial attempt below is preserved as historical evidence, not relabelled as passing.

## Initial attempt — stopped before real access

18 November 2026. Owner approved Stage A funding only, conditional on preparation gates. **No real DataStore access or simulation advancement occurred. Stage A was not executed. Stage B remains unauthorized.**

## Failed preparation gate

The approval required verifying that all execution flags were initially disabled and stopping without accessing the real profile if a required gate failed. Inspection found `src/server/Adapters/DataStoreAdapter.luau` still declared `LIVE_ACCESS_APPROVED=true` from the earlier P3a proof. The newer schema2 economy, bounded economy, schema3 migration and schema3 construction flags were false. The legacy adapter is explicitly invoked, exact-account/Test guarded and not selected by normal startup; this finding does not establish that it had been called. Nevertheless, its open flag fails the stated initial condition.

Stopped before the approved fresh uncached read. Closed the legacy flag as a local safety correction. The former validation scripts actually required the historical true value; those assertions now require false while preserving their exact-account/universe/Studio checks. An initial post-closure build/static command reported that old assertion; it was corrected to enforce the new closed state, not removed. Both builds and all checks then passed. This remediation does not silently waive the initial failed gate or resume execution.

## Prepared audit safeguards

Before discovering the legacy flag, review of the prepared construction adapter identified missing evidence capture needed for the approved procedure. Narrow local additions now:

- Reject any phase other than `Fund` before service access, independently of the closed execution flag. Stage B cannot use this approval.
- Retain initial/latest complete read snapshots and platform version, timestamps, associated user IDs and metadata in bounded in-memory capture. Nothing private is printed to ordinary logs.
- Record request budgets, latency, returned transition kind, profile revision and step alongside the existing bounded request records.
- Reject updates until a manual protected-preimage retention acknowledgement supplies the exact approved checksum. The operator must actually export and hash the fresh capture before acknowledging it; the acknowledgement is not itself proof of a disk export.

The real flag was never opened. These additions have static/Script Analysis coverage; their real platform capture path was **not executed**. The funding runner, financial arithmetic, lease contract and deterministic allowlist were unchanged. A future resumed execution must split preparation/capture from running the prepared capability; the convenience `ConstructionProofExecution.run` cannot bypass the new retention requirement.

## Checks actually performed

- All recorded P3c.1/P3c.2 protected evidence file hashes verified. Existing recovery packages unchanged; no new real preimage package was created.
- Five unchanged P3c.3 prepared source hashes verified against historical evidence. Adapter and static-check changes are explicitly recorded here rather than represented as unchanged hashes.
- Fresh stopped-Test fake funding proof: **62 assertions**,11:46:17 UTC. Forecast unchanged:124 intervals,step242,Bank125003 minor; synthetic purchase25003 minor. The fake purchase is test-only and does not imply a real quote/purchase.
- Retained P3a178, P3b93, P3b.3 44, P3b.4 33, P3b.5 50 and P2b.1 scheduler49 assertions passed. Full-day billing:1440 intervals/12 exact restores,353303 minor net,92283-byte full-ring profile.
- At11:48:57 UTC,10,000 accepted seed routes/pads, four rotations and safe fallback passed alongside2,916,780 world assertions. Fresh temporary fake module copies detached afterward.
- Both default and Test Rojo builds passed. Final static total **898** across ten retained check scripts. Git whitespace passed; line-ending notices are informational.
- Full-project Studio Script Analysis: **0 errors / 0 warnings**, Current Script Only disabled, after source closure. Studio remained stopped throughout this task.

## Exact changed files

- `src/server/Adapters/DataStoreAdapter.luau`: close legacy flag.
- `src/server/Adapters/Schema3ConstructionAdapter.luau`: Fund-only restriction, protected-preimage acknowledgement and bounded audit capture.
- `scripts/Validate.ps1`, `scripts/ValidateP2a.py`, `scripts/ValidateP2b.py`, `scripts/ValidateP3a.py`: require legacy gate false, retain destination guards.
- `scripts/ValidateP3c3.py`: assert closed legacy/prior gates, Stage B rejection, preimage barrier and audit fields.
- `PLANS.md`, `docs/DECISIONS.md`, this report and `docs/P3C4-EVIDENCE.json`.

## Execution evidence and next boundary

Actual real calls: **0 reads / 0 updates**. No acquired lease, simulation intervals, earned revenue, quote, construction debit, funding checkpoint or released-profile verification. Current Bank, platform version, profile revisions and checksum are therefore not freshly established. Historical P3c.2 remains schema3/profile26/country132/epoch8,step118,Bank1007.66 Credits; these are not current observations.

Request owner review of the failed initial gate and its closure before resuming Stage A. On renewed continuation authority, repeat the preparation checks, verify stopped authenticated Test identity, perform the single exact uncached preflight and require canonical equality to `d846d13a398113d1442ff1e0a3feeccbf2397fdf286cad88583f635524c75a65`. Securely export fresh profile/platform metadata before acknowledging retention or acquiring a lease. All previously approved Stage A limits still apply; any mismatch stops. No recovery writes or automatic adaptation.

Do not request Stage B execution on the basis of this task: there is no confirmed funded profile. Stage B requires its own approval after successful funding/release verification. No Production, settings, artwork, publication, deployment, commit or push occurred.

## Resumed Stage A — explicit owner reauthorisation

18 November2026. Owner explicitly accepted the legacy gate closure, strengthened checks, Fund-only restriction, bounded audit capture and protected-preimage barrier, and reauthorised **Stage A only**. The original failed gate above and [initial evidence](P3C4-EVIDENCE.json) remain unchanged. This section records the subsequent execution, not a reinterpretation of that earlier attempt.

### Preparation and exact identity

All prepared-source hashes in the initial P3c.4 evidence matched. All recorded files in the protected P3c.1/P3c.2 packages matched their manifests, before and after execution. Both Rojo builds,898 static assertions and full-project Script Analysis0 errors/0 warnings passed again. Fresh fake funding62 assertions and retained persistence/economy/scheduler suites passed; the10,000-seed route/pad sweep and2,916,780 world assertions finished at11:58:50 UTC. No threshold or gameplay rule changed.

Execution used stopped Studio, `RunService:IsStudio()` and `not IsRunning()`, personal creator149564436 and authenticated `StudioService:GetUserId()==149564436`, universe10776833313. The adapter fixes standard storePowerStateProfilesP3aTest, default/global scope and keyu:149564436. No other destination was accessed. The complete reviewed canonical record fixes Rowanbridge's identity and seed.

The manual preparation cloned the reviewed server modules into a temporary ServerStorage tree, detached every BaseScript and verified ten normalized source SHA-256 values inside Studio before service access. Only that isolated adapter copy's Fund-only gate was opened. All normal repository/Rojo flags remained false throughout. No bootstrap, Play session, preview service or Heartbeat simulation was started. Relative dependencies used the same isolated capability registration as ProfileService; this was not a generic real-storage bypass.

### Fresh preflight and protected export

At **12:00:07 UTC**, the single uncached preflight matched the entire reviewed schema3/ledger3 canonical profile, profile26/country132/epoch8,step118/cursor118,Bank100766 minor, generatorOn, no lease and empty construction. The existing opening grant remained exactly once. Platform version matched `08DF44E1F51DCFA5.000000001A.08DF45575FFF3C24.01`, associated UserIds were exactly[149564436], and custom metadata was empty. No unexpected field or ownership state was accepted.

The actual fresh profile, platform metadata and destination identity were exported through Studio's **Save to File**, as Folder/StringValues only, into:

`C:/Users/matt9/.codex/private/PowerState/P3c4-20261118/fresh-preimage.rbxmx`

The XML was parsed locally; its exact canonical Preimage value was saved as7796-byte `Preimage.json` and independently hashed before any mutation:

`d846d13a398113d1442ff1e0a3feeccbf2397fdf286cad88583f635524c75a65`

`Platform.json`, `Destination.json` and `PREWRITE-MANIFEST.json` retain the other verified fields and file hashes. Only after this disk verification was the adapter's exact checksum acknowledgement supplied. Export occurred before acquisition; the several-minute export/review interval did not advance simulation or consume a lease. The acquisition callback still required the exact reviewed head, so a concurrent change would have been rejected. No second preflight was made.

### Actual funding and preserved state

Funding started at12:06:09 UTC and completed at **12:08:20 UTC**, taking **131.219 seconds**, within the240-second phase limit. Exactly124 one-second waits/intervals advanced step118→242. No elapsed-time catch-up. Each computed country matched the deterministic allowlist, and the first affordability crossing was124796 minor at step241 → **125003 minor at step242**. Values came from the existing solver and120/80/10 billing, not assignment of a forecast.

| Financial category | Stage A change | Confirmed cumulative total |
| --- | ---: | ---: |
| Electricity sales | +789.13 Credits | 814.09 Credits |
| Variable generation costs | 526.09 Credits | 542.73 Credits |
| Fixed operating costs | 20.67 Credits | 21.33 Credits |
| Net earnings | +242.37 Credits | 250.03 Credits |
| Bank | 1,007.66 → **1,250.03 Credits** | **1,250.03 Credits** |
| Construction spending | 0 | 0 |

Final earned/spent minor units81409/56406. Opening grant100000 minor and grant identity unchanged; operating buffer25000 minor unchanged. No bonus sales, boost, extra grant, capital debit or purchase receipt. Construction is still empty and quoteState is `NotRequested`.

Exact final remainders (denominator60000): base sales36000, bonus0, variable cost4000, fixed cost20000. Activation step113 and original activation identity preserved; lastSettledStep242. Financial delivered/generated meters407048 kW-minutes, an increase394568;128 total online economic steps,124 added here. The four historical online steps were not billed again.

Physical requested/delivered cumulative history:12.712133333333297 /12.140133333333301 MWh. Stage A added6.576133333333333 MWh requested and delivered (394568/60000). All118 original reliability entries are unchanged; final history has242 entries/index242. Existing historical shortfall is preserved rather than erased. Country recipe, settlement, infrastructure, coordinates, version fields and other nonfinancial/nonsimulation country fields compare equal locally. Generator remainsOn. No offline advancement or district demand was introduced.

### Checkpoints, calls and lease outcome

One Acquire advanced profile26→27, epoch8→9. Five whole-country Checkpoints at steps148/178/208/238/242 advanced profiles28–32. Each checkpoint confirmed exact financial and electricity state. The ordinary checkpoints maintained the existing fenced lease policy; no separate Renew operation was necessary. The180-second lease and30-second safety margin were unchanged. One uncached funded-profile read confirmed the entire profile32 result before release. Release advanced profile33, followed by an uncached complete released-profile comparison. Final country revision256, epoch9, lease absent; coordinator profiles0/inFlight0, peak inFlight1.

| Application request | Step / returned profile revision | Latency ms |
| --- | --- | ---: |
| Preflight GetAsync, uncached | 118 /26 | 199.006 |
| Acquire UpdateAsync | 118 /27 | 830.035 |
| Checkpoint UpdateAsync | 148 /28 | 727.543 |
| Checkpoint UpdateAsync | 178 /29 | 725.716 |
| Checkpoint UpdateAsync | 208 /30 | 606.479 |
| Checkpoint UpdateAsync | 238 /31 | 723.431 |
| Affordability Checkpoint UpdateAsync | 242 /32 | 421.980 |
| Funded confirmation GetAsync, uncached | 242 /32 | 155.295 |
| Release UpdateAsync | 242 /33 | 533.574 |
| Released confirmation GetAsync, uncached | 242 /33 | 161.599 |

Exactly **7 updates +3 reads**, all successful. No application retry, reconciliation read, extra renewal, ambiguous outcome, deadline breach, competing operation or recovery write. Minimum sampled remaining GetAsync/SetIncrementAsync budgets2484/2489. Counts and latency describe application calls, not Roblox internal callback/network attempts. This short real-service sample is not an outage or hosted-session guarantee.

### Final protected evidence and closure

`funded-result.rbxmx` was exported locally after release. Its Profile value was independently hashed, then retained as `FundedProfile.json` with `FundedPlatform.json`, `FundedRecords.json` and `FundedSummary.json`. Full canonical final profile: **16232 bytes**, SHA-256:

`802d28f694d61242376bd9746f2724a2b85591ab9563199e50d9efed1ef2c548`

Final platform version: `08DF44E1F51DCFA5.0000000021.08DF456CA2E2E5D0.01`.

CreatedTime1794944138060; UpdatedTime1795003700146. UserIds[149564436], empty custom metadata preserved. The final protected `MANIFEST.json` records all package file hashes. Prior recovery packages and the fresh pre-write manifest files were rechecked unchanged. [Sanitized real funding evidence](P3C4-FUNDING-EVIDENCE.json) contains only selected results/metrics, not private session or operation tokens/full profiles.

The temporary adapter source gate was closed on return; after export verification, the prepared capability reference was cleared and its module tree and export objects detached. Cleanup verified at12:12:36 UTC. Temporary execution files were removed from `.build`; review-only `.lua.txt` copies remain in the protected evidence package. Studio command bar was cleared to a non-executable completion comment. Studio is stopped; final Script Analysis remains0/0. Normal source gates were never enabled and their hashes remain unchanged. No runtime code change was needed during this reauthorised execution; only report/roadmap/decision/evidence files are updated.

**Stage A: PASS and stopped. Stage B: not executed or authorised.** There are no unresolved Stage A outcomes. Physical touch/gamepad, actual hosted competing-session and outage acceptance remain outside this proof. No Production, permissions/settings, new asset/store/key, publication, deployment, commit or push occurred.

Separate Stage B approval must review this actual funded/released profile and require a fresh exact preflight. The intended purchase would debit1000 Credits, leaving250.03 if no other authorized simulation occurs, but that is a future conditional result—not a purchase performed here. Do not rerun Fund against the changed head, restore the old preimage over these earnings, or perform recovery writes. Any future recovery or mismatch requires reviewed forward reconciliation. Stop pending explicit Stage B approval.
