---
Template: Symbol
Name: Z3Const
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3Const
Keywords: [Z3, SMT, constant, handle, sort]
SeeAlso: [Z3Int, Z3Real, Z3Bool, Z3Function]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3Const]()["*name*", *sort*]</code> is a Z3 constant handle of the given *sort* (a sort name such as `"Int"`, `"Real"`, `"Bool"`).

## Details & Options

- [Z3Int](), [Z3Real](), and [Z3Bool]() are shorthands for the common sorts; [Z3Const]() handles any named sort.
- Pass constraints built from the handle to [Z3Solve]() with no domain argument.

## Basic Examples

An integer-sorted constant pinned between two bounds:

```wl
With[{c = Z3Const["c", "Int"]}, Z3Solve[{c > 100, c < 103}]]
```
<!-- => <|c -> 101|> -->
