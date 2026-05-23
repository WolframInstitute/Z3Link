(* ::Package:: *)

(* z3 location: explicit override -> system (PATH/common dirs) -> downloaded cache -> download.
   The result is memoized for the session. Download is the guaranteed fallback on every platform. *)

$Z3DefaultVersion = "4.16.0";

(* Map $SystemID to {assetSubstring, executableName}. assetSubstring matches the
   github release zip name (suffixes like glibc/osx versions vary, so we match a substring). *)
z3PlatformInfo[] := Switch[$SystemID,
  "Windows-x86-64", {"x64-win", "z3.exe"},
  "Windows-ARM64",  {"arm64-win", "z3.exe"},
  "Linux-x86-64",   {"x64-glibc", "z3"},
  "Linux-ARM64" | "Linux-AArch64", {"arm64-glibc", "z3"},
  "MacOSX-x86-64",  {"x64-osx", "z3"},
  "MacOSX-ARM64",   {"arm64-osx", "z3"},
  _, $Failed
];

z3ExecutableName[] := Last[z3PlatformInfo[]] /. {_?FailureQ -> "z3", x_ :> x};

(* paclet-private data directory for downloaded z3 installs *)
z3DataDirectory[] := Module[{dir},
  dir = FileNameJoin[{$UserBaseDirectory, "ApplicationData", "WolframInstitute", "Z3"}];
  If[! DirectoryQ[dir], Quiet@CreateDirectory[dir, CreateIntermediateDirectories -> True]];
  dir
];

(* validate a candidate path actually runs as z3 *)
z3WorksQ[path_String] := Quiet@Check[
  StringContainsQ[
    RunProcess[{path, "--version"}, "StandardOutput"],
    "Z3 version"
  ],
  False
];
z3WorksQ[_] := False;

(* search PATH and common system locations *)
findSystemZ3[] := Module[{name = z3ExecutableName[], pathHit, candidates},
  pathHit = Quiet@Check[
    If[z3WorksQ[name], name, $Failed],
    $Failed
  ];
  If[StringQ[pathHit], Return[pathHit]];
  candidates = Switch[$OperatingSystem,
    "Windows", {},
    "MacOSX", {"/opt/homebrew/bin/z3", "/usr/local/bin/z3", "/usr/bin/z3"},
    _, {"/usr/bin/z3", "/usr/local/bin/z3", "/snap/bin/z3"}
  ];
  SelectFirst[candidates, z3WorksQ, $Failed]
];

(* find a previously downloaded copy *)
findDownloadedZ3[] := Module[{name = z3ExecutableName[], hits},
  hits = FileNames[name, z3DataDirectory[], Infinity];
  SelectFirst[hits, z3WorksQ, $Failed]
];

