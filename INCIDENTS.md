# INCIDENTS.md

Anonymized production incidents from fleet operations, written as war stories for operators.
Hedges from the source knowledge are preserved — where a mechanism was never confirmed, it stays unconfirmed.
Version-dependent details reflect a verified window that has certainly moved; check your installed release and the CHANGELOG before treating any specific behavior as current.

## 1. The "Hung" Gateway That Wasn't OpenClaw's Fault

**Signal:** Several agents on a shared production host stopped responding mid-morning. Gateways were nominally up — systemd showed them active — but turns stalled and channels went quiet. The obvious move was to restart the units.

**Diagnosis:** We almost did the obvious thing. Checking `systemctl status` first showed units in D-state, and pressure stall information (PSI) showed sustained memory pressure on the host. This was not a gateway bug: the units were running under `MemoryHigh` caps, and under load the kernel was pinning them in reclaim wedges, occasionally escalating to memcg OOM kills. A "hung" gateway under load on a memory-capped systemd unit is often a reclaim wedge, and restarting a wedged unit just moves the problem — the replacement process re-enters the same wedge under the same cap.

**Fix:** Drop `MemoryHigh` entirely. Our working baseline per gateway unit: heap around 768M via `NODE_OPTIONS`, `MemoryMax=2G`, and nothing between them. In one deployment we measured, uncapped startup went from roughly 19 minutes of thrashing to seconds once tuned. Your numbers will differ — measure your own.

**Generalized lesson:**
- On capped systemd units, "hung under load" is a memory-management symptom until proven otherwise. Check `systemctl status` and PSI before restarting anything.
- `MemoryHigh` is the cap that bites. Cap the ceiling (`MemoryMax`) and leave the soft cap unset.
- Track RSS per unit and alert on growth trends, not just thresholds — heap creep within minutes of restart is a different failure you want to catch early.

## 2. The Gateway That Hung the Diagnostic Tool

**Signal:** A gateway on the fleet appeared hung. We reached for the platform's health-check/repair tool (`doctor`), which is the documented first response to an unhealthy agent. The doctor hung too.

**Diagnosis:** Two conditions were stacked: plugin version skew and legacy sessions state — old sessions JSON files left in place alongside the newer state store. The combination was enough to wedge both the gateway and the repair tool itself. The practical takeaway: don't wait indefinitely on a hung doctor. It has no timeout worth trusting here, and the failure pattern is recognizable.

**Fix:** Manual move-aside. We located the stale legacy session state files, archived them out of the state directory (moved, not deleted), and restarted the gateway. It came back clean. The archived files stayed on disk until we were confident nothing else referenced them.

**Cautionary second beat:** The reflexive alternative — running the repair tool's fix mode blindly — has destroyed production configs. Fix mode performs real migrations, not formatting: it can convert legacy heartbeat files into automation jobs (bumping the shared-state schema so older gateways can no longer run them), strip retired config keys, and more. If you use it at all: snapshot configs, state dirs, and cron definitions first and verify the snapshot restores; predict which migrations it will run on this specific agent before letting it; run it per-agent, staggered; verify the config diff against your prediction afterward. Diagnose manually first, always.

**Generalized lesson:**
- A hung diagnostic is a symptom, not a failure of your method — recognize the plugin-skew-plus-legacy-state pattern and go manual.
- Archive stale state files; never delete them mid-incident.
- There is no fleet-wide doctor. It is per-agent, and mixed results across agents are themselves a finding.

## 3. The 429 Storm After One Heartbeat

**Signal:** A single routine heartbeat check — the kind that runs dozens of times a day without incident — produced 10+ consecutive rate-limit (429) errors within about two minutes. Worse, the errors appeared to escalate toward heavier models rather than falling back to lighter ones.

**Diagnosis:** This is the uncomfortable one. The documented failover chain treats configured fallbacks as explicit operator intent: requested model first, then your fallback list. That documented behavior and what we observed cannot both be mechanically true. The mechanism was never confirmed, and we won't invent one here. Trust the documentation first; if you see this pattern, re-verify against your installed release before theorizing.

