---
Template: TechNote
Name: SolvingConstraintsWithZ3
Title: Solving Constraints with Z3
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/tutorial/SolvingConstraintsWithZ3
Keywords: [Z3, SMT, solver, constraints, bit-vectors, optimization, SMT-LIB, tutorial]
RelatedGuides: [Z3Link]
---

Z3 is a Satisfiability Modulo Theories (SMT) solver: it decides whether a system
of logical and arithmetic constraints can be satisfied, and if so exhibits a
satisfying assignment. Z3Link drives the `z3` command-line solver and translates
both the problem and its answer between the Wolfram Language and SMT-LIB2. This
tech note walks through a typical session: state a problem, read the model, switch
between the two input styles, reach for the bit-vector and array theories, solve
incrementally, and optimize.

## A First Solve

`Z3Solve` takes a system of constraints and a declaration of the variables'
domain - the same `vars ∈ domain` idiom [Reduce]() and [Solve]() use. It returns
an association mapping each variable to a value when the problem is satisfiable:

```wl
Z3Solve[x > 2 && y < 10 && x + 2 y == 7, {x, y} \[Element] Integers]
```
<!-- => <|y -> 0, x -> 7|> -->

When no assignment can satisfy the constraints, `Z3Solve` returns the symbol
`Unsatisfiable` instead of an association:

```wl
Z3Solve[x > 0 && x < 0, x \[Element] Integers]
```
<!-- => Unsatisfiable -->

Booleans work the same way; the domain is `Booleans` and the operators are the
ordinary [And](), [Or](), and [Not]():

```wl
Z3Solve[a || b && ! c, {a, b, c} \[Element] Booleans]
```
<!-- => <|b -> True, a -> False, c -> False|> -->

## Exact Results

Answers stay exact. A constraint over the [Reals]() that pins a rational value
comes back as an exact [Rational](), not a machine float:

```wl
Z3Solve[3 r == 1, r \[Element] Reals]
```
<!-- => <|r -> 1/3|> -->

Nonlinear real arithmetic produces algebraic numbers, which Z3Link returns as
[Root]() or [Sqrt]() objects that the Wolfram Language can simplify and compute
with:

```wl
Z3Solve[s^2 == 2 && s > 0, s \[Element] Reals]
```
<!-- => <|s -> Sqrt[2]|> -->

Pass `"Numeric" -> True` to get machine-precision numbers when that is what you
want instead.

## Two Ways to State a Problem

The examples above use *native* expressions plus a domain declaration. The
alternative is to build *typed handles* - the idiom Z3's Python bindings use, and
the one you need when a sort carries parameters (a bit-vector width, an array's
index and value sorts). A handle is an ordinary Wolfram expression you can do
arithmetic on:

```wl
With[{x = Z3Int["x"], y = Z3Int["y"]}, Z3Solve[{x + 2 y == 7, x > 2, y < 10}]]
```
<!-- => <|y -> 0, x -> 7|> -->

In an interactive session you would simply write `x = Z3Int["x"]` and then use
`x` directly; the `With` above keeps this example self-contained. Either style
feeds the same solver, so pick whichever reads better for the problem at hand.

## Bit-Vectors

The bit-vector theory models fixed-width machine integers, with wrap-around
arithmetic. `Z3BitVec[name, width]` is a variable and `Z3BitVecVal[value, width]`
is a literal; the arithmetic operators map to the corresponding bit-vector
operations:

```wl
With[{a = Z3BitVec["a", 8]}, Z3Solve[{a == Z3BitVecVal[10, 8] + Z3BitVecVal[5, 8]}]]
```
<!-- => <|a -> 15|> -->

For a bit-vector operation that has no Wolfram operator - bitwise *and*, *or*,
shifts - reach for `Z3Op`, the escape hatch that emits any SMT-LIB operator
directly:

```wl
With[{a = Z3BitVec["a", 8]}, Z3Solve[{Z3Op["bvand", a, Z3BitVecVal[12, 8]] == Z3BitVecVal[4, 8]}]]
```
<!-- => <|a -> 4|> -->

## Arrays and Uninterpreted Functions

