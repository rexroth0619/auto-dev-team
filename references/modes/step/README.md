# Step Mode (Step Execution)

> When to enter: After Architect/Refactor/Optimize generates a plan and user says "start" | Must read: current_steps.md

## Supreme Directives

```
⛔ Do not execute multiple steps consecutively (unless trust mode)
⛔ Do not skip How to Test
⛔ Do not proceed to next step without user confirmation
⛔ Each step must produce an independently verifiable module + log (incrementally testable)
⛔ Do not accumulate changes across steps for deferred verification
```

## Per-Step Workflow

### 0. Create Checkpoint

### 1. Start Declaration
```
"Now implementing: **Step X/Total: xxx**"

Example: "Now implementing: **Step 2/5: Add button component**"
```

### 2. Context Confirmation (Mandatory)
- **Must read** current_steps.md:
  - Current step
  - **Key decisions**: What to reuse, impact scope, edge handling
- Plan conflicts with current context → Stop and ask user
- Brief summary: Previous step → This step → Goal

### 3. Change Declaration
```
📋 Change scope:
- Files: [list]
- Functions: [list]
```

### 4. Execute Changes (Incremental Testable)
- **Reuse check**: Before new code, ask "Anything in module-registry I can use?"
- **Incremental testable**: Step must produce independently verifiable module/function/component
  - ✅ Good: "Implement data transformation function + unit test"
  - ❌ Bad: "Prepare data structures" (cannot verify)
  - ❌ Bad: "Write half the logic, complete next step" (incomplete)
- **Testable criteria**: Module correctness verifiable via log or behavior after step
- Guideline: ≤2 files, new code ≤50 lines per step
- Exceeding limits: Explain reason, wait for confirmation
- Log fingerprint: `[DEV-{topic}-Step{N}]`

### 5. How to Test (Smart Verification) ⛔ MANDATORY

```
⛔⛔⛔ RED LINE: DO NOT FAKE TEST RESULTS ⛔⛔⛔

AI MUST:
1. Actually execute test commands (not "pretend to execute")
2. Show actual command output (not self-fabricated)
3. Report results honestly (no fabrication)

Violation = Medical malpractice level error
```

**⚠️ Key**: This step's changes must be independently verifiable, not depending on later steps

**Step 5.1: Auto-assess verification method (Mandatory)**

⚠️ **Must read** `references/principles/test-verification.md` for complete assessment rules

AI must auto-assess this step's complexity:

```
📊 Complexity Assessment:
- Change size: [N files, M lines]
- Function type: [copy/style/single module logic/core flow/...]
- Impact scope: [single point/single module/cross-module/...]
- Assessment result: 🟢 Simple / 🟡 Medium / 🔴 Complex
```

**Step 5.2: Execute verification (based on assessment)**

#### 🟢 Simple Change → Instant Verification

```
🧪 Instant Verification

Method: [terminal command/temp script]
Command: [actual command executed]
Result: [pass/fail]
Evidence:
┌────────────────────────────────────────────────────
│ [Paste actual output]
└────────────────────────────────────────────────────
```

#### 🟡 Medium Change → User Choice

```
📊 Complexity Assessment: 🟡 Medium Change
- Change size: [N files, M lines]
- Function type: [single module logic]
- Impact scope: [single module]

📌 Choose verification method:
[1] Instant verification - terminal command/temp script (fast)
[2] Cucumber verification - run BDD scenarios (comprehensive)

⏸️ Please choose verification method...
```

#### 🔴 Complex Change → Cucumber Verification (Mandatory)

```
📊 Complexity Assessment: 🔴 Complex Change
- Change size: [N files, M lines]
- Function type: [core flow/API change]
- Impact scope: [cross-module/external API]
- Verification method: Cucumber verification (required)

🧪 BDD Verification - Actual Execution

📂 Command: npx cucumber-js features/xxx.feature
📤 Actual Output:
┌────────────────────────────────────────────────────
│ [Paste actual terminal output, including pass/fail info]
│ 
│ 3 scenarios (3 passed)
│ 9 steps (9 passed)
│ 0m0.123s
└────────────────────────────────────────────────────

📊 Results:
  ✅ Scenario: [name] → passed (from actual output)
  ✅ Scenario: [name] → passed (from actual output)
  👀 Scenario: [name] → @manual, needs manual confirmation
```

