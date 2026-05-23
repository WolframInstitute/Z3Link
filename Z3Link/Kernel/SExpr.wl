(* ::Package:: *)

(* S-expression reader: SMT-LIB2 response text -> nested Wolfram lists of string atoms.
   Atoms are kept as strings; numeric/structural interpretation happens in OutputTranslate.
   Strings are returned wrapped as Z3String["..."] so quoted content is never confused with atoms. *)

(* parse all top-level forms from a response string *)
parseSExprAll[text_String] := Module[{chars, pos, len, forms, f},
  chars = Characters[text];
  len = Length[chars];
  pos = 1;
  forms = {};
  While[True,
    pos = skipWS[chars, pos, len];
    If[pos > len, Break[]];
    f = readForm[chars, pos, len];
    If[f === $Failed, Break[]];
    forms = Append[forms, f[[1]]];
    pos = f[[2]];
  ];
  forms
];

(* a single form, error if more than one *)
parseSExpr[text_String] := With[{all = parseSExprAll[text]},
  Which[all === {}, Missing[], Length[all] == 1, First[all], True, all]
];

skipWS[chars_, pos0_, len_] := Module[{pos = pos0, c},
  While[pos <= len,
    c = chars[[pos]];
    Which[
      c === " " || c === "\t" || c === "\n" || c === "\r", pos++,
      c === ";", (* comment to end of line *)
        While[pos <= len && chars[[pos]] =!= "\n", pos++],
      True, Break[]
    ]
  ];
  pos
];

(* returns {form, nextPos} or $Failed *)
readForm[chars_, pos0_, len_] := Module[{pos, c},
  pos = skipWS[chars, pos0, len];
  If[pos > len, Return[$Failed]];
  c = chars[[pos]];
  Which[
    c === "(", readList[chars, pos + 1, len],
    c === ")", $Failed,
    c === "\"", readString[chars, pos + 1, len],
    c === "|", readQuotedSymbol[chars, pos + 1, len],
    True, readAtom[chars, pos, len]
  ]
];

readList[chars_, pos0_, len_] := Module[{pos = pos0, items = {}, f, c},
  While[True,
    pos = skipWS[chars, pos, len];
    If[pos > len, Return[$Failed]];
    c = chars[[pos]];
    If[c === ")", Return[{items, pos + 1}]];
    f = readForm[chars, pos, len];
    If[f === $Failed, Return[$Failed]];
    items = Append[items, f[[1]]];
    pos = f[[2]];
  ]
];

(* SMT-LIB strings: double-quote delimited, embedded quote escaped as "" *)
readString[chars_, pos0_, len_] := Module[{pos = pos0, sb = {}, c},
  While[pos <= len,
    c = chars[[pos]];
    If[c === "\"",
      If[pos + 1 <= len && chars[[pos + 1]] === "\"",
        (sb = Append[sb, "\""]; pos += 2),
        Return[{Z3String[StringJoin[sb]], pos + 1}]
      ],
      (sb = Append[sb, c]; pos++)
    ]
  ];
  {Z3String[StringJoin[sb]], pos}
];

readQuotedSymbol[chars_, pos0_, len_] := Module[{pos = pos0, sb = {}, c},
  While[pos <= len,
    c = chars[[pos]];
    If[c === "|", Return[{StringJoin[sb], pos + 1}], (sb = Append[sb, c]; pos++)]
  ];
  {StringJoin[sb], pos}
];

readAtom[chars_, pos0_, len_] := Module[{pos = pos0, sb = {}, c},
  While[pos <= len,
    c = chars[[pos]];
    If[c === " " || c === "\t" || c === "\n" || c === "\r" || c === "(" || c === ")",
      Break[], (sb = Append[sb, c]; pos++)]
  ];
  {StringJoin[sb], pos}
];
