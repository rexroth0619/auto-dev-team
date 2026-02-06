# Refactor Mode (Code Refactoring)

> Applies to: Messy code, reorganize, refactor | Output: current_steps.md

## AI Must Proactively Read

On entry, AI must read (without user providing):
- `docs/project-map.md` - Project structure
- Target files mentioned by user

## Workflow

### Phase 1: Code Smell Identification
```
User: [Describes refactoring goal]

AI:   0. Read project-map.md and target files

AI:   Analyze and output:
      
      🔍 Code Smells:
      - [ ] File too long (>300 lines)
      - [ ] Function too long (>50 lines)
      - [ ] Mixed responsibilities
      - [ ] Duplicate code → Consider abstraction
      - [ ] Unclear naming
      
      🔷 Abstraction Opportunities (if applicable):
      - [ ] Abstractable neutral logic found
      - [ ] Same pattern appears 3+ times
      
      If goal is "abstraction extraction":
      → Evaluate with Rule of Three:
         Q1: Neutral or business-specific?
         Q2: Will other scenarios use it?
         Q3: Is the API simpler after abstraction?
```

### Phase 2: Impact Scope Analysis
```
AI:   1. Scan direct call sites → List file | line | scenario | risk
      2. Check indirect impact (2nd-level dependencies)
      3. Impact assessment: 🟢Small / 🟡Medium / 🔴Large
      
      "Impact scope: [Large/Medium/Small], confirm to proceed?"
```

### Phase 3: Plan Design
```
AI:   📋 Refactoring Plan:
      1. [Specific change]
      2. [Specific change]
      
      🛡️ Backward Compatibility:
      - [How to ensure existing callers unbroken]
      
      ✅ Regression Checklist:
      1. [Verification point 1]
      2. [Verification point 2]
      
      "Confirm plan?"
```

### Phase 4: Incremental Execution (Incremental Testable)
```
AI:   Generate Step plan, write to current_steps.md:
      
      ## Key Decisions (prevent forgetting)
      - **Backward compatibility**: [Strategy]
      - **Regression test points**: [What to verify per step]
      - **Log identifier**: [REFACTOR-{target}]
      
      Execution requirements:
      - Each step modifies only one module
      - Each step keeps system runnable (incremental refactoring)
      - Each step inserts [REFACTOR-{target}-Step{N}] log for equivalence
      - Immediate regression verification after each step (compare via logs)
        ⚠️ Prohibited: "Step 1: Extract function, Step 2: Test" → Should be "Step 1: Extract function and verify equivalence"
      - Testable output per step: Pre/post log output must be identical
      - Last step cleans up [REFACTOR-*] logs
      - Auto-update project-map.md on completion
        Output: "📝 Auto-updated: project-map.md - [Module change summary]"
```

## Mandatory Rules

- Must output call site list
- Must explain backward compatibility strategy
- Must list regression test points
- High-risk call sites require user re-confirmation
- Must update module-registry.md after abstraction extraction

## Abstraction Extraction Refactoring (Special Type)

```
When goal is "abstraction extraction":

1. Identify all duplication points
2. Design unified API (Rule of Three)
3. Extract to independent file/module
4. Replace all call sites
5. Update documentation:
   - module-registry.md (add new Utility)
   - project-map.md (annotate new generic capability)

Output: "📝 Auto-updated: module-registry.md - Added [Utility name]"
```

## Equivalence Verification

```
After refactoring, verify via log comparison:
1. Existing behavior completely unchanged
   → Compare pre/post log output for consistency
2. Existing call patterns still work
   → [REFACTOR-{target}] log shows all call paths healthy
3. No new side effects
   → No unexpected additional operations in logs
```

## Mode Switch

New functionality needed for refactoring → "Suggest pausing, implement xxx first, then continue refactoring"

## Phase End Options

### Phase 2 End
```
📍 Current: Impact analysis complete, affects [N] files, risk [🟢/🟡/🔴]
📌 Next:
[1] Confirm - Proceed to plan design
[2] Narrow scope - Reduce files involved
[3] Details - View specific call sites and risk breakdown
[0] Cancel
```

### Phase 3.9: ⭐ Auto Consultation (Mandatory)

**After outputting plan, must auto-invoke Critique Subagent for review**

```
AI:   1. Generate refactoring plan (previous step)
      2. ⭐ Auto-invoke Critique Subagent
         - Pass: [User's refactoring goal] + plan, impact scope, backward compatibility
         - Focus: Simplest approach? Scope too large? Safer way?
      3. Subagent two-phase review:
         
         Phase A: Requirement Clarification
         ├── Refactoring goal clear?
         ├── Scope needs further confirmation?
         ├── Implicit business constraints not stated?
         └── ⚠️ Questions remain → Pause, ask user first
         
         Phase B: Plan Review (after clarification passes)
         └── Simplest approach? Scope too large? Safer way?
         
      4. Output consultation report
      5. Output "Original plan + Revised plan (if any)"
      6. Wait for user selection
```

**⛔ Do not skip consultation and let user choose execution directly**
**⛔ Do not execute directly after consultation; must wait for user selection**
**⛔ Do not output plan options when refactoring goal has open questions**

### Phase 3 End
```
📍 Current: Plan finalized, [N] steps, backward compatibility: [strategy summary]

━━━━━━━━━━━━━━━━━━━━
🏥 Consultation Report (Critique Subagent)
━━━━━━━━━━━━━━━━━━━━
[Subagent auto-review results]
━━━━━━━━━━━━━━━━━━━━

📌 Next:
[1] Execute original plan (enter autoDevTeam/step workflow) - Step-by-step, verify regression each step
[2] Execute revised plan (enter autoDevTeam/step workflow) - Step-by-step, verify regression each step
[3] Trust mode (enter autoDevTeam/step workflow) - Continuous execution, unified verification on completion
[0] Cancel
```
