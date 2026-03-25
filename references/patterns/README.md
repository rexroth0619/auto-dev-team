# Patterns Library

> Reusable engineering experience captured for later retrieval.

## Layout

```text
patterns/
├── README.md
├── universal/
├── language/
└── platform/
```

## Layers

| Layer | Directory | Scope |
|------|-----------|-------|
| universal | `universal/` | language-agnostic design ideas |
| language | `language/` | language-specific pitfalls and idioms |
| platform | `platform/` | platform-specific practices |

## Retrieval Rule

When pattern reuse is clearly needed:
1. identify the domain
2. identify the language and platform
3. search `universal/` first
4. then language-specific docs
5. then platform-specific docs
