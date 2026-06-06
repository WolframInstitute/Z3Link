---
Template: Paclet
ResourceType: Paclet
Name: WolframInstitute/Z3Link
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
Description: Bindings to the Z3 theorem prover (SMT solver), with native Wolfram and SMT-LIB2 input and exact symbolic results
ContributedBy: Richard Assar
Keywords: [Z3, SMT, solver, theorem prover, satisfiability, SMT-LIB, constraints]
MainGuide: Documentation/English/Guides/Z3Link.nb
License: GPL-3.0-or-later
WolframVersion: 13.0+
Categories: [Symbolic & Numeric Computation, Higher Mathematical Computation]
Disclosures: [LocalFiles, ExternalServices, LocalSystemInteractions]
Sources: ["L. de Moura and N. Bjørner, Z3: An Efficient SMT Solver. TACAS 2008, LNCS 4963, pp. 337-340"]
SourceControlURL: https://github.com/WolframInstitute/Z3Link
Links: ["[Z3 theorem prover](https://github.com/Z3Prover/z3)", "[SMT-LIB standard](https://smt-lib.org)"]
---

## Details & Options

- Z3Link drives the `z3` command-line solver as an external process; it does not link the Z3 library in-kernel.
- The `z3` executable is located on the system [Environment]() `PATH` and common install locations, or downloaded automatically once from the official GitHub releases and cached under [$UserBaseDirectory](). Use [Z3SetExecutable]() to pin a specific binary.
- Problems may be stated as native Wolfram expressions with a `vars ∈ domain` declaration, as typed handles ([Z3Int](), [Z3Real](), [Z3BitVec](), ...), or as raw SMT-LIB2 text.
- Results are exact: integers and rationals as themselves, algebraic numbers as [Root]() or [Sqrt]() objects, arrays and uninterpreted functions as callable pure functions. Pass `"Numeric" -> True` for machine-precision values.
- Supported theories: linear and nonlinear arithmetic over [Integers]() and [Reals](), [Booleans](), bit-vectors, arrays, uninterpreted functions, quantifiers, and optimization.

## Usage

The paclet provides one-shot solving with [Z3Solve](), [Z3SatisfiableQ](), [Z3ProvableQ](), and [Z3Optimize](); incremental [Z3SolverObject]() instances from [Z3CreateSolver]() driven by [Z3Assert](), [Z3CheckSat](), [Z3Model](), [Z3Eval](), [Z3Push](), [Z3Pop](), [Z3Reset](), [Z3Maximize](), [Z3Minimize](), [Z3UnsatCore](), and [Z3Statistics](); typed handles [Z3Int](), [Z3Real](), [Z3Bool](), [Z3BitVec](), [Z3BitVecVal](), [Z3Array](), [Z3Function](), [Z3Const](), [Z3Op](), [Z3Select](), [Z3Store](), [Z3ForAll](), and [Z3Exists](); SMT-LIB interoperation with [Z3ToSMTLIB](), [Z3RunSMTLIB](), and [Z3SetOption](); and installation control with [Z3InstallationLocation](), [Z3Version](), [Z3Install](), and [Z3SetExecutable]().

## Basic Examples

Solve a system of integer constraints:

```wl
Z3Solve[x > 2 && y < 10 && x + 2 y == 7, {x, y} \[Element] Integers]
```
<!-- => <|y -> 0, x -> 7|> -->

---

Unsatisfiable constraints return the symbol [Unsatisfiable]():

```wl
Z3Solve[x > 0 && x < 0, x \[Element] Integers]
```
<!-- => Unsatisfiable -->

---

Nonlinear real arithmetic returns exact algebraic numbers:

```wl
Z3Solve[s^2 == 2 && s > 0, s \[Element] Reals]
```
<!-- => <|s -> Sqrt[2]|> -->

---

Prove a claim holds for every value of its variables:

```wl
Z3ProvableQ[Implies[x > 0, x + 1 > 1], x \[Element] Integers]
```
<!-- => True -->

