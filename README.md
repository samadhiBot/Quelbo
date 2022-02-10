# Quelbo

> Quelbo: Transmute coconuts into gold

The goal of Quelbo is to translate [ZIL](https://www.ifwiki.org/ZIL) (Zork Implementation Language) into Swift. An initial phase uses Point-Free's [swift-parsing](https://github.com/pointfreeco/swift-parsing) library to parse ZIL into a set of Swift enumerated tokens. Then a processing phase translates these tokens into Swift code.

Quelbo is part of a larger effort to create a Swift version of Zork with a CoreML-based natural language parser in place of Infocom's original parser. Please see the [Nitfol](https://github.com/samadhiBot/Nitfol) project for further details.

For the intrepid adventurer who wants to translate ZIL into a language other than Swift, it should be straightforward to fork Quelbo and alter the processing phase to output your language of choice.

## Usage

```bash
swift run quelbo path/to/zil/file(s)
```

## Progress

Currently Quelbo can parse the ZIL source files at https://github.com/historicalsource/zork1 without errors into an incomplete set of Swift tokens. Processing work is in progress, and parsing will be enhanced as needed to support it.
