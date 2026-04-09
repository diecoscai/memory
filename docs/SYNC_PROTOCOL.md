# Cross-Platform Memory Contract

How knowledge flows between OpenClaw, Claude Code, OpenCode, and Obsidian.

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│              OBSIDIAN VAULT                          │
│          (Single Source of Truth)                    │
│  knowledge/ | logs/ | projects/ | identity/ | dev/  │
└────────────────────┬────────────────────────────────┘
                     │ writes via MCP (Obsidian tools)
        ┌────────────┼────────────┐
        │            │            │
 ┌──────┴──────┐ ┌───┴──┐  ┌─────┴──────┐
 │ Claude Code │ │ Open │  │  OpenClaw   │
 │  sessions   │ │ Code │  │ (Railway)   │
 │  + project  │ │      │  │             │
 │  memory     │ │      │  │ MEMORY.md   │
 │  + plans    │ │      │  │ memory/*    │
 └─────────────┘ └──────┘  └──────┬─────┘
                                   │ git push/pull
                              ┌────┴────┐
                              │  local   │
                              │openclaw- │
                              │ config/  │
                              └──────────┘
```

---

## Platform Roles

| Platform | HOT | WARM | COLD | Obsidian Access |
|----------|-----|------|------|-----------------|
| **OpenClaw** | MEMORY.md (router) + SESSION-STATE.md (WAL) | memory/topics/*.md | No MCP | git → local → Obsidian |
| **Claude Code** | SESSION-STATE.md (WAL) + CLAUDE.md | On-demand Read | Obsidian MCP | Direct |
| **OpenCode** | SESSION-STATE.md (WAL) | On-demand Read | Obsidian MCP | Direct |
| **Obsidian** | identity/ (HOT-equivalent) | projects/, logs/journals/ (30d) | knowledge/, logs/archive | Native |

---

## Sync Rules

### OpenClaw → Obsidian
- OpenClaw writes to `openclaw-config/memory/YYYY-MM-DD.md` independently
- On git pull: check for new files in `openclaw-config/memory/`
- Run Mode 2 of memory skill to pull new journals into Obsidian `logs/journals/`
- MEMORY.md compressed lessons → `knowledge/learnings/openclaw-operational-lessons.md`
- **Cadence**: On demand, or when `sync openclaw` is requested

### Claude Code / OpenCode → Obsidian
- After significant work sessions, run Mode 1 of memory skill
- Project memory files (`~/.claude/projects/*/memory/`) → Obsidian via Mode 3
- **Cadence**: End of session, or when "save to memory" / "sync memory" is said

### What OpenClaw Does NOT Do
- OpenClaw does NOT write to Obsidian (no MCP access on Railway)
- OpenClaw does NOT read from Obsidian
- OpenClaw maintains its own MEMORY.md independently
- Obsidian is a superset — it knows everything OpenClaw knows, plus Claude Code session knowledge

---

## Obsidian as Source of Truth

Obsidian is authoritative for:
- **Permanent patterns** — reusable across any platform
- **Strategic decisions** — reasoning recorded with context
- **Project knowledge** — up-to-date status for all active projects
- **Personal identity** — who Max is, who Neo is
- **Historical journals** — what happened when

Obsidian is NOT authoritative for:
- **Live operational state** — use `openclaw-config/SESSION-STATE.md` for that
- **Ephemeral session context** — stays in session until compaction
- **Active cron/gateway config** — use platform-native config

---

## Vault Folder Map

| Content | Folder |
|---------|--------|
| Patterns, frameworks, techniques | `knowledge/patterns/` |
| One-time learnings & gotchas | `knowledge/learnings/` |
| Strategic decisions | `knowledge/decisions/` |
| Daily session journals | `logs/journals/` |
| Evolution proposals | `logs/evolutions/` |
| Project status | `projects/` |
| Identity docs | `identity/` |
| Tech stack refs | `dev/stacks/` |
| Tool refs | `dev/tools/` |
| System architecture | `dev/architecture/` |
| Operational playbooks | `operations/` |
