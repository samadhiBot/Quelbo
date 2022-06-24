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
    private var registry: [Symbol]

    init(_ symbols: [Symbol] = []) {
        self.registry = []
        register(symbols)
    }

    static func find(_ id: Symbol.Identifier) -> Symbol? {
        registry.first { $0.id == id }
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
        assert(!symbol.id.stringLiteral.isEmpty, "Attempted to register a symbol without an id.")

        guard self[symbol.id] == nil else { return }
        registry.append(symbol)
        
//        if registry[symbol.id] == nil { registry[symbol.id] = symbol }
//
//        if symbol.typeCertainty > existing.typeCertainty
//
//        let newSymbol = Symbol(
//            id: symbol.id,
//            code: symbol.id.stringLiteral,
//            type: symbol.type,
//            category: symbol.category,
//            meta: symbol.meta
//        )
//
//        registry.merge([symbol.id: newSymbol]) { registered, new in
//            new.type == registered.type ? new : new.with(type: .zilElement)
//        }
    }

    /// Registers the ``Symbol/DataType-swift.enum`` for each of the specified symbols.
    ///
    /// - Parameter symbols: The symbols to be type-registered.
    func register(_ symbols: [Symbol]) {
        symbols.forEach { register($0) }
//        for symbol in symbols {
//            register(symbol)
//            try register(symbol.children)

//            if symbol.isPlaceholderGlobal {
//                try Game.overwrite(symbol.with(
//                    code: "var \(symbol.code): \(symbol.type)\(symbol.type.emptyValueAssignment)",
//                    type: symbol.type.emptyValueType,
//                    meta: symbol.type.emptyMeta
//                ))
//            }
//        }
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
