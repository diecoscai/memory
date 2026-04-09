# Memory — Vision

## Slide 1: Title

**MEMORY**

Your agents forget everything. This fixes that.

Cross-platform memory system. 3-tier architecture, vault sync, session hooks, weekly consolidation.

---

## Slide 2: The End State

You close your laptop at 6pm. You reopen it the next morning. Your agent picks up exactly where you left off — it knows what you decided yesterday, what's blocked, what your preferences are.

Every session builds on the last. Your Obsidian vault is the permanent brain — patterns, decisions, learnings accumulate over months. Nothing is lost to compaction. Nothing is duplicated across platforms.

Your agents get smarter because they remember.

---

## Slide 3: The Gap

Today, AI agent memory is a mess.

- `MEMORY.md` in one project. `CLAUDE.md` in another. A vault note somewhere. A session state file that gets wiped on compaction.
- Claude Code, OpenCode, and OpenClaw each maintain their own memory — none of them talk to each other.
- Compaction kills context. The agent that spent an hour learning your preferences forgets all of it when the context window fills up.
- No decay. No dedup. No sync. Memory files grow until they're too large to be useful, or they stay empty because there's no protocol for when and what to write.

The tools are powerful. The memory is broken.

---

## Slide 4: The Architecture

Three tiers. Clear boundaries. Automatic decay.

```
HOT   ≤2400tok, always loaded
  MEMORY.md         = router (pointers, not content)
  SESSION-STATE.md  = WAL (write-ahead log)

WARM  on-demand, domain-scoped
  memory/topics/*.md  facts with TTL
  memory/YYYY-MM-DD.md  daily journals

COLD  permanent, search-only
  Obsidian vault    knowledge/ logs/ projects/ identity/
```

The WAL protocol is the critical piece: write session state BEFORE responding. Not after. Not "when convenient." Before. This is how you survive compaction.

Token budget math: HOT tier stays under 2400 tokens. WARM loads on-demand when domain matches. COLD is search-only — the agent doesn't load 475 vault notes into context, it searches for what it needs.

---

## Slide 5: What Memory Does

Four sync modes. Seven session hooks. One weekly consolidation.

| Mode | Trigger | Flow |
|------|---------|------|
| **1. Session sync** | "save to memory" / session end | Session → topics → vault |
| **2. OpenClaw pull** | "sync openclaw" | OpenClaw journals → Obsidian |
| **3. Project sync** | "sync projects" | CC project memory → Obsidian |
| **4. REM Sleep** | Weekly cron / "run REM sleep" | Consolidate + prune + TTL audit |

Hooks handle the routine: vault stats on session start, state flushed on compaction, everything persisted on session end. You don't invoke them — they fire automatically.

---

## Slide 6: The WAL Protocol

Write-Ahead Logging. The database world solved this decades ago. We're applying it to agent memory.

**The problem**: Your agent learns something important. The context window fills up. Compaction happens. The knowledge is gone.

**The fix**: Write SESSION-STATE.md BEFORE responding to the user. Every preference, decision, deadline, correction — captured in the WAL before the response is generated.

When compaction hits, the pre-compact hook flushes the WAL to the vault daily journal. When the session ends, the stop hook persists everything. The knowledge survives.

| Trigger | Action |
|---------|--------|
| User states preference | Write WAL → respond |
| User makes decision | Write WAL → respond |
| User gives deadline | Write WAL → respond |
| User corrects you | Write WAL → respond |

---

## Slide 7: Session Hooks

Zero-effort persistence. Install once, forget about it.

**SessionStart** — Injects vault awareness. The agent knows: vault path, note count, journals this month. It starts every session with context.

**PreCompact** — Before compaction wipes context, the hook appends SESSION-STATE to the vault daily journal. Frontmatter is auto-generated. Nothing is lost.

**Stop** — Session ends. State is flushed to both the vault and `~/.claude/compaction-state/latest.md`. The next session can reconstruct what happened.

**SubagentStart / SubagentStop** — Tracks concurrent agent count. Useful for monitoring team parallelization.

**Notification (compact)** — After compaction, prints vault stats and a SESSION-STATE preview so you can verify what was preserved.

---

## Slide 8: Cross-Platform Sync

Three platforms. One source of truth.

```
┌────────────────────────────────────────────┐
│            OBSIDIAN VAULT                   │
│        (Single Source of Truth)             │
└──────────────────┬─────────────────────────┘
      ┌────────────┼────────────┐
      │            │            │
 Claude Code    OpenCode    OpenClaw
 (direct MCP)  (direct MCP)  (git → local)
```

**Claude Code & OpenCode** — Direct Obsidian MCP access. Hooks write to vault in real-time.

**OpenClaw** — Runs on Railway, no Obsidian access. Writes to `openclaw-config/memory/` independently. Mode 2 pulls those journals into the vault when you're back on local.

The vault is always the superset. It knows everything every platform knows.

---

## Slide 9: REM Sleep

The brain's offline processing. Weekly consolidation that keeps memory healthy.

**What it does**:
1. Reads last 7 daily journals
2. Extracts insights → classifies → routes to topic files
3. Prunes MEMORY.md router (≤15 lines, zero rules)
4. TTL audit: flags expired entries, archives stale facts
5. Health check: splits bloated topic files, flags missing TTLs
6. Syncs everything to Obsidian

**Health alerts**:
- `topic-file-too-large` — >50 entries, needs split
- `memory-router-bloated` — >15 lines, prune now
- `ttl-missing` — >6 months old, no decay suffix
- `boundary-violation` — rules found in MEMORY.md

---

## Slide 10: Obsidian as Cold Storage

Your Obsidian vault is the permanent tier. 10 canonical types. 8 domains. 48 tags. Every note has structured frontmatter.

| Folder | Content | Tier |
|--------|---------|------|
| `knowledge/patterns/` | Reusable frameworks | COLD |
| `knowledge/learnings/` | Experience distillations | COLD |
| `knowledge/decisions/` | Strategic choices with rationale | COLD |
| `logs/journals/` | Daily session logs | WARM→COLD |
| `projects/` | Active project notes | WARM |
| `identity/` | Profile, brand, identity | HOT-equivalent |

The taxonomy is versioned. The frontmatter is enforced. The Obsidian CLI handles search, read, create, and append — the agent never touches raw filesystem paths in the vault.

---

## Slide 11: Tradeoffs

**Obsidian dependency** — Obsidian app must be running for CLI commands. Hooks fall back to direct filesystem writes if the app is down, but search and index features require the app.

**TTL requires discipline** — If you don't assign TTL suffixes, entries accumulate indefinitely. REM Sleep flags these, but the human must decide: keep, decay, or archive.

**Async, not real-time** — OpenClaw sync is pull-based (Mode 2). Changes on Railway aren't visible in the vault until you run `/memory sync openclaw`. Claude Code and OpenCode sync is real-time via hooks.

**Token budget** — HOT tier is capped at ~2400 tokens. If your MEMORY.md router exceeds this, the agent may not load all of it. REM Sleep enforces the 15-line limit.

---

## Slide 12: The Vision

Every AI session contributes to a permanent knowledge graph. Patterns accumulate. Decisions are recorded with context. Learnings compound over months.

The agent that starts a session on Tuesday has access to everything you decided on Monday. The agent on a different platform knows what the other platform learned. Compaction stops being destructive because the WAL protocol preserves what matters.

Nothing is forgotten. Everything decays gracefully. Your agents get smarter because they remember.

Maintained by [maxtechera](https://github.com/maxtechera).
