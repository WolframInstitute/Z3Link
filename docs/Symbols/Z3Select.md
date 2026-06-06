---
Template: Symbol
Name: Z3Select
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3Select
Keywords: [Z3, SMT, array, select, read]
SeeAlso: [Z3Store, Z3Array]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3Select]()[*array*, *index*]</code> is the SMT `(select array index)` term - the value *array* holds at *index*.

## Details & Options

- *array* may be a [Z3Array]() handle or a [Z3Store]() term.
- Constrain selects to fix array entries, then read the model as a function.

## Basic Examples

Constrain two entries and read one back from the model:

```wl
With[{m = Z3Array["m", "Int", "Int"]}, Z3Solve[{Z3Select[m, 2] == 9, Z3Select[m, 5] == 7}]["m"][2]]
```
<!-- => 9 -->
