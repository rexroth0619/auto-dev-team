# Impact Analysis Principles

> ⚕️ Assess blast radius before surgery — changing one organ may affect the entire system.

## Trigger Conditions

After every code change, perform impact analysis to ensure tests cover all potentially affected modules.

## Analysis Dimensions

### 1. Direct Dependencies (Static Analysis — Automatable)

**Caller analysis**: Who calls the modified module?

```bash
# TypeScript/JavaScript
rg "import.*{modified_module}" --type ts
rg "from ['\"].*modified_module" --type ts

# Python
rg "from.*modified_module.*import" --type py
rg "import.*modified_module" --type py

# Go
rg "import.*modified_package" --type go
```

**Callee analysis**: What does the modified module call?

```
Read import/require statements of the modified file
→ List all dependencies
→ If behavioral assumptions of dependencies changed, there may be issues
```

### 2. Data Flow Dependencies (Requires Business Understanding)

| Question | Analysis Method |
|-----|---------|
| Where does this data come from? | Trace data source (API/database/user input) |
| Where does this data flow to? | Track consumers (UI/storage/third-party) |
| Who is affected by format changes? | Check all locations that parse/use this data |

**Example**:
```
Change: formatPrice() output changed from "$100" to "¥100"

Data flow analysis:
├── Source: pricing service
├── Consumer 1: ProductCard component (display) → needs testing
├── Consumer 2: PDF export (may have parsing logic) → needs testing
└── Consumer 3: third-party settlement system (API) → needs testing
```

### 3. Configuration/Environment Dependencies

| Change Type | Impact Scope |
|---------|---------|
| Environment variables | All services reading that variable |
| Config files | All modules loading that config |
| Database schema | All code querying that table |
| API endpoints | All clients calling that endpoint |

### 4. Implicit Dependencies (Most Easily Overlooked)

| Type | Example | Detection Method |
|-----|------|---------|
| String parsing | Regex matching "$" in prices | Search for related regex patterns |
| Order dependency | Assumes list is in specific order | Check sorting/iteration logic |
| Timing dependency | Assumes one operation precedes another | Check async/concurrency code |
| Cache dependency | Assumes data exists in cache | Check cache read/write points |

## Output Format

```
🎯 Impact Analysis

Current changes:
├── src/utils/price.ts (core change)
└── src/types/price.d.ts (type update)

━━━━━━━━━━━━━━━━━━━━

📌 Direct impact (callers):
├── src/components/ProductCard.tsx
├── src/components/CartItem.tsx
└── src/pages/Checkout.tsx

📌 Direct impact (callees):
└── src/utils/currency.ts

━━━━━━━━━━━━━━━━━━━━

📌 Data flow impact:
├── PDF export module (may parse price strings)
└── Settlement API (passes prices to third-party)

📌 Config impact:
└── None

━━━━━━━━━━━━━━━━━━━━

🧪 Recommended test scope:

| Priority | Module | Reason |
|-------|------|------|
| 🔴 Must test | price.ts | Core of this change |
| 🔴 Must test | ProductCard.tsx | Direct caller |
| 🔴 Must test | CartItem.tsx | Direct caller |
| 🟡 Recommended | Checkout.tsx | Direct caller |
| 🟡 Recommended | PDF export | Data flow consumer |
| ⚪ Optional | currency.ts | Callee, low impact |
```

## Integration with Instant Verification

Impact analysis results inform **verification scope**:

```
Primary Agent completes code
    ↓
Execute impact analysis
    ↓
Instant verification covers:
  - Change points
  - Direct callers
```

## Analysis Depth Rules

| Change Scale | Analysis Depth |
|---------|---------|
| 🟢 Small (1–2 files, <30 lines) | Direct callers only |
| 🟡 Medium (3–5 files) | Direct dependencies + data flow |
| 🔴 Large (>5 files or core interfaces) | Full analysis across all dimensions |

## Special Scenarios

### Interface Changes

```
If the change involves:
- API endpoint signatures
- Data structures/types
- Public function parameters

Must:
1. List all callers
2. Check backward compatibility
3. If not backward-compatible, all callers are must-test scope
```

### Database Changes

```
If the change involves:
- Table schema (ALTER TABLE)
- Index changes
- Constraint changes

Must:
1. List all code querying that table
2. Check ORM model sync
3. Check migration script correctness
```

### Configuration Changes

```
If the change involves:
- Environment variables
- Config files
- Feature flags

Must:
1. List all code reading that config
2. Check default value handling
3. Check cross-environment differences
```

### 5. Preservation Check (Required for "Add/Modify" Scenarios)

> ⚕️ Don't damage healthy tissue during surgery — adding a new organ must not remove existing ones.

| Checkpoint | Question | Typical Error |
|--------|------|----------|
| **Sibling preservation** | Other sibling elements (fields/functions/config items) preserved? | Adding a field while deleting others |
| **Hierarchy preservation** | Inner logic/content preserved? | Rewriting a function while losing critical internal logic |

**Execution**:

```
Before modifying a file, output preservation checklist:

📋 Preservation Check - [filename]
├── ✅ Preserve: [list all preserved elements]
├── 🔄 Modify: [list elements to modify]
└── ❌ Delete: [list elements to delete + reason] (leave empty if none)

⛔ When user says "add", the "Delete" section must be empty
```

### 6. Correlation Check (Required When Modifying Logic)

> ⚕️ The body is a whole — changing the heart's blood supply requires checking all organs receiving blood.

| Checkpoint | Question | Example |
|--------|------|------|
| **Symmetry** | Changed forward operation — reverse need syncing? | Encode↔Decode, Encrypt↔Decrypt, Serialize↔Deserialize |
| **Closed-loop** | Changed one flow link — other links need checking? | CRUD (changed C → check R, U, D), state machines, data flows |
| **Inheritance** | Changed base class/interface — subclasses need syncing? | Interface signature change → all implementing classes |

**Execution**:

```
Before modifying logic, output correlation checklist:

🔗 Correlation Check - [modified function/module]
├── ⚖️ Symmetric operations: [yes/no] → [if yes, list reverse operations]
├── 🔄 Complete flow: [yes/no] → [if yes, list other flow links]
└── 📐 Inheritance chain: [yes/no] → [if yes, list subclasses/implementations]

⛔ Any "yes" item must be checked for required synchronized changes
```

## Prohibited Actions

- ❌ Skip impact analysis and write tests directly
- ❌ Analyze only direct callers while ignoring data flow
- ❌ Omit test scope recommendations
- ❌ Perform shallow analysis for large changes
