# Gotchas

> Real mistakes worth remembering. Prefer these over generic programming trivia.

## Preservation and Edit Semantics

- when the user says "add", do not replace the whole file or function
- when the user says "modify X", change X only
- cleanup and refactor work often damages neighboring content; list what must be preserved first

## Git and Checkpoint

- review untracked files before archiving
- after `git add -A`, inspect the index for secrets and local-only files
- a clean worktree does not mean a safe rollback point already exists
- blast radius is more than a grep; check direct callers, reverse chains, neighbor tests, and config signals
- rerun blast radius if the actual edit scope changed
- rollback lists must come from real git state, not memory

## Debug and Validation

- if something "used to work", inspect recent changes first
- passing automated tests does not prove the full chain is correct
- if the target file or symbol is unclear, narrow the blast-radius target before editing
- GUI-capable tasks still need real GUI execution
- large tests must maintain `.autodev/current-test.md`
- failing GUI cases must be rerun after fixes

## Mode Switching

- when FastTrack exceeds 2 files or 30 lines, upgrade instead of forcing it
- Step execution must stay incremental after planning
- Tester and Cleanup are write modes, not read-only modes
