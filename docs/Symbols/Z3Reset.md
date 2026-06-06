---
Template: Symbol
Name: Z3Reset
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3Reset
Keywords: [Z3, SMT, reset, clear, solver]
SeeAlso: [Z3Push, Z3Pop, Z3Assert, Z3CreateSolver]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3Reset]()[*solver*]</code> clears all assertions and declarations from *solver*, returning it to its empty state; returns the solver.

## Details & Options

- Unlike [Z3Pop](), reset discards every scope and every declared variable.
- The underlying z3 process stays alive and ready for new assertions.

## Basic Examples

Assert and check some constraints:

```wl
s = Z3CreateSolver[]; Z3Assert[s, x > 5, x \[Element] Integers]; Z3CheckSat[s]
```
<!-- => "sat" -->

Reset, then assert fresh contradictory constraints:

```wl
Z3Reset[s]; Z3Assert[s, x > 5, x \[Element] Integers]; Z3Assert[s, x < 3, x \[Element] Integers]; Z3CheckSat[s]
```
<!-- => "unsat" -->
