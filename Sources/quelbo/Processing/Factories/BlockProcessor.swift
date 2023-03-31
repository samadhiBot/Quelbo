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
        private(set) var auxiliaries: [Instance] = []
        private(set) var parameters: [Instance] = []
        private(set) var repeating: Bool = false

        private(set) var returnHandling: Symbol.ReturnHandling = .suppressedPassthrough

        override func processTokens() throws {
            var tokens = tokens

            if case .atom(let tokenActivation) = tokens.first {
                let activationName = tokenActivation.lowerCamelCase
                localVariables.append(.init(
                    id: activationName,
                    code: { _ in activationName },
                    type: .unknown
                ))
                activation = activationName
                tokens.removeFirst()
            }

            if case .list(let paramTokens) = tokens.first {
                try processParameters(in: paramTokens)
                tokens.removeFirst()
            }

            symbols = try symbolize(tokens, type: context)
        }

        override func processSymbols() throws {
            for symbol in symbols {
                guard
                    case .statement(let statement) = symbol,
                    statement.isBindingAndRepeatingStatement
                else { continue }

                auxiliaries.append(contentsOf: statement.payload.parameters.map {
                    Instance($0.variable, context: .auxiliary)
                })
            }
        }

        var payload: Statement.Payload {
            .init(
                activation: activation,
                auxiliaries: auxiliaries,
                parameters: parameters,
                repeating: repeating,
                returnHandling: returnHandling,
                symbols: symbols
            )
        }
    }
}

// MARK: - Processing

extension Factories.BlockProcessor {
    func assert(
        activation: String? = nil,
        repeating: Bool? = nil,
        returnHandling: Symbol.ReturnHandling? = nil
    ) {
        if self.activation == nil {
            self.activation = activation
        }
        if let repeating {
            self.repeating = repeating
        }
        if let returnHandling {
            self.returnHandling = returnHandling
        }
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
        var context: Instance.Context = .normal

        for token in paramTokens {
            var nameToken: Token?
            var valueToken: Token?

            switch token {
            case .atom, .local:
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

            guard let nameToken else { continue }
            let name = nameToken.value.lowerCamelCase
            let nameVariable = {
                if let found = localVariables.first(where: { $0.id == name }) {
                    return found
                }
                let nameVariable = Statement(
                    id: name,
                    code: { _ in name },
                    type: .unknown,
                    returnHandling: .forced
                )
                localVariables.append(nameVariable)
                return nameVariable
            }()
            let nameSymbol: Symbol = .statement(nameVariable)

            let valueSymbol: Symbol? = try {
                guard let valueToken else { return nil }
                let value = try symbolize(valueToken)
                try nameSymbol.assert(.hasSameType(as: value))
                return value
            }()

            try valueSymbol?.assertHasReturnValue()

            let parameter = try Instance(
                nameVariable,
                context: context,
                defaultValue: valueSymbol,
                isOptional: context == .optional
            )

            switch context {
            case .auxiliary: auxiliaries.append(parameter)
            case .normal, .optional: parameters.append(parameter)
            }
        }
    }
}


// MARK: - Errors

extension Factories.BlockProcessor {
    enum Error: Swift.Error {
        case unexpectedTokenWhileFindingParameters([Token])
    }
}
