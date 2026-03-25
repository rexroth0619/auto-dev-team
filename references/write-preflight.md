# Shared Write Preflight

> Every workflow that writes files, changes config, generates tests, or archives state starts here. Strict behavior is the default; detailed switches may be adjusted through `.autodev/autodev-config.json`.

## Contents

- Applicable Modes
- Shared Preflight Steps
- Test Ledger Rules
- Principle Activation Matrix
- Observation-Driven Validation Rules
- GUI Validation Loop Rules
- Patterns on Demand
- Completion Actions
- Prohibitions

## Applicable Modes

- Architect
- FastTrack
- Debug
- Refactor
- Optimize
- Hotfix
- Cleanup
- Tester
- Step

`Survey` and `Explain` are read-only by default and do not enter this flow.

## Shared Preflight Steps

1. Initialize `.autodev/`.
   - Prefer `scripts/init-autodev.sh`
   - If unavailable, copy required templates manually from `assets/templates/`
   - `.autodev/autodev-config.json` is mandatory
   - ensure `.autodev/temp/` exists for temporary AI output
2. Check workspace boundaries.
   - temporary ledgers, debug output, drafts, and diagnostics must stay under `.autodev/temp/`
   - if temporary AI files exist elsewhere, move them, delete them, or ignore them first
3. Read `.autodev/context-snapshot.md`.
4. Read `.autodev/autodev-config.json`.
5. If the task touches git, deployment, paths, environments, service config, runtime paths, log paths, or console entrypoints, read `.autodev/path.md` first.
6. Read the most relevant parts of `references/gotchas.md`.
7. Run `git log -5 --oneline` and check for recent conflicts or related work.
8. Run branch guard.
   - prefer `scripts/checkpoint.sh ensure-branch <task-slug>`
   - otherwise follow `references/principles/checkpoint-mechanism.md`
9. Create a milestone baseline.
   - prefer `scripts/checkpoint.sh milestone "<task>#start" "task baseline" <task-slug>`
10. Register the pre-write snapshot gate.
   - prefer `scripts/checkpoint.sh snapshot-gate <task>`
11. Register the blast-radius gate.
   - prefer `scripts/blast-radius.py ... --write`
   - output must land in `.autodev/current-blast-radius.md` and `.autodev/blast-radius/*.md`
12. Run the anti-spaghetti quick check.
   - decide whether new code should extend an existing module or create a new one
   - check for reusable implementations first
   - check abstraction opportunity first; do not force abstraction at 1-2 uses; require it after repeated proven reuse
   - if a file is already accumulating too many responsibilities, split or upgrade mode before adding more

## Test Ledger Rules

- `.autodev/current-steps.md`: multi-step plan, covered scenarios, and step receipts
- `.autodev/current-test.md`: large-test matrix, execution log, business questions, residual risk, observation conclusions
- `.autodev/current-debug.md`: multi-round debug hypotheses, observation differences, fixes, and re-checks
- `.autodev/current-gui-test.js`: current-task GUI entrypoint tied directly to this change
- `.autodev/current-blast-radius.md`: latest blast-radius result; refresh it before any code / test / config write

Treat the task as a **large test** when any of these are true:

- auth, payment, permissions, approval, upload/download
- multi-step forms, multi-page navigation, session state, core user flows
- external integrations, API / data contract changes, cross-module work
- unclear business rules that require scenario clarification

If not large-test, `current-test.md` is optional, but a `🧾` test receipt is still required.

## Principle Activation Matrix

| Trigger | Must read |
|---------|-----------|
| every write mode | `references/principles/critique.md` |
| git / deployment / path / environment work | `references/principles/path-system.md` |
| before any code or config write | `references/principles/checkpoint-mechanism.md` |
| before the first line of code | `references/principles/impact-analysis.md` |
| when actual code execution starts | `references/principles/test-verification.md` |
| before validating behavior-changing code/config | `references/principles/observation-driven-verification.md` |
| GUI-capable task | `references/principles/gui-autonomous-loop.md` |
| entering Step execution | `references/principles/incremental-testable.md` |
| editing `.feature` or step definitions | `references/principles/bdd-testing.md` |
| abstraction / shared utility / common interface work | `references/principles/abstraction-rules.md` |
| writing a pattern | `references/patterns/README.md` |

## Observation-Driven Validation Rules

- Architect: every step must declare validation level and observation surfaces
- Step / FastTrack / Hotfix / Tester: behavior changes default to at least `L1`
- Debug: default `L2`, escalate to `L3` for complex problems
- Refactor: default `L3` with before/after baseline
- Regression isolation: default `L3`

## GUI Validation Loop Rules

- every GUI-capable task enters the GUI validation loop by default
- Web defaults to Playwright; other GUI tasks use the best available executor
- GUI-capable tasks must initialize or refresh `.autodev/current-gui-test.js`
- historical business E2E scripts may not replace the current-task GUI validation entrypoint
- Web GUI should run headed unless the user explicitly allows headless or the environment cannot display a browser
- GUI work cannot be marked complete until the case is passed, not executable, or explicitly disabled
- failed GUI cases enter a capture -> fix -> rerun loop, default max 3 rounds
- GUI fallback must produce a developer hand-test guide

## Patterns on Demand

- Architect / Refactor / Optimize: check reusable patterns by default
- Debug: load patterns only when clearly relevant
- FastTrack / Hotfix / Cleanup / Tester: load patterns only for explicit reuse needs

## Completion Actions

1. run scriptable blast radius and refresh the validation scope
2. run backend testing and matching observation-driven validation
3. if GUI-capable, continue through the GUI validation loop and retain evidence
4. create an archive and output:

```text
💾 Archive {task}#{index} -> {hash}
```

5. when a meaningful checkpoint is reached, ask whether to merge and push

## Prohibitions

- writing code without shared preflight
- touching git / deployment / server paths without reading `path.md`
- skipping the blast-radius gate
- archiving before validation
- treating observation-driven validation as "only after tests fail"
- skipping `current-test.md` on a large test
- treating `Cleanup` or `Tester` as read-only
- skipping `.autodev/current-gui-test.js` on GUI-capable work
- using historical GUI scripts instead of a current-task GUI validation entrypoint
