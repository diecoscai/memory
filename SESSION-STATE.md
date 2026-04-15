# SESSION-STATE.md — Active Working Memory (WAL)

## Current Task
Memory repo sync — running `/memory sync` to flush 2-session backlog to all tiers + Obsidian vault.

## Key Context
- memory repo at `/Users/max/.dotfiles/dev/memory` = `/Users/max/dev/memory` (same dir via symlink)
- All 7 hooks installed at `~/.claude/hooks/` → `/Users/max/dev/memory/hooks/`
- **Critical bug**: installed skill at `~/.claude/skills/memory` is STALE — still has old Mode 1-4 SKILL.md, not the new unified sync pipeline
- **Root cause of 15-day journal gap**: `session-stop-vault.sh` exits early if `${PWD}/SESSION-STATE.md` doesn't exist — no WAL = no flush
- Last vault journal: 2026-03-31. No April journals yet.
- CC project memories in `~/.claude/projects/` have 15+ unsynced feedback files

## Recent Decisions
- Unified sync pipeline: Modes 1-3 collapsed into single `/memory sync`, 8 sources, 7-step pipeline with wiki feed built-in
- README SEO rewrite: "AI amnesia" + "context engineering" + "second brain" framing
- Obsidian graph GIF (9.7MB, 8fps) + static screenshot added to README
- Linear tickets MAX-564–570 created (OSS courses, tools landing page, reel scripts) all P1

## Pending Actions
- [ ] Fix installed skill (`~/.claude/skills/memory`) — sync it to current repo state
- [ ] Investigate why `~/.claude/skills/memory` diverged from repo
- [ ] Run `/memory dream` after this sync to consolidate

## Blockers
- None
