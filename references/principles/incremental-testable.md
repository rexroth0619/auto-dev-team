# Incremental Testability Principle

> All multi-step tasks must follow incremental testability — each step produces an independently verifiable deliverable.

## Core Requirements

1. System must remain runnable after each step
2. Each step produces a verifiable module/feature/output
3. Each step has logs proving correctness
4. Accumulating multiple steps for final verification is prohibited

## Judgment Criteria

**Ask**: If we stopped after this step, could we verify it's correct?
- ✅ Yes → Decomposition is sound
- ❌ No → Re-decompose

## Good Decomposition Examples (Independently Verifiable)

### ✅ Step 1: Implement Data Transformation Function
- **Deliverable**: transformData() function
- **Verification**: Unit test / log input-output
- **Testable**: Fully independent

### ✅ Step 2: Implement API Wrapper
- **Deliverable**: fetchUserData() function
- **Verification**: Mock data test / log request-response
- **Testable**: Fully independent

### ✅ Step 3: Integrate into UI
- **Deliverable**: Complete feature
- **Verification**: UI rendering + interaction / log full flow
- **Testable**: Fully independent

## Bad Decomposition Examples (Not Independently Verifiable)

### ❌ Step 1: Define Types and Interfaces
- **Problem**: Only type definitions, nothing runnable
- **Correct**: Merge into the first implementation step

### ❌ Step 2: Implement First Half of Logic
- **Problem**: Incomplete, correctness unverifiable
- **Correct**: Decompose into complete sub-features

### ❌ Step 3: Complete Remaining Logic
### ❌ Step 4: Test Overall Feature
- **Problem**: Verification deferred to end
- **Correct**: Each step should be testable

## Incremental Testability in Refactoring

### ✅ Correct Approach
```
Step 1: Extract function A and verify equivalence
- Deliverable: new function + old function
- Verification: compare logs, output is identical
   
Step 2: Replace call site X and verify
- Deliverable: updated call
- Verification: behavior unchanged, logs consistent
```

### ❌ Wrong Approach
```
Step 1: Extract 3 functions
Step 2: Test all at once
- Problem: cannot pinpoint which function has issues
```

## Incremental Testability in Optimization

### ✅ Correct Approach
```
Step 1: Add caching mechanism
- Deliverable: cache module
- Verification: logs show hit/miss, compare request counts
```

### ❌ Wrong Approach
```
Step 1: Add caching
Step 2: Optimize algorithm
Step 3: Test overall performance
- Problem: cannot isolate the effect of each optimization
```

## Execution Principles

- If a step cannot be independently verified → **stop and re-decompose**
- If user says "implement first, test last" → **refuse; explain incremental testability**
- Trust mode still requires each step to be testable — just without waiting for confirmation
