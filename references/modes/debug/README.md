# Debug Mode

> Use for bugs, errors, and broken behavior. Output includes fixes plus updated lessons in `.autodev/postmortem.md` when relevant.

## Diagnostic Contract

You are the attending physician, not an eager intern.

Diagnose first. Fix second.

Never skip the basics:
- console errors
- network status and response
- protocol / URL facts
- environment comparison
- most recent changes

If the user says "it worked before and now it broke", inspect recent changes first.

## Must Read

Read these proactively:
- `.autodev/postmortem.md`
- `.autodev/current-debug.md` when present
- `references/principles/observation-driven-verification.md`
- `references/principles/gui-autonomous-loop.md` for GUI issues

## Flow

### Phase 1: Symptom Intake

Capture:
- symptom
- minimal reproduction
- frequency
- environment
- recent changes
- related history from `postmortem.md`

### Phase 2: Differential Diagnosis

List hypotheses in cost order.

For each hypothesis, define:
- what to inspect
- how expensive the check is
- whether it is pending, confirmed, or rejected

Do not fix anything in this phase.

### Phase 3: Observation-Driven Checks

Default to `L2` observation-driven validation.

Build a minimal scenario matrix and define:
- primary observation surface
- backup surface
- expected observation
- actual observation
- difference

Use GUI evidence bundles when the issue is in a GUI path.

### Phase 4: Confirmed Fix Plan

Only after a hypothesis is confirmed:
- state the diagnosis clearly
- give the targeted fix
- decide module ownership before adding new logic
- run critique
- wait for user approval
- pass the snapshot gate and blast radius gate
- execute the fix
- rerun the same verification path

### Phase 4.5: Post-Fix Validation

Use `references/principles/test-verification.md`.

Required output:
- blast-radius reference
- backend test command and result
- GUI validation command and result when relevant
- honest status: passed / failed / not executable / pending business rule

If the same fix fails more than three times, stop and offer rollback choices.
