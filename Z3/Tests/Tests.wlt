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

VerificationTest[
  Module[{f = FileNameJoin[{$TemporaryDirectory, "z3paclet-test.smt2"}]},
    Export[f, "(declare-const a Int)(assert (= a 7))(check-sat)(get-value (a))", "Text"];
    StringContainsQ[Z3RunSMTLIB[File[f]], "7"]],
  True, TestID -> "smtlib-file"
];

(* ---- more translation cases ---- *)

VerificationTest[StringContainsQ[Z3ToSMTLIB[Mod[x, 5] == 2, x \[Element] Integers], "(mod x 5)"], True, TestID -> "translate-mod"];
VerificationTest[StringContainsQ[Z3ToSMTLIB[2 < x < 5, x \[Element] Integers], "(< 2 x 5)"], True, TestID -> "translate-chained"];
VerificationTest[StringContainsQ[Z3ToSMTLIB[If[x > 0, 1, 0] == 1, x \[Element] Integers], "(ite (> x 0) 1 0)"], True, TestID -> "translate-ite"];
VerificationTest[StringContainsQ[Z3ToSMTLIB[Abs[x] + Min[x, y] == 0, {x, y} \[Element] Integers], "(abs x)"], True, TestID -> "translate-abs"];

(* ---- chained inequality + mod solving ---- *)

VerificationTest[With[{m = Z3Solve[2 < x < 5, x \[Element] Integers]}, 2 < m[x] < 5], True, TestID -> "solve-chained"];
VerificationTest[Z3Solve[Mod[x, 5] == 2 && x > 10 && x < 17, x \[Element] Integers][x], 12, TestID -> "solve-mod"];

(* ---- numeric option ---- *)

VerificationTest[
  Abs[Z3Solve[s^2 == 2 && s > 0, s \[Element] Reals, "Numeric" -> True][s] - Sqrt[2.]] < 10^-6,
  True, TestID -> "numeric-option"
];

(* ---- push / pop / reset ---- *)

VerificationTest[
  Module[{s = Z3CreateSolver[], r1, r2},
    Z3Assert[s, x > 0 && x < 10, x \[Element] Integers];
    Z3Push[s]; Z3Assert[s, x > 20, x \[Element] Integers];
    r1 = Z3CheckSat[s];
    Z3Pop[s]; r2 = Z3CheckSat[s];
    {r1, r2}],
  {"unsat", "sat"}, TestID -> "push-pop"
];

VerificationTest[
  Module[{s = Z3CreateSolver[]},
    Z3Assert[s, x > 5, x \[Element] Integers];
    Z3Reset[s];
    Z3Assert[s, x < 3, x \[Element] Integers];
    Z3CheckSat[s]],
  "sat", TestID -> "reset"
];

(* ---- eval ---- *)

VerificationTest[
  Module[{s = Z3CreateSolver[]},
    Z3Assert[s, x == 5, x \[Element] Integers];
    Z3CheckSat[s];
    Z3Eval[s, x + 1]],
  6, TestID -> "eval"
];

(* ---- unsat core ---- *)

VerificationTest[
  Module[{s = Z3CreateSolver[]},
    Z3Assert[s, x > 10, x \[Element] Integers];
    Z3Assert[s, x < 0, x \[Element] Integers];
    Z3CheckSat[s];
    Sort[Z3UnsatCore[s]] === Sort[{x > 10, x < 0}]],
  True, TestID -> "unsat-core"
];

(* ---- statistics ---- *)

VerificationTest[
  Module[{s = Z3CreateSolver[]},
    Z3Assert[s, x*x + y*y == 25 && x > 0 && y > 0, {x, y} \[Element] Integers];
    Z3CheckSat[s];
    With[{st = Z3Statistics[s]}, AssociationQ[st] && Length[st] > 0]],
  True, TestID -> "statistics"
];

(* ---- optimization: minimize + optimizer object ---- *)

VerificationTest[Z3Optimize[x -> Minimize, x > 5 && x < 100, x \[Element] Integers]["Objective"], 6, TestID -> "optimize-min"];

VerificationTest[
  Module[{o = Z3CreateSolver["Optimize"]},
    Z3Assert[o, x + y == 10 && x >= 0 && y >= 0, {x, y} \[Element] Integers];
    Z3Maximize[o, x];
    Z3CheckSat[o];
    Lookup[Z3Model[o], x]],
  10, TestID -> "optimizer-object"
];

