# Optimize Mode

> Use for performance work. Measure first, optimize second.

## Flow

1. define the slow path and target metric
2. reproduce and measure the baseline
3. run blast radius on the intended optimization target
4. decide whether the issue is algorithmic, I/O, rendering, or contention-related
5. propose the smallest meaningful optimization
6. run critique
7. execute through Step mode when the work is multi-step
8. validate both performance improvement and behavior correctness

## Rules

- do not optimize before confirming the bottleneck
- do not trade correctness for speed silently
- use `L3` observation-driven validation when regression risk is non-trivial
