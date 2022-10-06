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

        override func processTokens() throws {
            var tokens = tokens

            if case .atom(let tokenActivation) = tokens.first {
                let activationName = tokenActivation.lowerCamelCase
                localVariables.append(Variable(id: activationName, type: .unknown))
                activation = activationName
                tokens.removeFirst()
            }

            if case .list(let paramTokens) = tokens.first {
                try processParameters(in: paramTokens)
                tokens.removeFirst()
            }

            symbols = try symbolize(tokens)
        }

        override func processSymbols() throws {
            try symbols.withReturnStatement.assert(
                .haveCommonType
            )

            for parameter in parameters {
                try parameter.assertCommonType()
            }

            for symbol in symbols {
                guard
                    case .statement(let statement) = symbol,
                    statement.isBindWithAgainStatement
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
            let value = {
                if let value = defaultValue?.code {
                    return " = \(value)"
                } else {
                    return nameSymbol.type.emptyValueAssignment
                }
            }()
            return "var \(nameSymbol.code): \(nameSymbol.type)\(value)"
        }

        var initialization: String {
            if let defaultValue = defaultValue {
                return "var \(nameSymbol.code): \(defaultValue.type) = \(defaultValue.code)"
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

        var type: TypeInfo {
            nameSymbol.type
        }
    }
}

// MARK: - Processing

extension Factories.BlockProcessor {
    func assert(
        activation: String? = nil,
        implicitReturns: Bool = true,
        repeating: Bool = false
    ) {
        if self.activation == nil {
            self.activation = activation
        }
        self.implicitReturns = implicitReturns
        self.repeating = repeating
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
            let nameSymbol = try symbolize(nameToken)

            var valueSymbol: Symbol?
            if let valueToken = valueToken {
                let value = try symbolize(valueToken)
                try nameSymbol.assert(.hasSameType(as: value))
                valueSymbol = value
            }

            let nameVariable: Variable
            switch nameSymbol {
            case .instance(let instance): nameVariable = instance.variable
            case .variable(let variable): nameVariable = variable
            default: throw Error.unexpectedNameSymbolType(nameSymbol, paramTokens)
            }

            localVariables.append(nameVariable)

            let parameter = Parameter(
                nameSymbol: Instance(
                    nameVariable,
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
        guard let lastIndex = lines.lastIndex(where: { $0.type != .comment }) else {
            return lines.handles(.singleLineBreak)
        }
        let last = lines.remove(at: lastIndex)
        var codeLines = lines.map(\.handle)
        var lastLine: String {
            if let returnType = returnType(), last.type != returnType {
                return last.handle
            }
            switch last {
            case .definition:
                return last.handle
            case .literal, .instance, .variable:
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

    func discardableResult() throws -> String {
        let type = returnType()
        guard let type = type else { return "" }

        switch type {
        case .comment, .void: return ""
        default: return "@discardableResult\n"
        }
    }

//    func functionType() throws -> TypeInfo {
//        let type = try returnType() ?? .void
////        guard let type = type else {
////            throw Error.missingFunctionType
////        }
//
//        return .function(parameters.map(\.type.dataType), type.dataType)
//    }

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

            if statement.isBindWithAgainStatement {
                return statement
            }
        }
        return nil
    }

    var isRepeating: Bool {
        repeating || symbols.contains {
            guard case .statement(let statement) = $0 else { return false }

            return statement.isAgainStatement || statement.isBindWithAgainStatement
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
        guard let type = returnType() else { return "" }

        switch type {
        case .comment, .void: return ""
        default: return " -> \(type)"
        }
    }

    func returnType() -> TypeInfo? {
        symbols.returnType()
    }
}

// MARK: - Errors

extension Factories.BlockProcessor {
    enum Error: Swift.Error {
        case missingFunctionType
        case unexpectedNameSymbolType(Symbol, [Token])
        case unexpectedTokenWhileFindingParameters([Token])
    }
}
