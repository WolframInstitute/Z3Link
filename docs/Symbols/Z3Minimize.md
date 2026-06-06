---
Template: Symbol
Name: Z3Minimize
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3Minimize
Keywords: [Z3, SMT, optimization, minimize, objective]
SeeAlso: [Z3Maximize, Z3Optimize, Z3CreateSolver]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3Minimize]()[*solver*, *objective*]</code> adds a minimization *objective* to an optimizer created by [Z3CreateSolver]()["Optimize"]; returns the solver.

## Details & Options

- The solver must be an optimizer (`Z3CreateSolver["Optimize"]`).
- After adding objectives, call [Z3CheckSat]() and read the optimum with [Z3Model]().

## Basic Examples

Constrain two integers ≥ 2 summing to 10 and minimize their squared length:

```wl
o = Z3CreateSolver["Optimize"]; Z3Assert[o, x + y == 10 && x >= 2 && y >= 2, {x, y} \[Element] Integers]; Z3Minimize[o, x*x + y*y]; Z3CheckSat[o]
```
<!-- => "sat" -->

The minimizer balances the two variables:

```wl
Z3Model[o]
```
<!-- => <|x -> 5, y -> 5|> -->
