//
//  Factory.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/22.
//

import Foundation

/// A base class for symbol factories whose job is to translate a parsed ``Token`` array into a
/// ``Symbol`` representing a Zil code element.
class Factory {
    /// The Zil directives that correspond to this symbol factory.
    class var zilNames: [String] { [] }

    /// Specifies what type of command the factory translates.
    class var factoryType: Factories.FactoryType { .zCode }

    /// An array of the local variables at play within a factory.
    var localVariables: [Variable]

    /// <#Description#>
    let mode: FactoryMode

    /// An array of ``Symbol`` instances processed from ``tokens``.
    var symbols: [Symbol] = []

    /// An array of ``Token`` instances parsed from Zil source code.
    let tokens: [Token]

    required init(
        _ tokens: [Token],
        with variables: inout [Variable],
        mode factoryMode: FactoryMode = .process
    ) throws {
        self.localVariables = variables
        self.mode = factoryMode
        self.tokens = tokens

        try processTokens()
        try processSymbols()

        variables = localVariables
    }

    /// <#Description#>
    /// - Parameter symbols: <#symbols description#>
    /// - Returns: <#description#>
    func evaluate(_ symbols: [Symbol]) throws -> [Symbol] {
        var evaluatedSymbols: [Symbol] = []

        for symbol in symbols {
            guard case .definition(let definition) = symbol else {
                evaluatedSymbols.append(symbol)
                continue
            }

            evaluatedSymbols.append(
                contentsOf: try symbolize(definition.tokens)
            )
        }

        return evaluatedSymbols
    }

    /// <#Description#>
    /// - Parameter id: <#id description#>
    /// - Returns: <#description#>
    func findLocal(_ id: String) -> Variable? {
        localVariables.first { $0.id == id }
    }

    /// <#Description#>
    /// - Parameter zil: <#zil description#>
    /// - Returns: <#description#>
    func knownVariable(_ zil: String) -> Variable? {
        switch zil {
        case "PRSA":
            return Variable(
                id: "prsa",
                type: .int,
                category: .globals,
                isMutable: true
            )
        default:
            return nil
        }
    }

    /// Processes the ``tokens`` array into a ``Symbol`` array.
    ///
    /// `processTokens()` is called during initialization. Factories with special symbol processing
    /// requirements can override this method.
    ///
    /// - Returns: A `Symbol` array processed from the `tokens` array.
    ///
    /// - Throws: When the `tokens` array cannot be symbolized.
    func processTokens() throws {
        self.symbols = try symbolize(tokens)
    }

    /// <#Description#>
    func processSymbols() throws {
        // override in child factories
    }

    /// Processes the factory ``symbols`` into a single ``Symbol`` representing a piece of Zil code.
    ///
    /// - Returns: A `Symbol` representing a piece of Zil code.
    ///
    /// - Throws: When the `symbols` array cannot be processed.
    @discardableResult
    func process() throws -> Symbol {
        throw Error.unimplementedFactory(self)
    }
}

extension Factory {
    /// <#Description#>
    enum FactoryMode: Equatable {
        case evaluate

        case process
    }
}

// MARK: - Equatable

extension Factory: Equatable {
    static func == (lhs: Factory, rhs: Factory) -> Bool {
        type(of: lhs) == type(of: rhs)
    }
}

// MARK: - Errors

extension Factory {
    enum Error: Swift.Error {
        case unimplementedFactory(Factory)
    }
}
