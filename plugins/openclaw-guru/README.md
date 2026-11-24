# OpenClaw Guru

A Claude Code subagent with operational-depth knowledge of [OpenClaw](https://openclaw.ai)
— gateway troubleshooting, fleet upgrades, channel configuration, skills mechanics, cron,
and the doctor protocol. The knowledge comes from running a multi-agent OpenClaw fleet in
production through major version migrations, state-schema changes, and outages: battle
scars, not docs summaries.

**What this plugin ships:** one agent definition file. No MCP servers, no hooks, no
commands, no executable code. It runs nothing, collects nothing, and sends nothing
anywhere — the entire payload is readable markdown.

Every version claim carries a shelf life. This plugin's knowledge is re-verified against
specific OpenClaw releases and tracked in the repository's CHANGELOG; the verified window
is noted in the agent file itself. Current window: **v2026.11.5** (2026-11-18 review).

Not affiliated with or endorsed by the OpenClaw project or the OpenClaw Foundation.

**Install:** `/plugin marketplace add JordanNewell/openclaw-guru` then
`/plugin install openclaw-guru@openclaw-guru`.

**Support and issues:** [github.com/JordanNewell/openclaw-guru/issues](https://github.com/JordanNewell/openclaw-guru/issues)

**License:** MIT.
