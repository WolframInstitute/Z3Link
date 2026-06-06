---
Template: Symbol
Name: Z3Array
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3Array
Keywords: [Z3, SMT, array, handle, map]
SeeAlso: [Z3Select, Z3Store, Z3Const]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3Array]()["*m*", *domSort*, *rngSort*]</code> is an array-sorted Z3 variable handle: a total map from *domSort* to *rngSort*.

## Details & Options

- Read entries with [Z3Select]() and build updated arrays with [Z3Store]().
- The model for an array comes back as a callable pure function you index like the array.

## Basic Examples

Constrain two entries of an integer->integer array and read one back:

```wl
With[{m = Z3Array["m", "Int", "Int"]}, Z3Solve[{Z3Select[m, 2] == 9, Z3Select[m, 5] == 7}]["m"][2]]
```
<!-- => 9 -->
