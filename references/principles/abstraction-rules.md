# Abstraction Decision Principles

> Evaluate whether logic should be abstracted into a shared utility before implementing.

## Three-Question Rule (Ask Before Abstracting)

### Q1: Neutral operation or business-specific logic?

| Type | Characteristics | Abstraction Value |
|------|------|----------|
| **Neutral Operation** | Scanning, traversal, transformation, validation, formatting... | ✅ Worth abstracting |
| **Business-Specific** | User profiling, order state machines, domain-specific UI... | ❌ Usually not needed |

### Q2: Will other scenarios reuse this?

| Assessment | Conclusion |
|------|------|
| 🟢 Clearly yes (e.g., "scan" applies to characters/shapes/images) | → **Abstract** |
| 🟡 Possibly, uncertain | → **Don't abstract yet; mark as "potential abstraction point"** |
| 🔴 No | → **Don't abstract** |

### Q3: Will the API be simpler after abstraction?

| Assessment | Conclusion |
|------|------|
| Simpler (e.g., `scan(target, type)`) | → **Abstract** |
| More complex (parameter explosion, generics hell) | → **Don't abstract — over-engineering** |

## Rule of Three (Post-hoc Abstraction)

| Occurrences | Strategy |
|----------|------|
| 1–2 times | Don't abstract; duplication is acceptable |
| 3+ times | **Must abstract** |

## Abstraction Decision Flowchart

```
Identify potential abstraction opportunity
        │
        ▼
    Q1: Neutral operation?
        │
   ┌────┴────┐
   │         │
  Yes       No → Don't abstract
   │
   ▼
Q2: Will other scenarios use it?
   │
   ├─ Clearly yes → Q3
   ├─ Uncertain → Mark and observe
   └─ No → Don't abstract
   │
   ▼
Q3: Will API be simpler?
   │
   ├─ Yes → ✅ Abstract
   └─ No → ❌ Over-engineering
```

## Abstraction Deliverables

After abstracting:
1. Register new utility in `module-registry.md`
2. Update `project-map.md` to annotate the new shared capability

Output: `📝 Auto-updated: module-registry.md — added [Utility Name]`

## Common Abstraction Pitfalls

### ❌ Premature Abstraction
```
Abstracting after only 1 occurrence
→ Wastes time; abstraction direction may be wrong
```

### ❌ Over-Generalization
```
Adding excessive config parameters for "universality"
→ API complexity explodes; worse than no abstraction
```

### ❌ Abstracting Business Logic
```
Abstracting order pricing logic into a "universal pricer"
→ Business rules change constantly; abstraction becomes a burden
```

## Good Abstraction Example

```typescript
// ✅ Neutral operation, multi-scenario reuse, simple API
function traverse<T>(
  root: T, 
  getChildren: (node: T) => T[]
): T[] { ... }

// Use cases:
// - Traverse file tree
// - Traverse DOM nodes
// - Traverse org hierarchy
```

## Bad Abstraction Example

```typescript
// ❌ Business-specific, only one scenario
function calculateUserVIPDiscount(user, order) {
  // VIP discount rules change frequently; abstraction is pointless
}
```
