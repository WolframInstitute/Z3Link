---
Template: Symbol
Name: Z3CheckSat
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3CheckSat
Keywords: [Z3, SMT, check, satisfiability, sat, unsat]
SeeAlso: [Z3Assert, Z3Model, Z3UnsatCore, Z3SatisfiableQ]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3CheckSat]()[*solver*]</code> checks satisfiability of *solver*'s current assertions, returning `"sat"`, `"unsat"`, or `"unknown"`.

## Details & Options

- After a `"sat"` result, read the model with [Z3Model]() or evaluate terms with [Z3Eval]().
- After an `"unsat"` result, [Z3UnsatCore]() reports a conflicting subset of the assertions.

## Basic Examples

Assert and check satisfiable constraints:

```wl
s = Z3CreateSolver[]; Z3Assert[s, x > 3 && x < 9, x \[Element] Integers]; Z3CheckSat[s]
```
<!-- => "sat" -->

## Scope

Contradictory assertions are unsatisfiable:

```wl
t = Z3CreateSolver[]; Z3Assert[t, x > 5 && x < 3, x \[Element] Integers]; Z3CheckSat[t]
```
<!-- => "unsat" -->
