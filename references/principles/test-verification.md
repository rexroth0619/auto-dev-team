# Test Verification

> Canonical validation protocol for code changes.

## Core Rule

Do not claim success without executed evidence.

## Required Outputs

- backend test command and result
- observation-driven validation result
- GUI validation result when relevant
- explicit residual risk
- honest status: passed / failed / not executable / pending business input

## Large Test Rule

Create or update `.autodev/current-test.md` when the task touches:
- auth
- payments
- permissions
- approval flows
- multi-step user journeys
- cross-module contracts
- unclear business rules
