---
Template: Symbol
Name: Z3Maximize
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3Maximize
Keywords: [Z3, SMT, optimization, maximize, objective]
SeeAlso: [Z3Minimize, Z3Optimize, Z3CreateSolver]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3Maximize]()[*solver*, *objective*]</code> adds a maximization *objective* to an optimizer created by [Z3CreateSolver]()["Optimize"]; returns the solver.

## Details & Options

- The solver must be an optimizer (`Z3CreateSolver["Optimize"]`).
- After adding objectives, call [Z3CheckSat]() and read the optimum with [Z3Model]().

## Basic Examples

Create an optimizer and constrain two nonneg­ative integers summing to 10:

```wl
o = Z3CreateSolver["Optimize"]; Z3Assert[o, x + y == 10 && x >= 0 && y >= 0, {x, y} \[Element] Integers]; Z3Maximize[o, x*x + y*y]; Z3CheckSat[o]
```
<!-- => "sat" -->

The maximizing assignment pushes the sum to one corner:

```wl
Z3Model[o]
```
<!-- => <|x -> 10, y -> 0|> -->
