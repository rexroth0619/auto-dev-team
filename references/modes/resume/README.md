# Resume Mode

> Use when the user forgot where the task stopped, the model changed, the connection broke, or the team wants to recover the current active-flow state before doing anything else.

## Must Read

Read in this order:

1. `.autodev/current-flow.json`
2. `.autodev/current-brainstorm.md`
3. `.autodev/current-steps.md`
4. `.autodev/current-test.md`
5. `.autodev/current-debug.md`
6. `.autodev/current-blast-radius.md`
7. `.autodev/current-gui-test.js`
8. `.autodev/context-snapshot.md`

## Goal

Answer three questions before any new execution:

1. what are we currently building or fixing
2. how far did we get
3. what remains and what mode should continue next

Resume is read-only by default. Do not move into Step execution or rewrite the plan unless the user explicitly asks to continue.
