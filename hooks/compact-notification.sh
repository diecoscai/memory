#!/bin/bash
# Print vault stats + SESSION-STATE preview on compaction
VAULT_PATH=$(obsidian vault info=path 2>/dev/null)
if [ -n "$VAULT_PATH" ]; then
  COUNT=$(find "$VAULT_PATH" -name "*.md" -not -path "*/.obsidian/*" 2>/dev/null | wc -l | tr -d ' ')
  echo "## Vault: ${COUNT} notes at ${VAULT_PATH}/"
fi
cat "${PWD}/SESSION-STATE.md" 2>/dev/null | head -c 2000
