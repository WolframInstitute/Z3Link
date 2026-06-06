---
Template: Symbol
Name: Z3ToSMTLIB
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3ToSMTLIB
Keywords: [Z3, SMT, SMT-LIB, export, translation]
SeeAlso: [Z3RunSMTLIB, Z3Solve]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3ToSMTLIB]()[*constraints*, *vars* ∈ *domain*]</code> returns the SMT-LIB2 script that [Z3Solve]() would send to z3.

## Details & Options

- Useful for learning the SMT-LIB2 encoding or debugging a translation.
- The script ends with `(check-sat)` and `(get-model)`.

## Basic Examples

The SMT-LIB2 for a small integer problem:

```wl
Z3ToSMTLIB[x > 2 && x < 5, x \[Element] Integers]
```
<!-- => "(declare-const x Int)\n(assert (and (> x 2) (< x 5)))\n(check-sat)\n(get-model)" -->

## Scope

Typed handles encode their sorts, here an 8-bit bit-vector:

```wl
With[{a = Z3BitVec["a", 8]}, Z3ToSMTLIB[{a == Z3BitVecVal[255, 8]}, Automatic]]
```
<!-- => "(declare-const a (_ BitVec 8))\n(assert (= a (_ bv255 8)))\n(check-sat)\n(get-model)" -->
