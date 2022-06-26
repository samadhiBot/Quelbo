//
//  Symbol.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/26/22.
//

import CustomDump
import Foundation

/// A representation of a piece of Zil code and its Swift translation.
struct Symbol: Identifiable {
    /// The symbol's unique identifier.
    let id: Symbol.Identifier

    /// The Swift translation of a piece of Zil code.
    let codeBlock: (Symbol) throws -> String

    /// The ``Symbol/DataType-swift.enum`` for the ``code``.
    var type: DataType

    /// The symbol's ``Symbol/Category-swift.enum``.
    var category: Category?

    /// Any child symbols belonging to a complex symbol.
    let children: [Symbol]

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
        self.id = id ?? .id("")
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
        self.id = id ?? .id("")
        self.codeBlock = { _ in code.rightTrimmed }
        self.type = type
        self.category = category
        self.children = children
        self.meta = meta
    }
}

// MARK: - Symbol helper methods

extension Symbol {
    /// Runs the ``Symbol/codeBlock`` and returns the resulting `String`.
    var code: String {
        do {
            return try codeBlock(self)
        } catch {
            return "Symbol.code error: \(error)"
        }
    }

    /// Whether the symbol's children are ``Factories/Table`` definition flags.
    var containsTableFlags: Bool {
        !children.isEmpty && children.allSatisfy {
            ["byte", "length", "lexv", "pure", "string", "word"].contains($0.code)
        }
    }

    /// Returns a description of the symbol's data type.
    var dataType: String {
        for metaData in meta {
            if case .type(let type) = metaData { return type }
        }
        return type.description
    }

    /// Returns an unevaluated token stored by the symbol, if one exists.
    var definition: [Token] {
        for metaData in meta {
            if case .zil(let tokens) = metaData {
                return tokens
            }
        }
        return []
    }

    /// Whether the symbol represents a code block.
    var isCodeBlock: Bool {
        meta.contains { metaData in
            guard case .blockType = metaData else { return false }
            return true
        }
    }

    /// <#Description#>
    var identifiable: Bool {
        !id.stringLiteral.isEmpty
    }

    /// Whether the symbol represents a closure.
    var isFunctionClosure: Bool {
        for metaData in meta {
            if case .type = metaData { return true }
        }
        return false
    }

    /// Whether the symbol represents a literal value.
    var isLiteral: Bool {
        for metaData in meta {
            if case .isLiteral = metaData { return true }
        }
        return false
    }

    /// Whether the symbol represents a mutating variable.
    func isMutating(in symbols: [Symbol]) -> Bool? {
        for symbol in symbols {
            if symbol.id == id && !symbol.meta.contains(.isImmutable) {
                return true
            }
            if let foundInChildren = isMutating(in: symbol.children) {
                return foundInChildren
            }
        }
        return nil
    }

    /// Whether the symbol represents a return statement.
    var isReturnStatement: Bool {
        for metaData in meta {
            if case .isReturnStatement = metaData { return true }
        }
        return false
    }


    /// <#Description#>
    /// - Parameter symbol: <#symbol description#>
    /// - Returns: <#description#>
    mutating func reconcile(with other: Symbol) -> Symbol {
        var metaData = meta

        if type != other.type && typeCertainty < other.typeCertainty {
            type = other.type
            metaData = metaData.filter {
                if case .typeCertainty = $0 { return false } else { return true }
            }
            metaData.insert(.typeCertainty(other.typeCertainty))
        }
        if let otherCategory = other.category, category != otherCategory {
            category = otherCategory
        }
//        if meta != other.meta {
//            meta = other.meta
//        }

        print("// 🌶️ Reconciled \(self)") 

        return self.with(
//            code: other.code,
//            children: other.children,
            meta: metaData
        )
    }

    /// If a symbol represents a `return` statement with a return value, `returnValueType` provides
    /// the return value type. In all other cases, it returns `nil`.
    var returnValueType: Symbol.DataType? {
        for metaData in meta {
            if case .isReturnStatement(let type) = metaData { return type }
        }
        return nil
    }


    /// The level of confidence in a symbol's stated ``Symbol/type``.
    ///
    /// Symbols only specify their ``Symbol/MetaData/typeCertainty(_:)`` when their type is in
    /// question. 
    var typeCertainty: Symbol.MetaData.TypeCertainty {
        guard !type.isUnknown else { return .unknown }

        for metaData in meta {
            if case .typeCertainty(let value) = metaData { return value }
        }
        return .certain
    }

    /// Whether the symbol represents a global variable with a placeholder value of unknown type.
    ///
    /// This occurs with zil declarations such as `<GLOBAL PRSO <>>`, where the `false` is
    /// ambiguous. If Quelbo discovers a different `type` through the variable's use in the code,
    /// it updates the global with the found `type`.
//    var isPlaceholder: Bool {
//        typeCertainty != .certain
//    }

