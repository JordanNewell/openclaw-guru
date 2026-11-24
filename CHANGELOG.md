# open-claw-guru — Knowledge Changelog

What release of OpenClaw this agent's knowledge was last verified against, and what changed.
The agent file itself points here — **do not trust version-dependent claims from the agent
without checking the newest entry below.**

Format per entry: verified window, sources reviewed, what changed in the knowledge.

---

## v1.0.4 — 2026-11-23

**Verified against:** release notes reviewed through stable **v2026.11.7** (2026-11-23).
Full changelog markdown read for 11.6 (386 PRs) and 11.7 (533 PRs) via
CHANGELOG/2026.11.6.md + CHANGELOG/2026.11.7.md upstream (GH release bodies were
credits/verification metadata only for 11.6).

**What changed in the knowledge:**
- Freshness window bumped v2026.11.5 → **v2026.11.7**; new Version-Milestones entries
  for 2026.11.6 and 2026.11.7 (both patch releases, no fundamentals changed — this
  window was an operator-behavior pass: log-path move, slash-commands-at-start,
  Discord/Slack per-person turn separation, realtime 30s silence hangup, browser
  skill sign-in-prompt change, scheduled-job permission semantics).
- **2026.11.6 flagged for updaters**: dead update leases clear in repair; updater
  compatibility records (recovery bridges) make the "installed updater must already
  contain this fix" pattern explicit — very old fleets may need a manual
  package-manager update as the bridge.
