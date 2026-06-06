#!/usr/bin/env wolframscript

(* Build the Z3Link documentation notebooks and the Paclet Repository
   ResourceDefinition.nb from the structured markdown in docs/ using
   MarkdownToNotebook (M2N), then pack the paclet.

   Run:  wolframscript -file build.wls

   This calls the public cloud deployment of MarkdownToNotebook (the converter is
   not yet on the public Function Repository), so it needs Wolfram Cloud access. *)

root = DirectoryName[$InputFileName]
pacletDir = FileNameJoin[{root, "Z3Link"}]
docsDir = FileNameJoin[{root, "docs"}]

mtn = ResourceFunction[ResourceObject["https://www.wolframcloud.com/obj/nikm/DeployedResources/Function/MarkdownToNotebook"]]

(* Load the local paclet so example cells resolve its symbols during evaluation. *)
PacletDirectoryLoad[pacletDir]

(* Template -> documentation subdirectory (relative to the paclet). Overview shares
   the tutorial/ URI namespace with TechNotes, so both land in Tutorials. *)
subdir = <|
    "Symbol" -> {"Documentation", "English", "ReferencePages", "Symbols"},
    "Guide" -> {"Documentation", "English", "Guides"},
    "TechNote" -> {"Documentation", "English", "Tutorials"},
    "Overview" -> {"Documentation", "English", "Tutorials"}
|>

(* Read the Template: field from a markdown file's YAML frontmatter. *)
templateOf[md_String] := First[
    StringCases[Import[md, "Text"],
        RegularExpression["(?m)^Template:[ \\t]*(\\S+)"] -> "$1", 1],
    "TechNote"
]

(* Build one markdown source into its notebook. The output basename is the SOURCE
   basename so it matches the URI's last segment (an Overview's display Name:
   differs from its "Overview" basename). A Paclet-template document (the
   ResourceDefinition) builds to ResourceDefinition.nb at the paclet root. *)
buildDoc[srcFile_String] := Block[{tmpl = templateOf[srcFile], base = FileBaseName[srcFile], dir, out},
    Which[
        tmpl === "Paclet",
            out = FileNameJoin[{pacletDir, "ResourceDefinition.nb"}];
            mtn[srcFile, out];
            Print["  ", FileNameTake[srcFile], " -> ResourceDefinition.nb"],
        KeyExistsQ[subdir, tmpl],
            dir = FileNameJoin[Prepend[subdir[tmpl], pacletDir]];
            Quiet @ CreateDirectory[dir, CreateIntermediateDirectories -> True];
            out = FileNameJoin[{dir, base <> ".nb"}];
            mtn[srcFile, out];
            Print["  ", FileNameTake[srcFile], " -> Documentation/English/", Last[subdir[tmpl]], "/", base, ".nb"],
        True,
            Print["  ! skipping ", FileNameTake[srcFile], " (unknown Template: ", tmpl, ")"]
    ]
]

Print["Building Z3Link documentation from ", docsDir, " ..."]
Scan[buildDoc, Sort @ FileNames["*.md", docsDir, Infinity]]

(* Pack the paclet. *)
Print["Packing paclet from ", pacletDir, " ..."]
PacletDataRebuild[]
archive = CreatePacletArchive[pacletDir]
dest = FileNameJoin[{root, FileNameTake[archive]}]
If[ archive =!= dest, CopyFile[archive, dest, OverwriteTarget -> True] ]
Print["Paclet archive: ", dest]
Print["done"]
