# FastTrack Mode

> Use for tiny copy, styling, or single-point fixes. Hard limit: <= 2 files and <= 30 changed lines. Escalate when it grows beyond that.

Read `references/principles/gui-autonomous-loop.md` before validation if the task is GUI-capable.

## Flow

1. Version protection
   - pass the snapshot gate before the first write
   - archive once validation passes
2. Scope check
   - <= 2 files
   - <= 30 changed lines
   - otherwise escalate to Architect
3. Quick plan + critique
   - produce the quick plan
   - run critique
   - wait for user choice
4. Preservation check
   - confirm add / modify / delete semantics
5. Quick blast-radius gate
   - run `scripts/blast-radius.py ... --mode fasttrack --write`
   - if risk is high or the target is unclear, stop and escalate
6. Execute and validate
   - snapshot gate
   - blast-radius gate
   - apply the change
   - summarize the change
   - run backend validation
   - run GUI validation when relevant
7. Clean temporary debug markers before finishing

## Escalate When

- more than 2 files
- new files are needed
- interfaces change
- impact spreads beyond the original target
- blast radius exceeds the acceptable threshold
