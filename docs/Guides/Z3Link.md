---
Template: Guide
Name: Z3Link
Title: Z3Link
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/guide/Z3Link
Description: Wolfram Language bindings to the Z3 theorem prover (SMT solver).
Keywords: [Z3, SMT, solver, theorem prover, satisfiability, SMT-LIB, constraints]
RelatedGuides: [Reduce, BooleanComputation, ComputationalLogic]
Links: ["[Z3 theorem prover](https://github.com/Z3Prover/z3)", "[SMT-LIB standard](https://smt-lib.org)"]
---

## Abstract

Z3Link brings the [Z3 theorem prover](https://github.com/Z3Prover/z3) - an SMT (Satisfiability Modulo Theories) solver from Microsoft Research - to the Wolfram Language. You state a problem either as ordinary Wolfram expressions with a variable domain (the [Reduce]() idiom) or as typed handles in the style of Z3's Python bindings, and Z3Link translates the answer back into exact Wolfram values: [Integer]() and [Rational]() solutions, algebraic numbers as [Root]() or [Sqrt]() objects, [Boolean]() assignments, bit-vectors, arrays as callable functions, and uninterpreted-function models. It covers linear and nonlinear arithmetic over [Integers]() and [Reals](), bit-vectors, arrays, uninterpreted functions, quantifiers, and optimization, and it exposes raw SMT-LIB2 in both directions. The `z3` executable is located on your system or downloaded automatically on first use, so nothing needs to be installed by hand.

## Functions

- `Z3Solve` solve a constraint system, returning a model, `Unsatisfiable`, or `Indeterminate`
- `Z3SatisfiableQ` test whether constraints are satisfiable
- `Z3ProvableQ` test whether a claim holds for all values of its variables
- `Z3Optimize` solve a constrained maximization or minimization in one call
- `Z3CreateSolver` create an incremental solver or optimizer object
- `Z3SolverObject` a live incremental z3 solver or optimizer instance
- `Z3Assert` add constraints to a solver, declaring any new variables
- `Z3CheckSat` check satisfiability of a solver's current assertions
- `Z3Model` the model from a solver's last successful check
- `Z3Eval` evaluate an expression in a solver's current model
- `Z3Push` save a solver's current assertion scope
- `Z3Pop` restore the most recently pushed scope
- `Z3Reset` clear all assertions and declarations from a solver
- `Z3UnsatCore` a conflicting subset of assertions after an unsat result
- `Z3Statistics` z3 solver performance statistics
- `Z3Maximize` add a maximization objective to an optimizer
- `Z3Minimize` add a minimization objective to an optimizer
- `Z3Int` an integer-sorted variable handle
- `Z3Real` a real-sorted variable handle
- `Z3Bool` a boolean-sorted variable handle
- `Z3Const` a variable handle of an arbitrary sort
- `Z3BitVec` an *n*-bit bit-vector variable handle
- `Z3BitVecVal` an *n*-bit bit-vector literal
- `Z3Array` an array-sorted variable handle
- `Z3Function` an uninterpreted function handle
- `Z3Select` read an array entry
- `Z3Store` an array with one entry updated
- `Z3Op` build an arbitrary SMT-LIB operator term
- `Z3ForAll` a universally quantified formula
- `Z3Exists` an existentially quantified formula
- `Z3ToSMTLIB` the SMT-LIB2 script a native problem compiles to
- `Z3RunSMTLIB` run a raw SMT-LIB2 script and return its responses
- `Z3SetOption` set z3 options on a solver or as global defaults
- `Z3InstallationLocation` locate (or download) the z3 executable in use
- `Z3Version` the version of the z3 executable in use
- `Z3Install` download a private copy of z3 for this platform
- `Z3SetExecutable` pin a specific z3 binary
- `Unsatisfiable` the symbol `Z3Solve` returns when there is no solution
