# Session Hooks

Lifecycle hooks that fire automatically on Claude Code session events. These are the core persistence mechanism — they ensure session state survives compaction and session boundaries.

## Installation

### Automatic (Recommended)

```
/memory setup
```

The setup wizard symlinks hooks and updates `~/.claude/settings.json`.

### Manual

1. Symlink hooks:

```bash
ln -sf /path/to/memory/hooks/session-start-vault.sh ~/.claude/hooks/
ln -sf /path/to/memory/hooks/pre-compact-vault.sh ~/.claude/hooks/
ln -sf /path/to/memory/hooks/session-stop-vault.sh ~/.claude/hooks/
ln -sf /path/to/memory/hooks/agent-start.sh ~/.claude/hooks/
ln -sf /path/to/memory/hooks/agent-stop.sh ~/.claude/hooks/
ln -sf /path/to/memory/hooks/compact-notification.sh ~/.claude/hooks/
ln -sf /path/to/memory/hooks/force-mcp-connectors.sh ~/.claude/hooks/
```

2. Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/session-start-vault.sh"
          },
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/force-mcp-connectors.sh"
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/pre-compact-vault.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/session-stop-vault.sh",
            "async": true
          }
        ]
      }
    ],
    "SubagentStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/agent-start.sh",
            "async": true
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/agent-stop.sh",
            "async": true
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/compact-notification.sh"
          }
        ]
      }
    ]
  }
}
```

## Hook Reference

### session-start-vault.sh

**Event**: SessionStart (sync)
**What it does**: Injects vault awareness into every session. Outputs vault path, note count, and journal count for the current month.
**Dependencies**: Obsidian CLI (`obsidian` command). Falls back gracefully if CLI unavailable or app not running.

### pre-compact-vault.sh

**Event**: PreCompact (sync)
**What it does**: Before compaction wipes the context window, appends the current SESSION-STATE.md to the vault's daily journal (`logs/journals/YYYY-MM-DD.md`). Creates the journal with proper frontmatter if it doesn't exist.
**Dependencies**: Obsidian CLI preferred. Falls back to direct filesystem write using vault path from Obsidian config.

### session-stop-vault.sh

**Event**: Stop (async)
**What it does**: When the session ends, flushes SESSION-STATE.md to both the vault daily journal and `~/.claude/compaction-state/latest.md`. This ensures the next session can reconstruct what happened.
**Dependencies**: Same as pre-compact — Obsidian CLI with filesystem fallback.

### agent-start.sh

**Event**: SubagentStart (async)
**What it does**: Increments a counter at `/tmp/claude-agents-count`. Used for monitoring concurrent subagent activity.

### agent-stop.sh

**Event**: SubagentStop (async)
**What it does**: Decrements the counter at `/tmp/claude-agents-count`. Floor is 0.

### compact-notification.sh

**Event**: Notification (matcher: "compact", sync)
**What it does**: After compaction, prints vault stats (note count, vault path) and a preview of SESSION-STATE.md (first 2000 chars). Helps verify what was preserved.

### force-mcp-connectors.sh

**Event**: SessionStart (utility)
**What it does**: Force-enables the MCP connectors feature flag in `~/.claude.json`. Retries with delays (2s, 5s, 10s) to handle server sync timing.
