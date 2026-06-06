---
Template: Symbol
Name: Z3Version
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3Version
Keywords: [Z3, version, executable, info]
SeeAlso: [Z3InstallationLocation, Z3Install]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3Version]()[]</code> returns the version string of the z3 executable in use.

## Details & Options

- Locates or downloads z3 if needed (as [Z3InstallationLocation]() does) before querying its version.

## Basic Examples

Report the z3 version in use:

```wl
Z3Version[]
```
<!-- => "Z3 version 4.15.4 - 64 bit" -->
