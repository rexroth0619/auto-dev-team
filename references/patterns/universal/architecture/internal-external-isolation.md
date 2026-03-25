# Internal / External Isolation

> Internal-network acceleration or optimization must never leak internal addresses or assumptions to public users.

## Problem

A system has separate internal and external network paths. Internal acceleration logic often leaks internal URLs into responses, pages, or downloads.

## Preferred Approach

- keep public outputs on public addresses
- keep internal routing private to backend-side hops
- validate all user-visible URLs after optimization work
