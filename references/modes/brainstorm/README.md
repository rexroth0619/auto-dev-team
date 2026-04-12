# Brainstorm Mode

> Use when the requirement is still being discussed, the boundaries are unclear, or the team wants alignment before planning. Output: `current-brainstorm.md`, and optionally `current-metaphor.md`.

## Must Do

When entering this mode, the AI must:

1. run `scripts/flowctl.sh init <task-slug> brainstorm` to initialize or activate the flow
2. read `.autodev/current-flow.json` and confirm the active flow
3. create or update `.autodev/current-brainstorm.md`
4. create or update `.autodev/current-metaphor.md` when the user needs a non-technical explanation layer
5. stay in goals, boundaries, and acceptance; do not jump into implementation

## Flow

- clarify the real goal
- define scope and non-scope
- define user-verifiable acceptance criteria
- record the result in `.autodev/current-brainstorm.md`
- recommend the next mode
