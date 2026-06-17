(* ::Package:: *)

(* Style 2: typed handles. Z3Int["x"] etc. return Z3Expr[smtText, sort, decls].
   Operator UpValues build compound Z3Expr nodes, mirroring z3py operator overloading.
   Z3Expr[smt, sort, decls]: decls maps name -> declaration entry (see InputTranslate). *)

(* Collect declarations from handles at ANY depth: operands may be native Plus/
   Times nodes (Orderless operators are not eagerly overloaded) with handles
   nested inside, whose SMT is emitted by toSMT but whose declarations would
   otherwise be missed by a level-1 scan. *)
mergeDecls[args_List] := With[{ds = Cases[args, Z3Expr[_, _, d_] :> d, Infinity]},
  If[ds === {}, <||>, Join @@ ds]];

funDeclEntry[name_String, argS_List, ret_String] := <|
  "Name" -> name,
  "Decl" -> "(declare-fun " <> name <> " (" <> StringRiffle[argS, " "] <> ") " <> ret <> ")",
  "Kind" -> "Fun", "Key" -> name|>;

(* ---- declarations ---- *)

(* Key is the variable name (string); models from handle-built problems are keyed by name. *)
Z3Const[name_String, sortSpec_] := With[{s = domSort[sortSpec]},
  Z3Expr[name, s, <|name -> declEntry[name, s, name]|>]];
Z3Int[name_String] := Z3Expr[name, "Int", <|name -> declEntry[name, "Int", name]|>];
Z3Real[name_String] := Z3Expr[name, "Real", <|name -> declEntry[name, "Real", name]|>];
Z3Bool[name_String] := Z3Expr[name, "Bool", <|name -> declEntry[name, "Bool", name]|>];
Z3BitVec[name_String, n_Integer] := With[{s = domSort[{"BitVec", n}]},
  Z3Expr[name, s, <|name -> declEntry[name, s, name]|>]];
Z3Array[name_String, d_, r_] := With[{s = domSort[{"Array", d, r}]},
  Z3Expr[name, s, <|name -> declEntry[name, s, name]|>]];

Z3BitVecVal[v_Integer, w_Integer] :=
  Z3Expr["(_ bv" <> ToString[v] <> " " <> ToString[w] <> ")", domSort[{"BitVec", w}], <||>];

(* generic SMT operator escape hatch: Z3Op["bvadd", a, b] -> (bvadd a b) *)
Z3Op[op_String, args__] := Z3Expr[
  "(" <> op <> " " <> StringRiffle[toSMT /@ {args}, " "] <> ")", "Unknown", mergeDecls[{args}]];

(* uninterpreted functions *)
Z3Function[name_String, argSorts_List, retSort_] :=
  Z3FunctionHandle[name, domSort /@ argSorts, domSort[retSort]];
Z3FunctionHandle[name_, argS_, ret_][args__] := Z3Expr[
  "(" <> name <> " " <> StringRiffle[toSMT /@ {args}, " "] <> ")", ret,
  Join[<|name -> funDeclEntry[name, argS, ret]|>, mergeDecls[{args}]]];

(* array term builders that compose when given handles *)
arrayRange[Z3Expr[_, s_String, _]] := With[
  {m = StringCases[s, "(Array " ~~ d__ ~~ " " ~~ r__ ~~ ")" :> r]},
  If[m === {}, "Unknown", First[m]]];
arrayRange[_] := "Unknown";

Z3Select[a_Z3Expr, i_] := Z3Expr[
  "(select " <> toSMT[a] <> " " <> toSMT[i] <> ")", arrayRange[a], mergeDecls[{a, i}]];
Z3Store[a_Z3Expr, i_, v_] := Z3Expr[
  "(store " <> toSMT[a] <> " " <> toSMT[i] <> " " <> toSMT[v] <> ")", a[[2]], mergeDecls[{a, i, v}]];

(* ---- operator overloading ---- *)

