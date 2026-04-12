# Critique Protocol

> Every write-mode plan needs a second look.

## Goal

Catch:
- unclear requirements
- over-engineering
- hidden side effects
- weak structure choices
- skipped same-pattern defects
- repair levels that are too narrow or too heavy

## Default Flow

1. produce the plan
2. run critique
3. if possible, use a separate critique agent
4. otherwise run the local checklist
5. if clarification is needed, ask first
6. only execute after the user chooses a plan

## Checklist

- is the request still ambiguous?
- is the plan larger than necessary?
- is there a simpler or cheaper path?
- what can break?
- did we only patch the visible symptom, or did we check similar modules and symmetric paths too?
- is the repair level appropriate: one-off fix, batch fix, or platform-level fix?
- are add / modify / delete semantics preserved?
- does the change belong in the chosen module?
- is a single file accumulating too many responsibilities?
