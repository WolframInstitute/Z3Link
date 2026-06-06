---
Template: Symbol
Name: Z3Op
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3Op
Keywords: [Z3, SMT, operator, escape hatch, smt-lib]
SeeAlso: [Z3BitVec, Z3Function, Z3Select]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3Op]()["*smtOp*", *args*…]</code> builds an arbitrary SMT-LIB operator term - the escape hatch for any z3 function with no dedicated Wolfram form.

## Details & Options

- *smtOp* is the SMT-LIB operator name, e.g. `"bvand"`, `"bvor"`, `"=>"`, `"distinct"`.
- The arguments are handles or terms of the sorts the operator expects.

## Basic Examples

Bitwise-and a bit-vector variable with a mask:

```wl
With[{a = Z3BitVec["a", 8]}, Z3Solve[{Z3Op["bvand", a, Z3BitVecVal[12, 8]] == Z3BitVecVal[4, 8]}]]
```
<!-- => <|a -> 4|> -->
