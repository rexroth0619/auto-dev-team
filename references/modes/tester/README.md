# Tester Mode (Unit Testing)

> Applies to: Add tests, write unit tests | Output: Test files

## AI Must Proactively Read

On entry, AI must read target source files the user mentions (without user providing them).

## Phase 0: Environment Check

```
AI checks for test framework:

✅ Framework exists:
   → Identify (jest/vitest/pytest/mocha/etc.)
   → Proceed to Phase 1

❌ No framework:
   → "No test framework configured. Set one up?"
   → After confirm, recommend and configure based on project language
```

### Common Test Frameworks

| Language | Recommended | Alternative |
|----------|-------------|-------------|
| JavaScript/TypeScript | vitest | jest, mocha |
| Python | pytest | unittest |
| Go | go test | - |
| Rust | cargo test | - |
| Java | JUnit | TestNG |

## Phase 1: Testability Analysis

```
AI analyzes target code:

✅ Easy to test (priority):
   - Pure functions (input→output, no side effects)
   - Utility functions
   - Data transformation logic
   - Business rule calculations
   
⚠️ Requires mocking:
   - External API / network
   - Database
   - File system
   - Time/randomness
   - Third-party services
   
❌ Not recommended for unit testing:
   - UI component rendering (use manual/E2E)
   - Simple pass-through functions
   - Configuration files
   - Glue code
```

Output:
```
📋 Testability Analysis:
| Function/Module | Testability | Reason |
|-----------------|-------------|--------|
| calculate() | ✅ Easy | Pure function |
| fetchData() | ⚠️ Needs mock | Network request |
| Button component | ❌ Not recommended | Use manual testing for UI |

Recommended: calculate()
```

## Phase 2: Write Tests

### File Conventions
```
Location: Same directory or tests/ directory (follow project conventions)
Naming: Follow project conventions:
  - {source-file}.test.{ext}
  - {source-file}_test.{ext}
  - test_{source-file}.{ext}
```

### Test Structure (Universal)
```
describe/group: Function under test
  ├── test: Normal case (Happy Path)
  ├── test: Edge case (empty values, extremes)
  └── test: Error case (invalid input)
```

### Coverage Principles
```
Each function must cover at minimum:
1. ✅ Happy path - Typical input, expected output
2. ⚠️ Edge cases - Empty values, zero, extremes
3. ❌ Error cases - Invalid input, error handling
```

### Naming Conventions
```
Good names describe:
- Condition
- Action
- Expected result

Examples:
✅ "should return default value when input is empty"
✅ "should throw exception when amount is negative"
❌ "test1"
❌ "test calculate"
```

## Phase 3: Run Tests

```
AI: "Tests written. Auto-executing:

    Common commands:
    - npm run test
    - pytest
    - go test ./...
    - cargo test

    Expected:
    ✅ All passed: X passed, 0 failed
    
    If any fail:
    ❌ Failure info + expected vs actual
    
    If cannot auto-execute, will guide manual run.
    Paste results."
```

## Phase 4: Handle Results

### Tests Pass
```
AI: "✅ All tests passed

    Keep as regression safeguard?
    - Keep: Future changes auto-checked
    - Remove: Delete test files"
```

### Tests Fail
```
AI: "❌ Some tests failed

    Analyzing...
    
    Possible scenarios:
    1. Code bug → Fix code
    2. Test wrong → Fix test
    3. Requirement misunderstood → Confirm with user
    
    Suggestion: [specific suggestion]"
```

## Relationship with How to Test

```
┌─────────────────────────────────────────────────────┐
│  How to Test (Manual)                               │
│  - UI effects and visual presentation               │
│  - User interaction flows                           │
│  - End-to-end functionality                         │
│  → Execute manually after each change               │
├─────────────────────────────────────────────────────┤
│  Unit Tests (Automated)                             │
│  - Function logic correctness                       │
│  - Edge case handling                               │
│  - Error handling                                   │
│  → Run commands, instant                            │
├─────────────────────────────────────────────────────┤
│  Complementary, not substitutes                     │
│  User interaction/visual → Manual testing           │
│  Core logic/computation → Unit testing              │
└─────────────────────────────────────────────────────┘
```

## When to Suggest Tests

| Scenario | Suggestion | Reason |
|----------|-----------|--------|
| Fixed bug | 🟢 Strongly recommend | Prevent recurrence |
| After refactoring | 🟢 Strongly recommend | Verify equivalence |
| Core business logic | 🟢 Recommend | Ensure correctness |
| Utility functions | 🟢 Recommend | Easy, high value |
| New feature | 🟡 Optional | Depends on complexity |
| UI components | 🔴 Not recommended | Use manual testing |
| Simple pass-through | 🔴 Not recommended | Too low value |

## Mock Principles

```
Purpose: Isolate code under test from external dependencies

When to mock:
- External API / network
- Database operations
- File system
- Time (Date.now, time.time)
- Random numbers

Rules:
- Only mock what must be mocked
- Mock behavior, not implementation
- Keep mocks simple
```

## Mandatory Rules

- Test files follow project conventions
- Test names clearly describe expected behavior
- Test behavior, not implementation details
- Write highest-value tests first (core logic, bug fixes)

## Phase End Options

### After Tests Pass
```
📍 Current: [N] tests passed, covering [function/module names]
📌 Next:
[1] Keep - As regression safeguard
[2] More tests (continue autoDevTeam/tester workflow) - Other functions
[3] Develop new feature (enter autoDevTeam/architect workflow)
[0] Delete tests
```

### After Tests Fail
```
📍 Current: [N] tests failed at [test name/assertion summary]
📌 Next:
[1] Fix code (enter autoDevTeam/debug workflow) - Bug needs fixing
[2] Fix test - Wrong expectation
[3] Details - Failure reason and stack trace
[0] Cancel
```
