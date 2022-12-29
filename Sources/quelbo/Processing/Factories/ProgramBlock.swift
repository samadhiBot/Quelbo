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

        override func processSymbols() throws {
            if !blockProcessor.repeating {
                try blockProcessor.symbols.assert(
                    .haveSingleReturnType
                )
            }
        }

        override func process() throws -> Symbol {
            let activationDeclaration: String = {
                if let activation = blockProcessor.payload.activation, !activation.isEmpty {
                    return "\(activation): "
                }
                return ""
            }()
            let isBindingAndRepeating = blockProcessor.payload.activation == nil &&
                                        blockProcessor.payload.isRepeating
            let isRepeating: Bool = {
                if blockProcessor.payload.repeating { return true }
                if blockProcessor.payload.activation == nil { return false }
                return blockProcessor.payload.isRepeating
            }()

            return .statement(
                code: {
                    switch (
                        $0.payload.isRepeating,
                        activationDeclaration.isEmpty,
                        isBindingAndRepeating
                    ) {
                    case (true, false, true):
                        return """
                            \(activationDeclaration)\
                            while true {
                            \($0.payload.code.indented)
                            }
                            """
                    case (true, false, false):
                        return """
                            \($0.payload.auxiliaryDefsWithDefaultValues)\
                            \(activationDeclaration)\
                            while true {
                            \($0.payload.code.indented)
                            }
                            """
                    case (true, true, false):
                        return """
                            \($0.payload.auxiliaryDefsWithDefaultValues)\
                            while true {
                            \($0.payload.code.indented)
                            }
                            """
                    case (_, true, true):
                        return """
                            do {
                            \($0.payload.code.indented)
                            }
                            """
                    default:
                        return """
                            do {
                            \($0.payload.auxiliaryDefs.indented)\
                            \($0.payload.code.indented)
                            }
                            """
                    }
                },
                type: blockProcessor.payload.returnType ?? .unknown,
                payload: blockProcessor.payload,
                activation: blockProcessor.payload.activation,
                isBindingAndRepeatingStatement: isBindingAndRepeating,
                isRepeating: isRepeating,
                returnHandling: .suppressedPassthrough
            )
        }
    }
}
