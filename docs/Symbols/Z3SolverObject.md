---
Template: Symbol
Name: Z3SolverObject
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3SolverObject
Keywords: [Z3, SMT, solver, object, incremental]
SeeAlso: [Z3CreateSolver, Z3Assert, Z3CheckSat, Z3Model]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3SolverObject]()[…]</code> represents an incremental Z3 solver or optimizer instance backed by a live z3 process.

## Details & Options

- Create one with [Z3CreateSolver](); it holds an assertion stack you grow with [Z3Assert]() and query with [Z3CheckSat](), [Z3Model](), and [Z3Eval]().
- It displays as `Z3SolverObject[<Solver:id>]`, with a `dead` tag once its process has ended.
- Applying [DeleteObject]() to it terminates the underlying z3 process.

## Basic Examples

Creating a solver returns a [Z3SolverObject]() backed by a live process:

```wl
Z3CreateSolver[]
```
<!-- => Z3SolverObject[<Solver:1>] -->
