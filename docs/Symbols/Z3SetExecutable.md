---
Template: Symbol
Name: Z3SetExecutable
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3SetExecutable
Keywords: [Z3, executable, configure, path]
SeeAlso: [Z3InstallationLocation, Z3Install, Z3Version]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3SetExecutable]()[*path*]</code> forces the paclet to use the z3 executable at *path*.

## Details & Options

- Overrides all automatic discovery; pass a full path to a z3 binary you manage yourself.
- Useful to pin a system z3 instead of the auto-downloaded copy.

## Basic Examples

Pin a specific z3 binary:

```wl
#| eval: false
Z3SetExecutable["/usr/local/bin/z3"]
```
