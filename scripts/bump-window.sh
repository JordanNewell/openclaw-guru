#!/usr/bin/env bash
# bump-window.sh — mechanical half of a re-verification. Moves the verified
# window across every spot that carries it, after the human/agent half
# (reading the release notes) is actually done.
#
# Usage:
#   ./scripts/bump-window.sh <version> --verified
#
# Without --verified it refuses and prints the review checklist. That flag is
# a claim, not a shortcut: it asserts you read the release notes for every
# version between the old window and <version>. freshness-watch trusts this
# marker — a bump without the review makes it lie.
#
# What it touches:
#   1. CHANGELOG.md            — scaffolds the new entry (window line + skeleton)
#   2. README badge            — verified-against vX → new
#   3. agents/ header line     — "review ran <date> and covers through stable vX"
#   4. plugins/ copy           — re-synced from agents/ (byte-identical)
#   5. plugin manifests        — patch bump in BOTH (marketplace-only-updates-on-rise)
#   6. assets/                 — regenerated via build.py when the toolchain allows
#
# What it does NOT touch (that's the review):
#   version-milestones entries, Known Gotchas, knowledge sections, CHANGELOG prose.

set -euo pipefail

VERSION="${1:-}"; shift || true
if [ -z "$VERSION" ]; then
  echo "usage: $0 <version> --verified" >&2
  exit 1
fi
VERSION="${VERSION#v}"
TODAY=$(date +%Y-%m-%d)

if [ "${1:-}" != "--verified" ]; then
  cat <<'EOF'
REFUSING: no --verified flag.

A window bump without the review makes freshness-watch lie. Do the review first:
  1. Read the release notes for every version after the current window
     (github.com/openclaw/openclaw/releases — each release page, not the tag list)
  2. Update the version-milestones section in agents/open-claw-guru.agent.md
  3. Re-check claims flagged OPERATOR-OBSERVED in VERIFICATION.md
  4. Update Known Gotchas if anything changed
Then: ./scripts/bump-window.sh <version> --verified
Or:   /reverify  (Claude Code — walks the whole flow with you)
EOF
  exit 1
fi

OLD_WIN=$(grep -m1 -oP 'stable \*\*\Kv[0-9]+\.[0-9]+\.[0-9]+' CHANGELOG.md || true)
[ -z "$OLD_WIN" ] && { echo "error: no 'stable **vX.Y.Z**' marker in CHANGELOG.md" >&2; exit 1; }
OLD_AGENTS=$(grep -m1 -oP 'covers through stable \Kv[0-9]+\.[0-9]+\.[0-9]+' agents/open-claw-guru.agent.md || true)

if [ "$VERSION" = "${OLD_WIN#v}" ]; then
  echo "window already at $OLD_WIN — nothing to do"
  exit 0
fi
NEW_WIN="v$VERSION"

# 1. CHANGELOG: scaffold the new entry above the previous one (its window line
#    becomes the freshness-watch marker — first match wins)
ENTRY="## vNEXT — $TODAY

**Verified against:** release notes reviewed through stable **$NEW_WIN**.
[TODO before merge: name the release pages actually read, PR counts if notable,
and every knowledge section that changed. Delete this bracket before merging.]

**What changed in the knowledge:**
- [TODO: operator-relevant changes from the release notes, in the file's honesty style]

"
awk -v entry="$ENTRY" '
  /^## v/ && !done { printf "%s", entry; done=1 }
  { print }
' CHANGELOG.md > CHANGELOG.md.tmp && mv CHANGELOG.md.tmp CHANGELOG.md

# 2. README badge
sed -i -E "s/verified%20against-openclaw%20v[0-9]+\.[0-9]+\.[0-9]+/verified%20against-openclaw%20$NEW_WIN/" README.md

# 3. agents/ header line (date + window)
sed -i -E "s/release-note review ran [0-9]{4}-[0-9]{2}-[0-9]{2} and covers through stable v[0-9]+\.[0-9]+\.[0-9]+/release-note review ran $TODAY and covers through stable $NEW_WIN/" agents/open-claw-guru.agent.md

# 4. re-sync the marketplace copy (copy-sync CI demands byte-identical)
cp agents/open-claw-guru.agent.md plugins/openclaw-guru/agents/open-claw-guru.agent.md

# 4b. re-sync the OpenClaw-native skill body (skill-body-sync CI demands identical bodies)
python3 scripts/sync-skill.py

# 5. patch-bump both manifests
python3 - <<'PY'
import json, re
pj = "plugins/openclaw-guru/.claude-plugin/plugin.json"
mj = ".claude-plugin/marketplace.json"
s = open(pj, encoding="utf-8").read()
old = json.load(open(pj, encoding="utf-8"))["version"]
a, b, c = (int(x) for x in old.split("."))
new = f"{a}.{b}.{c + 1}"
s = re.sub(r'("version":\s*")' + re.escape(old) + '"', r"\g<1>" + new + '"', s, count=1)
open(pj, "w", encoding="utf-8", newline="\n").write(s)
s = open(mj, encoding="utf-8").read()
s = re.sub(r'("name": "openclaw-guru",\s*"source": "\./plugins/openclaw-guru",\s*"description": "[^"]*",\s*"version": ")' + re.escape(old) + '"', r"\g<1>" + new + '"', s, count=1)
open(mj, "w", encoding="utf-8", newline="\n").write(s)
print(f"manifests: {old} -> {new}")
PY

# 6. regenerate assets when the toolchain allows (DejaVu paths are Linux-only;
#    version only appears in the social preview)
if python3 -c "import fontTools, cairosvg" 2>/dev/null && [ -d /usr/share/fonts/truetype/dejavu ]; then
  python3 assets/build.py "$NEW_WIN" assets
  echo "assets: regenerated for $NEW_WIN"
else
  echo "assets: SKIPPED (needs fonttools + cairosvg + DejaVu at /usr/share/fonts — regen on Linux or CI)"
fi

echo
echo "window bumped: ${OLD_WIN:-$OLD_AGENTS} -> $NEW_WIN  (mechanical half done)"
echo "STILL ON YOU (the review half):"
echo "  - version-milestones section in agents/open-claw-guru.agent.md"
echo "  - OPERATOR-OBSERVED claims in VERIFICATION.md"
echo "  - CHANGELOG entry prose (TODO brackets now in the file)"
echo "  - rename the vNEXT heading in CHANGELOG.md to the real plugin version"
