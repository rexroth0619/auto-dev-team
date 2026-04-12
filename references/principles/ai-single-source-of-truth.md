# AI Single Source Of Truth

> Project-level fixed facts for AI execution. `path.md` is human-oriented; `ai-sot.json` is machine-oriented.

## Goal

- move long-lived staging / deployment / remote execution / GUI host / auth facts out of per-run plans
- stop the AI from re-guessing SSH aliases, working directories, allowed paths, base URLs, and auth mode every time
- keep `release-plan.json` focused on the current run only
