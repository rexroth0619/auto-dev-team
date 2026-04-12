# Automated Staging Validation Loop

> Minimal rules for the automated staging-validation path. Details should live in `release-plan.json` and scripts.

## Trigger

- the user explicitly chooses automatic mode
- `.autodev/temp/release-plan.json` already exists
- the project has the required `.autodev/path.md` facts
- the project has `.autodev/ai-sot.json`
