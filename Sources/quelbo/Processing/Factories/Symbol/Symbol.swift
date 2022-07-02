//
//  Symbol.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/26/22.
//

import CustomDump
import Foundation

/// A representation of a piece of Zil code and its Swift translation.
class Symbol: Identifiable {
    /// The symbol's unique identifier.
    let id: Symbol.Identifier

    /// The Swift translation of a piece of Zil code.
    let codeBlock: (Symbol) throws -> String

    /// The ``Symbol/DataType-swift.enum`` for the ``code``.
    var type: DataType

    /// The symbol's ``Symbol/Category-swift.enum``.
    var category: Category?

    /// Any child symbols belonging to a complex symbol.
    var children: [Symbol]

    /// Any additional information required for symbol processing.
    var meta: Set<MetaData>

    /// <#Description#>
    /// - Parameters:
    ///   - id: <#id description#>
    ///   - codeBlock: <#codeBlock description#>
    ///   - type: <#type description#>
    ///   - category: <#category description#>
    ///   - children: <#children description#>
    ///   - meta: <#meta description#>
    init(
        id: Symbol.Identifier? = nil,
        code codeBlock: @escaping (Symbol) throws -> String,
        type: DataType = .unknown,
        category: Category? = nil,
        children: [Symbol] = [],
        meta: Set<MetaData> = []
    ) {
        self.id = id ?? ""
        self.codeBlock = codeBlock
        self.type = type
        self.category = category
        self.children = children
        self.meta = meta
    }

    /// <#Description#>
    /// - Parameters:
    ///   - id: <#id description#>
    ///   - code: <#code description#>
    ///   - type: <#type description#>
    ///   - category: <#category description#>
    ///   - children: <#children description#>
    ///   - meta: <#meta description#>
    init(
        id: Symbol.Identifier? = nil,
        code: String = "",
        type: DataType = .unknown,
        category: Category? = nil,
        children: [Symbol] = [],
        meta: Set<MetaData> = []
    ) {
        self.id = id ?? ""
        self.codeBlock = { _ in code.rightTrimmed }
        self.type = type
        self.category = category
        self.children = children
        self.meta = meta
    }
}

// MARK: - Symbol.Error

extension Symbol {
    enum Error: Swift.Error, Equatable {
        case typeMismatch(Symbol, expected: Symbol.DataType)
        case typeNotFound([Symbol])
        case unexpectedType([Symbol], expected: Symbol.DataType)
    }
}

// MARK: - Conformances

extension Symbol: Comparable {
    static func < (lhs: Symbol, rhs: Symbol) -> Bool {
        lhs.id < rhs.id
    }
}

extension Symbol: CustomDumpReflectable {
    var customDumpMirror: Mirror {
        .init(
            self,
            children: [
                "id": self.id,
                "code": self.code,
                "type": self.type,
                "category": self.category?.rawValue ?? "none",
                "meta": self.meta,
            ],
            displayStyle: .struct
        )
    }
}

extension Symbol: CustomDebugStringConvertible {
    var debugDescription: String {
        """
        {
            id: \(id),
            code \(code),
            type: \(type),
            category: \(category?.rawValue ?? "none"),
            children: \(children),
            meta: \(meta)
        }
        """
    }
}

extension Symbol: CustomStringConvertible {
    var description: String {
//        guard !id.stringLiteral.isEmpty else { return code }

        return id.stringLiteral
    }
}

extension Symbol: Equatable {
    static func == (lhs: Symbol, rhs: Symbol) -> Bool {
        lhs.id == rhs.id &&
        lhs.code == rhs.code &&
        lhs.type == rhs.type &&
        lhs.category == rhs.category &&
        lhs.meta == rhs.meta
    }
}

extension Symbol: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(code)
        hasher.combine(type)
        hasher.combine(category)
        hasher.combine(meta)
    }
}

// MARK: - Common literal symbols

extension Symbol {
    /// A literal integer `0` symbol.
    static func booleanSymbol(_ boolean: Bool) -> Symbol {
        Symbol(
            code: { symbol in
                symbol.translate("\(boolean)")
            },
            type: .bool,
            meta: boolean ? [.isLiteral] : [.isLiteral, .typeCertainty(.booleanFalse)]
        )
    }

    /// A literal boolean `false` symbol.
    static var falseSymbol: Symbol {
        .booleanSymbol(false)
    }

    /// A literal integer `0` symbol.
    static func integerSymbol(_ integer: Int) -> Symbol {
        Symbol(
            code: { symbol in
                symbol.translate("\(integer)")
            },
            type: .int,
            meta: integer == 0 ? [.isLiteral, .typeCertainty(.integerZero)] : [.isLiteral]
        )
    }

    /// A literal boolean `true` symbol.
    static var trueSymbol: Symbol {
        .booleanSymbol(true)
    }

    /// A literal integer `0` symbol.
    static var zeroSymbol: Symbol {
        .integerSymbol(0)
    }
}
