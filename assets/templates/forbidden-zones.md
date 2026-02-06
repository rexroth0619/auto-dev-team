# Forbidden Zones Configuration

> ⚠️ Configure once, AI auto-complies. Warnings trigger only when a forbidden zone is touched.

## Absolutely Forbidden

<!-- AI must never modify these — halts and warns if encountered -->

```
# Examples (configure per project)
.env*                    # Environment variables
*.lock                   # Dependency lock files
migrations/              # Database migrations
```

## Requires Approval

<!-- AI may propose changes but must await explicit confirmation -->

```
# Examples
src/core/               # Core modules
api/                    # Public-facing interfaces
config/                 # Configuration files
```

## Sensitive Areas

<!-- Extra caution required for changes here -->

```
# Examples
src/auth/               # Authentication
src/payment/            # Payment processing
```

---

## AI Behavior on Forbidden Zones

### Absolutely Forbidden
```
⛔ Execution halted

Touches forbidden zone: [xxx]
Reason: [Why this modification is needed]

Requires manual handling — cannot modify directly.
```

### Requires Approval
```
⚠️ Confirmation required

Touches sensitive zone: [xxx]
Change details: [What exactly will be modified]
Impact scope: [What could be affected]

[1] Confirm modification
[2] Skip this change
[0] Cancel entire operation
```

---

*On first use, AI will ask whether to configure forbidden zones after Survey mode*
