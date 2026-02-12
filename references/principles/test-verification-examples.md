# Test Verification Examples

> This document demonstrates the smart verification rules in different scenarios

## Assessment Dimensions

| Dimension | 🟢 Simple | 🟡 Medium | 🔴 Complex |
|-----------|-----------|-----------|------------|
| **Change Size** | ≤2 files ≤30 lines | 3-5 files or 30-100 lines | >5 files or >100 lines |
| **Function Type** | Copy/style/small fix | Single module logic | Core flow/API change |
| **Impact Scope** | Single point | Single module | Cross-module/external API |
| **Verification Complexity** | 1 checkpoint | 2-3 checkpoints | Multiple scenarios/edge cases |

## Scenario 1: 🟢 Simple Change - Update Button Text

**Change**:
- Files: 1 (`Button.vue`)
- Lines: 1
- Type: Copy change

**Assessment**:
```
📊 Complexity Assessment: 🟢 Simple Change
- Change size: 1 file, 1 line
- Function type: Copy change
- Impact scope: Single point
- Verification method: Instant verification (terminal command/temp script)
```

**Verification Method**:
```bash
# Quick verification: Start app, check copy
npm run dev
# Or use screenshot tool to confirm UI copy updated
```

**Output**:
```
🧪 Instant Verification
Method: Start app + manual confirmation
Result: Pass
Evidence: Button text updated to "Confirm Submit"
```

## Scenario 2: 🟡 Medium Change - Add Form Validation

**Change**:
- Files: 3 (`Form.vue`, `validation.ts`, `utils.ts`)
- Lines: ~60
- Type: Single module logic change

**Assessment**:
```
📊 Complexity Assessment: 🟡 Medium Change
- Change size: 3 files, 60 lines
- Function type: Single module logic change (form validation)
- Impact scope: Single module (form component)
```

**Verification Method Choice**:
```
📌 Choose verification method:
[1] Instant verification - manually test various inputs (fast)
[2] Cucumber verification - run BDD scenarios, cover normal/error/edge cases (comprehensive)

User chooses [1]:
→ Use instant verification, manually test common inputs

User chooses [2]:
→ Execute `npx cucumber-js features/form-validation.feature`
```

## Scenario 3: 🔴 Complex Change - Refactor User Authentication

**Change**:
- Files: 8 (across modules: auth, api, middleware, store)
- Lines: ~200
- Type: Core flow change + API change

**Assessment**:
```
📊 Complexity Assessment: 🔴 Complex Change
- Change size: 8 files, 200 lines
- Function type: Core flow change (user auth) + API change
- Impact scope: Cross-module (auth, api, middleware, store) + external API
- Verification method: Cucumber verification (required)
```

**Verification Method**:
```
🧪 BDD Verification - Actual Execution

📂 Command: npx cucumber-js features/user-auth.feature
📤 Actual Output:
┌────────────────────────────────────────────────────
│ Feature: User Authentication
│ 
│   Scenario: User login with valid credentials
│     ✓ Given user "test@example.com" with password "password123"
│     ✓ When user submits login form
│     ✓ Then user should be redirected to dashboard
│     ✓ And session should be created
│ 
│   Scenario: User login with invalid credentials
│     ✓ Given user "test@example.com" with password "wrongpassword"
│     ✓ When user submits login form
│     ✓ Then user should see error message "Invalid credentials"
│     ✓ And no session should be created
│ 
│   Scenario: Token refresh flow
│     ✓ Given user is logged in
│     ✓ When access token expires
│     ✓ Then refresh token should be used automatically
│     ✓ And user should remain authenticated
│ 
│ 3 scenarios (3 passed)
│ 12 steps (12 passed)
│ 0m2.345s
└────────────────────────────────────────────────────

📊 Results:
  ✅ Scenario: User login with valid credentials → passed
  ✅ Scenario: User login with invalid credentials → passed
  ✅ Scenario: Token refresh flow → passed
```

