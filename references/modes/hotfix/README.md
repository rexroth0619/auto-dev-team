# Hotfix Mode

> Use for urgent production stabilization. The goal is service recovery with the smallest safe change.

## Rules

- minimize scope aggressively
- fix the confirmed cause, not a guess
- keep rollback ready at all times
- if the fix starts expanding, stop and re-plan

## Flow

1. capture the production symptom and blast radius
2. identify the most likely recent trigger
3. define the smallest safe fix
4. run critique in hotfix form
5. pass snapshot and blast-radius gates
6. apply the fix
7. run targeted backend validation
8. run GUI validation when applicable
9. archive and report the residual risk
