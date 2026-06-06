---
Template: Symbol
Name: Z3CreateSolver
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3CreateSolver
Keywords: [Z3, SMT, solver, optimizer, create]
SeeAlso: [Z3SolverObject, Z3Assert, Z3CheckSat, Z3Optimize, Z3Reset]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3CreateSolver]()[]</code> creates a new incremental [Z3SolverObject]().

<code>[Z3CreateSolver]()["Optimize"]</code> creates an optimizer that also accepts [Z3Maximize]() and [Z3Minimize]() objectives.

## Details & Options

- The returned [Z3SolverObject]() owns a running z3 process; release it with [DeleteObject]() when finished.
- A solver is grown with [Z3Assert]() and checked with [Z3CheckSat](); an optimizer additionally takes objectives.

## Basic Examples

Create an incremental solver:

```wl
Z3CreateSolver[]
```
<!-- => Z3SolverObject[<Solver:1>] -->

## Scope

Create an optimizer for maximize/minimize objectives:

```wl
Z3CreateSolver["Optimize"]
```
<!-- => Z3SolverObject[<Optimize:2>] -->
