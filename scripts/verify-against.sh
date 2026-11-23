#!/usr/bin/env bash
# verify-against.sh — run any published OpenClaw version in a throwaway sandbox.
#
# Usage:
#   ./scripts/verify-against.sh <version> [-- <openclaw subcommand and args>]
#
# Examples:
#   ./scripts/verify-against.sh 2026.11.5 -- doctor
#   ./scripts/verify-against.sh 2026.11.2 -- skills check
#   ./scripts/verify-against.sh 2026.11.5 -- --version
#
# State, config, and workspace dirs are redirected to a temp folder, so your real
# OpenClaw install is never touched. The version is fetched on demand via npx.
# If a gotcha reproduces here, report it with this version in the Gotcha report
# template — that's what upgrades a claim to evidence-backed.

set -euo pipefail

usage() {
  grep '^#' "$0" | sed 's/^# \{0,1\}//' | tail -n +2
  exit 1
}

VERSION="${1:-}"
[ -z "$VERSION" ] && usage
VERSION="${VERSION#v}" # accept v2026.11.5 or 2026.11.5

shift
if [ "${1:-}" = "--" ]; then shift; fi
if [ $# -eq 0 ]; then
  set -- doctor # default: the command most gotcha reports need
fi

if ! command -v node >/dev/null 2>&1; then
  echo "error: node not found — install Node.js first (24.x recommended; OpenClaw's engine gate moved to >=24 in 2026.9.5, softened to a recommendation in later releases — verify against your target version)." >&2
  exit 1
fi
NODE_MAJOR=$(node -p 'process.versions.node.split(".")[0]')
if [ "$NODE_MAJOR" -lt 24 ]; then
  echo "warning: node $(node -v) — OpenClaw's 2026.9.5+ releases targeted Node >=24. If this sandbox misbehaves, upgrade before blaming the version." >&2
fi

SANDBOX=$(mktemp -d)
trap 'rm -rf "$SANDBOX"' EXIT
export OPENCLAW_STATE_DIR="$SANDBOX/state"
export OPENCLAW_CONFIG_DIR="$SANDBOX/state"
export OPENCLAW_CONFIG_PATH="$SANDBOX/state/openclaw.json"
export OPENCLAW_WORKSPACE_DIR="$SANDBOX/workspace"
mkdir -p "$OPENCLAW_STATE_DIR" "$OPENCLAW_WORKSPACE_DIR"

echo "sandbox: $SANDBOX (removed on exit)"
echo "openclaw: $VERSION — running: openclaw $*"
exec npx -y "openclaw@$VERSION" "$@"
