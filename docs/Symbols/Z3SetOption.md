---
Template: Symbol
Name: Z3SetOption
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3SetOption
Keywords: [Z3, SMT, option, configure, settings]
SeeAlso: [Z3CreateSolver, Z3Solve]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3SetOption]()[*solver*, "*name*" -> *value*, …]</code> sets z3 options on *solver*; returns the solver.

<code>[Z3SetOption]()["*name*" -> *value*]</code> sets global default options for future sessions, returning the current global option list.

## Details & Options

- Any z3 option is reachable this way, e.g. `"timeout"`, `"smt.random_seed"`.
- Per-solver options affect only that [Z3SolverObject](); global options seed every new session.

## Basic Examples

Set a global default timeout for future sessions:

```wl
Z3SetOption["timeout" -> 10000]
```
<!-- => {"timeout" -> 10000} -->
