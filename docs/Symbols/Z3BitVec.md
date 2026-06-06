---
Template: Symbol
Name: Z3BitVec
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3BitVec
Keywords: [Z3, SMT, bit-vector, handle, machine integer]
SeeAlso: [Z3BitVecVal, Z3Op, Z3Int]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3BitVec]()["*a*", *n*]</code> is an *n*-bit bit-vector Z3 variable handle.

## Details & Options

- Bit-vector arithmetic wraps modulo 2^*n*; the operators map to z3's `bvadd`, `bvmul`, … .
- Use [Z3BitVecVal]() for literals and [Z3Op]() for bitwise operators like `bvand`.

## Basic Examples

Add two 8-bit literals into a bit-vector variable:

```wl
With[{a = Z3BitVec["a", 8]}, Z3Solve[{a == Z3BitVecVal[10, 8] + Z3BitVecVal[5, 8]}]]
```
<!-- => <|a -> 15|> -->
