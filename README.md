# Quelbo

> Quelbo: Transmute coconuts into gold

## Overview

Quelbo is a commandline tool that translates [ZIL](https://www.ifwiki.org/ZIL) (Zork Implementation Language) into Swift. Translation consists of two phases:

An initial phase [recursively parses](https://github.com/pointfreeco/swift-parsing) [ZIL source code](https://github.com/historicalsource) into enumerated Swift tokens. Quelbo prints these token representations to the console if you specify the `--print-tokens` option.

A second phase processes the tokens into Swift symbols that contain Swift translations of the ZIL functionality. Quelbo generates a Swift package containing the Swift translations if you specify a `--target` option; otherwise it prints the translations to the console. If translation fails, Quelbo prints all thrown errors to the console.

The [Fizmo](https://github.com/samadhiBot/Fizmo) library provides Swift implementations of any [Z-code built-in functions](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1j4nfs6) necessary for the processed code to compile and run.

Quelbo is part of a longer term experiment to create Swift versions of Zork and other ZIL titles, and replace the original ZIL parser with a CoreML-based natural language parser. Details can be found at the [Nitfol](https://github.com/samadhiBot/Nitfol) project.

## Usage

```
ॐ swift run quelbo -h

USAGE: quelbo <path> [-p] [-s] [-u] [--target <target>]

ARGUMENTS:
  <path>                  The path to a ZIL file or a directory containing one or more ZIL files.

OPTIONS:
  -p                      Print the ZIL tokens derived in the parsing phase.
  -s                      Print the processed game tokens when processing fails.
  -u                      Print the unprocessed game tokens when processing fails.
  -t, --target <target>   A target package to output results. When specified, and parsing and processing
                          are successful, Quelbo creates a package in `./Output/{target}`. Otherwise,
                          Quelbo prints the results to the console.
  -h, --help              Show help information.
  ```

### Sample output

```
ॐ swift run quelbo /path/to/historicalsource/zork1 -t Zork1

􀉂  Parsing Zil source
========================================================================
[-----------------------------------------------------------------] 100%

􀀷  Z-machine version
========================================================================
z3

􀥏  Processing Zil Tokens
========================================================================

􀣋  Processing tokens: 1547 of 1547 remaining (iteration 1)
========================================================================
[---------------------------------------------                    ] 69%

􀣋  Processing tokens: 217 of 1547 remaining (iteration 2)
========================================================================
[---------------------------------------------------------------- ] 99%

􀣋  Processing tokens: 2 of 1547 remaining (iteration 3)
========================================================================
[---------------------------------------------------------------- ] 99%

􀦆  Processing complete!
========================================================================

􀪏  Writing game translation to ./Output/Zork1
========================================================================

Done!
```