## Scenario 4: 🟢 Simple Change - Update CSS Styles

**Change**:
- Files: 1 (`styles.css`)
- Lines: 5
- Type: Style adjustment

**Assessment**:
```
📊 Complexity Assessment: 🟢 Simple Change
- Change size: 1 file, 5 lines
- Function type: Style adjustment
- Impact scope: Single point
- Verification method: Instant verification (browser check)
```

**Verification Method**:
```bash
# Refresh browser, check style effects
# Use dev tools to confirm CSS rules applied
```

**Output**:
```
🧪 Instant Verification
Method: Browser check
Result: Pass
Evidence: Button padding adjusted to 16px, matches design spec
```

## Scenario 5: 🟡 Medium Change - Add New API Endpoint

**Change**:
- Files: 4 (`routes.ts`, `controller.ts`, `service.ts`, `model.ts`)
- Lines: ~80
- Type: Single module logic change (new API)

**Assessment**:
```
📊 Complexity Assessment: 🟡 Medium Change
- Change size: 4 files, 80 lines
- Function type: Single module logic change (new API endpoint)
- Impact scope: Single module (API layer)
```

**Verification Method Choice**:
```
📌 Choose verification method:
[1] Instant verification - test API endpoint with curl/Postman (fast)
[2] Cucumber verification - run API test scenarios (comprehensive)

User chooses [1]:
→ Use curl to test new endpoint

User chooses [2]:
→ Execute `npx cucumber-js features/api/new-endpoint.feature`
```

**Instant Verification Example**:
```bash
# Test GET request
curl -X GET http://localhost:3000/api/users/123

# Test POST request
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com"}'
```

**Output**:
```
🧪 Instant Verification
Method: curl command test
Command: curl -X GET http://localhost:3000/api/users/123
Result: Pass
Evidence:
┌────────────────────────────────────────────────────
│ HTTP/1.1 200 OK
│ Content-Type: application/json
│ 
│ {
│   "id": 123,
│   "name": "Test User",
│   "email": "test@example.com"
│ }
└────────────────────────────────────────────────────
```

## Edge Cases

### Case A: Project Has No BDD Framework

If project has no BDD framework (no `.feature` files):

```
📊 Complexity Assessment: 🔴 Complex Change
- Change size: 10 files, 300 lines
- Function type: Core flow change
- Impact scope: Cross-module
- Project status: No BDD framework configured

⚠️ Suggestion: Complex projects should consider configuring BDD framework for long-term maintenance

📌 Current verification method:
→ Use instant verification (terminal command/temp script)
→ Cover core path + 2-3 key edge cases
```

### Case B: Uncertain Complexity

If AI cannot clearly determine complexity:

```
📊 Complexity Assessment: 🟡 Medium Change (uncertain)
- Change size: 3 files, 50 lines
- Function type: May affect core flow
- Impact scope: Needs further confirmation

📌 Choose verification method:
[1] Instant verification - terminal command/temp script (fast)
[2] Cucumber verification - run BDD scenarios (safer)

💡 Suggestion: If unsure about impact scope, choose [2] for safety
```

## Summary

**Decision Tree for Choosing Verification Method**:

```
Code change complete
    ↓
Assess complexity
    ↓
┌─────────┬─────────┬─────────┐
│ 🟢 Simple│ 🟡 Medium│ 🔴 Complex│
│ ≤2 files│ 3-5 files│ >5 files│
│ ≤30 lines│ single  │ cross   │
│         │ module  │ module  │
└─────────┴─────────┴─────────┘
    ↓         ↓         ↓
 Instant   User     Cucumber
  (fast)   Choice   (comprehensive)
           (balanced)
```

**Core Principles**:
- Small changes don't need Cucumber (reduce cost)
- Large changes must use Cucumber (ensure quality)
- Medium changes let user choose based on actual situation (flexible balance)
