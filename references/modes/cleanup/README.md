# Cleanup Mode (Code Cleanup)

> Applies to: Remove unused code, clean up redundancies | Types: Dead code / Redundant dependencies / Temporary code

## AI Must Proactively Read

On entry, AI must read (without user providing):
- `docs/project-map.md` - Project structure

## Cleanup Types

### 1. Dead Code
```
AI:   Scan for unused:
      - Uncalled functions
      - Unused variables
      - Unused imports
      - Commented-out code blocks
      
      📋 Pending cleanup:
      | File | Line | Type | Content |
      |------|------|------|---------|
      
      "Confirm deletion?"
```

### 2. Redundant Dependencies
```
AI:   Check dependency files (package.json / requirements.txt / go.mod / Cargo.toml):
      - Unused dependencies
      - Duplicate dependencies
      - Mergeable dependencies
```

### 3. Temporary Code
```
AI:   Scan for:
      - TODO/FIXME comments
      - Debug statements (console.log / print / fmt.Println)
      - Debug breakpoints (debugger / breakpoint())
      - Temporary hardcoded values
```

## Workflow

```
0. Create checkpoint
1. Scan → Output list
2. User confirms scope
3. Clean up item by item
4. Verify + Rollback (see checkpoint mechanism)
5. Auto-update module-registry.md (if registered components removed)
```

## Safety Rules

- Confirm no callers before deletion
- Batch deletions require user re-confirmation
- Retain deletion records for rollback

## Cleanup Completion Options

```
📍 Current: Cleaned up [N] items, removed [files/lines of code]
📌 Next:
[1] Continue cleanup (continue autoDevTeam/cleanup workflow) - Scan for other redundant code types
[2] Develop new feature (enter autoDevTeam/architect workflow)
[3] Refactor code (enter autoDevTeam/refactor workflow) - Further organize code structure
[0] Done
```
