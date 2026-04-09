# Minimal Sync Example (Mode 1)

A session sync triggered by "save to memory" after a work session.

## Detect

- SESSION-STATE.md has 3 unsaved entries
- Current task: "Migrated auth middleware to Auth0"
- Key context: "Auth0 tenant is dev-abc123, using M2M flow"
- Decision: "Chose Auth0 over Clerk for multi-tenant support"

## Classify

| Entry | Type | Target |
|-------|------|--------|
| Auth0 tenant ID | Tool/credential | `memory/topics/tools-creds.md` |
| Auth0 vs Clerk decision | Strategic decision | Obsidian `knowledge/decisions/` |
| Migration progress | Daily event | `memory/2026-04-09.md` |

## Write

- `memory/topics/tools-creds.md`: +1 entry — `Auth0 tenant: dev-abc123, M2M flow [2026-04-09:6m]`
- Obsidian `knowledge/decisions/auth0-over-clerk.md`: created with frontmatter
- `memory/2026-04-09.md`: appended migration summary

## Report

```
Memory sync complete
Mode: 1 session
Topic files updated: 1 entry across 1 file
Obsidian: 0 patterns, 1 decision, 0 learnings, 0 journals
SESSION-STATE: flushed to memory/2026-04-09.md
TTL: 0 entries reviewed, 0 archived
Skipped (duplicates): 0
Health: OK
```
