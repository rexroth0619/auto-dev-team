# Programming Patterns Library

> Reusable patterns — auto-accumulated, auto-retrieved, cross-project

## Directory Structure

```
patterns/
├── README.md                     # This file
│
├── universal/                    # 🌐 Universal principles (language/platform agnostic)
│   ├── concurrency/
│   ├── performance/
│   ├── error-handling/
│   ├── data/
│   └── architecture/
│
├── language/                     # 💻 Language-specific patterns
│   ├── typescript/
│   ├── python/
│   ├── java/
│   ├── swift/
│   ├── kotlin/
│   └── go/
│
└── platform/                     # 📱 Platform-specific patterns
    ├── web/
    ├── android/
    ├── ios/
    ├── backend/
    └── desktop/
```

## Three-Layer Classification

| Layer | Directory | Content | Examples |
|-------|-----------|---------|----------|
| **Universal Principles** | `universal/` | Language-agnostic design concepts | Queuing, caching, retry patterns |
| **Language Patterns** | `language/` | Language-specific pitfalls & techniques | TS type gymnastics, Python GIL |
| **Platform Patterns** | `platform/` | Platform-specific best practices | Android ANR, iOS memory mgmt |

## AI Retrieval Logic

```
On task entry:
1. Identify task domain (concurrency/performance/error-handling...)
2. Identify project language and platform
3. Search in order:
   → universal/{domain}/     # Universal principles first
   → language/{language}/    # Language patterns second
   → platform/{platform}/   # Platform patterns last
4. Synthesize recommendations
```

---

## Pattern File Format

### Universal Principles (`universal/`)

```markdown
# [Pattern Name]

> One-liner: scenario this pattern addresses

## Scope

| Dimension | Scope |
|-----------|-------|
| Language | Universal |
| Platform | Universal |

## Problem

[Describe the problem without referencing specific languages]

## Solution (Conceptual)

[Core approach via pseudocode or flowcharts]

## Key Decision Points

- Decision 1: [Factors]
- Decision 2: [Factors]

## Boundary Conditions

- Not applicable: [When not to use]
- Scale boundary: [When an alternative is needed]

## Checklist

- [ ] Checkpoint 1
- [ ] Checkpoint 2

---
*Tags*: `tag1`, `tag2`
```

### Language Patterns (`language/`)

```markdown
# [Language]: [Pattern Name]

> One-liner: language-specific problem/technique addressed

## Applicable Versions

- Language version: X.x+
- Related framework: Framework X.x (optional)

## Background

[Why this problem is language-specific]

## Pitfalls / Common Mistakes

[Incorrect examples + why they're wrong]

## Correct Approach

[Correct code examples]

## Related

- Universal principle: `universal/xxx/yyy.md` (if applicable)
- Related pattern: `language/xxx/zzz.md` (if applicable)

---
*Tags*: `tag1`, `tag2`
```

### Platform Patterns (`platform/`)

```markdown
# [Platform]: [Pattern Name]

> One-liner: platform-specific problem/best practice addressed

## Scope

- Platform version: Android 10+ / iOS 14+ / ...
- Related framework: React 18 / SwiftUI / ... (optional)

## Background

[Why this problem is platform-specific]

## Symptoms

[What users/developers encounter]

## Solution

[Best practices + code examples]

## Related

- Universal principle: `universal/xxx/yyy.md` (if applicable)
- Language pattern: `language/xxx/zzz.md` (if applicable)

---
*Tags*: `tag1`, `tag2`
```

---

## How to Add Patterns

### Trigger Conditions

After task completion, AI evaluates:
1. Was a representative problem solved?
2. Was the solution verified?
3. Is it reusable across projects?

### Classification Decision

```
This pattern is...
├── Language-agnostic universal concept? → universal/
├── Language-specific pitfall/technique? → language/{language}/
└── Platform-specific best practice? → platform/{platform}/
```

### Naming Conventions

- Filename: `kebab-case.md` (e.g., `token-refresh.md`)
- Avoid business-specific names
- Use verb/noun phrases describing the behavior

---

## Pattern Index

> Auto-updates as patterns accumulate

### Universal Principles (universal/)

#### architecture/
- `internal-external-isolation.md` - Internal/External Network Isolation: internal optimization must not expose internal addresses to external users

#### concurrency/
- (none yet)

#### performance/
- (none yet)

#### error-handling/
- (none yet)

### Language Patterns (language/)

- (none yet)

### Platform Patterns (platform/)

- (none yet)