    /// Returns the symbol with one or more properties replaced with those specified.
    ///
    /// - Parameters:
    ///   - id: The symbol's unique identifier.
    ///   - code: The Swift translation of a piece of Zil code.
    ///   - type: The symbol data type for the code.
    ///   - category: The symbol's category.
    ///   - children: Any child symbols belonging to a complex symbol.
    ///   - meta: Any additional information required for symbol processing.
    ///
    /// - Returns: The symbol with any specified properties updated.
    func with(
        id newID: Symbol.Identifier? = nil,
        code newCode: String? = nil,
        type newType: DataType? = nil,
        category newCategory: Category? = nil,
        children newChildren: [Symbol]? = nil,
        meta newMeta: Set<MetaData>? = nil
    ) -> Symbol {
        Symbol(
            id: newID ?? id,
            code: newCode ?? code,
            type: newType ?? type,
            category: newCategory ?? category,
            children: newChildren ?? children,
            meta: newMeta ?? meta
        )
    }

    /// Returns the original Zil name of the object represented by the symbol.
    var zilName: String {
        for metaData in meta {
            if case .zilName(let name) = metaData { return name }
        }
        return "???"
    }
}

// MARK: - Symbol.Category

extension Symbol {
    /// The set of ``Symbol`` categories.
    ///
    /// Categories are used to distinguish different kinds of symbols, allowing them to be grouped
    /// together appropriately in the game translation.
    enum Category: String {
        /// Symbols representing global constant game values.
        case constants

        /// Symbols representing definitions that are evaluated to create other symbols.
        case definitions

        /// Symbols representing room exit directions.
        case directions

        /// Symbols representing object flags.
        case flags

        /// Symbols representing evaluated functions defined by the game.
        case functions

        /// Symbols representing global game variables.
        case globals

        /// Symbols representing objects in the game.
        case objects

        /// Symbols representing object properties.
        case properties

        /// Symbols representing rooms (i.e. locations) in the game.
        case rooms

        /// Symbols representing routines defined by the game.
        case routines

        /// Symbols representing syntax declarations specified by the game.
        case syntax
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
                "type": self.type,
                "category": "\(self.category?.rawValue ?? "none")",
                "meta": self.meta,
                "code": self.code,
            ],
            displayStyle: .struct
        )
    }
}

extension Symbol: CustomStringConvertible {
    var description: String {
        var details: [String] = []
//        var ref = "\(ObjectIdentifier(self))"
//        ref.removeFirst(28)
//        ref.removeLast()
        if identifiable { details.append("id: \(id)") }
//        details.append("ref: \(ref)")
        if !code.isEmpty { details.append("code: \(code)") }
        details.append("type: \(type)")
        if let category = category { details.append("category: \(category)") }
        if !meta.isEmpty { details.append("meta: \(meta)") }

        return "{\n\(details.joined(separator: ",\n").indented)\n}"
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
        assert(identifiable, "Attempted to register a symbol without an id: \(code)")
        hasher.combine(id)
    }
}

// MARK: - Array where Element == Symbol

extension Symbol {
    /// Display options for use with the `codeValues` method.
    enum CodeValuesDisplayOption {
        /// Values to be comma-separated with a line break after each value.
        case commaLineBreakSeparated

        /// Values to be comma-separated.
        case commaSeparated

        /// Values to be comma-separated.
        case commaSeparatedNoTrailingComma

        /// Values to be comma-separated with a double line break after each value.
        case doubleLineBreak

        /// The set of values to be indented.
        case indented

        /// Values to be separated by the specified string.
        case separator(String)

        /// Values to separated by a line break after each value.
        case singleLineBreak
    }
}

extension Array where Element == Symbol {
    /// Returns a formatted string containing the ``Symbol/code`` values for a ``Symbol`` array.
    ///
    /// - Parameter displayOptions: One or more ``Symbol/CodeValuesDisplayOption`` values that
    ///                             specify how to separate and display the code values.
    ///
    /// - Returns: A formatted string containing the code values contained in the symbol array.
    func codeValues(_ displayOptions: Symbol.CodeValuesDisplayOption...) -> String {
        var addBlock = false
        var indented = false
        var lineBreaks = 0
        var noTrailingComma = false
        var separator = ""

        displayOptions.forEach { option in
            switch option {
            case .commaLineBreakSeparated:
                indented = true
                lineBreaks = 1
                separator = ","
            case .commaSeparated:
                separator = ","
            case .commaSeparatedNoTrailingComma:
                noTrailingComma = true
                separator = ","
            case .doubleLineBreak:
                lineBreaks = 2
            case .indented:
                indented = true
            case .separator(let string):
                separator = string.rightTrimmed
            case .singleLineBreak:
                lineBreaks = 1
            }
        }
        let codeValues = compactMap {
            $0.code.isEmpty ? nil : $0.code
        }
        if lineBreaks == 0 && separator == "," {
            let code = codeValues.joined(separator: separator)
            if code.count > 20 || code.contains("\n") {
                addBlock = true
                lineBreaks = 1
                indented = true
            }
        }
        if lineBreaks == 0 {
            separator.append(" ")
        }
        for _ in 0..<lineBreaks {
            separator.append("\n")
        }
        var values = codeValues.joined(separator: separator)
        if indented {
            values = values.indented.rightTrimmed
        }
        if addBlock {
            values = "\n\(values)\(noTrailingComma ? "\n" : separator)"
        }
        return values
    }