(* ---- quantifiers (message-free heads) ---- *)

VerificationTest[Z3ProvableQ[Z3ForAll[x \[Element] Integers, x^2 >= 0], {}], True, TestID -> "forall-provable"];
VerificationTest[Z3SatisfiableQ[Z3Exists[x \[Element] Integers, x > 100 && x < 102], {}], True, TestID -> "exists-sat"];

(* ---- arrays via Z3Store ---- *)

VerificationTest[
  Module[{m = Z3Array["m", "Int", "Int"], y = Z3Int["y"]},
    Lookup[Z3Solve[{Z3Select[Z3Store[m, 1, 7], 1] == y}], "y"]],
  7, TestID -> "array-store"
];

(* ---- Min / Max ---- *)

VerificationTest[Z3Solve[Min[x, y] == 2 && x == 5, {x, y} \[Element] Integers][y], 2, TestID -> "solve-min"];
VerificationTest[Z3Solve[Max[x, y] == 10 && x == 3, {x, y} \[Element] Integers][y], 10, TestID -> "solve-max"];

(* ---- Z3Solve on a raw SMT-LIB string routes to Z3RunSMTLIB ---- *)

VerificationTest[
  StringContainsQ[Z3Solve["(declare-const a Int)(assert (= a 9))(check-sat)(get-value (a))"], "9"],
  True, TestID -> "solve-string-route"
];

(* ---- diagnostics: a bad executable path gives a clear message + $Failed ---- *)

VerificationTest[Z3SetExecutable["/no/such/z3-binary"], $Failed,
  {Z3SetExecutable::nz3}, TestID -> "diag-bad-executable"];

(* ---- MOCK: cross-platform discovery + download-URL resolution, exercised on
   every OS without any network/download (the Linux/macOS paths we cannot run live) ---- *)

VerificationTest[WolframInstitute`Z3`Private`z3PlatformInfo["Linux-x86-64"], {"x64-glibc", "z3"}, TestID -> "mock-platform-linux"];
VerificationTest[WolframInstitute`Z3`Private`z3PlatformInfo["Linux-ARM64"], {"arm64-glibc", "z3"}, TestID -> "mock-platform-linux-arm"];
VerificationTest[WolframInstitute`Z3`Private`z3PlatformInfo["MacOSX-ARM64"], {"arm64-osx", "z3"}, TestID -> "mock-platform-macos"];
VerificationTest[WolframInstitute`Z3`Private`z3PlatformInfo["Windows-ARM64"], {"arm64-win", "z3.exe"}, TestID -> "mock-platform-winarm"];
VerificationTest[WolframInstitute`Z3`Private`z3PlatformInfo["Plan9-x86"], $Failed, TestID -> "mock-platform-unknown"];

VerificationTest[WolframInstitute`Z3`Private`z3AssetURL["4.16.0", "Linux-x86-64"],
  "https://github.com/Z3Prover/z3/releases/download/z3-4.16.0/z3-4.16.0-x64-glibc-2.39.zip", TestID -> "mock-url-linux"];
VerificationTest[WolframInstitute`Z3`Private`z3AssetURL["4.16.0", "MacOSX-ARM64"],
  "https://github.com/Z3Prover/z3/releases/download/z3-4.16.0/z3-4.16.0-arm64-osx-15.7.3.zip", TestID -> "mock-url-macos"];
VerificationTest[WolframInstitute`Z3`Private`z3AssetURL["4.16.0", "MacOSX-x86-64"],
  "https://github.com/Z3Prover/z3/releases/download/z3-4.16.0/z3-4.16.0-x64-osx-15.7.3.zip", TestID -> "mock-url-macos-x64"];
VerificationTest[WolframInstitute`Z3`Private`z3AssetURL["4.16.0", "Windows-x86-64"],
  "https://github.com/Z3Prover/z3/releases/download/z3-4.16.0/z3-4.16.0-x64-win.zip", TestID -> "mock-url-win"];
VerificationTest[WolframInstitute`Z3`Private`z3AssetURL["4.16.0", "Plan9-x86"], $Failed, TestID -> "mock-url-unknown"];

EndTestSection[];
