# TEST-NEEDS: ZeroProb.jl

## Current State

| Category | Count | Details |
|----------|-------|---------|
| **Source modules** | 7 | 3,222 lines |
| **Test files** | 9 | 1,193 lines, 390 @test/@testset |
| **Benchmarks** | 0 | None |
| **E2E tests** | 0 | None |

## What's Missing

### E2E Tests
- [ ] No end-to-end probability computation pipeline test

### Aspect Tests
- [ ] **Performance**: No benchmarks for probabilistic computations
- [ ] **Error handling**: No tests for numerical stability, underflow/overflow in probability space

### Benchmarks Needed
- [ ] Probability computation throughput
- [ ] Numerical precision under extreme values

### Self-Tests
- [ ] No self-consistency check

## FLAGGED ISSUES
- **390 tests across 9 files** -- excellent coverage and organization
- **7 modules with 390 tests = 56 tests/module** -- best ratio among Julia packages
- **0 benchmarks** for a numerical library -- needs performance baselines

## Priority: P3 (LOW) -- well tested, needs benchmarks

## FAKE-FUZZ ALERT

- `tests/fuzz/placeholder.txt` is a scorecard placeholder inherited from rsr-template-repo — it does NOT provide real fuzz testing
- Replace with an actual fuzz harness (see rsr-template-repo/tests/fuzz/README.adoc) or remove the file
- Priority: P2 — creates false impression of fuzz coverage
