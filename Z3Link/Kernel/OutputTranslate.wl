(* ::Package:: *)

(* z3 S-expression results -> idiomatic, exact Wolfram values.
   Integers/rationals/algebraics stay exact; bit-vectors become integers;
   uninterpreted functions and arrays become callable pure Functions. *)

(* ---------- atoms ---------- *)

exactDecimal[s_String] := Module[{neg, t, parts, ip, fp},
  neg = StringStartsQ[s, "-"];
  t = If[neg, StringDrop[s, 1], s];
  parts = StringSplit[t, "."];
  Which[
    Length[parts] == 1, (If[neg, -1, 1]) FromDigits[parts[[1]]],
    True,
      ip = parts[[1]]; fp = parts[[2]];
      (If[neg, -1, 1]) (FromDigits[ip] + If[fp === "", 0, FromDigits[fp]/10^StringLength[fp]])
  ]
];

interpAtom[s_String] := Which[
  s === "true", True,
  s === "false", False,
  StringMatchQ[s, "#x" ~~ __], FromDigits[StringDrop[s, 2], 16],
  StringMatchQ[s, "#b" ~~ __], FromDigits[StringDrop[s, 2], 2],
  StringMatchQ[s, ("-" | "") ~~ DigitCharacter ..], ToExpression[s],
  StringMatchQ[s, ("-" | "") ~~ DigitCharacter .. ~~ "." ~~ (DigitCharacter ...)], exactDecimal[s],
  True, s
];

(* ---------- general value/body translator with a binder environment ---------- *)

toWL[Z3String[s_], _] := s;
toWL[s_String, env_] := If[KeyExistsQ[env, s], env[s], interpAtom[s]];

