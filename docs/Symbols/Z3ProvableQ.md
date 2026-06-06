---
Template: Symbol
Name: Z3ProvableQ
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3ProvableQ
Keywords: [Z3, SMT, theorem proving, validity]
SeeAlso: [Z3SatisfiableQ, Z3Solve, Z3ForAll]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3ProvableQ]()[*claim*, *vars* ∈ *domain*]</code> returns [True]() if *claim* holds for all values of the variables (its negation is unsatisfiable), [False]() if there is a counterexample, and [Indeterminate]() if Z3 cannot decide.

## Details & Options

- A claim is provable exactly when its negation is not satisfiable, so `Z3ProvableQ` is `Not[Z3SatisfiableQ[Not[claim], …]]`.
- Combine with [Z3ForAll]() to prove universally quantified statements.

## Basic Examples

Adding 1 to a positive integer keeps it above 1, for every integer:

```wl
Z3ProvableQ[Implies[x > 0, x + 1 > 1], x \[Element] Integers]
```
<!-- => True -->

## Scope

A universally quantified claim, proved with [Z3ForAll]():

```wl
Z3ProvableQ[Z3ForAll[x \[Element] Integers, x^2 >= 0], {}]
```
<!-- => True -->

## Possible Issues

A claim with a counterexample is not provable:

```wl
Z3ProvableQ[x > 0, x \[Element] Integers]
```
<!-- => False -->
