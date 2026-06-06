---
Template: Symbol
Name: Z3Function
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3Function
Keywords: [Z3, SMT, uninterpreted function, handle]
SeeAlso: [Z3Const, Z3Op, Z3Solve]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3Function]()["*f*", {*argSorts*}, *resultSort*]</code> declares an uninterpreted function handle, applied like an ordinary function `f[arg]`.

## Details & Options

- An uninterpreted function has no definition beyond the constraints you place on its values.
- Its model comes back as a callable pure function you can apply to inputs.

## Basic Examples

Constrain a function at two points and read one value from the model:

```wl
With[{f = Z3Function["f", {"Int"}, "Int"]}, Z3Solve[{f[0] == 5, f[1] == 7}]["f"][1]]
```
<!-- => 7 -->
