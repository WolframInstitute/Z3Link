#!/usr/bin/env wolframscript

(* tools/md2nb.wls -- minimal Markdown -> Wolfram Notebook converter.

   Usage:
       wolframscript -file md2nb.wls Notebooks/             # convert every .md
       wolframscript -file md2nb.wls Notebooks/01_intro.md  # convert one file

   Supported markdown:
     #..######    headings           -> Title / Section / Subsection / Subsubsection / Subsubsubsection / Subsubsubsubsection
     paragraph    blank-separated    -> "Text"
     ```lang ... ```                 -> "Input"  (lang in {wolfram, mathematica, wl}) else "Program"
     - / *  list                     -> "Item"
     1. list                         -> "ItemNumbered"
     > line                          -> "Text" with italic style
     ---                             -> a Cell["", "Text"] separator (kept simple)
     inline:  `code`                 -> monospace StyleBox
              **bold**               -> Bold StyleBox
              *italic*               -> Italic StyleBox

   Math ($...$ and $$...$$) is currently kept as raw text -- a TeX->box pass
   can be added without changing the structure.
*)

(* --------------------------------------------------------------- helpers *)

splitOnBlankLines[lines_List] := Module[{groups = {{}}, last = "blank"},
  Do[
    If[StringMatchQ[StringTrim[ln], ""],
      If[Last[groups] =!= {}, AppendTo[groups, {}]],
      groups[[-1]] = Append[groups[[-1]], ln]
    ],
    {ln, lines}];
  DeleteCases[groups, {}]
];

