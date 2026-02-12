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

## ⭐ Verification Methods (Smart Assessment)

### Step 1: Check if project has BDD framework

```
Check for .feature files in the project:
- `ls **/*.feature` or `find . -name "*.feature"`

✅ Has .feature files → Project has BDD configured, proceed to assessment
❌ No .feature files → Jump to "No BDD Framework" branch
```

### Step 2A: Has BDD Framework → Assess Complexity

**Assessment Dimensions** (AI auto-judges):

| Dimension | 🟢 Simple (Instant) | 🟡 Medium (User Choice) | 🔴 Complex (Cucumber) |
|-----------|---------------------|-------------------------|----------------------|
| **Change Size** | ≤2 files ≤30 lines | 3-5 files or 30-100 lines | >5 files or >100 lines |
| **Function Type** | Copy/style/small fix | Single module logic | Core flow/API change |
| **Impact Scope** | Single point | Single module | Cross-module/external API |
| **Verification Complexity** | 1 checkpoint | 2-3 checkpoints | Multiple scenarios/edge cases |

**Assessment Results**:

#### 🟢 Simple Change → Instant Verification

```
📊 Complexity Assessment: 🟢 Simple Change
- Change size: [N files, M lines]
- Function type: [copy/style/...]
- Impact scope: [single point/...]
- Verification method: Instant verification (terminal command/temp script)

🧪 Instant Verification:
Method: [command/script]
Result: [pass/fail]
Evidence: [key output]
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
```

#### 🔴 Complex Change → Must Use Cucumber

```
📊 Complexity Assessment: 🔴 Complex Change
- Change size: [N files, M lines]
- Function type: [core flow/API change]
- Impact scope: [cross-module/external API]
- Verification method: Cucumber verification (required)

🧪 BDD Verification:
Command: npx cucumber-js [corresponding feature file]
Result: [actual output]
```

**⛔ Prohibited**:
- Using instant verification for 🔴 complex changes
- Skipping assessment and choosing method directly

### Step 2B: No BDD Framework → Prioritize Speed

```
Project has no BDD framework, prioritize speed:

1. Run directly in terminal (CLI / curl / node -e / python -c)
2. Temporary script (delete after verification)
3. User manual confirmation (UI/UX/external systems)

💡 Tip: Complex projects should consider configuring BDD framework
```

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
