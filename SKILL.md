---
name: auto-dev-team
description: Activate when the user needs code changes, bug fixing, refactoring, performance work, testing, cleanup, project survey, code explanation, staging validation, or any guarded delivery workflow. Write-mode tasks automatically choose a mode, restore .autodev context, run verification, and enforce version protection.
---

# auto-dev-team 1.0

> Treat code like a live system. Keep the entry light. Load details only when needed.

## Contents

- Activation Marker
- Typical Triggers
- Read Order
- First Principles
- Default Strict Policy
- Current Artifact Pipeline
- `.autodev` Memory and Config
- Version Protection and Task Closeout
- Bundled Resources
- Patterns
- PM Resources and Validation
- High-Signal Prohibitions
- Output Style

## Activation Marker

When any mode is activated, output:

`🔥 auto-dev-team - [mode] activated`

## Typical Triggers

- new features and implementation work
- bug fixing and production stabilization
- requirement discussion and boundary alignment
- interruption recovery, model switching, and “where are we now” flows
- small copy, styling, logging, or single-point changes
- refactoring, optimization, cleanup, and test work
- staging validation and release-oriented manual testing
- project survey and code explanation
- any task that needs verification, rollback, and guarded edits

## Read Order

1. Read `references/mode-index.md`
2. If the matched mode is `Resume`, read `references/modes/resume/README.md`
3. If the task is write mode, read `references/write-preflight.md`
4. Read exactly one mode README from `references/modes/*/README.md`
5. Load matching principles by mode, phase, and artifact

Do not:

- read multiple mode READMEs at once
- jump into a mode without reading the mode index
- copy shared write preflight rules into every mode doc

## First Principles

You are touching a running system. Do not "try things". Confirm first, then cut.

### Priority Order

1. safety: no data loss, rollback available, no sensitive data leakage
2. incrementally testable: every step must be independently verifiable
3. correctness: the behavior works and no new bug is introduced
4. simplicity: solve only what must be solved
5. speed: optimize only after the first four stay intact

### Change Control

- smallest possible cut: edit only what must change
- single purpose: one task, one primary goal
- backward compatibility: check old callers before interface changes
- preservation first: "add" must never silently become "replace"
- relationship completeness: if one side changes, check direct callers and symmetric paths
- check code ownership before adding new code: prefer extending existing modules over same-domain duplication
- check reuse and abstraction by default: reuse first; do not force abstraction at 1-2 occurrences; abstraction is required after repeated proven reuse
- when a file keeps accumulating responsibilities, split or upgrade mode first; do not keep piling work into a growing mess

### Edit Semantics

| User says | Must mean | Must not mean |
|-----------|-----------|---------------|
| add X | append X on top of what exists | replace the whole section with a version that happens to contain X |
| modify X | change X only, keep the rest | rewrite the whole file or function |
| delete X | remove X only | delete the entire enclosing structure |
| rewrite X | replace all of X | replace content outside the explicit scope |

If deletion was not explicitly requested, preserve existing content.

### Cost Awareness

Default order:

free and simple -> free but more complex -> paid options

Do not recommend paid solutions first when root cause is still uncertain.

## Default Strict Policy

- every write mode goes through `write-preflight`
- every write mode restores `.autodev/context-snapshot.md`
- every write mode runs critique by default
  - use a separate critique agent when available
  - fall back to a local checklist when not
- file writes require version-protection gates first
- the first line of code requires scriptable blast radius first
- code changes run backend tests by default
- behavior changes require at least one matching observation-driven validation pass
- GUI-capable tasks enter the GUI validation loop by default
- GUI-capable tasks must prepare or refresh `.autodev/current-gui-test.js`
- historical GUI scripts may only serve as supplemental regression
- a GUI use case must become `passed`, `not executable`, `user disabled`, or `manual only` before claiming completion
- create archives only after verification passes

## Current Artifact Pipeline

- `.autodev/current-*` is the compatibility entrypoint for the active flow, not just a filename convention
- the real ownership path is `.autodev/flows/<flow_id>/`
- `.autodev/current-flow.json` is the active-flow registry
- `Resume` treats `.autodev/current-flow.json + current-*` as the default memory-recovery surface

See `references/write-preflight.md` for the full activation matrix.

## `.autodev` Memory and Config

`.autodev/` lives at the repository root and is ignored locally through `.git/info/exclude` by default.

### Workspace Boundaries

- long-lived local memory stays under `.autodev/`
- blast radius reports stay under `.autodev/blast-radius/`
- AI-generated temporary ledgers, debug output, drafts, and diagnostics stay under `.autodev/temp/`
- non-final artifacts must not be written elsewhere in the repository
- if a tool must write temp output elsewhere, delete it or ignore it immediately

### Required Docs

