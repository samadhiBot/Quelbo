//
//  SymbolRegistry.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/30/22.
//

import Foundation

/// A registry of ``Symbol`` identifiers and their associated data types.
///
/// The type registry's scope is intended to be a root level Zil form declaration.
/// ``Game/processTokens()`` creates a new `SymbolRegistry` to keep track of any detected types
/// discovered in the processing phase, and that reference must be passed into each child
/// factory.
///
/// Zil's recursive nature necessitated using a reference type. Otherwise separate processing
/// branches could miss each others' type information.
class SymbolRegistry {
    /// A dictionary of symbol identifiers and their associated data types.
    private var registry: [Symbol.Identifier: Symbol]

    init(_ symbols: [Symbol] = []) {
        self.registry = [:]
        symbols.forEach { register($0) }
    }

    subscript(id: Symbol.Identifier) -> Symbol? {
        registry[id]
    }

    /// Registers the ``Symbol/DataType-swift.enum`` for the specified symbol ``Symbol/id``.
    ///
    /// - Parameters:
    ///   - id: A symbol identifier.
    ///   - type: The type to assign to the identifier.
    ///
    /// - Returns: The assigned type.

    /// <#Description#>
    /// - Parameter symbol: <#symbol description#>
    func register(_ symbol: Symbol) {
        guard !symbol.type.isUnknown else { return }

        registry.merge([symbol.id: symbol.ignoringChildren]) { registered, new in
            new.type == registered.type ? registered : new.with(type: .zilElement)
        }
    }

    /// Registers the ``Symbol/DataType-swift.enum`` for each of the specified symbols.
    ///
    /// - Parameter symbols: The symbols to be type-registered.
    func register(_ symbols: [Symbol]) throws {
        for symbol in symbols {
            register(symbol)
            try register(symbol.children)

            if symbol.isPlaceholderGlobal {
                try Game.overwrite(symbol.with(
                    code: "var \(symbol.code): \(symbol.type)\(symbol.type.emptyValueAssignment)",
                    type: symbol.type.emptyValueType,
                    meta: symbol.type.emptyMeta
                ))
            }
        }
    }
}

// MARK: - Conformances

extension SymbolRegistry: CustomStringConvertible {
    var description: String {
        guard !registry.isEmpty else {
            return "No types registered"
        }
        let types = registry.map { key, value in
            "\(key): \(value)"
        }.joined(separator: "\n")
        return """
            [
            \(types.indented)
            ]
            """
    }
}
