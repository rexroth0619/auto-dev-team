# Instant Verification Protocol

> Goal: **Fast, clear, reproducible**.

## Required Checklist

1. Core logic: primary functionality of this change
2. Boundary condition: at least 1 edge-case input
3. Callers: verify at least 1 obvious caller if applicable

## Method Selection

- Run directly in terminal (preferred)
- Temporary script (delete after verification)
- Cannot auto-verify → provide explicit manual steps to user

## Pass Criteria

- Must have expected values
- Must compare against actual output
- "No errors" alone is insufficient

## Failure Handling

1. Suspect code first, then check verification logic
2. Fix and retry, max 3 times
3. Still failing → request human intervention

# Instant Verification Protocol (Primary Agent)

> Goal: In current context, quickly prove "the change works and hasn't broken critical paths."

## Required Verification Points

1. Core logic (primary functionality of this change)
2. At least 1 boundary condition (null/extreme/abnormal input)
3. If direct callers exist, verify at least 1

## Verification Method Selection (Prioritize Speed)

- Pure functions/utilities: `node -e` / `python - <<'PY'`
- APIs: `curl` / temporary request scripts
- Files/config: directly read or inspect output files
- UI/UX: provide explicit manual verification steps

## Temporary Code Rules

- Prefer **one-liner commands** for verification
- When script needed: use `.tmp-verify.*`, delete after
- Never leave verification code in production files

## Failure Handling (Max 3 Retries)

1. Assume code issue first → fix → retry
2. Then check verification logic
3. Third failure → stop, request user intervention

## Output Format

```
🧪 Instant Verification: [pass/fail]
Evidence: [command/output summary]
```
