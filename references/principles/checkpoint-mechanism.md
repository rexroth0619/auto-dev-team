# Checkpoint Mechanism

> Create a git checkpoint before every change to ensure rollback is always possible.

## Checkpoint Naming Convention

```
git add -A && git commit -m "SPEC-{type}: {description}"
```

### Type Definitions

| Type | Use Case | Example |
|------|----------|------|
| `Step{N}-before` | Before Step execution | `SPEC-Step2-before: add button component` |
| `Quick` | Before FastTrack execution | `SPEC-Quick: change button color` |
| `Hotfix-before` | Before Hotfix execution | `SPEC-Hotfix-before: fix crash` |
| `Cleanup-before` | Before Cleanup execution | `SPEC-Cleanup-before: remove dead code` |
| `Optimize-before` | Before Optimize execution | `SPEC-Optimize-before: optimize rendering` |
| `Refactor-before` | Before Refactor execution | `SPEC-Refactor-before: extract function` |
| `Complete` | After task completion | `SPEC-Complete: user login feature` |
| `Save` | User-initiated save | `SPEC-Save: user changes` |

## Common Commands

### Create Checkpoint
```bash
git add -A && git commit -m "SPEC-{type}: {description}"
```

### Rollback to Checkpoint
```bash
git reset --hard SPEC-{checkpoint-name}
```

### List All Checkpoints
```bash
git log --oneline | grep SPEC
```

## Git Failure Handling

When a git operation fails:

```
→ "Unsaved changes detected. Commit first?"
→ After user confirms: git commit -m "SPEC-Save: user changes"
```

## Checkpoint Usage Scenarios

### 1. Step Execution

```
Before each step:
git commit -m "SPEC-Step{N}-before: {step description}"

After task completion:
git commit -m "SPEC-Complete: {task name}"
```

### 2. Quick Modifications

```
Before FastTrack execution:
git commit -m "SPEC-Quick: {change description}"
```

### 3. Emergency Fixes

```
Before Hotfix execution:
git commit -m "SPEC-Hotfix-before: {issue description}"
```

### 4. Rollback Operations

```
When user says "rollback" / "undo":
1. List recent checkpoints
2. Confirm rollback target
3. Execute: git reset --hard SPEC-{checkpoint}
4. Report rollback complete
```

## Checkpoint Principles

1. **Always create before changes**: Checkpoint before any code modification
2. **Clear descriptions**: Must recall the change content
3. **Appropriate granularity**: One checkpoint per logical unit
4. **Maintain rollback capability**: Ensure a safe state is always reachable
