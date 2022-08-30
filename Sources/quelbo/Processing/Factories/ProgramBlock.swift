//
//  ProgramBlock.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PROG](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1bkyn9b)
    /// function.
    class ProgramBlock: Factory {
        override class var zilNames: [String] {
            ["PROG"]
        }

        var blockProcessor: BlockProcessor!

        var activation: String? {
            ""
        }

        var repeating: Bool {
            false
        }

        override func processTokens() throws {
            self.blockProcessor = try BlockProcessor(
                tokens,
                with: &localVariables
            )
            
            blockProcessor.assert(
                activation: activation,
                repeating: repeating
            )
        }

        override func process() throws -> Symbol {
            let pro = blockProcessor!
            let repeating = repeating || pro.repeating
            let (type, confidence) = try pro.returnType()

            var activationDeclaration: String {
                guard
                    let activation = pro.activation,
                    !activation.isEmpty
                else { return "" }

                return "\(activation): "
            }

            var isRepeating: Bool {
                if repeating { return true }
                if activation == nil { return false }
                return pro.isRepeating
            }

            var quirk: Statement.Quirk? {
                activation == nil && pro.isRepeating ? .bindWithAgain : nil
            }

            return .statement(
                code: { _ in
                    switch (pro.isRepeating, activationDeclaration.isEmpty, quirk) {
                    case (true, false, _):
                        return """
                            \(activationDeclaration)\
                            while true {
                            \(pro.code.indented)
                            }
                            """
                    case (true, true, nil):
                        return """
                            \(pro.auxiliaryDefsWithDefaultValues)\
                            while true {
                            \(pro.code.indented)
                            }
                            """
                    case (true, true, .bindWithAgain):
                        return """
                            do {
                            \(pro.code.indented)
                            }
                            """
                    default:
                        return """
                            do {
                            \(pro.auxiliaryDefs.indented)\
                            \(pro.code.indented)
                            }
                            """
                    }
                },
                type: type,
                confidence: confidence,
                parameters: pro.paramSymbols,
                children: pro.symbols,
                activation: pro.activation,
                isRepeating: isRepeating,
                quirk: quirk,
                returnable: .void
            )
        }
    }
}
