# Explain Mode (Code Understanding)

> Applies to: Understanding how code works, "How is XXX implemented?" | Output: Call chain visualization

## AI Must Proactively Read

On entry, AI must find and read files related to the mentioned functionality (without user providing them).

## Applicable Scenarios

- Onboarding, learning the codebase
- Understanding feature implementation logic
- Quick familiarization before code review
- Understanding call relationships before impact assessment

## Workflow (Single Phase)

```
User: How is the user login flow implemented?
      @LoginButton.tsx

AI:   🔥 AutoDevTeam - Explain Activated
      
      📊 [User Login] Implementation Path:
      
      Entry: LoginButton.tsx:25
      ├─ onClick → handleLogin() @ auth.ts:45
      │  ├─ validateForm() @ validator.ts:12
      │  │  └─ checkEmail() + checkPassword()
      │  ├─ POST /api/login @ api.ts:78
      │  └─ onSuccess()
      │     ├─ saveToken() → localStorage
      │     └─ navigate('/dashboard')
      
      🔄 Data Flow:
      email/password → Validation → API request → token → Storage → Redirect
      
      💡 In one sentence: After form validation, calls login API; on success, stores token and redirects to home
      
      📂 Core Files:
      - auth.ts - Main login logic
      - validator.ts - Form validation rules
      - api.ts - API wrapper
```

## Output Principles

- **Call chain depth ≤3 levels** (guide user to ask deeper if needed)
- **Total output ≤400 words**
- **Structure only, no code expansion** (unless user asks)
- **Annotate file paths and line numbers**
- **Explain key branch points** (e.g. if/switch paths)

## Deep Follow-up Handling

```
User: "What exactly does validateForm do?"

AI:   📊 validateForm() Detailed Expansion:
      
      Location: validator.ts:12-28
      
      ├─ checkEmail(email)
      │  → Regex format validation
      │  → Returns boolean
      ├─ checkPassword(password)  
      │  → Length ≥8
      │  → Contains digits + letters
      │  → Returns boolean
      └─ Returns: { valid: boolean, errors: string[] }
      
      Edge handling:
      - Empty value → "Field cannot be empty"
      - Invalid format → Specific error message
```

## Boundaries with Other Modes

| Scenario | Which Mode |
|----------|-----------|
| Just want to understand, no changes | **Explain** |
| Understand then add feature | Explain → Architect |
| Understand then fix bug | Explain → Debug |
| Understand then refactor | Explain → Refactor |
| Full project architecture | **Survey** (not Explain) |

## Completion Options

```
📍 Current: Explained implementation path of "[feature]"
📌 Next:
[1] Go deeper (continue autoDevTeam/explain workflow) - Expand a function: [list expandable functions]
[2] Start development (enter autoDevTeam/architect workflow)
[3] Debug issue (enter autoDevTeam/debug workflow)
[4] Refactor code (enter autoDevTeam/refactor workflow)
[0] Done
```

## Mandatory Rules

- Must output visual call chain (tree structure)
- Must annotate file paths and line numbers
- Do not paste large code blocks (describe structure only)
- May flag obvious issues, but do not proactively fix
- Beyond 3 levels → Collapse details, guide user to ask deeper

## Difference from Ask Mode

```
Ask Mode (Cursor native):
- Free-form Q&A, no fixed format
- Suitable for conceptual questions like "What is a closure?"

Explain Mode (AutoDevTeam):
- Standardized output (call chain visualization)
- Focused on code implementation paths
- Suitable for "How is this feature implemented?"
```
