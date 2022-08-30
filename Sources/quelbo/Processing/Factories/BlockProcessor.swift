//
//  BlockProcessor.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/15/22.
//

import Foundation

extension Factories {
    /// A symbol factory for Zil code blocks.
    ///
    /// See the _ZILF Reference Guide_ entries on the
    /// [BIND](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.12jfdx2),
    /// [PROG](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1bkyn9b),
    /// [RETURN](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2fugb6e) and
    /// [AGAIN](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1au1eum)
    /// functions for detailed information.
    class BlockProcessor: Factory {
        private(set) var activation: String?
        private(set) var auxiliaries: [Parameter] = []
        private(set) var implicitReturns: Bool = true
        private(set) var parameters: [Parameter] = []
        private(set) var repeating: Bool = false
        private(set) var substitutions: [Token] = []

        override func processTokens() throws {
            var tokens = tokens

            if case .atom(let tokenActivation) = tokens.first {
                let activationName = tokenActivation.lowerCamelCase
                localVariables.append(Variable(id: activationName))
                activation = activationName
                tokens.removeFirst()
            }

            guard case .list(let paramTokens) = tokens.shift() else {
                throw Error.unexpectedTokenWhileFindingParameters(self.tokens)
            }

            try processParameters(in: paramTokens)

            symbols = try symbolize(tokens)
        }

        override func processSymbols() throws {
            try symbols
                .withReturnStatement
                .assert(.haveCommonType)

            try parameters.forEach {
                try $0.assertCommonType()
            }

            for symbol in symbols {
                guard
                    case .statement(let statement) = symbol,
                    statement.quirk == .bindWithAgain
                else { continue }

                for instance in statement.parameters {
                    auxiliaries.append(Parameter(
                        nameSymbol: instance,
                        defaultValue: nil,
                        context: .auxiliary
                    ))
                }
            }
        }
    }
}

// MARK: - Factories.BlockProcessor.Context

extension Factories.BlockProcessor {
    enum Context {
        case auxiliary
        case normal
        case optional
    }
}

// MARK: - Factories.BlockProcessor.Parameter

extension Factories.BlockProcessor {
    struct Parameter: Equatable {
        let nameSymbol: Instance
        let defaultValue: Symbol?
        let context: Context

        func assertCommonType() throws {
            guard let defaultValue = defaultValue else { return }

            try [.instance(nameSymbol), defaultValue].assert(.haveCommonType)
        }

        var declaration: String {
            if let defaultValue = defaultValue {
                return "\(nameSymbol.code): \(type) = \(defaultValue.code)"
            }
            if context == .optional {
                return "\(nameSymbol.code): \(type)\(type.emptyValueAssignment)"
            }
            return "\(nameSymbol.code): \(type)"
        }

        var emptyValueAssignment: String {
            let type = nameSymbol.type ?? .unknown
            var value: String {
                if let value = defaultValue?.code { return " = \(value)" }

                return type.emptyValueAssignment
            }

            return "var \(nameSymbol.code): \(type)\(value)"
        }

        var initialization: String {
            if let defaultValue = defaultValue {
                let type = defaultValue.type ?? .unknown
                return "var \(nameSymbol.code): \(type) = \(defaultValue.code)"
            }

            switch context {
            case .auxiliary:
                return emptyValueAssignment
            case .normal, .optional:
                return "var \(nameSymbol.code): \(type) = \(nameSymbol.code)"
            }
        }

        var isMutable: Bool {
            if let instanceIsMutable = nameSymbol.isMutable {
                return instanceIsMutable
            }
            return nameSymbol.variable.isMutable ?? false
        }

        var type: DataType {
            nameSymbol.type ?? .unknown
        }
    }
}

// MARK: - Processing

extension Factories.BlockProcessor {
    func assert(
        activation: String? = nil,
        implicitReturns: Bool = true,
        repeating: Bool = false,
        substitutions: [Token] = []
    ) {
        if self.activation == nil {
            self.activation = activation
        }
        self.implicitReturns = implicitReturns
        self.repeating = repeating
        if self.substitutions.isEmpty { self.substitutions = substitutions }
    }

