(* Verification tests for WolframInstitute/Z3.
   Run with the runner: tools/run_tests.wls (loads the paclet, then TestReport). *)

BeginTestSection["Z3"];

(* ---- translation (no solver needed) ---- *)

VerificationTest[
  StringContainsQ[Z3ToSMTLIB[x > 2 && y < 10 && x + 2 y == 7, {x, y} \[Element] Integers],
    "(assert (and (> x 2) (< y 10) (= (+ x (* 2 y)) 7)))"],
  True, TestID -> "translate-linear"
];

VerificationTest[
  StringContainsQ[Z3ToSMTLIB[s^2 == 2 && s > 0, s \[Element] Reals], "(* s s)"],
  True, TestID -> "translate-power"
];

(* ---- one-shot solving ---- *)

VerificationTest[Z3Solve[x == 5, x \[Element] Integers], <|x -> 5|>, TestID -> "solve-single"];

VerificationTest[Z3Solve[3 r == 1, r \[Element] Reals][r], 1/3, TestID -> "solve-rational"];

VerificationTest[Z3Solve[s^2 == 2 && s > 0, s \[Element] Reals][s], Sqrt[2], TestID -> "solve-algebraic"];

VerificationTest[Z3Solve[x > 5 && x < 3, x \[Element] Integers], Unsatisfiable, TestID -> "solve-unsat"];

VerificationTest[Z3Solve[a || b, {a, b} \[Element] Booleans] // AssociationQ, True, TestID -> "solve-bool"];

(* ---- predicates ---- *)

VerificationTest[Z3SatisfiableQ[x^2 == 2, x \[Element] Reals], True, TestID -> "sat-true"];
VerificationTest[Z3SatisfiableQ[x > 5 && x < 3, x \[Element] Integers], False, TestID -> "sat-false"];
VerificationTest[Z3ProvableQ[x^2 >= 0, x \[Element] Reals], True, TestID -> "provable"];

(* ---- typed handles ---- *)

VerificationTest[
  Module[{xx = Z3Int["x"], yy = Z3Int["y"]},
    Lookup[Z3Solve[{xx + 2 yy == 7, xx > 2, yy < 10}], "x"]] // IntegerQ,
  True, TestID -> "handles"
];

(* ---- bit-vectors ---- *)

VerificationTest[
  Lookup[Z3Solve[{Z3BitVec["a", 8] == Z3BitVecVal[10, 8] + Z3BitVecVal[5, 8]}], "a"],
  15, TestID -> "bitvec-add"
];

(* ---- arrays ---- *)

VerificationTest[
  Z3Solve[{Z3Select[Z3Array["m", "Int", "Int"], 2] == 9}]["m"][2],
  9, TestID -> "array"
];

(* ---- uninterpreted functions ---- *)

VerificationTest[
  Module[{f = Z3Function["f", {"Int"}, "Int"]},
    Z3Solve[{f[0] == 5, f[1] == 7}]["f"][1]],
  7, TestID -> "uf"
];

(* ---- incremental solver ---- *)

VerificationTest[
  Module[{s = Z3CreateSolver[]},
    Z3Assert[s, x > 0 && x < 10, x \[Element] Integers];
    Z3CheckSat[s]],
  "sat", TestID -> "incremental-sat"
];

VerificationTest[
  Module[{s = Z3CreateSolver[]},
    Z3Assert[s, x > 10, x \[Element] Integers];
    Z3Assert[s, x < 0, x \[Element] Integers];
    Z3CheckSat[s]],
  "unsat", TestID -> "incremental-unsat"
];

(* ---- optimization ---- *)

VerificationTest[
  Z3Optimize[x -> Maximize, x > 0 && x < 100, x \[Element] Integers]["Objective"],
  99, TestID -> "optimize-max"
];

(* ---- SMT-LIB interop ---- *)

VerificationTest[
  StringContainsQ[Z3RunSMTLIB["(declare-const a Int)(assert (= a 42))(check-sat)(get-value (a))"], "42"],
  True, TestID -> "smtlib-raw"
];

EndTestSection[];
