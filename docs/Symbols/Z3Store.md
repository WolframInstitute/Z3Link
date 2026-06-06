---
Template: Symbol
Name: Z3Store
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3Store
Keywords: [Z3, SMT, array, store, update]
SeeAlso: [Z3Select, Z3Array]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3Store]()[*array*, *index*, *value*]</code> is the SMT `(store array index value)` term - *array* updated so that *index* maps to *value*.

## Details & Options

- The result is a new array term; the original *array* is unchanged.
- Compose with [Z3Select]() to read entries of an updated array.

## Basic Examples

Inspect the SMT-LIB term for a select of a store:

```wl
Z3ToSMTLIB[Z3Select[Z3Store[Z3Array["m", "Int", "Int"], 1, 42], 1] == 99]
```
<!-- => "(declare-const m (Array Int Int))\n(assert (= (select (store m 1 42) 1) 99))\n(check-sat)\n(get-model)" -->
