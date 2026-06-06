---
Template: Symbol
Name: Unsatisfiable
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Unsatisfiable
Keywords: [Z3, SMT, unsatisfiable, result, no solution]
SeeAlso: [Z3Solve, Z3SatisfiableQ, Indeterminate]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Unsatisfiable]()</code> is the symbol [Z3Solve]() returns when the constraints have no solution.

## Details & Options

- Distinguishes a genuinely unsatisfiable problem from [Indeterminate]() (z3 could not decide) and from an [Association]() (a solution).
- Test for it directly, or use [Z3SatisfiableQ]() for a boolean answer.

## Basic Examples

Contradictory constraints make [Z3Solve]() return [Unsatisfiable]():

```wl
Z3Solve[x > 0 && x < 0, x \[Element] Integers]
```
<!-- => Unsatisfiable -->
