//
//  Factory.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/22.
//

import Foundation

/// A base class for symbol factories whose job is to translate a parsed ``Token`` array into a
/// ``Symbol`` representation of a Zil code element.
///
class FactoryType {
    /// The Zil directives that correspond to this symbol factory.
    class var zilNames: [String] { [] }

    /// <#Description#>
    class var muddle: Bool { false }

    /// A variables dictionary of saved ``DataType-swift.enum`` keyed by symbol ``Symbol/id``.
    var localVariables: [Variable]

    /// An array of ``Symbol`` values processed from ``tokens``.
    var symbols: [Symbol] = []

    /// An array of ``Token`` values parsed from Zil source code.
    let tokens: [Token]

    required init(
        _ tokens: [Token],
        with variables: inout [Variable]
    ) throws {
        self.localVariables = variables
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

    /// Generates a symbol identifier based on the specified tokens.
    ///
    /// - Parameter tokens: Tokens used to produce an identifier.
    ///
    /// - Returns: A symbol identifier based on the specified tokens.
    func evalID(_ tokens: [Token]) throws -> String {
        var tokens = tokens

        let name = try findName(in: &tokens)
        let params = tokens.map { token in
            switch token {
            case .atom(let value): return "\(value.lowerCamelCase):"
            case .bool: return "bool:"
            case .character: return "character:"
            case .commented: return "commented:"
            case .decimal: return "decimal:"
            case .eval: return "eval:"
            case .form: return "form:"
            case .global: return "global:"
            case .list: return "list:"
            case .local: return "local:"
            case .property: return "property:"
            case .quote: return "quote:"
            case .segment: return "segment:"
            case .string: return "string:"
            case .type: return "type:"
            case .vector: return "vector:"
            }
        }.joined(separator: "")

        return "\(name.lowerCamelCase)(\(params))"
    }

    func findLocal(_ id: String) -> Variable? {
        localVariables.first { $0.id == id }
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

// MARK: - Factories

/// Namespace for symbol factories that translate a ``Token`` array to a ``Symbol`` array.
enum Factories {}

// MARK: - Equatable

extension FactoryType: Equatable {
    static func == (lhs: FactoryType, rhs: FactoryType) -> Bool {
        type(of: lhs) == type(of: rhs)
    }
}

// MARK: - Factory

/// <#Description#>
class Factory: FactoryType {}

// MARK: - PropertyFactory

/// <#Description#>
class PropertyFactory: FactoryType {}

// MARK: - Errors

extension FactoryType {
    enum Error: Swift.Error {
        case unimplementedFactory(FactoryType)
    }
}
