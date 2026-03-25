# Abstraction Rules

> Evaluate abstraction deliberately. Reuse is good; premature abstraction is not.

## Three Questions Before Abstracting

1. Is this a neutral capability or a business-specific rule?
   - neutral capability: likely worth abstracting
   - business-specific rule: usually keep local
2. Will other scenarios clearly need it?
   - yes: abstraction is reasonable
   - maybe: mark as a future abstraction point
   - no: do not abstract
3. Does the abstraction make the API simpler?
   - simpler: acceptable
   - more parameters and complexity: over-engineering

## Rule of Three

- 1-2 occurrences: duplication is acceptable
- 3+ repeated occurrences: abstraction is expected

## After Creating an Abstraction

Update:
- `.autodev/module-registry.md`
- `.autodev/project-map.md`
