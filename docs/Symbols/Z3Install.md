---
Template: Symbol
Name: Z3Install
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3Install
Keywords: [Z3, install, download, executable]
SeeAlso: [Z3InstallationLocation, Z3SetExecutable, Z3Version]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3Install]()[]</code> downloads a private copy of z3 for this platform into the paclet data directory and returns its path.

<code>[Z3Install]()[*version*]</code> installs a specific z3 version.

## Details & Options

- The correct release for the platform (Windows / Linux / macOS, x86-64 / arm64) is fetched over HTTPS from the official z3 GitHub releases, verified by running it, and cached under [$UserBaseDirectory]().
- Normally unnecessary - [Z3Solve]() triggers an automatic download on first use; call it to force or pin a version.

## Basic Examples

Force a fresh download of z3 for this platform:

```wl
#| eval: false
Z3Install[]
```
