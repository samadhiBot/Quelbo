//
//  Factory.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/22.
//

import Foundation
import OSLog

/// A base class for symbol factories whose job is to translate a parsed ``Token`` array into a
/// ``Symbol`` representing a Zil code element.
class Factory {
    /// The Zil directives that correspond to this symbol factory.
    class var zilNames: [String] { [] }

    /// Specifies what type of command the factory translates.
    class var factoryType: Factories.FactoryType { .zCode }

    /// An array of the local variables at play within a factory.
    var localVariables: [Statement]

    /// <#Description#>
    let mode: FactoryMode

    /// An array of ``Symbol`` instances processed from ``tokens``.
    var symbols: [Symbol] = []

    /// An array of ``Token`` instances parsed from Zil source code.
    let tokens: [Token]

    required init(
        _ tokens: [Token],
        with variables: inout [Statement],
        mode factoryMode: FactoryMode = .process
    ) throws {
        self.localVariables = variables
        self.mode = factoryMode
        self.tokens = tokens

        if NSClassFromString("XCTest") == nil {
            Logger.process.debug("   􀎕 Factory: \(String(describing: self), privacy: .public)")
        }

        try processTokens()
        try processSymbols()

        variables = localVariables
    }

    func findAndEvaluateDefinition(_ zil: String) throws -> Statement? {
        guard Game.findDefinition(zil.lowerCamelCase) != nil else {
            return nil
        }
        let evaluated = try Factories.DefinitionEvaluate(
            [.atom(zil)],
            with: &localVariables
        ).process()

        return Statement(
            id: evaluated.id,
            code: { _ in
                evaluated.code
            },
            type: evaluated.type,
            payload: .init(
                symbols: [evaluated]
            )
        )
    }

    /// <#Description#>
    /// - Parameter id: <#id description#>
    /// - Returns: <#description#>
    func findLocal(_ id: String) -> Statement? {
        localVariables.first { $0.id == id }
    }

    /// <#Description#>
    /// - Parameter zil: <#zil description#>
    /// - Returns: <#description#>
    func knownVariable(_ zil: String) -> Statement? {
        switch zil {
        case "PRSA":
            return Statement(
                id: "prsa",
                code: { _ in "prsa" },
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
