# Memory Workflow — 5-Stage Sync Lifecycle

Every memory operation follows this lifecycle. Whether triggered by `/memory sync`, `/memory dream`, or a session hook, the same 5 stages execute in order.

> See also: [STATE_MACHINE.md](docs/STATE_MACHINE.md) for formal state transitions.

---

## Stage 1: Detect

**Goal**: Identify what changed since the last sync.

**Actions by mode**:

| Mode | What to detect |
|------|---------------|
| Mode 1 (session) | SESSION-STATE.md WAL entries not yet flushed |
| Mode 2 (openclaw) | New files in `openclaw-config/memory/` not in Obsidian `logs/journals/` |
| Mode 3 (projects) | Files in `~/.claude/projects/*/memory/*.md` not synced to vault |
| Mode 4 (dream) | Last 7 daily journals, stale TTLs, bloated routers |

**Output**: A list of items to process, or "Nothing to sync" → skip to Stage 5.

---

## Stage 2: Classify

**Goal**: Route each insight to the correct tier and target file.

| Insight Type | Target | Tier |
|-------------|--------|------|
| Platform/infra fact | `memory/topics/infra.md` | WARM |
| Project fact | `memory/topics/{project}.md` | WARM |
| Tool/credential | `memory/topics/tools-creds.md` | WARM |
| Pattern (reusable) | Obsidian `knowledge/patterns/` | COLD |
| Decision (strategic) | Obsidian `knowledge/decisions/` | COLD |
| Learning (one-time) | Obsidian `knowledge/learnings/` | COLD |
| Daily event | `memory/YYYY-MM-DD.md` + Obsidian `logs/journals/` | WARM→COLD |
| Behavioral rule | `AGENTS.md` | HOT |

**Critical**: Behavioral rules (NEVER, ALWAYS, must) go to `AGENTS.md`, never to `MEMORY.md`. Run boundary test after classification.

---

## Stage 3: Dedup

**Goal**: Prevent duplicate entries across tiers.

**For WARM tier (topic files)**:
1. Read the target file
2. Check each new entry against existing content
3. If >80% semantic match → update the existing entry in-place
4. If no match → append as new entry

**For COLD tier (Obsidian)**:
1. `obsidian search query="[key terms]" limit=5`
2. If match found → read note → patch with new information
3. If no match → create new note with proper frontmatter

**For MEMORY.md router**:
- Never add content directly — only add pointers to topic files
- If new domain emerges → create `memory/topics/{domain}.md` first, then add pointer

---

## Stage 4: Write

**Goal**: Apply all changes, WAL-first.

**Write order** (strict):
1. `SESSION-STATE.md` — updated BEFORE responding to user
2. `memory/topics/*.md` — append with TTL suffix
3. `MEMORY.md` — update router pointers if new topic files created
4. Obsidian notes — create/patch via Obsidian CLI with full frontmatter

**TTL requirement**: Every new entry in `memory/topics/*.md` must include a decay suffix `[YYYY-MM-DD:Nm]` or be explicitly permanent (no suffix).

**Frontmatter requirement**: Every new Obsidian note must include all required fields per `knowledge/TAXONOMY.md`.

---

## Stage 5: Report

**Goal**: Structured output of what happened.

```
Memory sync complete
Mode: [1 session | 2 openclaw-pull | 3 cc-project | 4 dream]
Topic files updated: X entries across Y files
Obsidian: X patterns, Y decisions, Z learnings, N journals
SESSION-STATE: flushed to memory/YYYY-MM-DD.md
TTL: X entries reviewed, Y archived
Skipped (duplicates): N
Health: [OK | ALERTS: ...]
```

**Health alerts** (Mode 4 only):
- `topic-file-too-large`: topic file has >50 entries → recommend split
- `memory-router-bloated`: MEMORY.md has >15 lines → prune needed
- `ttl-missing`: entry older than 6 months with no TTL suffix → assign or archive
- `boundary-violation`: MEMORY.md contains behavioral rules → fix immediately

---

## Priority Order

When multiple sync operations are pending, process in this order:

1. **WAL flush** — SESSION-STATE.md entries (immediate, blocking)
2. **Mode 1** — session sync (user-triggered, interactive)
3. **Mode 3** — CC project sync (on-demand)
4. **Mode 2** — OpenClaw pull sync (on-demand)
5. **Mode 4** — Dream (scheduled, background)
