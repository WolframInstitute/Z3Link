---
Template: Symbol
Name: Z3Int
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3Int
Keywords: [Z3, SMT, integer, handle, variable]
SeeAlso: [Z3Real, Z3Bool, Z3Const, Z3Solve]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3Int]()["*x*"]</code> is an integer-sorted Z3 variable handle, usable directly in arithmetic and logical expressions.

## Details & Options

- A handle is an ordinary Wolfram expression: build constraints with `+`, `*`, [Greater](), [And](), …, then pass them to [Z3Solve]() with no domain argument.
- The string is the variable name that appears in the model's keys.

## Basic Examples

Solve a small linear system built from integer handles:

```wl
With[{x = Z3Int["x"], y = Z3Int["y"]}, Z3Solve[{x + 2 y == 7, x > 2, y < 10}]]
```
<!-- => <|y -> 0, x -> 7|> -->