toWL[{"-", a_}, env_] := -toWL[a, env];
toWL[{"-", a_, b__}, env_] := toWL[a, env] - Total[toWL[#, env] & /@ {b}];
toWL[{"+", a__}, env_] := Total[toWL[#, env] & /@ {a}];
toWL[{"*", a__}, env_] := Times @@ (toWL[#, env] & /@ {a});
toWL[{"/", a_, b_}, env_] := toWL[a, env]/toWL[b, env];
toWL[{"^", a_, b_}, env_] := toWL[a, env]^toWL[b, env];

toWL[{"=", a_, b_}, env_] := toWL[a, env] == toWL[b, env];
toWL[{"<", a_, b_}, env_] := toWL[a, env] < toWL[b, env];
toWL[{">", a_, b_}, env_] := toWL[a, env] > toWL[b, env];
toWL[{"<=", a_, b_}, env_] := toWL[a, env] <= toWL[b, env];
toWL[{">=", a_, b_}, env_] := toWL[a, env] >= toWL[b, env];
toWL[{"and", a__}, env_] := And @@ (toWL[#, env] & /@ {a});
toWL[{"or", a__}, env_] := Or @@ (toWL[#, env] & /@ {a});
toWL[{"not", a_}, env_] := Not[toWL[a, env]];
toWL[{"=>", a_, b_}, env_] := Implies[toWL[a, env], toWL[b, env]];
(* force branch evaluation before building If, which otherwise holds them (HoldRest) *)
toWL[{"ite", c_, t_, e_}, env_] := With[
  {cc = toWL[c, env], tt = toWL[t, env], ee = toWL[e, env]}, If[cc, tt, ee]];

toWL[{"_", bv_String, _}, env_] /; StringStartsQ[bv, "bv"] := FromDigits[StringDrop[bv, 2]];
toWL[{"_", "as-array", f_}, env_] := Z3FunctionRef[f];

toWL[{"root-obj", poly_, idx_}, env_] := makeRoot[poly, idx];

(* arrays: constant arrays and store-chains become callable Functions *)
toWL[{{"as", "const", _}, d_}, env_] := With[{dv = toWL[d, env]}, Function[dv]];
toWL[{"store", arr_, i_, v_}, env_] := With[
  {a = toWL[arr, env], ii = toWL[i, env], vv = toWL[v, env]},
  Function[If[# == ii, vv, a[#]]]];
toWL[{"lambda", binders_List, body_}, env_] := bodyToFunction[binders, body, env];

(* datatype constructors / enum constants *)
toWL[{f_String, args__}, env_] := makeSymbol[f][Sequence @@ (toWL[#, env] & /@ {args})];
toWL[atom_, env_] := atom;

makeSymbol[s_String] := If[StringMatchQ[s, (LetterCharacter | "_") ~~ (WordCharacter | "_") ...],
  Symbol[s], s];

translateValue[v_] := toWL[v, <||>];

(* ---------- algebraic numbers ---------- *)

sexprToSlot["x"] := Slot[1];
sexprToSlot[s_String] := interpAtom[s];
sexprToSlot[{"+", a__}] := Plus @@ (sexprToSlot /@ {a});
sexprToSlot[{"-", a_}] := -sexprToSlot[a];
sexprToSlot[{"-", a_, b__}] := sexprToSlot[a] - Plus @@ (sexprToSlot /@ {b});
sexprToSlot[{"*", a__}] := Times @@ (sexprToSlot /@ {a});
sexprToSlot[{"/", a_, b_}] := sexprToSlot[a]/sexprToSlot[b];
sexprToSlot[{"^", a_, b_}] := sexprToSlot[a]^sexprToSlot[b];

makeRoot[poly_, idx_] := Root[Function[Evaluate[sexprToSlot[poly]]], ToExpression[idx]];

(* ---------- function models ---------- *)

bodyToFunction[binders_List, body_, env0_ : <||>] := Module[{names, formals, env},
  names = First /@ binders;       (* binder = {name, sort} *)
  formals = Table[Unique["z3arg"], {Length[names]}];
  env = Join[env0, AssociationThread[names -> formals]];
  Function[Evaluate[formals], Evaluate[toWL[body, env]]]
];

(* ---------- model / get-value ---------- *)

statusFromForms[forms_List] := FirstCase[forms, ("sat" | "unsat" | "unknown"), Missing[]];

stripModelHead[m_] := If[MatchQ[m, {"model", ___}], Rest[m], m];

(* model -> association name(String) -> value *)
parseModel[forms_List] := Module[{m},
  m = FirstCase[forms, _List, Missing[]];
  If[MissingQ[m], Return[<||>]];
  m = stripModelHead[m];
  Association[parseDefineFun /@ Cases[m, {"define-fun", __}]]
];

parseDefineFun[{"define-fun", name_String, binders_, sort_, body_}] :=
  name -> If[binders === {} || binders === "",
    translateValue[body],
    bodyToFunction[binders, body]];

(* get-value response: ((term val) (term val) ...) -> assoc *)
parseGetValue[forms_List] := Module[{lst},
  lst = FirstCase[forms, _List, {}];
  Association[(sexprText[#[[1]]] -> translateValue[#[[2]]]) & /@ lst]
];

sexprText[s_String] := s;
sexprText[Z3String[s_]] := s;
sexprText[l_List] := "(" <> StringRiffle[sexprText /@ l, " "] <> ")";

(* statistics: (:key1 v1 :key2 v2 ...) -> association *)
parseStatistics[forms_List] := Module[{lst},
  lst = FirstCase[forms, _List, {}];
  If[MatchQ[lst, {_String, {__}}] && StringStartsQ[lst[[1]], ":"], lst = lst[[2]]];
  Association[
    Cases[Partition[lst, 2],
      {k_String, v_} /; StringStartsQ[k, ":"] :> (StringDrop[k, 1] -> translateValue[v])]]
];

(* relabel a string-keyed model with the original Wolfram variable expressions *)
relabelModel[model_Association, varKeys_Association] := Association[
  KeyValueMap[
    Function[{name, val}, Lookup[varKeys, name, name] -> val],
    model]
];
