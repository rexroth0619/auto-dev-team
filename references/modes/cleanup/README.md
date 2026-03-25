# Cleanup Mode

> Use for dead code, redundant logic, and low-risk cleanup work.

## Flow

1. identify the deletion target
2. confirm direct callers and reverse references with blast radius
3. verify whether anything still depends on it
4. run critique on scope and safety
5. pass snapshot and blast-radius gates
6. delete or simplify
7. run targeted regression checks
8. archive the change

## Rules

- never treat Cleanup as read-only
- do not delete an enclosing structure when only one item should be removed
- if the cleanup starts changing behavior, escalate to Refactor or Architect
