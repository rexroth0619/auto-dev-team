# Explain Mode

> Use when the user wants to understand how code works. Primary output: a compact call-path explanation.

## Must Read

Read the files related to the feature the user mentioned. The user should not need to provide them manually.

## Output Rules

- show a tree-shaped call path
- keep the depth to about 3 layers unless the user asks for more
- keep the answer compact
- include file paths and line references
- explain structure, not large code dumps

## Typical Shape

- entrypoint
- key calls
- data flow
- one-line summary
- core files worth reading next

## Boundaries

- Explain only: stay read-only
- if the user then wants to build something, switch to Architect
- if the user wants to fix something, switch to Debug
- if the user wants a project-wide view, switch to Survey
