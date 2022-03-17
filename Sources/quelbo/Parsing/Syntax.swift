//
//  Syntax.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/5/22.
//

import Parsing

/// A recursive ZIL syntax parser.
struct Syntax {
    var parser: AnyParser<Substring.UTF8View, Token>

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
                ].contains(element)
            }.map { String(Substring($0)) }
        }

        let atomOddities = OneOf {
            "0?".utf8.map { "isZero" }
            "1?".utf8.map { "isOne" }
        }

        let boolFalse = Parse {
            "<>".utf8
        }

        let comment = Parse {
            ";".utf8
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

        let string = Parse {
            "\"".utf8
            Many(into: "") { string, fragment in
                string.append(contentsOf: fragment)
            } element: {
                OneOf {
                    Prefix(1...) { $0 != .init(ascii: "\"") && $0 != .init(ascii: "\\") }
                        .map { String(Substring($0)).translateMultiline }
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
                "\"".utf8
            }
        }

        parser = Parse {
            Skip { Whitespace() }
            OneOf {
                boolFalse.map { Token.bool(false) }
                comment.map(Token.commented)
                form.map(Token.form)
                list.map(Token.list)
                string.map(Token.string)
                atomOddities.map(Token.atom)
                Int.parser().map(Token.decimal)
                atom.map(Token.atom)
            }
            Skip { Whitespace() }
        }
        .eraseToAnyParser()

        self.parser = parser
    }
}
