---
Template: Symbol
Name: Z3Pop
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3Pop
Keywords: [Z3, SMT, pop, scope, backtrack]
SeeAlso: [Z3Push, Z3Reset, Z3Assert]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3Pop]()[*solver*]</code> restores the most recently pushed scope, discarding assertions made since that [Z3Push](); returns the solver.

## Details & Options

- Each pop undoes exactly one matching [Z3Push]().
- After a pop you must re-run [Z3CheckSat]() before reading a model.

## Basic Examples

Push a scope and add a temporary assumption:

```wl
s = Z3CreateSolver[]; Z3Assert[s, x > 0 && x < 10, x \[Element] Integers]; Z3Push[s]; Z3Assert[s, x > 8, x \[Element] Integers]; Z3CheckSat[s]
```
<!-- => "sat" -->

Pop it, then re-check the base constraints:

```wl
Z3Pop[s]; Z3CheckSat[s]
```
<!-- => "sat" -->
