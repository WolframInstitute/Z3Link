#!/usr/bin/env wolframscript

(* Install the built .paclet and run the verification suite against it. *)

root = ParentDirectory[DirectoryName[$InputFileName]];
pacletFile = First[FileNames["*.paclet", root], $Failed];
If[pacletFile === $Failed, Print["No .paclet found; run build.wls first."]; Exit[1]];

Print["Installing ", FileNameTake[pacletFile], " ..."];
PacletInstall[pacletFile, ForceVersionInstall -> True];
Needs["WolframInstitute`Z3`"];
Print["z3 version: ", Z3Version[]];

report = TestReport[FileNameJoin[{root, "Z3", "Tests", "Tests.wlt"}]];
results = Values[report["TestResults"]];
Print["\n--- results ---"];
Scan[Print["  ", #["Outcome"], "  ", #["TestID"]] &, results];
Print["\nPassed ", report["TestsSucceededCount"], " / ", Length[results]];
If[report["TestsFailedCount"] > 0,
  Print["\nFAILED detail:"];
  Scan[Print["  ", #["TestID"], "  actual: ", #["ActualOutput"]] &,
    Select[results, #["Outcome"] =!= "Success" &]]
];
Print["DONE-TESTS"];
