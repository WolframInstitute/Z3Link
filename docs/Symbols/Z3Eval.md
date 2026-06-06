---
Template: Symbol
Name: Z3Eval
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3Eval
Keywords: [Z3, SMT, evaluate, model, term]
SeeAlso: [Z3Model, Z3CheckSat, Z3Assert]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3Eval]()[*solver*, *expr*]</code> evaluates *expr* in *solver*'s current model.

## Details & Options

- Valid after a `"sat"` [Z3CheckSat](); *expr* may mention any declared variable.
- Use it to read a derived quantity without adding it as a variable.

## Basic Examples

Set up and check a solver:

```wl
s = Z3CreateSolver[]; Z3Assert[s, x > 3 && x < 10, x \[Element] Integers]; Z3CheckSat[s]
```
<!-- => "sat" -->

Evaluate an expression in the model:

```wl
Z3Eval[s, x + 1]
```
<!-- => 5 -->
