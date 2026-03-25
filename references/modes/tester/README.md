# Tester Mode

> Use for test creation, coverage work, use-case validation, staging validation, and interactive release testing. Output may include test files, `current-test.md`, or a current-round staging-testing draft.

## Must Read

Read these proactively:
- target source files mentioned by the user
- related test files when they exist
- `.autodev/current-test.md` when present
- recent commits or the requested commit range for staging-validation tasks
- `.autodev/path.md` when database queries, environment paths, or staging access matter

Also read:
- `references/principles/test-verification.md`
- `references/principles/observation-driven-verification.md` when runtime behavior matters
- `references/principles/bdd-testing.md` when `.feature` files or step definitions are involved

## Phase 0: Capability Check

Check:
- backend test framework
- BDD framework, if any
- GUI executor, if any
- existing coverage for the requested use cases

## Phase 1: Behavior Scenarios

Translate the request into scenarios:
- user-requested scenarios
- AI-added negative and boundary scenarios
- business-rule scenarios that still need confirmation

Ask the user before inventing thresholds, permission matrices, or approval policies.

## Phase 1.5: Interactive Release-Testing Flow

When the user asks for staging or release testing based on recent commits:
1. read the recent commits or the requested range
2. summarize only the behavior changes that matter for testing
3. decide whether real staging data is required first
4. if real data is required, output bootstrap SQL queries first
5. stop at `⏸️ Waiting For Staging Query Results`
6. only after the user pastes results back, draft test data, use cases, and manual test steps
7. after the user runs manual tests, continue based on returned results

### Fixed First-Round Template for Query-Led Flows

If the first round needs real data, the first response must contain only:
1. `🛠️ Release Test Start`
2. `🛠️ Bootstrap Database Queries`
3. `⏸️ Waiting For Staging Query Results`
4. `✅ Current Round Ready`

All queries must be emitted in one complete code block.

Before the user returns query results, do not generate final test data, use cases, or manual steps.

### Rules

- never fabricate business-critical test data when state is unclear
- generate SQL in the project-appropriate database dialect
- explain why each query exists and how the result will be used
- prefer scenarios directly affected by the recent commits over generic full regression
- when the final use cases are ready, the manual steps must tell the user what to paste, where to click, what should appear, and what counts as success
- if this is also a large test, keep `.autodev/current-test.md` in sync

## Phase 2: Choose the Test Layer

Map scenarios to:
- unit
- integration / contract
- GUI validation loop
- manual validation

Also decide:
- small vs large test
- whether `current-test.md` is required
- whether GUI validation is required
- whether `L1 / L2 / L3` observation-driven validation is needed

## Phase 3: Create or Update Test Assets

Priority order:
1. protective regression tests for fixed bugs
2. unit / integration tests for core logic
3. GUI executor coverage when the path is ready
4. manual validation steps for perception-heavy behavior

## Phase 4: Execute Validation

Required order:
1. snapshot gate
2. blast radius
3. backend testing
4. observation-driven validation
5. GUI validation when relevant
6. update `current-test.md` for large tests
7. emit a test receipt

## Phase 5: Result Handling

If tests pass, offer follow-up options such as keeping the tests as regression protection or returning to the main task.

If tests fail, decide whether the next step is fixing the code, fixing the test asset, or clarifying business rules.
