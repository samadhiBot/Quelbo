//
//  Statement.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/9/22.
//

import CustomDump
import Foundation

final class Statement: SymbolType {
    private(set) var activation: String?
    private(set) var category: Category?
    private(set) var children: [Symbol]
    private(set) var codeBlock: (Statement) throws -> String
    private(set) var id: String?
    private(set) var isAgainStatement: Bool
    private(set) var isBindWithAgainStatement: Bool
    private(set) var isMutable: Bool?
    private(set) var isReturnStatement: Bool
    private(set) var parameters: [Instance]
    private(set) var repeating: Bool
    private(set) var suppressesReturns: Bool
    private(set) var type: TypeInfo

    init(
        id: String? = nil,
        code: @escaping (Statement) throws -> String,
        type: TypeInfo,
        parameters: [Instance] = [],
        children: [Symbol] = [],
        category: Category? = nil,
        activation: String? = nil,
        isAgainStatement: Bool = false,
        isBindWithAgainStatement: Bool = false,
        isMutable: Bool? = nil,
        isRepeating: Bool = false,
        isReturnStatement: Bool = false,
        suppressesReturns: Bool = false
    ) {
        self.activation = activation
        self.category = category
        self.children = children
        self.codeBlock = code
        self.id = id
        self.isAgainStatement = isAgainStatement
        self.isBindWithAgainStatement = isBindWithAgainStatement
        self.isMutable = isMutable
        self.isReturnStatement = isReturnStatement
        self.parameters = parameters
        self.repeating = isRepeating
        self.suppressesReturns = suppressesReturns
        self.type = type
    }

    var code: String {
        do {
            return try codeBlock(self)
                .replacingOccurrences(of: "try try", with: "try")
        } catch {
            return "Statement:code:\(error)"
        }
    }

    var isRepeating: Bool {
        repeating || children.contains {
            guard case .statement(let statement) = $0 else { return false }
            return statement.isAgainStatement
        }
    }
}

// MARK: - Symbol Statement initializer

extension Symbol {
    static func statement(
        id: String? = nil,
        code: @escaping (Statement) throws -> String,
        type: TypeInfo,
        parameters: [Instance] = [],
        children: [Symbol] = [],
        category: Category? = nil,
        activation: String? = nil,
        isAgainStatement: Bool = false,
        isBindWithAgainStatement: Bool = false,
        isMutable: Bool? = nil,
        isRepeating: Bool = false,
        isReturnStatement: Bool = false,
        suppressesReturns: Bool = false
    ) -> Symbol {
        .statement(Statement(
            id: id,
            code: code,
            type: type,
            parameters: parameters,
            children: children,
            category: category,
            activation: activation,
            isAgainStatement: isAgainStatement,
            isBindWithAgainStatement: isBindWithAgainStatement,
            isMutable: isMutable,
            isRepeating: isRepeating,
            isReturnStatement: isReturnStatement,
            suppressesReturns: suppressesReturns
        ))
    }
}

// MARK: - Special assertion handlers

extension Statement {
    func assertHasType(_ assertedType: TypeInfo) throws {
        guard let reconciled = type.reconcile(with: assertedType) else {
            throw Symbol.AssertionError.hasTypeAssertionStatementFailed(
                for: id ?? code,
                asserted: assertedType,
                actual: type
            )
        }

        self.type = reconciled

        for symbol in children {
            guard
                case .statement(let statement) = symbol,
                statement.isReturnStatement
            else { continue }

            try statement.assertHasType(assertedType)
        }
    }
}

// MARK: - Conformances

extension Statement: CustomDumpReflectable {
    var customDumpMirror: Mirror {
        .init(
            self,
            children: [
                "id": self.id as Any,
                "code": self.code,
                "type": self.type as Any,
                "parameters": self.parameters,
                "category": self.category as Any,
                "activation": self.activation as Any,
                "isAgainStatement": self.isAgainStatement,
                "isBindWithAgainStatement": self.isBindWithAgainStatement,
                "isMutable": self.isMutable as Any,
                "isRepeating": self.isRepeating,
                "isReturnStatement": self.isReturnStatement,
                "suppressesReturns": self.suppressesReturns
            ],
            displayStyle: .struct
        )
    }
}

extension Statement: Equatable {
    static func == (lhs: Statement, rhs: Statement) -> Bool {
        lhs.id == rhs.id &&
        lhs.code == rhs.code &&
        lhs.type == rhs.type &&
        lhs.parameters == rhs.parameters &&
        lhs.category == rhs.category &&
        lhs.activation == rhs.activation &&
        lhs.isAgainStatement == rhs.isAgainStatement &&
        lhs.isBindWithAgainStatement == rhs.isBindWithAgainStatement &&
        lhs.isMutable == rhs.isMutable &&
        lhs.isRepeating == rhs.isRepeating &&
        lhs.isReturnStatement == rhs.isReturnStatement &&
        lhs.suppressesReturns == rhs.suppressesReturns
    }
}
