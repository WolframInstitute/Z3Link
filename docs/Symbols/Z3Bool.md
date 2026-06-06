---
Template: Symbol
Name: Z3Bool
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3Bool
Keywords: [Z3, SMT, boolean, handle, variable]
SeeAlso: [Z3Int, Z3Real, Z3Const, Z3Op]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3Bool]()["*p*"]</code> is a boolean-sorted Z3 variable handle.

## Details & Options

- Combine boolean handles with [And](), [Or](), [Not](), [Implies](), or via [Z3Op]() for SMT operators.
- The model assigns each boolean handle [True]() or [False]().

## Basic Examples

A self-implication is satisfied by either truth value:

```wl
With[{p = Z3Bool["p"]}, Z3Solve[{Z3Op["=>", p, p]}]]
```
<!-- => <|p -> False|> -->
