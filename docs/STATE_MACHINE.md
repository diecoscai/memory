# Memory — State Machine

Formal state transitions for memory sync operations.

> Cross-reference: [WORKFLOW.md](../WORKFLOW.md) describes the 5-stage lifecycle in operational terms. This document defines the formal states and transitions.

---

## States

| State | Description |
|-------|-------------|
| **Idle** | No sync in progress. Waiting for trigger. |
| **Detecting** | Scanning for changes: SESSION-STATE, journals, topic files, TTLs |
| **Classifying** | Routing each insight to correct tier and target file |
| **Deduplicating** | Checking existing content for matches before writing |
| **Writing** | Applying changes: WAL → topics → router → vault |
| **Reporting** | Generating structured sync report |
| **Error** | A write or vault operation failed; error logged in report |

---

## Transitions

```
Idle ──trigger──> Detecting
Detecting ──changes found──> Classifying
Detecting ──no changes──> Reporting
Classifying ──all routed──> Deduplicating
Deduplicating ──clean list──> Writing
Writing ──success──> Reporting
Writing ──partial failure──> Reporting (with warnings)
Writing ──critical failure──> Error
Error ──logged──> Reporting
Reporting ──done──> Idle
```

### State Diagram

```
                    ┌──────────┐
                    │   Idle   │◄────────────────────────┐
                    └────┬─────┘                         │
                         │ trigger                       │
                    ┌────▼─────┐                         │
                    │Detecting │                         │
                    └────┬─────┘                         │
              ┌──────────┼──────────┐                    │
         changes      no changes    │                    │
              │          │          │                    │
        ┌─────▼────┐     │          │                    │
        │Classifying│    │          │                    │
        └─────┬────┘     │          │               ┌───┴────┐
              │           │          │               │Reporting│
        ┌─────▼────────┐  │          │               └───▲────┘
        │Deduplicating │  │          │                   │
        └─────┬────────┘  │          │                   │
              │           │          │                   │
        ┌─────▼────┐      │          │                   │
        │ Writing  │──────┼──────────┼───────────────────┤
        └─────┬────┘      │          │        success    │
              │           │          │                   │
              │ failure   │          │                   │
        ┌─────▼────┐      │          │                   │
        │  Error   │──────┴──────────┴───────────────────┘
        └──────────┘                          logged
```

---

## Triggers

| Trigger | Source | Target State |
|---------|--------|-------------|
| `/memory sync` | User command | Detecting (Mode 1) |
| `/memory sync openclaw` | User command | Detecting (Mode 2) |
| `/memory sync projects` | User command | Detecting (Mode 3) |
| `/memory dream` | User command or cron | Detecting (Mode 4) |
| `/memory audit` | User command | Detecting (audit-only, no writes) |
| PreCompact hook | Automatic | Detecting (WAL flush only) |
| Stop hook | Automatic | Detecting (WAL flush only) |

---

## Error Handling

Errors during Writing do not halt the entire sync. The system continues with remaining items and reports partial results.

| Error Type | Action | Recovery |
|-----------|--------|----------|
| Obsidian CLI unavailable | Fall back to filesystem writes | Report warning, suggest starting app |
| Vault path not found | Skip COLD tier writes | Report error, suggest `/memory setup` |
| Topic file permission error | Skip that file | Report error with path |
| Dedup search timeout | Treat as no-match, write as new | Report warning |
| MEMORY.md locked by another process | Retry once, then skip | Report warning |

---

## Mode-Specific Behavior

### Mode 1 (Session Sync)
- Detecting: reads SESSION-STATE.md only
- Writing: WAL → topics → vault
- Lightweight, designed for interactive use

### Mode 2 (OpenClaw Pull)
- Detecting: diffs `openclaw-config/memory/` against vault journals
- Writing: creates/patches Obsidian `logs/journals/` notes
- Cleans raw metadata from OpenClaw entries

### Mode 3 (Project Sync)
- Detecting: scans `~/.claude/projects/*/memory/*.md`
- Classifying: prefixes vault notes with `cc-` origin marker
- Writing: creates/patches Obsidian knowledge/ and projects/ notes

### Mode 4 (Dream)
- Detecting: last 7 journals + all topic files + MEMORY.md router
- Full health check after Writing
- Generates comprehensive report with health alerts