| File | Purpose | Template |
|------|---------|----------|
| `.autodev/context-snapshot.md` | recent task summary | `assets/templates/context-snapshot.md` |
| `.autodev/project-map.md` | project structure map | `assets/templates/project-map.md` |
| `.autodev/module-registry.md` | reusable module registry | `assets/templates/module-registry.md` |
| `.autodev/postmortem.md` | lessons learned | `assets/templates/postmortem.md` |
| `.autodev/path.md` | environment, paths, git, deployment facts | `assets/templates/path.md` |
| `.autodev/autodev-config.json` | skill behavior switches and defaults | `assets/templates/autodev-config.json` |

### Conditional Docs

| File | Purpose | Template | Trigger |
|------|---------|----------|---------|
| `.autodev/current-steps.md` | multi-step execution plan and progress | `assets/templates/current-steps.md` | multi-step work / Step mode |
| `.autodev/current-test.md` | large-test matrix, execution log, residual risk | `assets/templates/current-test.md` | large tests / critical flows / cross-module work |
| `.autodev/current-debug.md` | hypotheses, observations, and follow-up diagnosis | `assets/templates/current-debug.md` | complex debug / repeated diagnosis / regression isolation |
| `.autodev/current-gui-test.js` | current-task GUI entrypoint tied to this change | `assets/templates/current-gui-test.js` | GUI-capable task with automation available |
| `.autodev/current-blast-radius.md` | latest blast radius conclusion and verification scope | `assets/templates/current-blast-radius.md` | before any code / test / config write |

Responsibility split:

- `.autodev/path.md`: environment, deployment, git, and path facts
- `.autodev/autodev-config.json`: skill behavior policy, blast-radius depth, output, and fail-close settings

`path.md` rules are defined in `references/principles/path-system.md`.

## Version Protection and Task Closeout

Version protection is defined in `references/principles/checkpoint-mechanism.md`.

Three layers:

- 🎯 milestones: trusted rollback anchors
- 💿 protection snapshots: pre-write protection
- 💾 archives: step-level validated history

Default order:

```text
scriptable blast radius -> execute change -> immediate verification -> archive -> completion report
```

## Bundled Resources

- `scripts/init-autodev.sh`
  - initialize `.autodev/`, copy templates, fill `autodev-config.json`
- `scripts/checkpoint.sh`
  - branch guard, milestone, snapshot gate, archive, list, rollback
- `scripts/checkpoint-selftest.sh`
  - checkpoint regression selftest
- `scripts/blast-radius.py`
  - scriptable blast radius gate before code changes
- `scripts/blast-radius-step.sh`
  - Step wrapper that parses targets and thresholds from `.autodev/current-steps.md`
- `scripts/blast-radius-selftest.sh`
  - blast radius selftest
- `scripts/blast-radius-step-selftest.sh`
  - step wrapper selftest
- `scripts/release-pack.py`
  - draft an interactive release-testing session from recent commits
- `scripts/release-pack-selftest.sh`
  - selftest for release-pack markdown and JSON outputs
- `references/gotchas.md`
  - high-signal mistakes learned from real work
- `assets/templates/playwright-script-loop.js`
  - script-first Playwright loop template
- `assets/templates/current-gui-test.js`
  - current-task GUI test template
- `assets/templates/current-blast-radius.md`
  - manual fallback template for latest blast radius
- `assets/templates/gui-case-matrix.md`
  - GUI case matrix template
- `assets/templates/gui-evidence-bundle.md`
  - GUI evidence bundle template
- `assets/templates/release-test-pack.md`
  - draft template for interactive release-testing sessions
- `references/shared/menu-contract.md`
  - menu conventions for lightweight guided flows
- `references/shared/flow-snippets.md`
  - shared snippets for receipts, critique, and menus

## Patterns

Patterns are loaded on demand.

- Architect / Refactor / Optimize: check for reusable patterns by default
- Debug: read patterns only when language, platform, or history clearly matters
- FastTrack / Hotfix / Cleanup / Tester: read patterns only when reuse is clearly needed

Read `references/patterns/README.md` before writing or changing a pattern.

## PM Resources and Validation

- `references/pm-guide/task-templates.md`
- `references/pm-guide/common-commands.md`
- `references/pm-guide/conversation-tips.md`
- `assets/templates/verification-checklist.md`

Forbidden areas are defined through `.autodev/forbidden-zones.md`. Stop when one is hit.

## High-Signal Prohibitions

- guessing without verification
- skipping basic checks before debugging
- stacking many edits before any validation
- faking test results or delegating verification responsibility to the user
- deleting existing content while pretending to "add"
- replacing an entire structure to implement a tiny edit
- writing directly on a protected branch

## Output Style

- technical users: technical and concise
- business users: business-facing with plain-language support
- when the user says "just do it" or "no explanation", reduce narration but not verification
- menu-style interaction follows `references/shared/menu-contract.md`
