(* ::Package:: *)

(* Public API: one-shot solving, incremental solver objects, optimization, SMT-LIB interop. *)

(* ---------- options ---------- *)

Options[Z3Solve] = {"Timeout" -> Automatic, "Numeric" -> False, "Options" -> {}};
Options[Z3Optimize] = {"Timeout" -> Automatic, "Numeric" -> False, "Options" -> {}};

optionCommands[opts_List] := StringRiffle[
  Function[r, "(set-option :" <> First[r] <> " " <> smtOptionValue[Last[r]] <> ")"] /@ opts, "\n"];
smtOptionValue[True] := "true";
smtOptionValue[False] := "false";
smtOptionValue[x_Integer] := ToString[x];
smtOptionValue[x_String] := x;
smtOptionValue[x_] := ToString[x];

applyOptions[id_, opts_List] := Module[{cmds = {}, t},
  t = "Timeout" /. opts /. "Timeout" -> Automatic;
  If[IntegerQ[t], AppendTo[cmds, "(set-option :timeout " <> ToString[t] <> ")"]];
  cmds = Join[cmds, {optionCommands["Options" /. opts /. "Options" -> {}]}];
  cmds = DeleteCases[cmds, "" | Null];
  If[cmds =!= {}, z3RawSend[id, StringRiffle[cmds, "\n"]]];
];

(* ---------- one-shot Z3Solve ---------- *)

Z3Solve[constraints_, opts : OptionsPattern[]] := Z3Solve[constraints, Automatic, opts];

(* shift a misplaced option in the domain slot *)
Z3Solve[c_, r_Rule, opts : OptionsPattern[]] /; MemberQ[Keys[Options[Z3Solve]], First[r]] :=
  Z3Solve[c, Automatic, r, opts];

Z3Solve[constraints_, domain_, opts : OptionsPattern[]] /; ! StringQ[constraints] := Module[
  {ol = Flatten[{opts}], compiled, id, status, model, result},
  compiled = compileConstraints[constraints, domain];
  If[FailureQ[compiled], Return[$Failed]];
  id = z3SessionStart[];
  If[! IntegerQ[id], Return[$Failed]];
  applyOptions[id, ol];
  z3RawSend[id, buildScript[compiled]];
  status = statusFromForms[z3Send[id, "(check-sat)"]];
  result = Switch[status,
    "sat",
      model = relabelModel[parseModel[z3Send[id, "(get-model)"]], constVarKeys[compiled]];
      If[TrueQ[OptionValue[Z3Solve, ol, "Numeric"]], N[model], model],
    "unsat", Unsatisfiable,
    _, Indeterminate
  ];
  z3SessionEnd[id];
  result
];

(* raw SMT-LIB string *)
Z3Solve[smt_String, opts : OptionsPattern[]] := Z3RunSMTLIB[smt];

Z3SatisfiableQ[constraints_, domain_ : Automatic] := With[
  {r = Z3Solve[constraints, domain]},
  Which[AssociationQ[r], True, r === Unsatisfiable, False, True, Indeterminate]];

Z3ProvableQ[claim_, domain_ : Automatic] := With[
  {r = Z3SatisfiableQ[Not[claim], domain]},
  Which[r === False, True, r === True, False, True, Indeterminate]];

(* ---------- SMT-LIB interop ---------- *)

Z3ToSMTLIB[constraints_, domain_ : Automatic] := Module[{compiled = compileConstraints[constraints, domain]},
  If[FailureQ[compiled], Return[$Failed]];
  buildScript[compiled] <> "\n(check-sat)\n(get-model)"
];

Z3RunSMTLIB[File[f_]] := Z3RunSMTLIB[Import[f, "Text"]];
Z3RunSMTLIB[text_String] := Module[{id, raw},
  id = z3SessionStart[];
  If[! IntegerQ[id], Return[$Failed]];
  raw = z3RawSend[id, text];
  z3SessionEnd[id];
  If[StringQ[raw], StringTrim[raw], $Failed]
];

(* ---------- incremental solver objects ---------- *)

Z3CreateSolver[type_ : "Solver"] := Module[{id = z3SessionStart[]},
  If[! IntegerQ[id], Return[$Failed]];
  $Z3Sessions[id, "VarKeys"] = <||>;
  $Z3Sessions[id, "Declared"] = {};
  $Z3Sessions[id, "Type"] = type;
  $Z3Sessions[id, "CoreCounter"] = 0;
  $Z3Sessions[id, "CoreMap"] = <||>;
  z3RawSend[id, "(set-option :produce-unsat-cores true)"];
  Z3SolverObject[id]
];

solverId[Z3SolverObject[id_]] := id;

Z3SolverObject /: MakeBoxes[Z3SolverObject[id_], form : (StandardForm | TraditionalForm)] :=
  With[{alive = z3SessionAliveQ[id], type = Lookup[$Z3Sessions[id], "Type", "Solver"]},
    InterpretationBox[
      RowBox[{"Z3SolverObject", "[", "<", ToBoxes[type, form], ":", ToBoxes[id, form],
        If[alive, "", ", dead"], ">", "]"}],
      Z3SolverObject[id]]];

