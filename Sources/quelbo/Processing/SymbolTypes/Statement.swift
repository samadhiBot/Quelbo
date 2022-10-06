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
    private(set) var isAnonymousFunction: Bool
    private(set) var isBindWithAgainStatement: Bool
    private(set) var isCommittable: Bool
    private(set) var isMutable: Bool?
    private(set) var isReturnStatement: Bool
    private(set) var parameters: [Instance]
    private(set) var repeating: Bool
    private(set) var returnHandling: Symbol.ReturnHandling
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
        isAnonymousFunction: Bool = false,
        isBindWithAgainStatement: Bool = false,
        isCommittable: Bool = false,
        isMutable: Bool? = nil,
        isRepeating: Bool = false,
        isReturnStatement: Bool = false,
        returnHandling: Symbol.ReturnHandling = .implicit
    ) {
        self.activation = activation
        self.category = category
        self.children = children
        self.codeBlock = code
        self.id = id
        self.isAgainStatement = isAgainStatement
        self.isAnonymousFunction = isAnonymousFunction
        self.isBindWithAgainStatement = isBindWithAgainStatement
        self.isCommittable = isCommittable
        self.isMutable = isMutable
        self.isReturnStatement = isReturnStatement
        self.parameters = parameters
        self.repeating = isRepeating
        self.returnHandling = returnHandling
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

    func assertShouldReturn() {
        switch returnHandling {
        case .force:
            break
        case .implicit:
            returnHandling = .force
        case .suppress:
            children.forEach {
                if case .statement(let statement) = $0 {
                    statement.assertShouldReturn()
                }
            }
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
        isAnonymousFunction: Bool = false,
        isBindWithAgainStatement: Bool = false,
        isCommittable: Bool = false,
        isMutable: Bool? = nil,
        isRepeating: Bool = false,
        isReturnStatement: Bool = false,
        returnHandling: Symbol.ReturnHandling = .implicit
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
            isAnonymousFunction: isAnonymousFunction,
            isBindWithAgainStatement: isBindWithAgainStatement,
            isCommittable: isCommittable,
            isMutable: isMutable,
            isRepeating: isRepeating,
            isReturnStatement: isReturnStatement,
            returnHandling: returnHandling
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
                "isCommittable": self.isCommittable,
                "isMutable": self.isMutable as Any,
                "isRepeating": self.isRepeating,
                "isReturnStatement": self.isReturnStatement,
                "returnHandling": self.returnHandling,
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
        (
            lhs.parameters == rhs.parameters ||
            lhs.parameters.isEmpty ||
            rhs.parameters.isEmpty
        ) &&
        (
            lhs.children == rhs.children ||
            lhs.children.isEmpty ||
            rhs.children.isEmpty
        ) &&
        lhs.category == rhs.category &&
        lhs.activation == rhs.activation &&
        lhs.isAgainStatement == rhs.isAgainStatement &&
        lhs.isBindWithAgainStatement == rhs.isBindWithAgainStatement &&
        lhs.isCommittable == rhs.isCommittable &&
        lhs.isMutable == rhs.isMutable &&
        lhs.isRepeating == rhs.isRepeating &&
        lhs.isReturnStatement == rhs.isReturnStatement &&
        lhs.returnHandling == rhs.returnHandling
    }
}
