---
Template: Symbol
Name: Z3Optimize
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3Optimize
Keywords: [Z3, SMT, optimization, maximize, minimize]
SeeAlso: [Z3Maximize, Z3Minimize, Z3Solve, Z3CreateSolver]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3Optimize]()[*objective* -> Maximize, *constraints*, *vars* ∈ *domain*]</code> maximizes *objective* subject to *constraints*, returning an [Association]() with `"Status"`, `"Objective"`, and `"Model"` keys.

<code>[Z3Optimize]()[*objective* -> Minimize, *constraints*, *vars* ∈ *domain*]</code> minimizes *objective* instead.

## Details & Options

- The direction is given as a [Rule](): `objective -> Maximize` or `objective -> Minimize`.
- When the constraints are unsatisfiable the result is `<|"Status" -> "unsat"|>` with no model.
- It accepts the same `"Timeout"`, `"Numeric"`, and `"Options"` options as [Z3Solve]().
- For an incremental optimizer, use [Z3CreateSolver]()["Optimize"] with [Z3Maximize]() / [Z3Minimize]().

## Basic Examples

Maximize *x* under bounds:

```wl
Z3Optimize[x -> Maximize, x > 0 && x < 100, x \[Element] Integers]
```
<!-- => <|"Status" -> "sat", "Objective" -> 99, "Model" -> <|x -> 99|>|> -->
