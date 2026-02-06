# Mode Index

> Match mode by user intent; once determined, read only that directory's README.md

## Matching Rules (in order, first match wins)

| # | Mode | Trigger Words/Scenarios | Read Path |
|---|------|-------------------------|----------|
| 1 | Hotfix | "production"/"urgent"/"prod issue"/"emergency"/"fix now" | `hotfix/README.md` |
| 2 | Debug | "error"/"bug"/"not working"/"crash"/"broken"/"failing" | `debug/README.md` |
| 3 | FastTrack | Clearly small change ≤2 files (copy change/style tweak/minor fix) | `fasttrack/README.md` |
| 4 | Refactor | "refactor"/"reorganize"/"messy code"/"split"/"extract" | `refactor/README.md` |
| 5 | Optimize | "too slow"/"optimize"/"performance"/"speed up"/"laggy" | `optimize/README.md` |
| 6 | Cleanup | "remove"/"dead code"/"redundant"/"clean up" | `cleanup/README.md` |
| 7 | Tester | "write tests"/"unit test"/"add tests"/"test coverage" | `tester/README.md` |
| 8 | Survey | "understand project"/"project structure"/"just inherited"/"familiarize with codebase" | `survey/README.md` |
| 9 | Explain | "what does this code do"/"how does it work"/"explain this" | `explain/README.md` |
| 10 | Architect | "build a"/"implement"/"new feature"/"develop"/"add a" | `architect/README.md` |

**Step Mode**: Not user-triggered; entered when Architect/Refactor/Optimize generates a plan → `step/README.md`

## ⭐ Universal Pre-Steps (mandatory for code-change modes)

**Code-change modes** (Architect / FastTrack / Debug / Refactor / Optimize / Hotfix) must execute before entering:

1. Read `docs/context-snapshot.md` → What was recently developed?
2. Run `git log -5 --oneline` → Last 5 commits?
3. Answer: **Any correlation between recent changes and this task?**
   - New feature: Conflicts/dependencies with recent changes?
   - Debug: Caused by recent changes?
   - Minor change: Could it affect recently shipped features?

⛔ **Do not skip this step and jump directly into a mode**

**Exempt modes**: Survey, Explain, Tester, Cleanup (read-only or no functional changes)

## Reading Rules

1. After reading this index, match user intent to the table above
2. **Execute universal pre-steps** (if applicable)
3. **Once a mode is determined**, read only that mode's `README.md`
4. ⛔ Do not read multiple mode README.md files simultaneously
5. ⛔ Do not "read first to see if it matches"

## Mode Overview

### Hotfix ⚡
Emergency triage — minimal change, fix first, postmortem later.

### Debug 🔍
Systematic diagnosis — examine before hypothesizing, prescribe only after confirmed diagnosis.

### FastTrack 🏃
Quick minor change — ≤2 files ≤30 lines, auto-escalates to Architect if exceeded.

### Refactor 🔧
Code restructuring — impact analysis, backward compatibility, incremental verification.

### Optimize ⚡
Performance optimization — diagnose before optimizing, one bottleneck at a time.

### Cleanup 🧹
Remove redundancy — confirm unused, delete safely.

### Tester 🧪
Add tests — testability analysis, core logic first.

### Survey 🗺️
Project reconnaissance — structure scan, generate documentation.

### Explain 📖
Code explanation — trace call flow, explain in plain terms.

### Architect 🏗️
New feature development — feasibility assessment, incremental testable breakdown.

### Step 📋
Step execution — entered after plan confirmation. Execute step by step, verify each.
