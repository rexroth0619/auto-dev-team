# Path Manifest System (path.md)

> 📍 Single source of truth for all fixed paths and configurations.

## Mechanism

**Every project must have `docs/path.md`** documenting all project-related fixed paths and configurations — the single source of truth for environment configuration.

## Required Contents

| Category | Example Content |
|------|----------|
| **Environment URLs** | Local, staging, production addresses and ports |
| **Server Paths** | Deployment directories, log directories, database paths |
| **Nginx Config** | Config file paths, SSL certificate paths |
| **Git Config** | Remote repo URLs, branch strategy, commit conventions |
| **Database** | Connection string templates, backup paths |
| **Third-Party Services** | API endpoints, console URLs, documentation links |
| **Common Commands** | Deploy, restart, backup command quick reference |

## Reference Rules

| Document | Must Include |
|------|----------|
| `docs/project-map.md` | Header reference `📍 Environment paths: see docs/path.md` |
| `docs/context-snapshot.md` | Header reference `📍 Environment paths: see docs/path.md` |

## AI Read Rules

These operations **must read `docs/path.md` first**:

- Deployment operations
- Git commit/push operations
- Environment config modifications
- Nginx config modifications
- Database operations
- Any operations involving server paths

## Auto-Detection and Creation

When entering any mode, the AI must:

1. Check if `docs/path.md` exists
2. If not, create from `assets/templates/path.md` template
3. Output: `📄 Created: docs/path.md (initialized from template — please fill in actual config)`

## Template Location

`assets/templates/path.md`

## Maintenance Rules

| Trigger | Action |
|------|------|
| Environment change | Update path.md |
| New service added | Add to path.md |
| Path change | Sync update path.md |
| Task completed | Check if path changes involved |

## Relationship with Other Documents

```
docs/path.md (environment paths)
    ↑ referenced by
docs/context-snapshot.md (project snapshot)
    ↑ referenced by
docs/project-map.md (architecture map)
```

These three documents cross-reference each other, forming a complete project knowledge system.
