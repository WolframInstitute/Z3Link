---
Template: Symbol
Name: Z3BitVecVal
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3BitVecVal
Keywords: [Z3, SMT, bit-vector, literal, constant]
SeeAlso: [Z3BitVec, Z3Op]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3BitVecVal]()[*value*, *n*]</code> is an *n*-bit bit-vector literal for the integer *value*.

## Details & Options

- The width *n* must match the bit-vectors it is combined with.
- Values wrap modulo 2^*n*, matching fixed-width machine arithmetic.

## Basic Examples

A literal participates in bit-vector arithmetic:

```wl
With[{a = Z3BitVec["a", 8]}, Z3Solve[{a == Z3BitVecVal[10, 8] + Z3BitVecVal[5, 8]}]]
```
<!-- => <|a -> 15|> -->
