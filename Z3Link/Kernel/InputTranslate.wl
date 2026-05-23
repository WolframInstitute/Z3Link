(* ::Package:: *)

(* Native Wolfram expression -> SMT-LIB2 text.
   Two input styles both flow through here:
     Style 1: ordinary symbolic expressions + a domain spec (vars in Integers, etc.)
     Style 2: typed handles (Z3Int[...]) carrying their own SMT text + declarations.
   compileConstraints[] returns declarations, assertions, and the variable->key map
   used to label the model that comes back. *)

(* ---------- sorts ---------- *)

domSort[Integers] := "Int";
domSort["Int" | "Integer"] := "Int";
domSort[Reals] := "Real";
domSort["Real"] := "Real";
domSort[Booleans] := "Bool";
domSort["Bool" | "Boolean"] := "Bool";
domSort["String" | Strings] := "String";
domSort[{"BitVec", n_Integer}] := "(_ BitVec " <> ToString[n] <> ")";
domSort[{"Array", d_, r_}] := "(Array " <> domSort[d] <> " " <> domSort[r] <> ")";
domSort[s_String] := s;
domSort[s_] := (Message[Z3Solve::sort, s]; Throw[$Failed, "Z3Translate"]);
Z3Solve::sort = "Unknown sort specification `1`.";

(* ---------- numerals ---------- *)

smtSymbolName[s_Symbol] := SymbolName[Unevaluated[s]];
smtSymbolName[s_String] := s;
SetAttributes[smtSymbolName, HoldFirst];

emitInt[n_Integer] := If[n < 0, "(- " <> ToString[-n] <> ")", ToString[n]];

emitRational[r_Rational] := With[{p = Numerator[r], q = Denominator[r]},
  If[p < 0,
    "(- (/ " <> ToString[-p] <> " " <> ToString[q] <> "))",
    "(/ " <> ToString[p] <> " " <> ToString[q] <> ")"]
];

realLit[n_Integer] := If[n < 0, "(- " <> ToString[-n] <> ".0)", ToString[n] <> ".0"];
emitReal[x_] := Module[{rr = Rationalize[x, 0]},
  If[IntegerQ[rr], realLit[rr],
    "(/ " <> realLit[Numerator[rr]] <> " " <> realLit[Denominator[rr]] <> ")"]
];

(* ---------- the translator ---------- *)

$z3BuiltinHeads = {Plus, Times, Power, Subtract, Divide, Equal, Unequal, Less,
  Greater, LessEqual, GreaterEqual, And, Or, Not, Implies, Xor, Equivalent, Nand,
  Nor, If, Mod, Quotient, Abs, Min, Max, Boole, Floor, Ceiling, ForAll, Exists,
  Z3ForAll, Z3Exists, Z3Select, Z3Store, Z3Expr, Z3Raw, List, Element};

nary[op_String, args_List] := "(" <> op <> " " <> StringRiffle[toSMT /@ args, " "] <> ")";

toSMT[Z3Expr[smt_String, _, _]] := smt;
toSMT[i_Integer] := emitInt[i];
toSMT[r_Rational] := emitRational[r];
toSMT[r_Real] := emitReal[r];
toSMT[True] := "true";
toSMT[False] := "false";

(* Note: match n-ary heads as e_Head (NOT Head[a__]) because Plus[a__], Equal[a__],
   And[a__], Nand[a__] etc. auto-evaluate at definition time (OneIdentity / single-arg
   rules: Plus[x]->x, Equal[x]->True), which silently corrupts the DownValue. *)

toSMT[e_Plus] := nary["+", List @@ e];

toSMT[e_Times] := Module[{args = List @@ e},
  Which[
    MatchQ[args, {-1, _}], "(- " <> toSMT[args[[2]]] <> ")",
    MatchQ[args, {-1, __}], "(- (* " <> StringRiffle[toSMT /@ Rest[args], " "] <> "))",
    True, nary["*", args]
  ]
];

