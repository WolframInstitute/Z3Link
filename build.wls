#!/usr/bin/env wolframscript

(* build.wls -- generate documentation notebooks from docs/*.md and pack the .paclet.
   Run:  wolframscript -file build.wls   *)

root = DirectoryName[$InputFileName];
pacletDir = FileNameJoin[{root, "Z3"}];

(* 1. markdown -> notebooks *)
Get[FileNameJoin[{root, "tools", "md2nb.wls"}]];
tutDir = FileNameJoin[{pacletDir, "Documentation", "English", "Tutorials"}];
If[! DirectoryQ[tutDir], CreateDirectory[tutDir, CreateIntermediateDirectories -> True]];
docs = FileNames["*.md", FileNameJoin[{root, "docs"}]];
Print["Converting ", Length[docs], " markdown file(s) to notebooks..."];
Do[
  convertOne[md, FileNameJoin[{tutDir, FileBaseName[md] <> ".nb"}]],
  {md, docs}
];

(* 2. pack the paclet *)
Print["Packing paclet from ", pacletDir, " ..."];
PacletDataRebuild[];
archive = CreatePacletArchive[pacletDir];
Print["Built: ", archive];

(* place the archive in the project root for convenience *)
dest = FileNameJoin[{root, FileNameTake[archive]}];
If[archive =!= dest, CopyFile[archive, dest, OverwriteTarget -> True]];
Print["Paclet archive: ", dest];