(* Inline parse: produce a TextData of String/StyleBox segments.  Order of
   regexes matters: we tokenize greedily left-to-right against the union of
   patterns, so a `code` match can't be eaten by a single-asterisk italic. *)
inlineParse[s_String] := Module[{parts, out, m, before, mid, after, rest = s,
    pat = RegularExpression["(`[^`]+`|\\*\\*[^*]+\\*\\*|\\*[^*]+\\*)"]},
  out = {};
  While[True,
    m = StringPosition[rest, pat, 1];
    If[m === {} || m === {{}}, AppendTo[out, rest]; Break[]];
    {{p1, p2}} = Take[m, 1];
    before = StringTake[rest, {1, p1 - 1}];
    mid    = StringTake[rest, {p1, p2}];
    after  = StringTake[rest, {p2 + 1, StringLength[rest]}];
    If[before =!= "", AppendTo[out, before]];
    AppendTo[out, formatInline[mid]];
    rest = after;
  ];
  TextData @ DeleteCases[out, ""]
];

formatInline[s_String] := Which[
  StringMatchQ[s, "`*`"],
    StyleBox[StringTake[s, {2, -2}], FontFamily -> "Source Code Pro", FontTracking -> "Plain"],
  StringMatchQ[s, "**" ~~ ___ ~~ "**"],
    StyleBox[StringTake[s, {3, -3}], FontWeight -> Bold],
  StringMatchQ[s, "*" ~~ ___ ~~ "*"],
    StyleBox[StringTake[s, {2, -2}], FontSlant -> Italic],
  True, s
];

(* --------------------------------------------------------------- block parser *)

(* classifyBlock: a block is a list of lines (no internal blank lines except
   inside a fenced code block).  Returns one or more Cell[...] expressions. *)

(* A block that looks like a heading: the first line starts with ##... *)
headingLevel[ln_String] := Module[{m},
  m = StringCases[ln, RegularExpression["^(#{1,6}) "] -> "$1"];
  If[m === {}, 0, StringLength[First[m]]]
];

headingStyle[1] = "Title";
headingStyle[2] = "Section";
headingStyle[3] = "Subsection";
headingStyle[4] = "Subsubsection";
headingStyle[5] = "Subsubsubsection";
headingStyle[6] = "Subsubsubsubsection";

stripHeading[ln_String] := StringTrim @ StringDrop[ln, headingLevel[ln] + 1];

(* List item detection. *)
unorderedItemQ[ln_String] := StringMatchQ[ln, RegularExpression["^[-*] .*"]];
orderedItemQ[ln_String]   := StringMatchQ[ln, RegularExpression["^[0-9]+\\. .*"]];
stripUnordered[ln_String] := StringDrop[ln, 2];
stripOrdered[ln_String]   := StringJoin @ Drop[Characters @ ln,
  StringPosition[ln, ". ", 1][[1, 2]]];

(* Block dispatch.  Each branch returns a list of Cells. *)
blockToCells[block_List] := Which[

  (* fenced code:  first line is ``` or ```lang, rest are code, last is ``` *)
  StringMatchQ[First[block], RegularExpression["^```.*"]],
    Module[{lang, body},
      lang = StringTrim @ StringDrop[First[block], 3];
      body = StringRiffle[
        Take[block, {2, -1 - Boole[StringMatchQ[Last[block], "```"]]}], "\n"];
      {Cell[BoxData @ body,
        If[MemberQ[{"wolfram", "mathematica", "wl"}, ToLowerCase[lang]],
          "Input", "Program"],
        ShowCellBracket -> True]}
    ],

  (* heading *)
  headingLevel[First[block]] > 0,
    {Cell[stripHeading[First[block]], headingStyle[headingLevel[First[block]]]]},

  (* unordered list: every line starts with - or * *)
  AllTrue[block, unorderedItemQ],
    Cell[inlineParse[stripUnordered[#]], "Item"] & /@ block,

  (* ordered list *)
  AllTrue[block, orderedItemQ],
    Cell[inlineParse[stripOrdered[#]], "ItemNumbered"] & /@ block,

  (* horizontal rule *)
  block === {"---"} || block === {"***"} || block === {"___"},
    {Cell["", "Text"]},

  (* blockquote: every line starts with > *)
  AllTrue[block, StringMatchQ[#, RegularExpression["^>.*"]] &],
    {Cell[inlineParse @ StringRiffle[StringTrim[StringDrop[#, 1]] & /@ block, " "],
       "Text", FontSlant -> Italic]},

  (* default: paragraph *)
  True,
    {Cell[inlineParse @ StringRiffle[block, " "], "Text"]}
];

(* --------------------------------------------------------------- driver *)

processFenced[lines_List] := Module[{out = {}, buf = {}, inFence = False, ln},
  Do[
    ln = lines[[i]];
    Which[
      StringMatchQ[ln, RegularExpression["^```.*"]] && !inFence,
        If[buf =!= {}, AppendTo[out, buf]; buf = {}];
        inFence = True; AppendTo[buf, ln],
      StringMatchQ[ln, "```"] && inFence,
        AppendTo[buf, ln];
        AppendTo[out, buf]; buf = {}; inFence = False,
      inFence,
        AppendTo[buf, ln],
      True,
        AppendTo[buf, ln]
    ],
    {i, Length[lines]}];
  If[buf =!= {}, AppendTo[out, buf]];
  out
];

(* Top-level: read .md, return Notebook[{Cell...}]. *)
mdToNotebook[mdPath_String] := Module[
  {src, lines, fenced, blocks, cells},
  src = Import[mdPath, "Text"];
  lines = StringSplit[src, "\n", All];
  (* First isolate fenced code blocks so blank lines inside don't split them. *)
  fenced = processFenced[lines];
  (* Each "fenced" group is either a code fence (already a single block) or a
     non-code chunk that we further split on blank lines. *)
  blocks = Flatten[
    Map[Function[g,
      If[Length[g] >= 1 && StringMatchQ[First[g], RegularExpression["^```.*"]],
        {g},
        splitOnBlankLines[g]
      ]
    ], fenced], 1];
  cells = Flatten[blockToCells /@ blocks];
  Notebook[cells, StyleDefinitions -> "Default.nb"]
];

convertOne[mdPath_String, nbPath_String] := Module[{nb},
  nb = mdToNotebook[mdPath];
  Export[nbPath, nb, "Notebook"];
  Print["[md2nb] ", FileNameTake[mdPath], " -> ", FileNameTake[nbPath]];
];

main[args_List] := Module[{targets, nbDir},
  targets = If[args === {} || (Length[args] == 1 && DirectoryQ[args[[1]]]),
    FileNames["*.md", If[args === {}, ".", args[[1]]]],
    Select[args, FileExistsQ]];
  If[targets === {},
    Print["[md2nb] no .md files found"]; Exit[1]];
  Do[
    nbDir = DirectoryName[md];
    convertOne[md, FileNameJoin[{nbDir, FileBaseName[md] <> ".nb"}]],
    {md, targets}];
  Print["[md2nb] done (", Length[targets], " file(s))"];
];

(* Run main only when invoked directly (not when Get-ed as a library by build.wls). *)
If[Length[$ScriptCommandLine] >= 1 && StringContainsQ[First[$ScriptCommandLine], "md2nb"],
  main[Rest[$ScriptCommandLine]]];
