//
//  SymbolFactory.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/22.
//

import Foundation

/// A base class for symbol factories whose job is to translate a parsed ``Token`` array into a
/// ``Symbol`` representation of a Zil code element.
///
class SymbolFactory {
    /// The Zil directives that correspond to this symbol factory.
    class var zilNames: [String] { [] }

    /// The number and types of ``Parameters-swift.enum`` required by this symbol factory.
    class var parameters: Parameters { .any }

    /// The return value ``Symbol/DataType`` for the symbol produced by this symbol factory.
    class var returnType: Symbol.DataType { .unknown }

    /// An array of ``Token`` values parsed from Zil source code.
    let tokens: [Token]

    /// An array of ``Symbol`` values processed from ``tokens``.
    var symbols: [Symbol] = []

    /// The symbol's ``ProgramBlockType``, or the block type in which the symbol exists.
    var blockType: ProgramBlockType?

    /// Whether the symbol representation is mutable.
    var isMutable: Bool = true

    required init(
        _ tokens: [Token],
        in blockType: ProgramBlockType? = nil
    ) throws {
        self.blockType = blockType
        self.tokens = tokens
        try processTokens()
    }

    /// <#Description#>
    /// - Returns: <#description#>
    func eval() throws -> Token {
        throw FactoryError.unimplemented(self)
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

    /// Processes the factory ``symbols`` into a single ``Symbol`` representing a piece of Zil code.
    ///
    /// - Returns: A `Symbol` representing a piece of Zil code.
    ///
    /// - Throws: When the `symbols` array cannot be processed.
    func process() throws -> Symbol {
        throw FactoryError.unimplemented(self)
    }

    /// Safely returns the ``Symbol`` at the specified index of the ``symbols`` array.
    ///
    /// - Parameter index: The array index to look up a `Symbol`.
    ///
    /// - Returns: The `Symbol` at the specified index in `symbols`.
    ///
    /// - Throws: When the specified index is out of range.
    func symbol(_ index: Int) throws -> Symbol {
        guard symbols.count > index else {
            throw FactoryError.outOfRangeSymbolIndex(index, symbols)
        }
        return symbols[index]
    }
}

// MARK: - Array where Element == SymbolFactory

extension Array where Element == SymbolFactory.Type {
    /// Finds the symbol that corresponds to the
    ///
    /// - Parameter zil: The Zil directive to search for in an array of symbol factories.
    ///
    /// - Returns: A matching symbol factory.
    ///
    /// - Throws: When either zero or multiple symbol factories are found matching the specified
    ///           Zil directive.
    func find(_ zil: String) throws -> SymbolFactory.Type? {
        var zil = zil
        if zil.hasPrefix(",") { zil.removeFirst() }
        let matches = filter { $0.zilNames.contains(zil) }

        switch matches.count {
        case 0:
            return nil
        case 1:
            return matches[0]
        default:
            throw FactoryError.foundMultipleMatchingFactories(zil: zil, matches: matches)
        }
    }
}

// MARK: - Equatable

extension SymbolFactory: Equatable {
    static func == (lhs: SymbolFactory, rhs: SymbolFactory) -> Bool {
        type(of: lhs) == type(of: rhs)
    }
}