(* ::Package:: *)

(* WolframInstitute/Z3Link -- Wolfram Language bindings to the Z3 SMT solver.
   Copyright (C) 2026 Richard Assar.

   This program is free software: you can redistribute it and/or modify it under
   the terms of the GNU General Public License as published by the Free Software
   Foundation, either version 3 of the License, or (at your option) any later
   version. This program is distributed WITHOUT ANY WARRANTY. See the GNU General
   Public License (LICENSE file) for more details. *)

BeginPackage["WolframInstitute`Z3Link`"];

(* ---- High-level solving ---- *)

Z3Solve::usage =
"Z3Solve[constraints, vars \[Element] domain] solves the constraints over the \
declared variables and returns an association of variable -> value if satisfiable, \
the symbol Unsatisfiable if not, or Indeterminate if Z3 cannot decide.\n\
Z3Solve[\"smtlib2 text\"] runs a raw SMT-LIB2 script and returns its results.\n\
constraints may be a list, an And/Or expression, or built from typed handles \
(Z3Int, Z3Real, ...). Options: \"Timeout\", \"Numeric\", \"Options\", \"All\" (all models).";

Z3SatisfiableQ::usage =
"Z3SatisfiableQ[constraints, vars \[Element] domain] returns True if the constraints are satisfiable.";

Z3ProvableQ::usage =
"Z3ProvableQ[claim, vars \[Element] domain] returns True if claim holds for all values of the variables \
(i.e. its negation is unsatisfiable).";

(* ---- Incremental solver objects ---- *)

Z3SolverObject::usage =
"Z3SolverObject[...] is an incremental Z3 solver/optimizer instance backed by a live z3 process.";

Z3CreateSolver::usage =
"Z3CreateSolver[] creates a new incremental Z3SolverObject. Z3CreateSolver[\"Optimize\"] creates an optimizer.";

Z3Assert::usage =
"Z3Assert[solver, constraints, vars \[Element] domain] adds constraints (declaring any new variables) to a Z3SolverObject.";

Z3CheckSat::usage =
"Z3CheckSat[solver] checks satisfiability of the current assertions, returning \"sat\", \"unsat\" or \"unknown\".";

Z3Model::usage =
"Z3Model[solver] returns the model (an association of variable -> value) from the last successful check.";

Z3Push::usage = "Z3Push[solver] saves the current assertion stack scope.";
Z3Pop::usage = "Z3Pop[solver] restores the most recently pushed scope.";
Z3Reset::usage = "Z3Reset[solver] clears all assertions and declarations.";
Z3Eval::usage = "Z3Eval[solver, expr] evaluates expr in the current model.";
Z3UnsatCore::usage = "Z3UnsatCore[solver] returns the subset of asserted constraints forming an unsatisfiable core (after an unsat check).";
Z3Statistics::usage = "Z3Statistics[solver] returns an association of z3 solver statistics.";

Z3ForAll::usage = "Z3ForAll[vars \[Element] domain, body] is a universally quantified formula (a message-free alternative to WL ForAll).";
Z3Exists::usage = "Z3Exists[vars \[Element] domain, body] is an existentially quantified formula.";

(* ---- Optimization ---- *)

Z3Maximize::usage = "Z3Maximize[solver, objective] adds a maximization objective to an optimizer.";
Z3Minimize::usage = "Z3Minimize[solver, objective] adds a minimization objective to an optimizer.";
Z3Optimize::usage =
"Z3Optimize[objective -> Maximize|Minimize, constraints, vars \[Element] domain] solves an optimization problem in one call.";

(* ---- Typed handles (z3py-style native expression building) ---- *)

Z3Int::usage = "Z3Int[\"x\"] is an integer-sorted Z3 variable handle usable in arithmetic/logical expressions.";
Z3Real::usage = "Z3Real[\"x\"] is a real-sorted Z3 variable handle.";
Z3Bool::usage = "Z3Bool[\"p\"] is a boolean-sorted Z3 variable handle.";
Z3BitVec::usage = "Z3BitVec[\"a\", n] is an n-bit bit-vector Z3 variable handle.";
Z3BitVecVal::usage = "Z3BitVecVal[value, n] is an n-bit bit-vector literal.";
Z3Array::usage = "Z3Array[\"m\", domSort, rngSort] is an array-sorted Z3 variable handle.";
Z3Function::usage = "Z3Function[\"f\", {argSorts}, resultSort] declares an uninterpreted function handle.";
Z3Const::usage = "Z3Const[\"name\", sort] is a Z3 constant handle of the given sort.";
Z3Op::usage = "Z3Op[\"smtOp\", args...] builds an arbitrary SMT-LIB operator term, e.g. Z3Op[\"bvand\", a, b]. An escape hatch for any z3 function.";

(* ---- Array / bit-vector term builders (Style 1) ---- *)

Z3Select::usage = "Z3Select[array, index] is the SMT (select array index) term.";
Z3Store::usage = "Z3Store[array, index, value] is the SMT (store array index value) term.";

(* ---- SMT-LIB interop ---- *)

Z3ToSMTLIB::usage =
"Z3ToSMTLIB[constraints, vars \[Element] domain] returns the SMT-LIB2 script that Z3Solve would send to z3.";

Z3RunSMTLIB::usage =
"Z3RunSMTLIB[\"smtlib2 text\"] runs raw SMT-LIB2 (string or File[...]) in a fresh z3 session and returns the parsed responses.";

Z3SetOption::usage =
"Z3SetOption[solver, \"name\" -> value, ...] sets z3 options on a solver. Z3SetOption[\"name\" -> value] sets global defaults.";

(* ---- Installation / discovery ---- *)

Z3Install::usage =
"Z3Install[] downloads a private copy of z3 for this platform into the paclet data directory. Z3Install[\"version\"] installs a specific version.";

Z3InstallationLocation::usage =
"Z3InstallationLocation[] returns the path to the z3 executable that will be used, locating or downloading it as needed.";

Z3Version::usage = "Z3Version[] returns the version string of the z3 executable in use.";

Z3SetExecutable::usage = "Z3SetExecutable[path] forces the paclet to use the z3 executable at path.";

(* ---- Result symbols ---- *)

Unsatisfiable::usage = "Unsatisfiable is returned by Z3Solve when the constraints have no solution.";

Begin["`Private`"];

$Z3PacletDirectory = ParentDirectory[DirectoryName[$InputFileName]];
$Z3KernelDirectory = DirectoryName[$InputFileName];

(* Load implementation modules (shared private context). Order matters. *)
Scan[
  Get[FileNameJoin[{$Z3KernelDirectory, # <> ".wl"}]] &,
  {"Discovery", "SExpr", "Process", "InputTranslate", "OutputTranslate", "Handles", "API"}
];

End[];

EndPackage[];
