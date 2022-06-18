# Quelbo

> Quelbo: Transmute coconuts into gold

## Overview

Quelbo is a commandline tool that translates [ZIL](https://www.ifwiki.org/ZIL) (Zork Implementation Language) into Swift. Translation consists of two phases:

An initial phase [recursively parses](https://github.com/pointfreeco/swift-parsing) [ZIL source code](https://github.com/historicalsource) into enumerated Swift tokens. Quelbo prints these token representations to the console if you specify the `--print-tokens` option.

A second phase processes the tokens into Swift symbols that contain Swift translations of the ZIL functionality. Quelbo generates a Swift package containing the Swift translations if you specify a `--target` option; otherwise it prints the translations to the console. If translation fails, Quelbo prints all thrown errors to the console.

The [Fizmo](https://github.com/samadhiBot/Fizmo) library provides Swift implementations of any [Z-code built-in functions](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1j4nfs6) necessary for the processed code to compile and run.

Quelbo is part of a longer term experiment to create Swift versions of Zork and other ZIL titles, and replace the original ZIL parser with a CoreML-based natural language parser. Details can be found at the [Nitfol](https://github.com/samadhiBot/Nitfol) project.

## Usage

```bash
ॐ  swift run quelbo -h

USAGE: quelbo <path> [-p] [-s] [--target <target>]

ARGUMENTS:
  <path>                  The path to a ZIL file or a directory containing one or more ZIL files.

OPTIONS:
  -p                      Whether to print the ZIL tokens derived in the parsing phase.
  -s                      Whether to print the processed game tokens when processing fails.
  -t, --target <target>   A target directory path to write results. If unspecified, Quelbo prints results.
  -h, --help              Show help information.
```
