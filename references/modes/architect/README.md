# Architect Mode (New Feature Development)

> Applies to: New feature or requirement | Output: current_steps.md

## AI Must Proactively Read

On entry, AI must read (without user providing):
- `docs/project-map.md` - Project structure
- `docs/module-registry.md` - Reusable components

## Workflow

### Phase 1: Requirement Confirmation
```
User: [Describes requirement]

AI:   0. Read project-map.md and module-registry.md
      1. Restate requirement (concise)
      2. "Does this look correct?"
      
User: Confirm / Supplement
```

### Phase 2: Feasibility Assessment
```
AI:   1. Search module-registry: "Search [keyword]: found xxx / not found"
      
      2. Impact scope: 🟢Small / 🟡Medium / 🔴Large
         
         ⭐ Consumer check (mandatory for addresses/paths/configs/data formats):
         ├── Producer: Who generates this data? → [Current change point]
         ├── Consumer: Who consumes this data? → [List all consumers]
         └── Compatibility: Can all consumers handle the new format?
         
         ⚠️ Internal/External network scenarios:
         - What if an internal address is exposed externally?
         - Can address replacement/transformation cover the new format?
      
      3. Edge cases: Invalid input? Concurrency? Empty/Large data?
      
      4. 🔷 Abstraction potential (Rule of Three):
         - 🟢 Recommend → Add "design generic interface" to plan
         - 🟡 Potential → Flag for observation
         - 🔴 Do not abstract
      
      5. Verdict: 💗Better approach exists / ⚠️Risks identified / ✅Feasible
```

### Phase 3: Generate Plan (Incremental Testable Breakdown)
```
AI:   1. Assess complexity:
         - [Trivial] 1 step → One-shot implementation
         - [Simple] 2-3 steps
         - [Medium] 4-5 steps
         - [Complex] >5 steps → Suggest splitting requirements
      
      2. Breakdown principles (critical):
         ⚠️ Each step must produce an independently verifiable module
         
         ✅ Good breakdown example:
         - Step 1: Implement data transformation function [Testable: input→output verification]
         - Step 2: Implement API call wrapper [Testable: mock data verification]
         - Step 3: Integrate into UI component [Testable: UI rendering verification]
         
         ❌ Bad breakdown example:
         - Step 1: Define types [Cannot verify independently]
         - Step 2: Write half the logic [Incomplete, cannot verify]
         - Step 3: Complete logic and test [Deferred to the end]
         
         Correct approach:
         - Each step = cohesive, independently runnable module
         - Each step has clear inputs, outputs, and verification method
      
      3. Output plan (each step: title + files + testable output)
         Format: Step N: [What to do] [Testable output: xxx]
      
      4. Write to current_steps.md:
         - Log identifier: [DEV-{task-topic}]
         - Key decisions
         - Testable output per step
      
      5. "Planning ready. Waiting for ❇️"
      
Reminder: Use [DEV-{topic}-Step{N}] log per step
Each step must be independently verifiable; do not defer verification
```

### Phase 3.5: PM Summary (Adaptive)

**Trigger**: User describes requirements in business language

```
📋 Plan Summary

What: [One-sentence business description]
Steps: N steps
Estimated changes: X files
Risk level: 🟢Low / 🟡Medium / 🔴High
Reversible: ✅ Can be rolled back at any time

Step overview:
1. [Business description of step 1]
2. [Business description of step 2]
...
```

**Skip**: User uses technical language, or says "no need to explain"

## Small Change Variant

Change ≤2 files, ≤30 lines → Skip planning, auto-switch to FastTrack mode

## Mandatory Checks

- File >300 lines → Add split step to plan
- Reusable component found → Must reuse, do not create new
- Documentation missing → Inform user, suggest Survey first

## Mode Switch

Extensive refactoring needed → "Suggest Refactor mode for xxx first, then return to feature development"

## Phase End Options

### Phase 1 End
```
📍 Current: Requirement understood as "[restated requirement]"
📌 Next:
[1] Confirm - Proceed to feasibility assessment
[2] Supplement - If needed: [list missing items]
[0] Cancel
```

