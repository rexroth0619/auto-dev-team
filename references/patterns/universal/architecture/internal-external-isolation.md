# Internal/External Network Isolation Principle

> One-liner: internal optimization must not expose internal addresses to external users

## Scope

| Dimension | Scope |
|-----------|-------|
| Language | Universal |
| Platform | Universal (especially cloud services) |

## Problem

To improve performance or cut costs, servers use internal network addresses for storage/databases/services. If internal addresses leak to external users, those users cannot access the resources.

**Typical scenarios**:
- Cloud storage (OSS/S3) with internal access generates signed URLs containing internal addresses
- Database connection strings use internal addresses but config files are read by the frontend
- Microservices use internal domains but mistakenly return them to clients

## Solution (Conceptual)

```
┌─────────────────────────────────────────────────────────────┐
│                     Server Internal                         │
│                                                             │
│   [Business Logic] ──internal addr──> [Storage/Service]     │
│       │                                                     │
│       │ When generating external access links               │
│       ▼                                                     │
│   [Address Translation Layer]                               │
│       │                                                     │
│       │ Replace with public address/custom domain           │
│       ▼                                                     │
│   [Return to User]                                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Key**: Before returning to user, an **address translation layer** must:
1. Replace internal addresses with public addresses
2. Cover all internal address formats

## Key Decision Points

- **Translation timing**: Translate just before returning to user, not at generation time
  - Reason: Server still needs internal addresses for performance
  
- **Translation coverage**: Must cover all address formats
  - Public: `xxx.oss-cn-hangzhou.aliyuncs.com`
  - Internal: `xxx.oss-cn-hangzhou-internal.aliyuncs.com`
  - VPC: `xxx.oss-cn-hangzhou.internal.aliyuncs.com` (some cloud services)

## Boundary Conditions

- **Not applicable**: Purely internal systems (no external user access)
- **Special handling**: If users share the same internal network (e.g., enterprise intranet), return different addresses based on user network environment

## Checklist

**When adding internal optimization**:
- [ ] List all URL/address generation points
- [ ] Verify each has address translation logic
- [ ] Verify translation covers all internal formats (public, internal, VPC)
- [ ] Verify end-to-end test: access generated URLs from user's perspective

**During code review**:
- [ ] Search for `internal`, `vpc`, `private` keywords
- [ ] Verify these addresses are not returned to users

## Examples

### Incorrect Example

```javascript
// Enable internal access
const ossClient = new OSS({ internal: true });

// Generate signed URL (contains internal address)
let url = ossClient.signatureUrl(objectKey);

// ❌ Incorrect: only replaces public format
const publicDomain = `${bucket}.${region}.aliyuncs.com`;
url = url.replace(publicDomain, customDomain);
// Internal format xxx-internal.aliyuncs.com is not replaced!
```

### Correct Example

```javascript
// ✅ Correct: replaces both public and internal formats
const publicDomain = `${bucket}.${region}.aliyuncs.com`;
const internalDomain = `${bucket}.${region}-internal.aliyuncs.com`;
url = url.replace(publicDomain, customDomain);
url = url.replace(internalDomain, customDomain);
```

---
*Tags*: `internal-optimization`, `address-translation`, `cloud-storage`, `OSS`, `S3`, `signed-URL`, `security`
