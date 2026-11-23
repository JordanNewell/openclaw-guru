# Contributing

This repo is **living infrastructure**, not a blog post. The agent's knowledge decays as
OpenClaw ships — community scar tissue is the primary antidote. The best possible PR is
a gotcha you personally bled for.

## Submitting a gotcha (the valuable kind of contribution)

Open an issue using the **Gotcha report** template. A good gotcha has:

1. **OpenClaw version** — exact, from `npm view openclaw version` or your install
2. **Platform** — Linux (systemd) / Windows (schtasks) / Docker / macOS
3. **Signal** — what you saw (symptom, error, log line)
4. **Diagnosis** — what it actually was, once you knew
5. **Fix** — what worked, reproducibly
6. **Evidence** — doc URL, release-note link, or minimal repro. "Trust me" gotchas get
   the OPERATOR-OBSERVED label; evidence-backed gotchas can upgrade a claim to DOC-VERIFIED.

## Verifying against a release

Gotcha evidence means running the real thing, not quoting docs. Use the sandbox script —
it downloads any published version and runs it against a throwaway state dir, so your
installed OpenClaw is untouched:

```bash
./scripts/verify-against.sh 2026.11.5 -- doctor        # the usual
./scripts/verify-against.sh 2026.11.2 -- skills check
```

Put the version you tested against in your gotcha report. Requires Node (24.x
recommended). If you need a full gateway environment instead of CLI checks, upstream
ships a Dockerfile (`openclaw/openclaw`) — heavier, but it exists.

The rules below are enforced by the `content-consistency` CI workflow on every push;
if a check fails, its error message states the exact fix.

## PR rules

- **Version bumps are mandatory for plugin installs**: Claude Code only updates a
  marketplace-installed plugin when its version string rises. Any change to
  `plugins/openclaw-guru/**` must bump `version` in BOTH
  `plugins/openclaw-guru/.claude-plugin/plugin.json` AND the matching entry in
  `.claude-plugin/marketplace.json`.
- Gotchas land in the agent file's **Known Gotchas** section (numbered) + a CHANGELOG entry
- **Match the file's honesty standard**: observed-once claims say "observed, verify your
  release"; never upgrade a hedge to a mechanism claim without docs evidence
- No rephrasing docs at length — if it's fully documented upstream, link it, don't copy it
- No fleet-identifying content (names, hostnames, IPs, providers) — anonymize like the
  existing file does
- Version-dependent claims must state the version they were true on

## What won't be merged

- Genero-guide content ("follow best practices") — this file is for scar tissue and
  mechanics, not aspiration
- Claims that contradict docs.openclaw.ai without an explicit "observed, release-dependent"
  hedge
- Anything that makes `openclaw doctor --fix` sound safe to run blind

## Maintenance posture

Verified-window tracking lives in [CHANGELOG.md](CHANGELOG.md); the freshness-watch CI
opens an issue when the verified window falls behind the latest OpenClaw release. If this
repo goes unmaintained, it will be archived with a banner rather than left to silently
mislead — check the repo's archived status before trusting version claims.
