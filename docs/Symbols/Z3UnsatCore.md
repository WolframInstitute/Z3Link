---
Template: Symbol
Name: Z3UnsatCore
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3UnsatCore
Keywords: [Z3, SMT, unsat core, conflict, diagnosis]
SeeAlso: [Z3CheckSat, Z3Assert, Z3Model]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3UnsatCore]()[*solver*]</code> returns a subset of *solver*'s asserted constraints that is already unsatisfiable, after an `"unsat"` [Z3CheckSat]().

## Details & Options

- Meaningful only after [Z3CheckSat]() returned `"unsat"`.
- The core is reported as the original Wolfram constraint expressions, useful for pinpointing which assumptions clash.

## Basic Examples

Assert two contradictory constraints and confirm they are unsat:

```wl
s = Z3CreateSolver[]; Z3Assert[s, x > 5, x \[Element] Integers]; Z3Assert[s, x < 3, x \[Element] Integers]; Z3CheckSat[s]
```
<!-- => "unsat" -->

The unsat core is the conflicting subset:

```wl
Z3UnsatCore[s]
```
<!-- => {x > 5, x < 3} -->
