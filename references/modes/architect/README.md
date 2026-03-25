# Architect Mode

> Use for new features and implementation work. Primary output: `current-steps.md`. Create `current-test.md` when the task qualifies as a large test.

## Must Read

Read these proactively:

- `.autodev/project-map.md`
- `.autodev/module-registry.md`

## Flow

### Phase 0: Requirement Discovery

Ask one question at a time when the request is still vague.

Focus on:
- goal
- user and scenario
- constraints
- completion signal

Do not design before understanding the problem.

### Phase 1: Confirm Requirements and Scenario Pack

Create a behavior pack that includes:
- user-requested scenarios
- AI-added negative and boundary cases
- business-rule scenarios that still need confirmation

If the repository already uses BDD and the scenario fits, plan a `.feature` file.

Mark whether this is a GUI-capable task.

### Phase 2: Feasibility Review

Check:
- available backend test framework
- BDD framework, if any
- GUI executor, if any
- reusable modules from `module-registry`
- module ownership: extend existing module or create a new one
- impact scope with `scripts/blast-radius.py`
- test level: small vs large
- GUI validation needs
- observation-driven validation level
- abstraction opportunity using the three-question rule

### Phase 3: Incremental Plan

Write `current-steps.md` with:
- task marker
- key decisions
- test level
- whether `current-test.md` is needed
- target files for each step
- covered scenarios for each step
- blast-radius targets and thresholds
- backend tests per step
- validation level and observation surfaces per step
- GUI validation notes when relevant

If this is a large test, initialize `.autodev/current-test.md`.

### Phase 3.5: PM Summary

When the user speaks in business language, add a short summary:
- what this change does
- how many steps
- expected file count
- risk level
- test level
- GUI validation status
- rollback readiness

### Critique and Execution

After the plan is produced, run critique as required by `references/principles/critique.md`.

Execution then moves to `references/modes/step/README.md`.

## Small-Change Variant

If the change is truly tiny (<= 2 files and <= 30 lines), drop into FastTrack instead of full planning.

## Mandatory Checks

- warn if a single file keeps growing in scope
- reuse existing components when they fit
- prefer extending an existing module over creating duplicates
- stop and ask when business rules are unclear
