# Changelog

All notable changes to the memory skill are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.0.0] - 2026-04-09

### Added
- Core memory skill (SKILL.md, WORKFLOW.md)
- 5-stage sync lifecycle: Detect → Classify → Dedup → Write → Report
- 3-tier memory architecture: HOT (router + WAL), WARM (topic files), COLD (Obsidian vault)
- 4 sync modes: session, openclaw-pull, cc-project, dream
- WAL protocol for compaction survival
- TTL convention for memory decay (permanent, operational/6m, project/3m, session/1m)
- 7 session hooks: session-start, pre-compact, session-stop, agent-start, agent-stop, compact-notification, force-mcp-connectors
- Cross-platform sync: Claude Code, OpenCode, OpenClaw → Obsidian as SOT
- Obsidian CLI integration (v1.12.7+)
- Claude Code Plugin Marketplace manifests
- ClawHub/OpenClaw distribution
- Gemini CLI extension manifest
- CI: validate workflow (hook lint, manifest validation, version sync, cross-doc checks)
- CI: release workflow (tag-push → GitHub Release)
