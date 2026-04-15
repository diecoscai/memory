# memory project — facts

## Repo
- Path: `/Users/max/.dotfiles/dev/memory` = `/Users/max/dev/memory` (symlinked)
- Remote: `github.com/maxtechera/memory` (main branch, public OSS)
- Installed skill: `~/.claude/skills/memory` — STALE as of 2026-04-15 [2026-04-15:3m]

## Hooks
- All 7 installed at `~/.claude/hooks/` → symlinks to `/Users/max/dev/memory/hooks/`
- SessionStart, PreCompact, Stop, SubagentStart/Stop, Notification all wired in settings.json
- **Gap**: `session-stop-vault.sh` exits early if `SESSION-STATE.md` missing — WAL must exist for flush to work [2026-04-15:3m]

## Architecture
- 3-tier HOT/WARM/COLD — no vector DB, no cloud, pure markdown + Obsidian
- Unified sync: single `/memory sync` scrapes all 8 sources → classify → dedup → TTL → route to tiers + wiki
- Dream: weekly consolidation, TTL audit, wiki rebuild
- LLM wiki: Karpathy pattern, compiles COLD vault into queryable wiki/, publishes to Notion

## README SEO (2026-04-15)
- Primary angles: "AI agent amnesia", "context engineering", "second brain for Claude Code", "LLM persistent memory"
- Top competing repos: coleam00/claude-memory-compiler, coleam00/second-brain-skills, rohitg00/agentmemory
- Differentiators: no vector DB, 3-tier OS-inspired, cross-platform, LLM wiki built-in, TTL decay, free/local
- Added: Obsidian graph GIF (9.7MB autoplay) + static screenshot as visual hook [2026-04-15:3m]
