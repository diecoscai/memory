# Memory

Your AI agents forget everything between sessions. Memory fixes that.

3-tier architecture (HOT/WARM/COLD), Obsidian vault sync, session hooks, and weekly consolidation. Every session contributes to a permanent knowledge graph. Nothing is forgotten. Everything decays gracefully.

## Install

**Claude Code (Recommended)**

```
/plugin marketplace add maxtechera/memory
/plugin install memory@memory
```

**Manual (Claude Code)**

```bash
git clone https://github.com/maxtechera/memory.git ~/.claude/skills/memory
```

**ClawHub / OpenClaw**

```bash
clawhub install memory
```

**Gemini CLI**

```bash
gemini extensions install maxtechera/memory
```

**Codex CLI**

```bash
git clone https://github.com/maxtechera/memory.git ~/.agents/skills/memory
```

---

## Setup

### Level 0: Zero Config (hooks only)

Install the skill. Session hooks fire automatically — vault awareness injected on session start, session state flushed to Obsidian on compaction and session end.

```
/memory setup
```

The setup wizard detects your Obsidian vault, installs hooks, and validates the CLI.

### Level 1: Connect Obsidian Vault

If auto-detection fails, set the vault path manually:

```bash
# In your .env or shell profile
export OBSIDIAN_VAULT_PATH=/path/to/your/vault
```

**Requirements**: Obsidian CLI v1.12.7+ installed, Obsidian app running for CLI commands.

### Level 2: Enable OpenClaw Sync (Mode 2)

If you run OpenClaw on Railway, connect it for cross-platform journal sync:

```bash
export OPENCLAW_CONFIG_PATH=/path/to/openclaw-config
```

This enables `/memory sync openclaw` to pull OpenClaw journals into your vault.

### Level 3: Full REM Sleep

Weekly consolidation runs as a cron job (default: Sunday 3am). Configure:

```bash
export REM_SLEEP_SCHEDULE="0 3 * * 0"
```

Or trigger manually: `/memory rem-sleep`

---

## Commands

| Command | Description |
|---------|-------------|
| `/memory sync` | Sync current session to memory (Mode 1) |
| `/memory sync openclaw` | Pull OpenClaw journals into Obsidian (Mode 2) |
| `/memory sync projects` | Sync Claude Code project memory to Obsidian (Mode 3) |
| `/memory rem-sleep` | Weekly consolidation: journals→topics, prune, TTL audit (Mode 4) |
| `/memory status` | Memory health: tier sizes, TTL alerts, last sync times |
| `/memory setup` | Configure vault path, detect platforms, install hooks |
| `/memory audit` | TTL audit + boundary check + health alerts |

---

## How It Works

### 3 Steps

1. **Detect** — Find what changed (new session state, stale journals, TTL expirations)
2. **Classify & Route** — Each insight goes to the right tier: fact → topics, pattern → vault, rule → AGENTS.md
3. **Write with Proof** — Structured sync report shows exactly what was written, skipped, or flagged

### The 3 Tiers

```
HOT   ≤2400tok, always loaded
  MEMORY.md         = router (pointers to topic files)
  SESSION-STATE.md  = WAL (current task, decisions, pending)

WARM  on-demand, domain-scoped
  memory/topics/*.md  facts with TTL decay
  memory/YYYY-MM-DD.md  daily journals

COLD  permanent, search-only
  Obsidian vault    knowledge/ logs/ projects/ identity/
```

### Cross-Platform Architecture

```
┌────────────────────────────────────────────┐
│            OBSIDIAN VAULT                   │
│        (Single Source of Truth)             │
│  knowledge/ | logs/ | projects/ | identity/ │
└──────────────────┬─────────────────────────┘
                   │ writes via Obsidian CLI
      ┌────────────┼────────────┐
      │            │            │
┌─────┴─────┐ ┌───┴──┐  ┌─────┴──────┐
│ Claude    │ │ Open │  │  OpenClaw   │
│ Code      │ │ Code │  │ (Railway)   │
│ + hooks   │ │      │  │ git → local │
└───────────┘ └──────┘  └────────────┘
```

---

## Session Hooks

Hooks fire automatically on Claude Code lifecycle events. No manual invocation needed.

