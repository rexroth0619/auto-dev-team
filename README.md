# auto-dev-team 1.0

> An Agent Skill for software delivery work: mode routing, structured execution, continuous verification, and safe rollback.

[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-Compatible-blue)](https://agentskills.io)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## What It Is

`auto-dev-team` is a delivery-oriented skill for coding agents.

It turns feature work, debugging, refactoring, testing, and staging validation into:
- explicit mode routing
- guarded write flows
- scriptable blast-radius analysis
- rollback-ready checkpoints and archives
- interactive staging-validation loops

## Language

- English: default branch `main`
- Chinese: branch `zh-CN`

Clone the English skill:

```bash
git clone -b main https://github.com/rexroth0619/AutoDevTeam.git
```

Clone the Chinese skill:

```bash
git clone -b zh-CN https://github.com/rexroth0619/AutoDevTeam.git
```

## Current Version

- English release tag: `v1.0.0`
- Chinese release tag: `v1.0.0-zh-CN`

## Recent Updates

- See [CHANGELOG.md](CHANGELOG.md)
- Current highlights:
  - interactive staging-validation flow
  - `release-pack` script and selftest
  - anti-spaghetti quick check
  - bilingual release branches

## Agent Quick Start

- read `SKILL.md` first
- before write-mode work, read `references/mode-index.md`
- then read `references/write-preflight.md`
- after script changes, run the matching selftest
- use `zh-CN` for Chinese work and `main` for English release work

## Contents

- Overview
- Entry Structure
- Repository Layout
- Modes
- V2 Testing Protocol
- Usage
- Config and Scripts
- PM Resources
- License

## Overview

`auto-dev-team` is built on the [Agent Skills specification](https://agentskills.io/specification).

The goal is to keep the main entry light while moving reusable delivery rules into mode docs, shared principles, templates, and scripts.

Core ideas:

- lightweight entry
- explicit mode routing
- shared write preflight
- principle loading by mode, phase, and artifact
- scripts for mechanical steps
- verification and rollback by default
- blast radius before the first code write
- backend testing after code changes
- GUI-capable work enters the GUI validation loop by default
- large tests are tracked in `.autodev/current-test.md`

## Entry Structure

```text
SKILL.md
references/mode-index.md
references/write-preflight.md
references/modes/*/README.md
references/principles/*.md
```

## Repository Layout

```text
auto-dev-team/
├── SKILL.md
├── .cursor/
│   └── agents/
│       ├── critique.md
│       ├── test-runner.md
│       └── test-writer.md
├── assets/
│   └── templates/
│       ├── autodev-config.json
│       ├── context-snapshot.md
│       ├── current-test.md
│       ├── current-steps.md
│       ├── current-blast-radius.md
│       ├── forbidden-zones.md
│       ├── module-registry.md
│       ├── gui-case-matrix.md
│       ├── gui-evidence-bundle.md
│       ├── path.md
│       ├── playwright-script-loop.js
│       ├── postmortem.md
│       ├── project-map.md
│       ├── release-test-pack.md
│       └── verification-checklist.md
├── scripts/
│   ├── blast-radius.py
│   ├── blast-radius-step.sh
│   ├── blast-radius-selftest.sh
│   ├── blast-radius-step-selftest.sh
│   ├── checkpoint.sh
│   ├── checkpoint-selftest.sh
│   ├── release-pack.py
│   ├── release-pack-selftest.sh
│   └── init-autodev.sh
└── references/
    ├── gotchas.md
    ├── mode-index.md
    ├── shared/
    │   └── flow-snippets.md
    ├── write-preflight.md
    ├── modes/
    │   ├── architect/README.md
    │   ├── cleanup/README.md
    │   ├── debug/README.md
    │   ├── explain/README.md
    │   ├── fasttrack/README.md
    │   ├── hotfix/README.md
    │   ├── optimize/README.md
    │   ├── refactor/README.md
    │   ├── step/README.md
    │   ├── survey/README.md
    │   └── tester/README.md
    ├── patterns/
    ├── pm-guide/
    └── principles/
```

## Modes

| Mode | Trigger | Purpose |
|------|---------|---------|
| Architect | new features, implementation work | design and step planning |
| Debug | bugs, errors, broken behavior | diagnose first, then fix |
| Hotfix | urgent production issues | minimum safe fix |
| FastTrack | tiny copy/style/single-point changes | fast low-risk execution |
| Refactor | splitting, cleanup, extraction | structural improvement with guardrails |
| Optimize | performance work | diagnose first, then optimize |
| Cleanup | dead code and redundancy removal | safe cleanup |
| Tester | tests, coverage, release testing, manual validation | testing assets and interactive validation |
| Survey | learn the project | project mapping |
| Explain | explain code or flow | comprehension support |
| Step | execution stage for Architect / Refactor / Optimize | incremental delivery |

## V2 Testing Protocol

- behavior scenarios for PM-readable use cases
- blast radius gate before code changes
- step blast radius wrapper from `current-steps.md`
- backend testing after code changes
- GUI validation loop for GUI-capable tasks
- script-first and suite-first Playwright support
- manual validation for perception-heavy or external-system cases
- interactive pre-release testing flow driven by real staging data
- small tests end with a test receipt
- large tests maintain `.autodev/current-test.md`

## Usage

Install the skill in any Agent Skills-compatible tool and describe the work in natural language.

Examples:

- "Build a user login feature"
- "This endpoint started returning 500"
- "Change the button color to blue"
- "This code is messy, refactor it"
- "Walk me through staging validation for the latest commits"

## Config and Scripts

- environment and path facts: `.autodev/path.md`
- skill policy and thresholds: `.autodev/autodev-config.json`
- initialize `.autodev/`: `scripts/init-autodev.sh`
- blast radius: `scripts/blast-radius.py`
- step blast radius wrapper: `scripts/blast-radius-step.sh`
- blast radius selftest: `scripts/blast-radius-selftest.sh`
- step wrapper selftest: `scripts/blast-radius-step-selftest.sh`
- checkpoint primitives: `scripts/checkpoint.sh`
- checkpoint selftest: `scripts/checkpoint-selftest.sh`
- interactive release-test draft: `scripts/release-pack.py`
- release-test selftest: `scripts/release-pack-selftest.sh`
- high-signal gotchas: `references/gotchas.md`

### Interactive Release-Test Examples

Standard calls for later agents:

```bash
python3 scripts/release-pack.py --commits 3 --task "Staging validation for the latest 3 commits"
python3 scripts/release-pack.py --range abc123..def456 --task "Approval flow staging validation"
bash scripts/release-pack-selftest.sh
```

## PM Resources

- `references/pm-guide/task-templates.md`
- `references/pm-guide/common-commands.md`
- `references/pm-guide/conversation-tips.md`

## License

MIT License