bvSortQ[s_String] := StringStartsQ[s, "(_ BitVec"];
anyBVQ[args_List] := AnyTrue[args, MatchQ[#, Z3Expr[_, _?bvSortQ, _]] &];
firstBVSort[args_List] := SelectFirst[args, MatchQ[#, Z3Expr[_, _?bvSortQ, _]] &][[2]];

realishQ[Z3Expr[_, "Real", _]] := True;
realishQ[_Real] := True;
realishQ[_] := False;
arithSort[args_List] := If[AnyTrue[args, realishQ], "Real", "Int"];

z3arith[op_, args_List] := Module[{bv = anyBVQ[args], opStr, sort},
  opStr = Switch[op,
    Plus, If[bv, "bvadd", "+"], Times, If[bv, "bvmul", "*"], Subtract, If[bv, "bvsub", "-"]];
  sort = If[bv, firstBVSort[args], arithSort[args]];
  Z3Expr["(" <> opStr <> " " <> StringRiffle[toSMT /@ args, " "] <> ")", sort, mergeDecls[args]]
];

z3bool[op_String, args_List] := Z3Expr[
  "(" <> op <> " " <> StringRiffle[toSMT /@ args, " "] <> ")", "Bool", mergeDecls[args]];

z3pow[x_Z3Expr, n_Integer] := Z3Expr[powSMT[x[[1]], n], x[[2]], x[[3]]];
z3pow[x_Z3Expr, n_] := Z3Expr["(^ " <> x[[1]] <> " " <> toSMT[n] <> ")", x[[2]], x[[3]]];

(* Plus/Times are Orderless: an UpValue pattern that anchors one handle among the
   args (a___, x_Z3Expr, b___) forces the Orderless matcher to enumerate how the
   other terms split across the two sequence blanks -- 2^n when many args are
   handles, e.g. an objective Total[handles]. We do NOT overload them eagerly.
   A sum/product of handles stays a native Plus/Times node (with the handles
   nested) and is converted at compile time by toSMT, which matches by head and
   walks the args once (linear) and whose collectHandleDecls pass picks up the
   nested handles' declarations. Ordered operators below stay eager: their
   a___,x,b___ matching is linear, and they are what turn an expression into an
   asserted constraint. *)
Z3Expr /: Power[x_Z3Expr, n_] := z3pow[x, n];

Z3Expr /: Equal[a___, x_Z3Expr, b___] := z3bool["=", {a, x, b}];
Z3Expr /: Unequal[a___, x_Z3Expr, b___] := z3bool["distinct", {a, x, b}];
Z3Expr /: Less[a___, x_Z3Expr, b___] := z3bool["<", {a, x, b}];
Z3Expr /: Greater[a___, x_Z3Expr, b___] := z3bool[">", {a, x, b}];
Z3Expr /: LessEqual[a___, x_Z3Expr, b___] := z3bool["<=", {a, x, b}];
Z3Expr /: GreaterEqual[a___, x_Z3Expr, b___] := z3bool[">=", {a, x, b}];

Z3Expr /: And[a___, x_Z3Expr, b___] := z3bool["and", {a, x, b}];
Z3Expr /: Or[a___, x_Z3Expr, b___] := z3bool["or", {a, x, b}];
Z3Expr /: Not[x_Z3Expr] := z3bool["not", {x}];
Z3Expr /: Implies[x_Z3Expr, b_] := z3bool["=>", {x, b}];
Z3Expr /: Implies[a_, x_Z3Expr] := z3bool["=>", {a, x}];
(* Xor is Orderless too -- not overloaded eagerly; compiled by toSMT (see Plus/Times). *)

(* readable display *)
Z3Expr /: MakeBoxes[Z3Expr[s_String, sort_, d_], form : (StandardForm | TraditionalForm)] :=
  RowBox[{"Z3Expr", "[", ToBoxes[s, form], ",", ToBoxes[sort, form], "]"}];
