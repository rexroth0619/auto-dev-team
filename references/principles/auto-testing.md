# Automated Testing Workflow

> ⚕️ Goal: **Fast, accurate, reproducible** — primary Agent verifies on the spot.

## Core Principles

- **Verify immediately after every code change**
- **Primary Agent verifies directly** — no testing Subagent
- **Evidence required**: command + output/result
- **Max 3 retries** — then request human intervention

## Layered Verification

1. **Instant Verification (Required)**  
   - Coverage: core logic + 1 boundary condition  
   - Methods: terminal commands / temporary scripts / direct execution
2. **Regression Check (Optional)**  
   - Run before task completion  
   - Only when project already has tests
3. **User Confirmation (When Necessary)**  
   - When UI/UX/external dependencies cannot be auto-verified

## Execution Order

```
Code change complete
→ Impact analysis
→ Instant verification
→ /critique
→ Output
```

## Output Format

```
🧪 Instant Verification
Method: [command/script]
Result: [pass/fail]
Evidence: [key output or error]
```

## Prohibited Actions

- ❌ Skip verification and commit directly
- ❌ Conclusions without evidence
- ❌ Continue progressing despite failure
