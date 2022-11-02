//
//  Statement+Payload.swift
//  Quelbo
//
//  Created by Chris Sessions on 10/11/22.
//

import CustomDump
import Foundation

extension Statement {
    /// <#Description#>
    struct Payload: Equatable {
        let activation: String?
        let auxiliaries: [Instance]
        let implicitReturns: Bool
        let parameters: [Instance]
        let predicate: Symbol?
        let repeating: Bool
        let symbols: [Symbol]

        init(
            activation: String? = nil,
            auxiliaries: [Instance] = [],
            implicitReturns: Bool = false,
            parameters: [Instance] = [],
            predicate: Symbol? = nil,
            repeating: Bool = false,
            symbols: [Symbol] = []
        ) {
            self.activation = activation
            self.auxiliaries = auxiliaries
            self.implicitReturns = implicitReturns
            self.parameters = parameters
            self.predicate = predicate
            self.repeating = repeating
            self.symbols = symbols
        }

        static var empty: Payload {
            .init()
        }

        var auxiliaryDefs: String {
            let auxVariables = auxiliaries + parameters.mutable
            guard !auxVariables.isEmpty else { return "" }

            return auxVariables
                .map(\.initialization)
                .joined(separator: "\n")
                .appending("\n")
        }

        var auxiliaryDefsWithDefaultValues: String {
            let auxVariables = auxiliaries + parameters.mutable
            guard !auxVariables.isEmpty else { return "" }

            return auxVariables
                .map(\.emptyValueAssignment)
                .joined(separator: "\n")
                .appending("\n")
        }

        var code: String {
            var lines = symbols.filter { !$0.code.isEmpty }
            guard let lastIndex = lines.lastIndex(where: { $0.type != .comment }) else {
                return lines.handles(.singleLineBreak)
            }
            let last = lines.remove(at: lastIndex)
            var codeLines = lines.map(\.code)
            var lastLine: String {
                if let returnType = returnType, last.type != returnType {
                    return last.handle
                }
                switch last {
                case .definition:
                    return last.handle
                case .literal, .instance:
                    return "return \(last.handle)"
                case .statement(let statement):
                    switch statement.returnHandling {
                    case .force:
                        return "return \(last.handle)"
                    case .implicit:
                        if statement.isReturnStatement ||
                           statement.type == .void ||
                           !implicitReturns
                        {
                            return last.handle
                        } else {
                            return "return \(last.handle)"
                        }
                    case .suppress:
                        return last.handle
                    }
                }
            }
            codeLines.insert(lastLine, at: lastIndex)
            return codeLines.joined(separator: "\n")
        }

        var codeHandlingRepeating: String {
            switch (isRepeating, repeatingBindChild?.activation) {
            case (true, nil), (true, ""): break
            case (true, _), (false, _): return code
            }

            var blockActivation: String {
                guard
                    let activationName = self.activation,
                    !activationName.isEmpty
                else { return "" }

                return "\(activationName): "
            }

            return """
                \(blockActivation)\
                while true {
                \(code.indented)
                }
                """
        }

        var discardableResult: String {
            switch returnType?.dataType {
            case .comment, .none, .void: return ""
            default: return "@discardableResult\n"
            }
        }

        var hasActivation: Bool {
            guard
                let activation = activation,
                !activation.isEmpty
            else { return false }

            return true
        }

        var repeatingBindChild: Statement? {
            for child in symbols {
                guard case .statement(let statement) = child else { continue }

                if statement.isBindingAndRepeatingStatement {
                    return statement
                }
            }
            return nil
        }

        var isRepeating: Bool {
            repeating || symbols.contains {
                guard case .statement(let statement) = $0 else { return false }

                return statement.isAgainStatement || statement.isBindingAndRepeatingStatement
            }
        }

        var paramDeclarations: String {
            parameters
                .map(\.declaration)
                .values(.commaSeparatedNoTrailingComma)
        }

        var returnDeclaration: String {
            guard let type = returnType else { return "" }
            switch type.dataType {
            case .comment, .void: return ""
            default: return " -> \(type)"
            }
        }

        var returnType: TypeInfo? {
            symbols.returnType()
        }
    }
}

// MARK: - Conformances

extension Statement.Payload: CustomDumpReflectable {
    var customDumpMirror: Mirror {
        .init(
            self,
            children: [
                "activation": self.activation as Any,
                "auxiliaries": self.auxiliaries,
                "symbols": self.symbols,
                "implicitReturns": self.implicitReturns,
                "parameters": self.parameters,
                "predicate": self.parameters,
                "repeating": self.repeating,
            ],
            displayStyle: .struct
        )
    }
}
