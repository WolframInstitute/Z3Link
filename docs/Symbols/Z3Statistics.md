---
Template: Symbol
Name: Z3Statistics
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3Statistics
Keywords: [Z3, SMT, statistics, performance, profiling]
SeeAlso: [Z3CheckSat, Z3CreateSolver]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3Statistics]()[*solver*]</code> returns an [Association]() of z3 solver statistics gathered during *solver*'s last check.

## Details & Options

- Keys are z3's own statistic names (memory use, conflicts, propagations, …); the exact set depends on the problem and z3 version.
- Call it after a [Z3CheckSat]() so there are statistics to report.

## Basic Examples

Assert and check a constraint:

```wl
s = Z3CreateSolver[]; Z3Assert[s, x > 1 && x < 99, x \[Element] Integers]; Z3CheckSat[s]
```
<!-- => "sat" -->

The statistics name z3's internal counters:

```wl
Take[Keys[Z3Statistics[s]], UpTo[5]]
```
<!-- => {"arith-make-feasible", "arith-max-columns", "binary-propagations", "conflicts", "max-memory"} -->
