# REM Sleep Report Example (Mode 4)

Weekly consolidation run — Sunday 3am UTC.

## Detect

- 7 daily journals scanned: 2026-04-03 through 2026-04-09
- 4 topic files checked for TTL expiry
- MEMORY.md router: 12 lines (within limit)

## Classify

| Source | Insight | Target |
|--------|---------|--------|
| 2026-04-05 journal | Flowise 2.x → 3.x migration gotchas | Obsidian `knowledge/learnings/` |
| 2026-04-07 journal | Chose Railway over Render for OpenClaw | Obsidian `knowledge/decisions/` |
| 2026-04-08 journal | Prisma batch upsert pattern | Obsidian `knowledge/patterns/` |
| tools-creds.md | Vercel token expired [2026-01-09:3m] | Archive |

## Write

- Obsidian `knowledge/learnings/flowise-3x-migration.md`: created
- Obsidian `knowledge/decisions/railway-over-render.md`: created
- Obsidian `knowledge/patterns/prisma-batch-upsert.md`: created
- `memory/topics/tools-creds.md`: removed expired Vercel token entry

## Health Check

```
MEMORY.md: 12 lines (OK, limit 15)
Topic files: 4 checked
  tools-creds.md: 23 entries (OK, limit 50)
  infra.md: 18 entries (OK)
  openclaw.md: 41 entries (OK)
  admirarr.md: 9 entries (OK)
Boundary test: PASS (0 rules in MEMORY.md)
TTL audit: 1 expired, 0 missing suffix
```

## Report

```
Memory sync complete
Mode: 4 REM-sleep
Topic files updated: 0 entries across 0 files (1 archived)
Obsidian: 1 pattern, 1 decision, 1 learning, 0 journals
SESSION-STATE: N/A (cron mode)
TTL: 4 entries reviewed, 1 archived
Skipped (duplicates): 0
Health: OK
```