powSMT[s_String, n_Integer] := Which[
  n == 0, "1",
  n == 1, s,
  2 <= n <= 256, "(* " <> StringRiffle[ConstantArray[s, n], " "] <> ")",
  n <= -1, "(/ 1.0 " <> powSMT[s, -n] <> ")",
  True, "(^ " <> s <> " " <> ToString[n] <> ")"
];
toSMT[HoldPattern[Power[a_, n_Integer]]] := powSMT[toSMT[a], n];
toSMT[HoldPattern[Power[a_, b_]]] := "(^ " <> toSMT[a] <> " " <> toSMT[b] <> ")";

toSMT[e_Equal] := nary["=", List @@ e];
toSMT[e_Unequal] := nary["distinct", List @@ e];
toSMT[e_Less] := nary["<", List @@ e];
toSMT[e_Greater] := nary[">", List @@ e];
toSMT[e_LessEqual] := nary["<=", List @@ e];
toSMT[e_GreaterEqual] := nary[">=", List @@ e];

toSMT[e_And] := nary["and", List @@ e];
toSMT[e_Or] := nary["or", List @@ e];
toSMT[HoldPattern[Not[a_]]] := "(not " <> toSMT[a] <> ")";
toSMT[HoldPattern[Implies[a_, b_]]] := "(=> " <> toSMT[a] <> " " <> toSMT[b] <> ")";
toSMT[e_Xor] := nary["xor", List @@ e];
toSMT[HoldPattern[Equivalent[a_, b_]]] := "(= " <> toSMT[a] <> " " <> toSMT[b] <> ")";
toSMT[e_Nand] := "(not " <> nary["and", List @@ e] <> ")";
toSMT[e_Nor] := "(not " <> nary["or", List @@ e] <> ")";

toSMT[If[c_, t_, e_]] := "(ite " <> toSMT[c] <> " " <> toSMT[t] <> " " <> toSMT[e] <> ")";

toSMT[Mod[a_, b_]] := "(mod " <> toSMT[a] <> " " <> toSMT[b] <> ")";
toSMT[Quotient[a_, b_]] := "(div " <> toSMT[a] <> " " <> toSMT[b] <> ")";
toSMT[Abs[a_]] := "(abs " <> toSMT[a] <> ")";
toSMT[Floor[a_]] := "(to_int " <> toSMT[a] <> ")";
toSMT[Ceiling[a_]] := "(- (to_int (- " <> toSMT[a] <> ")))";
toSMT[Boole[a_]] := "(ite " <> toSMT[a] <> " 1 0)";

toSMT[e_Min] := minmaxSMT["<=", toSMT /@ (List @@ e)];
toSMT[e_Max] := minmaxSMT[">=", toSMT /@ (List @@ e)];
minmaxSMT[op_, {x_}] := x;
minmaxSMT[op_, {x_, y_, rest___}] := minmaxSMT[op,
  {"(ite (" <> op <> " " <> x <> " " <> y <> ") " <> x <> " " <> y <> ")", rest}];

toSMT[Z3Select[a_, i_]] := "(select " <> toSMT[a] <> " " <> toSMT[i] <> ")";
toSMT[Z3Store[a_, i_, v_]] := "(store " <> toSMT[a] <> " " <> toSMT[i] <> " " <> toSMT[v] <> ")";

(* quantifiers: reuse WL ForAll/Exists; bound vars carry sorts via Element.
   {x,y} \[Element] dom canonicalizes to Element[x|y, dom] (Alternatives). *)