- **Route-collapse fix noted** (#193179): Doctor/update migrations no longer merge
  intentionally separate API vs Claude/Gemini CLI routes; operators already collapsed
  by a prior migration must restore a backup or re-add the fallback.
- **Gotcha #19 (Doctor can HANG) re-verified**: #178359/#190870-75/#187900 checked
  against BOTH new changelogs — still unreleased as of v2026.11.7; hedge stands.
- VERIFICATION.md operator-observed register re-checked — no entry superseded
  (cooldown ladder, mixed-version playbook, Windows patterns all unchanged by
  these releases; 11.6/11.7 strengthen the update-reliability story).

## v1.0.2 — 2026-11-18

**Verified against:** release notes reviewed through stable **v2026.11.5** (2026-11-17).
Release pages read for 11.3 (34 PRs, full GH body), 11.4 (125 PRs, docs.openclaw.ai formatted
page — GH body was credits-only), and 11.5 (351 PRs, full GH body + docs page). Docs nav
confirmed the beta-era promises landed: PostgreSQL operator guide and Knowledge scribes
sections are live on docs.openclaw.ai.

**What changed in the knowledge:**
- Freshness window bumped v2026.11.2 → **v2026.11.5**; the "2026.11.5-beta in flight"
  milestone replaced by stable 2026.11.3 / 11.4 / 11.5 entries.
- **2026.11.5 BREAKING contract flagged** (#175837): third-party harnesses must register
  session-keyed active runs in the host `runAttempt` callback; plugin RPC must replace
  `chatAbortControllers`/`chatQueuedTurns` with authorized Gateway dispatch; `expiresAtMs`
  → `startDeadlineAtMs`. Any operator running custom harness/plugin code needs this before
  upgrading.
- **Update rollback semantic added**: failed Doctor/Gateway startup now rolls back an
  activated update (11.5) — the "bad update wedges the agent" runbook changes to let the
  rollback happen first.
- **Doctor hang status refined**: 11.5 bounds doctor *startup* waits (#187936/#191125),
  but the Config-repairs capture-op hang (#178359, PR #200820 pending upstream) and the
  async-stack repair fixes (#190870-75, issue #187900) are verified NOT in 11.4/11.5
  changelogs — the "don't wait indefinitely" hedge stays fully in force.
- SQLite playbook parenthetical updated: Postgres data plane now stable-era (docs
  operator guide live), framed as new opt-in surface, SQLite still the default.
- 11.3 credential-isolation fix cluster (plugin results scoped to connection creds,
  inline env cred redaction, no secret inheritance by child processes) noted for
  multi-provider operators.

**Verification of the parked watch item:** `d894035c` (#190875) checked against both
CHANGELOG/2026.11.4.md and CHANGELOG/2026.11.5.md upstream — no match; #190870-75/#187900
remain unreleased as of v2026.11.5.

**Packaging note (added 2026-11-23):** the v1.0.2 plugin manifests (`plugin.json`,
`marketplace.json`) were still pinned at `1.0.0` when this entry shipped — marketplace
installs never received the v2026.11.5 knowledge until the manifests were bumped to
`1.0.2` on 2026-11-23, and the `plugins/` agent copy had also lagged the canonical
`agents/` file by one verification window. Both failure modes are now caught by the
`content-consistency` CI workflow (copy-sync + version-bump guards).

---

## v1.0.1 — 2026-11-12

**Verified against:** release notes reviewed through stable **v2026.11.2** (2026-11-08).
Single-source pass: the official release page (docs.openclaw.ai/releases/2026.11.2) read
in full; 11.2 was a patch release (113 PRs, no headline features), so no docs-section
re-sweep was needed. Beta 2026.11.5 remains in flight, noted as news.

**What changed in the knowledge:**
- Freshness window bumped v2026.11.1 → **v2026.11.2**; the agent file's pre-flagged
  "superseded, not yet reviewed" note on 11.1 claims is resolved.
- Version-milestones: added the **2026.11.2** entry — automations reminder-loss fix
  (text mentioning heartbeat polls/wakes), update-repair deadlock fix, POSIX triage-hang
  fixes, paired-node skill-repair behavior, three behavior changes (Chrome-MCP redirect
  policy, mise/XDG child PATH, plugin API floor ≥2026.11.2), and the post-manual-upgrade
  `doctor --fix` migration note.
- VERIFICATION.md operator-observed register: re-checked — **no entry superseded**; gap
  #4 marked RESOLVED (two doctor hang classes fixed upstream, gotcha #19 hedge retained).

---

## v1.0.0-draft — 2026-11-08

**Verified against:** release notes reviewed through stable **v2026.11.1** (2026-11-05) plus
beta 2026.11.5 (noted as news, not fact). Docs cross-checked live at docs.openclaw.ai on
2026-11-08. Numeric defaults sampled from docs + production observation — treated as
approximations (see the agent's Freshness Discipline section).

**Sources reviewed:** openclaw GitHub releases; docs pages on gateway architecture,
wire protocol/handshake, agent loop, security/trust model, automation, skills
(/tools/skills, /tools/creating-skills, /tools/skill-workshop, /tools/skills-config),
ClawHub (/clawhub, /clawhub/skill-format), workspace/memory/system-prompt/multi-agent
concepts, agents config (/gateway/config-agents/*), channels index + Discord/Slack/
Telegram/WhatsApp/iMessage/Signal/WebChat pages, plugins, browser (/tools/browser),
nodes, standing orders, heartbeat.

**Quality gates passed before this draft:**
- Three-researcher doc sweep (skills / workspace-memory / channels-plugins-nodes),
  every fact cluster cited to a docs URL; unknowns flagged UNCERTAIN rather than invented
- Hostile three-persona fact-audit (maintainer / skeptical operator / scrub pedant),
  live-docs verification of high-risk claims — 3 blockers + 14 warns, all fixed:
  - connect handshake corrected to req-typed RPC with challenge/deadline semantics
  - tailnet-bind control-port claim re-hedged (release-dependent; current docs = same-port loopback listener)
  - model-cascade "bug" reframed as unconfirmed one-off anomaly with cheap mitigation
    (was self-contradicting the documented failover chain)
  - attribution updated (steipete created, OpenClaw Foundation stewards)
  - systemd/Windows deployment templates hardened (User=, exit-78, per-agent config
    paths, USERPROFILE caveat, wmic dropped)
  - deployment fingerprints scrubbed (fleet size, benchmark numbers, provider error
    strings, exact log lines → generalized or hedged)
- OPSEC identifier sweep: zero hits (agent names, hostnames, IPs, ports, paths, session refs)

**Known gaps (flagged, not asserted):** LLM prompt-cache interaction with skill snapshots
(not documented upstream); iMessage full key list (index page only); HEARTBEAT.md exact
retirement version (doctor migration is the documented trigger); numeric defaults marked
approximate throughout. **v2026.11.2 was tagged 2026-11-08** — after this entry's verified
window closed; review its release notes before the first repo release. Cooldown-backoff
ladder flagged as conflicting with docs scale (/concepts/model-failover) — docs treated as
authoritative in-file.

**Out of scope for v1:** OpenClaw-skill (SKILL.md) repackaging of the same knowledge;
Fleet-gurus companion agents (hermes-guru et al.).
