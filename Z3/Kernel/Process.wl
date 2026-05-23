(* ::Package:: *)

(* Persistent z3 -in session. Commands are written to stdin; end-of-response is detected
   by echoing a unique sentinel and reading stdout lines until it appears.
   Errors arrive on stdout as (error "..."), which the caller can detect. *)

$Z3SessionCounter = 0;
$Z3Sessions = <||>;            (* id -> <|"Process"->proc, "Counter"->n, ...|> *)
$Z3DefaultSession = None;
$Z3ReadTimeout = 300;          (* seconds; backstop so a hung read cannot wedge the kernel *)

z3SessionStart[] := Module[{exe, proc, id},
  exe = z3Executable[];
  If[! StringQ[exe], Message[Z3Solve::noz3]; Return[$Failed]];
  proc = Quiet@Check[StartProcess[{exe, "-in"}], $Failed];
  If[FailureQ[proc], Message[Z3Solve::noz3]; Return[$Failed]];
  id = ++$Z3SessionCounter;
  $Z3Sessions[id] = <|"Process" -> proc, "Sentinel" -> 0|>;
  (* harmless baseline options *)
  z3RawSend[id, "(set-option :print-success false)\n(set-option :produce-models true)"];
  id
];

Z3Solve::noz3 = "Could not locate or download a working z3 executable.";

z3SessionProcess[id_] := Lookup[$Z3Sessions, id, <||>]["Process"];

z3SessionAliveQ[id_] := Module[{proc = z3SessionProcess[id]},
  ProcessObjectQ[proc] && ProcessStatus[proc] === "Running"
];

(* low-level: send commands, return raw stdout response text up to the sentinel *)
z3RawSend[id_, cmds_String] := Module[{proc, sentinel, lines, line, done},
  proc = z3SessionProcess[id];
  If[! ProcessObjectQ[proc], Return[$Failed]];
  $Z3Sessions[id, "Sentinel"] = $Z3Sessions[id, "Sentinel"] + 1;
  sentinel = "@@Z3DONE_" <> ToString[$Z3Sessions[id, "Sentinel"]] <> "@@";
  WriteLine[proc, cmds];
  WriteLine[proc, "(echo \"" <> sentinel <> "\")"];
  lines = {};
  done = TimeConstrained[
    (While[True,
       line = ReadLine[proc];
       If[line === EndOfFile, Return["EOF", Module]];
       If[StringTrim[line] === sentinel, Break[]];
       lines = Append[lines, line];
     ]; "OK"),
    $Z3ReadTimeout,
    "TIMEOUT"
  ];
  Which[
    done === "EOF", $Failed,
    done === "TIMEOUT", (Message[Z3CheckSat::timeout]; $Failed),
    True, StringRiffle[lines, "\n"]
  ]
];

Z3CheckSat::timeout = "z3 did not respond within the read timeout; the session may be wedged.";

(* send commands and parse stdout into top-level s-expr forms; raise on (error ...) *)
z3Send[id_, cmds_String] := Module[{raw, forms},
  raw = z3RawSend[id, cmds];
  If[! StringQ[raw], Return[$Failed]];
  forms = parseSExprAll[raw];
  checkZ3Errors[forms];
  forms
];

checkZ3Errors[forms_List] := Module[{errs},
  errs = Cases[forms, {"error", Z3String[msg_]} :> msg];
  If[errs =!= {}, Message[Z3Solve::z3err, First[errs]]];
  errs
];
Z3Solve::z3err = "z3 reported an error: `1`";

z3SessionEnd[id_] := Module[{proc = z3SessionProcess[id]},
  If[ProcessObjectQ[proc],
    Quiet[WriteLine[proc, "(exit)"]; KillProcess[proc]]
  ];
  KeyDropFrom[$Z3Sessions, id];
  If[$Z3DefaultSession === id, $Z3DefaultSession = None];
];

(* shared session for one-shot calls *)
z3DefaultSession[] := Module[{},
  If[$Z3DefaultSession === None || ! z3SessionAliveQ[$Z3DefaultSession],
    $Z3DefaultSession = z3SessionStart[]
  ];
  $Z3DefaultSession
];
