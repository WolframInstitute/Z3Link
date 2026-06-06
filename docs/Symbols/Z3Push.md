---
Template: Symbol
Name: Z3Push
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3Push
Keywords: [Z3, SMT, push, scope, backtrack]
SeeAlso: [Z3Pop, Z3Reset, Z3Assert]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3Push]()[*solver*]</code> saves *solver*'s current assertion scope, so a later [Z3Pop]() can restore it; returns the solver.

## Details & Options

- Assertions made after a push are discarded by the matching [Z3Pop]().
- Pushes nest, giving a stack of scopes for exploring assumptions.

## Basic Examples

Assert a base constraint and check it:

```wl
s = Z3CreateSolver[]; Z3Assert[s, x > 0 && x < 10, x \[Element] Integers]; Z3CheckSat[s]
```
<!-- => "sat" -->

Push a scope, add a stronger assumption, and re-check:

```wl
Z3Push[s]; Z3Assert[s, x > 8, x \[Element] Integers]; Z3CheckSat[s]
```
<!-- => "sat" -->

The model now reflects the extra assumption:

```wl
Z3Model[s]
```
<!-- => <|x -> 9|> -->
