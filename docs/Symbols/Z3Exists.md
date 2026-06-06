---
Template: Symbol
Name: Z3Exists
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3Exists
Keywords: [Z3, SMT, quantifier, exists, existential]
SeeAlso: [Z3ForAll, Z3SatisfiableQ, Exists]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3Exists]()[*vars* ∈ *domain*, *body*]</code> is an existentially quantified formula - a message-free alternative to the built-in [Exists]().

## Details & Options

- Use it inside [Z3SatisfiableQ]() / [Z3Solve]() to assert that *body* holds for some value of *vars*.
- Unlike [Exists](), it does not emit the `Exists::ivar` message for the `vars ∈ domain` form.

## Basic Examples

Some integer squares to 9 - satisfiable:

```wl
Z3SatisfiableQ[Z3Exists[x \[Element] Integers, x^2 == 9], {}]
```
<!-- => True -->
