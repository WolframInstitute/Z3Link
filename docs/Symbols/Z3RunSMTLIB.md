---
Template: Symbol
Name: Z3RunSMTLIB
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3RunSMTLIB
Keywords: [Z3, SMT, SMT-LIB, script, run]
SeeAlso: [Z3ToSMTLIB, Z3Solve]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3RunSMTLIB]()["*smtlib2*"]</code> runs a raw SMT-LIB2 script in a fresh z3 session and returns its responses as text.

<code>[Z3RunSMTLIB]()[[File]()["*path*"]]</code> runs a script read from a file.

## Details & Options

- The script controls z3 directly: declare constants, assert, `(check-sat)`, `(get-value …)`, … .
- The return is the concatenated solver output.

## Basic Examples

Declare a constant, bound it, and read its value:

```wl
Z3RunSMTLIB["(declare-const a Int)(assert (> a 41))(assert (< a 43))(check-sat)(get-value (a))"]
```
<!-- => "sat\n((a 42))" -->
