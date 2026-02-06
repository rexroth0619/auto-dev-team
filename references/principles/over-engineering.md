# No Over-Engineering Principle

> ⛔ PMs cannot distinguish over-engineering — the AI must self-regulate.

## Definition

**Over-engineering = Adding features the PM didn't ask for**

Not to be confused with reasonable code abstraction (see `abstraction-rules.md`).

## Signs of Over-Engineering

- ❌ PM says "build a login," you add "third-party login, remember-me, and 2FA while we're at it"
- ❌ PM says "add a button," you add "a full button component library while we're at it"
- ❌ PM says "show a list," you add "sorting, filtering, pagination, and export while we're at it"
- ❌ Any "while we're at it," "might need later," or "easy to add" features
- ❌ Config options, toggles, or optional parameters the PM never mentioned

## Correct Approach

- ✅ Build only what the PM explicitly asked for — nothing more
- ✅ When tempted to add extras, ask the PM first: "Should we also support xxx?"
- ✅ If the PM says no, don't add it

## Self-Check Questions (Ask Before Writing Code)

1. Did the PM specify this, or do I think it "should exist"?
2. If the PM didn't mention it, why am I adding it?

**If the answer is "I think it should exist" → stop and ask the PM. Do not add it.**

## Distinction from Code Abstraction

| Type | Definition | Allowed? |
|------|------|---------|
| Over-engineering | Adding features the PM didn't ask for | ❌ Prohibited |
| Code abstraction | Extracting repeated logic into functions/modules | ✅ Required |

**Abstraction criteria**: See `abstraction-rules.md`
- Rule of Three: same logic 3+ times → must abstract
- Three-Question Rule: neutral operation? Future reuse? Simpler API?

## Examples

### ❌ Over-Engineering

PM: "Build a user list page"

You built:
- User list ✅
- Pagination ❌ (PM didn't ask)
- Sorting ❌ (PM didn't ask)
- Filtering ❌ (PM didn't ask)
- Excel export ❌ (PM didn't ask)
- Batch delete ❌ (PM didn't ask)

### ✅ Correct Approach

PM: "Build a user list page"

You ask: "Do you need pagination? Sorting and filtering?"

PM: "Pagination yes, nothing else"

You built:
- User list ✅
- Pagination ✅
- Nothing else added
