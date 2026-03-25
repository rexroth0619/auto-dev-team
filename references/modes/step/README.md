# Step Mode

> Enter after Architect / Refactor / Optimize planning is approved and the user says to start. Required inputs: `current-steps.md`, and `current-test.md` for large tests.

Read before execution:
- `references/principles/incremental-testable.md`
- `references/principles/impact-analysis.md`
- `references/principles/test-verification.md`
- `references/principles/observation-driven-verification.md` when the step changes behavior
- `references/principles/gui-autonomous-loop.md` when the step is GUI-capable

## Highest-Order Rules

Do not:
- run multiple steps in sequence unless trust mode is explicitly enabled
- skip test receipts
- advance without user confirmation
- let a step end without an independently testable deliverable
- stack multiple steps before validation
- claim that the full user journey is done when only the current layer is verified

## Per-Step Flow

1. archive after a validated step
2. pass the snapshot gate before each step
3. announce the current step
4. re-read `current-steps.md` and related ledgers
5. run the blast-radius step gate, preferably with `scripts/blast-radius-step.sh --step {N}`
6. declare edit scope
7. execute the change incrementally
8. run How to Test for the step
9. update ledgers and receipts
10. stop for the user's next choice

## Step Validation

For every behavior-changing step:
- run backend tests first
- run observation-driven validation next
- if GUI-capable and available, run the smallest direct GUI case for the step
- keep `.autodev/current-gui-test.js` aligned with the current step
- do not let historical E2E suites replace the current-step GUI case

## Trust Mode

Trust mode allows continuous step execution, but only after a milestone and with the same validation requirements still enforced.
