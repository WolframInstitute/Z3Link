---
Template: Symbol
Name: Z3SatisfiableQ
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3SatisfiableQ
Keywords: [Z3, SMT, satisfiability, predicate]
SeeAlso: [Z3Solve, Z3ProvableQ, Z3CheckSat, Z3Exists]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3SatisfiableQ]()[*constraints*, *vars* ∈ *domain*]</code> returns [True]() if *constraints* have a solution, [False]() if not, and [Indeterminate]() if Z3 cannot decide.

## Details & Options

- It is the boolean companion to [Z3Solve](): satisfiable exactly when [Z3Solve]() returns an [Association]().
- The domain argument is optional when the constraints are built from typed handles.

## Basic Examples

A quadratic over the reals is satisfiable:

```wl
Z3SatisfiableQ[x^2 == 2, x \[Element] Reals]
```
<!-- => True -->

## Scope

Contradictory constraints are unsatisfiable:

```wl
Z3SatisfiableQ[x > 0 && x < 0, x \[Element] Integers]
```
<!-- => False -->

---

Test an existential claim with [Z3Exists]():

```wl
Z3SatisfiableQ[Z3Exists[x \[Element] Integers, x^2 == 9], {}]
```
<!-- => True -->
