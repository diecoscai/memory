#!/bin/bash
# Flush session state to vault + compaction-state (platform-agnostic)
SESSION_STATE="${PWD}/SESSION-STATE.md"

# Existing behavior: save to compaction-state
if [ -f "$SESSION_STATE" ]; then
  mkdir -p ~/.claude/compaction-state
  echo "[Session ended: $(date -Iseconds)]" >> ~/.claude/compaction-state/latest.md
  cat "$SESSION_STATE" >> ~/.claude/compaction-state/latest.md 2>/dev/null
fi

[ -f "$SESSION_STATE" ] || exit 0

# Try Obsidian CLI first (app must be running)
if command -v obsidian &>/dev/null; then
  CONTENT=$(cat "$SESSION_STATE" 2>/dev/null)
  HEADER="## CC Session Ended ($(date +%H:%M))"
  obsidian daily:append content="$HEADER\n$CONTENT" 2>/dev/null && exit 0
fi

# Fallback: write directly to vault path from Obsidian config
VAULT_PATH=$(python3 -c "
import json, os
p = os.path.expanduser('~/Library/Application Support/obsidian/obsidian.json')
if not os.path.exists(p):
  p = os.path.expanduser('~/.config/obsidian/obsidian.json')
if os.path.exists(p):
  d = json.load(open(p))
  for v in d.get('vaults',{}).values():
    if v.get('open'):
      print(v['path']); break
" 2>/dev/null)

[ -z "$VAULT_PATH" ] && exit 0

TODAY=$(date +%Y-%m-%d)
JOURNAL="$VAULT_PATH/logs/journals/$TODAY.md"

if [ ! -f "$JOURNAL" ]; then
  cat > "$JOURNAL" <<FRONTMATTER
---
type: journal
status: active
agent-use: high
use-when: "daily log, $TODAY"
summary: "Auto-generated from CC session"
tags: [workflow, claude-code]
domain: operations
created: '$TODAY'
source: claude-code hook
---

# $TODAY

FRONTMATTER
fi
echo "" >> "$JOURNAL"
echo "## CC Session Ended ($(date +%H:%M))" >> "$JOURNAL"
cat "$SESSION_STATE" >> "$JOURNAL"
