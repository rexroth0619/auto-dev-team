# FastTrack Mode (Quick Change)

> Applies to: Copy changes, style tweaks, minor fixes | Limit: ≤2 files, ≤30 lines | Auto-escalates to Architect if exceeded

## Applicable Scenarios

- Copy/text changes
- Style adjustments
- Minor bug fixes
- Single-point changes

## Workflow

### 0. Create Checkpoint

### 1. Scope Check
```
AI:   📍 Scope check:
      - Files involved: ≤2 ✅ / >2 ❌
      - Code changes: ≤30 lines ✅ / >30 lines ❌
      
      ✅ Scope OK → Execute directly
      ❌ Exceeds scope → "Too large, recommend full development workflow"
```

### 1.5 Quick Plan + Consultation (Mandatory)

```
AI:   1. Output quick plan (original)
      2. ⭐ Auto-invoke Critique Subagent
         - Pass: [User's request] + quick plan
      3. Subagent quick two-phase review:
         
         Phase A: Requirement Clarification (quick)
         ├── Is the request clear?
         └── ⚠️ Ambiguous → Quick follow-up (1 question)
         
         Phase B: Plan Review
         └── Truly minor? Plan correct?
         
      4. Output consultation report + revised plan (if any)
      5. Wait for user selection
```

**⛔ Do not execute directly after consultation; must wait for user selection**
**⛔ FastTrack clarification: 1 question max**

### 1.9 Preservation Quick Check (Mandatory)

Confirm before execution:

```
AI:   📋 Preservation check:
      - Operation type: Add / Modify / Delete
      - Target: [filename/structure name]
      - Existing elements: [N items]
      - Preserved this time: All ✅ / Partial [list deleted items]
      
      ⛔ If operation is "Add", "deleted items" must be empty
```

### 2. Direct Execution
```
AI:   1. Execute change (log: [SHORT-{topic}])
      2. Output change summary
      3. How to Test (simplified)
```

### 3. How to Test (Simplified)
```
🈶 Verification:
- Filter `[SHORT-{topic}]` should show: [key log output]
- Perform [xxx]: [expected result]
```

### 4. Completion Cleanup
```
After change takes effect, clean up [SHORT-*] logs
```

## Auto-Escalation Conditions

Auto-escalate to Architect mode when:
- Involves >2 files
- Requires new files
- Involves interface changes
- May impact other modules

## Circuit Breaker

```
During execution if discovered:
- Changes keep growing → Stop immediately
- Impact exceeds expectations → Stop immediately
- Report: "Scope too large, recommend full development workflow"
```

## Execution Completion Options

```
📍 Current: Completed "[change summary]", changed [N] files
📌 Next:
[1] Continue minor changes (continue autoDevTeam/fasttrack workflow)
[2] Develop new feature (enter autoDevTeam/architect workflow)
[3] Clean up code (enter autoDevTeam/cleanup workflow)
[0] Done
```

## Scope Exceeded Options

```
📍 Current: Scope too large (involves [N] files / [reason])
📌 Next:
[1] Full workflow (enter autoDevTeam/architect workflow) - Feasibility assessment first
[2] Narrow scope - Do only part: [list splittable sub-tasks]
[0] Cancel
```