(* resolve the github asset download url for a version + this platform *)
z3AssetURL[version_String] := Module[{sub = First[z3PlatformInfo[]], api, assets, match},
  api = "https://api.github.com/repos/Z3Prover/z3/releases/tags/z3-" <> version;
  assets = Quiet@Check[
    Lookup[Import[api, "RawJSON"], "assets", {}],
    {}
  ];
  match = SelectFirst[assets,
    StringContainsQ[Lookup[#, "name", ""], sub] && StringEndsQ[Lookup[#, "name", ""], ".zip"] &,
    $Failed
  ];
  If[AssociationQ[match],
    Lookup[match, "browser_download_url"],
    (* fallback: best-effort constructed url (works when suffix-free, e.g. win) *)
    "https://github.com/Z3Prover/z3/releases/download/z3-" <> version <>
      "/z3-" <> version <> "-" <> sub <> ".zip"
  ]
];

(* download + extract z3, returning the path to the executable *)
downloadZ3[version_String] := Module[
  {url, zip, extractDir, name = z3ExecutableName[], hits, exe},
  url = z3AssetURL[version];
  If[! StringQ[url], Return[$Failed]];

  printZ3[Style["Z3 was not found on your system.", Bold],
    "\nDownloading Z3 " <> version <> " for " <> $SystemID <> " (one-time setup)..."];

  extractDir = FileNameJoin[{z3DataDirectory[], "z3-" <> version <> "-" <> First[z3PlatformInfo[]]}];
  If[DirectoryQ[extractDir], Quiet@DeleteDirectory[extractDir, DeleteContents -> True]];

  zip = FileNameJoin[{z3DataDirectory[], "z3-download.zip"}];
  Quiet@DeleteFile[zip];

  If[FailureQ@downloadWithProgress[url, zip], Return[$Failed]];

  printZ3["Extracting..."];
  Quiet@Check[ExtractArchive[zip, extractDir], Return[$Failed]];
  Quiet@DeleteFile[zip];

  hits = FileNames[name, extractDir, Infinity];
  exe = SelectFirst[hits, z3WorksQ, $Failed];
  If[StringQ[exe],
    (* ensure executable bit on unix *)
    If[$OperatingSystem =!= "Windows", Quiet@Run["chmod +x " <> "\"" <> exe <> "\""]];
    printZ3[Style["Z3 " <> version <> " installed.", Bold]];
  ];
  exe
];

(* progress-reporting download that works headless or in a notebook *)
downloadWithProgress[url_String, dest_String] := Module[
  {task, total = 0, last = -1, pct, result},
  result = Quiet@Check[
    task = URLDownloadSubmit[url, dest,
      HandlerFunctions -> <|
        "TaskProgress" -> Function[ev,
          total = Lookup[ev, "ByteCountTotal", 0];
          If[total > 0,
            pct = Floor[100 Lookup[ev, "ByteCountDownloaded", 0] / total];
            If[pct >= last + 5,
              last = pct;
              printZ3Inline["  downloading: " <> ToString[pct] <> "%  (" <>
                ToString[Round[total/1024^2, 0.1]] <> " MB)"]
            ]
          ]
        ]|>,
      HandlerFunctionsKeys -> {"ByteCountDownloaded", "ByteCountTotal"}
    ];
    TaskWait[task];
    If[FileExistsQ[dest] && FileByteCount[dest] > 0, dest, $Failed],
    $Failed
  ];
  printZ3["  download complete."];
  result
];

(* printing helpers: Dynamic ProgressIndicator in a FE, plain Print headless *)
printZ3[args___] := If[TrueQ[$Notebooks], Print[Row[{args}]], Print[Row[{args}]]];
printZ3Inline[s_String] := Print[s];

(* session-memoized resolution *)
$Z3ResolvedExecutable = None;

z3Executable[] := z3Executable["Auto"];
z3Executable[force_] := Module[{exe},
  If[StringQ[$Z3ResolvedExecutable] && z3WorksQ[$Z3ResolvedExecutable] && force =!= "Force",
    Return[$Z3ResolvedExecutable]
  ];
  exe = Which[
    StringQ[$Z3UserExecutable] && z3WorksQ[$Z3UserExecutable], $Z3UserExecutable,
    True, Module[{s},
      s = findSystemZ3[];
      If[StringQ[s], s,
        s = findDownloadedZ3[];
        If[StringQ[s], s, downloadZ3[$Z3DefaultVersion]]
      ]
    ]
  ];
  If[StringQ[exe], $Z3ResolvedExecutable = exe];
  exe
];

$Z3UserExecutable = None;

(* ---- public-facing discovery functions ---- *)

Z3SetExecutable[path_String] := (
  If[z3WorksQ[path],
    $Z3UserExecutable = path; $Z3ResolvedExecutable = path; path,
    (Message[Z3SetExecutable::nz3, path]; $Failed)
  ]
);
Z3SetExecutable::nz3 = "`1` does not appear to be a working z3 executable.";

Z3InstallationLocation[] := Module[{exe = z3Executable[]},
  If[StringQ[exe], exe, $Failed]
];

Z3Install[] := Z3Install[$Z3DefaultVersion];
Z3Install[version_String] := Module[{exe = downloadZ3[version]},
  If[StringQ[exe], $Z3ResolvedExecutable = exe; exe, $Failed]
];

Z3Version[] := Module[{exe = z3Executable[], out},
  If[! StringQ[exe], Return[$Failed]];
  out = Quiet@RunProcess[{exe, "--version"}, "StandardOutput"];
  If[StringQ[out], StringTrim[out], $Failed]
];
