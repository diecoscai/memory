#!/bin/bash
# Inject vault awareness into every CC session (platform-agnostic via Obsidian CLI)

# Check if CLI is available
if ! command -v obsidian &>/dev/null; then
  echo "## Obsidian Vault Available"
  echo "Path: unknown | CLI: not installed"
  exit 0
fi

# Try CLI (requires Obsidian app running)
VAULT_PATH=$(obsidian vault info=path 2>/dev/null)
if [ -z "$VAULT_PATH" ]; then
  echo "## Obsidian Vault Available"
  echo "Path: unknown | CLI: obsidian (app not running) | Start Obsidian for full vault access"
  exit 0
fi

VAULT_NAME=$(obsidian vault info=name 2>/dev/null)
TOTAL=$(obsidian files ext=md total 2>/dev/null || echo "?")
MONTH=$(date +%Y-%m)
JOURNALS=$(obsidian files folder="logs/journals" ext=md 2>/dev/null | grep "$MONTH" | wc -l | tr -d ' ')

cat <<EOF
## Obsidian Vault Available
Path: $VAULT_PATH | CLI: obsidian (app running) | Fallback: Read/Grep on $VAULT_PATH/
Taxonomy: $VAULT_PATH/knowledge/TAXONOMY.md (10 types, 8 domains, 48 tags)
Stats: ~${TOTAL} notes | ${JOURNALS} journals this month
EOF

# ── Auto-seed SESSION-STATE.md if missing ────────────────────────────────────
# session-stop-vault.sh exits early when SESSION-STATE.md doesn't exist.
# This ensures every session has a landing zone for the WAL, preventing vault gaps.
SESSION_STATE="${PWD}/SESSION-STATE.md"
if [ ! -f "$SESSION_STATE" ]; then
  cat > "$SESSION_STATE" <<TEMPLATE
# SESSION-STATE.md — Active Working Memory (WAL)

## Current Task


## Key Context


## Pending Actions


## Recent Decisions


## Blockers

TEMPLATE
fi
