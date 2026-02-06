# Hotfix Mode (Emergency Fix)

> Applies to: Production issue, urgent, stop the bleeding fast | Principle: Stop bleeding first, postmortem later; minimal change | Output: postmortem [HOTFIX]

## Core Principle

```
Stop the bleeding first, postmortem later
Minimal change, rapid recovery
```

## Workflow

### 0. Create Checkpoint

### 1. Rapid Localization
```
User: [Describes urgent issue]
      [Error messages]

AI:   1. Skip deep analysis
      2. Directly locate error point
      3. Propose minimal fix
      
      4. ⭐ Auto-invoke Critique Subagent (even in emergencies)
         - Pass: [User's problem] + problem, minimal fix plan
         - Focus: Truly minimal? Could it introduce new issues?
      
      5. Subagent quick two-phase review:
         
         Phase A: Problem Clarification (quick)
         ├── Sufficient for localization?
         ├── More info needed to confirm direction?
         └── ⚠️ Critical info missing → Quick follow-up (1-2 questions)
         
         Phase B: Plan Review
         └── Truly minimal? New issues possible?
         
      6. Output:
         ━━━━━━━━━━━━━━━━━━━━
         ⚡ Minimal Fix Plan: [xxx]
         ━━━━━━━━━━━━━━━━━━━━
         🏥 Quick Consultation: [Subagent brief review]
         ━━━━━━━━━━━━━━━━━━━━
         📋 Original plan: [Minimal fix plan]
         🛠️ Revised plan: [After consultation, if any]
         
         Which one to execute?
```

**⛔ Urgency is not a reason to skip consultation** — Use shorter checklist
**⛔ Do not execute directly after consultation; must wait for user selection**
**⛔ Emergency clarification: 1-2 key questions max**

### 2. Quick Fix
```
AI:   1. Execute minimal change (log: [HOTFIX-{issue}])
      2. "⚠️ This is a temporary patch, not a root fix"
      3. How to Test
         
         Filter `[HOTFIX-{issue}]` should show:
         → [HOTFIX-{issue}] Fix point: xxx
         → [HOTFIX-{issue}] Verification: xxx
```

### 3. Post-Incident Documentation (Mandatory)
```
AI:   1. Auto-write to postmortem.md (tagged [HOTFIX])
         Output: "📝 Auto-updated: postmortem.md - [HOTFIX] Bug-YYYY-MM-DD-00X"
      2. "Recommend creating a Debug task for thorough investigation later"
      3. Clean up [HOTFIX-*] logs
```

## Difference from Debug

| | Hotfix | Debug |
|---|--------|-------|
| Goal | Stop bleeding | Root fix |
| Analysis | Skipped | In-depth |
| Solution | Minimal change | Complete fix |
| Time | Minutes | As needed |

## Fix Completion Options

```
📍 Current: Temporary patch applied, fixed "[issue summary]"
⚠️ Temporary fix; thorough investigation recommended
📌 Next:
[1] Deep investigation (enter autoDevTeam/debug workflow) - Find root cause
[2] View postmortem - Review [HOTFIX] record
[3] Develop new feature (enter autoDevTeam/architect workflow)
[0] Done
```