Z3Assert[s : Z3SolverObject[id_], constraints_, domain_ : Automatic] := Module[
  {compiled, declared, newNames, declLines, asserts, cons, counter, coreMap, names, assertLines},
  compiled = compileConstraints[constraints, domain];
  If[FailureQ[compiled], Return[$Failed]];
  declared = Lookup[$Z3Sessions[id], "Declared", {}];
  newNames = Complement[Keys[compiled["Decls"]], declared];
  declLines = (compiled["Decls"][#]["Decl"]) & /@ newNames;
  asserts = compiled["Asserts"];
  cons = compiled["Constraints"];
  counter = Lookup[$Z3Sessions[id], "CoreCounter", 0];
  coreMap = Lookup[$Z3Sessions[id], "CoreMap", <||>];
  names = Table["g" <> ToString[counter + i], {i, Length[asserts]}];
  assertLines = MapThread["(assert (! " <> #1 <> " :named " <> #2 <> "))" &, {asserts, names}];
  MapThread[(coreMap[#2] = #1) &, {cons, names}];
  z3RawSend[id, StringRiffle[Join[declLines, assertLines], "\n"]];
  $Z3Sessions[id, "Declared"] = Union[declared, newNames];
  $Z3Sessions[id, "CoreCounter"] = counter + Length[asserts];
  $Z3Sessions[id, "CoreMap"] = coreMap;
  $Z3Sessions[id, "VarKeys"] = Join[Lookup[$Z3Sessions[id], "VarKeys", <||>], constVarKeys[compiled]];
  s
];

Z3UnsatCore[Z3SolverObject[id_]] := Module[{forms, names, coreMap},
  forms = z3Send[id, "(get-unsat-core)"];
  names = FirstCase[forms, _List, {}];
  coreMap = Lookup[$Z3Sessions[id], "CoreMap", <||>];
  Lookup[coreMap, #, #] & /@ names
];

Z3Statistics[Z3SolverObject[id_]] := parseStatistics[z3Send[id, "(get-info :all-statistics)"]];

Z3CheckSat[Z3SolverObject[id_], assumptions_ : None] := Module[{cmd, status},
  cmd = "(check-sat)";
  status = statusFromForms[z3Send[id, cmd]];
  status /. Missing[] -> "unknown"
];

Z3Model[Z3SolverObject[id_]] := relabelModel[
  KeyDrop[parseModel[z3Send[id, "(get-model)"]], Keys[Lookup[$Z3Sessions[id], "CoreMap", <||>]]],
  Lookup[$Z3Sessions[id], "VarKeys", <||>]];

Z3Eval[Z3SolverObject[id_], expr_] := Module[{smt = toSMT[expr], res},
  res = parseGetValue[z3Send[id, "(get-value (" <> smt <> "))"]];
  If[Length[res] == 1, First[Values[res]], res]
];

Z3Push[s : Z3SolverObject[id_]] := (z3RawSend[id, "(push)"]; s);
Z3Pop[s : Z3SolverObject[id_]] := (z3RawSend[id, "(pop)"]; s);
Z3Reset[s : Z3SolverObject[id_]] := (
  z3RawSend[id, "(reset)"];
  $Z3Sessions[id, "Declared"] = {};
  $Z3Sessions[id, "VarKeys"] = <||>;
  s);

Z3SetOption[s : Z3SolverObject[id_], opts__Rule] := (
  z3RawSend[id, optionCommands[{opts}]]; s);
Z3SetOption[opts__Rule] := (z3RawSend[z3DefaultSession[], optionCommands[{opts}]];);

(* close + free a solver's process *)
Z3SolverObject /: DeleteObject[Z3SolverObject[id_]] := z3SessionEnd[id];

(* ---------- optimization ---------- *)

ensureDecls[id_, expr_] := Module[{decls, declared, newNames},
  decls = collectHandleDecls[expr];
  declared = Lookup[$Z3Sessions[id], "Declared", {}];
  newNames = Complement[Keys[decls], declared];
  If[newNames =!= {},
    z3RawSend[id, StringRiffle[(decls[#]["Decl"]) & /@ newNames, "\n"]];
    $Z3Sessions[id, "Declared"] = Union[declared, newNames];
  ];
];

Z3Maximize[s : Z3SolverObject[id_], obj_] := (ensureDecls[id, obj]; z3RawSend[id, "(maximize " <> toSMT[obj] <> ")"]; s);
Z3Minimize[s : Z3SolverObject[id_], obj_] := (ensureDecls[id, obj]; z3RawSend[id, "(minimize " <> toSMT[obj] <> ")"]; s);

Z3Optimize[obj_ -> dir_, constraints_, domain_ : Automatic, opts : OptionsPattern[]] := Module[
  {ol = Flatten[{opts}], compiled, id, status, model, objval},
  compiled = compileConstraints[constraints, domain];
  If[FailureQ[compiled], Return[$Failed]];
  id = z3SessionStart[];
  If[! IntegerQ[id], Return[$Failed]];
  applyOptions[id, ol];
  z3RawSend[id, buildScript[compiled]];
  ensureDeclsFromCompiled[id, compiled];
  Switch[dir,
    Maximize, z3RawSend[id, "(maximize " <> toSMT[obj] <> ")"],
    Minimize, z3RawSend[id, "(minimize " <> toSMT[obj] <> ")"]
  ];
  status = statusFromForms[z3Send[id, "(check-sat)"]];
  model = If[status === "sat",
    relabelModel[parseModel[z3Send[id, "(get-model)"]], constVarKeys[compiled]], Unsatisfiable];
  objval = If[status === "sat", parseGetValue[z3Send[id, "(get-value (" <> toSMT[obj] <> "))"]], Missing[]];
  z3SessionEnd[id];
  If[status === "sat",
    <|"Status" -> status, "Objective" -> If[Length[objval] > 0, First[Values[objval]], Missing[]],
      "Model" -> If[TrueQ[OptionValue[Z3Optimize, ol, "Numeric"]], N[model], model]|>,
    <|"Status" -> status|>]
];

ensureDeclsFromCompiled[id_, compiled_] := ($Z3Sessions[id, "Declared"] = Keys[compiled["Decls"]]);
