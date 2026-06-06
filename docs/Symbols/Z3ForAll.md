---
Template: Symbol
Name: Z3ForAll
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3ForAll
Keywords: [Z3, SMT, quantifier, forall, universal]
SeeAlso: [Z3Exists, Z3ProvableQ, ForAll]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3ForAll]()[*vars* ∈ *domain*, *body*]</code> is a universally quantified formula - a message-free alternative to the built-in [ForAll]().

## Details & Options

- Use it inside [Z3ProvableQ]() / [Z3Solve]() to assert that *body* holds for every value of *vars*.
- Unlike [ForAll](), it does not emit the `ForAll::ivar` message for the `vars ∈ domain` form.

## Basic Examples

Every integer has a nonnegative square - provable:

```wl
Z3ProvableQ[Z3ForAll[x \[Element] Integers, x^2 >= 0], {}]
```
<!-- => True -->
