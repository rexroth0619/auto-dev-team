# Refactor Mode

> Use for structural cleanup, splitting, extraction, and removing architectural friction without changing intended behavior.

## Goals

- improve structure without silently changing behavior
- keep rollback and verification strong
- avoid speculative redesign

## Flow

1. define the explicit refactor target
2. map direct callers, consumers, and contracts with blast radius
3. decide whether to split, extract, or relocate responsibilities
4. run critique on scope and design risk
5. plan incremental steps
6. execute through Step mode
7. use `L3` observation-driven validation by default

## Mandatory Checks

- confirm behavior parity
- avoid mixing refactor with unrelated feature work
- when a shared abstraction appears, use the abstraction rules rather than inventing a generic framework
