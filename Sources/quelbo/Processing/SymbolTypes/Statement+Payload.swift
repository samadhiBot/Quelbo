//
//  Statement+Payload.swift
//  Quelbo
//
//  Created by Chris Sessions on 10/11/22.
//

import CustomDump
import Fizmo
import Foundation

extension Statement {
    /// <#Description#>
    class Payload {
        let activation: String?
        let auxiliaries: [Instance]
        let evaluation: Literal?
        let flags: [Fizmo.Table.Flag]
        let parameters: [Instance]
        let predicate: Symbol?
        let repeating: Bool
        let symbols: [Symbol]
        private(set) var returnHandling: Symbol.ReturnHandling

        init(
            activation: String? = nil,
            auxiliaries: [Instance] = [],
            evaluation: Literal? = nil,
            flags: [Fizmo.Table.Flag] = [],
            parameters: [Instance] = [],
            predicate: Symbol? = nil,
            repeating: Bool = false,
            returnHandling: Symbol.ReturnHandling = .implicit,
            symbols: [Symbol] = []
        ) {
            self.activation = activation
            self.auxiliaries = auxiliaries
            self.evaluation = evaluation
            self.flags = flags
            self.parameters = parameters
            self.predicate = predicate
            self.repeating = repeating
            self.returnHandling = returnHandling
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
            var lines = symbols
            guard let lastIndex = lines.lastIndex(where: { $0.type != .comment }) else {
                return lines.handles(.singleLineBreak)
            }

            let last = lines.remove(at: lastIndex)
            var codeLines = lines.map(\.code)
            let lastLine = {
                let handle = last.handle
                guard
                    last.returnHandling > .implicit,
                    last.type.hasReturnValue,
                    !handle.hasPrefix("return")
                else {
                    return last.handle
                }
                return "return \(last.handle)"
            }()
            codeLines.insert(lastLine, at: lastIndex)

            return codeLines
                .filter { !$0.isEmpty }
                .values(.singleLineBreak)
        }

        var codeHandlingRepeating: String {
            switch (isRepeating, repeatingBindChild?.activation) {
            case (true, nil), (true, ""):
                break
            case (true, _), (false, _):
                return code
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
            case .comment, .none, .void:
                return ""
            default:
                return "@discardableResult\n"
            }
        }

        var hasActivation: Bool {
            guard
                let activation = activation,
                !activation.isEmpty
            else { return false }

            return true
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

        var repeatingBindChild: Statement? {
            for child in symbols {
                guard case .statement(let statement) = child else { continue }

                if statement.isBindingAndRepeatingStatement {
                    return statement
                }
            }
            return nil
        }

        var returnDeclaration: String {
            guard let returnType else { return "" }

            switch returnType.dataType {
            case .comment, .void:
                return ""
            default:
                return " -> \(returnType)"
            }
        }

        var returnType: TypeInfo? {
            symbols
                .returningSymbols
                .returnType
        }
    }
}

// MARK: - Special assertion handlers

extension Statement.Payload {
    func assertHasReturnHandling(
        _ assertedHandling: Symbol.ReturnHandling,
        from parentHandling: Symbol.ReturnHandling
    ) throws {
        switch (assertedHandling, returnHandling) {
        case (.forced, .implicit):
            self.returnHandling = .forced
            try symbols.assert(
                .haveReturnHandling(.forced)
            )
        case (.forced, .passthrough):
            self.returnHandling = .forcedPassthrough
            try symbols.assert(
                .haveSingleReturnType
            )
        case (.forced, .forcedPassthrough):
            try symbols.assert(
                .haveSingleReturnType
            )
        case (.forced, .suppressedPassthrough):
            if parentHandling != .suppressedPassthrough {
                try symbols.assert(
                    .haveSingleReturnType
                )
            }
//        case (.suppressed, .forced):
//            throw Symbol.AssertionError.hasReturnHandlingAssertionFailed(
//                for: "Payload",
//                asserted: assertedHandling,
//                actual: returnHandling
//            )
        default:
            throw Symbol.AssertionError.hasReturnHandlingAssertionFailed(
                for: "Payload",
                asserted: assertedHandling,
                actual: returnHandling
            )

//            assertionFailure(
//                "Unexpected assertHasReturnHandling \(assertedHandling) -> \(returnHandling)"
//            )
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
                "parameters": self.parameters,
                "predicate": self.parameters,
                "repeating": self.repeating,
                "returnHandling": self.returnHandling,
            ],
            displayStyle: .struct
        )
    }
}

extension Statement.Payload: Equatable {
    static func == (lhs: Statement.Payload, rhs: Statement.Payload) -> Bool {
        lhs.activation == rhs.activation &&
        lhs.auxiliaries == rhs.auxiliaries &&
        lhs.evaluation == rhs.evaluation &&
        lhs.parameters == rhs.parameters &&
        lhs.predicate == rhs.predicate &&
        lhs.repeating == rhs.repeating &&
        lhs.symbols == rhs.symbols &&
        lhs.returnHandling == rhs.returnHandling
    }
}

// MARK: - Errors

extension Statement.Payload {
    enum Error: Swift.Error {
        case returnHandlingAssertionFailed(for: Statement.Payload)
    }
}
