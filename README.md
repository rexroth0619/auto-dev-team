# 🤖 AutoDevTeam

> Your AI Cyber Dev Team — structured, incremental, testable software development for Cursor.

[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-Compatible-blue)](https://agentskills.io)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Overview

AutoDevTeam is a [Cursor Skill](https://agentskills.io/specification) that turns AI into a full dev team with structured, incrementally testable workflows. PMs describe requirements in natural language; AI picks the right workflow and executes step by step.

## Features

- 🎯 **Auto Mode Selection** — picks the right workflow by intent
- 📋 **Incremental Testability** — every step is verifiable
- 🔄 **Checkpoints** — rollback anytime
- 📚 **Pattern Distillation** — accumulates reusable patterns
- 🛡️ **Forbidden Zones** — protects critical files
- 👔 **PM-Friendly** — no technical background needed

## Install

```bash
# User-level
cd ~/.cursor/skills/ && git clone git@github.com:rexroth0619/AutoDevTeam.git autoDevTeam

# Project-level
cd your-project/.cursor/skills/ && git clone git@github.com:rexroth0619/AutoDevTeam.git autoDevTeam
```

## Structure

```
autoDevTeam/
├── SKILL.md                    # Main skill file
├── assets/templates/           # Project doc templates
├── references/
│   ├── modes/                  # Workflow definitions
│   ├── patterns/               # Reusable patterns (universal/language/platform)
│   ├── principles/             # Core principles
│   └── pm-guide/               # PM resources
└── .cursor/agents/             # Subagent definitions
```

## Modes

| Mode | Trigger | Purpose |
|------|---------|---------|
| **Architect** | "Build a login feature" | New features |
| **Debug** | "Login API is broken" | Bug diagnosis |
| **Hotfix** | "Production is down!" | Emergency fix |
| **FastTrack** | "Change button to blue" | Quick edits |
| **Refactor** | "This code is a mess" | Restructure |
| **Optimize** | "Page loads too slow" | Performance |
| **Survey** | "Walk me through this project" | Onboarding |
| **Cleanup** | "Remove dead code" | Cleanup |
| **Tester** | "Add tests for this" | Testing |
| **Explain** | "What does this do?" | Explanation |

## Core Principles

1. **Safety** — no data loss, rollback-capable, no secret leaks
2. **Incremental Testability** — each step independently verifiable
3. **Minimal Changes** — only what's necessary
4. **Pattern Distillation** — every solution may yield a reusable pattern

## PM Resources

- `references/pm-guide/task-templates.md` — task templates
- `references/pm-guide/common-commands.md` — command cheat sheet
- `references/pm-guide/conversation-tips.md` — conversation tips

## Contributing

Contributions welcome: new modes, language/platform patterns, PM UX improvements, bug fixes.

## License

MIT
