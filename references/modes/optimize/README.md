# Optimize Mode (Performance Optimization)

> Applies to: Program too slow, want to optimize performance | Output: Update project-map.md

## AI Must Proactively Read

On entry, AI must read (without user providing):
- `docs/project-map.md` - Project structure
- Target files mentioned by user

## Phase 1: Performance Diagnosis

```
AI:   1. Clarify: What is slow? How slow? Which scenarios?
      
      2. 🔍 Diagnostic checklist (Show Your Work):
         | Type | Check Item | Status | Finding |
         | Compute/Render/Network/Memory | ... | ✅/❌ | ... |
         
      3. Impact scope: 🟢Small / 🟡Medium / 🔴Large
```

### Phase 1 End Options
```
📍 Current: Diagnosis complete, found [N] bottlenecks, primarily [type]
📌 Next:
[1] Confirm - Proceed to plan, prioritize optimizations
[2] More info - If needed: [list missing items]
[3] Switch to debug (enter autoDevTeam/debug workflow) - Functional issue, not performance
[0] Cancel
```

## Phase 2: Optimization Plan

```
AI:   📋 Optimization Plan:
      
      | Priority | Optimization Point | Expected Gain | Risk | Complexity |
      |----------|-------------------|---------------|------|------------|
      | P0 | xxx | 🔥High | 🟢Low | Simple |
      | P1 | xxx | 🔶Medium | 🟡Medium | Medium |
      | P2 | xxx | 🔹Low | 🟢Low | Simple |
      
      ⚠️ Notes:
      - [Potentially affected features]
      - [Scenarios requiring extra testing]
      
      📊 Complexity:
      - Single-point (1 point) → Execute directly
      - Multi-point (2+) → Generate Step plan
```

### Phase 2.9: ⭐ Auto Consultation (Mandatory)

**After outputting plan, must auto-invoke Critique Subagent for review**

```
AI:   1. Generate optimization plan (previous step)
      2. ⭐ Auto-invoke Critique Subagent
         - Pass: [User's optimization concern] + plan, priority, risk assessment
         - Focus: Premature optimization? Simpler approach? Affects functionality?
      3. Subagent two-phase review:
         
         Phase A: Requirement Clarification
         ├── What specific scenario is "slow"? Quantitative data?
         ├── Clear target (how fast is enough)?
         ├── Functionality vs. performance trade-offs to confirm?
         └── ⚠️ Questions remain → Pause, ask user first
         
         Phase B: Plan Review (after clarification passes)
         └── Premature optimization? Simpler approach? Affects functionality?
         
      4. Output consultation report
      5. Output "Original plan + Revised plan (if any)"
      6. Wait for user selection

Output:
━━━━━━━━━━━━━━━━━━━━
🏥 Consultation Report (Critique Subagent)
━━━━━━━━━━━━━━━━━━━━
[Subagent auto-review results]
━━━━━━━━━━━━━━━━━━━━

"Confirm execution? Choose original or revised plan, starting from P0?"
```

**⛔ Do not skip consultation and let user choose execution directly**
**⛔ Do not execute directly after consultation; must wait for user selection**
**⛔ Do not output plan options when optimization target has open questions**

## Phase 3: Execute Optimization

### Single-Point Optimization
```
1. Create checkpoint
2. Execute optimization (log: [OPT-{optimization-point}])
   
   Must include:
   → [OPT-{optimization-point}] Before: xxx ms / computation count
   → [OPT-{optimization-point}] Applied: [strategy]
   → [OPT-{optimization-point}] After: yyy ms / computation count
   
3. How to Test: Compare before/after log data
4. Verify functionality unaffected
5. Clean up [OPT-*] logs (or retain as [BASE-{module-name}] for monitoring)
```

### Multi-Point Optimization → Enter Step Mode (Incremental Testable)
```
Generate Step plan in current_steps.md:

- Each step = one optimization point
- Each step independently verifiable
  ✅ Good: Step 1: Cache API results [Testable: compare request count logs]
  ❌ Bad: Step 1: Prepare cache structure [Cannot verify effect]
  
- Each step uses [OPT-{optimization-point}-Step{N}] log
- Immediate verification after each step:
  → Performance data comparison (via logs)
  → Functionality unaffected (via log flow completeness)
  
Do not batch multiple optimization points for final verification
```

## Common Optimization Patterns

### Compute
- Cache results (memoization)
- Reduce nested loops
- Lazy evaluation
- Batch processing

### Render
- Reduce unnecessary re-renders
- Virtual lists (large datasets)
- Debounce/Throttle
- Async loading

### Network
- Request batching
- Data compression
- Caching strategies
- Pagination/Lazy loading

### Memory
- Timely release of large objects
- Avoid closure traps
- Event listener cleanup

## Verification Method

```
AI:   "Verify optimization results:

      📊 Log Comparison (mandatory):
      Filter `[OPT-{optimization-point}]` for before/after data:
      
      Before: [OPT-{optimization-point}] Before: X ms
      After: [OPT-{optimization-point}] After: Y ms
      
      📏 Performance Comparison:
      | Metric | Before | After | Change |
      |--------|--------|-------|--------|
      | xxx    | ~Xms   | ~Yms  | ⬇️Z%   |
      
      ⚠️ Functional Verification:
      - [ ] Existing functionality works (log flow complete)
      - [ ] No new errors
      
      Report actual results."
```

## Optimization Ineffective Handling

```
If no significant improvement:

AI:   "⚠️ Optimization effect negligible
      
      Possible reasons:
      1. Bottleneck is not here
      2. Measurement method inaccurate
      3. Deeper analysis needed
      
      Suggestions:
      - Roll back: `rollback`
      - Try other points: `continue optimizing`
      - Detailed profiling: Use a profiler tool"
```

## Mode Boundaries

### Boundary with Debug
| Scenario | Which Mode |
|----------|-----------|
| Correct but slow | Optimize |
| Broken (e.g. memory leak crash) | Debug |
| Unclear if perf or bug | Start Optimize, switch to Debug if bug found |

### Boundary with Refactor
| Scenario | Which Mode |
|----------|-----------|
| Restructure for performance | Optimize |
| Restructure for maintainability | Refactor |
| Both needed | Refactor first, then Optimize |

## Mandatory Rules

- Must Show Your Work during diagnosis
- Must define clear target before optimizing; no "while we're at it"
- One optimization point at a time; no mixed changes
- Must verify functionality unaffected after optimization
- Multi-point → must generate Step plan
- Auto-update project-map.md on completion

## Prohibited Behaviors

- ❌ No optimization without a clear target
- ❌ No premature optimization
- ❌ No sacrificing readability for performance (unless necessary and commented)
- ❌ No multiple optimizations at once (hard to assess individual effects)
- ❌ No skipping diagnosis to jump to optimization
- ❌ No committing to specific numbers (use High/Medium/Low qualitative descriptions)
