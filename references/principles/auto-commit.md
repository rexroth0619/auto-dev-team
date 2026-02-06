# Automatic Git Commit Mechanism

> ⚕️ Archive after every surgery — ensure all changes are traceable and reversible.

## Mechanism

**Rule**: After every implementation/fix completes, **auto-commit and push** — non-optional.

## Trigger Conditions

- New feature complete
- Bug fix complete
- Refactoring complete
- Optimization complete
- Any code change complete

## Execution Flow

```
1. Read `docs/path.md` for git config (remote repo, branch strategy)
2. git add -A
3. git commit -m "{type}: {one-line description}"
4. git push (to remote configured in path.md)
5. Output: 🔄 Committed: {commit hash} → {remote repo}
```

## Commit Types

| Type | Scenario | Example |
|------|------|------|
| `feat` | New feature | `feat: add user login` |
| `fix` | Bug fix | `fix: resolve download failure` |
| `refactor` | Refactoring | `refactor: extract shared validation logic` |
| `perf` | Performance optimization | `perf: optimize database queries` |
| `docs` | Documentation update | `docs: update API documentation` |
| `chore` | Config/dependency update | `chore: upgrade dependency versions` |

## Commit Message Format

```
{type}: {one-line description}

- change 1
- change 2
```

**Example**:
```
feat: add risk-control pending status

- Add pending status to RiskControlModel
- Auto-add watermark-tracked matched orders to pending list
- Support risk-control/permanent-ban/ignore actions
```

## Task Completion Report Format

```
━━━━━━━━━━━━━━━━━━━━
✅ Completed: [one-line description]
📁 Changed: [file list]
🔄 Committed: [commit hash] → [remote repo]
━━━━━━━━━━━━━━━━━━━━
📌 Next steps:
[1] [most relevant next step]
[2] [second most relevant next step]
[3] 📸 Save snapshot and finish
[0] End directly
━━━━━━━━━━━━━━━━━━━━
```

## Error Handling

| Situation | Handling |
|------|----------|
| No `docs/path.md` | Prompt user to create via template `assets/templates/path.md` |
| Remote repo not configured | Prompt user to configure Git section in `path.md` |
| Push failed | Report error, preserve local commit, prompt manual resolution |
| Conflict | Stop auto-flow, prompt user to resolve and push manually |
| No changes | Skip commit, output task completion report as normal |

## Platform Notes

### Windows PowerShell

PowerShell does not support `&&` chaining; execute separately:

```powershell
git add -A
git commit -m "feat: brief description"
git push origin main
```

### Linux / macOS

Chain commands:

```bash
git add -A && git commit -m "feat: brief description" && git push origin main
```

## Smart Recommendations (Next Steps)

| Just Completed | Recommended Next Step |
|-------------|-----------|
| Bug fix | Add tests, write postmortem |
| New feature | Add tests |
| Small change (≤2 files) | Streamlined options |
| Refactoring | Run tests to verify |