An array is a total map from an index sort to a value sort. `Z3Select[arr, i]`
reads it and `Z3Store[arr, i, v]` returns an updated copy. The model comes back
as a callable pure function, which you index to read back individual entries:

```wl
With[{m = Z3Array["m", "Int", "Int"]}, Z3Solve[{Z3Select[m, 2] == 9, Z3Select[m, 5] == 7}]["m"][2]]
```
<!-- => 9 -->

An uninterpreted function is a function symbol with no definition beyond the
constraints you place on it. `Z3Function[name, {argSorts}, resultSort]` declares
one, and its model is again a callable function:

```wl
With[{f = Z3Function["f", {"Int"}, "Int"]}, Z3Solve[{f[0] == 5, f[1] == 7}]["f"][0]]
```
<!-- => 5 -->

## Quantifiers

You can quantify over a sort with `Z3ForAll` and `Z3Exists` (message-free
equivalents of the built-in [ForAll]() and [Exists]()). Combined with
`Z3ProvableQ` - which holds when a claim is true for *all* values of its
variables - this turns Z3 into a small theorem prover:

```wl
Z3ProvableQ[Z3ForAll[x \[Element] Integers, x^2 >= 0], {}]
```
<!-- => True -->

## Solving Incrementally

For an interactive exploration where constraints arrive over time, create a
live `Z3SolverObject`. It keeps a z3 process running with a push/pop assertion
stack, so you can add constraints, check, backtrack, and continue. Assert some
constraints and check them:

```wl
solver = Z3CreateSolver[];
Z3Assert[solver, x > 0 && x < 10, x \[Element] Integers];
Z3CheckSat[solver]
```
<!-- => "sat" -->

`Z3Model` reads back the satisfying assignment from the most recent check:

```wl
Z3Model[solver]
```
<!-- => <|x -> 1|> -->

`Z3Push` marks a scope you can return to. Constraints asserted after a push are
discarded by the matching `Z3Pop`, so you can try an extra assumption and undo
it:

```wl
Z3Push[solver];
Z3Assert[solver, x > 8, x \[Element] Integers];
Z3CheckSat[solver];
Z3Model[solver]
```
<!-- => <|x -> 9|> -->

After popping, `Z3Eval` evaluates an arbitrary expression in the current model:

```wl
Z3Pop[solver];
Z3CheckSat[solver];
Z3Eval[solver, x + 1]
```
<!-- => 2 -->

When a set of assertions is contradictory, `Z3CheckSat` returns `"unsat"` and
`Z3UnsatCore` reports a conflicting subset - useful for diagnosing which
assumptions clash:

```wl
Z3Reset[solver];
Z3Assert[solver, x > 5, x \[Element] Integers];
Z3Assert[solver, x < 3, x \[Element] Integers];
Z3CheckSat[solver];
Z3UnsatCore[solver]
```
<!-- => {x > 5, x < 3} -->

## Optimization

Beyond pure satisfiability, Z3 can maximize or minimize an objective subject to
constraints. `Z3Optimize` does this in one call, returning the optimal objective
value alongside the model:

```wl
Z3Optimize[x -> Maximize, x > 0 && x < 100, x \[Element] Integers]
```
<!-- => <|"Status" -> "sat", "Objective" -> 99, "Model" -> <|x -> 99|>|> -->

## Talking SMT-LIB Directly

Every native problem compiles to an SMT-LIB2 script, which `Z3ToSMTLIB` lets you
inspect - handy for learning the format or debugging a translation:

```wl
Z3ToSMTLIB[x > 2 && x < 5, x \[Element] Integers]
```
<!-- => "(declare-const x Int)\n(assert (and (> x 2) (< x 5)))\n(check-sat)\n(get-model)" -->

Going the other way, `Z3RunSMTLIB` hands a raw SMT-LIB2 script straight to z3 and
returns its responses, so you can run scripts written for the solver verbatim:

```wl
Z3RunSMTLIB["(declare-const a Int)(assert (> a 41))(assert (< a 43))(check-sat)(get-value (a))"]
```
<!-- => "sat\n((a 42))" -->

These two functions, together with the native and handle styles, let you move
fluidly between Wolfram expressions and the SMT-LIB world Z3 speaks natively.
