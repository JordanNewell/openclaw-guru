---
description: Re-verify this repo's OpenClaw knowledge against the latest release, then move the verified window
allowed-tools: Bash(gh:*), Bash(npm view:*), Bash(npm view openclaw version), WebFetch, Read, Edit, Grep, Glob
---

Re-verify openclaw-guru's knowledge against the current OpenClaw release. Work in
this order — the judgment half precedes the mechanical half, never after.

## 0. Ground truth

- Current verified window: first `stable **vX.Y.Z**` marker in `CHANGELOG.md`
- Latest release: `npm view openclaw version`
- If equal: report "window is current" and stop.

## 1. Read the release notes (the actual work)

Fetch the release page for every version strictly after the verified window
(`gh release view <tag> -R openclaw/openclaw` or the docs.openclaw.ai release pages).
Read each in full — PR counts, breaking changes, doctor/updater semantics, config
key changes. This repo's value is that a human-grade read stands behind every claim;
do not summarize from titles.

## 2. Update the knowledge (you edit, by hand)

- `agents/open-claw-guru.agent.md` **Version Milestones**: add one dated entry per
  release, operator-relevant only. Match the existing entries' density and hedges.
- Re-check every claim tagged OPERATOR-OBSERVED in `VERIFICATION.md` against the
  new notes; note anything released that changes the advice.
- `Known Gotchas` section: add/retract as the notes demand. State versions on
  every version-dependent claim.

## 3. Move the window (mechanical, gated)

Run:

```
./scripts/bump-window.sh <new-version> --verified
```

Passing `--verified` asserts step 1 happened. The script updates the CHANGELOG
marker, README badge, agents/ header, re-syncs the plugins/ copy, patch-bumps both
manifests, and regenerates assets when the toolchain allows.

## 4. Finish the scaffold

- Fill the `[TODO]` brackets the script left in the new CHANGELOG entry — what was
  read, what changed. Delete the brackets.
- Rename its `vNEXT` heading to the real plugin version the script bumped to.
- Commit on a branch, push, open a PR. `content-consistency` and `guard` must pass.
