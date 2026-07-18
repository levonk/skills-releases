---
type: Practice
title: BigDecimal Pitfalls — equals() vs compareTo() for Numerical Equality
description: BigDecimal.equals() compares both value and scale; use compareTo() when checking numerical equality to avoid silent inequality bugs from trailing zeros.
tags: [java, bigdecimal, equality, pitfall, equals, compareto]
timestamp: 2026-07-17T00:00:00Z
---

# BigDecimal Pitfalls

## Failure Mode

Two `BigDecimal` values that represent the same number compare as unequal
because `equals()` checks both the numeric value and the scale (number of
fractional digits). This leads to silent bugs in tests, map lookups, and
business logic.

## Symptoms

- `new BigDecimal("1.0").equals(new BigDecimal("1.00"))` returns `false`.
- `HashMap<BigDecimal, ...>` lookups fail for values that differ only in scale.
- Unit tests pass for `1.0` but fail for `1.00` or vice versa.
- Financial calculations appear correct but equality checks reject valid values.

## Practice

### Use compareTo() for Numerical Equality

```java
BigDecimal a = new BigDecimal("1.0");
BigDecimal b = new BigDecimal("1.00");

// Correct
if (a.compareTo(b) == 0) { ... }

// Wrong unless you explicitly want scale equality
if (a.equals(b)) { ... } // false
```

### Set Scale Explicitly When Needed

- Call `setScale(int, RoundingMode)` before `equals()` if scale matters.
- Use `stripTrailingZeros()` cautiously — it changes scale but can also change
  output format (`1E+3` for `1000`).

### Test with Different Scales

- Include test cases for `1.0`, `1.00`, `1.000`, and `0.10`/`0.1` to catch
  scale-sensitive logic.

### Hash Collections

- Do not use `BigDecimal` as a `HashMap` key or `HashSet` element unless the
  scale is strictly controlled, because two numerically equal values with
  different scales will occupy different buckets.

## When equals() Is Correct

`equals()` is correct only when you genuinely care about both numeric value and
scale, such as verifying that a parsed value has not been normalized.

## Citations

[1] [2ndbrain BigDecimal article](https://igorstechnoclub.com/java-bigdecimal/) — Igor's Techno Club, captured 2024-06-19
[2] [BigDecimal Javadoc](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/math/BigDecimal.html)
