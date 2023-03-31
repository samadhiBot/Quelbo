//
//  ZilSyntax.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/5/22.
//

import Parsing

/// A recursive ZIL (Zork Implementation Language) syntax parser.
///
/// ZIL is a domain-specific language used to create interactive fiction games. This parser is used
/// for parsing ZIL source code into a syntax tree composed of ``Token`` values.
struct ZilSyntax {
    /// The main parser used for translating the ZIL source code into ``Token`` values.
    var parser: AnyParser<Substring.UTF8View, Token>

    /// Initializes a new instance of the `ZilSyntax` parser.
    init() {
        var parser: AnyParser<Substring.UTF8View, Token>!

        let unicode = Prefix(4) {
            (.init(ascii: "0") ... .init(ascii: "9")).contains($0)
            || (.init(ascii: "A") ... .init(ascii: "F")).contains($0)
            || (.init(ascii: "a") ... .init(ascii: "f")).contains($0)
        }.compactMap {
            UInt32(Substring($0), radix: 16)
                .flatMap(UnicodeScalar.init)
                .map(String.init)
        }

        let atom = Parse {
            Prefix(1...) { (element: Substring.UTF8View.Element) in
                ![
                    .init(ascii: " "),
                    .init(ascii: "\n"),
                    .init(ascii: "\r"),
                    .init(ascii: "\t"),
                    .init(ascii: "<"),
                    .init(ascii: ">"),
                    .init(ascii: "("),
                    .init(ascii: ")"),
                    .init(ascii: "["),
                    .init(ascii: "]"),
                ].contains(element)
            }.map { String(Substring($0)) }
        }

        let action = Parse {
            ",ACT?".utf8
            atom
        }

        let atomOddities = OneOf {
            "0?".utf8.map { "0?" }
            "1?".utf8.map { "1?" }
            "1ST?".utf8.map { "1ST?" }
        }

        let boolFalse = Parse {
            "<>".utf8
        }

        let character = Parse {
            "!\\".utf8
            atom
        }

        let comment = Parse {
            ";".utf8
            Lazy { parser! }
        }

        let eval = Parse {
            "%".utf8
            Lazy { parser! }
        }

        let form = Parse {
            "<".utf8
            Many {
                Lazy { parser! }
            } separator: {
                Whitespace()
            } terminator: {
                ">".utf8
            }
        }

        let global = Parse {
            ",".utf8
            Lazy { parser! }
        }

        let list = Parse {
            "(".utf8
            Many {
                Lazy { parser! }
            } separator: {
                Whitespace()
            } terminator: {
                ")".utf8
            }
        }

        let local = Parse {
            ".".utf8
            atom
        }

        let partsOfSpeech = Parse {
            ",PS?".utf8
            atom
        }

        let partsOfSpeechFirst = Parse {
            ",P1?".utf8
            atom
        }

        let property = Parse {
            ",P?".utf8
            atom
        }

        let quote = Parse {
            "'".utf8
            Lazy { parser! }
        }

        let segment = Parse {
            "!".utf8
            Lazy { parser! }
        }

        let string = Parse {
            #"""#.utf8
            Many(into: "") { string, fragment in
                string.append(contentsOf: fragment)
            } element: {
                OneOf {
                    Prefix(1...) {
                        $0 != .init(ascii: "\"") && $0 != .init(ascii: "\\")
                    }.map { String(Substring($0)).translateMultiline }
                    Parse {
                        "\\".utf8
                        OneOf {
                            "\"".utf8.map { "\"" }
                            "\\".utf8.map { "\\" }
                            "/".utf8.map { "/" }
                            "b".utf8.map { "\u{8}" }
                            "f".utf8.map { "\u{c}" }
                            "n".utf8.map { "\n" }
                            "r".utf8.map { "\r" }
                            "t".utf8.map { "\t" }
                            unicode
                        }
                    }
                }
            } terminator: {
                #"""#.utf8
            }
        }

        let type = Parse {
            "#".utf8
            atom
        }

        let vector = Parse {
            "[".utf8
            Many {
                Lazy { parser! }
            } separator: {
                Whitespace()
            } terminator: {
                "]".utf8
            }
        }

        let verb = Parse {
            ",V?".utf8
            atom
        }

        let word = Parse {
            ",W?".utf8
            atom
        }

        parser = Parse {
            Skip { Whitespace() }
            OneOf {
                OneOf {
                    boolFalse.map { Token.bool(false) }
                    type.map(Token.type)
                    character.map(Token.character)
                    comment.map(Token.commented)
                    eval.map(Token.eval)
                    form.map(Token.form)
                    partsOfSpeech.map(Token.partsOfSpeech)
                    partsOfSpeechFirst.map(Token.partsOfSpeechFirst)
                }
                OneOf {
                    property.map(Token.property)
                    verb.map(Token.verb)
                    word.map(Token.word)
                    action.map(Token.action)
                    global.map(Token.global)
                    list.map(Token.list)
                    local.map(Token.local)
                }
                OneOf {
                    quote.map(Token.quote)
                    segment.map(Token.segment)
                    vector.map(Token.vector)
                    string.map(Token.string)
                    atomOddities.map(Token.atom)
                    Int.parser().map(Token.decimal)
                    atom.map(Token.atom)
                }
            }
            Skip { Whitespace() }
        }
        .eraseToAnyParser()

        self.parser = parser
    }
}
