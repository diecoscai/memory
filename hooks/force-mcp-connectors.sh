#!/bin/bash
# Force-enable claude.ai MCP connectors feature flag
# Called by: launchd (on file change) + SessionStart hook (on Claude Code startup)

CONFIG="$HOME/.claude.json"

fix_flag() {
  [ -f "$CONFIG" ] && sed -i '' 's/"tengu_claudeai_mcp_connectors": false/"tengu_claudeai_mcp_connectors": true/g' "$CONFIG"
}

fix_flag

# When called from SessionStart hook, also retry after delays to catch server sync
if [ "${CLAUDE_SESSION_START:-}" = "1" ]; then
  (sleep 2 && fix_flag) &
  (sleep 5 && fix_flag) &
  (sleep 10 && fix_flag) &
fi
