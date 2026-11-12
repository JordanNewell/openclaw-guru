# open-claw-guru — Knowledge Changelog

What release of OpenClaw this agent's knowledge was last verified against, and what changed.
The agent file itself points here — **do not trust version-dependent claims from the agent
without checking the newest entry below.**

Format per entry: verified window, sources reviewed, what changed in the knowledge.

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
