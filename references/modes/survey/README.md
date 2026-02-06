# Survey Mode (Project Reconnaissance)

> Applies to: Just inherited a project, want to understand structure | Output: project-map.md, module-registry.md, abstraction opportunity list

## AI Must Proactively Execute

On entry, AI scans project structure without user providing any files.

## Workflow

### Phase 1: Structure Scan
```
AI:   Scan project, output:
      
      📁 Directory Structure:
      src/
      ├── app/      # [Inferred responsibility]
      ├── utils/    # [Inferred responsibility]
      └── ...
      
      📊 File Statistics:
      - Total files: X
      - Largest file: xxx (Y lines)
      - Entry point: xxx
```

### Phase 2: Module Analysis
```
AI:   Per-module analysis:
      
      | Module | Responsibility | Dependencies | Health |
      |--------|---------------|--------------|--------|
      | A      | xxx           | B,C          | 🟢Good |
      | B      | xxx           | C            | 🟡Fair |
      | C      | xxx           | -            | 🔴Poor |
```

### Phase 2.5: Abstraction Opportunity Identification (Rule of Three)
```
AI:   Scan for duplicate/similar patterns:
      
      🔷 Abstraction Opportunity List:
      | Finding | Locations | Occurrences | Suggestion | Priority |
      |---------|-----------|-------------|------------|----------|
      | Similar validation logic | a.ts, b.ts, c.ts | 3x | Extract as validateXxx() | P1 |
      | Duplicate data transform | x.ts, y.ts | 2x | Do not abstract yet, observe | - |
      | Generic traversal pattern | Multiple places | 5x | Extract as traverseXxx() | P0 |
      
      Criteria:
      - 3+ occurrences → Must abstract (assign priority)
      - 2 occurrences → Flag for observation
      - 1 occurrence → Ignore
```

### Phase 3: Tech Debt Identification
```
AI:   🔍 Tech Debt List:
      
      | Priority | Location | Issue | Suggestion |
      |----------|----------|-------|-----------|
      | P0 | utils.ts | 523 lines | Split |
      | P1 | xxx | xxx | xxx |
      
      🔷 Abstraction-Related Tech Debt:
      | Priority | Issue | Suggestion |
      |----------|-------|-----------|
      | P0 | 3 duplicate scan logic instances | Abstract as ScanUtility |
      | P1 | Multiple similar formatters | Abstract as Formatter |
```

### Phase 4: Output Documentation
```
AI:   1. Generate/Update project-map.md
      2. Generate/Update module-registry.md
      3. "Top priority: [xxx]"
```

### Phase 4.5: PM Summary (Adaptive)

**Trigger**: User uses business language or is new to the project

```
📊 Project Overview

What it is: [One-sentence description]
Tech stack: [Main technologies, plain language]
Scale: Small / Medium / Large
Health: 🟢Good / 🟡Fair / 🔴Needs attention

Main risks:
1. [Business language]
2. [Business language]

Suggestion: [What to do next]
```

**Skip**: User states familiarity, or says "just the technical details"

### Phase 5: Forbidden Zones Configuration (First Time)

**Trigger**: First Survey and `docs/forbidden-zones.md` not configured

```
AI:   "🔒 Configure forbidden zones?
      
      Forbidden zones = Files/directories AI cannot auto-modify
      
      Common configurations:
      - .env* (environment variables)
      - migrations/ (database migrations)
      - Core configuration files
      
      [1] Configure - Create docs/forbidden-zones.md
      [2] Skip - No restrictions needed
      "
```

## Deliverables

- project-map.md (Architecture map)
- module-registry.md (Component registry)
- Tech debt priority list
- forbidden-zones.md (Optional, first-time)

## Reconnaissance Completion Options

```
📍 Current: Reconnaissance complete, [N] tech debt items, [M] abstraction opportunities
📌 Next:
[1] Address tech debt (enter autoDevTeam/refactor workflow) - P0: [brief description]
[2] Extract abstractions (enter autoDevTeam/refactor workflow) - Duplicate code: [brief description]
[3] Develop new feature (enter autoDevTeam/architect workflow)
[4] Clean up code (enter autoDevTeam/cleanup workflow) - Dead code and redundant dependencies
[5] Configure forbidden zones - Set files AI cannot auto-modify (recommended first time)
[0] Done
```
