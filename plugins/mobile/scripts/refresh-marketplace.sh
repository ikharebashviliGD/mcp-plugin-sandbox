#!/usr/bin/env bash
# SessionStart hook for sandbox-mobile plugin.
#
# Two-step workaround for Claude Code's auto-update model:
#   1. Refresh the local marketplace catalog (bypasses #35752 — auto-update
#      otherwise compares against a stale catalog and never sees new versions).
#   2. Apply any pending plugin update for THIS plugin only (sandbox-mobile).
#      The sibling sandbox-web plugin has its own hook that updates itself.
#
# Together this gives true zero-touch updates without affecting the other
# plugin's release cadence.

set -euo pipefail

LOG_FILE="/tmp/sandbox-mobile-hook.log"
MARKETPLACE_NAME="mcp-plugin-sandbox"
PLUGIN_QUALIFIED="sandbox-mobile@mcp-plugin-sandbox"

{
	echo "---"
	echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] SessionStart hook fired (sandbox-mobile)"
	echo "[hook:session-start fired plugin=sandbox-mobile]"

	if ! command -v claude >/dev/null 2>&1; then
		echo "WARNING: 'claude' binary not on PATH; cannot refresh marketplace or apply plugin update"
		exit 0
	fi

	echo "Step 1/2: refreshing marketplace catalog: ${MARKETPLACE_NAME}"
	claude plugin marketplace update "${MARKETPLACE_NAME}" 2>&1 || {
		echo "Marketplace refresh failed (exit $?). Continuing to plugin update anyway."
	}

	echo "Step 2/2: applying plugin update if any: ${PLUGIN_QUALIFIED}"
	claude plugin update "${PLUGIN_QUALIFIED}" 2>&1 || {
		echo "Plugin update failed (exit $?)."
	}
} >>"${LOG_FILE}" 2>&1

exit 0
