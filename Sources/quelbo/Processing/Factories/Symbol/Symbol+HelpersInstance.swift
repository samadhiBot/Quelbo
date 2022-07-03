//
//  Symbol+HelpersInstance.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/2/22.
//

import Foundation

extension Symbol {
    /// Whether the symbol represents a literal value.
//    var blockType: SymbolFactory.ProgramBlockType? {
//        for metaData in meta {
//            if case .blockType(let blockType) = metaData { return blockType }
//        }
//        return nil
//    }

    /// Runs the ``Symbol/codeBlock`` and returns the resulting `String`.
    var code: String {
        do {
            return try codeBlock(self)
        } catch {
            return "Symbol.code error: \(error)"
        }
    }

    /// <#Description#>
    var controlflow: MetaData.ControlFlow? {
        for metaData in meta {
            if case .controlFlow(let flow) = metaData { return flow }
        }
        return nil
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
            if case .zil(let tokens) = metaData { return tokens }
        }
        return []
    }

    /// Whether the symbol represents a code block.
    var isCodeBlock: Bool {
        meta.contains { metaData in
            if case .controlFlow(.block) = metaData { return true }
            return false
        }
    }

    /// <#Description#>
    var isIdentifiable: Bool {
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
    func isParamWith(context: Symbol.ParamContext) -> Bool {
        for metaData in meta {
            if case .paramContext(let paramContext) = metaData { return paramContext == context }
        }
        return false
    }


    /// Whether the symbol represents a return statement.
    var isReturnStatement: Bool {
        meta.contains { metaData in
            if case .controlFlow(.returnValue) = metaData { return true }
            return false
        }
    }

    /// <#Description#>
    var localVariable: String {
        if code.contains("=") {
            return "var \(code)"
        } else {
            return "var \(code)\(type.emptyValueAssignment)"
        }
    }

    /// <#Description#>
    /// - Parameter symbol: <#symbol description#>
    /// - Returns: <#description#>
    func reconcile(with revision: Symbol) -> Symbol {
        // print("🥔 reconcile \(self) \(ObjectIdentifier(self))")
//        if case .variable = type {
//            self.type = revision.type.asVariable // TODO: still necessary?
//        } else {
//            self.type = revision.type
//        }
        if revision.typeCertainty > typeCertainty {
            self.meta = meta.withoutTypeCertainty
            self.type = revision.type
            // print("// 🍊 type revised to \(self.type)")
        }

        if !revision.children.isEmpty {
            self.children = revision.children
            // print("// 🍊 children revised to \(self.children)")
        }

        if let revisedCategory = revision.category {
            self.category = revisedCategory
            // print("// 🍊 category revised to \(self.category)")
        }

        revision.meta.forEach { metaData in
            switch metaData {
//            case .activation(let activation):
//                print("// 🥥 activation: \(activation)")
//            case .blockType(let blockType):
//                print("// 🥥 blockType: \(blockType)")
//            case .isAgainStatement:
//                print("// 🥥 isAgainStatement")
//            case .isImmutable:
//                print("// 🥥 isImmutable")
//            case .isLiteral:
//                print("// 🥥 isLiteral")
//            case .isReturnStatement(let isReturnStatement):
//                print("// 🥥 isReturnStatement: \(isReturnStatement)")
//            case .paramContext(let paramContext):
//                if !meta.contains(where: {
//                    if case .paramContext = $0 { return true } else { return false }
//                }) {
//                    meta.insert(metaData)
//                }
//            case .paramDeclarations(let paramDeclarations):
//                print("// 🥥 paramDeclarations: \(paramDeclarations)")
//            case .type(let type):
//                print("// 🥥 type: \(type)")
//            case .typeCertainty(let typeCertainty):
//                print("// 🥥 typeCertainty: \(typeCertainty)")
//            case .zil(let zil):
//                print("// 🥥 zil: \(zil)")
//            case .zilName(let zilName):
//                print("// 🥥 zilName: \(zilName)")
            case .controlFlow(_):
                break
            case .isImmutable:
                break
            case .isLiteral:
                break
            case .paramContext:
                if !meta.contains(where: {
                    if case .paramContext = $0 { return true } else { return false }
                }) {
                    meta.insert(metaData)
                }
            case .paramDeclarations(_):
                break
            case .type(_):
                break
            case .typeCertainty(_):
                break
            case .zil(_):
                break
            case .zilName(_):
                break
            }
        }

        return revision
    }

    /// If a symbol represents a `return` statement with a return value, `returnValueType` provides
    /// the return value type. In all other cases, it returns `nil`.
    var returnValueType: Symbol.DataType? {
        for metaData in meta {
            if case .controlFlow(.returnValue(type: let type)) = metaData { return type }
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

    /// <#Description#>
    /// - Parameter value: <#value description#>
    func translate(_ value: String) -> String {
        switch type {
        case .bool:
            switch value {
            case "0", "false": return "false"
            default: return "true"
            }
        case .int, .int16, .int32, .int8:
            switch value {
            case "0", "false": return "0"
            case "true": return "1"
            default: return value
            }
        case .optional:
            switch value {
            case "0", "false": return "nil"
            default: return value
            }
        default:
            return value
        }
    }

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
        var codeValue: ((Symbol) throws -> String) {
            if let newCode = newCode {
                return { _ in newCode }
            } else {
                return codeBlock
            }
        }
        return Symbol(
            id: newID ?? id,
            code: codeValue,
            type: newType ?? type,
            category: newCategory ?? category,
            children: newChildren ?? children,
            meta: newMeta ?? meta
        )
    }

    func with(
        id newID: Symbol.Identifier? = nil,
        code newCode: @escaping (Symbol) throws -> String,
        type newType: DataType? = nil,
        category newCategory: Category? = nil,
        children newChildren: [Symbol]? = nil,
        meta newMeta: Set<MetaData>? = nil
    ) -> Symbol {
        Symbol(
            id: newID ?? id,
            code: newCode,
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
