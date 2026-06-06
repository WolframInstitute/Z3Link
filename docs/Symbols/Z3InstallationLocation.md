---
Template: Symbol
Name: Z3InstallationLocation
Context: WolframInstitute`Z3Link`
Paclet: WolframInstitute/Z3Link
URI: WolframInstitute/Z3Link/ref/Z3InstallationLocation
Keywords: [Z3, installation, executable, discovery, path]
SeeAlso: [Z3Version, Z3Install, Z3SetExecutable]
RelatedGuides: [Z3Link]
---

## Usage

<code>[Z3InstallationLocation]()[]</code> returns the path to the z3 executable that will be used, locating it on the system or downloading a private copy if none is found.

## Details & Options

- Resolution order: an executable pinned with [Z3SetExecutable](), the system `PATH` and common install locations, a previously downloaded copy, then an automatic download.
- The first call may print a one-time download progress message.

## Basic Examples

Resolve the z3 executable in use:

```wl
Z3InstallationLocation[]
```
<!-- => "z3" -->