    /// Deep-searches a ``Symbol`` array for a `"paramDeclarations"` metadata declaration, and
    /// returns its value if one is found.
    var deepParamDeclarations: String? {
        for symbol in self {
            for metaData in symbol.meta {
                if case .paramDeclarations(let params) = metaData {
                    return params
                }
            }
            if let paramDeclarations = symbol.children.deepParamDeclarations {
                return paramDeclarations
            }
        }
        return nil
    }

    /// Deep-searches a ``Symbol`` array for a `"block"` metadata declaration with
    /// `"repeatingWithoutDefaultActivation"` value, and returns `true` if one is found.
    var deepRepeating: Bool? {
        for symbol in self {
            if symbol.meta.contains(.blockType(.repeatingWithoutDefaultActivation)) {
                return true
            }
            if let deepRepeatingChild = symbol.children.deepRepeating {
                return deepRepeatingChild
            }
        }
        return nil
    }

    var deepReplaceEmptyReturnValues: [Symbol] {
        map {
            $0.with(
                code: $0.code.replacingOccurrences(of: "return false", with: "return nil"),
                children: $0.children.deepReplaceEmptyReturnValues
            )
        }
    }

    /// Deep-searches a ``Symbol`` array for explicit `return` statements with return values, and
    /// returns their symbol representations.
    var deepReturnTypes: [Symbol] {
        reduce(into: [Symbol]()) { partial, symbol in
            partial.append(contentsOf: symbol.children.deepReturnTypes)
            if let _ = symbol.returnValueType {
                partial.append(symbol)
            }
//            partial.sort { $0.typeCertainty > $1.typeCertainty }
//            let sorted = partial.sorted(by: { $0.typeCertainty > $1.typeCertainty })
//            guard let maxCertainty = sorted.first?.typeCertainty else {
//                return
//            }
//            partial = sorted.filter { $0.typeCertainty >= maxCertainty }
        }
    }

    /// Searches the array to find a ``Symbol`` with the specified `id`.
    ///
    /// The recursive search inspects each `Symbol` and each symbol's `children`, until it finds a
    /// match, which it returns.
    ///
    /// - Parameter id: A unique `Symbol` identifier.
    ///
    /// - Returns: A `Symbol` with the specified `id`, if one exists within the array.
    func find(id symbolID: Symbol.Identifier) -> Symbol? {
        guard !symbolID.stringLiteral.isEmpty else { return nil }

        for symbol in self {
            if symbolID == symbol.id {
                return symbol
            } else if let childSymbol = symbol.children.find(id: symbolID) {
                return childSymbol
            }
        }
        return nil
    }

    /// <#Description#>
    ///
    /// - Returns: <#description#>
    func findByTypeCertainty() -> Symbol? {
        guard count > 1 else { return first }

        var symbols = sorted { $0.typeCertainty > $1.typeCertainty }
        while let subject = symbols.shift() {
            if subject.typeCertainty > symbols.first?.typeCertainty ?? .unknown {
                return subject
            }
            if subject.type != symbols.first?.type {
                return nil
            }
        }
        return nil
    }

    /// Returns the ``Symbol`` array with quotes applied to the code values of any elements with
    /// type ``Symbol/DataType/string``.
    var quoted: [Symbol] {
        map { symbol in
            guard symbol.type == .string else {
                return symbol
            }
            return symbol.with(code: symbol.code.quoted)
        }
    }

    /// Returns the ``Symbol`` array sorted by element ``Symbol/id``.
    var sorted: [Symbol] {
        sorted {
            if $0.category == .flags {
                return $0.code < $1.code
            } else {
                return $0.id < $1.id
            }
        }
    }
}

// MARK: - Common literal symbols

extension Symbol {
    /// A literal boolean `false` symbol.
    static var falseSymbol: Symbol {
        Symbol(
            code: "false",
            type: .bool,
            meta: [
                .isLiteral,
                .typeCertainty(.booleanFalse)
            ]
        )
    }

    /// A literal integer `0` symbol.
    static func integerSymbol(_ integer: Int) -> Symbol {
        Symbol(
            code: "\(integer)",
            type: .int,
            meta: integer == 0 ? [.isLiteral, .typeCertainty(.integerZero)] : [.isLiteral]
        )
    }

    /// A literal boolean `true` symbol.
    static var trueSymbol: Symbol {
        Symbol(code: "true", type: .bool, meta: [.isLiteral])
    }

    /// A literal integer `0` symbol.
    static var zeroSymbol: Symbol {
        .integerSymbol(0)
    }
}

//extension Symbol {
//    struct ReturnType {
//        let type: DataType
//        let maybeEmptyValue: Bool
//    }
//}