### Phase 3.9: ⭐ Auto Consultation (Mandatory)

**After outputting the plan, must auto-invoke Critique Subagent for independent review**

```
AI:   1. Generate plan (previous step)
      2. ⭐ Auto-invoke Critique Subagent
         - Pass: [User's original requirement] + plan, impact scope, key decisions
         - Do not pass: AI's reasoning process
      3. Subagent two-phase review:
         
         Phase A: Requirement Clarification
         ├── Is the requirement reasonable? Better approach?
         ├── Ambiguous? Critical info missing?
         └── ⚠️ Issues found → Pause, output questions, wait for user
         
         Phase B: Plan Review (after clarification passes)
         └── Root cause validation, over-engineering, cost audit, side effects
         
      4. Based on results:
         - Clarification needed → Output questions, regenerate after user responds
         - No clarification needed → Output report + original/revised plan
      5. Wait for user selection
```

**⛔ Do not skip consultation and let user choose execution directly**
**⛔ Do not execute directly after consultation; must wait for user selection**
**⛔ Do not output plan options when requirement has clarification questions**

### Phase 3 End
```
📍 Current: Plan generated, N steps, estimated X file changes

━━━━━━━━━━━━━━━━━━━━
🏥 Consultation Report (Critique Subagent)
━━━━━━━━━━━━━━━━━━━━
[Subagent auto-review results]
━━━━━━━━━━━━━━━━━━━━

📌 Next:
[1] Execute original plan (enter autoDevTeam/step workflow) - Step-by-step, confirm each
[2] Execute revised plan (enter autoDevTeam/step workflow) - Step-by-step, confirm each
[3] Trust mode (enter autoDevTeam/step workflow) - Continuous execution, report on completion
[0] Cancel
```

## Phase 4: Step Execution & Instant Verification

⚠️ **Must read** `references/principles/auto-testing.md` for complete workflow

### Step Mode (Step-by-Step Confirmation)

After each Step completes:

```
Step N Complete
    ↓
1. Impact scope analysis (see references/principles/impact-analysis.md)
    ↓
2. Instant verification (Main Agent, see references/principles/test-verification.md)
    ↓
3. Output to PM
```

**Step Completion Output**:
```
━━━━━━━━━━━━━━━━━━━━
✅ Step N Complete: [Step description]
━━━━━━━━━━━━━━━━━━━━

🎯 Impact scope: [Module list]

🧪 Instant verification:
Method: [Command/Script]
Result: [Pass/Fail]
Evidence: [Key output]

📌 Next:
[1] Continue Step N+1
[0] Pause
━━━━━━━━━━━━━━━━━━━━
```

### Trust Mode (Continuous Execution)

Instant verification per step, regression at task end (if tests exist):

```
Execute Step 1 → Step 2 → ... → Step N
    ↓
Instant verification after each step
    ↓
Run regression before completion (if project has tests)
    ↓
Output to PM
```

**Trust Mode Completion Output**:
```
━━━━━━━━━━━━━━━━━━━━
✅ [Feature name] Development Complete
━━━━━━━━━━━━━━━━━━━━

📊 Execution Summary:
├── Completed: N steps
├── Changed: X files
└── Instant verification: N/N passed

🔄 Regression: [Ran/Not ran] [Result]
━━━━━━━━━━━━━━━━━━━━
```

### Test Failure Handling

```
Test failure (still failing after 3 retries):

━━━━━━━━━━━━━━━━━━━━
⚠️ Test failure, manual intervention required
━━━━━━━━━━━━━━━━━━━━

❌ Persistent failures:
| Test | Reason |
|------|--------|
| [Test name] | [Failure reason] |

🔍 Root cause analysis:
[Analysis description]

📌 Options:
[1] View detailed error logs
[2] I'll fix it, retry after fix
[3] Skip this test and continue (not recommended)
[0] Abort task
━━━━━━━━━━━━━━━━━━━━
```