**Fix:** The mitigation is cheap, harmless, and we recommend doing it regardless of mechanism: strip each agent's model list to exactly two models — primary plus fallback — so escalation to heavier models is structurally impossible no matter what the failover logic does. Also remove stale aliases from the fleet-wide model list; dead entries keep dead escalation paths alive. Note that with fallbacks configured, each one gets a fresh timeout budget, so total run time can exceed your per-attempt budget when fallbacks fire — set explicit budgets rather than trusting defaults (the default per-attempt budget is long enough to surprise everyone eventually).

**Generalized lesson:**
- Two-model lists make bad failover behavior structurally impossible. Do it even when you can't explain the anomaly.
- When observation contradicts documented behavior, say so plainly and mitigate cheaply — don't retrofit a mechanism you can't prove.
- Monitor rate-limit errors in gateway logs as a standing practice; the storm started with a workload that had run cleanly hundreds of times before.

## 4. The Upgrade That Broke Only Some Agents

**Signal:** After a fleet upgrade, channel connections and provider calls started failing — but only on some agents. Others on the same release ran fine. Cron jobs on the affected agents sat in error state; at least one showed an auth loop.

**Diagnosis:** The split was the clue. Agents that failed were the ones carrying stale legacy JSON state files — sessions and related state that predated the migration to the SQLite-backed state store. The new code, expecting migrated state, was poisoned at startup by the leftover files. Mixed-version state across a fleet is the top upgrade risk in this era of the platform; the per-agent differences in state, not version, explain why the outage was partial.

**Fix:** For each affected agent: move the legacy JSON state files aside (archive, don't delete) and restart the gateway. This has fixed repeated outages of this shape. Check the state schema version per agent afterward and confirm it matches what the release expects.

**Runbook changes we adopted:** snapshot configs, state directories, and cron definitions before any bump, and test that the snapshot actually restores; bump one canary agent first (not the most critical one) and verify gateway start, channel connect, cron firing, and a clean doctor; roll out in waves, verifying agent-by-agent rather than fleet-at-once. Know your rollback before you need it — and note schema migrations usually are not backward-compatible: restoring old code against new state can corrupt it. When unsure, fix forward.

**Generalized lesson:**
- Partial outages after an upgrade usually mean state divergence, not a bad release. Compare affected vs. unaffected agents.
- Legacy state files are landmines: archive them at upgrade time, not after they detonate.
- Staggered rollout isn't ceremony — it converts a fleet-wide outage into a single-agent lesson.

## 5. The Cron Jobs That Silently Never Ran

**Signal:** Scheduled jobs on the fleet weren't producing output. No error state, no failed-run entries — the jobs simply didn't fire. Inspection showed their stored next-run times had gone stale relative to wall-clock time, and on restarts the scheduler dropped the missed slots instead of running them.

**Diagnosis:** Pre-fix in that release window, the scheduler treated a missed slot with a stale stored next-run time as unrecoverable and silently skipped it. Combined with restart-heavy operations (which a fleet doing staggered restarts has constantly), jobs could silently starve. A later release addressed this: missed slots with stale stored next-run times are caught up at startup instead of dropped, and interrupted long-running jobs no longer block scheduler startup. Verify your installed release — this is exactly the kind of behavior that changed.

**Fix:** Version-side, upgrade past the missed-slot behavior. Fleet-side, the durable mitigation is scheduling discipline: stagger cron so same-model agents never fire in the same minute (a minute or more of separation per agent), separate agents by model tier so a shared key's rate limit isn't a single point of contention, and consider per-tier API keys to eliminate shared limits entirely. When multiple agents share a key and all fire morning briefs at 08:00, you get a self-inflicted rate-limit storm at the exact moment everything else is also waking up.

**Generalized lesson:**
- "The cron didn't fire" and "the cron fired and said nothing" are different conditions — the latter is a deliberate no-reply design, the former is this incident.
- Silent drops are worse than errors. Reconcile stored next-run times against wall clock after any restart-heavy period.
- Shared API keys turn scheduling into a collective-action problem: stagger, tier, or split keys.