parseBound1[Element[v_Alternatives, dom_]] := With[{s = domSort[dom]},
  ("(" <> smtSymbolName[#] <> " " <> s <> ")") & /@ (List @@ v)];
parseBound1[Element[v_List, dom_]] := With[{s = domSort[dom]},
  ("(" <> smtSymbolName[#] <> " " <> s <> ")") & /@ v];
parseBound1[Element[v_, dom_]] := {"(" <> smtSymbolName[v] <> " " <> domSort[dom] <> ")"};
parseBound[b_List] /; AllTrue[b, MatchQ[#, _Element] &] := Join @@ (parseBound1 /@ b);
parseBound[b_] := parseBound1[b];

toSMT[e_ForAll] := quantSMT["forall", List @@ e];
toSMT[e_Exists] := quantSMT["exists", List @@ e];
(* clean, message-free quantifier heads (ForAll[Element[..]] prints a benign ForAll::ivar) *)
toSMT[Z3ForAll[args__]] := quantSMT["forall", {args}];
toSMT[Z3Exists[args__]] := quantSMT["exists", {args}];
quantSMT[q_, {b_, body_}] := "(" <> q <> " (" <> StringRiffle[parseBound[b], " "] <> ") " <> toSMT[body] <> ")";
quantSMT["forall", {b_, cond_, body_}] := quantSMT["forall", {b, Implies[cond, body]}];
quantSMT["exists", {b_, cond_, body_}] := quantSMT["exists", {b, And[cond, body]}];

toSMT[s_Symbol] := smtSymbolName[s];

(* generic application = (uninterpreted) function call *)
toSMT[f_Symbol[args__]] /; FreeQ[$z3BuiltinHeads, f] :=
  "(" <> smtSymbolName[f] <> " " <> StringRiffle[toSMT /@ {args}, " "] <> ")";

toSMT[e_] := (Message[Z3Solve::trans, ToString[e, InputForm]]; Throw[$Failed, "Z3Translate"]);
Z3Solve::trans = "Unable to translate `1` to SMT-LIB2.";

(* ---------- declarations / domain spec ---------- *)

declEntry[name_String, sortStr_String, key_] := <|
  "Name" -> name,
  "Decl" -> "(declare-const " <> name <> " " <> sortStr <> ")",
  "Sort" -> sortStr, "Key" -> key, "Kind" -> "Const"|>;

parseDomItem[Element[v_Alternatives, dom_]] := With[{s = domSort[dom]},
  (declEntry[smtSymbolName[#], s, #]) & /@ (List @@ v)];
parseDomItem[Element[v_List, dom_]] := With[{s = domSort[dom]},
  (declEntry[smtSymbolName[#], s, #]) & /@ v];
parseDomItem[Element[v_, dom_]] := {declEntry[smtSymbolName[v], domSort[dom], v]};
parseDomItem[Rule[v_, dom_]] := {declEntry[smtSymbolName[v], domSort[dom], v]};
parseDomItem[other_] := (Message[Z3Solve::domain, other]; Throw[$Failed, "Z3Translate"]);
Z3Solve::domain = "Unrecognized domain specification `1`.";

parseDomain[Automatic] := <||>;
parseDomain[None] := <||>;
parseDomain[{}] := <||>;
parseDomain[spec_] := Module[{entries},
  entries = If[Head[spec] === List,
    Join @@ (parseDomItem /@ spec),
    parseDomItem[spec]];
  Association[(#["Name"] -> #) & /@ entries]
];

(* collect declarations carried by Z3Expr handles in the constraints *)
collectHandleDecls[expr_] := Module[{handles},
  handles = Cases[{expr}, Z3Expr[_, _, d_Association] :> d, Infinity];
  If[handles === {}, <||>, Join @@ handles]
];

(* ---------- top-level compile ---------- *)

normalizeConstraints[l_List] := Flatten[normalizeConstraints /@ l];
normalizeConstraints[And[a__]] := Flatten[normalizeConstraints /@ {a}];
normalizeConstraints[Z3Expr[s_, sort_, d_]] := {Z3Expr[s, sort, d]};
normalizeConstraints[x_] := {x};

compileConstraints[constraints_, domainSpec_] := Catch[
  Module[{clist, domDecls, handleDecls, decls, asserts},
    clist = normalizeConstraints[constraints];
    domDecls = parseDomain[domainSpec];
    handleDecls = collectHandleDecls[clist];
    decls = Join[handleDecls, domDecls];          (* domain spec wins on conflict *)
    asserts = toSMT /@ clist;
    <|"Decls" -> decls, "Asserts" -> asserts, "Constraints" -> clist|>
  ],
  "Z3Translate"
];

(* build a full one-shot script (declarations + assertions) *)
buildScript[compiled_Association] := Module[{declLines, assertLines},
  declLines = (#["Decl"]) & /@ Values[compiled["Decls"]];
  assertLines = ("(assert " <> # <> ")") & /@ compiled["Asserts"];
  StringRiffle[Join[declLines, assertLines], "\n"]
];

(* names + keys of constant variables, for labelling the model *)
constVarKeys[compiled_Association] := Association[
  KeyValueMap[#1 -> #2["Key"] &,
    Select[compiled["Decls"], #["Kind"] === "Const" &]]
];
