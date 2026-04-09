# Memory Architecture — 3-Tier Reference

Definitive reference for the HOT/WARM/COLD memory architecture.

---

## Overview

```
┌─────────────────────────────────────────────────┐
│  HOT TIER  (≤2400 tokens, always loaded)        │
│  MEMORY.md — router, pointers                   │
│  SESSION-STATE.md — WAL, live context            │
├─────────────────────────────────────────────────┤
│  WARM TIER  (on-demand, domain-scoped)          │
│  memory/topics/*.md — facts with TTL decay      │
│  memory/YYYY-MM-DD.md — daily journals          │
├─────────────────────────────────────────────────┤
│  COLD TIER  (permanent, search-only)            │
│  Obsidian vault — knowledge, logs, projects     │
└─────────────────────────────────────────────────┘
```

---

## HOT Tier

**Budget**: ≤2400 tokens total across both files.
**Load pattern**: Always injected into context. Every session, every prompt.

### MEMORY.md (Router)

- Contains ONLY facts and pointers — never rules
- Max 15 lines
- Format: `- [Title](topic-file.md) — one-line hook`
- Pruned by REM Sleep weekly

### SESSION-STATE.md (WAL)

- Write-Ahead Log: updated BEFORE responding
- Contains: current task, key context, pending actions, recent decisions, blockers
- Flushed to vault daily journal on compaction and session end
- Ephemeral by design — wiped when session completes

---

## WARM Tier

**Budget**: On-demand. Loaded only when domain matches current work.
**Read pattern**: Agent reads specific topic file when working in that domain.

### Topic Files (`memory/topics/*.md`)

- Domain-scoped: `openclaw.md`, `infra.md`, `tools-creds.md`, `{project}.md`
- Every entry has TTL suffix: `[YYYY-MM-DD:Nm]` or explicitly permanent
- Max 50 entries per file — split when exceeded
- Dedup enforced: >80% match → update in-place

### Daily Journals (`memory/YYYY-MM-DD.md`)

- Auto-created by hooks and Mode 1 sync
- WARM for last 7 days, then archived
- Contains session summaries, key decisions, timestamps

---

## COLD Tier

**Budget**: Search-only. Agent uses `obsidian search` to find relevant notes, then reads specific ones.
**Storage**: Obsidian vault with enforced frontmatter schema.

### Content Types

| Type | Folder | Description |
|------|--------|-------------|
| `pattern` | `knowledge/patterns/` | Reusable mental models, frameworks |
| `learning` | `knowledge/learnings/` | Experience distillations, gotchas |
| `decision` | `knowledge/decisions/` | Strategic choices with rationale |
| `journal` | `logs/journals/` | Daily logs (from hooks + sync) |
| `session-digest` | `logs/sessions/` | Auto-generated session summaries |
| `project` | `projects/` | Active/archived project notes |
| `moc` | `*/_*.md` | Maps of Content (index files) |
| `reference` | `dev/` | Tech docs, stack guides, integration specs |
| `identity` | `identity/` | Profile, brand, identity docs |
| `operations` | `operations/` | Workflows, playbooks, agent definitions |

### Frontmatter Schema (Required)

```yaml
---
type: [one of 10 canonical types]
status: active|draft|archived
agent-use: high|medium|low
use-when: "comma-separated keywords"
summary: "one-line description"
tags: [tag1, tag2]
domain: [one of 8 canonical domains]
created: 'YYYY-MM-DD'
source: "origin"
---
```

---

## Tier Promotion / Demotion

| Direction | When | Example |
|-----------|------|---------|
| HOT → WARM | MEMORY.md pruned, fact moves to topic file | Router entry → `memory/topics/infra.md` |
| WARM → COLD | Pattern recognized, or REM Sleep promotes | Topic fact → Obsidian `knowledge/patterns/` |
| WARM → archived | TTL expired, entry no longer relevant | Old API version → deleted or archived |
| COLD → never moves | Permanent knowledge stays in vault | Patterns, decisions are forever |

Facts flow DOWN the tiers (HOT → WARM → COLD). They never flow up. The HOT tier is always a subset of what WARM knows, which is a subset of what COLD knows.

---

## Token Budget Math

| Component | Typical Tokens | Max Tokens |
|-----------|---------------|------------|
| MEMORY.md (15 lines) | ~400 | ~600 |
| SESSION-STATE.md | ~800 | ~1800 |
| **HOT total** | ~1200 | ~2400 |

If MEMORY.md + SESSION-STATE.md exceed 2400 tokens, the agent may truncate. REM Sleep health checks flag this condition.

---

## Platform-Specific Behavior

### Claude Code
- HOT: `SESSION-STATE.md` (WAL) + `CLAUDE.md` (loaded by framework)
- WARM: `~/.claude/projects/*/memory/*.md` (on-demand)
- COLD: Obsidian MCP (direct access)
- Hooks: All 7 hooks active

### OpenCode
- HOT: `SESSION-STATE.md` (WAL)
- WARM: On-demand file reads
- COLD: Obsidian MCP (direct access)
- Hooks: Not yet supported

### OpenClaw (Railway)
- HOT: `MEMORY.md` (router) + `SESSION-STATE.md` (WAL)
- WARM: `memory/topics/*.md` in `openclaw-config/`
- COLD: No Obsidian access — synced via Mode 2
- Hooks: N/A (runs as cron/webhook)
