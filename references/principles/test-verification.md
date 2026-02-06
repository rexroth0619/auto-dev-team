# Test Verification Mechanism (Instant Verification)

> Goal: **Verify now** — catch issues quickly, provide evidence.

## Trigger Conditions (Mandatory)

- Any code change (Step / Debug / Hotfix / Refactor / Optimize / Fix / Feat)

## Core Rules

- **Primary Agent verifies directly** (no testing Subagent)
- **Execute immediately**: verify on the spot after writing code
- **Minimum coverage**: core logic + 1 boundary condition
- **Retry on failure**: max 3 times; then request human intervention
- **Evidence required**: command + output/result

## Verification Methods (Prioritize Speed)

1. Run directly in terminal (CLI / curl / node -e / python -c)
2. Temporary script (delete after verification)
3. User manual confirmation (UI/UX/external systems)

## Output Format (Required)

```
🧪 Instant Verification
Method: [command/script/user confirmation]
Result: [pass/fail/unable to execute]
Evidence: [key output or reason]
```

## Prohibited Actions

- ❌ Skip verification and commit directly
- ❌ Conclusions without evidence
