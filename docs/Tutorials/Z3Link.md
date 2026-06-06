---
Template: TechNote
Name: Z3Link
Title: Z3Link
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/tutorial/Z3Link
Keywords: [Z3, SMT, solver, theorem prover, satisfiability, SMT-LIB, constraints, bit-vectors]
RelatedGuides: [Z3Link]
RelatedTutorials: [SolvingConstraintsWithZ3]
---

Z3Link gives the Wolfram Language bindings to the [Z3 theorem prover](https://github.com/Z3Prover/z3), an SMT (Satisfiability Modulo Theories) solver from Microsoft Research. You enter problems as native Wolfram expressions *or* as SMT-LIB2, and results come back as exact Wolfram values - integers, rationals, algebraic numbers, booleans, bit-vectors, arrays, and functions. This tech note tours the paclet feature by feature.

## Installation

The paclet drives the `z3` command-line solver. It looks for `z3` in this order: an executable set explicitly, the `Z3_PATH` environment variable, the system `PATH`, common install locations, a previously downloaded copy, and finally it downloads a private copy automatically (once) if none is found - so nothing needs to be installed by hand. The first call locates or downloads z3:

```wl
Z3InstallationLocation[]
```
<!-- => "z3" (or a full path / freshly downloaded copy) -->

[Z3Version]() reports the version in use, and [Z3SetExecutable]() forces a specific binary.

## Quick Start

Solve a system of integer constraints. Variables are ordinary symbols; the second argument declares their domain, exactly like [Reduce]() or [Solve]():

```wl
Z3Solve[x > 2 && y < 10 && x + 2 y == 7, {x, y} \[Element] Integers]
```
<!-- => <|y -> 0, x -> 7|> -->

[Z3Solve]() returns an [Association]() mapping each variable to its value when the problem is satisfiable, the symbol [Unsatisfiable]() when it is not, and [Indeterminate]() when z3 cannot decide.

## Two Ways to Enter a Problem

### Native expressions with a domain

Write ordinary Wolfram boolean and arithmetic expressions and declare the variable sorts separately. Supported domains include [Integers](), [Reals](), and [Booleans]():

```wl
Z3Solve[a || b && ! c, {a, b, c} \[Element] Booleans]
```
<!-- => <|b -> True, a -> False, c -> False|> -->

### Typed handles

Create typed variable handles and build expressions with normal operators - the idiom Z3's Python bindings use, and the one required where a sort carries parameters (bit-vector widths, array sorts):

```wl
With[{x = Z3Int["x"], y = Z3Int["y"]}, Z3Solve[{x + 2 y == 7, x > 2, y < 10}]]
```
<!-- => <|y -> 0, x -> 7|> -->

The handle constructors are [Z3Int](), [Z3Real](), [Z3Bool](), [Z3BitVec](), [Z3Array](), [Z3Const](), and [Z3Function]() for uninterpreted functions.

## Exact Results

Results stay exact. Rationals come back as [Rational]():

```wl
Z3Solve[3 r == 1, r \[Element] Reals]
```
<!-- => <|r -> 1/3|> -->

Algebraic numbers from nonlinear real arithmetic come back as [Root]() or [Sqrt]() objects, which the Wolfram Language simplifies where it can:

```wl
Z3Solve[s^2 == 2 && s > 0, s \[Element] Reals]
```
<!-- => <|s -> Sqrt[2]|> -->

Pass `"Numeric" -> True` to get machine-precision numbers instead.

## Theories

### Integers and reals

Z3Link supports linear and nonlinear arithmetic over [Integers]() and [Reals](), including [Mod](), [Quotient](), [Abs](), [Min](), [Max](), [Floor](), [Ceiling](), and integer powers. A nonlinear integer system:

```wl
Z3Solve[x^2 + y^2 == 25 && x > 0 && y > 0 && x < y, {x, y} \[Element] Integers]
```
<!-- => <|y -> 4, x -> 3|> -->

### Bit-vectors

Bit-vector arithmetic models fixed-width machine integers with wrap-around. [Z3BitVec]() is a variable and [Z3BitVecVal]() a literal:

```wl
With[{a = Z3BitVec["a", 8]}, Z3Solve[{a == Z3BitVecVal[10, 8] + Z3BitVecVal[5, 8]}]]
```
<!-- => <|a -> 15|> -->

Arithmetic operators on bit-vector handles map to the bit-vector operations (`bvadd`, `bvmul`, …); for any other SMT operator use the escape hatch [Z3Op]():

```wl
With[{a = Z3BitVec["a", 8]}, Z3Solve[{Z3Op["bvand", a, Z3BitVecVal[12, 8]] == Z3BitVecVal[4, 8]}]]
```
<!-- => <|a -> 4|> -->

### Arrays

An array is a total map from an index sort to a value sort. [Z3Select]() reads an entry and [Z3Store]() returns an updated array; the model comes back as a callable pure function:

```wl
With[{m = Z3Array["m", "Int", "Int"]}, Z3Solve[{Z3Select[m, 2] == 9, Z3Select[m, 5] == 7}]["m"][2]]
```
<!-- => 9 -->

### Uninterpreted functions

[Z3Function]() declares a function symbol with no definition beyond the constraints you place on it; its model is again a callable function:

```wl
With[{f = Z3Function["f", {"Int"}, "Int"]}, Z3Solve[{f[0] == 5, f[1] == 7}]["f"][1]]
```
<!-- => 7 -->

### Quantifiers

Attach sorts to bound variables with ∈ and quantify with [Z3ForAll]() and [Z3Exists]() (message-free equivalents of [ForAll]() and [Exists]()). With [Z3ProvableQ](), this turns Z3 into a small theorem prover:

```wl
Z3ProvableQ[Z3ForAll[x \[Element] Integers, x^2 >= 0], {}]
```
<!-- => True -->

## SMT-LIB Input and Output

Hand z3 a raw SMT-LIB2 script (string or [File]()) and get its response back with [Z3RunSMTLIB]():

```wl
Z3RunSMTLIB["(declare-const a Int)(assert (> a 41))(assert (< a 43))(check-sat)(get-value (a))"]
```
<!-- => "sat\n((a 42))" -->

To see the SMT-LIB2 that a native problem produces, use [Z3ToSMTLIB]():

```wl
Z3ToSMTLIB[x > 2 && y < 10 && x + 2 y == 7, {x, y} \[Element] Integers]
```
<!-- => "(declare-const x Int)\n(declare-const y Int)\n(assert (and (> x 2) (< y 10) (= (+ x (* 2 y)) 7)))\n(check-sat)\n(get-model)" -->

## Incremental Solving

A [Z3SolverObject]() keeps a live z3 process with a push/pop assertion stack, like a z3py `Solver`. Create one, assert constraints, and check satisfiability:

```wl
s = Z3CreateSolver[]; Z3Assert[s, x > 0 && x < 10, x \[Element] Integers]; Z3CheckSat[s]
```
<!-- => "sat" -->

Read the satisfying assignment with [Z3Model]():

```wl
Z3Model[s]
```
<!-- => <|x -> 1|> -->

[Z3Push]() marks a scope, and the matching [Z3Pop]() discards anything asserted after it, so you can try an assumption and back it out:

```wl
Z3Push[s]; Z3Assert[s, x > 8, x \[Element] Integers]; Z3CheckSat[s]; Z3Model[s]
```
<!-- => <|x -> 9|> -->

After an unsatisfiable check, [Z3UnsatCore]() returns the conflicting subset of assertions and [Z3Statistics]() returns solver statistics.

## Optimization

Z3's optimization engine is exposed through [Z3Optimize]() (one-shot) and [Z3Maximize]() / [Z3Minimize]() on an optimizer object:

```wl
Z3Optimize[x -> Maximize, x > 0 && x < 100, x \[Element] Integers]
```
<!-- => <|"Status" -> "sat", "Objective" -> 99, "Model" -> <|x -> 99|>|> -->

An incremental optimizer comes from [Z3CreateSolver]()["Optimize"], to which you add objectives before checking:

```wl
o = Z3CreateSolver["Optimize"]; Z3Assert[o, x + y == 10 && x >= 0 && y >= 0, {x, y} \[Element] Integers]; Z3Maximize[o, x*x + y*y]; Z3CheckSat[o]; Z3Model[o]
```
<!-- => <|x -> 10, y -> 0|> -->

## Options

[Z3Solve]() and [Z3Optimize]() accept `"Timeout" -> ms` (a per-solve timeout in milliseconds), `"Numeric" -> True` (machine-precision numbers instead of exact ones), and `"Options" -> {"name" -> value, …}` (arbitrary z3 options). [Z3SetOption]() sets options on a solver object directly, or sets global defaults:

```wl
Z3SetOption["timeout" -> 10000]
```
<!-- => {"timeout" -> 10000} -->

## Convenience Predicates

[Z3SatisfiableQ]() answers whether a system has any solution at all:

```wl
Z3SatisfiableQ[x^2 == 2, x \[Element] Reals]
```
<!-- => True -->

[Z3ProvableQ]() is [True]() when a claim holds for all values of its variables (its negation is unsatisfiable):

```wl
Z3ProvableQ[Implies[x > 0, x + 1 > 1], x \[Element] Integers]
```
<!-- => True -->
