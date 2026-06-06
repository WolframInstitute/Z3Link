---
Template: Symbol
Name: Z3Real
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3Real
Keywords: [Z3, SMT, real, handle, variable]
SeeAlso: [Z3Int, Z3Bool, Z3Const, Z3Solve]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3Real]()["*x*"]</code> is a real-sorted Z3 variable handle.

## Details & Options

- Real handles give exact answers - rationals as [Rational](), algebraic numbers as [Root]() or [Sqrt]() objects.
- Build constraints from the handle and pass them to [Z3Solve]() with no domain argument.

## Basic Examples

A real handle pinned to a rational value:

```wl
With[{t = Z3Real["t"]}, Z3Solve[{t*3 == 2}]]
```
<!-- => <|t -> 2/3|> -->