## Scope

Build constraints from typed handles in the style of Z3's Python bindings:

```wl
With[{x = Z3Int["x"], y = Z3Int["y"]}, Z3Solve[{x + 2 y == 7, x > 2, y < 10}]]
```
<!-- => <|y -> 0, x -> 7|> -->

---

Solve over the bit-vector theory with wrap-around machine arithmetic:

```wl
With[{a = Z3BitVec["a", 8]}, Z3Solve[{a == Z3BitVecVal[10, 8] + Z3BitVecVal[5, 8]}]]
```
<!-- => <|a -> 15|> -->

---

Recover an array model as a callable function:

```wl
With[{m = Z3Array["m", "Int", "Int"]}, Z3Solve[{Z3Select[m, 2] == 9, Z3Select[m, 5] == 7}]["m"][2]]
```
<!-- => 9 -->

## Applications

Maximize an objective subject to constraints in a single call:

```wl
Z3Optimize[x -> Maximize, x > 0 && x < 100, x \[Element] Integers]
```
<!-- => <|"Status" -> "sat", "Objective" -> 99, "Model" -> <|x -> 99|>|> -->

---

Drive a live solver incrementally with a push/pop assertion stack:

```wl
With[{s = Z3CreateSolver[]}, Z3Assert[s, x > 5 && x < 9, x \[Element] Integers]; Z3CheckSat[s] -> Z3Model[s]]
```
<!-- => "sat" -> <|x -> 6|> -->

## Possible Issues

Inspect the SMT-LIB2 a native problem compiles to, or run raw SMT-LIB2 directly:

```wl
Z3RunSMTLIB["(declare-const a Int)(assert (> a 41))(assert (< a 43))(check-sat)(get-value (a))"]
```
<!-- => "sat\n((a 42))" -->

## Hero Image

A small integer program - the points satisfying `x + 2 y == 7` with `x > 2` -
and the satisfying assignment `{x, y} = {7, 0}` that Z3 returns:

```wl
With[
  {sols = Select[Tuples[{Range[3, 9], Range[-1, 3]}], #[[1]] + 2 #[[2]] == 7 &],
   answer = {7, 0}},
  Rasterize[
    Framed[
      Column[
        {Style["Z3Link", 38, Bold, GrayLevel[0.12], FontFamily -> "Helvetica"],
         Style["Bindings to the Z3 SMT solver", 15, GrayLevel[0.45], FontFamily -> "Helvetica"],
         Spacer[14],
         Graphics[
           {GrayLevel[0.82], Thick, InfiniteLine[{{7, 0}, {5, 1}}],
            RGBColor[0.27, 0.5, 0.72], PointSize[0.045], Point[sols],
            RGBColor[0.86, 0.32, 0.27], PointSize[0.08], Point[answer],
            Black, Text[Style["x + 2y = 7", 14, FontFamily -> "Helvetica"], {6.2, 2.4}],
            RGBColor[0.86, 0.32, 0.27],
            Text[Style["{x,y} = {7,0}", 13, Bold, FontFamily -> "Helvetica"], {7, -1.1}]},
           Axes -> True, AxesStyle -> GrayLevel[0.6], Frame -> False,
           PlotRange -> {{2, 10}, {-1.6, 3.2}}, ImageSize -> 360, AspectRatio -> 0.62]},
        Alignment -> Center, Spacings -> 0.6],
      Background -> GrayLevel[0.98], FrameMargins -> 32,
      FrameStyle -> GrayLevel[0.9], RoundingRadius -> 16],
    ImageResolution -> 144, Background -> None]]
```

## Author Notes

The Z3Link paclet is by Richard Assar (Wolfram Institute). This resource
definition and the accompanying documentation pages (guide, symbol reference
pages, tech note, and overview) were drafted with the assistance of Claude
(Anthropic, Opus) and reviewed and edited by Nikolay Murzin; every example was
executed against the live paclet and its output verified before inclusion.
