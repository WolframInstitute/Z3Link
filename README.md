# WolframInstitute/Z3Link

Wolfram Language bindings to the [Z3 theorem prover](https://github.com/Z3Prover/z3), an SMT (Satisfiability Modulo Theories) solver from Microsoft Research.

You enter problems as **native Wolfram expressions** or as **SMT-LIB2**, and results are translated back into **exact Wolfram values** - integers, rationals, algebraic numbers (`Root`/`Sqrt`), booleans, bit-vectors, arrays and functions.

- **Author:** Richard Assar
- **Publisher:** Wolfram Institute
- **License:** GNU GPL v3 or later (the paclet). Z3 itself is MIT-licensed by Microsoft.
- **Paclet Repository:** [WolframInstitute/Z3Link](https://www.wolframcloud.com/obj/resourcesystem/published/PacletRepository/resources/WolframInstitute/Z3Link/)

---

## Requirements

- Wolfram Language 13.0+ (developed and tested on 14.3).
- The `z3` command-line solver. **You do not need to install it yourself** - if no system z3 is found, the paclet downloads a private copy automatically on first use (see below).

---

## Installation

### From the Paclet Repository

The paclet is published in the [Wolfram Paclet Repository](https://www.wolframcloud.com/obj/resourcesystem/published/PacletRepository/resources/WolframInstitute/Z3Link/):

```wl
PacletInstall["WolframInstitute/Z3Link"]
Needs["WolframInstitute`Z3Link`"]
```

### From the built paclet archive

```wl
PacletInstall["WolframInstitute__Z3Link-1.0.0.paclet"]
Needs["WolframInstitute`Z3Link`"]
```

### From source (development)

```wl
PacletDirectoryLoad["/path/to/z3_paclet/Z3Link"]
Needs["WolframInstitute`Z3Link`"]
```

### Building the paclet and docs from source

From the repository root:

```bash
wolframscript -file build.wls             # render docs/*.md and pack WolframInstitute__Z3Link-*.paclet
wolframscript -file tools/run_tests.wls   # install the built paclet and run the test suite
```

`build.wls` renders the markdown in `docs/` into the paclet's documentation notebooks with [MarkdownToNotebook](https://github.com/sw1sh/MarkdownToNotebook) (which needs Wolfram Cloud access), then packs the `.paclet`.

---

## Documentation

The paclet ships full documentation: a guide page, reference pages for all 38 symbols, and two tutorials (a feature tour and a constraints walkthrough). After installing, browse it in the Wolfram Documentation Center, or read it on the [Paclet Repository page](https://www.wolframcloud.com/obj/resourcesystem/published/PacletRepository/resources/WolframInstitute/Z3Link/).

---

## How z3 is located (and auto-downloaded)

On first use the paclet resolves a working `z3` executable in this order:

1. An executable set explicitly via `Z3SetExecutable["..."]`.
2. The system `PATH` (and common locations such as `/usr/bin`, `/usr/local/bin`, `/opt/homebrew/bin`).
3. A copy previously downloaded by the paclet.
4. **Automatic download** - the correct Z3 release for your platform (Windows / Linux / macOS, x86-64 / arm64) is fetched over HTTPS from the official GitHub releases, then verified by actually running it (`z3 --version`), and cached under `$UserBaseDirectory`. This happens **on every platform** as a guaranteed fallback, with a one-time progress message. On Unix the executable bit is set after extraction; on macOS the quarantine attribute is cleared and the binary + `libz3.dylib` are ad-hoc code-signed (`codesign -s -`) so Apple Silicon will run them. If anything fails, a specific diagnostic message points you to `Z3SetExecutable["..."]`.

```wl
Z3InstallationLocation[]   (* resolve (and download if needed) the z3 path *)
Z3Version[]                (* version string in use *)
Z3Install[]                (* force a fresh download of the pinned version *)
Z3SetExecutable["/usr/bin/z3"]  (* pin a specific binary *)
```

The download is cross-platform: it detects `$SystemID` and selects the matching release asset, resolving the exact asset name dynamically from the GitHub API (with a constructed-URL fallback).

---

## Quick start

```wl
Needs["WolframInstitute`Z3Link`"]

Z3Solve[x > 2 && y < 10 && x + 2 y == 7, {x, y} \[Element] Integers]
(*  <| y -> 0, x -> 7 |>  *)
```

`Z3Solve` returns an association `variable -> value` when satisfiable, the symbol `Unsatisfiable` when not, and `Indeterminate` when z3 cannot decide.

---

## Two input styles

### Style 1 - native expressions + domain (like `Solve`)

Variables are plain symbols; the second argument declares their domain (`Integers`, `Reals`, `Booleans`).

```wl
Z3Solve[a || b && ! c, {a, b, c} \[Element] Booleans]
```

### Style 2 - typed handles (like z3py)

```wl
x = Z3Int["x"]; y = Z3Int["y"];
Z3Solve[{x + 2 y == 7, x > 2, y < 10}]
```

Handle constructors: `Z3Int`, `Z3Real`, `Z3Bool`, `Z3BitVec[name, w]`, `Z3Array[name, dom, rng]`, `Z3Const[name, sort]`, `Z3Function[name, {argSorts}, ret]`, plus the literal `Z3BitVecVal[v, w]` and the escape hatch `Z3Op["smtOp", args...]`.

---

## Exact results

```wl
Z3Solve[3 r == 1, r \[Element] Reals]       (*  <| r -> 1/3 |>             *)
Z3Solve[s^2 == 2 && s > 0, s \[Element] Reals]  (*  <| s -> Sqrt[2] |>     *)
```

Rationals come back exact; nonlinear-real solutions come back as exact algebraic `Root` objects. Use `"Numeric" -> True` for machine numbers.

---

## Theories supported

| Theory | Example |
|---|---|
| Linear/nonlinear integers & reals | `Z3Solve[x^2 + y^2 == 25 && x > 0 && y > 0, {x,y} \[Element] Integers]` |
| Booleans | `Z3Solve[Xor[p, q] && p, {p,q} \[Element] Booleans]` |
| Bit-vectors | `a = Z3BitVec["a",8]; Z3Solve[{a == Z3BitVecVal[10,8] + Z3BitVecVal[5,8]}]` |
| Arrays | `m = Z3Array["m","Int","Int"]; Z3Solve[{Z3Select[m,2] == 9}]` |
| Uninterpreted functions | `f = Z3Function["f",{"Int"},"Int"]; Z3Solve[{f[0]==5, f[1]==7}]` |
| Quantifiers | `Z3ProvableQ[Z3ForAll[x \[Element] Integers, x^2 >= 0], {}]` |

Arithmetic helpers translated to SMT: `Plus Times Power Subtract Divide Mod Quotient Abs Min Max Floor Ceiling Boole`. Logic: `And Or Not Implies Xor Equivalent Nand Nor If`. Relations: `Equal Unequal Less Greater LessEqual GreaterEqual` (including chained inequalities). Array terms: `Z3Select`, `Z3Store`.

Bit-vector arithmetic operators on handles map to `bvadd`/`bvmul`/`bvsub`; for every other SMT operation use `Z3Op["bvand", a, b]`, etc.

---

## SMT-LIB interoperability

```wl
Z3RunSMTLIB["(declare-const a Int)(assert (> a 41))(assert (< a 43))(check-sat)(get-value (a))"]
Z3RunSMTLIB[File["problem.smt2"]]
Z3ToSMTLIB[x > 2 && y < 10, {x, y} \[Element] Integers]   (* inspect the generated SMT-LIB2 *)
```

---

## Incremental solving

```wl
s = Z3CreateSolver[];
Z3Assert[s, x > 0 && x < 10, x \[Element] Integers];
Z3CheckSat[s]            (* "sat" *)
Z3Model[s]
Z3Push[s];
Z3Assert[s, x > 8, x \[Element] Integers];
Z3CheckSat[s]
Z3Pop[s];
Z3Eval[s, x + 1]
Z3UnsatCore[s]           (* conflicting assertions after an unsat check *)
Z3Statistics[s]          (* solver statistics association *)
```

`Z3CheckSat` returns `"sat"`, `"unsat"`, or `"unknown"`.

---

## Optimization

```wl
Z3Optimize[x -> Maximize, x > 0 && x < 100, x \[Element] Integers]
(* <| "Status" -> "sat", "Objective" -> 99, "Model" -> <| x -> 99 |> |> *)

o = Z3CreateSolver["Optimize"];
Z3Assert[o, x + y == 10 && x >= 0 && y >= 0, {x, y} \[Element] Integers];
Z3Maximize[o, x*x + y*y];
Z3CheckSat[o]; Z3Model[o]
```

---

## Options

`Z3Solve` and `Z3Optimize`:

- `"Timeout" -> ms` - per-solve timeout (milliseconds).
- `"Numeric" -> True` - machine-precision numbers instead of exact.
- `"Options" -> {"name" -> value, ...}` - arbitrary z3 options.

`Z3SetOption[solver, "name" -> value]` sets any z3 option on a live solver; `Z3SetOption["name" -> value]` sets a global default applied to every subsequent solve.

## Full coverage / advanced features

The wrapped functions cover the common workflow, and three escape hatches reach **everything else z3 can do** - no feature is locked out:

- **Any z3 option** -> `Z3SetOption[...]` or the `"Options"` option (e.g. random seeds, `:smt.arith.solver`, `:sat.restart`, model/proof production).
- **Any SMT operator** -> `Z3Op["op", args...]` builds an arbitrary SMT-LIB term (e.g. `Z3Op["bvashr", a, b]`, `Z3Op["str.++", s, t]`, `Z3Op["re.union", r1, r2]`).
- **Any z3 command** -> `Z3RunSMTLIB["..."]` runs raw SMT-LIB2, which exposes tactics (`(check-sat-using (then simplify smt))`), proofs (`(get-proof)`), soft constraints / MaxSAT (`(assert-soft ...)`), interpolation, datatypes, `(simplify ...)`, and the full optimization command set.

So the native and handle APIs are conveniences over the same surface; the raw path guarantees parity with the `z3` binary itself.

---

## Function reference

| Function | Purpose |
|---|---|
| `Z3Solve[constraints, domain]` | one-shot solve -> model / `Unsatisfiable` / `Indeterminate` |
| `Z3Solve["smtlib2..."]` | run a raw SMT-LIB2 script |
| `Z3SatisfiableQ`, `Z3ProvableQ` | satisfiability / validity predicates |
| `Z3ToSMTLIB`, `Z3RunSMTLIB` | SMT-LIB2 export / run |
| `Z3CreateSolver[]`, `Z3CreateSolver["Optimize"]` | incremental solver / optimizer object |
| `Z3Assert`, `Z3CheckSat`, `Z3Model`, `Z3Eval` | incremental API |
| `Z3Push`, `Z3Pop`, `Z3Reset` | assertion-stack control |
| `Z3UnsatCore`, `Z3Statistics` | core extraction / statistics |
| `Z3Maximize`, `Z3Minimize`, `Z3Optimize` | optimization |
| `Z3SetOption` | set z3 options |
| `Z3Int`, `Z3Real`, `Z3Bool`, `Z3BitVec`, `Z3Array`, `Z3Const`, `Z3Function` | typed handles |
| `Z3BitVecVal`, `Z3Op`, `Z3Select`, `Z3Store`, `Z3ForAll`, `Z3Exists` | term builders |
| `Z3InstallationLocation`, `Z3Install`, `Z3Version`, `Z3SetExecutable` | z3 discovery / install |

---

## How it works (architecture)

The paclet drives a persistent `z3 -in` process over SMT-LIB2, framed by an echoed sentinel so each response is read back reliably. Native Wolfram expressions are translated to SMT-LIB2 by a recursive translator; z3's S-expression responses are parsed and translated back to exact Wolfram values (rationals, `Root` algebraics, bit-vector integers, callable functions for arrays/UFs).

```
Z3Solve / handles / SMT-LIB
        |
   translate  (Wolfram expr  <->  SMT-LIB2 text)
        |
   z3 process  (stdin/stdout, persistent, incremental)
```

Kernel sources:

- `Kernel/Discovery.wl` - locate / auto-download z3 per platform.
- `Kernel/Process.wl` - persistent process + sentinel framing.
- `Kernel/SExpr.wl` - S-expression reader.
- `Kernel/InputTranslate.wl` - Wolfram -> SMT-LIB2.
- `Kernel/OutputTranslate.wl` - z3 results -> exact Wolfram values.
- `Kernel/Handles.wl` - typed handles + operator overloading.
- `Kernel/API.wl` - public functions.

---

## Cross-platform notes

The bindings are pure Wolfram + the `z3` executable, so they run anywhere a Wolfram kernel and z3 run: **Windows, Linux, macOS, and WSL**. The kernel and z3 must be the same OS (e.g. a Windows kernel uses a Windows z3); the auto-downloader always fetches the matching build, so this is handled for you. The paclet detects `$SystemID` (`Windows-x86-64`, `Windows-ARM64`, `Linux-x86-64`, `Linux-ARM64`, `MacOSX-x86-64`, `MacOSX-ARM64`) and behaves accordingly. The exact per-platform download URLs are pinned to verified release-asset names (so resolution doesn't depend on the GitHub API), and on macOS the downloaded binary is automatically un-quarantined and ad-hoc code-signed so Apple Silicon will run it.

> Note on testing: this paclet's automated suite has been exercised on Windows (x86-64). The Linux and macOS code paths - system discovery, the per-platform download, and the macOS permission/signing steps - are written from verified release-asset URLs and documented platform behavior, but have not been executed on those OSes here. On any failure they emit a specific, actionable message (pointing to `Z3SetExecutable[...]`) rather than failing silently.

---

## Running the tests

```bash
wolframscript -file tools/run_tests.wls
```

This installs the built `.paclet` and runs `Z3Link/Tests/Tests.wlt` (translation, all theories, incremental solving, optimization, SMT-LIB interop).

---

## License

This paclet is free software, licensed under the **GNU General Public License v3.0 or later** - see [LICENSE](LICENSE). You may redistribute and/or modify it under those terms; it comes with no warranty.

## Credits

Z3 is developed by Microsoft Research (https://github.com/Z3Prover/z3) and is MIT-licensed. This paclet is an independent set of bindings.
