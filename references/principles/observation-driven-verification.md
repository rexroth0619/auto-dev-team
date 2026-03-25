# Observation-Driven Verification

> Compare expected observations against actual observations, not just test pass/fail status.

## Levels

- `L1`: lightweight
- `L2`: standard
- `L3`: heavy / regression-focused

## Required Pattern

For each validation pass, record:
- expected observation
- actual observation
- difference
- conclusion

Use higher levels for asynchronous work, state machines, permissions, caching, or cross-module flows.