    /// Scans through a ``Token`` array until it finds a parameter list, then returns a translated
    /// ``Symbol`` array.
    ///
    /// The `Token` array is mutated in the course of the search, removing any elements up to and
    /// including the target list.
    ///
    /// Any token specified in `substituting` is substituted in for the corresponding element in
    /// the `tokens` array. This applies when processing unevaluated
    /// ``Symbol/Category-swift.enum/definitions``.
    ///
    /// - Parameters:
    ///   - tokens: A `Token` array to search.
    ///   - substituting: And optional `Token` array to substitute for the found parameters.
    ///
    /// - Returns: An array of `Symbol` translations of the list tokens.
    ///
    /// - Throws: When no list is found, or token symbolization fails.
    func processParameters(in paramTokens: [Token]) throws {
        var context: Context = .normal

        for token in paramTokens {
            var nameToken: Token?
            var valueToken: Token?

            switch token {
            case .atom:
                nameToken = token
            case .list(let listTokens):
                guard listTokens.count == 2 else {
                    throw Error.unexpectedTokenWhileFindingParameters(listTokens)
                }
                nameToken = listTokens[0]
                valueToken = listTokens[1]
            case .quote(let quoted):
                nameToken = quoted
            case .string("ARGS"):
                context = .normal
            case .string("AUX"), .string("EXTRA"):
                context = .auxiliary
            case .string("OPT"), .string("OPTIONAL"):
                context = .optional
            case .string:
                nameToken = .atom("STRING")
                valueToken = token
            default:
                break
            }

            guard let nameToken = nameToken else { continue }

            var nameSymbol: Symbol
            if let substitution = substitutions.shift() {
                nameSymbol = try symbolize(substitution)
            } else {
                nameSymbol = try symbolize(nameToken)
            }

            var valueSymbol: Symbol?
            if let valueToken = valueToken {
                let value = try symbolize(valueToken)
                try nameSymbol.assert(.hasSameType(as: value))
                valueSymbol = value
            }

            guard case .variable(let variable) = nameSymbol else {
                throw Error.unexpectedNameSymboltype(nameSymbol, paramTokens)
            }

            localVariables.append(variable)

            let parameter = Parameter(
                nameSymbol: Instance(
                    variable,
                    isOptional: context == .optional
                ),
                defaultValue: valueSymbol,
                context: context
            )

            switch context {
            case .auxiliary: auxiliaries.append(parameter)
            case .normal, .optional: parameters.append(parameter)
            }
        }
    }
}

// MARK: - Methods & Computed properties

extension Factories.BlockProcessor {
    var auxiliaryDefs: String {
        let auxVariables = auxiliaries + parameters.filter(\.isMutable)
        guard !auxVariables.isEmpty else { return "" }

        return auxVariables
            .map(\.initialization)
            .joined(separator: "\n")
            .appending("\n")
    }

    var auxiliaryDefsWithDefaultValues: String {
        let auxVariables = auxiliaries + parameters.filter(\.isMutable)
        guard !auxVariables.isEmpty else { return "" }

        return auxVariables
            .map(\.emptyValueAssignment)
            .joined(separator: "\n")
            .appending("\n")
    }

    var code: String {
        var lines = symbols.filter { !$0.code.isEmpty }

        guard let last = lines.last else { return "" }
        lines.removeLast()

        var codeLines = lines.map(\.code)

        var lastLine: String {
            switch last.returnable {
            case .always:
                return "return \(last.code)"
            case .implicit:
                return implicitReturns ? "return \(last.code)" : last.code
            case .explicit, .void:
                return last.code
            }
        }

        codeLines.append(lastLine)

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

    func discardableResult() throws -> String {
        let (type, _) = try returnType()
        guard let type = type else { return "" }

        switch type {
        case .comment, .void: return ""
        default: return "@discardableResult\n"
        }
    }

    func functionType() throws -> DataType {
        let (type, _) = try returnType()
//        guard let type = type else {
//            throw Error.missingFunctionType
//        }

        return .function(parameters.map(\.type), type ?? .unknown)
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

            if statement.quirk == .bindWithAgain {
                return statement
            }
        }
        return nil
    }

    var isRepeating: Bool {
        repeating || symbols.contains {
            guard case .statement(let statement) = $0 else { return false }

            return [.againStatement, .bindWithAgain].contains(statement.quirk)
        }
    }

    var paramDeclarations: String {
        parameters
            .map(\.declaration)
            .values(.commaSeparatedNoTrailingComma)
    }

    var paramSymbols: [Instance] {
        parameters.map(\.nameSymbol)
    }

    func returnDeclaration() throws -> String {
        let (type, _) = try returnType()
        guard let type = type else { return "" }

        switch type {
        case .comment, .void: return ""
        default: return " -> \(type)"
        }
    }

    func returnType() throws -> (DataType?, DataType.Confidence?) {
        try symbols.returnType() ?? (.void, .void)
    }
}

// MARK: - Errors

extension Factories.BlockProcessor {
    enum Error: Swift.Error {
        case missingFunctionType
        case unexpectedNameSymboltype(Symbol, [Token])
        case unexpectedTokenWhileFindingParameters([Token])
    }
}
