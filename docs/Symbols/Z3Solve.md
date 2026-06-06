---
Template: Symbol
Name: Z3Solve
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3Solve
Keywords: [Z3, SMT, solve, constraints, satisfiability]
SeeAlso: [Z3SatisfiableQ, Z3ProvableQ, Z3Optimize, Z3CreateSolver, Z3ToSMTLIB, Unsatisfiable]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3Solve]()[*constraints*, *vars* ∈ *domain*]</code> solves *constraints* over the declared variables, returning an [Association]() of variable -> value if satisfiable, the symbol [Unsatisfiable]() if not, or [Indeterminate]() if Z3 cannot decide.

<code>[Z3Solve]()[{*c₁*, *c₂*, …}]</code> solves constraints built from typed handles ([Z3Int](), [Z3Real](), …), whose sorts are taken from the handles.

<code>[Z3Solve]()["*smtlib2*"]</code> runs a raw SMT-LIB2 script and returns its responses.

## Details & Options

- The domain follows the [Reduce]() / [Solve]() idiom: `vars ∈ domain` with *domain* one of [Integers](), [Reals](), or [Booleans]().
- Results are exact: rationals as [Rational](), algebraic numbers as [Root]() or [Sqrt]() objects, arrays and uninterpreted functions as callable pure functions.
- The following options can be given:

| option | default | |
|---|---|---|
| `"Timeout"` | Automatic | per-solve time limit in milliseconds |
| `"Numeric"` | False | return machine-precision numbers instead of exact values |
| `"Options"` | {} | a list of `"name" -> value` z3 options to set |

## Basic Examples

Solve a system of integer constraints:

```wl
Z3Solve[x > 2 && y < 10 && x + 2 y == 7, {x, y} \[Element] Integers]
```
<!-- => <|y -> 0, x -> 7|> -->

## Scope

Solve a propositional formula over boolean variables:

```wl
Z3Solve[a || b && ! c, {a, b, c} \[Element] Booleans]
```
<!-- => <|b -> True, a -> False, c -> False|> -->

---

Rationals stay exact over the reals:

```wl
Z3Solve[3 r == 1, r \[Element] Reals]
```
<!-- => <|r -> 1/3|> -->

---

Nonlinear real arithmetic returns algebraic numbers:

```wl
Z3Solve[s^2 == 2 && s > 0, s \[Element] Reals]
```
<!-- => <|s -> Sqrt[2]|> -->

---

Typed handles need no domain argument:

```wl
With[{x = Z3Int["x"], y = Z3Int["y"]}, Z3Solve[{x + 2 y == 7, x > 2, y < 10}]]
```
<!-- => <|y -> 0, x -> 7|> -->

## Options

`"Numeric" -> True` returns machine numbers:

```wl
Z3Solve[s^2 == 2 && s > 0, s \[Element] Reals, "Numeric" -> True]
```
<!-- => <|s -> 1.4142135623730951|> -->

---

`"Timeout"` caps the solve in milliseconds:

```wl
Z3Solve[x > 2 && x < 8, x \[Element] Integers, "Timeout" -> 5000]
```
<!-- => <|x -> 3|> -->

## Possible Issues

Unsatisfiable constraints return the symbol [Unsatisfiable](), not an association:

```wl
Z3Solve[x > 0 && x < 0, x \[Element] Integers]
```
<!-- => Unsatisfiable -->
