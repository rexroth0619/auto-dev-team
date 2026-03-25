# Impact Analysis

> Canonical blast-radius protocol.

## Core Rule

Before the first line of code, run a scriptable blast-radius pass.

## Required Scope

Check at least:
- target files or symbols
- direct callers
- key consumers
- neighbor tests
- config and environment surfaces

## Stop Conditions

Stop direct editing when:
- the blast-radius result exceeds the planned threshold
- the target is ambiguous
- the actual edit scope grows beyond the original target
