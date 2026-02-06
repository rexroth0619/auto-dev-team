# Auto-Consultation Mechanism

> ⚕️ Every plan needs a second opinion — the attending physician reviewing their own work has bias.

## Mechanism

**Problem**: After a new conversation, the AI loses context and may propose over-engineered or band-aid solutions. The primary Agent self-reviewing has confirmation bias. Worse: user requirements themselves may be unreasonable, ambiguous, or incomplete, and the primary Agent tends to execute without questioning.

**Solution**: After every plan, **auto-invoke an independent Critique Subagent** for review. The Subagent reviews both the plan and the user's original requirements.

## Trigger Conditions (Mandatory Auto-trigger)

- After proposing any plan involving code changes (feature, debug, refactor, optimization)

## Execution Flow

```
1. Primary Agent generates plan
2. Auto-invoke Critique Subagent (no user selection needed)
   - Pass: [user's original requirements] + plan content, diagnosis, rationale
   - Do NOT pass: Primary Agent's thought process (avoids bias transfer)
3. Subagent performs two-phase review:
   ┌─────────────────────────────────────────┐
   │ Phase A: Requirements Clarification      │
   │ → Requirements reasonable?              │
   │ → Any ambiguity?                        │
   │ → Missing critical info?                │
   │ → User re-confirmation needed?           │
   │                                         │
   │ ⚠️ If clarification needed, pause       │
   │    immediately and ask the user          │
   └─────────────────────────────────────────┘
   ┌─────────────────────────────────────────┐
   │ Phase B: Plan Review (only after        │
   │          clarification passes)           │
   │ → Root cause, over-engineering,          │
   │   cost audit, side effects               │
   └─────────────────────────────────────────┘
4. Subagent returns consultation report
5. Primary Agent presents report to user
6. Primary Agent outputs:
   - Original plan (unrevised)
   - Revised plan based on feedback (if any)
7. **Wait for user selection** (original / revised / cancel)
```

## Output Format

### Case 1: Requirements Need Clarification (Phase A Issues)

```
━━━━━━━━━━━━━━━━━━━━
⏸️ Consultation Paused — Requirements Pending Clarification
━━━━━━━━━━━━━━━━━━━━
Critique Subagent found issues during requirements review:

❓ Pending Clarification:
1. [specific question 1 — needs user response]
2. [specific question 2 — needs user response]

💡 Suggestions:
[alternatives or risk warnings, if any]

━━━━━━━━━━━━━━━━━━━━
📌 Please answer the above questions before proceeding
━━━━━━━━━━━━━━━━━━━━
```

**⛔ Do NOT output plan options here; wait for user clarification then regenerate the plan**

### Case 2: Requirements Clear, Plan Review Passed

```
━━━━━━━━━━━━━━━━━━━━
📋 Original Plan (Unrevised)
━━━━━━━━━━━━━━━━━━━━
[original plan content]

━━━━━━━━━━━━━━━━━━━━
🏥 Consultation Report (Critique Subagent)
━━━━━━━━━━━━━━━━━━━━
✅ Requirements Clarification: Requirements are clear, no ambiguity
[plan review results]

━━━━━━━━━━━━━━━━━━━━
🛠️ Revised Plan (If Any)
━━━━━━━━━━━━━━━━━━━━
[revised version based on consultation]

━━━━━━━━━━━━━━━━━━━━
📌 Next steps:
[1] Execute original plan
[2] Execute revised plan
[0] Cancel
━━━━━━━━━━━━━━━━━━━━
```

## Critique Subagent Review Checklist

### Phase A: Requirements Clarification (Execute First — Pause If Issues Found)

| Check Item | What to Check | Action on Issues |
|--------|----------|------------------|
| 🤔 Reasonableness | Is the request reasonable? Better approach available? | Suggest alternatives |
| ❓ Ambiguity | Multiple interpretations possible? | List ambiguities, request clarification |
| 📋 Completeness | Missing critical info (boundaries, priorities, constraints)? | List gaps, request supplementation |
| 🎯 Goal Clarity | Real problem? Surface vs. actual needs? | Probe true intent |
| ⚠️ Risk Warning | User aware of potential risks/costs? | Highlight risks, request confirmation |

**⛔ Any Phase A issues → must pause, clarify with user first; do NOT proceed to Phase B**

### Phase B: Plan Review (After Requirements Clarification Passes)

| Check Item | What to Check |
|--------|----------|
| 🔬 Root Cause | Confirmed or guessing? Basic checks performed? |
| 🎯 Over-Engineering | Anything the PM didn't ask for? |
| 💰 Cost Audit | Free alternatives available? Root cause confirmed before spending? |
| ⚡ Side Effects | New problems introduced? Reversible? |
| 🛡️ Preservation | Did "add" become "replace"? Sibling/nested elements accidentally deleted? |
| 🔗 Correlation | Symmetric operations missed? (Changed encoding — did decoding change?) Full flow checked? |
| 📐 Inheritance | Changed base class/interface — subclasses/implementations need syncing? |

## Subagent Location

| Location | Path | Purpose |
|------|------|------|
| Project-level | `.cursor/agents/critique.md` | Follows git; includes project context |
| User-level | `~/.cursor/agents/critique.md` | Follows machine; universal version |

Prefer project-level — it understands the project's business context.

## ⛔ Prohibited Actions

- Primary Agent self-reviewing by switching roles (has bias)
- Skipping consultation and executing directly
- Passing Primary Agent's thought process during consultation
- **Starting plan review when requirements are ambiguous** (must clarify first)
- **Outputting plan options after finding clarification issues** (must wait for user response)

## Flexibility Principle

The Critique Subagent must:
1. Read `docs/context-snapshot.md` to understand business context first
2. Accept that "convoluted" approaches are sometimes business necessities
3. Accept plans with reasonable justification
4. Aid decision-making, not block execution

## Clarification Judgment Criteria

**Clarification needed**:
- User says "build an XX feature" without specifying requirements
- Multiple approaches exist, choice impacts downstream work
- User describes symptoms, root cause unclear
- Requested change may have side effects user is unaware of
- Requirements involve sensitive operations (deleting data, modifying permissions, affecting production)

**Clarification not needed**:
- Requirements are sufficiently specific and clear
- User explicitly says "don't ask me, just do it"
- Details can be reasonably inferred and adjusted during review
- Clarification value is far less than just executing and iterating