| Hook | When | What It Does |
|------|------|-------------|
| `session-start-vault.sh` | Session starts | Injects vault stats: path, note count, journals this month |
| `pre-compact-vault.sh` | Before compaction | Appends SESSION-STATE to vault daily journal |
| `session-stop-vault.sh` | Session ends | Flushes state to vault + `~/.claude/compaction-state/` |
| `agent-start.sh` | Subagent spawned | Increments agent counter |
| `agent-stop.sh` | Subagent finished | Decrements agent counter |
| `compact-notification.sh` | After compaction | Prints vault stats + session state preview |
| `force-mcp-connectors.sh` | Session starts | Force-enables MCP connectors flag |

### Manual Hook Installation

If not using `/memory setup`:

```bash
# Symlink hooks to Claude Code hooks directory
ln -sf ~/dev/memory/hooks/session-start-vault.sh ~/.claude/hooks/
ln -sf ~/dev/memory/hooks/pre-compact-vault.sh ~/.claude/hooks/
ln -sf ~/dev/memory/hooks/session-stop-vault.sh ~/.claude/hooks/
ln -sf ~/dev/memory/hooks/agent-start.sh ~/.claude/hooks/
ln -sf ~/dev/memory/hooks/agent-stop.sh ~/.claude/hooks/
```

Then update `~/.claude/settings.json` to register the hooks. See `hooks/README.md` for the full configuration.

---

## 4 Sync Modes

| Mode | Command | What It Syncs | Direction |
|------|---------|---------------|-----------|
| 1 | `/memory sync` | Current session insights | Session → WARM → COLD |
| 2 | `/memory sync openclaw` | OpenClaw journals | OpenClaw → Obsidian |
| 3 | `/memory sync projects` | CC project memory files | `~/.claude/projects/` → Obsidian |
| 4 | `/memory rem-sleep` | Everything + consolidation | All tiers + prune + TTL audit |

---

## Memory Boundary Rules

The most important rule: **MEMORY.md contains facts. AGENTS.md contains rules. Never mix them.**

| File | Contains | Never Contains |
|------|----------|----------------|
| `MEMORY.md` | Facts, project index, pointers | Rules, instructions |
| `AGENTS.md` | Behavioral rules, policies | Facts, configs |
| `SESSION-STATE.md` | Live context, WAL entries | Long-term facts |
| `memory/topics/*.md` | Domain facts with TTL | Rules |

**Boundary test**: `grep -c "NEVER\|ALWAYS\|must\|rule" MEMORY.md` must return 0.

---

## TTL Decay

Every memory entry has a shelf life:

| Class | Suffix | TTL | Example |
|-------|--------|-----|---------|
| permanent | (none) | forever | Core architecture decisions |
| operational | `[date:6m]` | 6 months | API versions, tool configs |
| project | `[date:3m]` | 3 months | Project-specific facts |
| session | `[date:1m]` | 30 days | Research notes, citations |

REM Sleep (Mode 4) audits TTLs weekly and flags expired entries.

---

## Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `OBSIDIAN_VAULT_PATH` | Absolute path to Obsidian vault | Auto-detected |
| `OBSIDIAN_CLI_PATH` | Path to obsidian CLI binary | `/usr/local/bin/obsidian` |
| `OPENCLAW_CONFIG_PATH` | Path to openclaw-config repo | None |
| `MEMORY_ROUTER_MAX_LINES` | Max lines in MEMORY.md | 15 |
| `MEMORY_TOPIC_MAX_ENTRIES` | Max entries per topic file | 50 |
| `REM_SLEEP_SCHEDULE` | Cron for weekly consolidation | `0 3 * * 0` |

---

## What This Repo Contains

```
memory/
├── SKILL.md              # The skill — agents read this
├── WORKFLOW.md           # 5-stage sync lifecycle
├── README.md             # You are here
├── hooks/                # Session lifecycle hooks
├── docs/
│   ├── VISION.md         # Vision deck
│   ├── STATE_MACHINE.md  # Sync state transitions
│   ├── ARCHITECTURE.md   # 3-tier memory reference
│   └── SYNC_PROTOCOL.md  # Cross-platform contract
├── examples/             # Sync examples and reports
├── .claude-plugin/       # Claude Code marketplace
├── gemini-extension.json # Gemini CLI manifest
└── .github/workflows/    # CI validation + release
```

---

## Principles

1. **Vault is the single source of truth** — all platforms sync to Obsidian
2. **WAL-first** — write session state before responding
3. **Facts and rules never mix** — MEMORY.md ≠ AGENTS.md
4. **Everything decays** — TTL is mandatory, permanent is explicit
5. **Dedup before write** — search, patch, or skip
6. **Report what you did** — structured output, not silent writes

---

## License

MIT — see [LICENSE](LICENSE).

Maintained by [maxtechera](https://github.com/maxtechera).