**Step 5.3: Handle @manual scenarios (if applicable)**

```
**Manual verification items (@manual scenarios):**
- [Specific steps - UI/visual/external systems]
```

**Step 5.4: Result handling**

- ✅ Verification passed → Continue to next step
- ❌ Verification failed → Fix and retry (max 3 times)
- ⚠️ Command failed → Check environment, report to user

**⛔ Absolute Prohibitions**

```
❌ DO NOT skip complexity assessment
❌ DO NOT use instant verification for 🔴 complex changes
❌ DO NOT claim "passed" without executing commands
❌ DO NOT fabricate test output
❌ DO NOT skip testing and say "Ready for QA Testing"
```

**❌ If cannot execute test commands:**

```
Case 1: No BDD framework
→ Use instant verification (terminal command/temp script)
→ 💡 Tip: Complex projects should consider configuring BDD framework

Case 2: Step definitions not implemented (BDD framework exists)
→ Implement step definitions first
→ Execute tests after implementation

Case 3: Environment issues
→ Report error message honestly
→ Request user assistance
```

### 6. End (Mandatory Wait)
```
--- Step X/Total Complete ---

✅ Updated current_steps.md
⏸️ Waiting for confirmation...

Reply:
- "ok" / "confirm" / "continue" → Next step
- "issue" / "rollback" → I'll handle it
```
Update current_steps.md: 🌀 → ✅

### 7. Absolute Prohibition - Must Wait for User
```
⛔ Must stop and wait for user reply after Step ends
⛔ Do not self-assess "should be fine" and continue
⛔ Even if code is trivial, must wait for confirmation
```

## Trust Mode

When user says "trust mode": continuous execution allowed, but checkpoints per step; stop immediately on issues.

## Last Step Special Workflow

```
"🧹 Clean up temporary logs?"

[1] Clean up - Remove all [DEV-{topic}-*] logs
[2] Retain as production logs - Rename to [BASE-{module-name}], streamline to key steps
[3] Keep all - Leave as-is (for debugging)

Recommended: 
- Core flows → Retain as [BASE-{module-name}]
- Temporary debugging → Clean up
```

## Task Completion Wrap-up

```
1. Instant verification (mandatory):
   - Reference: references/principles/test-verification.md
   - Output: "🧪 Instant verification"
2. Auto-update documentation (mandatory):
   - project-map.md (new/changed modules)
   - module-registry.md (new reusable components)
   - Output: "📝 Auto-updated: xxx"
3. Core logic exists → Ask: "Add unit tests?"
4. Completion checkpoint: git commit -m "SPEC-Complete: {task-name}"
5. "✅ Task complete"
6. Output next step options
```

## Wrap-up Micro-Tasks

Minor tweaks after completion (copy/style/small fixes):

```
User: "Also change the button color"

AI: "📒 AutoDevTeam - Wrap-up @{task-name}
[Brief change description]"

→ Execute → How to Test (simplified) → Done

"✅ Done, any other wrap-up items?"
```

**Boundary**: Wrap-up >2 files or needs new files → "Too large, recommend separate task"

## Task Completion Options

```
📍 Current: Task "[task-name]" complete, [N] steps executed
📌 Next:
[1] Add tests (enter autoDevTeam/tester workflow) - Unit tests for new core logic
[2] Clean up code (enter autoDevTeam/cleanup workflow) - Clean up dev temporary code
[3] Develop new feature (enter autoDevTeam/architect workflow)
[0] Done

💡 You can also request wrap-up changes, e.g. "make the button blue"
```

## Failure Handling

```
If step fails:
1. Stop immediately, do not "fix and continue"
2. Report: Failure reason + files changed
3. Ask: "Roll back this step?"
```

## Mid-Task Micro-Tasks

Other requests during Step execution:

```
AI: "📒 AutoDevTeam - Micro-task @Step{N}
[Brief description]"

→ Execute → How to Test → Done

"✅ Micro-task complete
⏩ Continue Step {N+1}?"
```

**Boundary**: Micro-task >30 lines or >2 files → Handle separately after current Step
