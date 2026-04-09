#!/bin/bash
# Increment agent counter when a subagent starts
COUNTER_FILE="/tmp/claude-agents-count"
CURRENT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
echo $((CURRENT + 1)) > "$COUNTER_FILE"
