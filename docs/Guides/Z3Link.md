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

## One-shot solving

- `Z3Solve` solves constraints over a declared domain, returning a variable->value association, `Unsatisfiable`, or `Indeterminate`
- `Z3SatisfiableQ` tests whether constraints have a solution
- `Z3ProvableQ` tests whether a claim holds for all values of its variables
- `Z3Optimize` solves a constrained maximization or minimization in one call

## Incremental solvers

- `Z3CreateSolver` creates a live `Z3SolverObject` (a solver or optimizer) with a push/pop assertion stack
- `Z3SolverObject` is the handle to a running z3 process
- `Z3Assert` adds constraints to a solver, declaring any new variables
- `Z3CheckSat` checks satisfiability of the current assertions
- `Z3Model` returns the model from the last successful check
- `Z3Eval` evaluates an expression in the current model
- `Z3Push` saves the current assertion scope; `Z3Pop` restores it
- `Z3Reset` clears all assertions and declarations
- `Z3Maximize` and `Z3Minimize` add objectives to an optimizer
- `Z3UnsatCore` returns a conflicting subset of assertions after an unsat result
- `Z3Statistics` returns solver performance statistics

## Typed handles

- `Z3Int`, `Z3Real`, `Z3Bool` are integer-, real-, and boolean-sorted variable handles
- `Z3BitVec` is an *n*-bit bit-vector handle; `Z3BitVecVal` is a bit-vector literal
- `Z3Array` is an array-sorted handle; `Z3Select` and `Z3Store` read and update arrays
- `Z3Function` declares an uninterpreted function; `Z3Const` is a handle of an arbitrary sort
- `Z3Op` builds an arbitrary SMT-LIB operator term as an escape hatch
- `Z3ForAll` and `Z3Exists` are message-free quantified formulas

## SMT-LIB interoperation

- `Z3ToSMTLIB` shows the SMT-LIB2 script a native problem compiles to
- `Z3RunSMTLIB` runs a raw SMT-LIB2 script (string or `File`) and returns its responses
- `Z3SetOption` sets z3 options on a solver or as global defaults

## Installation and discovery

- `Z3InstallationLocation` resolves (locating or downloading) the z3 executable in use
- `Z3Version` reports the version of that executable
- `Z3Install` forces a fresh download of z3 for this platform
- `Z3SetExecutable` pins a specific z3 binary
