# Survey Mode

> Use when you are new to the repository or need a project map. Primary outputs: `project-map.md`, `module-registry.md`, and a debt / abstraction-opportunity summary.

## Flow

1. scan the structure
   - directory tree
   - file counts
   - entrypoints
   - largest files
2. analyze modules
   - responsibility
   - dependencies
   - rough health signal
3. identify abstraction opportunities
   - 3+ repeated patterns: abstraction candidate
   - 2 repeated patterns: observe only
4. identify technical debt
5. update `project-map.md` and `module-registry.md`
6. optionally help define forbidden zones for future automation

## PM Summary

When helpful, summarize:
- what the project is
- tech stack
- rough scale
- major risks
- recommended next move
