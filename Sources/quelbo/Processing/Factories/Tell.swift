//
//  Tell.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [TELL](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.104agfo)
    /// function.
    class Tell: Factory {
        override class var zilNames: [String] {
            ["TELL"]
        }

        enum PrintMode {
            case carriageReturn
            case character
            case description
            case normal
            case number
        }

        var printMode: PrintMode = .normal

        override func processTokens() throws {
            let printTokens: [Token] = tokens.compactMap { token in
                switch token {
                    case .atom("CR"), .atom("CRLF"):
                        printMode = .carriageReturn
                        return nil
                    case .atom("D"):
                        printMode = .description
                        return nil
                    case .atom("N"):
                        printMode = .number
                        return nil
                    case .atom("C"):
                        printMode = .character
                        return nil
                    case .atom("B"):
                        printMode = .normal
                        return nil
                    default: break
                }

                defer { printMode = .normal }

                switch printMode {
                    case .carriageReturn:
                        return .form([.atom("CRLF")])
                    case .character:
                        return .form([.atom("PRINTC"), token])
                    case .description:
                        return .form([.atom("PRINTD"), token])
                    case .normal:
                        return .form([.atom("PRINT"), token])
                    case .number:
                        return .form([.atom("PRINTN"), token])
                }
            }

            symbols = try symbolize(printTokens)
        }

        override func processSymbols() throws {
            try symbols.assert(.haveCount(.atLeast(1)))
        }

        override func process() throws -> Symbol {
            let prints = symbols

            return .statement(
                code: { _ in
                    prints.codeValues(.singleLineBreak)
                },
                type: .void,
                payload: .init(symbols: symbols)
            )
        }
    }
}
