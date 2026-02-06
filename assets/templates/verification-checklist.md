# Verification Checklist

> 💡 Optional. Say "run verification" when done, or "I trust the result" to skip.

## Functional (PM Check)

- [ ] **Core functionality**: Does the feature work?
- [ ] **Edge cases**: Correct with empty data, invalid input?
- [ ] **UX**: Smooth operation, no lag?

## Technical (AI Auto-completes)

- [ ] No lint errors
- [ ] Related tests pass (if any)
- [ ] Docs updated (project-map / module-registry)
- [ ] Checkpoint created

## Regression

- [ ] Existing features unaffected
- [ ] Related pages/features work normally

---

## Quick Verification Flow

### Minor Changes (FastTrack)
```
AI: "✅ Done — modified [N] files"

PM options:
[1] Review the result → Manual verification
[2] Finish → Trust the result
```

### New Feature
```
AI: "✅ Task complete — [N] steps executed"

PM options:
[1] Verification checklist → Check each item
[2] Quick verification → Core functionality only
[3] Finish → Trust the result
```

### Bug Fix
```
AI: "✅ Bug fixed"

PM must verify:
1. Reproduce with original steps → Issue should be gone
2. Related features work → No new issues introduced
```

---

*Checklist auto-adjusts based on task type*
