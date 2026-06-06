---
Template: Symbol
Name: Z3Model
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3Model
Keywords: [Z3, SMT, model, assignment, solution]
SeeAlso: [Z3CheckSat, Z3Eval, Z3Assert]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3Model]()[*solver*]</code> returns the model - an [Association]() of variable -> value - from *solver*'s last successful [Z3CheckSat]().

## Details & Options

- Call it only after a `"sat"` check; values are exact, as in [Z3Solve]().
- Array- and function-valued entries come back as callable pure functions.

## Basic Examples

Assert, check, then read the satisfying assignment:

```wl
s = Z3CreateSolver[]; Z3Assert[s, x > 3 && x < 9, x \[Element] Integers]; Z3CheckSat[s]
```
<!-- => "sat" -->

The model maps each variable to a value:

```wl
Z3Model[s]
```
<!-- => <|x -> 4|> -->
