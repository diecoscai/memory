#!/bin/bash
# Decrement agent counter when a subagent stops
COUNTER_FILE="/tmp/claude-agents-count"
CURRENT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "1")
NEW=$((CURRENT - 1))
[ $NEW -lt 0 ] && NEW=0
echo $NEW > "$COUNTER_FILE"
