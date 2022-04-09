# Quelbo

> Quelbo: Transmute coconuts into gold

Quelbo is a commandline tool that translates [ZIL](https://www.ifwiki.org/ZIL) (Zork Implementation Language) into Swift. Translation consists of two phases:

An initial phase uses the Point-Free [swift-parsing](https://github.com/pointfreeco/swift-parsing) library to recursively parse ZIL into a set of enumerated Swift tokens.

A second phase processes the tokens into Swift code. The [Fizmo](https://github.com/samadhiBot/Fizmo) library provides Swift implementations of any [Z-code built-in functions](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1j4nfs6) necessary for the processed code to compile and run.

Quelbo is part of a longer term experiment to create Swift versions of Zork and other ZIL titles, and replace the original ZIL parser with a CoreML-based natural language parser. Details can be found at the [Nitfol](https://github.com/samadhiBot/Nitfol) project.

## Usage

```bash
ॐ  swift run quelbo -h

USAGE: quelbo <path> [--print-tokens] [--output <output>]

ARGUMENTS:
  <path>                  The path to a ZIL file or a directory containing one or more ZIL files.

OPTIONS:
  -p, --print-tokens      Whether to print the ZIL tokens derived in the parsing phase.
  -o, --output <output>   The path to an output directory. If unspecified, Quelbo prints results.
  -h, --help              Show help information.
```

## Progress

Currently Quelbo can parse and naïvely process the ZIL source files at [historicalsource/zork1](https://github.com/historicalsource/zork1). While the translated Swift code does not yet compile, work is ongoing in [Quelbo](https://github.com/samadhiBot/Quelbo) and [Fizmo](https://github.com/samadhiBot/Fizmo) to fine tune ZIL->Swift processing, and provide Swift implementations of [Z-code built-in functions](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1j4nfs6) as necessary.
