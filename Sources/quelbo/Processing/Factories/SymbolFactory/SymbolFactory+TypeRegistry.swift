//
//  SymbolFactory+TypeRegistry.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/30/22.
//

import Foundation

extension SymbolFactory {
    /// A registry of ``Symbol`` identifiers and their associated data types.
    ///
    /// The type registry's scope is intended to be a root level Zil form declaration.
    /// ``Game/processTokens()`` creates a new `TypeRegistry` to keep track of any detected types
    /// discovered in the processing phase, and that reference must be passed into each child
    /// factory.
    ///
    /// Zil's recursive nature necessitated using a reference type. Otherwise separate processing
    /// branches could miss each others' type information.
    class TypeRegistry {
        /// A dictionary of symbol identifiers and their associated data types.
        var registry: [Symbol.Identifier: Symbol.DataType]

        init() {
            self.registry = [:]
        }

        subscript(id: Symbol.Identifier) -> Symbol.DataType? {
            registry[id]
        }

        /// Registers the ``Symbol/DataType-swift.enum`` for the specified symbol ``Symbol/id``.
        ///
        /// - Parameters:
        ///   - id: A symbol identifier.
        ///   - type: The type to assign to the identifier.
        ///
        /// - Returns: The assigned type.
        @discardableResult func register(
            id: Symbol.Identifier,
            as type: Symbol.DataType
        ) -> Symbol.DataType {
            guard !type.isUnknown else {
                return .unknown
            }
            registry.merge([id: type]) { registered, new in
                new == registered ? registered : .zilElement
            }
            return type
        }

        /// Registers the ``Symbol/DataType-swift.enum`` for each of the specified symbols.
        ///
        /// - Parameter symbols: The symbols to be type-registered.
        func register(_ symbols: [Symbol]) throws {
            for symbol in symbols {
                register(id: symbol.id, as: symbol.type)
                try register(symbol.children)

                if symbol.isPlaceholderGlobal {
                    try Game.overwrite(symbol.with(
                        code: "var \(symbol.code): \(symbol.type) = \(symbol.type.emptyValue)"
                    ))
                }
            }
        }
    }
}

// MARK: - Conformances

extension SymbolFactory.TypeRegistry: CustomStringConvertible {
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
