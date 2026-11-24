#!/usr/bin/env python3
"""sync-skill.py — rebuild openclaw-guru-skill/SKILL.md from the canonical agent file.

The skill is the OpenClaw-native packaging of the same knowledge: its frontmatter is
skill-specific, its body is the agent file's body verbatim. Run this after any edit to
agents/open-claw-guru.agent.md (bump-window.sh does it automatically). The
content-consistency CI fails if the two bodies drift.
"""
import re
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
AGENT = ROOT / "agents" / "open-claw-guru.agent.md"
SKILL = ROOT / "openclaw-guru-skill" / "SKILL.md"

SKILL_DESCRIPTION = (
    "Operational-depth OpenClaw platform expertise for answering questions about OpenClaw "
    "(openclaw.ai) itself: gateway troubleshooting, fleet upgrades, channel configuration, "
    "skills mechanics, cron, SQLite migration, and the doctor protocol. Load when the user "
    "asks about OpenClaw configuration, deployment, upgrades, or troubleshooting; do not "
    "load for general chat."
)

def body_of(path):
    src = path.read_text(encoding="utf-8")
    m = re.match(r"^---\n.*?\n---\n", src, re.DOTALL)
    if not m:
        raise SystemExit(f"error: no frontmatter block in {path}")
    return src[m.end():].lstrip("\n")

skill = (
    "---\n"
    "name: openclaw-guru\n"
    f"description: {SKILL_DESCRIPTION}\n"
    "---\n\n"
    + body_of(AGENT)
)
SKILL.write_text(skill, encoding="utf-8", newline="\n")
print(f"synced: {SKILL.relative_to(ROOT)} ({len(skill)} chars, body = agents/ canonical)")
