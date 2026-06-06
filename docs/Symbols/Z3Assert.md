---
Template: Symbol
Name: Z3Assert
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3Assert
Keywords: [Z3, SMT, assert, constraints, solver]
SeeAlso: [Z3CreateSolver, Z3CheckSat, Z3Model, Z3UnsatCore, Z3Reset]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3Assert]()[*solver*, *constraints*, *vars* ∈ *domain*]</code> adds *constraints* to *solver*, declaring any new variables, and returns the solver.

## Details & Options

- New variables are declared automatically; a variable already declared keeps its sort.
- The domain argument is optional when the constraints are built from typed handles.
- Returns the [Z3SolverObject]() so calls can be chained.

## Basic Examples

Assert constraints into a fresh solver:

```wl
s = Z3CreateSolver[]; Z3Assert[s, x > 0 && x < 10, x \[Element] Integers]
```
<!-- => Z3SolverObject[<Solver:1>] -->

Then check satisfiability of what was asserted:

```wl
Z3CheckSat[s]
```
<!-- => "sat" -->
